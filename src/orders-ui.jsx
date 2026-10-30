import React,{useEffect,useState} from 'react';
import {ArrowLeft,ArrowRight,Download,RotateCcw,Search,Store} from 'lucide-react';
import {useApp} from './context.jsx';
import {Badge,Button,Empty,Link,Notice,ProductArt} from './components.jsx';
import {OrderListNext} from './experience.jsx';
import {OrderMiniProgress} from './order-tracking.jsx';
import {InvoiceButton} from './invoice-ui.jsx';
import {CUSTOMER_TABS,buyAgain,customerTab,formatWaiting,orderQueue} from './order-logic.mjs';
import {canReview,dateTime,label,money} from './domain.mjs';
import {downloadCsv,orderColumns,stamp,toCsv} from './csv.mjs';

const PER_PAGE=25;
const TAB_STATUS={pay:'To pay',verify:'Verifying payment',ship:'To ship',receive:'To receive',done:'Completed',cancelled:'Cancelled'};

/* Staff quick filters, with live counts. They set the same status/payment filters as the dropdowns. */
function StaffPills({orders,status,payment,setStatus,setPayment}){
  const live=o=>o.status!=='cancelled';
  const defs=[['all','All orders',()=>true,'all','all'],['verify','Verify payment',o=>live(o)&&o.payment_status==='submitted','all','submitted'],['awaiting','Awaiting transfer',o=>o.status==='awaiting_payment'&&['awaiting','rejected'].includes(o.payment_status),'awaiting_payment','all'],['prepare','To ship',o=>o.status==='processing','processing','all'],['shipped','Shipped',o=>o.status==='shipped','shipped','all'],['delivered','Delivered',o=>o.status==='delivered','delivered','all']];
  const active=(defs.find(d=>d[3]===status&&d[4]===payment)||[])[0];
  return <div className="order-pills" role="group" aria-label="Quick order filters">{defs.map(([key,text,test,s,p])=><button key={key} type="button" aria-pressed={active===key} className={active===key?'selected':''} onClick={()=>{setStatus(s);setPayment(p);}}>{text}<span>{orders.filter(test).length}</span></button>)}</div>;
}

/* Customer tabs: the way people already think about a marketplace order */
function CustomerTabs({orders,tab,setTab}){
  return <div className="order-tabs" role="tablist" aria-label="Order status">{CUSTOMER_TABS.map(([key,text])=>{const count=key==='all'?orders.length:orders.filter(o=>customerTab(o)===key).length;return <button key={key} type="button" role="tab" aria-selected={tab===key} className={tab===key?'selected':''} onClick={()=>setTab(key)}>{text}{count?<span>{count}</span>:null}</button>;})}</div>;
}

function Thumb({item,products}){
  const product=products.find(p=>p.id===item.product_id);
  return <div className="order-line"><div className="order-thumb">{product?<ProductArt product={product}/>:<span aria-hidden="true">{item.name.charAt(0)}</span>}</div><div><b>{item.name}</b><small>{item.quantity} × {money(item.price_cents)}</small></div><span className="order-line-total">{money(item.line_total_cents)}</span></div>;
}

export function OrdersView({workspace=false}){
  const {data,go,profile,route,cart,setCart,notify}=useApp(),params=new URLSearchParams(route.split('?')[1]);
  const [status,setStatus]=useState(params.get('status')||'all'),[payment,setPayment]=useState(params.get('payment')||'all'),[tab,setTab]=useState('all'),[q,setQ]=useState(''),[sort,setSort]=useState('priority'),[page,setPage]=useState(1);
  useEffect(()=>{setPage(1);},[status,payment,tab,q,sort]);
  useEffect(()=>{const p=new URLSearchParams(route.split('?')[1]);setStatus(p.get('status')||'all');setPayment(p.get('payment')||'all');},[route]);
  const all=data.orders||[],now=Date.now();
  if(profile.role!=='customer'&&!workspace)return <main className="container section"><Notice>Use the staff workspace to manage store orders.</Notice><Link to="/workspace/orders" go={go}>Open staff orders →</Link></main>;

  const filtered=all.filter(o=>(status==='all'||o.status===status)&&(payment==='all'||o.payment_status===payment)&&(workspace||tab==='all'||customerTab(o)===tab)&&(!q||String(o.order_number).includes(q.replace(/^gl-/i,''))||o.address.name.toLowerCase().includes(q.toLowerCase())||(o.items||[]).some(i=>i.name.toLowerCase().includes(q.toLowerCase()))));
  const tasks=new Map(orderQueue({orders:workspace?filtered:[]},now).map((t,i)=>[t.orderId,{...t,rank:i}]));
  const orders=workspace&&sort==='priority'?[...filtered].sort((a,b)=>{const ta=tasks.get(a.id),tb=tasks.get(b.id);return ta&&tb?ta.rank-tb.rank:ta?-1:tb?1:new Date(b.created_at)-new Date(a.created_at);}):[...filtered].sort((a,b)=>new Date(b.created_at)-new Date(a.created_at));
  const pages=Math.max(1,Math.ceil(orders.length/PER_PAGE)),safePage=Math.min(page,pages),visible=orders.slice((safePage-1)*PER_PAGE,safePage*PER_PAGE);
  const reorder=order=>{
    const result=buyAgain(order,data.products,cart);
    if(!result.added){notify('None of these items can be added right now. They may be sold out or unavailable.','error');return;}
    setCart(result.cart);
    notify(`Added ${result.added} item${result.added===1?'':'s'} from GL-${order.order_number} to your cart.${result.skipped.length?' Not added or reduced: '+result.skipped.join(', ')+'.':''}`);
    go('/cart');
  };

  return <section className={workspace?'':'container section'}>
    <div className="section-heading"><div><span className="eyebrow">{workspace?'FULFILMENT & PAYMENT':'YOUR PURCHASES'}</span><h1>{workspace?'Orders':'My orders'}</h1><p>{workspace?'Orders that need a person come first. Open one to verify payment or record shipment.':'Follow each order from payment to delivery. Open an order for payment instructions and tracking.'}</p></div></div>
    {!workspace?<CustomerTabs orders={all} tab={tab} setTab={setTab}/>:null}
    <div className="toolbar">
      <div className="inline-search"><Search size={16}/><input aria-label="Search orders" placeholder={workspace?'Order number or name':'Order number or product name'} maxLength={100} value={q} onChange={e=>setQ(e.target.value)}/></div>
      {workspace?<>
        <select aria-label="Payment status" value={payment} onChange={e=>setPayment(e.target.value)}><option value="all">All payment states</option>{['awaiting','submitted','verified','rejected','refunded'].map(v=><option key={v} value={v}>{label(v)}</option>)}</select>
        <select aria-label="Order status" value={status} onChange={e=>setStatus(e.target.value)}><option value="all">All order statuses</option>{['awaiting_payment','processing','shipped','delivered','cancelled'].map(v=><option key={v} value={v}>{label(v)}</option>)}</select>
        <select aria-label="Sort orders" value={sort} onChange={e=>setSort(e.target.value)}><option value="priority">Needs action first</option><option value="newest">Newest first</option></select>
        <Button variant="secondary small" disabled={!orders.length} onClick={()=>downloadCsv('orders-'+stamp()+'.csv',toCsv(orders,orderColumns))}><Download size={15}/>Export {orders.length} to CSV</Button>
      </>:null}
    </div>
    {workspace?<StaffPills orders={all} status={status} payment={payment} setStatus={setStatus} setPayment={setPayment}/>:null}
    {orders.length?<div className="order-list">
      {visible.map(o=>{
        const task=tasks.get(o.id),tabKey=customerTab(o),needsYou=!workspace&&tabKey==='pay',unreviewed=!workspace&&tabKey==='done'&&(o.items||[]).some(i=>canReview(o,i.product_id)&&!data.reviews.some(r=>r.order_id===o.id&&r.product_id===i.product_id));
        const primary=workspace?(task?{text:task.kind==='payment'?'Verify payment':'Pack and ship',to:'/workspace/orders/'+o.id}:null):needsYou?{text:'Pay now',to:'/orders/'+o.id}:tabKey==='receive'?{text:'Confirm receipt',to:'/orders/'+o.id}:unreviewed?{text:'Review items',to:'/orders/'+o.id}:null;
        return <article key={o.id} className={'panel order-list-card'+(task||needsYou?' needs-action':'')+(task?' urgency-'+task.urgency:'')}>
          <div className="order-list-top">
            <div><b>GL-{o.order_number}</b><small>{dateTime(o.created_at)}{task?<em className={'waiting '+task.urgency}> · waiting {formatWaiting(task.hours)}</em>:null}</small></div>
            {task?<span className={'action-tag '+task.urgency}>{task.urgency==='urgent'?'Overdue · ':''}{task.kind==='payment'?'Verify payment':'Ship order'}</span>:needsYou?<span className="action-tag">Your next step</span>:null}
            {workspace?<><Badge value={o.status}/><Badge value={o.payment_status}/></>:<span className={'order-stage stage-'+tabKey}>{TAB_STATUS[tabKey]}</span>}
            <b>{money(o.total_cents)}</b>
          </div>
          <OrderMiniProgress order={o}/>
          {workspace?<><OrderListNext order={o} staff/><div className="order-list-bottom"><div><p>{o.items.map(i=>i.quantity+' × '+i.name).join(' · ')}</p><small>{o.address.name}</small></div><div className="order-actions-row">{primary?<Link className="button small" to={primary.to} go={go}>{primary.text} <ArrowRight size={15}/></Link>:null}<Link className={'button small'+(primary?' secondary':' secondary')} to={'/workspace/orders/'+o.id} go={go}>View order <ArrowRight size={15}/></Link></div></div></>
          :<>
            <div className="order-lines">{(o.items||[]).slice(0,3).map(i=><Thumb key={i.id||i.product_id} item={i} products={data.products}/>)}{(o.items||[]).length>3?<small className="muted">+ {(o.items||[]).length-3} more item{(o.items||[]).length-3===1?'':'s'}</small>:null}</div>
            <OrderListNext order={o}/>
            <div className="order-list-bottom"><small>{o.received_at?'Receipt confirmed':'Receipt not yet confirmed'}</small><div className="order-actions-row">
              {['done','cancelled'].includes(tabKey)||tabKey==='receive'?<Button variant="secondary small" onClick={()=>reorder(o)}><RotateCcw size={15}/>Buy again</Button>:null}
              <InvoiceButton order={o} label="Invoice"/>
              {primary?<Link className="button small" to={primary.to} go={go}>{primary.text}<ArrowRight size={15}/></Link>:null}
              <Link className="button secondary small" to={'/orders/'+o.id} go={go}>View details<ArrowRight size={15}/></Link>
            </div></div>
          </>}
        </article>;
      })}
      {pages>1?<div className="pagination"><Button variant="secondary small" disabled={safePage<=1} onClick={()=>setPage(safePage-1)}><ArrowLeft size={14}/>Previous</Button><span>Page {safePage} of {pages} · {orders.length} orders</span><Button variant="secondary small" disabled={safePage>=pages} onClick={()=>setPage(safePage+1)}>Next<ArrowRight size={14}/></Button></div>:null}
    </div>:<Empty title={all.length&&!workspace&&tab!=='all'?'Nothing in "'+CUSTOMER_TABS.find(t=>t[0]===tab)[1]+'"':'No matching orders'} action={!workspace?<Link className="button" to="/shop" go={go}>Browse parts</Link>:null}>{all.length?'Try another tab or search term.':'Your orders will appear here after you check out.'}</Empty>}
  </section>;
}
