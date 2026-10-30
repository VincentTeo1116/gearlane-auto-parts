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

  // The sample-data announcement is for staff and never reaches shoppers; real announcements still do
  await page.goto(base + '/shop');
  await page.locator('.product-card').first().waitFor();
  await page.evaluate(() => {const key = 'gearlane_preview_v1', s = JSON.parse(localStorage.getItem(key));const now = new Date().toISOString();s.announcements.push({id:'31000000-0000-4000-8000-000000000001', title:'Testing data enabled', body:'This test store includes fictional customer orders.', active:true, created_at:now}, {id:crypto.randomUUID(), title:'Workshop hours this week', body:'We close early on Friday.', active:true, created_at:now});localStorage.setItem(key, JSON.stringify(s));});
  await page.goto(base + '/');
  await page.getByText('Workshop hours this week').waitFor();
  assert.equal(await page.getByText('Testing data enabled').count(), 0, 'the sample-data announcement is hidden from shoppers');

  // Storefront header: sticky, no scrollbar in navigation, accent search button
  await page.goto(base + '/shop');
  await page.locator('#page-main').waitFor();
  assert.equal(await page.evaluate(() => getComputedStyle(document.querySelector('.store-header')).position), 'sticky');
  assert.ok(await noScrollbar('.shop-navigation, .category-chips, .primary-navigation-wrap'), 'storefront navigation shows a scrollbar');
  await page.mouse.wheel(0, 900);
  await page.waitForTimeout(300);
  const headerTop = await page.evaluate(() => Math.round(document.querySelector('.store-header').getBoundingClientRect().top));
  assert.equal(headerTop, 0, 'header stays pinned while scrolling and is not covered by the demo banner');

  // Phone header: logo + name, cart and menu share one row, with the search directly below
  const headerOneRow = async label => {
    const box = await page.evaluate(() => {
      const rect = selector => {const el = document.querySelector(selector);if (!el) return null;const b = el.getBoundingClientRect();return {top:b.top, bottom:b.bottom, left:b.left, right:b.right, mid:(b.top + b.bottom) / 2};};
      return {brand:rect('.header-main > .brand'), cart:rect('.header-cart'), menu:rect('.mobile-menu'), search:rect('.header-search'), width:innerWidth};
    });
    assert.ok(Math.abs(box.brand.mid - box.cart.mid) < 12 && Math.abs(box.cart.mid - box.menu.mid) < 12, label + ': brand, cart and menu are not on one row ' + JSON.stringify(box));
    assert.ok(box.search.top >= box.brand.bottom - 2 && box.search.top >= box.cart.bottom - 2, label + ': search should sit below the first row');
    assert.ok(box.menu.right <= box.width && box.brand.right <= box.cart.left + 1, label + ': header content overflows');
  };
  for (const width of [320, 360, 390, 430, 600]) {
    await page.setViewportSize({width, height:800});
    await page.goto(base + '/');
    await page.locator('.header-main').waitFor();
    await headerOneRow('guest ' + width + 'px');
  }
  await page.setViewportSize({width:1440, height:900});

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
  for (const width of [320, 390]) {
    await page.setViewportSize({width, height:800});
    await page.goto(base + '/shop');
    await page.locator('.header-main').waitFor();
    assert.equal(await page.locator('.notification-control').count(), 1, 'signed-in header includes the bell');
    await headerOneRow('signed-in ' + width + 'px');
  }
  await page.setViewportSize({width:1440, height:900});

  // Promotion codes are checked one at a time; the customer's data never contains the code list
  await page.evaluate(() => {
    const key = 'gearlane_preview_v1', state = JSON.parse(localStorage.getItem(key));
    state.promotions = [{id:crypto.randomUUID(), code:'SAVE10', kind:'percent', value:10, minimum_cents:0, maximum_uses:5, used_count:0, starts_at:new Date(Date.now() - 864e5).toISOString(), ends_at:new Date(Date.now() + 864e5).toISOString(), active:true}];
    localStorage.setItem(key, JSON.stringify(state));
    localStorage.setItem('gearlane_cart', '[]');
  });
  await page.goto(base + '/shop');
  await page.locator('.product-card .add-button').first().click();
  await page.goto(base + '/checkout');
  await page.locator('summary', {hasText:'promotion code'}).click();
  await page.getByLabel('Promotion code', {exact:true}).fill('wrongcode');
  await page.getByRole('button', {name:'Apply', exact:true}).click();
  await page.getByText('That promotion code is not valid.').waitFor();
  assert.equal(await page.getByText('SAVE10').count(), 0, 'a wrong guess never reveals real codes');
  await page.getByLabel('Promotion code', {exact:true}).fill('save10');
  await page.getByRole('button', {name:'Apply', exact:true}).click();
  await page.getByText('Code SAVE10 applied.').waitFor();
  await page.locator('.totals dt', {hasText:'Promotion'}).waitFor();
  await page.getByRole('button', {name:'Remove', exact:true}).click();
  assert.equal(await page.locator('.totals dt', {hasText:'Promotion'}).count(), 0, 'removing the code removes the discount');
  await page.goto(base + '/account');
  await page.getByRole('button', {name:'Sign out', exact:true}).click();
  await page.waitForURL(base + '/');

  // Admin dashboard: widgets exist, are interactive and nothing overflows
  await login('admin');
  await page.locator('.kpi-grid').waitFor();
  assert.equal(await page.getByText(/testing database includes fictional/i).count(), 0, 'no "testing database" banner on the dashboard');
  for (const selector of ['.hero-stat', '.action-center', '.trend-chart', '.pipeline', '.donut', '.top-products']) await page.locator(selector).first().waitFor();
  assert.ok(await page.locator('.pipeline-row').count() >= 5, 'pipeline stages');
  assert.ok(await page.locator('.donut-legend li').count() >= 2, 'donut legend');
  assert.ok(await page.locator('.top-products li').count() >= 1, 'top products');
  await page.locator('.trend-chart .bar-chart button').nth(3).click();
  assert.match(await page.locator('.chart-readout').textContent(), /RM/);
  // The sales chart: every day on the axis, bars across the full width, readable non-overlapping date labels
  const chartGeometry = () => page.evaluate(() => {
    const plot = document.querySelector('.trend-chart .plot').getBoundingClientRect();
    const bars = [...document.querySelectorAll('.trend-chart .bar-chart button')].map(b => b.getBoundingClientRect());
    const ticks = [...document.querySelectorAll('.trend-chart .x-tick')].map(t => {const r = t.getBoundingClientRect();return {left:r.left, right:r.right, size:parseFloat(getComputedStyle(t).fontSize), text:t.textContent};});
    const baseline = [...document.querySelectorAll('.trend-chart .bar-chart button:not(.zero) > span')].map(b => Math.round(plot.bottom - b.getBoundingClientRect().bottom));
    return {plot:{left:plot.left, right:plot.right, width:plot.width}, count:bars.length, first:bars[0].left, last:bars.at(-1).right, ticks, baseline};
  });
  for (const [period, expected] of [['7', 7], ['30', 30], ['90', 13]]) {
    await page.getByLabel('Analytics period', {exact:true}).selectOption(period);
    await page.locator('.trend-chart .bar-chart button').nth(expected - 1).waitFor();
    const g = await chartGeometry();
    assert.equal(g.count, expected, period + ' days: bar count (90 days is shown as weekly bars)');
    assert.ok(g.first - g.plot.left < 6 && g.plot.right - g.last < 6, period + ' days: bars span the whole plot, not a corner of it ' + JSON.stringify([g.first, g.last, g.plot]));
    assert.ok(g.plot.width / g.count >= 5, period + ' days: bars are wide enough to see');
    assert.ok(g.ticks.length >= 2, period + ' days: the axis has date labels');
    for (const tick of g.ticks) assert.ok(tick.size >= 12.4, period + ' days: label "' + tick.text + '" is ' + tick.size + 'px, too small to read');
    const sorted = [...g.ticks].sort((a, b) => a.left - b.left);
    sorted.slice(1).forEach((tick, i) => assert.ok(tick.left >= sorted[i].right + 6, period + ' days: labels "' + sorted[i].text + '" and "' + tick.text + '" touch'));
    assert.ok(sorted.at(-1).right <= g.plot.right + 6 && sorted[0].left >= g.plot.left - 40, period + ' days: labels stay inside the chart');
    assert.ok(g.baseline.every(b => b <= 1), period + ' days: every bar stands on the baseline, none floats');
  }
  await page.getByLabel('Analytics period', {exact:true}).selectOption('30');
  await page.locator('.trend-chart .bar-chart button').nth(3).hover();
  assert.match(await page.locator('.trend-chart .bar-chart button').nth(3).evaluate(el => el.dataset.tip), /^\w{3} \d+ \w{3} · RM/, 'each bar carries its date and amount');
  await page.getByRole('button', {name:'Active hours', exact:true}).click();
  await page.locator('.trend-chart .bar-chart button').first().click();
  await page.getByLabel('Analytics period', {exact:true}).selectOption('7');
  await page.locator('.trend-chart').waitFor();
  assert.ok(await noScrollbar('.workspace-sidebar, .workspace-sidebar nav'), 'workspace sidebar shows a scrollbar');
  for (const width of [390, 768, 1024, 1440]) {
    await page.setViewportSize({width, height: width < 760 ? 844 : 900});
    await page.waitForTimeout(250);
    const narrow = await chartGeometry();
    for (const tick of narrow.ticks) assert.ok(tick.size >= 12, width + 'px: chart label "' + tick.text + '" is ' + tick.size + 'px');
    const order = [...narrow.ticks].sort((a, b) => a.left - b.left);
    order.slice(1).forEach((tick, i) => assert.ok(tick.left >= order[i].right + 4, width + 'px: chart labels "' + order[i].text + '" and "' + tick.text + '" touch'));
    assert.ok(order.at(-1).right <= narrow.plot.right + 6, width + 'px: the last chart label stays inside the chart');
    const overflow = await page.evaluate(() => document.documentElement.scrollWidth - innerWidth);
    assert.ok(overflow <= 1, 'dashboard overflows horizontally at ' + width + 'px by ' + overflow);
  }
  assert.deepEqual(errors, []);
  console.log('Design checks passed: pinned header, one-row phone header, scrollbar-free navigation, star ratings with highlights, review summary, private promotion-code checking and dashboard widgets and layouts.');
} finally {
  await browser?.close();
  await server.close();
}
