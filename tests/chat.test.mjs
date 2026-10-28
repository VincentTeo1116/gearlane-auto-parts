import test from 'node:test';
import assert from 'node:assert/strict';
import {CHAT_SYNC_MS, createChatSync, mergeMessages} from '../src/chat.mjs';
import {messageSchema, validate} from '../src/domain.mjs';

test('chat validates meaningful text, size, controls and product identifiers',()=>{
  for(const body of ['','  ','\n\t','\u200B\u200C','\uFEFF','x'.repeat(2001),'hello\u0001world'])assert.throws(()=>validate(messageSchema,{body}));
  assert.throws(()=>validate(messageSchema,{body:'A valid question',product_id:'invalid/product'}));
  assert.equal(validate(messageSchema,{body:'  你好! Is 5W-30 suitable?\nMy model is 2020.  ',product_id:'GL-0001'}).body,'你好! Is 5W-30 suitable?\nMy model is 2020.');
  assert.equal(validate(messageSchema,{body:'Part <test> & specification'}).body,'Part <test> & specification','Plain text is preserved; React escapes rendering');
});

test('message sync preserves older history and deduplicates updated rows',()=>{
  const old={id:'a',created_at:'2026-10-28T01:00:00Z',body:'Older history'},recent={id:'b',created_at:'2026-10-28T02:00:00Z',body:'Recent'};
  const result=mergeMessages([old,recent],[{...recent,body:'Authoritative recent'}, {id:'c',created_at:'2026-10-28T03:00:00Z',body:'New'}]);
  assert.deepEqual(result.map(x=>x.id),['a','b','c']);assert.equal(result[1].body,'Authoritative recent');
});

test('five-second sync coalesces overlapping requests and stops callbacks after cleanup',async()=>{
  let tick,cancelled=false,resolve,calls=0;const received=[];
  const controller=createChatSync(()=>{calls++;return new Promise(r=>resolve=r);},{schedule(fn,ms){tick=fn;assert.equal(ms,CHAT_SYNC_MS);assert.equal(ms,5000);return 17;},cancel(id){assert.equal(id,17);cancelled=true;},onSuccess:value=>received.push(value)});
  const one=controller.sync(),two=controller.sync();assert.equal(one,two);await Promise.resolve();assert.equal(calls,1);tick();assert.equal(calls,1);
  resolve('first');await one;assert.deepEqual(received,['first']);
  const late=controller.sync();await Promise.resolve();assert.equal(calls,2);controller.stop();resolve('late');await late;assert.equal(cancelled,true);assert.deepEqual(received,['first']);await controller.sync();assert.equal(calls,2);
});

test('a failed sync can recover on the next scheduled attempt',async()=>{
  let tick,fail=true,errors=0,values=0;
  const controller=createChatSync(async()=>{if(fail)throw new Error('Offline');return 'reconnected';},{schedule(fn){tick=fn;return 1;},cancel(){},onError(){errors++;},onSuccess(){values++;}});
  await controller.sync();assert.equal(errors,1);fail=false;tick();await controller.sync();assert.equal(values,1);controller.stop();
});
