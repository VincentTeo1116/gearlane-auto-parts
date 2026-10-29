import test from 'node:test';
import assert from 'node:assert/strict';
import {composeEmail,createHandler,esc} from '../api/order-email.js';

const ORDER='10000000-0000-4000-8000-0000000000aa';
const env={SUPABASE_URL:'https://x.supabase.co',SUPABASE_PUBLISHABLE_KEY:'public',SUPABASE_SERVICE_ROLE_KEY:'secret',SITE_URL:'https://store.example',RESEND_API_KEY:'re_key',EMAIL_FROM:'GearLane <orders@store.example>'};
const res=()=>({code:200,headers:{},body:undefined,setHeader(k,v){this.headers[k]=v;},status(n){this.code=n;return this;},json(b){this.body=b;return this;}});
const req=(extra={})=>({method:'POST',headers:{origin:'https://store.example',authorization:'Bearer valid.token'},body:{order_id:ORDER,event:'shipped'},...extra});
const baseOrder={id:ORDER,order_number:10077,customer_id:'cust',status:'shipped',payment_status:'verified',total_cents:13845,address:{name:'Amir <script>Rahman'},carrier:'J&T',tracking_number:'JT123'};

function world({order=baseOrder,user={id:'u'},claimError=null,profile={email:'amir@example.test',is_active:true},ok=true}={}){
  const state={claims:[],deleted:[],sent:[]};
  const client=(url,key)=>{
    if(key==='secret')return{from(table){return{
      insert:async row=>{state.claims.push(row);return{error:claimError};},
      delete:()=>({match:async m=>{state.deleted.push(m);return{};}}),
      select:()=>({eq:()=>({single:async()=>({data:table==='profiles'?profile:{store_name:'GearLane Auto Parts'}})})}),
    };}};
    return{auth:{getUser:async()=>({data:{user},error:user?null:{}})},from(){return{select:()=>({eq:()=>({maybeSingle:async()=>({data:order,error:null})})})};}};
  };
  const fetcher=async(url,options)=>{state.sent.push({url,options:{...options,body:JSON.parse(options.body)}});return{ok};};
  return{state,handler:createHandler({client,env,fetcher})};
}

test('a customer gets one email for a real milestone, sent only to the order owner',async()=>{
  const {state,handler}=world(),r=res();
  await handler(req(),r);
  assert.equal(r.code,200);assert.deepEqual(r.body,{sent:true});
  assert.equal(state.sent.length,1);assert.equal(state.sent[0].url,'https://api.resend.com/emails');
  assert.deepEqual(state.sent[0].options.body.to,['amir@example.test'],'recipient comes from the order, never the request');
  assert.match(state.sent[0].options.body.subject,/GL-10077 has shipped/);
  assert.match(state.sent[0].options.body.text,/JT123/);
  assert.equal(state.sent[0].options.headers.Authorization,'Bearer re_key');
  assert.deepEqual(state.claims,[{order_id:ORDER,event:'shipped'}]);
});
test('the same milestone is never emailed twice',async()=>{
  const {state,handler}=world({claimError:{code:'23505'}}),r=res();
  await handler(req(),r);
  assert.deepEqual(r.body,{sent:false,reason:'already_sent'});assert.equal(state.sent.length,0);
});
test('an event that has not happened is refused, even for a signed-in user who can see the order',async()=>{
  const {state,handler}=world({order:{...baseOrder,status:'processing'}}),r=res();
  await handler(req(),r);
  assert.equal(r.code,409);assert.equal(state.sent.length,0);assert.equal(state.claims.length,0);
});
test('callers who cannot read the order, or are not signed in, get nothing',async()=>{
  let {state,handler}=world({order:null}),r=res();
  await handler(req(),r);assert.equal(r.code,404);assert.equal(state.sent.length,0);
  ({state,handler}=world({user:null}));r=res();await handler(req(),r);assert.equal(r.code,401);
  ({handler}=world());r=res();await handler(req({headers:{origin:'https://store.example'}}),r);assert.equal(r.code,401);
  r=res();await handler(req({headers:{origin:'https://evil.example',authorization:'Bearer a.b'}}),r);assert.equal(r.code,403);
});
test('bad input, wrong method and missing configuration fail closed',async()=>{
  const {handler}=world();
  for(const body of [{order_id:'not-a-uuid',event:'shipped'},{order_id:ORDER,event:'refunded'},{order_id:ORDER,event:'shipped',to:'attacker@evil.test'},{}]){const r=res();await handler(req({body}),r);assert.equal(r.code,400,JSON.stringify(body));}
  let r=res();await handler(req({method:'GET'}),r);assert.equal(r.code,405);
  r=res();await handler(req({headers:{origin:'https://store.example',authorization:'Bearer a.b','content-length':'99999'}}),r);assert.equal(r.code,413);
  r=res();await createHandler({env:{...env,RESEND_API_KEY:''}})(req(),r);assert.equal(r.code,503);
});
test('a failed send releases the claim so the next attempt can retry, and no recipient sends nothing',async()=>{
  let {state,handler}=world({ok:false}),r=res();
  await handler(req(),r);assert.equal(r.code,502);assert.deepEqual(state.deleted,[{order_id:ORDER,event:'shipped'}]);
  ({state,handler}=world({profile:{email:'',is_active:true}}));r=res();await handler(req(),r);
  assert.deepEqual(r.body,{sent:false,reason:'no_recipient'});assert.equal(state.sent.length,0);assert.equal(state.deleted.length,1);
});
test('emails escape customer text and never include bank details',()=>{
  const mail=composeEmail('placed',{...baseOrder,status:'awaiting_payment',payment_instructions:{bank_account_number:'123456789'}},{storeName:'Store <b>',link:'https://store.example/orders/x"y'});
  assert.equal(mail.html.includes('<script>'),false);assert.equal(mail.html.includes('<b>'),false);assert.equal(mail.html.includes('x"y'),false);
  assert.equal(JSON.stringify(mail).includes('123456789'),false);assert.match(mail.text,/never ask for your banking password/);
  assert.equal(esc('<&">'),'&lt;&amp;&quot;&gt;');
  for(const event of ['placed','payment_verified','payment_rejected','shipped','delivered','cancelled'])assert.ok(composeEmail(event,baseOrder,{storeName:'S',link:'https://s/x'}).subject.includes('GL-10077'),event);
});
