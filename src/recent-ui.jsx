import React,{useMemo,useState} from 'react';
import {useApp} from './context.jsx';
import {clearRecent,readRecent} from './recent.mjs';

/* Parts this browser looked at recently, newest first. Kept in this browser only. */
export function RecentlyViewed({ProductCard,exclude=null,limit=6}){
  const {data,route}=useApp(),[version,setVersion]=useState(0);
  const products=useMemo(()=>readRecent().filter(id=>id!==exclude).map(id=>data.products.find(p=>p.id===id&&p.active)).filter(Boolean).slice(0,limit),[route,version,exclude,data.products]);
  if(!products.length)return null;
  return <section className="container section recent-section" aria-label="Recently viewed parts">
    <div className="section-heading"><div><span className="eyebrow">PICK UP WHERE YOU LEFT OFF</span><h2>Recently viewed</h2></div><button type="button" className="text-button" onClick={()=>{clearRecent();setVersion(v=>v+1);}}>Clear history</button></div>
    <div className="recent-strip">{products.map(p=><ProductCard key={p.id} product={p}/>)}</div>
  </section>;
}
