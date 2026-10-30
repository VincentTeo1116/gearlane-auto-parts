import React,{useEffect,useState} from 'react';
import {Truck} from 'lucide-react';
import {deliveryProgress} from './order-logic.mjs';
import {money} from './domain.mjs';

/* "Add RM 40 more for free delivery": a nudge that only appears when the store has a free-delivery threshold */
export function DeliveryProgress({subtotalCents,settings}){
  const progress=deliveryProgress(subtotalCents,settings);
  if(!progress)return null;
  return <div className={'free-delivery'+(progress.unlocked?' unlocked':'')} role="status">
    <Truck size={20} aria-hidden="true"/>
    <div>
      <b>{progress.unlocked?'You have free delivery':`Add ${money(progress.remaining)} more for free delivery`}</b>
      <div className="free-delivery-bar" role="progressbar" aria-valuemin={0} aria-valuemax={100} aria-valuenow={progress.percent} aria-label="Progress to free delivery"><i style={{width:progress.percent+'%'}}/></div>
    </div>
  </div>;
}

/* Min / max price in RM. Applied when the customer leaves the field or presses Enter, not on every keystroke. */
export function PriceRange({min,max,onCommit}){
  const [lo,setLo]=useState(min||''),[hi,setHi]=useState(max||'');
  useEffect(()=>{setLo(min||'');setHi(max||'');},[min,max]);
  const commit=()=>onCommit(lo.trim(),hi.trim());
  const keys=e=>{if(e.key==='Enter'){e.preventDefault();commit();}};
  return <fieldset className="price-range">
    <legend>Price (RM)</legend>
    <div>
      <label><span className="sr-only">Minimum price in ringgit</span><input inputMode="decimal" placeholder="Min" maxLength={9} value={lo} onChange={e=>setLo(e.target.value)} onBlur={commit} onKeyDown={keys}/></label>
      <span aria-hidden="true">to</span>
      <label><span className="sr-only">Maximum price in ringgit</span><input inputMode="decimal" placeholder="Max" maxLength={9} value={hi} onChange={e=>setHi(e.target.value)} onBlur={commit} onKeyDown={keys}/></label>
    </div>
  </fieldset>;
}
