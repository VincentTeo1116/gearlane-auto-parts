import test from 'node:test';
import assert from 'node:assert/strict';
import {PGlite} from '@electric-sql/pglite';
import {readFile} from 'node:fs/promises';

test('signed-out visitors and customers cannot read bank details, list promotion codes or see reviewer identifiers',async()=>{
 const db=await PGlite.create();
 const ids={customer:'10000000-0000-4000-8000-000000000001',worker:'10000000-0000-4000-8000-000000000003',admin:'10000000-0000-4000-8000-000000000004'};
 const as=async(role,fn)=>{await db.exec('reset role');if(role!=='anon')await db.query("select set_config('request.jwt.claim.sub',$1,false)",[ids[role]]);else await db.query("select set_config('request.jwt.claim.sub','',false)");await db.exec(role==='anon'?'set role anon':'set role authenticated');try{return await fn();}finally{await db.exec('reset role');}};
 const rpc=async(name,args=[])=>{const placeholders=args.map((_,i)=>'$'+(i+1)).join(',');return (await db.query(`select public.${name}(${placeholders}) as value`,args)).rows[0]?.value;};
 try{
  await db.exec(`create role anon;create role authenticated;create schema auth;create schema storage;create table auth.users(id uuid primary key,email text,raw_user_meta_data jsonb default '{}');create table storage.objects(bucket_id text,name text);create function auth.uid() returns uuid language sql stable as $$select nullif(current_setting('request.jwt.claim.sub',true),'')::uuid$$;grant usage on schema public,auth to anon,authenticated;grant execute on function auth.uid() to anon,authenticated;`);
  for(const name of ['001-schema.sql','002-commerce.sql','003-workspace.sql','007-chat-delivery.sql'])await db.exec(await readFile(new URL('../supabase/'+name,import.meta.url),'utf8'));
  await db.exec((await readFile(new URL('../supabase/008-promotion-banners.sql',import.meta.url),'utf8')).split('-- Supabase Storage')[0]);
  const migration=await readFile(new URL('../supabase/010-privacy-hardening.sql',import.meta.url),'utf8');
  await db.exec(migration);
  await db.exec(migration); // idempotent: safe to run twice
  for(const [role,id] of Object.entries(ids))await db.query("insert into auth.users(id,email,raw_user_meta_data) values($1,$2,$3)",[id,role+'@example.test',JSON.stringify({full_name:'Test '+role})]);
  await db.query("update profiles set role='worker' where id=$1",[ids.worker]);await db.query("update profiles set role='admin' where id=$1",[ids.admin]);
  await db.exec("update store_settings set checkout_enabled=true,bank_name='Secret bank',bank_account_name='GearLane',bank_account_number='123456789',shipping_cents=500");
  await db.exec("insert into products(id,sku,name,brand,category,description,price_cents,price_confirmed,stock) values('oil','OIL-1','Test engine oil','Test','Engine Oil','A test product description.',10000,true,5)");
  await db.exec("insert into promotions(code,kind,value,minimum_cents,maximum_uses,starts_at,ends_at,active) values('SECRET10','percent',10,0,5,now()-interval '1 day',now()+interval '1 day',true),('EXPIRED5','fixed',500,0,5,now()-interval '3 day',now()-interval '2 day',true)");

  // 1. Bank details
  for(const role of ['anon','customer','worker']){
   await as(role,async()=>{
    await assert.rejects(()=>db.query('select bank_account_number from store_settings'),/permission denied/,role+' must not read the settings table');
    await assert.rejects(()=>db.query('select * from store_settings'),/permission denied/);
    const view=(await db.query('select * from public_store_settings')).rows[0];
    assert.equal(view.store_name,'GearLane Auto Parts');assert.equal(view.shipping_cents,500);assert.equal(view.checkout_enabled,true);
    assert.deepEqual(Object.keys(view).filter(k=>k.startsWith('bank_')),[],'public settings never include bank fields');
    await assert.rejects(()=>rpc('admin_get_settings'),/permission/);
   });
  }
  const full=await as('admin',()=>rpc('admin_get_settings'));
  assert.equal(full.bank_account_number,'123456789');
  await as('admin',()=>db.query("select public.admin_save_settings($1::jsonb)",[JSON.stringify({store_name:'GearLane Auto Parts',bank_name:'New bank',bank_account_name:'GearLane',bank_account_number:'987654321',shipping_cents:500,free_shipping_cents:0,checkout_enabled:true,contact_email:'a@example.test',return_policy:'Contact the seller to confirm return eligibility before purchasing.'})]));
  assert.equal((await as('admin',()=>rpc('admin_get_settings'))).bank_name,'New bank','admins can still save settings');

  // 2. Promotions
  await as('anon',async()=>assert.rejects(()=>db.query('select code from promotions'),/permission denied/));
  await as('customer',async()=>{
   assert.equal((await db.query('select code from promotions')).rows.length,0,'customers cannot list codes');
   const started=Date.now();
   const promo=await rpc('check_promotion',[' secret10 ']);
   assert.deepEqual([promo.code,promo.kind,Number(promo.value),promo.active],['SECRET10','percent',10,true]);
   assert.ok(!('used_count' in promo)&&!('maximum_uses' in promo),'usage limits are not disclosed');
   const miss=Date.now();
   await assert.rejects(()=>rpc('check_promotion',['NOPE1234']),/promotion code is not valid/);
   await assert.rejects(()=>rpc('check_promotion',['EXPIRED5']),/promotion code is not valid/);
   await assert.rejects(()=>rpc('check_promotion',['x'.repeat(31)]),/promotion code is not valid/);
   assert.ok(Date.now()-miss>=1000,'failed guesses are slowed down');
   assert.ok(miss-started<1000,'a valid code is answered immediately');
  });
  await as('anon',async()=>assert.rejects(()=>rpc('check_promotion',['SECRET10']),/permission denied/));
  await as('worker',async()=>assert.rejects(()=>rpc('check_promotion',['SECRET10']),/permission/));
  assert.equal((await as('admin',()=>db.query('select code from promotions'))).rows.length,2,'admins still manage all promotions');

  // 3. Reviews: public text only for signed-out visitors
  await db.exec("insert into orders(id,customer_id,address,subtotal_cents,discount_cents,shipping_cents,total_cents,idempotency_key,payment_instructions,status,payment_status,received_at) values('30000000-0000-4000-8000-000000000001','"+ids.customer+"','{}',10000,0,0,10000,'20000000-0000-4000-8000-000000000009','{}','delivered','verified',now())");
  await db.exec("insert into reviews(order_id,product_id,customer_id,display_name,rating,body) values('30000000-0000-4000-8000-000000000001','oil','"+ids.customer+"','Test C.',5,'Excellent product, fast delivery.')");
  await as('anon',async()=>{
   const rows=(await db.query('select id,product_id,rating,body,display_name,reply,published,created_at from reviews')).rows;
   assert.equal(rows.length,1);assert.equal(rows[0].display_name,'Test C.');
   await assert.rejects(()=>db.query('select customer_id from reviews'),/permission denied/);
   await assert.rejects(()=>db.query('select order_id from reviews'),/permission denied/);
   await assert.rejects(()=>db.query('select * from reviews'),/permission denied/);
  });
  await as('customer',async()=>assert.equal((await db.query('select customer_id,order_id from reviews')).rows.length,1,'the owner still sees which order they reviewed'));

  // Products and announcements stay public for the storefront
  await as('anon',async()=>assert.equal((await db.query('select id from products')).rows.length,1));
 }finally{await db.close();}
});
