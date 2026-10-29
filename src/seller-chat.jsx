import React,{useEffect,useId,useRef,useState} from 'react';
import {ArrowLeft,Maximize2,MessageCircle,Minimize2,Minus} from 'lucide-react';
import {useApp} from './context.jsx';
import {MessagesPage,SupportCompose} from './chat-page.jsx';

export function SellerChat({open,product,conversationId,onClose,onOpened,onClearProduct,onBusyChange}){
 const {data}=useApp(),ref=useRef(null),titleId=useId();
 const [mobile,setMobile]=useState(()=>matchMedia('(max-width:760px)').matches),[expanded,setExpanded]=useState(false);
 const full=mobile||expanded;
 useEffect(()=>{const media=matchMedia('(max-width:760px)'),change=()=>setMobile(media.matches);media.addEventListener('change',change);return()=>media.removeEventListener('change',change);},[]);
 useEffect(()=>{
  if(!open||!mobile||!window.visualViewport)return;
  const viewport=window.visualViewport,update=()=>{ref.current?.style.setProperty('--seller-chat-height',viewport.height+'px');ref.current?.style.setProperty('--seller-chat-top',viewport.offsetTop+'px');};
  update();viewport.addEventListener('resize',update);viewport.addEventListener('scroll',update);
  return()=>{viewport.removeEventListener('resize',update);viewport.removeEventListener('scroll',update);ref.current?.style.removeProperty('--seller-chat-height');ref.current?.style.removeProperty('--seller-chat-top');};
 },[open,mobile]);
 useEffect(()=>{
  const element=ref.current;if(!open){element?.close();return;}
  const previous=document.activeElement,overflow=document.body.style.overflow;
  if(element.open)element.close();
  if(full){element.showModal();document.body.style.overflow='hidden';}else element.show();
  const frame=requestAnimationFrame(()=>element.querySelector('textarea:not([readonly]),button')?.focus({preventScroll:true}));
  return()=>{cancelAnimationFrame(frame);element.close();if(full)document.body.style.overflow=overflow;if(previous?.isConnected)previous.focus({preventScroll:true});};
 },[open,full]);
 // Keep the conversation mounted when minimised: drafts and in-flight sends survive.
 return <dialog id="seller-chat" ref={ref} className={'seller-chat-window '+(full?'full-screen':'')} aria-labelledby={titleId} aria-modal={full?'true':undefined} onCancel={e=>{e.preventDefault();onClose();}} onKeyDown={e=>{if(e.key==='Escape'){e.preventDefault();onClose();}}}>
  <header className="seller-chat-header"><span className="seller-chat-avatar"><MessageCircle size={23}/></span><div><h2 id={titleId}>Chat with the seller</h2><p>{data.settings.store_name} support</p></div><div className="seller-chat-window-actions">{!mobile?<button className="icon-button" aria-label={expanded?'Restore chat window':'Expand chat'} onClick={()=>setExpanded(v=>!v)}>{expanded?<Minimize2 size={18}/>:<Maximize2 size={18}/>}</button>:null}<button className="icon-button" aria-label={mobile?'Back to store':'Minimise chat'} onClick={onClose}>{mobile?<ArrowLeft size={21}/>:<Minus size={21}/>}</button></div></header>
  {product?<div className="seller-chat-product-pane"><SupportCompose key={product.id} product={product} embedded onClose={onClearProduct} onOpened={onOpened} onBusyChange={onBusyChange}/></div>:null}
  <div className="seller-chat-conversation-pane" hidden={Boolean(product)}><MessagesPage embedded active={open&&!product} conversationId={conversationId} onBusyChange={onBusyChange}/></div>
 </dialog>;
}
