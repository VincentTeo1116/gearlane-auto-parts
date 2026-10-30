import test from 'node:test';
import assert from 'node:assert/strict';
import {PGlite} from '@electric-sql/pglite';
import {readFile} from 'node:fs/promises';

test('address book, garage, product questions and invoice details obey their access rules',async()=>{
 const db=await PGlite.create();
 const ids={customer:'10000000-0000-4000-8000-000000000001',other:'10000000-0000-4000-8000-000000000002',worker:'10000000-0000-4000-8000-000000000003',admin:'10000000-0000-4000-8000-000000000004'};
 const as=async(role,fn)=>{await db.exec('reset role');await db.query("select set_config('request.jwt.claim.sub',$1,false)",[ids[role]||'']);await db.exec(role==='anon'?'set role anon':'set role authenticated');try{return await fn();}finally{await db.exec('reset role');}};
 const rpc=async(name,args=[])=>{const placeholders=args.map((_,i)=>'$'+(i+1)).join(',');return (await db.query(`select public.${name}(${placeholders}) as value`,args)).rows[0]?.value;};
 const rows=async sql=>(await db.query(sql)).rows;
 const sql=file=>readFile(new URL('../supabase/'+file,import.meta.url),'utf8');
 const address={label:' Home ',name:'Amir Rahman',phone:'0123456789',line1:'12 Jalan Demo, Taman Contoh',city:'Petaling Jaya',postcode:'47300',state:'Selangor'};
 try{
  await db.exec(`create role anon;create role authenticated;create schema auth;create schema storage;create table auth.users(id uuid primary key,email text,raw_user_meta_data jsonb default '{}');create table storage.objects(bucket_id text,name text);create function auth.uid() returns uuid language sql stable as $$select nullif(current_setting('request.jwt.claim.sub',true),'')::uuid$$;grant usage on schema public,auth to anon,authenticated;grant execute on function auth.uid() to anon,authenticated;`);
  for(const name of ['001-schema.sql','002-commerce.sql','003-workspace.sql','007-chat-delivery.sql'])await db.exec(await sql(name));
  await db.exec((await sql('008-promotion-banners.sql')).split('-- Supabase Storage')[0]);
  for(const name of ['010-privacy-hardening.sql','016-address-book-and-garage.sql','017-product-questions.sql','018-invoice-details.sql']){await db.exec(await sql(name));await db.exec(await sql(name));} // idempotent
  const names={customer:'Amir Rahman',other:'Siti',worker:'Sarah Tan',admin:'Admin User'};
  for(const [role,id] of Object.entries(ids))await db.query("insert into auth.users(id,email,raw_user_meta_data) values($1,$2,$3)",[id,role+'@example.test',JSON.stringify({full_name:names[role]})]);
  await db.query("update profiles set role='worker' where id=$1",[ids.worker]);await db.query("update profiles set role='admin' where id=$1",[ids.admin]);
  const product=(id,active=true)=>db.exec(`insert into products(id,sku,name,brand,category,description,price_cents,price_confirmed,stock,active) values('${id}','SKU-${id}','Product ${id}','Brand','Cat','A test product description.',1000,true,5,${active})`);
  await product('p1');await product('p2');await product('p3');await product('hidden',false);

  // =============== Address book ===============
  let a1,a2;
  await as('customer',async()=>{
   a1=await rpc('save_address',[JSON.stringify(address)]);
   assert.equal((await rows('select label,is_default from saved_addresses'))[0].label,'Home','text is trimmed');
   assert.equal((await rows('select is_default from saved_addresses'))[0].is_default,true,'the first address becomes the default');
   a2=await rpc('save_address',[JSON.stringify({...address,label:'Workshop',line1:'88 Jalan Bengkel, Shah Alam'})]);
   assert.deepEqual((await rows('select label,is_default from saved_addresses order by created_at')).map(r=>[r.label,r.is_default]),[['Home',true],['Workshop',false]]);
   await rpc('save_address',[JSON.stringify({...address,label:'Workshop',line1:'88 Jalan Bengkel, Shah Alam'}),a2,true]);
   assert.deepEqual((await rows('select label from saved_addresses where is_default')).map(r=>r.label),['Workshop'],'only one default at a time');
   await rpc('save_address',[JSON.stringify({...address,label:'Home',city:'Subang Jaya'}),a1,false]);
   assert.equal((await rows("select city from saved_addresses where label='Home'"))[0].city,'Subang Jaya','an address can be edited');
   assert.equal((await rows('select is_default from saved_addresses where id=$1'.replace('$1',`'${a2}'`)))[0].is_default,true,'editing without the default flag keeps the default');
   await assert.rejects(()=>rpc('save_address',[JSON.stringify({...address,postcode:'1234'})]),/check/,'postcode must be 5 digits');
   await assert.rejects(()=>rpc('save_address',[JSON.stringify({...address,phone:'abc'})]),/check/);
   await assert.rejects(()=>rpc('save_address',[JSON.stringify({...address,line1:'short'})]),/check/);
   await assert.rejects(()=>rpc('save_address',[JSON.stringify({...address,label:'x'.repeat(41)})]),/check/);
   await assert.rejects(()=>rpc('save_address',['[]']),/Check the address/);
   await assert.rejects(()=>rpc('save_address',[JSON.stringify(address),'50000000-0000-4000-8000-000000000099']),/not found/);
   await assert.rejects(()=>db.exec("insert into saved_addresses(user_id,name,phone,line1,city,postcode,state) values(auth.uid(),'A B','0123456789','12 Jalan Demo Test','PJ','47300','Selangor')"),/permission denied/,'no direct writes');
  });
  await as('other',async()=>{
   assert.equal((await rows('select * from saved_addresses')).length,0,'addresses are private');
   await assert.rejects(()=>rpc('save_address',[JSON.stringify(address),a1]),/not found/,'cannot edit someone else\'s address');
   await assert.rejects(()=>rpc('delete_address',[a1]),/not found/);
   await assert.rejects(()=>rpc('set_default_address',[a1]),/not found/);
  });
  for(const role of ['anon','worker','admin'])await as(role,async()=>{await assert.rejects(()=>rpc('save_address',[JSON.stringify(address)]),/permission/);if(role!=='anon')assert.equal((await rows('select * from saved_addresses')).length,0);});
  await as('customer',async()=>{
   await rpc('set_default_address',[a1]);assert.deepEqual((await rows('select label from saved_addresses where is_default')).map(r=>r.label),['Home']);
   await rpc('delete_address',[a1]);
   assert.deepEqual((await rows('select label,is_default from saved_addresses')).map(r=>[r.label,r.is_default]),[['Workshop',true]],'deleting the default promotes another address');
   for(let i=0;i<9;i++)await rpc('save_address',[JSON.stringify({...address,label:'Extra '+i})]);
   assert.equal((await rows('select * from saved_addresses')).length,10);
   await assert.rejects(()=>rpc('save_address',[JSON.stringify(address)]),/up to 10/);
   assert.equal((await rows('select * from saved_addresses where is_default')).length,1);
  });

  // =============== Garage ===============
  let v1,v2;
  await as('customer',async()=>{
   v1=await rpc('add_garage_vehicle',['Proton','X50',2022,'Daily car']);
   assert.deepEqual((await rows('select make,model,year,is_active from garage_vehicles')).map(r=>[r.make,r.model,r.year,r.is_active]),[['Proton','X50',2022,true]]);
   v2=await rpc('add_garage_vehicle',[' Perodua ','Myvi',null]);
   assert.deepEqual((await rows('select model,is_active from garage_vehicles order by created_at')).map(r=>[r.model,r.is_active]),[['X50',false],['Myvi',true]],'adding activates it and switches the previous one off');
   assert.equal(await rpc('add_garage_vehicle',['proton','x50',2022]),v1,'the same vehicle is found, not duplicated');
   assert.deepEqual((await rows('select model from garage_vehicles where is_active')).map(r=>r.model),['X50'],'and becomes active again');
   await rpc('add_garage_vehicle',['Honda','Civic',2015,'',false]);
   assert.equal((await rows("select is_active from garage_vehicles where model='Civic'"))[0].is_active,false,'p_activate false keeps the current vehicle');
   await rpc('set_active_vehicle',[null]);assert.equal((await rows('select * from garage_vehicles where is_active')).length,0,'null turns the filter off');
   await rpc('set_active_vehicle',[v2]);assert.deepEqual((await rows('select model from garage_vehicles where is_active')).map(r=>r.model),['Myvi']);
   await assert.rejects(()=>rpc('add_garage_vehicle',['P','X',2020]),/check/,'make too short');
   await assert.rejects(()=>rpc('add_garage_vehicle',['Proton','X70',1800]),/check/,'year out of range');
   await assert.rejects(()=>rpc('set_active_vehicle',['50000000-0000-4000-8000-000000000099']),/not found/);
   await assert.rejects(()=>db.exec("update garage_vehicles set is_active=true"),/permission denied/);
   for(let i=0;i<5;i++)await rpc('add_garage_vehicle',['Make'+i,'Model',2000+i]);
   assert.equal((await rows('select * from garage_vehicles')).length,8);
   await assert.rejects(()=>rpc('add_garage_vehicle',['Toyota','Vios',2020]),/up to 8/);
   assert.equal((await rows('select * from garage_vehicles where is_active')).length,1,'never more than one active vehicle');
  });
  await as('other',async()=>{
   assert.equal((await rows('select * from garage_vehicles')).length,0);
   await assert.rejects(()=>rpc('remove_garage_vehicle',[v1]),/not found/);
   await assert.rejects(()=>rpc('set_active_vehicle',[v1]),/not found/);
  });
  for(const role of ['anon','worker','admin'])await as(role,async()=>assert.rejects(()=>rpc('add_garage_vehicle',['Proton','X50',2022]),/permission/));
  await as('customer',async()=>{await rpc('remove_garage_vehicle',[v1]);assert.equal((await rows('select * from garage_vehicles')).length,7);await assert.rejects(()=>rpc('remove_garage_vehicle',[v1]),/not found/);});

  // =============== Product questions ===============
  let q1;
  await as('customer',async()=>{
   q1=await rpc('ask_question',['p1','  Will this fit a 2019 Proton X50?  ']);
   const row=(await rows('select question,asker_name,answered_at from product_questions'))[0];
   assert.equal(row.question,'Will this fit a 2019 Proton X50?','text is trimmed');assert.equal(row.asker_name,'Amir R.','only a first name and initial are stored for display');assert.equal(row.answered_at,null);
   await assert.rejects(()=>rpc('ask_question',['p1','too short']),/10 to 500/);
   await assert.rejects(()=>rpc('ask_question',['p1','x'.repeat(501)]),/10 to 500/);
   await assert.rejects(()=>rpc('ask_question',['p1','          ']),/10 to 500/);
   await assert.rejects(()=>rpc('ask_question',['hidden','Is this product still sold?']),/unavailable/);
   await assert.rejects(()=>rpc('ask_question',['nope','Is this product real at all?']),/unavailable/);
   await rpc('ask_question',['p1','Does it come with a gasket included?']);
   await assert.rejects(()=>rpc('ask_question',['p1','A third waiting question here.']),/already have questions waiting/);
   await rpc('ask_question',['p2','Is this the genuine OEM part?']);await rpc('ask_question',['p3','What is the warranty period?']);await rpc('ask_question',['p3','Can I collect it from the shop?']);
   await assert.rejects(()=>rpc('ask_question',['p2','A sixth question within a day.']),/up to 5 questions a day/);
   await assert.rejects(()=>db.exec("insert into product_questions(product_id,asker_id,asker_name,question) values('p1',auth.uid(),'Amir R.','Direct insert is not allowed')"),/permission denied/);
  });
  await as('other',async()=>assert.equal((await rpc('ask_question',['p1','Is installation available nearby?'])).length>10,true));
  assert.equal((await rows("select asker_name from product_questions where asker_id='"+ids.other+"'"))[0].asker_name,'Siti','a single name has no initial');
  for(const role of ['anon','worker','admin'])await as(role,async()=>assert.rejects(()=>rpc('ask_question',['p1','Staff and visitors cannot ask here.']),/permission/));
  assert.ok((await rows("select * from notifications where title='New product question' and user_id in ('"+ids.worker+"','"+ids.admin+"')")).length>=2,'staff are told about a new question');

  // visibility before an answer
  await as('anon',async()=>assert.equal((await rows('select id,product_id,asker_name,question,answer,answered_at,created_at from product_questions')).length,0,'unanswered questions are private'));
  await as('other',async()=>assert.deepEqual((await rows('select asker_name from product_questions')).map(r=>r.asker_name),['Siti'],'a customer sees only their own'));
  await as('worker',async()=>assert.equal((await rows('select * from product_questions')).length,6,'staff see every question'));

  // answering
  await as('customer',async()=>assert.rejects(()=>rpc('answer_question',[q1,'I am not staff, but here is an answer.']),/permission/));
  await as('anon',async()=>assert.rejects(()=>rpc('answer_question',[q1,'Anonymous answer attempt here.']),/permission/));
  await as('worker',async()=>{
   await assert.rejects(()=>rpc('answer_question',[q1,'x']),/2 to 2000/);
   await assert.rejects(()=>rpc('answer_question',['50000000-0000-4000-8000-000000000099','Answer to nothing at all.']),/not found/);
   await rpc('answer_question',[q1,' Yes, it fits 2020 to 2024 Proton X50. ']);
  });
  assert.equal((await rows('select answer from product_questions where id=$1'.replace('$1',`'${q1}'`)))[0].answer,'Yes, it fits 2020 to 2024 Proton X50.');
  assert.equal((await rows("select * from notifications where user_id='"+ids.customer+"' and title='Your question was answered'")).length,1,'the asker is told once');
  await as('admin',()=>rpc('answer_question',[q1,'Yes, it fits 2020 to 2024 Proton X50 (updated).']));
  assert.equal((await rows("select * from notifications where user_id='"+ids.customer+"' and title='Your question was answered'")).length,1,'editing an answer does not notify again');
  assert.equal((await rows("select count(*)::int as n from audit_events where action='question_answered'"))[0].n,2);

  // visibility after an answer
  await as('anon',async()=>{
   const list=await rows('select id,product_id,asker_name,question,answer,answered_at,created_at from product_questions');
   assert.equal(list.length,1);assert.equal(list[0].asker_name,'Amir R.');assert.match(list[0].answer,/updated/);
   await assert.rejects(()=>db.query('select asker_id from product_questions'),/permission denied/,'who asked is never public');
   await assert.rejects(()=>db.query('select * from product_questions'),/permission denied/);
  });
  await as('other',async()=>assert.deepEqual((await rows('select asker_name from product_questions order by asker_name')).map(r=>r.asker_name),['Amir R.','Siti'],'answered questions are public to signed-in customers too'));

  // moderation
  await as('worker',async()=>assert.rejects(()=>rpc('moderate_question',[q1,false]),/permission/));
  await as('customer',async()=>assert.rejects(()=>rpc('moderate_question',[q1,false]),/permission/));
  await as('admin',async()=>{await assert.rejects(()=>rpc('moderate_question',['50000000-0000-4000-8000-000000000099',false]),/not found/);await rpc('moderate_question',[q1,false]);});
  await as('anon',async()=>assert.equal((await rows('select id,product_id,asker_name,question,answer,answered_at,created_at from product_questions')).length,0,'a hidden question disappears from the public'));
  await as('customer',async()=>assert.equal((await rows('select * from product_questions where id=$1'.replace('$1',`'${q1}'`))).length,1,'the asker still sees their own'));
  await as('admin',()=>rpc('moderate_question',[q1,true]));
  await as('anon',async()=>assert.equal((await rows('select id,product_id,asker_name,question,answer,answered_at,created_at from product_questions')).length,1));
  await db.exec("update products set active=false where id='p1'");
  await as('anon',async()=>assert.equal((await rows('select id,product_id,asker_name,question,answer,answered_at,created_at from product_questions')).length,0,'questions about an archived product are not public'));
  await db.exec("update products set active=true where id='p1'");

  // =============== Invoice details ===============
  const settings={store_name:'GearLane Auto Parts',bank_name:'Bank',bank_account_name:'GearLane',bank_account_number:'123456789',shipping_cents:500,free_shipping_cents:0,checkout_enabled:true,contact_email:'a@example.test',return_policy:'Policy text here.'};
  await as('admin',()=>rpc('admin_save_settings',[JSON.stringify({...settings,invoice_details:'  GearLane Sdn Bhd (Reg. 123456-X)\n1 Jalan Demo, 50000 Kuala Lumpur  '})]));
  for(const role of ['anon','customer']){await as(role,async()=>{const view=(await rows('select * from public_store_settings'))[0];assert.equal(view.invoice_details,'GearLane Sdn Bhd (Reg. 123456-X)\n1 Jalan Demo, 50000 Kuala Lumpur','invoice details are public business information');assert.equal(Object.keys(view).some(k=>k.startsWith('bank_')),false,'bank details stay hidden');});}
  await as('admin',()=>rpc('admin_save_settings',[JSON.stringify({...settings,store_name:'GearLane Auto Parts 2'})]));
  assert.match((await rows('select invoice_details from store_settings'))[0].invoice_details,/Reg\. 123456-X/,'a client that omits the field leaves it unchanged');
  await as('admin',()=>rpc('admin_save_settings',[JSON.stringify({...settings,invoice_details:''})]));
  assert.equal((await rows('select invoice_details from store_settings'))[0].invoice_details,'','an explicit empty value clears it');
  await as('admin',async()=>assert.rejects(()=>rpc('admin_save_settings',[JSON.stringify({...settings,invoice_details:'x'.repeat(1001)})]),/too long/));
  for(const role of ['customer','worker','anon'])await as(role,async()=>assert.rejects(()=>rpc('admin_save_settings',[JSON.stringify(settings)]),/permission/));
  assert.equal((await rows("select count(*)::int as n from audit_events where action='store_settings_updated'"))[0].n,3);
 }finally{await db.close();}
});
