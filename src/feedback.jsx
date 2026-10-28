import React, {useEffect, useRef} from 'react';
import {AlertCircle, ArrowRight, CheckCircle2, Info, ShoppingBag, X} from 'lucide-react';
import {useApp} from './context.jsx';
import {Button, Confirm, Modal} from './components.jsx';
import {SuccessMark} from './visuals.jsx';

function ToastItem({item,dismiss}) {
  const {go}=useApp(),timer=useRef(null),remaining=useRef(item.type==='error'?12000:8500),started=useRef(0);
  const close=()=>dismiss(item.id);
  const resume=()=>{if(timer.current)return;started.current=Date.now();timer.current=setTimeout(close,remaining.current);};
  const pause=()=>{if(!timer.current)return;clearTimeout(timer.current);timer.current=null;remaining.current=Math.max(0,remaining.current-(Date.now()-started.current));};
  useEffect(()=>{resume();return()=>clearTimeout(timer.current);},[]);
  const Icon=item.type==='error'?AlertCircle:item.text==='Added to your cart.'?ShoppingBag:item.type==='success'?CheckCircle2:Info;
  const action=item.action||(item.text==='Added to your cart.'?{label:'View cart',onClick:()=>go('/cart')}:null);
  return <div className={'toast '+item.type} role={item.type==='error'?'alert':'status'} aria-atomic="true" onMouseEnter={pause} onMouseLeave={resume} onFocusCapture={pause} onBlurCapture={e=>{if(!e.currentTarget.contains(e.relatedTarget))resume();}}><Icon size={21} aria-hidden="true"/><div className="toast-copy"><b>{item.text}</b>{item.detail?<p>{item.detail}</p>:null}{action?<button className="toast-action" onClick={()=>{action.onClick();close();}}>{action.label}<ArrowRight size={14}/></button>:null}</div><button className="toast-dismiss" aria-label="Dismiss notification" onClick={close}><X size={17}/></button></div>;
}

export function ToastRegion({items,dismiss}) {
  return <div className="toast-region" aria-label="Action notifications">{items.map(item=><ToastItem key={item.id} item={item} dismiss={dismiss}/>)}</div>;
}

export function ActionDialog({dialog,onClose}) {
  const {cart,setCart,notify,go}=useApp();
  if(dialog.type==='clear-cart')return <Confirm title="Remove all items from your cart?" onClose={onClose} onConfirm={()=>{const saved=cart;setCart([]);notify('Cart cleared.','success',{action:{label:'Undo',onClick:()=>setCart(items=>[...items,...saved.filter(old=>!items.some(i=>i.product_id===old.product_id))])}});}}>You can continue browsing and add parts again. Your placed orders are unaffected.</Confirm>;
  if(dialog.type==='order-placed')return <Modal title="Your order is placed" onClose={onClose}><div className="success-state"><SuccessMark/><span className="eyebrow">ORDER SAVED · PAYMENT COMES NEXT</span><h3>One more step: your bank transfer.</h3><p>Your order page shows the exact amount and bank account. After transferring, submit your reference so the store can verify the deposit.</p><Button className="full-width" onClick={()=>{onClose();requestAnimationFrame(()=>{document.getElementById('order-actions')?.scrollIntoView({behavior:'smooth',block:'start'});document.getElementById('order-actions')?.focus({preventScroll:true});});}}>View payment instructions <ArrowRight size={18}/></Button><small>No money has been charged automatically.</small></div></Modal>;
  if(dialog.type==='registration-success')return <Modal title={dialog.confirmationRequired?'Check your email':'Your account is ready'} onClose={onClose}><div className="success-state"><SuccessMark/><span className="eyebrow">{dialog.confirmationRequired?'CONFIRM YOUR EMAIL TO CONTINUE':'WELCOME TO GEARLANE'}</span><h3>{dialog.confirmationRequired?'A quick check, then you’re in.':'A smoother next service starts here.'}</h3><p>{dialog.confirmationRequired?<>Check <b>{dialog.email}</b> for account confirmation instructions. Confirm your email, then sign in to continue. Delivery may take a moment; check your spam folder too.</>:'Save parts, track your orders and talk to the store from one account.'}</p>{dialog.preview?<p className="preview-success-note">Local preview only: future sign-in for this demo account uses <b>DemoCustomer123!</b>.</p>:null}<Button className="full-width" onClick={()=>{onClose();go(dialog.confirmationRequired?'/account':cart.length?'/cart':'/shop');}}>{dialog.confirmationRequired?'Back to sign in':cart.length?'Continue to your cart':'Start browsing'}<ArrowRight size={18}/></Button></div></Modal>;
  return null;
}
