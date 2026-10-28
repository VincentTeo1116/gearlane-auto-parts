import test from 'node:test';
import assert from 'node:assert/strict';
import {PGlite} from '@electric-sql/pglite';
import {readFile} from 'node:fs/promises';

test('database permissions and transactional commerce workflows',async()=>{
 const db=await PGlite.create();
 const ids={customer:'10000000-0000-4000-8000-000000000001',other:'10000000-0000-4000-8000-000000000002',worker:'10000000-0000-4000-8000-000000000003',admin:'10000000-0000-4000-8000-000000000004'};
 const actor=async(role,fn)=>{await db.exec('reset role');await db.query("select set_config('request.jwt.claim.sub',$1,false)",[ids[role]]);await db.exec('set role authenticated');try{return await fn();}finally{await db.exec('reset role');}};
 const rpc=async(name,args=[])=>{const placeholders=args.map((_,i)=>'$'+(i+1)).join(',');return (await db.query(`select public.${name}(${placeholders}) as value`,args)).rows[0]?.value;};
 const address={name:'Test Buyer',phone:'0123456789',line1:'12 Jalan Test, Test Town',city:'Kuala Lumpur',postcode:'50000',state:'Kuala Lumpur'};
 try {
 await db.exec(`create role anon;create role authenticated;create schema auth;create schema storage;create table auth.users(id uuid primary key,email text,raw_user_meta_data jsonb default '{}');create table storage.objects(bucket_id text,name text);create function auth.uid() returns uuid language sql stable as $$select nullif(current_setting('request.jwt.claim.sub',true),'')::uuid$$;grant usage on schema public,auth to anon,authenticated;grant execute on function auth.uid() to anon,authenticated;`);
 for(const name of ['001-schema.sql','002-commerce.sql','003-workspace.sql','007-chat-delivery.sql'])await db.exec(await readFile(new URL('../supabase/'+name,import.meta.url),'utf8'));
 await db.exec((await readFile(new URL('../supabase/008-promotion-banners.sql',import.meta.url),'utf8')).split('-- Supabase Storage')[0]);
 for(const [role,id] of Object.entries(ids))await db.query("insert into auth.users(id,email,raw_user_meta_data) values($1,$2,$3)",[id,role+'@example.test',JSON.stringify({full_name:'Test '+role,role:'admin'})]);
 assert.equal((await db.query('select role from profiles where id=$1',[ids.customer])).rows[0].role,'customer','Signup metadata must not grant admin');
 await db.query("update profiles set role='worker' where id=$1",[ids.worker]);await db.query("update profiles set role='admin' where id=$1",[ids.admin]);
 await db.exec("update store_settings set checkout_enabled=true,bank_name='Test bank',bank_account_name='GearLane',bank_account_number='123456789',shipping_cents=500");
 await db.exec("insert into products(id,sku,name,brand,category,description,price_cents,price_confirmed,stock) values('oil','OIL-1','Test engine oil','Test','Engine Oil','A test product description.',10000,true,5),('pad','PAD-1','Test brake pad','Test','Brakes','A test product description.',5000,true,2)");
 await actor('customer',async()=>{
   await assert.rejects(()=>rpc('admin_archive_product',['oil']),/permission/);
   await assert.rejects(()=>db.exec("update profiles set role='admin' where id=auth.uid()"),/permission denied/);
   await assert.rejects(()=>db.exec("update products set stock=1000"),/permission denied/);
   assert.equal(await rpc('toggle_wishlist',['oil']),true);assert.equal(await rpc('toggle_wishlist',['oil']),false);
 });
 const key='20000000-0000-4000-8000-000000000001';let order;
 await actor('customer',async()=>{
   await assert.rejects(()=>rpc('create_order',[JSON.stringify([{product_id:'oil',quantity:6}]),JSON.stringify(address),'',key,60500]),/stock/);
   await assert.rejects(()=>rpc('create_order',[JSON.stringify([{product_id:'oil',quantity:1}]),JSON.stringify(address),'',key,1]),/changed/);
   order=await rpc('create_order',[JSON.stringify([{product_id:'oil',quantity:1}]),JSON.stringify(address),'',key,10500]);
   assert.equal(await rpc('create_order',[JSON.stringify([{product_id:'oil',quantity:1}]),JSON.stringify(address),'',key,10500]),order);
   await assert.rejects(()=>rpc('submit_review',[order,'oil',5,'This should not be allowed yet.']),/receipt/);
   await rpc('submit_payment',[order,'BANK-REF-123',null]);
   await assert.rejects(()=>rpc('cancel_order',[order,'Cancel after submitting transfer.']),/refund process/);
 });
 assert.equal((await db.query("select stock from products where id='oil'")).rows[0].stock,4);
 await actor('other',async()=>{assert.equal((await db.query('select * from orders')).rows.length,0);await assert.rejects(()=>rpc('confirm_receipt',[order]),/buyer/);});
 await actor('worker',async()=>{
   await assert.rejects(()=>rpc('set_order_status',[order,'shipped','Test carrier','TRACK123']),/Invalid/);
   await rpc('verify_payment',[order,true,'Matched the actual account deposit.']);
   await rpc('set_order_status',[order,'shipped','Test carrier','TRACK123']);
   await assert.rejects(()=>rpc('dashboard_stats',[30]),/permission/);
 });
 let review;
 await actor('customer',async()=>{await assert.rejects(()=>rpc('submit_review',[order,'oil',5,'Still not confirmed received.']),/receipt/);await rpc('confirm_receipt',[order]);review=await rpc('submit_review',[order,'oil',5,'Received the purchased test product.']);});
 await actor('worker',async()=>{await rpc('reply_review',[review,'Thank you for your feedback.']);});
 let refund;
 await actor('customer',async()=>{refund=await rpc('request_refund',[order,'The delivered test item is damaged.']);});
 await actor('worker',async()=>{await rpc('review_refund',[refund,true,'Return accepted and goods received.',true]);await assert.rejects(()=>rpc('confirm_refund',[refund,'REFUND123',true]),/permission/);});
 await actor('admin',async()=>{await rpc('confirm_refund',[refund,'REFUND123',true]);await assert.rejects(()=>rpc('confirm_refund',[refund,'REFUND123',true]),/approved/);});
 assert.equal((await db.query("select stock from products where id='oil'")).rows[0].stock,5);
 let cancelOrder;
 await actor('customer',async()=>{cancelOrder=await rpc('create_order',[JSON.stringify([{product_id:'pad',quantity:2}]),JSON.stringify(address),'','20000000-0000-4000-8000-000000000002',10500]);});
 await actor('other',async()=>{await assert.rejects(()=>rpc('create_order',[JSON.stringify([{product_id:'pad',quantity:1}]),JSON.stringify(address),'','20000000-0000-4000-8000-000000000003',5500]),/stock/);});
 await actor('customer',async()=>{await rpc('cancel_order',[cancelOrder,'Customer changed the required part.']);await rpc('cancel_order',[cancelOrder,'Customer changed the required part.']);});
 assert.equal((await db.query("select stock from products where id='pad'")).rows[0].stock,2);
 let support,internal;
 await actor('customer',async()=>{support=await rpc('start_conversation',['support',null]);await rpc('send_message',[support,'Please confirm the oil specification.','oil']);});
 await actor('customer',async()=>{
  const reference='90000000-0000-4000-8000-000000000001';
  const sent=await rpc('send_chat_message',[support,'Message with a delivery reference.','oil',reference]);
  assert.equal(await rpc('send_chat_message',[support,'Message with a delivery reference.','oil',reference]),sent,'Retry returns the same message');
  assert.equal((await db.query('select count(*)::int as n from messages where client_message_id=$1',[reference])).rows[0].n,1);
  await assert.rejects(()=>rpc('send_chat_message',[support,'A different message.',null,reference]),/different message/);
  for(const body of ['   ','\n\t','\u200B','x'.repeat(2001),'Invalid\u0001message'])await assert.rejects(()=>rpc('send_chat_message',[support,body,null,'90000000-0000-4000-8000-000000000002']),/message|characters/i);
 });
 await actor('other',async()=>{assert.equal((await db.query('select * from messages')).rows.length,0);await assert.rejects(()=>rpc('send_message',[support,'Unauthorised message',null]),/unavailable/);});
 await actor('worker',async()=>{await rpc('send_message',[support,'Please share the vehicle model and year.',null]);internal=await rpc('start_conversation',['internal',ids.admin]);await rpc('send_message',[internal,'Please check the restock request.',null]);});
 await actor('customer',async()=>{assert.equal((await db.query('select * from messages where conversation_id=$1',[internal])).rows.length,0);});
 await actor('admin',async()=>{assert.equal((await db.query('select * from messages where conversation_id=$1',[internal])).rows.length,1);const stats=await rpc('dashboard_stats',[30]);assert.equal(Number(stats.paid_sales_cents),0);});
 let request;
 await actor('worker',async()=>{request=await rpc('request_restock',['oil',10,'Workshop demand exceeds current supply.']);});
 await actor('admin',async()=>{await rpc('resolve_restock',[request,10,'Ten units physically received and counted.']);await assert.rejects(()=>rpc('resolve_restock',[request,10,'Duplicate delivery must not count.']),/resolved/);});
 assert.equal((await db.query("select stock from products where id='oil'")).rows[0].stock,15);
 // The incremental update must also apply cleanly to an already initialized database.
 await db.exec(await readFile(new URL('../supabase/006-checkout-hardening.sql',import.meta.url),'utf8'));
 await actor('customer',async()=>{await rpc('toggle_wishlist',['pad']);});
 await actor('admin',async()=>{await rpc('admin_archive_product',['pad']);});
 await actor('customer',async()=>{assert.equal(await rpc('toggle_wishlist',['pad']),false);});
 const created=(await db.query('select payment_instructions from orders where id=$1',[order])).rows[0];
 assert.equal(created.payment_instructions.bank_account_number,'123456789');
 await actor('other',async()=>{await assert.rejects(()=>rpc('send_chat_message',[support,'Forbidden new chat request.',null,crypto.randomUUID()]),/unavailable/);});
 await actor('customer',async()=>{
  let count=Number((await db.query('select count(*) as n from messages where sender_id=$1',[ids.customer])).rows[0].n);
  while(count++<30)await rpc('send_chat_message',[support,'Rate limit fixture '+count,null,crypto.randomUUID()]);
  await assert.rejects(()=>rpc('send_chat_message',[support,'One message too many.',null,crypto.randomUUID()]),/limit reached/);
 });
 await actor('worker',async()=>{await rpc('manage_conversation',[support,'close']);});
 await actor('customer',async()=>{
  await assert.rejects(()=>rpc('send_chat_message',[support,'Cannot send into a closed conversation.',null,crypto.randomUUID()]),/closed/);
  assert.ok(await rpc('send_chat_message',[support,'Message with a delivery reference.','oil','90000000-0000-4000-8000-000000000001']),'A confirmed retry remains safe after closure');
 });
 let banner;
 const bannerDraft={title:'Workshop offer',alt_text:'',image_url:null,mobile_image_url:null,link_path:'/shop?category=Engine%20Oil',position:1,published:false};
 await actor('customer',async()=>{await assert.rejects(()=>rpc('admin_save_banner',[JSON.stringify(bannerDraft),null]),/permission/);});
 await actor('worker',async()=>{await assert.rejects(()=>rpc('admin_save_banner',[JSON.stringify(bannerDraft),null]),/permission/);});
 await actor('admin',async()=>{banner=await rpc('admin_save_banner',[JSON.stringify(bannerDraft),null]);await assert.rejects(()=>rpc('admin_save_banner',[JSON.stringify({...bannerDraft,id:banner,published:true}),1]),/constraint/);await assert.rejects(()=>rpc('admin_save_banner',[JSON.stringify({...bannerDraft,id:banner,link_path:'https://external.example'}),1]),/store page/);});
 await actor('customer',async()=>{assert.equal((await db.query('select * from promotion_banners')).rows.length,0);});
 await actor('admin',async()=>{await rpc('admin_save_banner',[JSON.stringify({...bannerDraft,id:banner,published:true,image_url:'https://example.test/banner.webp',alt_text:'Service essentials promotion'}),1]);await assert.rejects(()=>rpc('admin_save_banner',[JSON.stringify({...bannerDraft,id:banner}),1]),/changed/);});
 await actor('customer',async()=>{assert.equal((await db.query('select * from promotion_banners')).rows.length,1);await assert.rejects(()=>db.exec('delete from promotion_banners'),/permission denied/);});
 await actor('admin',async()=>{await rpc('admin_delete_banner',[banner]);});
 assert.equal((await db.query('select * from promotion_banners')).rows.length,0);
 console.log('Verified SQL/RLS: customer isolation, role escalation prevention, authoritative prices, stock, idempotency, payment/refund states, received-only reviews, private chat, restock and incremental migration.');
 }finally{await db.close();}
});
