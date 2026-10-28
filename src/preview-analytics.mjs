// Match dashboard_stats SQL: verified orders only; full paid refunds are excluded.
export function previewAnalytics(state,days,now=Date.now()){
 const since=now-days*86400000;
 const recent=state.orders.filter(o=>new Date(o.created_at)>=since);
 const paid=recent.filter(o=>o.payment_status==='verified');
 const activity=state.activity.filter(e=>new Date(e.created_at)>=since);
 const customers=state.users.filter(u=>u.role==='customer'&&u.is_active);
 const counts=(rows,key)=>{const map=new Map();for(const row of rows){const name=key(row);map.set(name,(map.get(name)||0)+1);}return [...map].map(([name,count])=>({name,count}));};
 const daily=new Map(),categories=new Map();
 for(const order of paid){
  const day=new Date(new Date(order.created_at).getTime()+8*3600000).toISOString().slice(0,10);
  daily.set(day,(daily.get(day)||0)+order.total_cents);
  for(const item of order.items){const row=categories.get(item.category)||{category:item.category,units:0,value:0};row.units+=item.quantity;row.value+=item.line_total_cents;categories.set(item.category,row);}
 }
 return {
  paid_sales_cents:paid.reduce((sum,o)=>sum+o.total_cents,0),paid_orders:paid.length,orders:recent.length,
  customers:customers.length,active_customers:new Set(activity.map(e=>e.user_id)).size,
  awaiting_payment:state.orders.filter(o=>o.status==='awaiting_payment').length,
  low_stock:state.products.filter(p=>p.active&&p.stock<10).length,
  customer_types:counts(customers,u=>u.business_type).map(x=>({business_type:x.name,count:x.count})),
  daily_sales:[...daily].sort(([a],[b])=>a.localeCompare(b)).map(([day,value])=>({day,value})),
  active_hours:counts(activity,e=>(new Date(e.created_at).getUTCHours()+8)%24).map(x=>({hour:x.name,count:x.count})).sort((a,b)=>a.hour-b.hour),
  categories:[...categories.values()].sort((a,b)=>b.value-a.value),
  wishlist_categories:counts(state.wishlist,w=>state.products.find(p=>p.id===w.product_id)?.category||'Other').map(x=>({category:x.name,count:x.count})).sort((a,b)=>b.count-a.count)
 };
}
