import test from 'node:test';
import assert from 'node:assert/strict';
import {actionGroups,buyAgain,carrierSearchUrl,customerTab,deliveryProgress,formatWaiting,orderQueue,parsePrice,trackerSteps,urgencyFor,withinPrice} from '../src/order-logic.mjs';
import {clearRecent,pushRecent,readRecent} from '../src/recent.mjs';

const NOW=Date.parse('2026-10-31T12:00:00Z'),ago=h=>new Date(NOW-h*36e5).toISOString();
const order=(extra={})=>({id:'o'+Math.random(),status:'awaiting_payment',payment_status:'awaiting',created_at:ago(2),events:[],items:[],...extra});
const states=o=>trackerSteps(o).steps.map(s=>s.key+':'+s.state).join(' ');

test('tracker shows exactly where the order is at every stage',()=>{
  assert.equal(states(order()),'placed:done payment:current packing:todo shipped:todo received:todo');
  assert.equal(trackerSteps(order({payment_status:'submitted'})).steps[1].detail,'We are checking your transfer');
  assert.equal(trackerSteps(order({payment_status:'rejected'})).steps[1].detail,'Your transfer details need attention');
  assert.equal(states(order({status:'processing',payment_status:'verified'})),'placed:done payment:done packing:current shipped:todo received:todo');
  assert.equal(states(order({status:'shipped',payment_status:'verified'})),'placed:done payment:done packing:done shipped:done received:current');
  assert.equal(states(order({status:'delivered',payment_status:'verified'})),'placed:done payment:done packing:done shipped:done received:current');
  const received=trackerSteps(order({status:'delivered',payment_status:'verified',received_at:ago(1)}));
  assert.equal(received.steps.every(s=>s.state==='done'),true);assert.equal(received.current,'received');
  assert.equal(states(order({status:'delivered',payment_status:'refunded',received_at:ago(1)})),'placed:done payment:done packing:done shipped:done received:done');
});
test('tracker takes dates from real events and never invents one',()=>{
  const t=trackerSteps(order({status:'shipped',payment_status:'verified',events:[{event:'payment_verified',created_at:ago(30)},{event:'shipped',created_at:ago(5)},{event:'shipped',created_at:ago(9)}]}));
  assert.equal(t.steps[0].date,ago(2));assert.equal(t.steps[1].date,ago(30));assert.equal(t.steps[3].date,ago(5),'the latest event wins');assert.equal(t.steps[2].date,null);assert.equal(t.steps[4].date,null);
  assert.equal(trackerSteps(order({status:'processing',payment_status:'verified'})).steps[1].date,null,'no event, no date');
});
test('a cancelled order stops the tracker and keeps the reason',()=>{
  const t=trackerSteps(order({status:'cancelled',cancel_reason:'Changed my mind',events:[{event:'cancelled',created_at:ago(1)}]}));
  assert.equal(t.cancelled,true);assert.equal(t.reason,'Changed my mind');assert.equal(t.cancelledAt,ago(1));
  assert.deepEqual(t.steps.map(s=>s.state),['done','todo','todo','todo','todo']);assert.equal(t.current,null);
});
test('carrier link is a plain web search, never a guessed carrier URL',()=>{
  assert.equal(carrierSearchUrl('J&T Express','JT 123'),'https://www.google.com/search?q=J%26T%20Express%20tracking%20JT%20123');
  assert.equal(carrierSearchUrl('DHL',''),null);assert.equal(carrierSearchUrl('','ABC1')?.includes('tracking%20ABC1'),true);
});
test('customer tabs put every order in exactly one place',()=>{
  const cases=[[order(),'pay'],[order({payment_status:'rejected'}),'pay'],[order({payment_status:'submitted'}),'verify'],[order({status:'processing',payment_status:'verified'}),'ship'],[order({status:'shipped',payment_status:'verified'}),'receive'],[order({status:'delivered',payment_status:'verified'}),'receive'],[order({status:'delivered',payment_status:'verified',received_at:ago(1)}),'done'],[order({status:'cancelled'}),'cancelled'],[order({status:'delivered',payment_status:'refunded',received_at:ago(1)}),'cancelled']];
  for(const [o,tab] of cases)assert.equal(customerTab(o),tab,JSON.stringify([o.status,o.payment_status]));
});
test('staff queue is most urgent first, then oldest first, and ignores finished work',()=>{
  const orders=[
    order({id:'new-pay',payment_status:'submitted',created_at:ago(1)}),
    order({id:'old-pay',payment_status:'submitted',created_at:ago(30)}),
    order({id:'ship-old',status:'processing',payment_status:'verified',created_at:ago(60)}),
    order({id:'ship-new',status:'processing',payment_status:'verified',created_at:ago(3)}),
    order({id:'done',status:'delivered',payment_status:'verified'}),order({id:'unpaid'}),order({id:'cancelled',status:'cancelled',payment_status:'submitted'}),
  ];
  const queue=orderQueue({orders},NOW);
  assert.deepEqual(queue.map(t=>t.orderId),['old-pay','ship-old','new-pay','ship-new'],'urgent payment, urgent shipment, then the rest with payments before shipments (verifying unlocks fulfilment)');
  assert.equal(queue[0].urgency,'urgent');assert.equal(queue.at(-1).urgency,'normal');
});
test('waiting time uses the real event when there is one',()=>{
  const q=orderQueue({orders:[order({payment_status:'submitted',created_at:ago(100),events:[{event:'payment_submitted',created_at:ago(3)}]})]},NOW);
  assert.equal(Math.round(q[0].hours),3);assert.equal(q[0].urgency,'normal');
  assert.equal(formatWaiting(0.2),'under 1 hour');assert.equal(formatWaiting(1.4),'1 hour');assert.equal(formatWaiting(5),'5 hours');assert.equal(formatWaiting(24),'1 day');assert.equal(formatWaiting(75),'3 days');
  assert.equal(urgencyFor(3,4,24),'normal');assert.equal(urgencyFor(4,4,24),'soon');assert.equal(urgencyFor(24,4,24),'urgent');
});
test('action groups rank real work above empty groups and flag urgency',()=>{
  const products=[{active:true,stock:0,price_confirmed:true},{active:true,stock:3},{active:true,stock:50},{active:false,stock:0,price_confirmed:true}];
  const groups=actionGroups({orders:[order({payment_status:'submitted',created_at:ago(40)})],refunds:[{status:'requested',created_at:ago(2)},{status:'paid',created_at:ago(900)}],products,reviews:[{published:true,reply:null,created_at:ago(10)},{published:true,reply:'Thanks',created_at:ago(10)},{published:false,reply:null,created_at:ago(10)}]},NOW);
  const by=Object.fromEntries(groups.map(g=>[g.key,g]));
  assert.equal(by.payment.count,1);assert.equal(by.payment.urgency,'urgent');assert.equal(by.ship.count,0);assert.equal(by.refund.count,1);assert.equal(by.review.count,1,'only published reviews without a reply');
  assert.equal(by.stock.count,2);assert.equal(by.stock.urgency,'urgent');assert.match(by.stock.hint,/1 sold out, 1 running low/);
  assert.equal(groups.at(-1).count,0,'groups with nothing to do come last');assert.equal(groups[0].key,'payment');
});
test('delivery progress shows how close the customer is to free delivery',()=>{
  assert.equal(deliveryProgress(5000,{free_shipping_cents:0}),null);
  assert.deepEqual(deliveryProgress(10000,{free_shipping_cents:25000}),{threshold:25000,remaining:15000,unlocked:false,percent:40});
  assert.equal(deliveryProgress(30000,{free_shipping_cents:25000}).unlocked,true);assert.equal(deliveryProgress(30000,{free_shipping_cents:25000}).percent,100);
});
test('buy again respects stock, price confirmation and what is already in the cart',()=>{
  const products=[{id:'a',active:true,price_confirmed:true,stock:10},{id:'b',active:true,price_confirmed:true,stock:2},{id:'c',active:true,price_confirmed:false,stock:9},{id:'d',active:false,price_confirmed:true,stock:9},{id:'e',active:true,price_confirmed:true,stock:0}];
  const items=[{product_id:'a',quantity:3,name:'A'},{product_id:'b',quantity:5,name:'B'},{product_id:'c',quantity:1,name:'C'},{product_id:'d',quantity:1,name:'D'},{product_id:'e',quantity:1,name:'E'},{product_id:'gone',quantity:1,name:'G'}];
  const result=buyAgain({items},products,[{product_id:'a',quantity:2}]);
  assert.deepEqual(result.cart,[{product_id:'a',quantity:5},{product_id:'b',quantity:2}]);assert.equal(result.added,2);
  assert.deepEqual(result.skipped,['B (fewer than before)','C','D','E','G']);
  const cart=[{product_id:'a',quantity:2}];buyAgain({items},products,cart);assert.deepEqual(cart,[{product_id:'a',quantity:2}],'the original cart is not mutated');
});
test('price filter reads RM text safely',()=>{
  assert.equal(parsePrice('12.50'),1250);assert.equal(parsePrice('1,200'),120000);assert.equal(parsePrice(''),null);assert.equal(parsePrice(null),null);assert.equal(parsePrice('abc'),null);assert.equal(parsePrice('-5'),null);assert.equal(parsePrice('99999999'),null);
  const p={price_cents:5000};assert.equal(withinPrice(p,null,null),true);assert.equal(withinPrice(p,5000,5000),true);assert.equal(withinPrice(p,5001,null),false);assert.equal(withinPrice(p,null,4999),false);
});
test('recently viewed keeps the newest twelve, once each, and survives broken storage',()=>{
  const data={};const store={getItem:k=>data[k]??null,setItem:(k,v)=>{data[k]=v;},removeItem:k=>{delete data[k];}};
  for(let i=0;i<15;i++)pushRecent('p'+i,store);
  assert.equal(readRecent(store).length,12);assert.equal(readRecent(store)[0],'p14');
  pushRecent('p10',store);assert.equal(readRecent(store)[0],'p10');assert.equal(readRecent(store).filter(x=>x==='p10').length,1);
  data.gearlane_recent='{not json';assert.deepEqual(readRecent(store),[]);data.gearlane_recent='{"a":1}';assert.deepEqual(readRecent(store),[]);
  assert.deepEqual(pushRecent('',store),[]);assert.deepEqual(pushRecent(null,store),[]);
  pushRecent('x',store);clearRecent(store);assert.deepEqual(readRecent(store),[]);
  assert.deepEqual(readRecent({getItem(){throw new Error('blocked');}}),[]);assert.doesNotThrow(()=>pushRecent('x',{getItem:()=>null,setItem(){throw new Error('quota');}}));
});
test('every action group has a singular and a plural name so counts read naturally',()=>{
  for(const g of actionGroups({orders:[],refunds:[],products:[],reviews:[]},NOW)){assert.ok(g.label&&g.one&&g.label!==g.one,g.key);}
});
test('unanswered product questions are work, and the oldest one drives urgency',()=>{
  const groups=actionGroups({questions:[{answered_at:null,created_at:ago(80)},{answered_at:null,created_at:ago(2)},{answered_at:ago(1),created_at:ago(5)}]},NOW);
  const q=groups.find(g=>g.key==='question');
  assert.equal(q.count,2,'answered questions are not counted');assert.equal(q.urgency,'urgent','80 hours without an answer is overdue');assert.equal(q.to,'/workspace/questions');
  assert.equal(actionGroups({questions:[{answered_at:null,created_at:ago(30)}]},NOW).find(g=>g.key==='question').urgency,'soon');
  assert.equal(actionGroups({questions:[]},NOW).find(g=>g.key==='question').count,0);
});
