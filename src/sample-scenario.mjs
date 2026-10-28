// Fictional records for the isolated preview. Never imported by the live repository.
export const SAMPLE_SCENARIO_VERSION=1;
const DAY=86400000,HOUR=3600000;
const sum=(rows,key)=>rows.reduce((total,row)=>total+row[key],0);
const time=(value)=>new Date(value).toISOString();
const localTime=(now,days,hour)=>Math.floor((now+8*HOUR)/DAY)*DAY-8*HOUR-days*DAY+hour*HOUR;

export function addSampleScenario(input,{now=Date.now()}={}){
 if(input.sample_data_version===SAMPLE_SCENARIO_VERSION)return input;
 const state=structuredClone(input),uid=()=>crypto.randomUUID();
 const admin=state.users.find(u=>u.role==='admin'),worker=state.users.find(u=>u.role==='worker')||admin;
 const types=['personal','workshop','retailer','distributor'];
 const customers=Array.from({length:12},(_,index)=>({id:`30000000-0000-4000-8000-${String(index+1).padStart(12,'0')}`,role:'customer',full_name:`Demo ${['Motorist','Workshop','Parts Shop','Distributor'][index%4]} ${String(index+1).padStart(2,'0')}`,email:`sample-buyer-${index+1}@example.invalid`,phone:'0100000000',business_type:types[index%4],is_active:true,created_at:time(now-95*DAY),sample_data:true}));
 state.users.push(...customers);
 const inventory=state.products.map(p=>({product_id:p.id,opening_units:p.stock,reserved_or_sold_units:0,restored_units:0}));
 const available=state.products.filter(p=>p.active&&p.price_confirmed&&p.stock>=12);
 if(available.length<4)throw new Error('Sample reports need at least four preview products with confirmed prices and 12 units in stock.');
 const categories=[...new Set(available.map(p=>p.category))];
 const requested=['Engine Oil','Filters','Engine Oil','Brake Pads','Gearbox Oil','Wipers',...categories];
 const hours=[9,10,11,13,14,18,20,21,20,21,20,21];
 const addedOrders=[],addedRefunds=[],addedReviews=[],addedActivity=[];
 let nextOrder=Math.max(10000,...state.orders.map(o=>Number(o.order_number)))+1;
 for(let index=0;index<84;index++){
  const customer=customers[index%customers.length],recent=index<14;
  const kind=recent?['awaiting','submitted','rejected','processing','shipped','delivered','cancelled','refunded','delivered','delivered','delivered','delivered','refund_requested','refund_approved'][index]:index%17===0?'refunded':index%13===0?'cancelled':'delivered';
  const pending=['awaiting','submitted','rejected'].includes(kind);
  const created=pending?now-(index+2)*HOUR:localTime(now,recent?Math.max(2,index):8+index-14,hours[index%hours.length]);
  const orderId=uid(),items=[];
  for(let line=0;line<1+index%3;line++){
   const category=requested[(index+line*3)%requested.length];
   const candidates=available.filter(p=>!items.some(i=>i.product_id===p.id)&&p.stock>=12);
   const matching=candidates.filter(p=>p.category===category),pool=matching.length?matching:candidates;
   if(!pool.length)break;
   const product=pool[(index+line)%pool.length];
   const wanted=customer.business_type==='personal'?1+index%2:customer.business_type==='workshop'?3+index%4:customer.business_type==='retailer'?6+index%7:12+index%9;
   const quantity=Math.min(wanted,product.stock-10);
   items.push({id:uid(),order_id:orderId,product_id:product.id,name:product.name,sku:product.sku,category:product.category,quantity,price_cents:product.price_cents,line_total_cents:quantity*product.price_cents});
   const balance=inventory.find(row=>row.product_id===product.id);
   balance.reserved_or_sold_units+=quantity;product.stock-=quantity;
   if(kind==='cancelled'||kind==='refunded'){balance.restored_units+=quantity;product.stock+=quantity;}
  }
  if(!items.length)throw new Error('Not enough preview inventory to generate coherent example orders.');
  const subtotal=sum(items,'line_total_cents');
  const shipping=state.settings.free_shipping_cents>0&&subtotal>=state.settings.free_shipping_cents?0:state.settings.shipping_cents;
  const payment=kind==='refunded'?'refunded':kind==='cancelled'||kind==='awaiting'?'awaiting':kind==='submitted'?'submitted':kind==='rejected'?'rejected':'verified';
  const status=pending?'awaiting_payment':kind==='cancelled'||kind==='refunded'?'cancelled':kind==='processing'?'processing':kind==='shipped'?'shipped':'delivered';
  const received=status==='delivered'||kind==='refunded';
  const event=(event,offset,note)=>({id:uid(),order_id:orderId,event,actor_id:customer.id,note,created_at:time(created+offset)});
  const events=[event('order_created',0,'Fictional example: inventory reserved.')];
  if(!['awaiting','cancelled'].includes(kind))events.push(event('payment_submitted',10*60000,'Fictional bank reference; no transfer occurred.'));
  if(payment==='verified'||payment==='refunded')events.push({...event('payment_verified',20*60000,'Fictional deposit verification.'),actor_id:worker?.id});
  if(['shipped','delivered'].includes(status)||kind==='refunded')events.push({...event('shipped',DAY,'Fictional carrier and tracking number.'),actor_id:worker?.id});
  if(received)events.push(event('receipt_confirmed',2*DAY,'Fictional buyer confirmed receipt.'));
  if(kind==='rejected')events.push({...event('payment_rejected',20*60000,'Example transfer amount does not match the order.'),actor_id:worker?.id});
  if(kind==='cancelled')events.push(event('cancelled',30*60000,'Fictional unpaid cancellation; reserved inventory restored.'));
  if(kind==='refunded')events.push({...event('refund_paid',3*DAY,'Fictional full refund; returned units restored.'),actor_id:admin?.id});
  const order={id:orderId,order_number:nextOrder++,customer_id:customer.id,status,payment_status:payment,address:{name:customer.full_name,phone:customer.phone,line1:'Demo address — not for delivery',city:'Petaling Jaya',postcode:'47300',state:'Selangor'},subtotal_cents:subtotal,discount_cents:0,shipping_cents:shipping,total_cents:subtotal+shipping,payment_instructions:{bank_name:state.settings.bank_name,bank_account_name:state.settings.bank_account_name,bank_account_number:state.settings.bank_account_number},payment_reference:['awaiting','cancelled'].includes(kind)?null:`SAMPLE-NO-TRANSFER-${index+1}`,paid_verified_by:payment==='verified'||payment==='refunded'?worker?.id:null,payment_note:kind==='rejected'?'Example amount mismatch.':null,carrier:['shipped','delivered'].includes(status)||kind==='refunded'?'Demo carrier':null,tracking_number:['shipped','delivered'].includes(status)||kind==='refunded'?`DEMO-NOT-A-PARCEL-${index+1}`:null,received_at:received?time(created+2*DAY):null,cancel_reason:kind==='cancelled'?'Example customer changed their mind.':null,idempotency_key:uid(),created_at:time(created),updated_at:events.at(-1).created_at,expires_at:time(created+DAY),items,events,sample_data:true};
  addedOrders.push(order);
  if(['refund_requested','refund_approved','refunded'].includes(kind))addedRefunds.push({id:uid(),order_id:orderId,customer_id:customer.id,reason:'Fictional example: the buyer ordered the wrong specification.',status:kind==='refunded'?'paid':kind==='refund_approved'?'approved':'requested',amount_cents:order.total_cents,staff_note:kind==='refund_requested'?null:'Fictional return review only.',transfer_reference:kind==='refunded'?`DEMO-REFUND-NOT-PAID-${index+1}`:null,return_received:kind!=='refund_requested',stock_restored:kind==='refunded',created_at:time(created+2.5*DAY),updated_at:time(created+3*DAY),sample_data:true});
  if(status==='delivered'&&index%4===1)addedReviews.push({id:uid(),order_id:orderId,product_id:items[0].product_id,customer_id:customer.id,display_name:customer.full_name,rating:index%5===0?3:index%3===0?4:5,body:'Fictional verified-purchase feedback: received the selected specification and checked the packaging.',reply:index%2===1?'Example seller reply: thank you for checking the specification.':null,reply_by:index%2===1?worker?.id:null,published:true,created_at:time(created+3*DAY),sample_data:true});
  const session=uid();
  for(const [event,offset] of [['session_started',-15*60000],['view_product',-10*60000],['checkout_started',-5*60000],['order_placed',0]])addedActivity.push({user_id:customer.id,event,product_id:event==='view_product'?items[0].product_id:null,session_id:session,created_at:time(created+offset),sample_data:true});
 }
 state.orders.push(...addedOrders);state.orders.sort((a,b)=>b.created_at.localeCompare(a.created_at));
 state.refunds.push(...addedRefunds);state.reviews.push(...addedReviews);state.activity.push(...addedActivity);
 for(const [index,customer] of customers.entries())for(let choice=0;choice<2+index%4;choice++){
  const product=available[(index*3+choice*5)%available.length];
  if(!state.wishlist.some(w=>w.user_id===customer.id&&w.product_id===product.id))state.wishlist.push({user_id:customer.id,product_id:product.id,created_at:time(now-(index+1)*DAY),sample_data:true});
 }
 state.sample_data_version=SAMPLE_SCENARIO_VERSION;
 state.sample_inventory=inventory.map(row=>({...row,closing_units:state.products.find(p=>p.id===row.product_id).stock}));
 state.sample_summary={customers:customers.length,orders:addedOrders.length,activity_events:addedActivity.length,reviews:addedReviews.length,refunds:addedRefunds.length,days:90,generated_at:time(now)};
 return state;
}
