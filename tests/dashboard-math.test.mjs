import test from 'node:test';
import assert from 'node:assert/strict';
import {deltaInfo,deltaLabel} from '../src/dashboard-math.mjs';
import {previewPreviousPeriod} from '../src/preview-analytics.mjs';

test('period comparison handles growth, decline, no change and an empty previous period',()=>{
  assert.deepEqual(deltaInfo(150,100),{kind:'change',pct:50,dir:'up'});
  assert.deepEqual(deltaInfo(75,100),{kind:'change',pct:-25,dir:'down'});
  assert.deepEqual(deltaInfo(100,100),{kind:'same',pct:0,dir:'flat'});
  assert.deepEqual(deltaInfo(10,0),{kind:'new',pct:null,dir:'up'});
  assert.equal(deltaInfo(0,0),null,'nothing to compare');
  assert.equal(deltaInfo(undefined,5),null);assert.equal(deltaInfo(-1,5),null);assert.equal(deltaInfo('x',5),null);
});
test('labels are plain words and never show NaN or Infinity',()=>{
  assert.equal(deltaLabel(deltaInfo(150,100),30),'▲ 50% vs previous 30 days');
  assert.equal(deltaLabel(deltaInfo(912,1000),7),'▼ 8.8% vs previous 7 days');
  assert.equal(deltaLabel(deltaInfo(1000,100),30),'▲ 900% vs previous 30 days');
  assert.match(deltaLabel(deltaInfo(5,0),30),/^New/);
  assert.equal(deltaLabel(null,30),'');
});
test('previous period covers exactly the window before the selected one',()=>{
  const now=Date.parse('2026-10-31T00:00:00Z'),day=864e5,order=(daysAgo,total,payment='verified')=>({created_at:new Date(now-daysAgo*day).toISOString(),total_cents:total,payment_status:payment});
  const state={orders:[order(1,1000),order(29,2000),order(31,4000),order(45,8000),order(59,16000),order(61,32000),order(40,999,'submitted')],activity:[{user_id:'a',created_at:new Date(now-40*day).toISOString()},{user_id:'a',created_at:new Date(now-41*day).toISOString()},{user_id:'b',created_at:new Date(now-5*day).toISOString()}]};
  const previous=previewPreviousPeriod(state,30,now);
  assert.equal(previous.paid_sales_cents,4000+8000+16000,'days 31-60 only, verified only');
  assert.equal(previous.paid_orders,3);assert.equal(previous.active_customers,1);
});
