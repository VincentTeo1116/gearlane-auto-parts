/* Pure order, task and cart logic shared by the customer and staff screens (no React, easy to test). */
const HOUR=36e5;
const latest=(events,name)=>(events||[]).filter(e=>e.event===name).map(e=>e.created_at).sort().at(-1)||null;
const hoursSince=(iso,now)=>iso?Math.max(0,(now-new Date(iso).getTime())/HOUR):0;

/* ---------- Order tracker ---------- */
export function trackerSteps(order){
  const events=order.events||[];
  const paid=['verified','refunded'].includes(order.payment_status);
  const shipped=['shipped','delivered'].includes(order.status)||Boolean(order.received_at);
  const received=Boolean(order.received_at);
  const cancelled=order.status==='cancelled';
  const step=(key,name,done,current,date=null,detail='')=>({key,name,state:done?'done':current?'current':'todo',date,detail});
  const paymentCurrent=!paid&&!cancelled;
  const paymentDetail=order.payment_status==='submitted'?'We are checking your transfer':order.payment_status==='rejected'?'Your transfer details need attention':'Waiting for your bank transfer';
  const steps=[
    step('placed','Order placed',true,false,order.created_at),
    step('payment','Payment',paid,paymentCurrent,paid?latest(events,'payment_verified'):null,paymentCurrent?paymentDetail:''),
    step('packing','Preparing',shipped,paid&&!shipped&&!cancelled,null,paid&&!shipped&&!cancelled?'Being packed by the store':''),
    step('shipped','Shipped',shipped,false,shipped?latest(events,'shipped'):null),
    step('received','Received',received,shipped&&!received&&!cancelled,received?(order.received_at||latest(events,'receipt_confirmed')):null,shipped&&!received&&!cancelled?'Confirm when it arrives':''),
  ];
  if(cancelled){
    return{cancelled:true,cancelledAt:latest(events,'cancelled')||order.updated_at||null,reason:order.cancel_reason||'',steps:steps.map((s,i)=>i===0?s:{...s,state:'todo',date:null,detail:''}),current:null};
  }
  return{cancelled:false,steps,current:steps.find(s=>s.state==='current')?.key||(received?'received':null)};
}

/* "https://www.google.com/search?q=J%26T%20tracking%20JT123" is a universal fallback: no carrier URL formats are assumed */
export function carrierSearchUrl(carrier,number){
  const query=[String(carrier||'').trim(),'tracking',String(number||'').trim()].filter(Boolean).join(' ');
  return number?'https://www.google.com/search?q='+encodeURIComponent(query):null;
}

/* ---------- Customer order tabs (To pay / To ship / To receive ...) ---------- */
export const CUSTOMER_TABS=[['all','All'],['pay','To pay'],['verify','Verifying'],['ship','To ship'],['receive','To receive'],['done','Completed'],['cancelled','Cancelled & refunds']];
export function customerTab(order){
  if(order.status==='cancelled'||order.payment_status==='refunded')return 'cancelled';
  if(order.received_at)return 'done';
  if(['shipped','delivered'].includes(order.status))return 'receive';
  if(order.status==='processing')return 'ship';
  if(order.payment_status==='submitted')return 'verify';
  return 'pay';
}

/* ---------- Staff priorities ---------- */
export const urgencyFor=(hours,soon,urgent)=>hours>=urgent?'urgent':hours>=soon?'soon':'normal';
const URGENCY_RANK={urgent:0,soon:1,normal:2};
export function formatWaiting(hours){
  if(hours<1)return 'under 1 hour';
  if(hours<24)return Math.floor(hours)+(Math.floor(hours)===1?' hour':' hours');
  const days=Math.floor(hours/24);return days+(days===1?' day':' days');
}

/* Individual orders that need a person, most urgent first, then oldest first. */
export function orderQueue({orders=[]},now=Date.now()){
  const tasks=[];
  for(const o of orders){
    if(o.status==='cancelled')continue;
    if(o.payment_status==='submitted'&&o.status==='awaiting_payment'){
      const since=latest(o.events,'payment_submitted')||o.created_at,hours=hoursSince(since,now);
      tasks.push({key:'pay-'+o.id,kind:'payment',orderId:o.id,title:'Verify payment',order:o,hours,urgency:urgencyFor(hours,4,24),action:'Verify'});
    }else if(o.status==='processing'&&o.payment_status==='verified'){
      const since=latest(o.events,'payment_verified')||o.created_at,hours=hoursSince(since,now);
      tasks.push({key:'ship-'+o.id,kind:'ship',orderId:o.id,title:'Pack and ship',order:o,hours,urgency:urgencyFor(hours,24,48),action:'Ship'});
    }
  }
  const kindRank={payment:0,ship:1};
  return tasks.sort((a,b)=>URGENCY_RANK[a.urgency]-URGENCY_RANK[b.urgency]||kindRank[a.kind]-kindRank[b.kind]||b.hours-a.hours);
}

/* The big groups in the admin "needs action" panel and the worker summary. */
export function actionGroups({orders=[],refunds=[],products=[],reviews=[],questions=[]},now=Date.now()){
  const queue=orderQueue({orders},now),oldest=list=>list.reduce((m,t)=>Math.max(m,t.hours),0);
  const pay=queue.filter(t=>t.kind==='payment'),ship=queue.filter(t=>t.kind==='ship');
  const refundOpen=refunds.filter(r=>['requested','approved'].includes(r.status)).map(r=>({hours:hoursSince(r.created_at,now),approved:r.status==='approved'}));
  const openQuestions=questions.filter(q=>!q.answered_at).map(q=>({hours:hoursSince(q.created_at,now)}));
  const unanswered=reviews.filter(r=>r.published&&!r.reply).map(r=>({hours:hoursSince(r.created_at,now)}));
  const active=products.filter(p=>p.active),out=active.filter(p=>p.stock===0&&p.price_confirmed),low=active.filter(p=>p.stock>0&&p.stock<10);
  const groups=[
    {key:'payment',label:'Payments to verify',one:'Payment to verify',hint:'Check the real bank deposit',count:pay.length,hours:oldest(pay),urgency:urgencyFor(oldest(pay),4,24),to:'/workspace/orders?payment=submitted',cta:'Verify'},
    {key:'ship',label:'Orders to pack and ship',one:'Order to pack and ship',hint:'Verified and waiting for dispatch',count:ship.length,hours:oldest(ship),urgency:urgencyFor(oldest(ship),24,48),to:'/workspace/orders?status=processing',cta:'Ship'},
    {key:'refund',label:'Refund requests',one:'Refund request',hint:'Review, then record the transfer',count:refundOpen.length,hours:oldest(refundOpen),urgency:urgencyFor(oldest(refundOpen),24,48),to:'/workspace/refunds',cta:'Review'},
    {key:'question',label:'Questions to answer',one:'Question to answer',hint:'Public answers help other buyers',count:openQuestions.length,hours:oldest(openQuestions),urgency:urgencyFor(oldest(openQuestions),24,72),to:'/workspace/questions',cta:'Answer'},
    {key:'review',label:'Reviews to answer',one:'Review to answer',hint:'A public reply builds trust',count:unanswered.length,hours:oldest(unanswered),urgency:urgencyFor(oldest(unanswered),72,168),to:'/workspace/reviews',cta:'Reply'},
    {key:'stock',label:'Products to restock',one:'Product to restock',hint:out.length?`${out.length} sold out, ${low.length} running low`:`${low.length} running low`,count:out.length+low.length,hours:0,urgency:out.length?'urgent':low.length?'soon':'normal',to:'/workspace/restock',cta:'Restock'},
  ];
  return groups.sort((a,b)=>(a.count?0:1)-(b.count?0:1)||URGENCY_RANK[a.urgency]-URGENCY_RANK[b.urgency]||b.hours-a.hours);
}

/* ---------- Cart helpers ---------- */
export function deliveryProgress(subtotalCents,settings){
  const threshold=Number(settings?.free_shipping_cents||0);
  if(threshold<=0)return null;
  const remaining=Math.max(0,threshold-subtotalCents);
  return{threshold,remaining,unlocked:remaining===0,percent:Math.min(100,Math.round(subtotalCents/threshold*100))};
}

/* Adds an earlier order's items to the cart, never beyond stock, and reports what could not be added. */
export function buyAgain(order,products,cart){
  const next=cart.map(l=>({...l})),skipped=[];let added=0;
  for(const item of order.items||[]){
    const p=products.find(x=>x.id===item.product_id);
    if(!p||!p.active||!p.price_confirmed||p.stock<1){skipped.push(item.name);continue;}
    const existing=next.find(l=>l.product_id===p.id),have=existing?existing.quantity:0,room=p.stock-have;
    if(room<1){skipped.push(item.name);continue;}
    const quantity=Math.min(item.quantity,room);
    if(existing)existing.quantity+=quantity;else next.push({product_id:p.id,quantity});
    added++;if(quantity<item.quantity)skipped.push(item.name+' (fewer than before)');
  }
  return{cart:next,added,skipped};
}

/* ---------- Price filter (RM text from the URL to cents) ---------- */
export function parsePrice(text){
  if(text===null||text===undefined||String(text).trim()==='')return null;
  const value=Number(String(text).replace(/,/g,''));
  return Number.isFinite(value)&&value>=0&&value<=1000000?Math.round(value*100):null;
}
export function withinPrice(product,min,max){
  return(min===null||product.price_cents>=min)&&(max===null||product.price_cents<=max);
}
