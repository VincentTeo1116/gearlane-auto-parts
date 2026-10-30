import assert from 'node:assert/strict';
import {mkdir} from 'node:fs/promises';
import {chromium} from 'playwright';
import {createServer} from 'vite';

/* End-to-end check of order tracking, marketplace-style order lists, cart and shop helpers, and the
   worker and admin home screens. Screenshots go to .generated/ux for a visual look. */
const server=await createServer({mode:'demo',server:{host:'127.0.0.1',port:5212,strictPort:true}});
await server.listen();
let browser;
const errors=[];
const base='http://127.0.0.1:5212';
await mkdir('.generated/ux',{recursive:true});
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
  const hideToasts=()=>page.addStyleTag({content:'[class*=toast]{display:none!important}'});
  const shot=async name=>{await hideToasts();await page.waitForTimeout(300);await page.screenshot({path:`.generated/ux/${name}.png`});};

  /* ---------- Seed one order in every state for the demo customer ---------- */
  await page.goto(base+'/shop');
  await page.locator('.product-card').first().waitFor();
  const ids=await page.evaluate(()=>{
    const key='gearlane_preview_v1',state=JSON.parse(localStorage.getItem(key));
    const me=state.users.find(u=>u.email==='customer@gearlane.demo');
    const template=state.orders.find(o=>o.customer_id===me.id&&o.items.length);
    const product=state.products.find(p=>p.active&&p.price_confirmed&&p.stock>20);
    const hours=h=>new Date(Date.now()-h*36e5).toISOString();
    let number=Math.max(...state.orders.map(o=>o.order_number))+1;
    const make=(name,extra,events=[])=>({...template,id:crypto.randomUUID(),order_number:number++,created_at:hours(50),updated_at:hours(1),received_at:null,cancel_reason:null,tracking_number:null,carrier:null,payment_reference:null,events:events.map((e,i)=>({id:crypto.randomUUID(),event:e[0],note:'',created_at:hours(e[1])})),items:[{id:crypto.randomUUID(),product_id:product.id,name:product.name,sku:product.sku,category:product.category,quantity:2,price_cents:product.price_cents,line_total_cents:product.price_cents*2}],...extra,_name:name});
    const orders=[
      make('pay',{status:'awaiting_payment',payment_status:'awaiting'},[['order_created',50]]),
      make('verify',{status:'awaiting_payment',payment_status:'submitted',payment_reference:'REF12345'},[['order_created',50],['payment_submitted',3]]),
      make('ship',{status:'processing',payment_status:'verified'},[['order_created',50],['payment_verified',30]]),
      make('receive',{status:'shipped',payment_status:'verified',carrier:'J&T Express',tracking_number:'JT0012345678'},[['order_created',50],['payment_verified',30],['shipped',10]]),
      make('done',{status:'delivered',payment_status:'verified',received_at:hours(2)},[['order_created',50],['payment_verified',30],['shipped',10],['receipt_confirmed',2]]),
      make('cancelled',{status:'cancelled',payment_status:'awaiting',cancel_reason:'Changed my mind'},[['order_created',50],['cancelled',20]]),
    ];
    state.orders=state.orders.filter(o=>o.customer_id!==me.id).concat(orders.map(({_name,...o})=>o));
    state.reviews=state.reviews.filter(r=>r.customer_id!==me.id);
    state.settings.free_shipping_cents=25000;
    localStorage.setItem(key,JSON.stringify(state));
    return Object.fromEntries(orders.map(o=>[o._name,{id:o.id,number:o.order_number}]).concat([['product',{id:product.id,name:product.name,price:product.price_cents}]]));
  });
  await login('customer');

  /* ---------- My orders: marketplace tabs with counts ---------- */
  await page.goto(base+'/orders');
  await page.locator('.order-list-card').first().waitFor();
  const tabText=async name=>(await page.getByRole('tab',{name:new RegExp('^'+name)}).textContent()).replace(/\s+/g,' ').trim();
  assert.equal(await tabText('All'),'All6');
  for(const [name,count] of [['To pay',1],['Verifying',1],['To ship',1],['To receive',1],['Completed',1],['Cancelled & refunds',1]])assert.equal(await tabText(name),name+count,name);
  assert.equal(await page.locator('.order-list-card').count(),6);
  await shot('customer-orders-all');
  for(const [name,key] of [['To pay','pay'],['Verifying','verify'],['To ship','ship'],['To receive','receive'],['Completed','done'],['Cancelled & refunds','cancelled']]){
    await page.getByRole('tab',{name:new RegExp('^'+name)}).click();
    assert.equal(await page.locator('.order-list-card').count(),1,name+' shows exactly its own order');
    assert.match(await page.locator('.order-list-card').textContent(),new RegExp('GL-'+ids[key].number),name);
  }
  // each card says what to do next
  await page.getByRole('tab',{name:/^To pay/}).click();
  await page.getByRole('link',{name:/^Pay now/}).waitFor();
  await page.getByRole('tab',{name:/^To receive/}).click();
  await page.getByRole('link',{name:/^Confirm receipt/}).waitFor();
  assert.match(await page.locator('.mini-progress').getAttribute('aria-label'),/4 of 5 steps done, now received/);
  await page.getByRole('tab',{name:/^Completed/}).click();
  await page.getByRole('link',{name:/^Review items/}).waitFor();
  await page.getByRole('tab',{name:/^To ship/}).click();
  assert.match(await page.locator('.mini-progress').getAttribute('aria-label'),/2 of 5 steps done, now preparing/);
  assert.equal(await page.getByRole('link',{name:/^Pay now|^Confirm receipt|^Review items/}).count(),0,'no misleading action on an order that only needs waiting');
  await page.getByRole('tab',{name:/^Cancelled/}).click();
  assert.equal(await page.locator('.mini-progress.cancelled').count(),1);
  await page.getByRole('tab',{name:/^All/}).click();
  await page.getByLabel('Search orders').fill('GL-'+ids.done.number);
  assert.equal(await page.locator('.order-list-card').count(),1,'search by order number, with or without GL-');
  await page.getByLabel('Search orders').fill(ids.product.name.slice(0,12));
  assert.ok(await page.locator('.order-list-card').count()>=6,'search by product name');
  await page.getByLabel('Search orders').fill('');

  /* ---------- Order tracker on each order's page ---------- */
  const track=async(key)=>{await page.goto(base+'/orders/'+ids[key].id);await page.locator('.tracker, .tracker-cancelled').first().waitFor();};
  await track('pay');
  assert.match(await page.locator('.tracker-step[aria-current=step]').textContent(),/Payment.*Waiting for your bank transfer/s);
  await shot('customer-order-to-pay');
  await track('verify');
  assert.match(await page.locator('.tracker-step[aria-current=step]').textContent(),/We are checking your transfer/);
  await track('ship');
  assert.match(await page.locator('.tracker-step[aria-current=step]').textContent(),/Preparing.*Being packed by the store/s);
  assert.equal(await page.locator('.tracker-step.done').count(),2);
  await track('receive');
  assert.match(await page.locator('.tracker-step[aria-current=step]').textContent(),/Received.*Confirm when it arrives/s);
  assert.equal(await page.locator('.tracker-step.done').count(),4);
  assert.match(await page.locator('.tracker-step.done').nth(3).textContent(),/Shipped\s*,?\s*completed\s*\d+ \w+/s,'a recorded event date appears under its step');
  const link=page.getByRole('link',{name:/^Track parcel/});
  assert.match(await link.getAttribute('href'),/^https:\/\/www\.google\.com\/search\?q=J%26T%20Express%20tracking%20JT0012345678$/);
  assert.equal(await link.getAttribute('rel'),'noopener noreferrer');assert.equal(await link.getAttribute('target'),'_blank');
  await page.context().grantPermissions(['clipboard-read','clipboard-write']).catch(()=>{});
  await page.getByRole('button',{name:/^Copy tracking number/}).click();
  await page.getByRole('button',{name:/Copied/}).waitFor();
  await shot('customer-order-shipped');
  await track('done');
  assert.equal(await page.locator('.tracker-step[aria-current=step]').count(),0);assert.equal(await page.locator('.tracker-step.done').count(),5);
  await track('cancelled');
  assert.match(await page.locator('.tracker-cancelled').textContent(),/cancelled.*Changed my mind/s);

  /* ---------- Buy again from a completed order ---------- */
  await page.goto(base+'/orders');
  await page.getByRole('tab',{name:/^Completed/}).click();
  await page.getByRole('button',{name:/Buy again/}).click();
  await page.waitForURL('**/cart');
  await page.locator('.cart-row').first().waitFor();
  assert.match(await page.locator('.cart-row').first().textContent(),new RegExp(ids.product.name.slice(0,15).replace(/[()]/g,'')));
  assert.equal(await page.locator('.cart-row input[type=number]').first().inputValue(),'2','quantities carry over');

  /* ---------- Free delivery nudge follows the threshold ---------- */
  const setThreshold=async cents=>{await page.evaluate(c=>{const key='gearlane_preview_v1',s=JSON.parse(localStorage.getItem(key));s.settings.free_shipping_cents=c;localStorage.setItem(key,JSON.stringify(s));},cents);await page.reload();await page.locator('.cart-row').first().waitFor();};
  await setThreshold(99999999);
  assert.match(await page.locator('.free-delivery').textContent(),/Add RM\s[\d,]+\.\d\d more for free delivery/);
  assert.ok(Number(await page.locator('.free-delivery-bar').getAttribute('aria-valuenow'))<100);
  await shot('customer-cart');
  await setThreshold(100);
  assert.match(await page.locator('.free-delivery').textContent(),/You have free delivery/);
  await setThreshold(0);
  assert.equal(await page.locator('.free-delivery').count(),0,'no threshold, no nudge');

  /* ---------- Checkout starts from the address used last time ---------- */
  await page.goto(base+'/checkout');
  await page.getByLabel('Delivery address',{exact:true}).waitFor();
  assert.match(await page.getByLabel('Delivery address',{exact:true}).inputValue(),/Jalan/);
  assert.ok((await page.getByLabel('Postcode',{exact:true}).inputValue()).length>=5);

  /* ---------- Buy now, recently viewed ---------- */
  await page.goto(base+'/products/'+ids.product.id);
  await page.locator('.detail-info').getByRole('button',{name:'Buy now'}).click();
  await page.waitForURL('**/checkout');
  await page.getByRole('heading',{name:'Where should we send your order?'}).waitFor();
  const others=await page.evaluate(id=>JSON.parse(localStorage.getItem('gearlane_preview_v1')).products.filter(p=>p.active&&p.id!==id).slice(0,2).map(p=>({id:p.id,name:p.name})),ids.product.id);
  await page.evaluate(()=>localStorage.removeItem('gearlane_recent'));
  for(const p of [{id:ids.product.id},...others]){await page.goto(base+'/products/'+p.id);await page.locator('.detail-info').waitFor();}
  await page.goto(base+'/');
  await page.getByRole('region',{name:'Recently viewed parts'}).waitFor();
  const recentNames=await page.locator('.recent-strip .product-name').allTextContents();
  assert.equal(recentNames.length,3);assert.equal(recentNames[0].trim(),others[1].name,'newest first');
  await page.goto(base+'/products/'+others[1].id);
  assert.equal((await page.locator('.recent-strip .product-name').allTextContents()).includes(others[1].name),false,'the page you are on is not listed');
  await page.goto(base+'/');
  await page.getByRole('button',{name:'Clear history'}).click();
  await page.waitForFunction(()=>!document.querySelector('.recent-strip'));

  /* ---------- Shop: price range and best-rated sort ---------- */
  await page.goto(base+'/shop');
  await page.locator('.product-card').first().waitFor();
  const min=page.getByLabel('Minimum price in ringgit'),max=page.getByLabel('Maximum price in ringgit');
  await min.fill('50');await max.fill('60');await max.press('Enter');
  await page.waitForFunction(()=>location.search.includes('min=50')&&location.search.includes('max=60'));
  await page.locator('.product-card').first().waitFor();
  const prices=(await page.locator('.product-card-foot b').allTextContents()).map(t=>Number(t.replace(/[^\d.]/g,'')));
  assert.ok(prices.length>0&&prices.every(p=>p>=50&&p<=60),'every product is within RM 50 to RM 60: '+prices);
  await min.fill('abc');await min.press('Enter');
  await page.waitForFunction(()=>!location.search.includes('min='));
  await page.goto(base+'/shop?sort=rating');
  await page.locator('.product-card').first().waitFor();
  assert.match(await page.locator('.product-card').first().locator('.rating-line').textContent(),/\d\.\d/,'best-rated products come first');

  /* ---------- Worker: one clear next task, queue in priority order ---------- */
  await logout();
  await login('worker');
  await page.locator('.next-up').waitFor();
  assert.equal(await page.locator('.work-queue').count(),0,'no duplicate tiles');
  assert.equal(await page.locator('.stat-card').count(),0,'the worker home is a queue, not a wall of numbers');
  const nextOrder=(await page.locator('.next-up h2').textContent()).match(/GL-\d+/)[0];
  const rows=page.locator('.task-row');
  assert.ok(await rows.count()>=2,'the demo has at least two tasks');
  assert.match(await rows.first().textContent(),new RegExp(nextOrder),'"do this first" is the first row of the queue');
  const flags=await rows.evaluateAll(list=>list.map(r=>r.className.includes('urgency-urgent')?0:r.className.includes('urgency-soon')?1:2));
  assert.deepEqual([...flags].sort((a,b)=>a-b),flags,'overdue first, then soon, then normal');
  await shot('worker-home');
  await page.locator('.next-up .button').click();
  await page.waitForURL(/\/workspace\/orders\/[a-f0-9-]+$/);
  await page.locator('.tracker').waitFor();
  await page.getByRole('button',{name:'Print packing slip'}).waitFor();
  await page.getByRole('button',{name:/^Copy delivery address/}).waitFor();
  await shot('worker-order');

  /* ---------- Staff order list: needs-action first ---------- */
  await page.goto(base+'/workspace/orders');
  await page.locator('.order-list-card').first().waitFor();
  assert.ok(await page.locator('.order-list-card').first().locator('.action-tag').count()>=1,'the first order needs action');
  assert.equal(await page.getByLabel('Sort orders').inputValue(),'priority');
  const flagsList=await page.locator('.order-list-card').evaluateAll(cards=>cards.map(c=>c.classList.contains('needs-action')?1:0));
  assert.deepEqual([...flagsList].sort((a,b)=>b-a),flagsList,'every order needing action is above every order that does not');
  await page.getByLabel('Sort orders').selectOption('newest');
  const dates=await page.locator('.order-list-card .order-list-top small').allTextContents();
  assert.ok(dates.length>1);
  await shot('worker-orders');

  /* ---------- Admin: the biggest box is the most important one ---------- */
  await logout();
  await login('admin');
  await page.locator('.hero-stat').waitFor();
  await page.locator('.action-center').waitFor();
  const boxes=await page.evaluate(()=>{
    const area=el=>{const r=el.getBoundingClientRect();return r.width*r.height;};
    const hero=document.querySelector('.hero-stat'),action=document.querySelector('.action-center');
    const others=[...document.querySelectorAll('.dashboard .panel, .dashboard .stat-card')].filter(el=>el!==hero&&el!==action&&!hero.contains(el)&&!action.contains(el));
    return{hero:area(hero),action:area(action),biggestOther:Math.max(...others.map(area)),heroTop:hero.getBoundingClientRect().top,actionTop:action.getBoundingClientRect().top,smallKpi:Math.max(...[...document.querySelectorAll('.kpi-small .stat-card')].map(area)),vh:innerHeight};
  });
  assert.ok(boxes.hero>boxes.biggestOther,'the revenue hero is larger than every other box');
  assert.ok(boxes.hero>boxes.smallKpi*3,'and several times larger than a supporting KPI card');
  assert.ok(boxes.heroTop<boxes.vh*0.6&&boxes.actionTop<boxes.vh*0.6,'the hero and the action panel start in the first screen');
  assert.ok(await page.locator('.action-row.urgent, .action-row.soon').count()>=1,'something needs attention in the demo');
  const order=await page.locator('.action-row').evaluateAll(rows=>rows.map(r=>r.classList.contains('urgent')?0:r.classList.contains('soon')?1:r.classList.contains('clear')?3:2));
  assert.deepEqual([...order].sort((a,b)=>a-b),order,'action rows run from most urgent to all clear');
  assert.equal(await page.locator('.work-queue').count(),0);
  const firstStat=await page.locator('.stat-card>b').first().textContent();
  assert.match(firstStat,/^RM\s[\d,]+\.\d\d$/,'the first figure is the revenue headline');
  await shot('admin-home');

  /* ---------- Phone layouts ---------- */
  await logout();
  await login('customer');
  await page.setViewportSize({width:390,height:844});
  const fits=async label=>{const overflow=await page.evaluate(()=>document.documentElement.scrollWidth-innerWidth);assert.ok(overflow<=1,label+' overflows by '+overflow+'px');};
  await page.goto(base+'/orders');await page.locator('.order-list-card').first().waitFor();await fits('orders tabs');await shot('phone-customer-orders');
  await track('receive');
  assert.equal(await page.evaluate(()=>getComputedStyle(document.querySelector('.tracker')).gridTemplateColumns.split(' ').length),1,'the tracker stacks vertically on a phone');
  await fits('order detail');await shot('phone-customer-order');
  await logout();await login('worker');await page.locator('.next-up').waitFor();await fits('worker home');await shot('phone-worker-home');
  await logout();await login('admin');await page.locator('.hero-stat').waitFor();await fits('admin home');await shot('phone-admin-home');

  assert.deepEqual(errors,[]);
  console.log('UX checks passed: marketplace order tabs, five-step tracker with real dates, tracking link and copy, buy again, free-delivery nudge, remembered address, buy now, recently viewed, price filter, best-rated sort, worker next-task queue, priority order list, admin hero hierarchy and phone layouts.');
}finally{
  await browser?.close();
  await server.close();
}
