import React,{useCallback,useEffect,useRef,useState} from 'react';
import {Search,ShoppingBag,Heart,MessageCircle,User,Bell,Menu,X,LogOut,ArrowRight,Wrench,ShieldCheck,Truck,Package,LayoutDashboard,Users,Tag,Megaphone,Settings,ClipboardList,RotateCcw,Star,Boxes} from 'lucide-react';
import {repository,preview,companyName} from './repository.mjs';
import {AppContext} from './context.jsx';
import {Button,Link,Modal,Notice,NotFound} from './components.jsx';
import {friendlyError,money} from './domain.mjs';
import {HomePage,ShopPage,ProductPage,CartPage,CheckoutPage,AccountPage,OrdersPage,OrderPage,SupportCompose,MessagesPage,WishlistPage} from './customer-pages.jsx';
import {WorkspacePage} from './workspace-pages.jsx';
import {StoreChrome,ShoppingGuide} from './experience.jsx';

function useRoute(){const[route,setRoute]=useState(()=>location.pathname+location.search);useEffect(()=>{const handler=()=>setRoute(location.pathname+location.search);window.addEventListener('popstate',handler);return()=>window.removeEventListener('popstate',handler);},[]);const go=useCallback((to,{preserveScroll=false}={})=>{if(!to.startsWith('/')||to.startsWith('//'))return;history.pushState({},'',to);setRoute(to);if(!preserveScroll){window.scrollTo({top:0,behavior:'instant'});setTimeout(()=>document.getElementById('page-main')?.focus(),0);}},[]);return[route,go];}
function useCart(profile){const key='gearlane_cart_'+(profile?.id||'guest'),[state,setState]=useState({key:'',items:[]});useEffect(()=>{let items=[];try{const saved=JSON.parse(localStorage.getItem(key));if(Array.isArray(saved))items=saved.filter(i=>typeof i.product_id==='string'&&Number.isSafeInteger(i.quantity)&&i.quantity>0&&i.quantity<=9999);}catch{}setState({key,items});},[key]);useEffect(()=>{if(state.key===key)try{localStorage.setItem(key,JSON.stringify(state.items));}catch{}},[key,state]);return[state.key===key?state.items:[],fn=>setState(previous=>({key,items:typeof fn==='function'?fn(previous.key===key?previous.items:[]):fn}))];}
export default function App(){
 const[route,go]=useRoute(),[profile,setProfile]=useState(null),[data,setData]=useState(null),[loading,setLoading]=useState(true),[loadError,setLoadError]=useState(''),[revision,setRevision]=useState(0),[toast,setToast]=useState(null),[dialog,setDialog]=useState(null),[mobile,setMobile]=useState(false),[cart,setCart]=useCart(profile),generation=useRef(0),mergeGuest=useRef(false);
 const notify=useCallback((text,type='success')=>setToast({text,type,time:Date.now()}),[]);
 useEffect(()=>{if(!toast)return;const timer=setTimeout(()=>setToast(null),6500);return()=>clearTimeout(timer);},[toast]);
 const refresh=useCallback(async()=>{
  if(!repository){setLoading(false);return;}
  const request=++generation.current;
  try{const user=await repository.session(),p=user?await repository.profile(user.id):null;const snapshot=await repository.snapshot(p);if(request!==generation.current)return;setProfile(p);setData(snapshot);setLoadError('');setRevision(n=>n+1);}
  catch(e){if(request!==generation.current)return;setData(null);setProfile(null);setLoadError(friendlyError(e));throw e;}
  finally{if(request===generation.current)setLoading(false);}
 },[]);
 useEffect(()=>{refresh().catch(()=>{});if(!repository)return;return repository.onAuth((user,event)=>{if(event==='PASSWORD_RECOVERY')go('/account?reset=1');refresh().catch(()=>{});});},[refresh,go]);
 useEffect(()=>{if(!repository)return;let timer;const stop=repository.subscribe(()=>{clearTimeout(timer);timer=setTimeout(()=>refresh().catch(()=>{}),350);});return()=>{clearTimeout(timer);stop();};},[profile?.id,refresh]);
 useEffect(()=>{if(!profile||profile.role!=='customer')return;mergeGuest.current=false;let guest=[];try{guest=JSON.parse(localStorage.getItem('gearlane_cart_guest'))||[];localStorage.removeItem('gearlane_cart_guest');}catch{}if(guest.length)setCart(items=>{const map=new Map(items.map(i=>[i.product_id,{...i}]));guest.forEach(i=>{const found=map.get(i.product_id);if(found)found.quantity=Math.min(9999,found.quantity+i.quantity);else map.set(i.product_id,i);});return[...map.values()];});},[profile?.id,cart.length]);
 useEffect(()=>{setMobile(false);document.title=(route.startsWith('/workspace')?'Workspace · ':'')+(data?.settings.store_name||companyName);},[route,data?.settings.store_name]);
 const activitySession=useRef(crypto.randomUUID());
 const track=useCallback((event,productId=null)=>{if(profile?.role==='customer')repository.rpc('record_event',{p_event:event,p_product_id:productId,p_session_id:activitySession.current}).catch(()=>{});},[profile?.id]);
 useEffect(()=>{if(profile?.role==='customer')track('session_started');},[profile?.id,track]);
 const run=useCallback(async(task,success)=>{const value=await task();await refresh();if(success)notify(success);return value;},[refresh,notify]);
 const addToCart=(p,quantity=1)=>{if(profile&&profile.role!=='customer'){notify('Sign in with a customer account to shop.','error');return false;}if(!p.active||!p.price_confirmed||p.stock<1){notify('This product is not ready for checkout. Ask the store for assistance.','error');return false;}const existing=cart.find(i=>i.product_id===p.id)?.quantity||0;if(!Number.isSafeInteger(quantity)||quantity<1||existing+quantity>p.stock||existing+quantity>9999){notify('Check the quantity and available stock.','error');return false;}setCart(items=>{const found=items.find(i=>i.product_id===p.id);return found?items.map(i=>i.product_id===p.id?{...i,quantity:i.quantity+quantity}:i):[...items,{product_id:p.id,quantity}];});notify('Added to your cart.');return true;};
 const setQuantity=(id,quantity)=>{if(!Number.isSafeInteger(quantity)||quantity<0||quantity>9999){notify('Use a whole quantity from 0 to 9,999.','error');return;}setCart(items=>quantity===0?items.filter(i=>i.product_id!==id):items.map(i=>i.product_id===id?{...i,quantity}:i));};
 const openSupport=product=>{if(!profile){go('/account?next='+encodeURIComponent(location.pathname));return;}if(profile.role!=='customer'){go('/workspace/messages');return;}setDialog({type:'support',product});};
 const context={repository,preview,data,profile,refresh,revision,route,go,notify,run,cart,setCart,addToCart,setQuantity,openSupport,setDialog,track,afterSignIn:()=>{mergeGuest.current=true;}};
 const path=route.split('?')[0],isWorkspace=path.startsWith('/workspace');
 let page;
 if(!repository)page=<main className="fatal"><ShieldCheck size={32}/><h1>Store setup is required.</h1><p>Add the Supabase URL and public key in the Vercel environment, run the database migrations and redeploy. Preview mode must be explicitly enabled for demonstrations.</p></main>;
 else if(loading&&!data)page=<main className="loading-screen"><span className="loading-dot"/><h2>Opening GearLane…</h2><p>Loading the catalogue and your account.</p></main>;
 else if(loadError)page=<main className="fatal"><h1>We couldn’t load the store.</h1><Notice type="error">{loadError}</Notice><p>If this is a new project, confirm that the Supabase setup script has completed. No order has been confirmed by this screen.</p><div className="actions"><Button onClick={()=>{setLoading(true);refresh().catch(()=>{});}}>Try again</Button><Button variant="secondary" onClick={()=>repository.signOut()}>Sign out</Button></div></main>;
 else if(isWorkspace)page=!profile?<AccountPage/>:!['worker','admin'].includes(profile.role)?<main className="fatal"><ShieldCheck size={32}/><h1>Staff access only</h1><p>Your customer account does not have access to these tools.</p><Button onClick={()=>go('/')}>Return to the store</Button></main>:<WorkspacePage/>;
 else if(path==='/')page=<HomePage/>;
 else if(path==='/shop')page=<ShopPage/>;
 else if(path==='/wishlist')page=<WishlistPage/>;
 else if(path.startsWith('/products/')){let id;try{id=decodeURIComponent(path.slice(10));}catch{}page=<ProductPage id={id}/>;}
 else if(path==='/cart')page=<CartPage/>;
 else if(path==='/checkout')page=profile?.role==='customer'?<CheckoutPage/>:<AccountPage/>;
 else if(path==='/account')page=<AccountPage/>;
 else if(path==='/orders')page=profile?<OrdersPage/>:<AccountPage/>;
 else if(path.startsWith('/orders/'))page=profile?<OrderPage id={path.slice(8)}/>:<AccountPage/>;
 else if(path==='/messages')page=profile?<MessagesPage/>:<AccountPage/>;
 else page=<NotFound go={go}/>;
 const brand=data?.settings.store_name||companyName,count=cart.reduce((n,i)=>n+i.quantity,0),wishCount=data?.wishlist?.length||0,unread=data?.notifications?.filter(n=>!n.read_at).length||0;
 return <AppContext.Provider value={context}>
  {preview?<div className="preview-banner"><b>LOCAL PREVIEW</b><span>Sample stock and accounts · no real orders, payments or emails · live mode uses Supabase security</span></div>:null}
  {!isWorkspace?<StoreChrome/>:null}
  <div id="page-main" tabIndex="-1">{page}</div>
  {!isWorkspace&&data?<><section className="service-strip container"><div><ShieldCheck/><span><b>Confirm the right fit</b><small>Ask us before you order</small></span></div><div><Truck/><span><b>Track your order</b><small>Carrier details added by staff</small></span></div><div><MessageCircle/><span><b>Real customer support</b><small>Send a product with your enquiry</small></span></div></section><footer className="store-footer"><div className="container footer-grid"><div><h3>{brand}</h3><p>Automotive parts and service essentials. We’re here to help you confirm the specification before buying.</p><small>Supplier reference information does not guarantee vehicle compatibility.</small></div><div><h4>Explore</h4><Link to="/shop" go={go}>Browse catalogue</Link><Link to="/wishlist" go={go}>Wishlist</Link><Link to="/orders" go={go}>Your orders</Link></div><div><h4>Help & account</h4><Link to="/messages" go={go}>Contact the seller</Link><Link to="/account" go={go}>Manage account</Link><button className="text-button" onClick={()=>setDialog({type:'policy'})}>Returns & delivery</button></div><div><h4>Store team</h4><Link to="/workspace" go={go}>Worker / admin sign in</Link><p>Payments are verified manually. Never share banking passwords or card details in chat.</p></div></div><div className="container footer-bottom"><span>© {new Date().getFullYear()} {brand}</span><span>{preview?'Demonstration environment':'Secure accounts · Prices in MYR'}</span></div></footer><button className="support-fab" onClick={()=>openSupport(null)}><MessageCircle size={19}/><span>Chat with the seller</span></button></>:null}
  {toast?<div className={'toast '+toast.type} role="status"><span>{toast.text}</span>{toast.text==='Added to your cart.'?<button className="toast-action" onClick={()=>{setToast(null);go('/cart');}}>View cart <ArrowRight size={16}/></button>:null}<button aria-label="Dismiss notification" onClick={()=>setToast(null)}><X size={16}/></button></div>:null}
  {dialog?.type==='shopping-guide'?<ShoppingGuide onClose={()=>setDialog(null)}/>:null}
  {dialog?.type==='support'?<SupportCompose product={dialog.product} onClose={()=>setDialog(null)}/>:null}
  {dialog?.type==='notifications'?<Modal title="Your notifications" onClose={()=>setDialog(null)}><Button variant="secondary small" onClick={()=>run(()=>repository.rpc('read_notifications'),'Marked as read.').catch(e=>notify(friendlyError(e),'error'))}>Mark all read</Button><div className="notification-list">{data?.notifications?.length?data.notifications.map(n=><button key={n.id} className={n.read_at?'read':''} onClick={()=>{setDialog(null);go(n.route);}}><b>{n.title}</b><p>{n.body}</p></button>):<p>No notifications yet.</p>}</div></Modal>:null}
  {dialog?.type==='policy'?<Modal title="Returns & delivery" onClose={()=>setDialog(null)}><p>{data.settings.return_policy}</p><p className="muted">Delivery charge: {money(data.settings.shipping_cents)}{data.settings.free_shipping_cents>0?' · Free from '+money(data.settings.free_shipping_cents):''}. The checkout shows the configured total before you place an order.</p><p>For a paid order, submit a refund request from the order page. Approval is separate from a refund transfer being recorded. Ask the team about eligibility before returning a part.</p></Modal>:null}
 </AppContext.Provider>;
}
