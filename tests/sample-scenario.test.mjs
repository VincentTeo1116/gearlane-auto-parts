import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {addSampleScenario} from '../src/sample-scenario.mjs';
import {previewAnalytics} from '../src/preview-analytics.mjs';
const now=Date.parse('2026-10-28T10:00:00Z');
const catalogue=JSON.parse(readFileSync(new URL('../data/catalogue.json',import.meta.url)));
const base=()=>({users:[{id:'admin',role:'admin',is_active:true},{id:'worker',role:'worker',is_active:true}],products:catalogue.map((p,i)=>({...p,stock:i>52?0:i>47?5:160,price_cents:Math.round(p.price*100),price_confirmed:true,active:true})),settings:{shipping_cents:1500,free_shipping_cents:25000,bank_name:'DEMO',bank_account_name:'DO NOT TRANSFER',bank_account_number:'0000000000'},orders:[],refunds:[],reviews:[],wishlist:[],activity:[]});

test('sample orders reconcile prices, delivery charges, refunds and reserved stock',()=>{
 const state=addSampleScenario(base(),{now});
 assert.equal(state.orders.length,84);assert.equal(state.sample_summary.customers,12);
 for(const order of state.orders){
  assert.equal(order.subtotal_cents,order.items.reduce((s,i)=>s+i.quantity*i.price_cents,0));
  assert.equal(order.total_cents,order.subtotal_cents-order.discount_cents+order.shipping_cents);
  assert.equal(order.shipping_cents,order.subtotal_cents>=25000?0:1500);
  assert.equal(new Set(order.items.map(i=>i.product_id)).size,order.items.length);
 }
 for(const product of state.products){
  const balance=state.sample_inventory.find(i=>i.product_id===product.id);
  const reserved=state.orders.flatMap(o=>o.items).filter(i=>i.product_id===product.id).reduce((s,i)=>s+i.quantity,0);
  const restored=state.orders.filter(o=>o.status==='cancelled').flatMap(o=>o.items).filter(i=>i.product_id===product.id).reduce((s,i)=>s+i.quantity,0);
  assert.equal(balance.opening_units-reserved+restored,product.stock);
  assert.ok(Number.isInteger(product.stock)&&product.stock>=0);
 }
 assert.ok(state.products.some(p=>p.stock===0));assert.ok(state.products.some(p=>p.stock>0&&p.stock<10));
 for(const refund of state.refunds){const order=state.orders.find(o=>o.id===refund.order_id);assert.equal(refund.amount_cents,order.total_cents);assert.equal(order.payment_status,refund.status==='paid'?'refunded':'verified');}
});

test('sample histories have valid chronology and reviews only follow confirmed receipt',()=>{
 const state=addSampleScenario(base(),{now});
 for(const order of state.orders){
  const created=Date.parse(order.created_at);
  assert.ok(created<=now);assert.ok(state.users.some(u=>u.id===order.customer_id&&Date.parse(u.created_at)<=created));
  for(const event of order.events)assert.ok(Date.parse(event.created_at)>=created&&Date.parse(event.created_at)<=now);
  if(order.status==='awaiting_payment')assert.ok(Date.parse(order.expires_at)>now,'Pending example reservations are still valid');
 }
 for(const review of state.reviews){const order=state.orders.find(o=>o.id===review.order_id);assert.equal(order.payment_status,'verified');assert.ok(order.received_at);assert.ok(Date.parse(review.created_at)>=Date.parse(order.received_at));assert.ok(order.items.some(i=>i.product_id===review.product_id));}
 assert.ok(state.activity.every(e=>Date.parse(e.created_at)<=now));
});

test('sample reports use the underlying orders, exclude unpaid/refunded revenue and respect report periods',()=>{
 const state=addSampleScenario(base(),{now}),short=previewAnalytics(state,7,now),month=previewAnalytics(state,30,now),all=previewAnalytics(state,90,now);
 assert.ok(short.paid_orders<month.paid_orders&&month.paid_orders<all.paid_orders);
 const paid=state.orders.filter(o=>o.payment_status==='verified');
 assert.equal(all.paid_sales_cents,paid.reduce((s,o)=>s+o.total_cents,0));
 assert.equal(all.daily_sales.reduce((s,d)=>s+d.value,0),all.paid_sales_cents);
 assert.equal(all.categories.reduce((s,c)=>s+c.value,0),paid.reduce((s,o)=>s+o.subtotal_cents,0));
 assert.equal(all.customer_types.reduce((s,c)=>s+Number(c.count),0),12);
 assert.equal(all.active_customers,12);assert.equal(all.active_hours.reduce((s,h)=>s+h.count,0),84*4);
 assert.ok(all.wishlist_categories.length>=3);
 const utc=state.activity[0].created_at;assert.ok(all.active_hours.some(h=>h.hour===(new Date(utc).getUTCHours()+8)%24));
});

test('adding sample reports is idempotent and preserves existing preview records',()=>{
 const input=base();input.orders=[{id:'existing-order',order_number:10001,created_at:new Date(now).toISOString(),items:[]}];
 const state=addSampleScenario(input,{now});
 assert.equal(input.orders.length,1);assert.ok(state.orders.some(o=>o.id==='existing-order'));
 assert.equal(addSampleScenario(state,{now}),state);assert.equal(state.orders.length,85);
});
