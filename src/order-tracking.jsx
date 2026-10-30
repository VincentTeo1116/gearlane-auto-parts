import React,{useEffect,useRef,useState} from 'react';
import {Check,CircleX,Copy,CreditCard,ExternalLink,Package,PackageCheck,ShoppingBag,Truck} from 'lucide-react';
import {carrierSearchUrl,trackerSteps} from './order-logic.mjs';

const ICONS={placed:ShoppingBag,payment:CreditCard,packing:Package,shipped:Truck,received:PackageCheck};
const when=iso=>iso?new Date(iso).toLocaleString('en-MY',{day:'numeric',month:'short',hour:'numeric',minute:'2-digit'}):'';

/* The order's journey as five steps. Done / current / not started is stated in words as well as shown,
   and a date appears only when the order really recorded one. */
export function OrderTracker({order}){
  const tracker=trackerSteps(order);
  if(tracker.cancelled)return <div className="tracker-cancelled" role="status"><CircleX size={22} aria-hidden="true"/><div><b>This order was cancelled{tracker.cancelledAt?' on '+when(tracker.cancelledAt):''}</b>{tracker.reason?<span>Reason: {tracker.reason}</span>:<span>No further payment or delivery is needed.</span>}</div></div>;
  return <ol className="tracker" aria-label="Order progress">{tracker.steps.map(step=>{const Icon=ICONS[step.key];return <li key={step.key} className={'tracker-step '+step.state} aria-current={step.state==='current'?'step':undefined}>
    <span className="tracker-dot" aria-hidden="true">{step.state==='done'?<Check size={18} strokeWidth={3}/>:<Icon size={18}/>}</span>
    <b>{step.name}</b>
    <span className="sr-only">{step.state==='done'?', completed':step.state==='current'?', current step':', not started yet'}</span>
    {step.date?<small className="tracker-date">{when(step.date)}</small>:step.state==='current'&&step.detail?<small className="tracker-detail">{step.detail}</small>:<small className="tracker-date"> </small>}
  </li>;})}</ol>;
}

/* Five thin segments for list cards; the label tells screen readers the same thing */
export function OrderMiniProgress({order}){
  const tracker=trackerSteps(order);
  if(tracker.cancelled)return <div className="mini-progress cancelled" role="img" aria-label="Order cancelled"><i/></div>;
  const done=tracker.steps.filter(s=>s.state==='done').length,current=tracker.steps.find(s=>s.state==='current');
  return <div className="mini-progress" role="img" aria-label={`Progress: ${done} of 5 steps done${current?', now '+current.name.toLowerCase():''}`}>{tracker.steps.map(s=><i key={s.key} className={s.state}/>)}</div>;
}

export function CopyButton({text,label='Copy'}){
  const [copied,setCopied]=useState(false),timer=useRef(null);
  useEffect(()=>()=>clearTimeout(timer.current),[]);
  const copy=async()=>{
    try{await navigator.clipboard.writeText(text);}
    catch{const area=document.createElement('textarea');area.value=text;area.setAttribute('readonly','');area.style.position='fixed';area.style.opacity='0';document.body.appendChild(area);area.select();try{document.execCommand('copy');}catch{/* copying is a convenience only */}area.remove();}
    setCopied(true);clearTimeout(timer.current);timer.current=setTimeout(()=>setCopied(false),2000);
  };
  return <button type="button" className="copy-button" onClick={copy} aria-label={copied?'Copied '+text:label+' '+text}>{copied?<><Check size={14}/>Copied</>:<><Copy size={14}/>Copy</>}<span className="sr-only" role="status">{copied?'Copied to clipboard':''}</span></button>;
}

/* Carrier and tracking number, with one-tap copy and a web search for the parcel */
export function TrackingInfo({order}){
  if(!order.tracking_number)return <p className="muted">Carrier details appear here once the store dispatches your order.</p>;
  const url=carrierSearchUrl(order.carrier,order.tracking_number);
  return <div className="tracking-info"><Truck size={22} aria-hidden="true"/><div><b>{order.carrier||'Carrier'}</b><span>Tracking number <code>{order.tracking_number}</code></span></div><CopyButton text={order.tracking_number} label="Copy tracking number"/>{url?<a className="button secondary small" href={url} target="_blank" rel="noopener noreferrer">Track parcel<ExternalLink size={14}/></a>:null}</div>;
}
