import assert from 'node:assert/strict';
import {chromium} from 'playwright';
import {createServer} from 'vite';
import {mkdir} from 'node:fs/promises';

const server = await createServer({mode:'demo',server:{host:'127.0.0.1',port:5189,strictPort:true}});
await server.listen();
let browser;
const errors = [];
const sizes = [320,390,768,1024,1440,1920];
try {
  browser = await chromium.launch({headless:true});
  const page = await browser.newPage({viewport:{width:1440,height:1000}});
  page.setDefaultTimeout(10000);
  page.setDefaultNavigationTimeout(15000);
  page.on('pageerror',e=>errors.push(e.message));
  const base='http://127.0.0.1:5189';
  await mkdir('.generated/responsive',{recursive:true});
  const visit=async route=>{
    await page.goto(base+route);
    await page.locator('#page-main').waitFor();
    await page.locator('.loading-screen').waitFor({state:'hidden'});
    await page.locator('.fatal').waitFor({state:'hidden'});
    await page.locator('#page-main').waitFor();
  };
  const fits=async route=>{
    const result=await page.evaluate(()=>({width:innerWidth,scroll:document.documentElement.scrollWidth,offenders:[...document.querySelectorAll('#page-main *')].filter(el=>{const r=el.getBoundingClientRect();return r.width&&r.right>innerWidth+2&&getComputedStyle(el).position!=='fixed'&&!el.closest('.table-scroll');}).slice(0,5).map(el=>el.className)}));
    assert.ok(result.scroll<=result.width+1,route+': '+JSON.stringify(result));
    assert.equal(await page.locator('.fatal').count(),0);
  };
  const login=async role=>{
    await visit('/account');
    if(await page.getByRole('button',{name:'Sign out',exact:true}).count()){
      await page.getByRole('button',{name:'Sign out',exact:true}).click();
      await page.waitForURL(base+'/');
      await visit('/account');
    }
    await page.getByLabel('Email address',{exact:true}).fill(role+'@gearlane.demo');
    await page.getByLabel('Password',{exact:true}).fill('Demo'+role[0].toUpperCase()+role.slice(1)+'123!');
    await page.locator('form').filter({has:page.getByLabel('Password',{exact:true})}).getByRole('button',{name:'Sign in',exact:true}).click();
    await page.waitForURL(role==='customer'?'**/shop':'**/workspace');
  };
  await visit('/shop');
  await page.locator('.product-card').first().locator('.add-button').click();
  await page.getByRole('button',{name:'View cart',exact:true}).click();
  await page.waitForURL('**/cart');
  await login('customer');
  await visit('/cart');
  assert.equal(await page.locator('.cart-row').count(),1,'Guest cart survives sign-in');
  await visit('/shop');
  const product=await page.locator('.product-name').first().getAttribute('href');
  await page.locator('.product-card').first().locator('.add-button').click();
  await page.getByRole('button',{name:'View cart',exact:true}).click();
  await page.waitForURL('**/cart');
  for(const width of sizes){
    await page.setViewportSize({width,height:width<760?844:1000});
    for(const route of ['/','/shop',product,'/cart','/checkout','/orders','/messages','/account']){
      await visit(route);await fits(route);
      if(route==='/shop'){
        if(width<=760){
          assert.equal(await page.locator('.filters').isVisible(),false);
          await page.getByRole('button',{name:'Filters',exact:true}).click();
          assert.equal(await page.locator('.filters').isVisible(),true);
          await page.locator('.filters').getByLabel('Category',{exact:true}).selectOption('Engine Oil');
          await page.getByRole('button',{name:/Show 11 products/}).click();
          assert.equal(await page.locator('.filters').isVisible(),false);
          assert.equal(await page.locator('.product-card').count(),11);
        }else assert.equal(await page.locator('.filters').isVisible(),true);
      }
      if([390,768,1440].includes(width)&&['/','/shop','/cart','/checkout','/messages'].includes(route))await page.screenshot({path:'.generated/responsive/customer-'+width+'-'+(route.slice(1)||'home')+'.png',fullPage:true});
    }
    console.log('Customer layouts passed at '+width+'px');
  }
  await page.setViewportSize({width:390,height:844});
  await visit('/checkout');
  await page.getByRole('button',{name:'Continue to review',exact:true}).click();
  assert.equal(await page.getByRole('heading',{name:'Where should we send your order?'}).count(),1,'Invalid delivery cannot advance');
  for(const [name,value] of [['Full name','Responsive Buyer'],['Phone number','0123456789'],['Delivery address','12 Jalan Responsive, Taman Test'],['City','Petaling Jaya'],['Postcode','47300']])await page.getByLabel(name,{exact:true}).fill(value);
  await page.getByRole('button',{name:'Continue to review',exact:true}).click();
  await page.getByRole('heading',{name:'Everything look right?'}).waitFor();
  await fits('checkout review');
  await page.screenshot({path:'.generated/responsive/checkout-review-390.png',fullPage:true});
  await page.getByRole('button',{name:'Edit address',exact:true}).click();
  assert.equal(await page.getByLabel('Delivery address',{exact:true}).inputValue(),'12 Jalan Responsive, Taman Test');
  await visit('/');
  await page.getByRole('button',{name:'See how it works',exact:true}).click();
  await page.getByRole('dialog').waitFor();
  assert.equal(await page.locator('.guide-list > li').count(),4);
  await page.keyboard.press('Escape');
  assert.equal(await page.getByRole('dialog').count(),0);
  await login('admin');
  await page.evaluate(()=>{const state=JSON.parse(localStorage.getItem('gearlane_preview_v1'));state.settings.checkout_enabled=false;localStorage.setItem('gearlane_preview_v1',JSON.stringify(state));});
  for(const width of sizes){
    await page.setViewportSize({width,height:width<760?844:1000});
    for(const route of ['/workspace','/workspace/orders','/workspace/products','/workspace/users','/workspace/promotions','/workspace/settings','/workspace/messages']){
      await visit(route);await fits(route);
      if(route==='/workspace/products'&&width<=560){
        await page.locator('td[data-label="Price"]').first().waitFor();
        assert.ok(await page.locator('td[data-label="Price"]').count()>0,'Mobile product cards retain field labels');
        assert.equal(await page.locator('.table-scroll thead').isVisible(),false);
        await page.getByRole('button',{name:/Edit /}).first().click();
        await page.getByRole('dialog').waitFor();await fits('product dialog');await page.keyboard.press('Escape');
      }
      if([390,768,1440].includes(width)&&['/workspace','/workspace/products','/workspace/settings'].includes(route))await page.screenshot({path:'.generated/responsive/admin-'+width+'-'+route.split('/').at(-1)+'.png',fullPage:true});
    }
    if(width<=1024){
      await page.getByRole('button',{name:'Toggle workspace navigation',exact:true}).click();
      await page.waitForFunction(()=>document.querySelector('.workspace-sidebar').getBoundingClientRect().left===0);
      await page.getByRole('button',{name:'Close workspace menu',exact:true}).click();
    }
    console.log('Admin layouts passed at '+width+'px');
  }
  await visit('/workspace');
  await page.getByRole('link',{name:/Verify payments/}).click();
  await page.waitForURL('**/workspace/orders?payment=submitted');
  assert.equal(await page.getByLabel('Payment status',{exact:true}).inputValue(),'submitted');
  await page.getByLabel('Payment status',{exact:true}).selectOption('all');
  await login('worker');
  for(const width of [390,768,1440]){
    await page.setViewportSize({width,height:width<760?844:1000});
    for(const route of ['/workspace','/workspace/orders','/workspace/restock','/workspace/messages','/workspace/refunds','/workspace/reviews']){await visit(route);await fits(route);}
    console.log('Worker layouts passed at '+width+'px');
  }
  assert.deepEqual(errors,[]);
  console.log('Responsive and usability checks passed: 6 widths, all major customer/admin screens, filters, checkout validation/back navigation, cart continuation, guide dialog and priority queue filters.');
} finally {await browser?.close();await server.close();}
