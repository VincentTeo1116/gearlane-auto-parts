import React from 'react';
import {ArrowRight,CircleCheck,Clock,MessageCircle,PartyPopper} from 'lucide-react';
import {Badge,Button,Link} from './components.jsx';
import {actionGroups,formatWaiting,orderQueue} from './order-logic.mjs';
import {money} from './domain.mjs';

/* Everything that needs a person, most urgent first. Red means overdue, amber means soon, grey means fine.
   Used as the big "act now" panel on the admin overview and as the side summary on the worker home. */
export function ActionCenter({groups,go,title='Needs your attention'}){
  const open=groups.filter(g=>g.count).length;
  return <section className="panel action-center" aria-label={title}>
    <div className="panel-heading"><div><h3>{title}</h3><small className="muted">{open?`${open} area${open===1?'':'s'} waiting. Most urgent first.`:'Nothing is waiting. Nice work.'}</small></div></div>
    <ul>{groups.map(g=><li key={g.key} className={'action-row '+(g.count?g.urgency:'clear')}>
      <Link to={g.to} go={go}>
        <span className="action-count" aria-hidden="true">{g.count?g.count:<CircleCheck size={22}/>}</span>
        <span className="action-text"><b>{g.count?`${g.count} ${(g.count===1?g.one:g.label).toLowerCase()}`:g.label}</b><small>{g.count?(g.hours>=1?`Oldest waiting ${formatWaiting(g.hours)}`:g.hint):'All clear'}</small></span>
        <span className="action-cta">{g.count?g.cta:'Open'}<ArrowRight size={16}/></span>
      </Link>
    </li>)}</ul>
  </section>;
}

function TaskRow({task,go}){
  const o=task.order;
  return <li className={'task-row urgency-'+task.urgency}>
    <div className="task-main"><b>GL-{o.order_number}</b><span>{o.address.name}</span><small>{o.items.map(i=>i.quantity+' × '+i.name).join(' · ')}</small></div>
    <span className={'task-wait '+task.urgency}><Clock size={14} aria-hidden="true"/>{task.urgency==='urgent'?'Overdue · ':''}{formatWaiting(task.hours)}</span>
    <b className="task-amount">{money(o.total_cents)}</b>
    <Link className="button small" to={'/workspace/orders/'+o.id} go={go}>{task.kind==='payment'?'Verify payment':'Pack and ship'}<ArrowRight size={15}/></Link>
  </li>;
}

/* The worker's whole home screen: one clear "do this first", then the queue in order, with the rest at the side */
export function WorkerHome({data,profile,go,busy,onRelease,notice}){
  const now=Date.now(),queue=orderQueue({orders:data.orders},now),groups=actionGroups({orders:data.orders,refunds:data.refunds,products:data.products,reviews:data.reviews,questions:data.questions||[]},now);
  const first=queue[0],firstName=profile.full_name.split(' ')[0];
  const otherWork=groups.filter(g=>g.count&&!['payment','ship'].includes(g.key));
  return <div className="dashboard worker-home">
    <div className="dash-head"><div><span className="eyebrow">YOUR QUEUE</span><h1>Hi {firstName}, here is what to do</h1><p>{queue.length?`${queue.length} order${queue.length===1?'':'s'} waiting for you, most urgent first.`:'No orders are waiting for you right now.'}</p></div></div>
    {notice}
    {first?<section className={'next-up urgency-'+first.urgency} aria-label="Do this first">
      <div><span className="eyebrow">DO THIS FIRST</span>
        <h2>{first.kind==='payment'?'Verify the payment for':'Pack and ship'} GL-{first.order.order_number}</h2>
        <p>{first.order.address.name} · {money(first.order.total_cents)} · {first.order.items.length} item{first.order.items.length===1?'':'s'}</p>
        <span className={'task-wait big '+first.urgency}><Clock size={16} aria-hidden="true"/>{first.urgency==='urgent'?'Overdue. ':''}Waiting {formatWaiting(first.hours)}</span>
      </div>
      <Link className="button" to={'/workspace/orders/'+first.order.id} go={go}>{first.kind==='payment'?'Verify payment':'Pack and ship'}<ArrowRight size={18}/></Link>
    </section>:<section className="next-up clear" aria-label="All caught up">
      <PartyPopper size={34} aria-hidden="true"/>
      <div><h2>You are all caught up</h2><p>{otherWork.length?`Next: ${otherWork[0].label.toLowerCase()}.`:'No payments to verify and no orders to ship.'}</p></div>
      {otherWork.length?<Link className="button" to={otherWork[0].to} go={go}>{otherWork[0].cta}<ArrowRight size={18}/></Link>:null}
    </section>}
    <div className="dash-grid">
      <section className="panel dash-span-8 task-queue"><div className="panel-heading"><div><h3>Up next</h3><small className="muted">Payments first, then shipments. Oldest and overdue on top.</small></div><Link className="text-link" to="/workspace/orders" go={go}>All orders ↗</Link></div>
        {queue.length?<ul>{queue.slice(0,8).map(t=><TaskRow key={t.key} task={t} go={go}/>)}</ul>:<p className="muted">The queue is clear. New orders will appear here.</p>}
        {queue.length>8?<Link className="text-link" to="/workspace/orders" go={go}>{queue.length-8} more in Orders ↗</Link>:null}
      </section>
      <div className="dash-span-4 worker-side">
        <ActionCenter groups={groups} go={go} title="Everything else"/>
        <section className="panel"><div className="panel-heading"><h3>Customer messages</h3></div><p className="muted small">Reply to customers who wrote to the seller.</p><Link className="button secondary" to="/workspace/messages" go={go}><MessageCircle size={16}/>Open the inbox</Link></section>
        <section className="panel"><div className="panel-heading"><h3>Housekeeping</h3></div><Button variant="secondary small" busy={busy} onClick={onRelease}>Release expired unpaid reservations</Button><p className="small muted">Only unpaid reservations older than 24 hours are released.</p></section>
      </div>
    </div>
  </div>;
}
