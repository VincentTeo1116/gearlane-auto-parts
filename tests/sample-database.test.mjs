import test from 'node:test';
import assert from 'node:assert/strict';
import {readFile} from 'node:fs/promises';
import {PGlite} from '@electric-sql/pglite';
import {previewAnalytics} from '../src/preview-analytics.mjs';

test('test-project seed reconciles real SQL reports, preserves existing records, reruns safely and cleans up with conflict protection',async()=>{
 const db=await PGlite.create(),read=name=>readFile(new URL('../supabase/'+name,import.meta.url),'utf8');
 const admin='10000000-0000-4000-8000-000000000003',buyer='10000000-0000-4000-8000-000000000001';
 const seed=await read('examples/seed-analytics.sql'),cleanup=await read('examples/remove-analytics.sql');
 try{
  await db.exec("create role anon;create role authenticated;create schema auth;create schema storage;create table auth.users(id uuid primary key,email text,raw_user_meta_data jsonb default '{}');create table storage.objects(bucket_id text,name text);create function auth.uid() returns uuid language sql stable as $$select nullif(current_setting('request.jwt.claim.sub',true),'')::uuid$$;grant usage on schema public,auth to anon,authenticated;grant execute on function auth.uid() to anon,authenticated;");
  for(const name of ['001-schema.sql','002-commerce.sql','003-workspace.sql','005-catalogue.sql'])await db.exec(await read(name));
  await db.query("insert into auth.users(id,email,raw_user_meta_data) values($1,'owner@example.test','{\"full_name\":\"Existing Owner\"}'),($2,'buyer@example.test','{\"full_name\":\"Existing Buyer\"}')",[admin,buyer]);
  await db.query("update profiles set role='admin' where id=$1",[admin]);
  await db.exec("update store_settings set checkout_enabled=true,shipping_cents=2500,free_shipping_cents=50000,bank_name='Existing bank',bank_account_name='Existing store',bank_account_number='123456789';update products set price_cents=15555,stock=7,price_confirmed=true where id='toyota-fully-synthetic-0w-20-engine-oil-4l';");
  await db.query("select set_config('request.jwt.claim.sub',$1,false)",[buyer]);
  const existing=(await db.query("select create_order($1::jsonb,$2::jsonb,'',$3::uuid,18055) id",[JSON.stringify([{product_id:'toyota-fully-synthetic-0w-20-engine-oil-4l',quantity:1}]),JSON.stringify({name:'Existing Buyer',phone:'0123456789',line1:'12 Existing Test Street',city:'Kuala Lumpur',postcode:'50000',state:'Kuala Lumpur'}),'20000000-0000-4000-8000-000000000099'])).rows[0].id;
  const before=(await db.query('select id,stock,price_confirmed,price_cents from products order by id')).rows;
  const settings=(await db.query('select * from store_settings')).rows;
  await db.exec(seed);
  assert.equal((await db.query('select count(*)::int n from orders')).rows[0].n,85);
  assert.equal((await db.query('select count(*)::int n from profiles')).rows[0].n,14);
  assert.deepEqual((await db.query('select * from store_settings')).rows,settings);
  assert.deepEqual((await db.query('select id,price_cents from products order by id')).rows,before.map(({id,price_cents})=>({id,price_cents})));
  assert.equal((await db.query('select count(*)::int n from order_items where line_total_cents<>quantity*price_cents')).rows[0].n,0);
  assert.equal((await db.query('select count(*)::int n from orders o where subtotal_cents<>(select sum(line_total_cents) from order_items i where i.order_id=o.id)')).rows[0].n,0);
  assert.equal((await db.query('select count(*)::int n from refunds r join orders o on r.order_id=o.id where r.amount_cents<>o.total_cents')).rows[0].n,0);
  const orders=(await db.query("select o.*,coalesce((select jsonb_agg(i) from order_items i where i.order_id=o.id),'[]'::jsonb) items from orders o")).rows;
  const state={orders,users:(await db.query('select * from profiles')).rows,products:(await db.query('select * from products')).rows,activity:(await db.query('select * from activity_events')).rows,wishlist:(await db.query('select * from wishlist')).rows};
  await db.query("select set_config('request.jwt.claim.sub',$1,false)",[admin]);
  for(const days of [7,30,90]){
   const actual=(await db.query('select dashboard_stats($1) stats',[days])).rows[0].stats,expected=previewAnalytics(state,days);
   assert.equal(Number(actual.paid_sales_cents),expected.paid_sales_cents);assert.equal(Number(actual.paid_orders),expected.paid_orders);
   assert.equal(Number(actual.active_customers),expected.active_customers);
   assert.equal(actual.categories.reduce((s,c)=>s+Number(c.value),0),expected.categories.reduce((s,c)=>s+c.value,0));
  }
  const after=(await db.query('select id,stock,version from products order by id')).rows;
  await db.exec(seed);assert.deepEqual((await db.query('select id,stock,version from products order by id')).rows,after);
  assert.equal((await db.query('select count(*)::int n from orders')).rows[0].n,85);
  await db.query("select set_config('request.jwt.claim.sub',$1,false)",[buyer]);await db.exec('set role authenticated');
  assert.equal((await db.query('select count(*)::int n from orders')).rows[0].n,1,'Customer cannot read fictional customers’ orders');
  await db.exec('reset role');
  await db.query('update products set stock=stock+1,version=version+1 where id=$1',[after[0].id]);
  await assert.rejects(()=>db.exec(cleanup),/changed after seeding/);await db.exec('rollback');
  assert.equal((await db.query('select count(*)::int n from orders')).rows[0].n,85,'Conflicting cleanup leaves the dataset intact');
  await db.query('update products set stock=$1,version=$2 where id=$3',[after[0].stock,after[0].version,after[0].id]);
  await db.exec(cleanup);
  assert.deepEqual((await db.query('select id,stock,price_confirmed,price_cents from products order by id')).rows,before);
  assert.equal((await db.query('select id from orders')).rows[0].id,existing);
  assert.equal((await db.query('select count(*)::int n from profiles')).rows[0].n,2);
  await db.exec(cleanup);
 }finally{await db.close();}
});
