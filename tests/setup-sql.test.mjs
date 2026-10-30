import test from 'node:test';
import assert from 'node:assert/strict';
import {PGlite} from '@electric-sql/pglite';
import {readFile} from 'node:fs/promises';

/* A brand new project runs ONE file: supabase/setup.sql. The individual migrations are tested elsewhere; this proves
   the combined file runs from scratch, in order, and leaves every feature's tables, functions and rules in place. */
test('setup.sql builds a complete, working database on its own',async()=>{
  const db=await PGlite.create();
  const ids={customer:'10000000-0000-4000-8000-000000000001',admin:'10000000-0000-4000-8000-000000000004'};
  const as=async(role,fn)=>{await db.exec('reset role');await db.query("select set_config('request.jwt.claim.sub',$1,false)",[ids[role]||'']);await db.exec(role==='anon'?'set role anon':'set role authenticated');try{return await fn();}finally{await db.exec('reset role');}};
  try{
    await db.exec(`
      create role anon;create role authenticated;create schema auth;create schema storage;
      create table auth.users(id uuid primary key,email text,raw_user_meta_data jsonb default '{}');
      create table storage.buckets(id text primary key,name text,public boolean,file_size_limit bigint,allowed_mime_types text[]);
      create table storage.objects(bucket_id text,name text);alter table storage.objects enable row level security;
      create function storage.foldername(name text) returns text[] language sql as $$select string_to_array(name,'/')$$;
      create function auth.uid() returns uuid language sql stable as $$select nullif(current_setting('request.jwt.claim.sub',true),'')::uuid$$;
      create publication supabase_realtime;
      grant usage on schema public,auth,storage to anon,authenticated;grant execute on function auth.uid() to anon,authenticated;`);
    const script=await readFile(new URL('../supabase/setup.sql',import.meta.url),'utf8');
    await db.exec(script);                       // the whole file, exactly as a new project would run it
    const exists=async(sql)=>(await db.query(sql)).rows[0].n>0;
    for(const table of ['store_settings','products','orders','order_emails','stock_alerts','product_fitment','staff_alerts','saved_addresses','garage_vehicles','product_questions'])
      assert.ok(await exists(`select count(*)::int as n from information_schema.tables where table_schema='public' and table_name='${table}'`),'table '+table);
    for(const fn of ['create_order','check_promotion','admin_get_settings','dashboard_previous_period','toggle_stock_alert','admin_set_fitment','save_address','add_garage_vehicle','ask_question','answer_question','moderate_question','admin_save_settings'])
      assert.ok(await exists(`select count(*)::int as n from pg_proc p join pg_namespace n on n.oid=p.pronamespace where n.nspname='public' and p.proname='${fn}'`),'function '+fn);
    // behaviour that depends on the later migrations replacing earlier objects
    for(const [role,id] of Object.entries(ids))await db.query("insert into auth.users(id,email,raw_user_meta_data) values($1,$2,$3)",[id,role+'@example.test',JSON.stringify({full_name:'Test '+role})]);
    await db.query("update profiles set role='admin' where id=$1",[ids.admin]);
    await db.exec("update store_settings set bank_account_number='123456789',invoice_details='Seller details'");
    await as('anon',async()=>{
      const view=(await db.query('select * from public_store_settings')).rows[0];
      assert.equal(view.invoice_details,'Seller details','the public settings view includes invoice details (018 replaced the 010 view)');
      assert.equal(Object.keys(view).some(k=>k.startsWith('bank_')),false,'and still never the bank details');
      await assert.rejects(()=>db.query('select bank_account_number from store_settings'),/permission denied/);
    });
    await as('admin',async()=>{
      await db.query("select public.admin_save_settings($1::jsonb)",[JSON.stringify({store_name:'GearLane Auto Parts',bank_name:'Bank',bank_account_name:'GearLane',bank_account_number:'123456789',shipping_cents:500,free_shipping_cents:0,checkout_enabled:true,contact_email:'a@example.test',return_policy:'Policy.',invoice_details:'New details'})]);
      assert.equal((await db.query('select public.admin_get_settings() as v')).rows[0].v.invoice_details,'New details');
    });
    assert.equal((await db.query('select count(*)::int as n from pg_policies where tablename in (\'saved_addresses\',\'garage_vehicles\',\'product_questions\',\'stock_alerts\',\'product_fitment\')')).rows[0].n>=5,true,'row-level security policies exist for the new tables');
    for(const table of ['saved_addresses','garage_vehicles','product_questions','stock_alerts','order_emails','staff_alerts'])
      assert.equal((await db.query(`select relrowsecurity from pg_class where relname='${table}' and relnamespace='public'::regnamespace`)).rows[0].relrowsecurity,true,table+' has row-level security on');
  }finally{await db.close();}
});
