import assert from 'node:assert/strict';
import {chromium} from 'playwright';
import {createServer} from 'vite';

const server=await createServer({mode:'demo',server:{host:'127.0.0.1',port:5203,strictPort:true}});
await server.listen();
let browser;
const errors=[];
const base='http://127.0.0.1:5203';
try{
  browser=await chromium.launch({headless:true});
  const page=await browser.newPage({viewport:{width:1440,height:900}});
  page.setDefaultTimeout(15000);
  page.on('pageerror',e=>errors.push(e.message));
  const login=async role=>{
    await page.goto(base+'/account');
    await page.locator('#page-main').waitFor();
    await page.getByLabel('Email address',{exact:true}).fill(role+'@gearlane.demo');
    await page.getByLabel('Password',{exact:true}).fill('Demo'+role[0].toUpperCase()+role.slice(1)+'123!');
    await page.locator('form').filter({has:page.getByLabel('Password',{exact:true})}).getByRole('button',{name:'Sign in',exact:true}).click();
    await page.waitForURL(role==='customer'?'**/shop':'**/workspace');
  };
  const logout=async()=>{await page.goto(base+'/account');await page.getByRole('button',{name:'Sign out',exact:true}).click();await page.waitForURL(base+'/');};
  const meta=name=>page.evaluate(n=>document.querySelector(`meta[name="${n}"]`)?.content||null,name);

  // ---- Search visibility: titles, canonical, noindex on private pages, product structured data
  await page.goto(base+'/shop?category=Engine%20Oil');
  await page.locator('.product-card').first().waitFor();
  assert.match(await page.title(),/^Engine Oil/);
  assert.match(await page.evaluate(()=>document.querySelector('link[rel=canonical]').href),/\/shop\?category=Engine%20Oil$/);
  assert.equal(await meta('robots'),'index,follow');
  const pick=await page.evaluate(()=>{const s=JSON.parse(localStorage.getItem('gearlane_preview_v1'));return{inStock:s.products.find(p=>p.active&&p.price_confirmed&&p.stock>5&&!s.fitment.some(f=>f.product_id===p.id)),out:s.products.find(p=>p.active&&p.price_confirmed&&p.stock===0&&!s.fitment.some(f=>f.product_id===p.id))};});
  assert.ok(pick.inStock&&pick.out,'demo data has an in-stock and an out-of-stock confirmed product');
  await page.goto(base+'/products/'+pick.inStock.id);
  await page.getByRole('heading',{level:1}).waitFor();
  const ld=JSON.parse(await page.evaluate(()=>document.querySelector('script[data-seo=jsonld]').textContent));
  assert.equal(ld['@type'],'Product');assert.equal(ld.offers.priceCurrency,'MYR');
  await page.goto(base+'/cart');await page.locator('#page-main').waitFor();
  assert.equal(await meta('robots'),'noindex,nofollow');

  // ---- Vehicle finder (guest): only fitment the store listed, never a guess
  await page.goto(base+'/shop');
  await page.locator('.vehicle-bar').waitFor();
  const makeOptions=await page.getByLabel('Vehicle make').locator('option').allTextContents();
  assert.ok(makeOptions.length>1&&makeOptions[0]==='Make');
  await page.getByLabel('Vehicle make').selectOption({index:1});
  assert.equal(await page.getByLabel('Vehicle model').isDisabled(),false,'choosing a make enables models');
  await page.getByLabel('Vehicle model').selectOption({index:1});
  await page.locator('.vehicle-summary').waitFor();
  assert.match(page.url(),/vehicle=/);
  const listed=await page.locator('.product-card').count();
  assert.ok(listed>=1,'at least one part is listed for the chosen vehicle');
  await page.getByRole('button',{name:'Clear vehicle',exact:true}).click();
  await page.waitForFunction(()=>!location.search.includes('vehicle='));
  assert.equal(await page.locator('.vehicle-summary').count(),0);

  // ---- Follow an out-of-stock part as a customer
  await login('customer');
  await page.goto(base+'/products/'+pick.out.id);
  const detail=page.locator('.detail-info'),follow=detail.getByRole('button',{name:'Notify me when back in stock'});
  await follow.click();
  await detail.getByRole('button',{name:/Following/}).waitFor();
  assert.equal(await detail.getByRole('button',{name:/Following/}).getAttribute('aria-pressed'),'true');
  await logout();

  // ---- Admin restocks it and lists its vehicles (with validation)
  await login('admin');
  await page.goto(base+'/workspace/products');
  await page.getByLabel('Search managed products').fill(pick.out.sku);
  await page.locator('tbody tr',{hasText:pick.out.sku}).getByRole('button',{name:'Edit'}).first().click();
  const dialog=page.getByRole('dialog');
  await dialog.getByLabel('Actual units in stock').fill('7');
  const vehicles=dialog.getByLabel('Vehicles this product is listed for');
  await vehicles.fill('Proton');
  await dialog.getByRole('button',{name:'Save product'}).click();
  await dialog.getByText(/Line 1: use "Make, Model, Years"/).waitFor();
  assert.ok(await dialog.isVisible(),'a bad vehicle list blocks the save and keeps the form open');
  await vehicles.fill('Proton, X50, 2020-2024\nPerodua, Myvi');
  await dialog.getByRole('button',{name:'Save product'}).click();
  await dialog.waitFor({state:'hidden'});
  await page.goto(base+'/workspace');
  await page.locator('.kpi-grid').waitFor();
  assert.ok(await page.locator('.stat-card .delta').count()>=1,'KPI cards compare with the previous period');
  assert.match(await page.locator('.stat-card .delta').first().textContent(),/(▲|▼|No change|New).*(previous \d+ days|none in the previous)/);

  // ---- Settings are sectioned and still save
  await page.goto(base+'/workspace/settings');
  await page.locator('fieldset.settings-section').first().waitFor();
  assert.equal(await page.locator('fieldset.settings-section').count(),5);
  await page.getByRole('button',{name:'Save store settings'}).click();
  await page.getByText('Store settings saved.').waitFor();
  await logout();

  // ---- Customer is told, and sees the vehicles it is listed for
  await login('customer');
  await page.getByRole('button',{name:'Notifications'}).click();
  await page.getByText('Back in stock: '+pick.out.name.slice(0,60)).first().waitFor();
  await page.keyboard.press('Escape');
  await page.goto(base+'/products/'+pick.out.id);
  await page.locator('.fitment-panel').waitFor();
  assert.match(await page.locator('.fitment-panel').textContent(),/Proton X50.*2020–2024/);
  assert.match(await page.locator('.fitment-panel').textContent(),/Perodua Myvi.*all years/);
  assert.match(await page.locator('.fitment-panel').textContent(),/not a manufacturer guarantee/);
  assert.equal(await page.locator('.detail-info').getByRole('button',{name:/Notify me when back in stock|Following/}).count(),0,'no follow button once it is in stock');
  // choosing Proton X50 now lists this part
  await page.goto(base+'/shop?vehicle='+encodeURIComponent('Proton|X50|2022'));
  await page.locator('.product-card',{hasText:pick.out.name}).first().waitFor();
  await page.goto(base+'/shop?vehicle='+encodeURIComponent('Proton|X50|2018'));
  await page.locator('.vehicle-summary').waitFor();
  assert.equal(await page.locator('.product-card',{hasText:pick.out.name}).count(),0,'2018 is outside the listed years');

  assert.deepEqual(errors,[]);
  console.log('Feature checks passed: SEO metadata, vehicle finder, back-in-stock follow and notification, fitment editor with validation, period comparison and sectioned settings.');
}finally{
  await browser?.close();
  await server.close();
}
