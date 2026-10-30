import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
import {mkdir,readFile} from 'node:fs/promises';
import {chromium} from 'playwright';
import {createServer} from 'vite';
import {parsePdf} from '../tests/pdf-helpers.mjs';

/* End-to-end check of the address book, the garage ("my vehicle" for the whole store), product questions and
   answers, and PDF invoices. Screenshots go to .generated/profile for a visual look. */
const server=await createServer({mode:'demo',server:{host:'127.0.0.1',port:5214,strictPort:true}});
await server.listen();
let browser;
const errors=[];
const base='http://127.0.0.1:5214';
await mkdir('.generated/profile',{recursive:true});
const clean=text=>text.replace(/\s+/g,' ').trim();
try{
  browser=await chromium.launch({headless:true});
  const page=await browser.newPage({viewport:{width:1440,height:900},acceptDownloads:true});
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
  const shot=async name=>{await hideToasts();await page.waitForTimeout(300);await page.screenshot({path:`.generated/profile/${name}.png`});};
  const state=fn=>page.evaluate(fn);

  await page.goto(base+'/shop');
  await page.locator('.product-card').first().waitFor();
  const fixtures=await page.evaluate(()=>{
    const s=JSON.parse(localStorage.getItem('gearlane_preview_v1'));
    const withFit=s.products.find(p=>p.active&&p.price_confirmed&&p.stock>5&&s.fitment.some(f=>f.product_id===p.id));
    const fit=s.fitment.find(f=>f.product_id===withFit.id);
    const plain=s.products.find(p=>p.active&&p.price_confirmed&&p.stock>5&&!s.fitment.some(f=>f.product_id===p.id));
    return{withFit:{id:withFit.id,name:withFit.name},make:fit.make,model:fit.model,plain:{id:plain.id,name:plain.name}};
  });

  /* =============== Garage: a guest chooses a vehicle and the whole store follows =============== */
  await page.goto(base+'/');
  await page.getByRole('button',{name:'Add my vehicle'}).click();
  let dialog=page.getByRole('dialog');
  await dialog.getByText('Saved on this device. Sign in to keep your garage on every device.').waitFor();
  await dialog.getByLabel('Make').selectOption(fixtures.make);
  await dialog.getByLabel('Model').selectOption(fixtures.model);
  await dialog.getByRole('button',{name:'Add vehicle'}).click();
  await dialog.waitFor({state:'hidden'});
  const chip=page.getByRole('button',{name:/^My vehicle:/});
  await chip.waitFor();
  assert.match(await chip.textContent(),new RegExp(fixtures.model));
  await page.getByRole('region',{name:/^Parts for your/}).waitFor();                      // home page shelf
  await shot('garage-home-guest');
  await page.goto(base+'/shop');                                                          // the catalogue is filtered by default
  await page.locator('.vehicle-summary').waitFor();
  const filtered=await page.locator('.product-card').count();
  assert.ok(filtered>=1,'parts listed for the vehicle are shown');
  assert.ok(await page.locator('.fit-chip.yes').count()>=1,'each card says it fits');
  assert.match(await page.locator('.fit-chip.yes').first().textContent(),new RegExp('Fits your '+fixtures.model));
  await page.getByRole('button',{name:'Show all parts'}).click();
  await page.waitForFunction(()=>location.search.includes('all=1'));
  await page.locator('.product-card').first().waitFor();
  await page.waitForFunction(n=>document.querySelectorAll('.product-card').length>n,filtered);
  await page.goto(base+'/products/'+fixtures.withFit.id);
  await page.locator('.fitment-panel').waitFor();
  assert.match(await page.locator('.fit-yes').textContent(),new RegExp('Listed for your .*'+fixtures.model));
  await page.goto(base+'/products/'+fixtures.plain.id);
  assert.match(await page.locator('.fitment-none').textContent(),/No vehicle list for this part yet/,'unknown fitment is never called "fits" or "does not fit"');

  /* =============== The garage moves into the account at sign-in =============== */
  await login('customer');
  await page.goto(base+'/account');
  const garageRow=page.locator('.garage-list li').first();
  await garageRow.waitFor();
  assert.match(await garageRow.textContent(),new RegExp(fixtures.model));assert.match(await garageRow.textContent(),/In use/);
  const garageState=await state(()=>JSON.parse(localStorage.getItem('gearlane_preview_v1')).garage_vehicles.length);
  assert.equal(garageState,1,'the guest vehicle was saved to the account exactly once');
  await shot('account-garage');
  // add a second vehicle in the account, switch between them, remove one, and turn the filter off
  const options=await page.evaluate(()=>{const s=JSON.parse(localStorage.getItem('gearlane_preview_v1'));const other=s.fitment.find(f=>!(f.make===(s.garage_vehicles[0]?.make)&&f.model===(s.garage_vehicles[0]?.model)));return{make:other.make,model:other.model};});
  await page.locator('.garage-add').getByLabel('Make').selectOption(options.make);
  await page.locator('.garage-add').getByLabel('Model').selectOption(options.model);
  await page.locator('.garage-add').getByRole('button',{name:'Add vehicle'}).click();
  await page.waitForFunction(()=>document.querySelectorAll('.garage-list li').length===2);
  assert.equal(await page.locator('.garage-list li.active').count(),1,'only one vehicle is in use');
  assert.match(await page.locator('.garage-list li.active').textContent(),new RegExp(options.model));
  await page.locator('.garage-list li:not(.active)').getByRole('button',{name:'Use this vehicle'}).click();
  await page.waitForFunction(m=>!document.querySelector('.garage-list li.active')?.textContent.includes(m),options.model);
  await page.getByRole('button',{name:'Show all parts (no vehicle)'}).click();
  await page.waitForFunction(()=>document.querySelectorAll('.garage-list li.active').length===0);
  await page.getByRole('button',{name:'Add my vehicle'}).waitFor();
  await page.goto(base+'/shop');
  await page.locator('.product-card').first().waitFor();
  assert.equal(await page.locator('.vehicle-summary').count(),0,'no vehicle means the full catalogue');
  assert.equal(await page.locator('.fit-chip').count(),0);
  await page.goto(base+'/account');
  await page.locator('.garage-list li').first().getByRole('button',{name:/^Remove /}).click();
  await page.waitForFunction(()=>document.querySelectorAll('.garage-list li').length===1);
  await page.locator('.garage-list li').first().getByRole('button',{name:'Use this vehicle'}).click();
  await page.reload();
  await page.getByRole('button',{name:/^My vehicle:/}).waitFor();                         // it survives a reload, from the account

  /* =============== Address book =============== */
  await page.goto(base+'/account');
  const book=page.locator('.address-book');
  await book.getByText('No saved addresses yet.').waitFor();
  const fill=async(dialog,v)=>{
    if(v.label!==undefined)await dialog.getByLabel('Label (optional)').fill(v.label);
    await dialog.getByLabel('Full name').fill(v.name);await dialog.getByLabel('Phone number').fill(v.phone);await dialog.getByLabel('Delivery address').fill(v.line1);
    await dialog.getByLabel('City').fill(v.city);await dialog.getByLabel('Postcode').fill(v.postcode);
  };
  const home={label:'Home',name:'Amir Rahman',phone:'0123456789',line1:'12 Jalan Demo, Taman Contoh',city:'Petaling Jaya',postcode:'47300'};
  await book.getByRole('button',{name:'Add address'}).click();
  dialog=page.getByRole('dialog');
  await fill(dialog,{...home,postcode:'123'});
  await dialog.getByRole('button',{name:'Save address'}).click();
  await dialog.getByText(/5-digit/).waitFor();                                            // the same rules as checkout
  assert.equal(await page.locator('.address-list li').count(),0,'an invalid address is not saved');
  await fill(dialog,home);
  await dialog.getByRole('button',{name:'Save address'}).click();
  await dialog.waitFor({state:'hidden'});
  await page.locator('.address-list li').first().waitFor();
  assert.match(await page.locator('.address-list li').first().textContent(),/Home.*Default/s,'the first address is the default');
  await book.getByRole('button',{name:'Add address'}).click();
  dialog=page.getByRole('dialog');
  await fill(dialog,{...home,label:'Workshop',line1:'88 Jalan Bengkel, Shah Alam',city:'Shah Alam',postcode:'40000'});
  await dialog.getByRole('button',{name:'Save address'}).click();
  await dialog.waitFor({state:'hidden'});
  await page.waitForFunction(()=>document.querySelectorAll('.address-list li').length===2);
  await page.locator('.address-list li',{hasText:'Workshop'}).getByRole('button',{name:'Make default'}).click();
  await page.waitForFunction(()=>document.querySelector('.address-list li.default')?.textContent.includes('Workshop'));
  assert.equal(await page.locator('.address-list li.default').count(),1,'only one default');
  await page.locator('.address-list li',{hasText:'Home'}).getByRole('button',{name:/^Edit/}).click();
  dialog=page.getByRole('dialog');
  await dialog.getByLabel('City').fill('Subang Jaya');
  await dialog.getByRole('button',{name:'Save changes'}).click();
  await dialog.waitFor({state:'hidden'});
  await page.locator('.address-list li',{hasText:'Subang Jaya'}).waitFor();
  await shot('account-address-book');
  await page.locator('.address-list li',{hasText:'Workshop'}).getByRole('button',{name:/^Delete address/}).click();
  await page.waitForFunction(()=>document.querySelectorAll('.address-list li').length===1);
  assert.match(await page.locator('.address-list li.default').textContent(),/Home/,'deleting the default promotes the remaining address');

  /* ---- checkout uses the book, and can add to it ---- */
  await page.goto(base+'/shop?all=1');
  await page.locator('.product-card .add-button').first().click();
  await page.goto(base+'/checkout');
  await page.locator('.address-picker').waitFor();
  assert.equal(await page.getByLabel('Delivery address',{exact:true}).inputValue(),home.line1,'the default address is filled in');
  await shot('checkout-address-picker');
  await page.getByLabel('A different address').check();
  assert.equal(await page.getByLabel('Delivery address',{exact:true}).inputValue(),'','choosing a different address clears the street');
  await page.getByLabel('Delivery address',{exact:true}).fill('5 Lorong Baru, Taman Subang');
  await page.getByLabel('City',{exact:true}).fill('Subang Jaya');await page.getByLabel('Postcode',{exact:true}).fill('47500');
  await page.getByLabel('Save this address to my address book').check();
  await page.getByRole('button',{name:'Continue to review',exact:true}).click();
  await page.getByRole('checkbox').check();
  await page.getByRole('button',{name:'Place order',exact:true}).click();
  await page.waitForURL(/\/orders\/[a-f0-9-]+$/);
  await page.goto(base+'/account');
  await page.waitForFunction(()=>document.querySelectorAll('.address-list li').length===2);
  assert.match(await page.locator('.address-list').textContent(),/5 Lorong Baru/,'the checkout address was saved');

  /* =============== Product questions and answers =============== */
  const product=fixtures.plain;
  await page.goto(base+'/products/'+product.id);
  await page.getByRole('tab',{name:/^Questions \(0\)/}).click();
  const ask=page.getByRole('button',{name:'Ask the store'});
  assert.equal(await ask.isDisabled(),true,'an empty question cannot be sent');
  await page.getByLabel('Your question').fill('too short');
  assert.equal(await ask.isDisabled(),true,'neither can a very short one');
  await page.getByLabel('Your question').fill('Please call me on 012-345 6789 about this part');
  await page.getByText(/phone number/).waitFor();
  await page.getByLabel('Your question').fill('Will this fit a 2019 Proton X50 1.5 turbo?');
  await ask.click();
  await page.locator('.qa-item.waiting').waitFor();
  assert.match(await page.locator('.qa-item.waiting').textContent(),/Only you can see this until it is answered/);
  assert.equal(await page.getByLabel('Your question').inputValue(),'','the box is cleared after sending');
  await page.getByLabel('Your question').fill('Does it come with a gasket included?');
  await ask.click();
  await page.waitForFunction(()=>document.querySelectorAll('.qa-item.waiting').length===2);
  await page.getByLabel('Your question').fill('A third question while two are waiting.');
  assert.equal(await ask.isDisabled(),true,'at most two waiting questions per product');
  await page.getByText(/already have questions waiting on this product/).waitFor();
  await shot('questions-customer');
  await logout();

  await page.goto(base+'/products/'+product.id);
  await page.getByRole('tab',{name:/^Questions/}).click();
  await page.getByText(/Sign in to ask the store a question/).waitFor();
  assert.equal(await page.locator('.qa-item').count(),0,'a waiting question is private to its asker');
  assert.equal(await page.getByRole('tab',{name:/^Questions \(0\)/}).count(),1);

  await login('worker');
  await page.locator('.next-up').waitFor();
  assert.match(await page.locator('.action-center').textContent(),/2 questions to answer/);
  const badge=page.locator('.workspace-sidebar nav a',{hasText:'Questions'}).locator('small');
  assert.equal((await badge.textContent()).trim(),'2');
  await page.goto(base+'/workspace/questions');
  await page.locator('.question-card').first().waitFor();
  assert.equal(await page.locator('.question-card').count(),2);
  assert.match(await page.locator('.question-card').first().textContent(),/Will this fit a 2019 Proton X50/,'the oldest question comes first');
  assert.match(await page.locator('.question-card').first().textContent(),/Amir R\./,'only a first name and initial are shown');
  await shot('questions-staff');
  await page.locator('.question-card').first().getByRole('button',{name:'Answer'}).click();
  dialog=page.getByRole('dialog');
  assert.equal(await dialog.getByRole('button',{name:'Publish answer'}).isDisabled(),true);
  await dialog.getByLabel('Your answer').fill('Yes, it fits the 2019 Proton X50 1.5 turbo. Please keep your old filter for comparison.');
  await dialog.getByRole('button',{name:'Publish answer'}).click();
  await dialog.waitFor({state:'hidden'});
  await page.waitForFunction(()=>document.querySelectorAll('.question-card').length===1);
  await logout();

  await login('customer');
  await page.getByRole('button',{name:'Notifications'}).click();
  await page.getByText('Your question was answered').first().waitFor();
  await page.keyboard.press('Escape');
  await page.goto(base+'/products/'+product.id);
  await page.getByRole('tab',{name:/^Questions \(1\)/}).click();
  await page.locator('.qa-answer').waitFor();
  assert.match(await page.locator('.qa-item:not(.waiting)').textContent(),/Will this fit a 2019 Proton X50.*Store answer.*Please keep your old filter/s);
  assert.equal(await page.locator('.qa-item.waiting').count(),1,'the other question is still waiting');
  await logout();
  await page.goto(base+'/products/'+product.id);
  await page.getByRole('tab',{name:/^Questions \(1\)/}).click();
  await page.locator('.qa-answer').waitFor();
  assert.match(await page.locator('.qa-item').first().textContent(),/Asked by Amir R\./,'visitors see the answer and a first name only');
  assert.equal(await page.locator('.qa-item.waiting').count(),0);
  await shot('questions-public');

  await login('admin');
  await page.goto(base+'/workspace/questions');
  await page.getByRole('tab',{name:'Answered'}).click();
  await page.locator('.question-card').first().getByRole('button',{name:'Hide'}).click();
  await page.locator('.question-card').first().getByText('Hidden').waitFor();
  await logout();
  await page.goto(base+'/products/'+product.id);
  await page.getByRole('tab',{name:/^Questions \(0\)/}).click();
  assert.equal(await page.locator('.qa-answer').count(),0,'a hidden question disappears from the product page');

  /* =============== PDF invoices =============== */
  await page.goto(base+'/shop');
  const ids=await page.evaluate(()=>{
    const key='gearlane_preview_v1',s=JSON.parse(localStorage.getItem(key));
    const me=s.users.find(u=>u.email==='customer@gearlane.demo'),template=s.orders.find(o=>o.customer_id===me.id&&o.items.length)||s.orders[0];
    const prod=s.products.find(p=>p.active&&p.price_confirmed&&p.stock>20);
    let number=Math.max(...s.orders.map(o=>o.order_number))+1;
    const hours=h=>new Date(Date.now()-h*36e5).toISOString();
    const make=(extra,events)=>({...template,customer_id:me.id,id:crypto.randomUUID(),order_number:number++,created_at:hours(50),received_at:null,tracking_number:null,carrier:null,promotion_code:'SAVE10',payment_reference:'MBB-INV-001',events:events.map(e=>({id:crypto.randomUUID(),event:e[0],note:'',created_at:hours(e[1])})),items:[{id:crypto.randomUUID(),product_id:prod.id,name:prod.name,sku:prod.sku,category:prod.category,quantity:2,price_cents:prod.price_cents,line_total_cents:prod.price_cents*2}],subtotal_cents:prod.price_cents*2,discount_cents:1000,shipping_cents:1500,total_cents:prod.price_cents*2-1000+1500,...extra});
    const paid=make({status:'delivered',payment_status:'verified',received_at:hours(2)},[['order_created',50],['payment_verified',30],['shipped',10]]);
    const unpaid=make({status:'awaiting_payment',payment_status:'awaiting',payment_reference:null},[['order_created',50]]);
    const refunded=make({status:'cancelled',payment_status:'refunded'},[['order_created',50],['payment_verified',30]]);
    s.orders.push(paid,unpaid,refunded);localStorage.setItem(key,JSON.stringify(s));
    return{paid:{id:paid.id,number:paid.order_number,total:paid.total_cents,name:prod.name},unpaid:{id:unpaid.id},refunded:{id:refunded.id,number:refunded.order_number}};
  });
  const download=async(button)=>{const [file]=await Promise.all([page.waitForEvent('download'),button.click()]);return{name:file.suggestedFilename(),bytes:new Uint8Array(await readFile(await file.path()))};};
  const inspect=bytes=>{const parsed=parsePdf(bytes);assert.deepEqual(parsed.problems,[],'the downloaded PDF is well formed');return parsed;};

  await login('customer');
  await page.goto(base+'/orders/'+ids.paid.id);
  await page.locator('.tracker').waitFor();
  let file=await download(page.getByRole('button',{name:'Download invoice (PDF)'}));
  assert.equal(file.name,`invoice-GL-${ids.paid.number}.pdf`);
  assert.equal(new TextDecoder('latin1').decode(file.bytes.slice(0,8)),'%PDF-1.4');
  let pdf=inspect(file.bytes),text=pdf.allText.map(clean).join('\n');
  for(const expected of ['INVOICE',`INV-${ids.paid.number}`,`GL-${ids.paid.number}`,'PAID','Amir Rahman','Discount (SAVE10)','Paid by bank transfer, reference MBB-INV-001',ids.paid.name.slice(0,25)])assert.ok(text.includes(expected),'invoice contains: '+expected);
  assert.ok(text.includes(clean(new Intl.NumberFormat('en-MY',{style:'currency',currency:'MYR'}).format(ids.paid.total/100))),'the invoice total is the order total');
  await page.goto(base+'/orders/'+ids.unpaid.id);
  await page.locator('.tracker').waitFor();
  assert.equal(await page.getByRole('button',{name:'Download invoice (PDF)'}).count(),0,'no invoice before payment is verified');
  await page.goto(base+'/orders/'+ids.refunded.id);
  await page.locator('.tracker, .tracker-cancelled').first().waitFor();
  file=await download(page.getByRole('button',{name:'Download invoice (PDF)'}));
  pdf=inspect(file.bytes);assert.ok(pdf.allText.includes('REFUNDED'),'a refunded order is marked');
  await page.goto(base+'/orders');
  await page.getByRole('tab',{name:/^Completed/}).click();
  await page.locator('.order-list-card').first().getByRole('button',{name:'Invoice'}).waitFor();
  // an independent reader agrees (only when Python and pypdf are installed)
  await (await import('node:fs/promises')).writeFile('.generated/profile/check.pdf',file.bytes);
  const reread=spawnSync('python',['-I','-c','import pypdf,sys;r=pypdf.PdfReader(sys.argv[1],strict=True);print(len(r.pages));print(r.metadata.title)','.generated/profile/check.pdf'],{encoding:'utf8'});
  if(reread.status===0){assert.match(reread.stdout,/^1\r?\nInvoice INV-\d+/);console.log('  pypdf (independent reader) accepted the invoice');}
  else console.log('  (pypdf not available here, skipped the independent read)');
  await logout();

  await login('worker');
  await page.goto(base+'/workspace/orders/'+ids.paid.id);
  await page.getByRole('button',{name:'Download invoice (PDF)'}).waitFor();
  await logout();

  await login('admin');
  await page.goto(base+'/workspace/settings');
  await page.getByLabel('Seller details on invoices').fill('GearLane Sdn Bhd (Reg. 202001234567)\nSST No: W10-1234-56789012\n1 Jalan Demo, 50000 Kuala Lumpur');
  await page.getByRole('button',{name:'Save store settings'}).click();
  await page.getByText('Store settings saved.').waitFor();
  await logout();
  await login('customer');
  await page.goto(base+'/orders/'+ids.paid.id);
  file=await download(page.getByRole('button',{name:'Download invoice (PDF)'}));
  pdf=inspect(file.bytes);text=pdf.allText.join('\n');
  assert.ok(text.includes('GearLane Sdn Bhd (Reg. 202001234567)')&&text.includes('SST No: W10-1234-56789012'),'the admin\'s company details appear on the invoice');
  await shot('invoice-order-page');

  /* =============== Phone layouts =============== */
  await page.setViewportSize({width:390,height:844});
  const fits=async label=>{const overflow=await page.evaluate(()=>document.documentElement.scrollWidth-innerWidth);assert.ok(overflow<=1,label+' overflows by '+overflow+'px');};
  await page.goto(base+'/account');await page.locator('.address-list li').first().waitFor();await fits('account (address book and garage)');await shot('phone-account');
  await page.getByRole('button',{name:/^My vehicle:/}).click();await page.getByRole('dialog').waitFor();await fits('garage dialog');await shot('phone-garage');await page.keyboard.press('Escape');
  await page.goto(base+'/products/'+product.id);await page.getByRole('tab',{name:/^Questions/}).click();await page.locator('.qa-panel').waitFor();await fits('product questions');await shot('phone-questions');
  await page.goto(base+'/orders/'+ids.paid.id);await page.locator('.tracker').waitFor();await fits('order page with invoice button');
  await page.goto(base+'/shop');await page.locator('.product-card').first().waitFor();await fits('shop with the vehicle chip');
  await logout();await login('worker');await page.goto(base+'/workspace/questions');await page.locator('.order-tabs').waitFor();await fits('staff questions');
  await logout();

  assert.deepEqual(errors,[]);
  console.log('Profile checks passed: garage (guest to account, whole-store filter, fit badges, home shelf), address book with checkout picker and save-back, product questions across guest, customer, worker and admin, and PDF invoices that parse cleanly.');
}finally{
  await browser?.close();
  await server.close();
}
