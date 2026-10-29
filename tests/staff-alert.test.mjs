import test from 'node:test';
import assert from 'node:assert/strict';
import {composeAlert,createHandler,esc,FRESH_MS,THROTTLE_MS} from '../api/staff-alert.js';

const CONVERSATION='10000000-0000-4000-8000-0000000000bb';
const NOW=Date.parse('2026-10-31T10:00:00Z');
const env={SUPABASE_URL:'https://x.supabase.co',SUPABASE_PUBLISHABLE_KEY:'public',SUPABASE_SERVICE_ROLE_KEY:'secret',SITE_URL:'https://store.example',RESEND_API_KEY:'re_key',EMAIL_FROM:'GearLane <onboarding@resend.dev>',STAFF_ALERT_EMAIL:'owner@example.test'};
const res=()=>({code:200,headers:{},body:undefined,setHeader(k,v){this.headers[k]=v;},status(n){this.code=n;return this;},json(b){this.body=b;return this;}});
const req=(extra={})=>({method:'POST',headers:{origin:'https://store.example',authorization:'Bearer valid.token'},body:{conversation_id:CONVERSATION},...extra});

function world({user={id:'cust'},conversation={id:CONVERSATION,kind:'support',customer_id:'cust',title:'Brake pads'},message,insertError=null,updatedRows=[{conversation_id:CONVERSATION}],ok=true,product={name:'Front Brake Pads'}}={}){
  const msg=message===undefined?{id:'m1',body:'Do these fit my Proton X50?',sender_id:'cust',sender_name:'Amir Rahman',product_id:'brake1',created_at:new Date(NOW-30000).toISOString()}:message;
  const state={inserts:[],updates:[],deletes:[],sent:[]};
  const caller={auth:{getUser:async()=>({data:{user},error:user?null:{}})},from(table){
    const rows={conversations:conversation,messages:msg,products:product}[table];
    const chain={eq:()=>chain,order:()=>chain,limit:()=>chain,maybeSingle:async()=>({data:rows,error:null})};
    return{select:()=>chain};
  }};
  const service={from(table){
    if(table==='staff_alerts')return{
      insert:async row=>{state.inserts.push(row);return{error:insertError};},
      update:row=>{state.updates.push(row);const chain={eq:()=>chain,lt:()=>chain,select:async()=>({data:updatedRows,error:null}),then:undefined};chain.eq=()=>chain;return chain;},
      delete:()=>({eq:async()=>{state.deletes.push(true);return{};}}),
    };
    return{select:()=>({eq:()=>({single:async()=>({data:{store_name:'GearLane Auto Parts'}})})})};
  }};
  const client=(url,key)=>key==='secret'?service:caller;
  const fetcher=async(url,options)=>{state.sent.push({url,body:JSON.parse(options.body),headers:options.headers});return{ok};};
  return{state,handler:createHandler({client,env,fetcher,now:()=>NOW})};
}

test('a customer message emails the store owner, with the text read from the database',async()=>{
  const {state,handler}=world(),r=res();
  await handler(req(),r);
  assert.deepEqual(r.body,{sent:true});assert.equal(state.sent.length,1);
  assert.deepEqual(state.sent[0].body.to,['owner@example.test'],'recipient is the configured owner, never from the request');
  assert.equal(state.sent[0].body.from,'GearLane <onboarding@resend.dev>');
  assert.equal(state.sent[0].body.subject,'New message from Amir Rahman');
  assert.match(state.sent[0].body.text,/Do these fit my Proton X50\?/);assert.match(state.sent[0].body.text,/Front Brake Pads/);
  assert.match(state.sent[0].body.text,/https:\/\/store\.example\/workspace\/messages\?conversation=10000000/);
  assert.match(state.sent[0].body.text,/does not reach the customer/);
  assert.equal(state.inserts.length,1);
});
test('quick follow-up messages do not send a second email within five minutes',async()=>{
  const {state,handler}=world({insertError:{code:'23505'},updatedRows:[]}),r=res();
  await handler(req(),r);
  assert.deepEqual(r.body,{sent:false,reason:'throttled'});assert.equal(state.sent.length,0);
  assert.equal(THROTTLE_MS,300000);
});
test('after the quiet period the next message is emailed again',async()=>{
  const {state,handler}=world({insertError:{code:'23505'},updatedRows:[{conversation_id:CONVERSATION}]}),r=res();
  await handler(req(),r);
  assert.deepEqual(r.body,{sent:true});assert.equal(state.sent.length,1);assert.equal(state.updates.length,1);
});
test('only the customer of a support conversation, with a fresh message of their own, can trigger an email',async()=>{
  const cases=[
    [{conversation:{id:CONVERSATION,kind:'support',customer_id:'someone-else'}},'not_a_customer_message'],
    [{conversation:{id:CONVERSATION,kind:'internal',customer_id:'cust'}},'not_a_customer_message'],
    [{message:{id:'m',body:'Staff reply',sender_id:'staff-user',sender_name:'Sarah',created_at:new Date(NOW-1000).toISOString()}},'no_recent_message'],
    [{message:{id:'m',body:'Old message',sender_id:'cust',sender_name:'Amir',created_at:new Date(NOW-FRESH_MS-1000).toISOString()}},'no_recent_message'],
    [{message:null},'no_recent_message'],
  ];
  for(const [options,reason] of cases){const {state,handler}=world(options),r=res();await handler(req(),r);assert.deepEqual(r.body,{sent:false,reason},JSON.stringify(options));assert.equal(state.sent.length,0);assert.equal(state.inserts.length,0);}
});
test('unknown conversations, signed-out callers, wrong origin, bad input and missing setup get nothing',async()=>{
  let {handler}=world({conversation:null}),r=res();await handler(req(),r);assert.equal(r.code,404);
  ({handler}=world({user:null}));r=res();await handler(req(),r);assert.equal(r.code,401);
  ({handler}=world());
  r=res();await handler(req({headers:{origin:'https://store.example'}}),r);assert.equal(r.code,401);
  r=res();await handler(req({headers:{origin:'https://evil.example',authorization:'Bearer a.b'}}),r);assert.equal(r.code,403);
  for(const body of [{conversation_id:'nope'},{conversation_id:CONVERSATION,to:'attacker@evil.test'},{conversation_id:CONVERSATION,body:'free text'},{}]){r=res();await handler(req({body}),r);assert.equal(r.code,400,JSON.stringify(body));}
  r=res();await handler(req({method:'GET'}),r);assert.equal(r.code,405);
  r=res();await handler(req({headers:{origin:'https://store.example',authorization:'Bearer a.b','content-length':'9999'}}),r);assert.equal(r.code,413);
  r=res();await createHandler({env:{...env,STAFF_ALERT_EMAIL:''}})(req(),r);assert.equal(r.code,503,'no owner address configured');
});
test('a failed send releases the slot so the next message can try again',async()=>{
  let {state,handler}=world({ok:false}),r=res();
  await handler(req(),r);assert.equal(r.code,502);assert.equal(state.deletes.length,1,'a new slot is removed');
  ({state,handler}=world({ok:false,insertError:{code:'23505'}}));r=res();await handler(req(),r);
  assert.equal(r.code,502);assert.equal(state.updates.length,2,'an updated slot is made old again');
});
test('alert emails escape customer text',()=>{
  const mail=composeAlert({customerName:'Eve <script>alert(1)</script>',message:'<img src=x onerror=alert(1)> '+'long '.repeat(200),productName:'Pads "X" & Y',link:'https://store.example/workspace/messages?conversation=a"b',storeName:'Store <b>'});
  assert.equal(mail.html.includes('<script>'),false);assert.equal(mail.html.includes('<img'),false);assert.equal(mail.html.includes('a"b'),false);assert.equal(mail.html.includes('Store <b>'),false,'the store name is escaped');assert.equal(mail.html.includes('Pads "X"'),false,'quotes in the product name are escaped');
  assert.ok(mail.text.length<900,'long messages are shortened');assert.equal(esc('<&">'),'&lt;&amp;&quot;&gt;');
});
