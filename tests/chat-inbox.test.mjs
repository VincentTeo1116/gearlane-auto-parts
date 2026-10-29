import test from 'node:test';
import assert from 'node:assert/strict';
import {PGlite} from '@electric-sql/pglite';
import {readFile} from 'node:fs/promises';
import {enquiryTitleSchema,filterConversations,inboxDate,previewInbox} from '../src/chat-inbox.mjs';

test('inbox filters search topic/message and order by activity, with Malaysia dates and validated topics',()=>{
 const rows=[{id:'older',title:'Brake pad fitment',created_at:'2026-10-01T00:00:00Z',closed_at:null,last_message:{body:'Saga year 2020',created_at:'2026-10-29T01:00:00Z'}},{id:'newer',title:'Oil order',created_at:'2026-10-28T00:00:00Z',closed_at:'2026-10-28T02:00:00Z'}];
 assert.equal(filterConversations(rows)[0].id,'older');assert.equal(filterConversations(rows,{query:'saga'})[0].id,'older');assert.equal(filterConversations(rows,{status:'closed'})[0].id,'newer');assert.equal(filterConversations(rows,{query:'absent'}).length,0);
 assert.equal(enquiryTitleSchema.safeParse('  Brake pad fitment  ').data,'Brake pad fitment');
 for(const invalid of ['  ','ab','x'.repeat(121),'Invalid\u0001topic'])assert.equal(enquiryTitleSchema.safeParse(invalid).success,false);
 assert.equal(inboxDate('2026-10-27T18:00:00Z',Date.parse('2026-10-28T18:00:00Z')),'Yesterday');
});

test('preview inbox only previews accessible chats and counts incoming unread messages',()=>{
 const state={conversations:[{id:'own',created_at:'2026-10-01',members:[{user_id:'me',last_read_at:'2026-10-02'}]},{id:'private',created_at:'2026-10-01',members:[]}],messages:[{id:'a',conversation_id:'own',sender_id:'seller',body:'Old reply',created_at:'2026-10-01'},{id:'b',conversation_id:'own',sender_id:'seller',body:'New reply',created_at:'2026-10-03'},{id:'c',conversation_id:'own',sender_id:'me',body:'My message',created_at:'2026-10-04'},{id:'d',conversation_id:'private',sender_id:'seller',body:'Private staff message',created_at:'2026-10-05'}]};
 const rows=previewInbox(state,{id:'me'},c=>c.id==='own');assert.equal(rows.length,1);assert.equal(rows[0].unread_count,1);assert.equal(rows[0].last_message.body,'My message');
});

test('chat inbox SQL isolates customers/private staff chats and creates named enquiries with rate limits and duplicate-safe retries',async()=>{
 const db=await PGlite.create(),ids={customer:'10000000-0000-4000-8000-000000000001',other:'10000000-0000-4000-8000-000000000002',worker:'10000000-0000-4000-8000-000000000003',admin:'10000000-0000-4000-8000-000000000004'};
 const as=async(role,fn)=>{await db.exec('reset role');await db.query("select set_config('request.jwt.claim.sub',$1,false)",[ids[role]]);await db.exec('set role authenticated');try{return await fn();}finally{await db.exec('reset role');}};
 const rpc=async(name,args=[])=>{return(await db.query(`select public.${name}(${args.map((_,i)=>'$'+(i+1)).join(',')}) result`,args)).rows[0].result;};
 try{
  await db.exec("create role anon;create role authenticated;create schema auth;create schema storage;create table auth.users(id uuid primary key,email text,raw_user_meta_data jsonb default '{}');create table storage.objects(bucket_id text,name text);create function auth.uid() returns uuid language sql stable as $$select nullif(current_setting('request.jwt.claim.sub',true),'')::uuid$$;grant usage on schema public,auth to anon,authenticated;grant execute on function auth.uid() to anon,authenticated;");
  for(const name of ['001-schema.sql','002-commerce.sql','003-workspace.sql','007-chat-delivery.sql','009-chat-inbox.sql'])await db.exec(await readFile(new URL('../supabase/'+name,import.meta.url),'utf8'));
  for(const [role,id]of Object.entries(ids))await db.query('insert into auth.users(id,email,raw_user_meta_data) values($1,$2,$3)',[id,role+'@example.test',JSON.stringify({full_name:role})]);
  await db.query("update profiles set role='worker' where id=$1",[ids.worker]);await db.query("update profiles set role='admin' where id=$1",[ids.admin]);
  const a='40000000-0000-4000-8000-000000000001',b='40000000-0000-4000-8000-000000000002';let legacy,internal;
  await as('customer',async()=>{legacy=await rpc('start_conversation',['support',null]);assert.equal(await rpc('start_support_enquiry',['Brake pad fitment',a]),a);assert.equal(await rpc('start_support_enquiry',['Oil order tracking',b]),b);assert.equal(await rpc('start_support_enquiry',['Oil order tracking',b]),b);await assert.rejects(()=>rpc('start_support_enquiry',['Another new topic',crypto.randomUUID()]),/Too many/);await assert.rejects(()=>rpc('start_support_enquiry',['Changed topic',b]),/unavailable/);for(const invalid of ['ab','x'.repeat(121),'Invalid\u0001topic'])await assert.rejects(()=>rpc('start_support_enquiry',[invalid,crypto.randomUUID()]),/topic/);assert.equal(await rpc('start_conversation',['support',null]),b);await rpc('send_chat_message',[a,'Can these fit my 2020 Saga?',null,crypto.randomUUID()]);});
  await as('worker',async()=>{await assert.rejects(()=>rpc('start_support_enquiry',['Forbidden staff enquiry',crypto.randomUUID()]),/permission/);await rpc('send_chat_message',[a,'Please confirm the engine code.',null,crypto.randomUUID()]);internal=await rpc('start_conversation',['internal',ids.admin]);await rpc('send_chat_message',[internal,'Private stock discussion.',null,crypto.randomUUID()]);});
  await as('other',async()=>{await rpc('start_support_enquiry',['Other buyer question',crypto.randomUUID()]);await assert.rejects(()=>rpc('start_support_enquiry',['Brake pad fitment',a]),/unavailable/);assert.equal((await rpc('chat_inbox')).length,1);});
  await as('customer',async()=>{const inbox=await rpc('chat_inbox');assert.equal(inbox.length,3);assert.equal(inbox[0].id,a);assert.equal(inbox[0].last_message.body,'Please confirm the engine code.');assert.equal(Number(inbox[0].unread_count),1);assert.ok(inbox.every(c=>c.id!==internal));await rpc('manage_conversation',[a,'read']);assert.equal(Number((await rpc('chat_inbox')).find(c=>c.id===a).unread_count),0);});
  await as('worker',async()=>{await rpc('manage_conversation',[a,'close']);});
  await as('customer',async()=>{const inbox=await rpc('chat_inbox');assert.ok(inbox.find(c=>c.id===a).closed_at);await assert.rejects(()=>rpc('send_chat_message',[a,'Cannot send here.',null,crypto.randomUUID()]),/closed/);});
  await db.exec('set role anon');await assert.rejects(()=>rpc('chat_inbox'),/permission denied/);await db.exec('reset role');
  const migration=await readFile(new URL('../supabase/009-chat-inbox.sql',import.meta.url),'utf8');await db.exec(migration);
  assert.equal((await db.query('select count(*)::int n from conversations')).rows[0].n,5,'Migration rerun preserves existing chats');
 }finally{await db.close();}
});
