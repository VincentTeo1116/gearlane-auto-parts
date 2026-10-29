import test from 'node:test';
import assert from 'node:assert/strict';
import {PGlite} from '@electric-sql/pglite';
import {readFile} from 'node:fs/promises';

test('order-email log, stock alerts and vehicle fitment obey their access rules',async()=>{
 const db=await PGlite.create();
 const ids={customer:'10000000-0000-4000-8000-000000000001',other:'10000000-0000-4000-8000-000000000002',worker:'10000000-0000-4000-8000-000000000003',admin:'10000000-0000-4000-8000-000000000004'};
 const as=async(role,fn)=>{await db.exec('reset role');await db.query("select set_config('request.jwt.claim.sub',$1,false)",[ids[role]||'']);await db.exec(role==='anon'?'set role anon':'set role authenticated');try{return await fn();}finally{await db.exec('reset role');}};
 const rpc=async(name,args=[])=>{const placeholders=args.map((_,i)=>'$'+(i+1)).join(',');return (await db.query(`select public.${name}(${placeholders}) as value`,args)).rows[0]?.value;};
 const sql=file=>readFile(new URL('../supabase/'+file,import.meta.url),'utf8');
 try{
  await db.exec(`create role anon;create role authenticated;create schema auth;create schema storage;create table auth.users(id uuid primary key,email text,raw_user_meta_data jsonb default '{}');create table storage.objects(bucket_id text,name text);create function auth.uid() returns uuid language sql stable as $$select nullif(current_setting('request.jwt.claim.sub',true),'')::uuid$$;grant usage on schema public,auth to anon,authenticated;grant execute on function auth.uid() to anon,authenticated;`);
  for(const name of ['001-schema.sql','002-commerce.sql','003-workspace.sql','007-chat-delivery.sql'])await db.exec(await sql(name));
  await db.exec((await sql('008-promotion-banners.sql')).split('-- Supabase Storage')[0]);
  for(const name of ['012-order-emails.sql','013-stock-alerts.sql','014-vehicle-fitment.sql','015-staff-alerts.sql']){await db.exec(await sql(name));await db.exec(await sql(name));} // idempotent
  for(const [role,id] of Object.entries(ids))await db.query("insert into auth.users(id,email,raw_user_meta_data) values($1,$2,$3)",[id,role+'@example.test',JSON.stringify({full_name:'Test '+role})]);
  await db.query("update profiles set role='worker' where id=$1",[ids.worker]);await db.query("update profiles set role='admin' where id=$1",[ids.admin]);
  const product=(id,stock,extra='')=>db.exec(`insert into products(id,sku,name,brand,category,description,price_cents,price_confirmed,stock,active) values('${id}','SKU-${id}','Product ${id}','Brand','Cat','A test product description.',1000,${extra.includes('unconfirmed')?'false':'true'},${stock},${extra.includes('inactive')?'false':'true'})`);
  await product('out1',0);await product('out2',0);await product('instock',5);await product('hidden',0,'inactive');await product('unconf',0,'unconfirmed');

  // ---- order email log: server only
  await db.exec(`insert into orders(id,customer_id,address,subtotal_cents,discount_cents,shipping_cents,total_cents,idempotency_key,payment_instructions) values('30000000-0000-4000-8000-000000000001','${ids.customer}','{}',1000,0,0,1000,'20000000-0000-4000-8000-000000000001','{}')`);
  await db.exec("insert into order_emails(order_id,event) values('30000000-0000-4000-8000-000000000001','placed')");
  await assert.rejects(()=>db.exec("insert into order_emails(order_id,event) values('30000000-0000-4000-8000-000000000001','placed')"),/duplicate|unique/,'one email per order and event');
  await assert.rejects(()=>db.exec("insert into order_emails(order_id,event) values('30000000-0000-4000-8000-000000000001','refunded')"),/check/,'unknown events are rejected');
  for(const role of ['anon','customer','worker','admin'])await as(role,async()=>{
    await assert.rejects(()=>db.query('select * from order_emails'),/permission denied/,role+' cannot read the email log');
    await assert.rejects(()=>db.exec("delete from order_emails"),/permission denied/);
  });

  // ---- staff alert throttle: server only
  await db.exec(`insert into conversations(id,kind,customer_id,title,created_by) values('50000000-0000-4000-8000-000000000001','support','${ids.customer}','Brake pads','${ids.customer}')`);
  await db.exec("insert into staff_alerts(conversation_id) values('50000000-0000-4000-8000-000000000001')");
  await assert.rejects(()=>db.exec("insert into staff_alerts(conversation_id) values('50000000-0000-4000-8000-000000000001')"),/duplicate|unique/,'one slot per conversation');
  for(const role of ['anon','customer','worker','admin'])await as(role,async()=>{
    await assert.rejects(()=>db.query('select * from staff_alerts'),/permission denied/,role+' cannot read alert timing');
    await assert.rejects(()=>db.exec("update staff_alerts set last_sent_at=now()-interval '1 day'"),/permission denied/,role+' cannot reset the throttle');
  });
  await db.exec("delete from conversations where id='50000000-0000-4000-8000-000000000001'");
  assert.equal((await db.query('select count(*)::int as n from staff_alerts')).rows[0].n,0,'the slot goes when its conversation does');

  // ---- stock alerts
  await as('customer',async()=>{
   assert.equal(await rpc('toggle_stock_alert',['out1']),true);
   assert.equal(await rpc('toggle_stock_alert',['out1']),false,'toggling again unfollows');
   assert.equal(await rpc('toggle_stock_alert',['out1']),true);assert.equal(await rpc('toggle_stock_alert',['out2']),true);assert.equal(await rpc('toggle_stock_alert',['unconf']),true);
   await assert.rejects(()=>rpc('toggle_stock_alert',['instock']),/in stock now/);
   await assert.rejects(()=>rpc('toggle_stock_alert',['hidden']),/unavailable/);
   await assert.rejects(()=>rpc('toggle_stock_alert',['nope']),/unavailable/);
   await assert.rejects(()=>db.exec("insert into stock_alerts(user_id,product_id) values('"+ids.other+"','out1')"),/permission denied/,'no direct writes, so nobody can follow on behalf of another person');
  });
  await as('other',async()=>{assert.equal((await db.query('select * from stock_alerts')).rows.length,0,'followers are private');assert.equal(await rpc('toggle_stock_alert',['out1']),true);});
  for(const role of ['worker','admin'])await as(role,async()=>{assert.equal((await db.query('select * from stock_alerts')).rows.length,0);await assert.rejects(()=>rpc('toggle_stock_alert',['out1']),/permission/);});
  await as('anon',async()=>assert.rejects(()=>db.query('select * from stock_alerts'),/permission denied/));
  await db.exec("update products set stock=3 where id='out1'");
  const titles=async uid=>(await db.query('select title,route from notifications where user_id=$1 order by created_at',[uid])).rows;
  assert.deepEqual(await titles(ids.customer),[{title:'Back in stock: Product out1',route:'/products/out1'}]);
  assert.equal((await titles(ids.other)).length,1,'every follower is told');
  assert.equal((await db.query("select count(*)::int as n from stock_alerts where product_id='out1'")).rows[0].n,0,'the follow ends once the customer is told');
  assert.equal((await db.query("select count(*)::int as n from stock_alerts where product_id='out2'")).rows[0].n,1,'other products are untouched');
  await db.exec("update products set stock=9 where id='out1'");assert.equal((await titles(ids.customer)).length,1,'a second change does not notify again');
  await db.exec("update products set stock=4 where id='unconf'");assert.equal((await titles(ids.customer)).length,1,'a product without a confirmed price does not announce itself');
  await db.exec("update products set stock=0 where id='out2'");await db.exec("update products set stock=0,active=false where id='out2'");await db.exec("update products set stock=2 where id='out2'");assert.equal((await titles(ids.customer)).length,1,'inactive products stay quiet');
  await db.exec("delete from stock_alerts");
  await db.exec(`insert into products(id,sku,name,brand,category,description,price_cents,price_confirmed,stock) select 'bulk'||g,'BULK-'||g,'Bulk '||g,'Brand','Cat','A test product description.',1000,true,0 from generate_series(0,50) g on conflict do nothing`);
  await as('customer',async()=>{for(let i=0;i<50;i++)await rpc('toggle_stock_alert',['bulk'+i]);await assert.rejects(()=>rpc('toggle_stock_alert',['bulk50']),/up to 50/);});

  // ---- vehicle fitment
  const rows=[{make:'Proton',model:'X50',year_from:2020,year_to:2024},{make:'Perodua',model:'Myvi',year_from:null,year_to:null}];
  await as('customer',async()=>assert.rejects(()=>rpc('admin_set_fitment',['instock',JSON.stringify(rows)]),/permission/));
  await as('worker',async()=>assert.rejects(()=>rpc('admin_set_fitment',['instock',JSON.stringify(rows)]),/permission/));
  await as('anon',async()=>assert.rejects(()=>rpc('admin_set_fitment',['instock',JSON.stringify(rows)]),/permission/));
  await as('customer',async()=>assert.rejects(()=>db.exec("insert into product_fitment(product_id,make,model) values('instock','Proton','Saga')"),/permission denied/,'no direct writes'));
  await as('admin',async()=>{
   assert.equal(Number(await rpc('admin_set_fitment',['instock',JSON.stringify(rows)])),2);
   await assert.rejects(()=>rpc('admin_set_fitment',['nope',JSON.stringify(rows)]),/not found/);
   await assert.rejects(()=>rpc('admin_set_fitment',['instock',JSON.stringify([{make:'Proton',model:'X50',year_from:2024,year_to:2020}])]),/check/,'years must run forward');
   await assert.rejects(()=>rpc('admin_set_fitment',['instock',JSON.stringify([{make:'Proton',model:'X50',year_from:2020,year_to:null}])]),/check/,'both years or neither');
   await assert.rejects(()=>rpc('admin_set_fitment',['instock',JSON.stringify([{make:'P',model:'X'}])]),/check/,'make needs at least 2 characters');
   await assert.rejects(()=>rpc('admin_set_fitment',['instock',JSON.stringify(Array.from({length:61},(_,i)=>({make:'Make',model:'M'+i})))]),/up to 60/);
   await assert.rejects(()=>rpc('admin_set_fitment',['instock','{}']),/up to 60|array/);
  });
  assert.equal((await db.query("select count(*)::int as n from product_fitment where product_id='instock'")).rows[0].n,2,'a rejected update changes nothing (all or nothing)');
  await as('admin',async()=>assert.equal(Number(await rpc('admin_set_fitment',['instock',JSON.stringify([rows[0]])])),1));
  assert.equal((await db.query("select count(*)::int as n from product_fitment where product_id='instock'")).rows[0].n,1,'saving replaces the previous list');
  assert.equal((await db.query("select count(*)::int as n from audit_events where action='fitment_saved'")).rows[0].n,2,'changes are audited');
  await as('admin',()=>rpc('admin_set_fitment',['hidden',JSON.stringify([rows[0]])]));
  await as('anon',async()=>{const list=(await db.query('select product_id,make,model,year_from,year_to from product_fitment')).rows;assert.deepEqual(list.map(r=>r.product_id),['instock'],'public sees fitment of active products only');assert.equal(list[0].model,'X50');});
  await as('worker',async()=>assert.equal((await db.query('select * from product_fitment')).rows.length,2,'staff also see fitment of archived products'));
 }finally{await db.close();}
});
