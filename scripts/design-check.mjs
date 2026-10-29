import assert from 'node:assert/strict';
import {chromium} from 'playwright';
import {createServer} from 'vite';

const server = await createServer({mode:'demo',server:{host:'127.0.0.1',port:5196,strictPort:true}});
await server.listen();
let browser;
const errors = [];
const base = 'http://127.0.0.1:5196';
try {
  browser = await chromium.launch({headless:true});
  const page = await browser.newPage({viewport:{width:1440,height:900}});
  page.setDefaultTimeout(10000);
  page.on('pageerror', e => errors.push(e.message));
  const login = async role => {
    await page.goto(base + '/account');
    await page.locator('#page-main').waitFor();
    await page.getByLabel('Email address', {exact:true}).fill(role + '@gearlane.demo');
    await page.getByLabel('Password', {exact:true}).fill('Demo' + role[0].toUpperCase() + role.slice(1) + '123!');
    await page.locator('form').filter({has:page.getByLabel('Password', {exact:true})}).getByRole('button', {name:'Sign in', exact:true}).click();
    await page.waitForURL(role === 'customer' ? '**/shop' : '**/workspace');
  };
  const noScrollbar = (selector) => page.evaluate(sel => [...document.querySelectorAll(sel)].every(el => {
    const style = getComputedStyle(el);
    return style.scrollbarWidth === 'none' || el.offsetHeight === el.clientHeight && el.offsetWidth === el.clientWidth;
  }), selector);

  // Storefront header: sticky, no scrollbar in navigation, accent search button
  await page.goto(base + '/shop');
  await page.locator('#page-main').waitFor();
  assert.equal(await page.evaluate(() => getComputedStyle(document.querySelector('.store-header')).position), 'sticky');
  assert.ok(await noScrollbar('.shop-navigation, .category-chips, .primary-navigation-wrap'), 'storefront navigation shows a scrollbar');
  await page.mouse.wheel(0, 900);
  await page.waitForTimeout(300);
  const headerTop = await page.evaluate(() => Math.round(document.querySelector('.store-header').getBoundingClientRect().top));
  assert.equal(headerTop, 0, 'header stays pinned while scrolling and is not covered by the demo banner');

  // Customer: receive an order, rate with stars and highlights, see it on the product page
  await login('customer');
  await page.goto(base + '/orders');
  await page.locator('#page-main').waitFor();
  // Put one of the customer's demo orders into the "received" state so the receipt-gated review form opens
  const reviewable = await page.evaluate(() => {
    const key = 'gearlane_preview_v1', state = JSON.parse(localStorage.getItem(key));
    const me = state.users.find(u => u.email === 'customer@gearlane.demo');
    const order = state.orders.find(o => o.customer_id === me.id && o.items.length && o.status !== 'cancelled');
    order.payment_status = 'verified';
    order.status = 'delivered';
    order.received_at = order.received_at || new Date().toISOString();
    state.reviews = state.reviews.filter(r => r.order_id !== order.id);
    localStorage.setItem(key, JSON.stringify(state));
    return {order:order.id, product:order.items[0].product_id};
  });
  await page.reload();
  await page.locator('#page-main').waitFor();
  {
    await page.goto(base + '/orders/' + reviewable.order);
    await page.getByRole('button', {name:'Review item'}).first().click();
    const dialog = page.getByRole('dialog');
    const radios = dialog.getByRole('radio');
    assert.equal(await radios.count(), 5, 'five stars to choose from');
    assert.equal(await dialog.locator('select').count(), 0, 'no rating dropdown remains');
    await radios.nth(3).click();
    assert.equal(await radios.nth(3).getAttribute('aria-checked'), 'true');
    await radios.nth(3).press('ArrowRight');
    assert.equal(await radios.nth(4).getAttribute('aria-checked'), 'true', 'arrow keys move the rating');
    await radios.nth(4).press('ArrowLeft');
    assert.match(await dialog.getByText(/4\/5/).first().textContent(), /Good/);
    await dialog.getByRole('button', {name:'Quality', exact:true}).click();
    await dialog.getByRole('button', {name:'Value for money', exact:true}).click();
    await dialog.getByLabel('Your feedback', {exact:true}).fill('Design check: solid part and fair price.');
    await dialog.getByRole('button', {name:'Submit verified review'}).click();
    await dialog.waitFor({state:'hidden'});
    await page.goto(base + '/products/' + reviewable.product);
    await page.getByRole('tab', {name:/Reviews/}).click();
    await page.getByText('Design check: solid part and fair price.').waitFor();
    assert.equal(await page.getByText('[Highlights').count(), 0, 'encoded highlight line is never shown to readers');
    await page.locator('.review-tags span', {hasText:'Value for money'}).first().waitFor();
    await page.locator('.review-bars').waitFor();
    await page.getByRole('button', {name:/^4 star/}).first().click();
    assert.ok(await page.locator('.review-card').count() >= 1);
  }
  await page.goto(base + '/account');
  await page.getByRole('button', {name:'Sign out', exact:true}).click();
  await page.waitForURL(base + '/');

  // Admin dashboard: widgets exist, are interactive and nothing overflows
  await login('admin');
  await page.locator('.kpi-grid').waitFor();
  for (const selector of ['.work-queue', '.trend-chart', '.pipeline', '.donut', '.top-products']) await page.locator(selector).first().waitFor();
  assert.ok(await page.locator('.pipeline-row').count() >= 5, 'pipeline stages');
  assert.ok(await page.locator('.donut-legend li').count() >= 2, 'donut legend');
  assert.ok(await page.locator('.top-products li').count() >= 1, 'top products');
  await page.locator('.trend-chart .bar-chart button').nth(3).click();
  assert.match(await page.locator('.chart-readout').textContent(), /RM/);
  await page.getByRole('button', {name:'Active hours', exact:true}).click();
  await page.locator('.trend-chart .bar-chart button').first().click();
  await page.getByLabel('Analytics period', {exact:true}).selectOption('7');
  await page.locator('.trend-chart').waitFor();
  assert.ok(await noScrollbar('.workspace-sidebar, .workspace-sidebar nav'), 'workspace sidebar shows a scrollbar');
  for (const width of [390, 768, 1024, 1440]) {
    await page.setViewportSize({width, height: width < 760 ? 844 : 900});
    await page.waitForTimeout(250);
    const overflow = await page.evaluate(() => document.documentElement.scrollWidth - innerWidth);
    assert.ok(overflow <= 1, 'dashboard overflows horizontally at ' + width + 'px by ' + overflow);
  }
  assert.deepEqual(errors, []);
  console.log('Design checks passed: pinned header, scrollbar-free navigation, star ratings with highlights, review summary, dashboard widgets and layouts.');
} finally {
  await browser?.close();
  await server.close();
}
