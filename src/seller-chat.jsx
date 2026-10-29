import React,{useEffect,useId,useRef,useState} from 'react';
import {ArrowLeft,Maximize2,MessageCircle,Minimize2,Minus,MoreVertical} from 'lucide-react';
import {useApp} from './context.jsx';
import {MessagesPage,SupportCompose} from './chat-page.jsx';

export function SellerChat({open,product,conversationId,onClose,onOpened,onClearProduct,onBusyChange}){
 const {data}=useApp(),ref=useRef(null),titleId=useId();
 const [mobile,setMobile]=useState(()=>matchMedia('(max-width:760px)').matches),[expanded,setExpanded]=useState(false),[optionsOpen,setOptionsOpen]=useState(false);
 useEffect(()=>{if(!open||product)setOptionsOpen(false);},[open,product]);
 const dismiss=()=>{if(optionsOpen)setOptionsOpen(false);else onClose();};
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
 return <dialog id="seller-chat" ref={ref} className={'seller-chat-window '+(full?'full-screen':'')} aria-labelledby={titleId} aria-modal={full?'true':undefined} onCancel={e=>{e.preventDefault();dismiss();}} onKeyDown={e=>{if(e.key==='Escape'){e.preventDefault();dismiss();}}}>
  <header className="seller-chat-header">{mobile?<button className="icon-button seller-chat-back" aria-label="Back to store" onClick={dismiss}><ArrowLeft size={21}/></button>:<span className="seller-chat-avatar"><MessageCircle size={23}/></span>}<div><h2 id={titleId}>{mobile?data.settings.store_name:'Chat with the seller'}</h2>{!mobile?<p>{data.settings.store_name} support</p>:null}</div><div className="seller-chat-window-actions">{!product?<button className="icon-button" aria-label="Chat options" aria-expanded={optionsOpen} aria-controls="seller-chat-options" onClick={()=>setOptionsOpen(v=>!v)}><MoreVertical size={21}/></button>:null}{!mobile?<><button className="icon-button" aria-label={expanded?'Restore chat window':'Expand chat'} onClick={()=>setExpanded(v=>!v)}>{expanded?<Minimize2 size={18}/>:<Maximize2 size={18}/>}</button><button className="icon-button" aria-label="Minimise chat" onClick={onClose}><Minus size={21}/></button></>:null}</div></header>
  {product?<div className="seller-chat-product-pane"><SupportCompose key={product.id} product={product} embedded onClose={onClearProduct} onOpened={onOpened} onBusyChange={onBusyChange}/></div>:null}
  <div className="seller-chat-conversation-pane" hidden={Boolean(product)}><MessagesPage embedded active={open&&!product} conversationId={conversationId} onBusyChange={onBusyChange} optionsOpen={optionsOpen} onCloseOptions={()=>setOptionsOpen(false)}/></div>
 </dialog>;
}
