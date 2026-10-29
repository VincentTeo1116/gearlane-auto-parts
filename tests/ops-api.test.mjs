import test from 'node:test';
import assert from 'node:assert/strict';
import {createHandler as health} from '../api/health.js';
import {allow,createHandler as clientError} from '../api/client-error.js';

const response=()=>({code:200,headers:{},body:undefined,ended:false,setHeader(k,v){this.headers[k]=v;},status(n){this.code=n;return this;},json(b){this.body=b;return this;},end(){this.ended=true;return this;}});
const env={SUPABASE_URL:'https://example.supabase.co',SUPABASE_PUBLISHABLE_KEY:'public',SITE_URL:'https://store.example'};
const supabaseReturning=result=>()=>({from(){return{select(){return{eq(){return{single:async()=>result};}};}};}});

test('health reports ok only when the database answers, and never leaks details',async()=>{
  let res=response();
  await health({client:supabaseReturning({data:{id:1},error:null}),env})({method:'GET',headers:{}},res);
  assert.equal(res.code,200);assert.equal(res.body.status,'ok');assert.equal(res.headers['Cache-Control'],'no-store');
  res=response();
  await health({client:supabaseReturning({data:null,error:{message:'secret internal detail'}}),env})({method:'GET',headers:{}},res);
  assert.equal(res.code,503);assert.equal(JSON.stringify(res.body).includes('secret'),false);
  res=response();
  await health({client:()=>{throw new Error('boom');},env})({method:'GET',headers:{}},res);
  assert.equal(res.code,503);
  res=response();
  await health({client:supabaseReturning({data:{id:1}}),env:{}})({method:'GET',headers:{}},res);
  assert.equal(res.code,503);assert.equal(res.body.status,'unconfigured');
  res=response();
  await health({client:supabaseReturning({data:{id:1}}),env})({method:'POST',headers:{}},res);
  assert.equal(res.code,405);
});

test('client error log accepts same-origin reports, sanitises them and refuses everything else',async()=>{
  const logged=[];
  const call=async(req,extraEnv=env)=>{const r=response();await clientError({env:extraEnv,log:e=>logged.push(e),now:()=>1e12})(req,r);return r;};
  const good={method:'POST',headers:{origin:'https://store.example','x-forwarded-for':'203.0.113.1'},body:{message:'Boom'+String.fromCharCode(0)+String.fromCharCode(10)+'line',stack:'x'.repeat(5000),route:'/shop',evil:'<script>',kind:'error'}};
  const ok=await call(good);
  assert.equal(ok.code,204);assert.equal(logged.length,1);
  assert.equal(logged[0].message,'Boom  line');assert.equal(logged[0].stack.length,1500);assert.equal('evil' in logged[0],false,'unknown fields are dropped');
  assert.equal((await call({method:'GET',headers:{}})).code,405);
  assert.equal((await call({method:'POST',headers:{origin:'https://evil.example'},body:{message:'x'}})).code,403);
  assert.equal((await call({method:'POST',headers:{origin:'https://store.example','content-length':'99999'},body:{message:'x'}})).code,413);
  assert.equal((await call({method:'POST',headers:{origin:'https://store.example'},body:'{not json'})).code,400);
  assert.equal((await call({method:'POST',headers:{origin:'https://store.example'},body:{kind:'error'}})).code,400,'a report needs a message');
  assert.equal((await call({method:'POST',headers:{origin:'https://store.example'},body:{message:'x'}},{})).code,503);
  assert.equal(logged.length,1,'rejected requests are never logged');
});

test('client error log rate limits one address without blocking others',()=>{
  const t=2e12;
  for(let i=0;i<20;i++)assert.equal(allow('198.51.100.7',t),true);
  assert.equal(allow('198.51.100.7',t),false,'21st report in a minute is refused');
  assert.equal(allow('198.51.100.8',t),true,'other addresses are unaffected');
  assert.equal(allow('198.51.100.7',t+61000),true,'the window expires');
});
