import React, {useEffect, useId, useRef, useState} from 'react';
import {ArrowRight, Check, ChevronRight, Eye, EyeOff, Heart, MessageCircle, Package, Search, ShieldCheck, ShoppingBag, Truck, Wrench} from 'lucide-react';
import {useApp,useTask} from './context.jsx';
import {Button,Field,Link,Notice,ProductArt} from './components.jsx';
import {friendlyError,label,money,signUpSchema} from './domain.mjs';
import {GarageScene,SuccessMark} from './visuals.jsx';
import {PromotionCarousel} from './promotion-banners.jsx';
import {ServiceShowcase,CategoryGlyph,PageReveals} from './storefront-motion.jsx';

export function CatalogueSearch() {
  const {data,go,route}=useApp(),id=useId(),root=useRef(null);
  const [query,setQuery]=useState(''),[open,setOpen]=useState(false),[active,setActive]=useState(-1);
  useEffect(()=>{setOpen(false);setActive(-1);if(route.startsWith('/shop'))setQuery(new URLSearchParams(route.split('?')[1]).get('q')||'');},[route]);
  const results=query.trim().length>=2?(data?.products||[]).filter(p=>p.active&&(p.name+' '+p.sku+' '+p.brand).toLowerCase().includes(query.trim().toLowerCase())).slice(0,5):[];
  const search=()=>{setOpen(false);go('/shop'+(query.trim()?'?q='+encodeURIComponent(query.trim()):''));};
  return <form className="header-search smart-search" role="search" ref={root} onSubmit={e=>{e.preventDefault();search();}} onBlur={e=>{if(!root.current?.contains(e.relatedTarget))setOpen(false);}}><Search size={20}/><input name="q" type="search" maxLength={150} value={query} placeholder="Search parts, brands or part numbers" aria-label="Search the catalogue" role="combobox" aria-expanded={open&&results.length>0} aria-autocomplete="list" aria-controls={id} aria-activedescendant={open&&active>=0&&results[active]?id+'-'+active:undefined} onFocus={()=>setOpen(true)} onChange={e=>{setQuery(e.target.value);setOpen(true);setActive(-1);}} onKeyDown={e=>{if(e.key==='Enter'&&open&&results[active]){e.preventDefault();setOpen(false);go('/products/'+results[active].id);}if(e.key==='Escape'){setOpen(false);setActive(-1);}if(e.key==='ArrowDown'&&results.length){e.preventDefault();setOpen(true);setActive(i=>(i+1)%results.length);}if(e.key==='ArrowUp'&&results.length){e.preventDefault();setActive(i=>(i-1+results.length)%results.length);}}}/><button type="submit" aria-label="Search parts">Search<ArrowRight size={15}/></button>
    {open&&results.length?<div className="search-suggestions"><span className="suggestions-heading">Matching parts</span><div id={id} role="listbox" aria-label="Matching products">{results.map((p,index)=><div key={p.id} id={id+'-'+index} role="option" aria-selected={active===index} className={active===index?'active':''} onMouseDown={e=>e.preventDefault()} onClick={()=>{setOpen(false);go('/products/'+p.id);}}><ProductArt product={p}/><span><b>{p.name}</b><small>{p.sku} · {p.category}</small></span><ChevronRight size={17}/></div>)}</div><button type="button" className="search-all" onClick={search}>View all results for “{query}”<ArrowRight size={15}/></button></div>:null}
  </form>;
}

export function CustomerHome({ProductCard}) {
  const {data,profile,go,openSupport,setDialog}=useApp();
  const products=data.products.filter(p=>p.active),categoryOrder=['Engine Oil','Brake Pads','Filters','Wipers','Transmission Fluid','Coolant','Spark Plugs','Brake Fluid'];
  const categories=[...new Set([...categoryOrder.filter(c=>products.some(p=>p.category===c)),...products.map(p=>p.category)])];
  const [expanded,setExpanded]=useState(false);
  const readyFirst=[...products].sort((a,b)=>Number(b.price_confirmed&&b.stock>0)-Number(a.price_confirmed&&a.stock>0));
  const varied=categories.map(c=>readyFirst.find(p=>p.category===c)).filter(Boolean);
  const featured=[...varied,...readyFirst.filter(p=>!varied.some(v=>v.id===p.id))].slice(0,8);
  const awaiting=data.orders?.find(o=>o.customer_id===profile?.id&&o.status==='awaiting_payment'&&['awaiting','rejected'].includes(o.payment_status));
  return <main className="customer-home"><PromotionCarousel/>
    <ServiceShowcase products={products}/><PageReveals/>
    <section className="container customer-benefits"><div><Wrench/><span><b>Get the fit right</b><small>Ask about your vehicle and part number</small></span></div><div><ShieldCheck/><span><b>Review before you pay</b><small>See your complete total at checkout</small></span></div><div><Package/><span><b>Know what’s next</b><small>Follow payment and delivery in My orders</small></span></div></section>
    {awaiting?<section className="container resume-order"><Package size={25}/><div><b>Your order has a next step</b><p>GL-{awaiting.order_number} is waiting for your bank-transfer details.</p></div><Link to={'/orders/'+awaiting.id} go={go} className="button secondary">Continue your order<ArrowRight size={17}/></Link></section>:null}
    <section className="container section category-section"><div className="section-heading"><div><span className="eyebrow">START WITH THE PART YOU NEED</span><h2>What’s on your service list?</h2></div><Link to="/shop" go={go} className="text-link">All parts <ArrowRight size={17}/></Link></div><div className="customer-category-grid">{categories.slice(0,expanded?categories.length:6).map(category=><Link key={category} className="customer-category" to={'/shop?category='+encodeURIComponent(category)} go={go}><CategoryGlyph category={category}/><div><b>{category}</b><span>{products.filter(p=>p.category===category).length} parts</span></div><ArrowRight size={17}/></Link>)}</div>{categories.length>6?<button className="category-expand" onClick={()=>setExpanded(!expanded)} aria-expanded={expanded}>{expanded?'Show fewer categories':'See all '+categories.length+' categories'}<ChevronRight size={16}/></button>:null}</section>
    <section className="container section home-products"><div className="section-heading"><div><span className="eyebrow">SMALL PARTS. IMPORTANT JOBS.</span><h2>Service essentials, all in one place.</h2><p>Check the details. Choose your quantity. We’ll guide you from there.</p></div><Link to="/shop" go={go} className="text-link">Shop all parts <ArrowRight size={17}/></Link></div>{products.some(p=>!p.price_confirmed)?<Notice>Items marked “Check price first” need the store to confirm its price and stock. Use “Ask for price” to start a conversation.</Notice>:null}<div className="product-grid">{featured.map(p=><ProductCard key={p.id} product={p}/>)}</div></section>
    <section className="container order-explained"><div><span className="eyebrow">YOUR FIRST ORDER, MADE CLEAR</span><h2>From finding a part<br/> to getting it to your door.</h2><button className="text-link" onClick={()=>setDialog({type:'shopping-guide'})}>See how it works <ArrowRight size={17}/></button></div><ol>{[['01','Find and check','Search your part, check the specification and ask us if you’re unsure.'],['02','Review and order','Check quantities, delivery details and the total before placing your order.'],['03','Transfer and track','Follow the bank instructions on your order, then track its progress.']].map(([number,title,text])=><li key={number}><span>{number}</span><div><b>{title}</b><p>{text}</p></div></li>)}</ol></section>
    {data.announcements.some(a=>a.active)?<section className="container store-updates">{data.announcements.filter(a=>a.active).slice(0,2).map(a=><article key={a.id}><span className="eyebrow">FROM THE STORE</span><h3>{a.title}</h3><p>{a.body}</p></article>)}</section>:null}
    <section className="container human-help"><div className="human-help-icon"><MessageCircle size={37}/></div><div><span className="eyebrow">A REAL PERSON. A HELPFUL ANSWER.</span><h2>Not sure which part fits?</h2><p>Send us your vehicle model, year and engine code. Attach a product to your chat and we’ll help you check.</p></div><Button onClick={()=>openSupport(null)}>Talk to the seller <ArrowRight size={18}/></Button></section>
  </main>;
}

export function CategoryChips() {
  const {data,route,go}=useApp(),params=new URLSearchParams(route.split('?')[1]),selected=params.get('category')||'';
  const categories=[...new Set(data.products.filter(p=>p.active).map(p=>p.category))];
  return <nav className="category-chips" aria-label="Product categories">{['',...categories].map(category=><button key={category} className={selected===category?'selected':''} aria-pressed={selected===category} onClick={()=>{const next=new URLSearchParams(params);if(category)next.set('category',category);else next.delete('category');next.delete('page');go('/shop'+(next.size?'?'+next:''),{preserveScroll:true});}}>{category==='Filters'?'Filter parts':category||'All categories'}</button>)}</nav>;
}

export function MobileProductBar({product,quantity}) {
  const {addToCart,openSupport,profile}=useApp();
  if(profile&&profile.role!=='customer')return null;
  const ready=product.price_confirmed&&product.stock>0;
  return <div className="mobile-product-bar"><div><small>{product.price_confirmed?'Selling price':'Reference price'}</small><b>{money(product.price_cents)}</b></div><Button aria-label={ready?'Add to cart from quick bar':'Ask about this item from quick bar'} onClick={()=>ready?addToCart(product,quantity):openSupport(product)}>{ready?<><ShoppingBag size={18}/>Add to cart</>:<><MessageCircle size={18}/>Ask the seller</>}</Button></div>;
}

export function AccountShortcuts() {
  const {profile,data,go}=useApp();
  if(profile.role!=='customer')return null;
  return <nav className="account-shortcuts" aria-label="Your account shortcuts">{[['/orders','Your orders',data.orders.length+' recent orders',Package],['/wishlist','Saved parts',(data.wishlist?.length||0)+' saved items',Heart],['/messages','Messages','Talk to the store',MessageCircle]].map(([to,title,detail,Icon])=><Link key={to} to={to} go={go}><Icon size={22}/><span><b>{title}</b><small>{detail}</small></span><ChevronRight size={16}/></Link>)}</nav>;
}

export function AccountExperience({ProfileComponent}) {
  const {profile,repository,preview,go,route,afterSignIn,notify,setDialog}=useApp(),task=useTask();
  const [mode,setMode]=useState('signin'),[values,setValues]=useState({name:'',email:'',password:'',phone:'',business_type:'personal'}),[errors,setErrors]=useState({}),[showPassword,setShowPassword]=useState(false),[recoverySent,setRecoverySent]=useState(false);
  const params=new URLSearchParams(route.split('?')[1]);
  const change=(key,value)=>{setValues(v=>({...v,[key]:value}));setErrors(e=>({...e,[key]:undefined}));task.setError('');};
  const changeMode=next=>{setMode(next);setErrors({});setRecoverySent(false);task.setError('');};
  const submit=async e=>{
    e.preventDefault();let valid={...values,email:values.email.trim()};
    if(mode==='signup'){
      const checked=signUpSchema.safeParse(valid);
      if(!checked.success){setErrors(Object.fromEntries(checked.error.issues.map(i=>[i.path[0],i.message])));return;}
      valid=checked.data;
    }else if(!signUpSchema.shape.email.safeParse(valid.email).success){setErrors({email:'Enter a valid email address.'});return;}else if(mode==='signin'&&!valid.password){setErrors({password:'Enter your password.'});return;}
    const result=await task.perform(()=>{if(mode==='reset')return repository.resetPassword(valid.email);afterSignIn();return mode==='signup'?repository.signUp(valid):repository.signIn(valid.email,valid.password);});
    if(!result.ok)return;
    if(mode==='reset'){setRecoverySent(true);notify('Recovery request received.','success',{detail:'If an eligible account exists, check its inbox for instructions.'});return;}
    if(mode==='signup'){
      setDialog({type:'registration-success',confirmationRequired:Boolean(result.value?.confirmationRequired),email:valid.email,preview});
      if(result.value?.confirmationRequired){changeMode('signin');return;}
    }else notify('You’re signed in.','success',{detail:'Your account and saved cart are ready.'});
    try{const user=await repository.session();if(user){const p=await repository.profile(user.id),next=params.get('next');go(p.role!=='customer'?'/workspace':next?.startsWith('/')&&!next.startsWith('//')?next:route.startsWith('/checkout')?'/checkout':'/shop');}}
    catch(error){notify(friendlyError(error),'error');}
  };
  if(profile&&params.get('reset')==='1')return <PasswordReset/>;
  if(profile)return <ProfileComponent/>;
  return <main className="container account-experience"><section className="account-story"><span className="eyebrow">A LITTLE LESS ADMIN. A LOT MORE CLARITY.</span><h1>Your parts.<br/> Your orders.<br/> <em>All together.</em></h1><p>Keep your next service organised, from the first question to the delivery.</p><ul><li><Heart/><span><b>Save what you need</b><small>Keep a wishlist for your next service.</small></span></li><li><Package/><span><b>Follow every step</b><small>See payment, preparation and delivery updates.</small></span></li><li><MessageCircle/><span><b>Ask a real person</b><small>Send a product straight to the store team.</small></span></li></ul><div className="account-story-footer"><ShieldCheck size={17}/>Staff use the same sign-in with their assigned access.</div></section>
    <section className="panel auth-panel"><div className="auth-mode-tabs" role="tablist" aria-label="Account access"><button role="tab" type="button" disabled={task.busy} aria-selected={mode!=='signup'} onClick={()=>changeMode('signin')}>Sign in</button><button role="tab" type="button" disabled={task.busy} aria-selected={mode==='signup'} onClick={()=>changeMode('signup')}>Create account</button></div><span className="eyebrow">{mode==='signup'?'LET’S GET YOU STARTED':mode==='reset'?'BACK TO YOUR ACCOUNT':'GOOD TO SEE YOU'}</span><h2>{mode==='signup'?'Make your next service easier.':mode==='reset'?'Forgot your password?':'Welcome back.'}</h2><p className="auth-description">{mode==='signup'?'Create a customer account to save parts, place orders and get support.':mode==='reset'?'Enter your account email and we’ll request recovery instructions.':'Sign in to pick up where you left off.'}</p>{route.startsWith('/checkout')?<Notice>Your cart is saved. Sign in or create an account to continue checkout.</Notice>:null}
      {recoverySent?<div className="recovery-sent"><SuccessMark/><h3>Check your inbox</h3><p>If this email belongs to an eligible account, recovery instructions will be sent. Check your spam folder too.</p><Button variant="secondary" onClick={()=>changeMode('signin')}>Back to sign in</Button></div>:<form onSubmit={submit} noValidate>
        {mode==='signup'?<Field label="Full name" error={errors.name}><input required maxLength={100} autoComplete="name" disabled={task.busy} value={values.name} onChange={e=>change('name',e.target.value)}/></Field>:null}
        <Field label="Email address" error={errors.email}><input type="email" required maxLength={254} autoComplete="email" disabled={task.busy} value={values.email} onChange={e=>change('email',e.target.value)}/></Field>
        {mode!=='reset'?<div className="password-control"><Field label="Password" error={errors.password} hint={mode==='signup'?'Use at least 12 characters. Avoid a password you use elsewhere.':undefined}><input type={showPassword?'text':'password'} required minLength={mode==='signup'?12:1} maxLength={128} autoComplete={mode==='signup'?'new-password':'current-password'} disabled={task.busy} value={values.password} onChange={e=>change('password',e.target.value)}/></Field><button type="button" aria-label={showPassword?'Hide password':'Show password'} aria-pressed={showPassword} onClick={()=>setShowPassword(!showPassword)}>{showPassword?<EyeOff size={19}/>:<Eye size={19}/>}</button></div>:null}
        {mode==='signup'?<><Field label="Phone number" error={errors.phone}><input type="tel" required maxLength={20} autoComplete="tel" disabled={task.busy} value={values.phone} onChange={e=>change('phone',e.target.value)}/></Field><Field label="I’m buying for"><select disabled={task.busy} value={values.business_type} onChange={e=>change('business_type',e.target.value)}>{['personal','workshop','retailer','distributor'].map(v=><option key={v} value={v}>{label(v)}</option>)}</select></Field></>:null}
        {task.error?<Notice type="error">{task.error}</Notice>:null}<Button type="submit" className="full-width" busy={task.busy}>{task.busy?mode==='signup'?'Creating your account…':'Please wait…':mode==='signup'?'Create account':mode==='reset'?'Send recovery instructions':'Sign in'}<ArrowRight size={18}/></Button>
      </form>}
      {!recoverySent?<button className="text-button recovery-link" onClick={()=>changeMode(mode==='reset'?'signin':'reset')}>{mode==='reset'?'Back to sign in':'Forgot password?'}</button>:null}
      {preview?<details className="preview-account-options"><summary>Try the local demo accounts</summary><div className="preview-accounts"><b>Local preview accounts</b>{[['customer','DemoCustomer123!'],['worker','DemoWorker123!'],['admin','DemoAdmin123!']].map(([role,password])=><button key={role} onClick={()=>{changeMode('signin');setValues(v=>({...v,email:role+'@gearlane.demo',password}));}}><span>{label(role)}<small>{role}@gearlane.demo</small></span><span>Use account <ArrowRight size={13}/></span></button>)}<small>Choose an account, then sign in. Preview credentials have no live access.</small></div></details>:null}
    </section>
  </main>;
}

function PasswordReset(){
  const {repository,go}=useApp(),task=useTask(),[password,setPassword]=useState('');
  return <main className="container section narrow"><div className="panel"><span className="eyebrow">ACCOUNT RECOVERY</span><h1>Set a new password</h1><p>Use a unique password with at least 12 characters.</p><form onSubmit={async e=>{e.preventDefault();if(password.length<12){task.setError('Use at least 12 characters.');return;}const result=await task.perform(()=>repository.changePassword(password),'Password updated.');if(result.ok)go('/account');}}><Field label="New password"><input type="password" required minLength={12} maxLength={128} autoComplete="new-password" value={password} onChange={e=>setPassword(e.target.value)}/></Field>{task.error?<Notice type="error">{task.error}</Notice>:null}<Button busy={task.busy}>Update password<ArrowRight size={18}/></Button></form></div></main>;
}
