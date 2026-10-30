import assert from 'node:assert/strict';
import {readFile} from 'node:fs/promises';
import {chromium} from 'playwright';
import {createServer} from 'vite';

/* Behaviour with a large store: 2,500 products, 1,500 orders, 1,200 reviews on one product, 500 users.
   The demo keeps its data in the browser (about 5 MB), so seeded records are lean copies of real ones.
   This exercises the interface (rendering, paging, exports), not Supabase. Budgets are generous so a slow CI
   runner does not cause false alarms, yet they still catch "renders everything at once" mistakes. */
const PRODUCTS=2500,ORDERS=1500,REVIEWS=1200,USERS=500;
const BUDGET={firstRender:8000,interaction:3000,dashboard:8000};

const server=await createServer({mode:'demo',server:{host:'127.0.0.1',port:5202,strictPort:true}});
await server.listen();
let browser;
const errors=[];
const base='http://127.0.0.1:5202';
const timed=async fn=>{const start=Date.now();const value=await fn();const ms=Date.now()-start;if(process.env.LOAD_VERBOSE)console.log('  timing',ms+'ms');return{ms,value};};
try{
  browser=await chromium.launch({headless:true});
  const page=await browser.newPage({viewport:{width:1440,height:900},acceptDownloads:true});
  page.setDefaultTimeout(20000);
  page.on('pageerror',e=>errors.push(e.message));
  await page.goto(base+'/shop');
  await page.locator('.product-card').first().waitFor();

  const seeded=await page.evaluate(({PRODUCTS,ORDERS,REVIEWS,USERS})=>{
    const key='gearlane_preview_v1',state=JSON.parse(localStorage.getItem(key));
    const baseProducts=state.products.filter(p=>p.active),baseOrders=state.orders.filter(o=>o.items.length);
    const customers=state.users.filter(u=>u.role==='customer');
    for(let i=0;state.products.length<PRODUCTS;i++){
      const p=baseProducts[i%baseProducts.length],id='load-p'+i;
      state.products.push({...p,id,sku:'LOAD-'+i,name:p.name+' #'+i,description:'Load test product description.',specs:{},source_note:'',source_url:null,price_source_url:null,stock:i%7===0?0:20+i%80,active:true});
      if(i%3===0)state.fitment.push({id:'load-f'+i,product_id:id,make:['Proton','Perodua','Toyota','Honda'][i%4],model:'Model '+(i%25),year_from:null,year_to:null});
    }
    let number=Math.max(...state.orders.map(o=>o.order_number))+1;
    for(let i=0;state.orders.length<ORDERS;i++){
      const o=baseOrders[i%baseOrders.length];
      state.orders.push({...o,id:crypto.randomUUID(),order_number:number++,created_at:new Date(Date.now()-(i%85)*864e5-i*1000).toISOString(),events:[],payment_instructions:{},items:o.items.slice(0,2).map(x=>({...x,id:crypto.randomUUID()}))});
    }
    const target=state.products[0].id,owner=customers[0]?.id;
    for(let i=0;i<REVIEWS;i++)state.reviews.push({id:crypto.randomUUID(),order_id:state.orders[i%state.orders.length].id,product_id:target,customer_id:owner,display_name:'Load Tester '+(i%40),rating:1+i%5,body:'Load test review number '+i+' with enough words.',reply:null,published:true,created_at:new Date(Date.now()-i*60000).toISOString()});
    for(let i=0;state.users.length<USERS;i++)state.users.push({id:crypto.randomUUID(),role:'customer',full_name:'Load Customer '+i,email:'load'+i+'@example.test',phone:'0123456789',business_type:'personal',is_active:true,created_at:new Date().toISOString()});
    localStorage.setItem(key,JSON.stringify(state));
    return{products:state.products.length,orders:state.orders.length,reviews:state.reviews.filter(r=>r.product_id===target).length,users:state.users.length,target};
  },{PRODUCTS,ORDERS,REVIEWS,USERS});
  assert.ok(seeded.products>=PRODUCTS&&seeded.orders>=ORDERS&&seeded.reviews>=REVIEWS&&seeded.users>=USERS,JSON.stringify(seeded));

  // Catalogue: only one page of cards is ever drawn, however large the catalogue
  let r=await timed(async()=>{await page.goto(base+'/shop');await page.locator('.product-card').first().waitFor();});
  assert.ok(r.ms<BUDGET.firstRender,'catalogue first render took '+r.ms+'ms');
  assert.equal(await page.locator('.product-card').count(),12,'catalogue draws 12 cards per page');
  assert.ok(await page.evaluate(()=>document.querySelectorAll('*').length)<6000,'catalogue DOM stays small');
  r=await timed(async()=>{await page.getByRole('button',{name:'In stock now'}).click();await page.waitForURL('**stock=1**');await page.locator('.product-card').first().waitFor();});
  assert.ok(r.ms<BUDGET.interaction,'stock toggle took '+r.ms+'ms');
  r=await timed(async()=>{await page.getByRole('combobox',{name:'Search the catalogue'}).fill('Engine Oil');await page.locator('.search-suggestions').waitFor();});
  assert.ok(r.ms<BUDGET.interaction,'search suggestions took '+r.ms+'ms');
  assert.ok(await page.locator('.search-suggestions [role=option]').count()<=5,'suggestions are capped');

  // Vehicle finder over a large fitment list
  await page.goto(base+'/shop');
  await page.locator('.vehicle-bar').waitFor();
  r=await timed(async()=>{await page.getByLabel('Vehicle make').selectOption('Proton');await page.getByLabel('Vehicle model').selectOption({index:1});await page.locator('.vehicle-summary').waitFor();});
  assert.ok(r.ms<BUDGET.interaction,'vehicle filter took '+r.ms+'ms');
  assert.ok(await page.locator('.product-card').count()<=12);

  // A product with 1,500 reviews shows ten at a time
  await page.goto(base+'/products/'+seeded.target);
  await page.getByRole('tab',{name:/Reviews/}).click();
  await page.locator('.review-card').first().waitFor();
  assert.equal(await page.locator('.review-card').count(),10,'first ten reviews only');
  await page.getByRole('button',{name:/Show more reviews/}).click();
  assert.equal(await page.locator('.review-card').count(),20);

  // Staff: dashboard, orders (paged + full CSV export) and users (paged)
  await page.goto(base+'/account');
  await page.getByRole('button',{name:'Sign out',exact:true}).click().catch(()=>{});
  await page.goto(base+'/account');
  await page.getByLabel('Email address',{exact:true}).fill('admin@gearlane.demo');
  await page.getByLabel('Password',{exact:true}).fill('DemoAdmin123!');
  await page.locator('form').filter({has:page.getByLabel('Password',{exact:true})}).getByRole('button',{name:'Sign in',exact:true}).click();
  await page.waitForURL('**/workspace');
  r=await timed(async()=>{await page.goto(base+'/workspace');await page.locator('.trend-chart').waitFor();await page.locator('.top-products li').first().waitFor();});
  assert.ok(r.ms<BUDGET.dashboard,'dashboard took '+r.ms+'ms');

  await page.goto(base+'/workspace/orders');
  await page.locator('.order-list-card').first().waitFor();
  assert.equal(await page.locator('.order-list-card').count(),25,'orders are listed 25 per page');
  const orderCount=await page.evaluate(()=>JSON.parse(localStorage.getItem('gearlane_preview_v1')).orders.length);
  const [download]=await Promise.all([page.waitForEvent('download'),page.getByRole('button',{name:/^Export \d+ to CSV$/}).click()]);
  const csvPath=await download.path();
  const csv=(await readFile(csvPath,'utf8')).trim().split('\r\n');
  assert.equal(csv.length-1,orderCount,'the export holds every order, not only the visible page');
  assert.match(csv[0],/Order,Placed,Customer/);
  await page.getByRole('button',{name:/^Next/}).click();
  await page.getByText(/Page 2 of/).waitFor();

  await page.goto(base+'/workspace/users');
  await page.locator('tbody tr').first().waitFor();
  assert.equal(await page.locator('tbody tr').count(),20,'users are listed 20 per page');

  assert.deepEqual(errors,[]);
  console.log(`Load checks passed with ${seeded.products} products, ${seeded.orders} orders, ${seeded.reviews} reviews and ${seeded.users} users: paged lists, capped suggestions, full CSV export, render budgets met.`);
}finally{
  await browser?.close();
  await server.close();
}
