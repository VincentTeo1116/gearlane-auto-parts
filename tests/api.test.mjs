import test from 'node:test';import assert from 'node:assert/strict';import {createHandler} from '../api/admin-users.js';
const env={SUPABASE_URL:'https://example.supabase.co',SUPABASE_PUBLISHABLE_KEY:'public',SUPABASE_SERVICE_ROLE_KEY:'secret',SITE_URL:'https://store.example'};
const request=extra=>({method:'POST',headers:{origin:'https://store.example',authorization:'Bearer valid.token'},body:{name:'Test Worker',email:'worker@example.com',role:'worker'},...extra});
const response=()=>({code:200,headers:{},setHeader(k,v){this.headers[k]=v;},status(n){this.code=n;return this;},json(body){this.body=body;return this;}});
function mock(role='admin',active=true,inviteResponse=null){let invited=0,assigned=0,inviteOptions=null;const client=(url,key)=>key==='secret'?{auth:{admin:{inviteUserByEmail:async(email,options)=>{invited++;inviteOptions=options;if(inviteResponse)return inviteResponse;return{data:{user:{id:'10000000-0000-4000-8000-000000000001'}}};},deleteUser:async()=>({})}}}:{auth:{getUser:async()=>({data:{user:{id:'10000000-0000-4000-8000-000000000003'}}})},from:()=>({select:()=>({eq:()=>({single:async()=>({data:{role,is_active:active}})})})}),rpc:async()=>{assigned++;return{};}};return{client,get invited(){return invited;},get assigned(){return assigned;},get inviteOptions(){return inviteOptions;}};}
test('admin API rejects missing token, foreign origin, worker and inactive admin',async()=>{for(const [role,active,extra,code]of [['admin',true,{headers:{origin:'https://store.example'}},401],['admin',true,{headers:{origin:'https://evil.example',authorization:'Bearer valid'}},403],['worker',true,{},403],['admin',false,{},403]]){const m=mock(role,active),res=response();await createHandler({client:m.client,env})(request(extra),res);assert.equal(res.code,code);assert.equal(m.invited,0);}});
test('admin invitation validates payload and returns no server secrets',async()=>{const m=mock(),handler=createHandler({client:m.client,env});let res=response();await handler(request({body:{name:'X',email:'invalid',role:'owner'}}),res);assert.equal(res.code,400);res=response();await handler(request(),res);assert.equal(res.code,201);assert.equal(m.invited,1);assert.equal(m.inviteOptions.redirectTo,'https://store.example/account?reset=1');assert.ok(!JSON.stringify(res.body).includes('secret'));});
test('admin cannot delete own account and missing server configuration fails closed',async()=>{const m=mock(),res=response();await createHandler({client:m.client,env})(request({method:'DELETE',body:{id:'10000000-0000-4000-8000-000000000003'}}),res);assert.equal(res.code,409);const empty=response();await createHandler({env:{}})(request(),empty);assert.equal(empty.code,503);});

test('invitation failures preserve rate-limit status and explain safe recovery without exposing provider details',async()=>{
 for(const [error,status,code,copy]of [
  [{status:429,code:'over_email_send_rate_limit'},429,'invitation_rate_limited',/quota.*SMTP/],
  [{status:429,code:'over_request_rate_limit'},429,'invitation_rate_limited',/rate-limited/],
  [{status:429},429,'invitation_rate_limited',/quota/],
  [{status:400,code:'email_exists'},409,'invitation_email_exists',/already exists/],
  [{status:400,message:'User already registered'},409,'invitation_email_exists',/already exists/],
  [{status:400,code:'email_address_not_authorized'},422,'invitation_recipient_restricted',/SMTP/],
  [{status:400,code:'email_address_invalid'},422,'invitation_invalid_email',/email address/],
  [{status:400,code:'email_provider_disabled'},503,'invitation_email_disabled',/disabled/],
  [{status:401,code:'bad_jwt'},503,'invitation_server_config',/server invitation credentials/],
  [{status:500},502,'invitation_delivery_failed',/SMTP/],
  [{status:400,code:'unknown_provider_error'},400,'invitation_rejected',/Authentication logs/]
 ]){
  const m=mock('admin',true,{data:null,error:{message:'Sensitive provider details including secret-value',...error}}),res=response();
  await createHandler({client:m.client,env})(request(),res);
  assert.equal(res.code,status);assert.equal(res.body.code,code);assert.match(res.body.error,copy);
  assert.equal(m.invited,1);assert.equal(m.assigned,0);assert.ok(!JSON.stringify(res.body).includes('secret-value'));
 }
});
