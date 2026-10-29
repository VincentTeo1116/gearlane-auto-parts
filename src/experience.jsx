import React, {useEffect, useRef, useState} from 'react';
import {ArrowRight, ArrowLeft, Search, ShoppingBag, Package, Heart, MessageCircle, User, Bell, Menu, X, Check, ShieldCheck, Truck, CreditCard, ClipboardCheck, Wrench, ChevronRight, CircleHelp, Settings, Boxes} from 'lucide-react';
import {useApp, useTask} from './context.jsx';
import {CustomerHome,CatalogueSearch} from './customer-design.jsx';
import {Button, Link, Modal, ProductArt, Notice, Field, Empty} from './components.jsx';
import {money, addressSchema, validate, calculateCart, STATES} from './domain.mjs';

export function StoreChrome() {
  const {data, profile, route, go, cart, setDialog} = useApp();
  const [menu, setMenu] = useState(false);
  useEffect(() => setMenu(false), [route]);
  const path = route.split('?')[0];
  const count = cart.reduce((n, item) => n + item.quantity, 0);
  const unread = data?.notifications?.filter(n => !n.read_at).length || 0;
  const staff = profile && profile.role !== 'customer';
  const links = [['/shop', 'Shop parts', ShoppingBag], [staff ? '/workspace' : '/orders', staff ? 'Workspace' : 'My orders', Package], ['/messages', 'Messages', MessageCircle]];
  return <>
    <a className="skip-link" href="#page-main">Skip to content</a>
    <div className="store-promise"><div className="container"><span><ShieldCheck size={15}/> Find the right part. Ask us if you’re unsure.</span><button onClick={() => setDialog({type: 'shopping-guide'})}>New here? How to order <ArrowRight size={14}/></button></div></div>
    <header className="store-header redesigned-header">
      <div className="container header-main">
        <Link to="/" go={go} className="brand" aria-label="GearLane home"><span className="brand-mark">G<span/></span><span>{data?.settings.store_name || 'GearLane Auto Parts'}<small><span>PARTS. SUPPORT.</span>{' '}<span>PEACE OF MIND.</span></small></span></Link>
        <CatalogueSearch/>
        <div className="header-icons">
          {profile ? <button className="icon-link notification-control" aria-label="Notifications" onClick={() => setDialog({type: 'notifications'})}><Bell size={22}/>{unread ? <small>{unread}</small> : null}</button> : null}
          <Link to="/account" go={go} className="account-link"><User size={22}/><span>{profile ? profile.full_name.split(' ')[0] : 'Sign in'}<small>{profile ? 'Your account' : 'or create an account'}</small></span></Link>
          <Link to="/cart" go={go} className="header-cart" aria-label={'Cart, ' + count + ' items'}><ShoppingBag size={22}/><span>Cart <b key={count} className={"count-pop"+(count?"":" zero")}>{count}</b></span></Link>
          <button className="icon-button mobile-menu" aria-label="Toggle navigation" aria-expanded={menu} aria-controls="store-primary-navigation" onClick={() => setMenu(!menu)}>{menu ? <X/> : <Menu/>}</button>
        </div>
      </div>
      <div className="primary-navigation-wrap"><nav id="store-primary-navigation" className={'container shop-navigation ' + (menu ? 'open' : '')} aria-label="Store navigation">
        {links.map(([to, text, Icon]) => <Link key={to} to={to} go={go} aria-current={path === to ? 'page' : undefined} className={path === to ? 'active' : ''}><Icon size={17}/>{text}</Link>)}
        <Link to="/wishlist" go={go} aria-current={path === '/wishlist' ? 'page' : undefined}><Heart size={17}/>Saved items</Link>
        <button className="shopping-help-link" onClick={() => {setMenu(false); setDialog({type: 'shopping-guide'});}}><CircleHelp size={17}/>How to order</button>
        <span className="nav-note"><CreditCard size={16}/>Pay by bank transfer</span>
      </nav></div>
    </header>
    <nav className="mobile-bottom-nav" aria-label="Quick navigation">{[['/shop', 'Shop', ShoppingBag], ['/cart', 'Cart', CreditCard], [staff ? '/workspace' : '/orders', staff ? 'Workspace' : 'Orders', Package], ['/account', 'Account', User]].map(([to, text, Icon]) => <Link key={to} to={to} go={go} aria-current={path === to ? 'page' : undefined}><Icon size={21}/><span>{text}{to === '/cart' && count ? <b>{count}</b> : null}</span></Link>)}</nav>
  </>;
}

export function ShoppingGuide({onClose}) {
  const {go} = useApp();
  return <Modal title="Your first order, step by step" onClose={onClose}>
    <p>Browse first. Transfer only after you’ve placed an order and received its bank instructions.</p>
    <ol className="guide-list">{[
      ['Choose your parts', 'Search or choose a category. Check specifications and ask the seller if you need help with fitment.'],
      ['Check your cart and delivery', 'Add available items, sign in, enter your address and review the complete total.'],
      ['Place the order, then transfer', 'Your order page shows the bank account and amount. Make the transfer and submit its reference.'],
      ['Follow progress in My orders', 'Staff verify payment and add shipping details. Confirm receipt when the order arrives to leave a review.']
    ].map(([title, text], index) => <li key={title}><span>{index + 1}</span><div><b>{title}</b><p>{text}</p></div></li>)}</ol>
    <Button className="full-width" onClick={() => {onClose(); go('/shop');}}>Start browsing <ArrowRight size={18}/></Button>
  </Modal>;
}

export function ShoppingSteps({current = 0}) {
  const {go} = useApp();
  const steps = [['Find parts', '/shop'], ['Your cart', '/cart'], ['Delivery & review', '/checkout'], ['Bank transfer', null]];
  return <ol className="shopping-steps" aria-label="Shopping progress">{steps.map(([name, to], index) => <li key={name} className={index < current ? 'complete' : index === current ? 'current' : ''} aria-current={index === current ? 'step' : undefined}>
    <span>{index < current ? <Check size={16}/> : index + 1}</span>{to && index < current ? <Link to={to} go={go}>{name}</Link> : <b>{name}</b>}
  </li>)}</ol>;
}

export function StoreHome({ProductCard}) {return <CustomerHome ProductCard={ProductCard}/>;}

export function ActiveFilters() {
  const {route, go} = useApp();
  const params = new URLSearchParams(route.split('?')[1]);
  const active = ['q', 'category', 'brand', 'stock'].filter(k => params.get(k));
  if (!active.length) return null;
  return <div className="active-filters" aria-label="Active filters">{active.map(key => <button key={key} onClick={() => {const next = new URLSearchParams(params); next.delete(key); next.delete('page'); go('/shop' + (next.size ? '?' + next : ''), {preserveScroll:true});}}>{key === 'stock' ? 'Ready to buy' : params.get(key)}<X size={14}/><span className="sr-only">Remove filter</span></button>)}</div>;
}

export function GuidedCheckout({Totals}) {
  const {data, cart, setCart, profile, repository, go, track, setDialog} = useApp();
  const task = useTask();
  const [stage, setStage] = useState('delivery');
  const [address, setAddress] = useState({name:profile.full_name,phone:profile.phone,line1:'',city:'',postcode:'',state:'Selangor'});
  const [code, setCode] = useState(''), [applied, setApplied] = useState(''), [accepted, setAccepted] = useState(false);
  const heading = useRef(null), idempotency = useRef(null);
  useEffect(() => {track('checkout_started');try {idempotency.current = sessionStorage.getItem('gearlane_checkout_key') || crypto.randomUUID();sessionStorage.setItem('gearlane_checkout_key',idempotency.current);}catch {idempotency.current=crypto.randomUUID();}}, []);
  const promo = applied ? data.promotions.find(p => p.code === applied) : null;
  let totals, error;
  try {if(applied && !promo) throw new Error('Promotion unavailable.');totals=calculateCart(cart,data.products,data.settings,promo);}catch(e) {error=e.message;}
  const changeStage = next => {setStage(next);task.setError('');requestAnimationFrame(() => {heading.current?.focus();heading.current?.scrollIntoView({block:'start'});});};
  const submit = async e => {
    e.preventDefault();
    if (stage === 'delivery') {try {setAddress(validate(addressSchema,address));changeStage('review');}catch(e) {task.setError(e.message);}return;}
    const result=await task.perform(async () => {if(!accepted) throw new Error('Please confirm the item specifications and bank-transfer process.');if(error) throw new Error(error);return repository.rpc('create_order',{p_items:cart,p_address:validate(addressSchema,address),p_code:applied,p_idempotency_key:idempotency.current,p_expected_total:totals.total_cents});});
    if(result.ok) {setCart([]);sessionStorage.removeItem('gearlane_checkout_key');go('/orders/'+result.value);setDialog({type:'order-placed',orderId:result.value});}
  };
  if(!cart.length) return <main className="container section"><ShoppingSteps current={1}/><Empty title="Your cart is empty" action={<Link className="button" to="/shop" go={go}>Find your parts <ArrowRight size={18}/></Link>}>Add available parts before entering delivery details.</Empty></main>;
  return <main className="container section guided-checkout"><ShoppingSteps current={2}/><div className="section-heading"><div><span className="eyebrow">{stage === 'delivery' ? 'STEP 1 OF 2 · DELIVERY' : 'STEP 2 OF 2 · REVIEW'}</span><h1 ref={heading} tabIndex={-1}>{stage === 'delivery' ? 'Where should we send your order?' : 'Everything look right?'}</h1><p>{stage === 'delivery' ? 'Enter your delivery details. You can check everything before placing the order.' : 'Check your items, delivery address and total. Bank instructions come next.'}</p></div></div>
    <ol className="stage-progress" aria-label="Checkout progress"><li className={stage==='delivery'?'current':'complete'} aria-current={stage==='delivery'?'step':undefined}><span>{stage==='delivery'?'1':<Check size={15}/>}</span>{stage==='review'?<button type="button" onClick={() => changeStage('delivery')}>Delivery</button>:<b>Delivery</b>}</li><li className={stage==='review'?'current':''} aria-current={stage==='review'?'step':undefined}><span>2</span><b>Review &amp; place order</b></li><li className="after"><span>3</span><b>Pay by bank transfer</b><small>after ordering</small></li></ol>
    <form className="checkout-layout" onSubmit={submit}>
      <section>
        {stage === 'delivery' ? <div className="panel"><div className="panel-heading"><h2>Delivery details</h2><span className="signed-in-note"><ShieldCheck size={16}/>Signed in</span></div><div className="form-grid">{[['name','Full name',100],['phone','Phone number',20],['line1','Delivery address',300],['city','City',80],['postcode','Postcode',5]].map(([key,text,max]) => <Field key={key} label={text} className={key === 'line1' ? 'full' : ''}><input name={key} required minLength={key === 'line1' ? 8 : 2} maxLength={max} autoComplete={{name:'name',phone:'tel',line1:'street-address',city:'address-level2',postcode:'postal-code'}[key]} value={address[key]} inputMode={key === 'phone' ? 'tel' : key === 'postcode' ? 'numeric' : 'text'} onChange={e => setAddress({...address,[key]:e.target.value})}/></Field>)}<Field label="State / territory"><select autoComplete="address-level1" value={address.state} onChange={e => setAddress({...address,state:e.target.value})}>{STATES.map(s => <option key={s}>{s}</option>)}</select></Field></div>{task.error ? <Notice type="error">{task.error}</Notice> : null}<div className="checkout-stage-actions"><Link to="/cart" go={go} className="text-link"><ArrowLeft size={17}/>Back to cart</Link><Button type="submit">Continue to review <ArrowRight size={18}/></Button></div></div> : <>
          <div className="panel delivery-review"><div className="panel-heading"><h2>Delivery address</h2><Button type="button" variant="secondary small" onClick={() => changeStage('delivery')}>Edit address</Button></div><b>{address.name}</b><p>{address.line1}<br/>{address.postcode} {address.city}, {address.state}<br/>{address.phone}</p></div>
          <div className="panel payment-explainer"><span className="eyebrow">WHAT HAPPENS AFTER YOU PLACE THE ORDER?</span><h2>Pay by manual bank transfer</h2><ol className="payment-mini-steps"><li><b>Get your instructions</b><span>Your order page shows the bank account and exact amount.</span></li><li><b>Transfer and submit the reference</b><span>Make your transfer, then add its reference and an optional receipt.</span></li><li><b>We verify and prepare</b><span>The store checks the deposit before preparing your order.</span></li></ol><Notice>Nothing is charged automatically. Unpaid reservations expire after 24 hours. If a reservation has expired, contact the seller before transferring.</Notice><label className="checkbox"><input type="checkbox" required checked={accepted} onChange={e => setAccepted(e.target.checked)}/>I checked the item specifications and understand how bank-transfer payment works.</label></div>
        </>}
      </section>
      {totals ? <button type="button" className="checkout-total-bar" onClick={() => document.getElementById('order-summary')?.scrollIntoView({behavior:'smooth',block:'start'})}><span>Order total</span><b>{money(totals.total_cents)}</b><em>View summary</em></button> : null}
      <aside id="order-summary" className="panel order-summary"><div className="panel-heading"><h2>Your order</h2><Link to="/cart" go={go} className="text-link">Edit cart</Link></div><div className="checkout-items">{cart.map(i => {const p=data.products.find(p=>p.id===i.product_id);return <div key={i.product_id}><span><b>{i.quantity} ×</b> {p?.name || 'Unavailable item'}</span><b>{p ? money(i.quantity*p.price_cents) : '—'}</b></div>;})}</div><details className="promotion-disclosure"><summary>Have a promotion code?</summary><div className="coupon-row"><input aria-label="Promotion code" maxLength={30} placeholder="Enter code" value={code} onChange={e=>setCode(e.target.value.toUpperCase())} onKeyDown={e=>{if(e.key==='Enter'){e.preventDefault();setApplied(code.trim());task.setError('');}}}/><Button type="button" variant="secondary small" onClick={()=>{setApplied(code.trim());task.setError('');}}>Apply</Button>{applied ? <Button type="button" variant="secondary small" onClick={()=>{setCode('');setApplied('');}}>Remove</Button> : null}</div></details>{error ? <Notice type="error">{error}</Notice> : <Totals totals={totals}/>}<p className="summary-assurance"><ShieldCheck size={16}/>Full total shown before ordering</p>{!data.settings.checkout_enabled ? <Notice>Checkout is being configured. Contact the seller for help.</Notice> : null}{stage === 'review' ? <>{task.error ? <Notice type="error">{task.error}</Notice> : null}<Button type="submit" className="full-width" busy={task.busy} disabled={Boolean(error)||!data.settings.checkout_enabled}>Place order <ArrowRight size={18}/></Button><p className="muted">Next: bank details and transfer instructions.</p></> : <p className="muted">Next: review your address and confirm the order.</p>}</aside>
    </form>
  </main>;
}

export function OrderGuidance({order, staff, refund}) {
  const {go} = useApp();
  let title, text, action;
  if(refund?.status === 'paid') {title='Your refund has been recorded';text='Open the refund details below to see the recorded transfer reference.';}
  else if(order.status === 'cancelled') {title='This order is cancelled';text='There is no further payment step for this order.';}
  else if(refund && ['requested','approved'].includes(refund.status)) {title=staff ? 'A refund is being reviewed' : 'Your refund request is being handled';text='Approval and the completed bank transfer are separate steps. See the refund details below.';}
  else if(['awaiting','rejected'].includes(order.payment_status)) {title=staff ? 'Waiting for the customer’s transfer reference' : order.payment_status === 'rejected' ? 'Your payment details need attention' : 'Next: complete your bank transfer';text=staff ? 'The customer must submit transfer details before you can verify the deposit.' : 'Check the bank account and exact amount below. After transferring, submit your bank reference for verification.';if(!staff) action='Go to payment instructions';}
  else if(order.payment_status === 'submitted') {title=staff ? 'Next: verify the actual bank deposit' : 'Transfer details received. We’ll check the deposit.';text=staff ? 'Match the amount and bank reference before approving payment. A receipt image alone is not proof of cleared funds.' : 'No further payment submission is needed. The store will update this page after verification.';if(staff) action='Review payment';}
  else if(order.status === 'processing') {title=staff ? 'Next: prepare and dispatch the order' : 'Payment verified. Your order is being prepared.';text=staff ? 'Pack the items, then record the actual carrier and tracking number.' : 'Shipping details will appear here when your parcel is dispatched.';if(staff) action='Record shipment details';}
  else if(!order.received_at) {title=staff ? 'Order dispatched' : 'Your order is on its way';text=staff ? 'Carrier details are recorded below. The buyer confirms receipt to unlock reviews.' : 'Check the tracking details below. Confirm receipt only once your items have arrived.';if(!staff) action='Go to receipt confirmation';}
  else {title='Order received. Thank you!';text=staff ? 'The buyer has confirmed receipt. You can respond to their feedback from Customer feedback.' : 'You can now review each purchased item below, or contact the seller if you need help.';}
  const current=order.received_at ? 4 : ['shipped','delivered'].includes(order.status) ? 3 : order.payment_status === 'verified' ? 2 : order.payment_status === 'submitted' ? 1 : 0;
  return <section className="order-guidance" aria-label="Order progress and next action"><div className="next-action-card"><span className="next-action-icon">{order.received_at ? <Check/> : <Package/>}</span><div><span className="eyebrow">{staff ? 'WHAT TO DO NEXT' : 'YOUR ORDER UPDATE'}</span><h2>{title}</h2><p>{text}</p></div>{action ? <Button variant="secondary" onClick={()=>{const target=document.getElementById('order-actions');target?.scrollIntoView({behavior:'smooth',block:'start'});target?.focus({preventScroll:true});}}>{action}<ArrowRight size={17}/></Button> : !staff ? <Link className="text-link" to="/messages" go={go}>Need help?<MessageCircle size={17}/></Link> : null}</div>{order.status !== 'cancelled' ? <ol className="order-progress" aria-label="Order timeline">{['Order placed','Transfer submitted','Payment verified','Dispatched','Received'].map((name,index)=><li key={name} className={index<=current ? 'complete' : ''} aria-current={index===current ? 'step' : undefined}><span>{index<=current ? <Check size={15}/> : index+1}</span><b>{name}</b></li>)}</ol> : null}</section>;
}

export function OrderListNext({order, staff}) {
  let text;
  if(order.status==='cancelled') text='Cancelled — no further payment step.';
  else if(order.payment_status==='submitted') text=staff?'Next: verify the deposit in the business bank account.':'Next: the store will verify your transfer.';
  else if(['awaiting','rejected'].includes(order.payment_status)) text=staff?'Waiting for the customer’s bank-transfer submission.':'Next: open this order for bank details and submit your transfer reference.';
  else if(order.status==='processing') text=staff?'Next: prepare the order and record its shipment.':'Next: the store will prepare and dispatch your order.';
  else if(!order.received_at) text=staff?'The buyer can confirm receipt after delivery.':'Next: track the parcel and confirm receipt when it arrives.';
  else text=staff?'Received by the buyer. Feedback can now be submitted.':'Received — you can now review your purchased items.';
  return <p className="order-list-next"><ChevronRight size={16}/>{text}</p>;
}

export function WorkspaceWelcome() {
  const {profile,data,go} = useApp();
  const pending=data.orders.filter(o=>o.payment_status==='submitted').length;
  const preparing=data.orders.filter(o=>o.status==='processing').length;
  const requested=data.refunds.filter(r=>r.status==='requested').length;
  const unconfirmed=data.products.filter(p=>p.active&&(!p.price_confirmed||p.stock===0)).length;
  const low=data.products.filter(p=>p.active&&p.stock<10).length;
  const setup=profile.role==='admin'&&!data.settings.checkout_enabled;
  return <>
    {setup ? <section className="setup-guide"><div><span className="eyebrow">GET YOUR STORE READY</span><h2>A few checks before your first sale</h2><p>Checkout is currently disabled. Complete these steps before accepting orders.</p></div><div className="setup-links"><Link to="/workspace/products" go={go}><span>1</span><div><b>Confirm products and stock</b><small>{unconfirmed} active items need a confirmed price or available stock</small></div><ChevronRight size={18}/></Link><Link to="/workspace/settings" go={go}><span>2</span><div><b>Add bank and delivery details</b><small>Check your account, charges and return policy</small></div><ChevronRight size={18}/></Link><Link to="/workspace/settings" go={go}><span>3</span><div><b>Enable checkout when ready</b><small>Only confirmed, stocked products can be purchased</small></div><ChevronRight size={18}/></Link></div></section> : null}
    <section className="work-queue" aria-label="Priority tasks">{[[pending,'Verify payments','Check the actual bank deposit','/workspace/orders?payment=submitted',CreditCard],[preparing,'Prepare orders','Pack items and record shipment','/workspace/orders?status=processing',Package],[requested,'Review refunds','Check eligibility and returned goods','/workspace/refunds',ClipboardCheck],[low,'Restock items','Products with fewer than 10 units','/workspace/restock',Boxes]].map(([count,title,text,to,Icon])=><Link key={title} to={to} go={go}><Icon size={23}/><div><b>{title}<span>{count}</span></b><small>{text}</small></div><ArrowRight size={18}/></Link>)}</section>
  </>;
}
