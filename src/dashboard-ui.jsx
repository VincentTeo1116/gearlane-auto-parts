import React,{useMemo,useState} from 'react';
import {ArrowRight} from 'lucide-react';
import {Link} from './components.jsx';
import {money} from './domain.mjs';

/* Categorical palette: distinguishable in light mode and for most colour-vision types; always paired with text labels */
export const CHART_COLORS=['#2f6fa3','#e8782a','#1f9d8a','#7a5bd6','#d6457a','#8a9a2b'];
const OTHER_COLOR='#9aa9b4';

export function niceMax(value){
  if(value<=0)return 1;
  const exp=Math.pow(10,Math.floor(Math.log10(value))),f=value/exp;
  return (f<=1?1:f<=2?2:f<=2.5?2.5:f<=5?5:10)*exp;
}
export function compactMoney(cents){
  const v=cents/100;
  if(v>=1e6)return 'RM '+(v/1e6).toFixed(1).replace(/\.0$/,'')+'M';
  if(v>=1e3)return 'RM '+(v/1e3).toFixed(1).replace(/\.0$/,'')+'k';
  return 'RM '+Math.round(v);
}

/* Bars with y-axis, grid lines and an average line. Keeps the same accessible button-per-bar behaviour. */
export function TrendChart({series,metric,selected,onSelect,label}){
  const isMoney=metric==='daily',peak=Math.max(0,...series.map(s=>s.value)),top=niceMax(peak);
  const ticks=[0,.25,.5,.75,1].map(f=>f*top),avg=series.length?series.reduce((a,s)=>a+s.value,0)/series.length:0;
  const fmt=v=>isMoney?compactMoney(v):String(Math.round(v));
  const every=series.length>40?7:series.length>14?3:series.length>10?2:1;
  return <div className="trend-chart">
    <div className="y-axis" aria-hidden="true">{[...ticks].reverse().map(t=><span key={t}>{fmt(t)}</span>)}</div>
    <div className="plot">
      <div className="gridlines" aria-hidden="true">{ticks.map(t=><i key={t} style={{bottom:(t/top*100)+'%'}}/>)}</div>
      {avg>0?<div className="avg-line" aria-hidden="true" style={{bottom:(avg/top*100)+'%'}}><span>avg {fmt(avg)}</span></div>:null}
      <div className="bar-chart" aria-label={label}>
        {series.map((s,i)=><button type="button" key={s.name} className={(selected?.name===s.name?'selected ':'')+(s.value===peak&&peak>0?'peak':'')} aria-label={s.name+': '+(isMoney?money(s.value):s.value+' events')} title={s.name+' · '+(isMoney?money(s.value):s.value)} onClick={()=>onSelect(s)}><span style={{height:(s.value/top*100)+'%'}}/><small>{i%every===0?s.name.slice(isMoney?5:0):''}</small></button>)}
      </div>
    </div>
  </div>;
}

/* Donut with centre total and a legend that carries the exact numbers (never colour alone) */
export function Donut({rows,currency=false,centreLabel='Total',maxSlices=5}){
  const sorted=[...rows].filter(r=>r.value>0).sort((a,b)=>b.value-a.value);
  const head=sorted.slice(0,maxSlices),rest=sorted.slice(maxSlices),restSum=rest.reduce((a,r)=>a+r.value,0);
  const parts=restSum?[...head,{name:'Other',value:restSum}]:head,total=parts.reduce((a,r)=>a+r.value,0);
  const [active,setActive]=useState(null);
  if(!total)return <p className="muted small">No data yet.</p>;
  const R=52,C=2*Math.PI*R;let offset=0;
  const fmt=v=>currency?money(v):String(v);
  const colour=(i,r)=>r.name==='Other'&&restSum?OTHER_COLOR:CHART_COLORS[i%CHART_COLORS.length];
  const shown=active!==null?parts[active]:null;
  return <div className="donut-wrap">
    <svg viewBox="0 0 140 140" className="donut" role="img" aria-label={parts.map(r=>r.name+' '+Math.round(r.value/total*100)+'%').join(', ')}>
      <circle cx="70" cy="70" r={R} fill="none" stroke="#eef2f5" strokeWidth="18"/>
      {parts.map((r,i)=>{const len=r.value/total*C,dash=`${Math.max(0,len-1.5)} ${C-Math.max(0,len-1.5)}`,el=<circle key={r.name} cx="70" cy="70" r={R} fill="none" stroke={colour(i,r)} strokeWidth={active===i?22:18} strokeDasharray={dash} strokeDashoffset={-offset} transform="rotate(-90 70 70)" style={{transition:'stroke-width .15s',opacity:active===null||active===i?1:.35}} onMouseEnter={()=>setActive(i)} onMouseLeave={()=>setActive(null)}/>;offset+=len;return el;})}
      <text x="70" y="66" textAnchor="middle" className="donut-value">{shown?Math.round(shown.value/total*100)+'%':currency?compactMoney(total):total}</text>
      <text x="70" y="84" textAnchor="middle" className="donut-label">{shown?shown.name.length>14?shown.name.slice(0,13)+'…':shown.name:centreLabel}</text>
    </svg>
    <ul className="donut-legend">{parts.map((r,i)=><li key={r.name} onMouseEnter={()=>setActive(i)} onMouseLeave={()=>setActive(null)} className={active===i?'active':''}><i style={{background:colour(i,r)}}/><span>{r.name}</span><b>{fmt(r.value)}</b><em>{Math.round(r.value/total*100)}%</em></li>)}</ul>
  </div>;
}

/* Order pipeline: where every order currently sits. Each stage links to the filtered order list. */
export function Pipeline({orders,go}){
  const stages=useMemo(()=>[
    ['Awaiting transfer','/workspace/orders?status=awaiting_payment',o=>o.status==='awaiting_payment'&&['awaiting','rejected'].includes(o.payment_status),'#9aa9b4'],
    ['Verify payment','/workspace/orders?payment=submitted',o=>o.status!=='cancelled'&&o.payment_status==='submitted','#e8782a'],
    ['To ship','/workspace/orders?status=processing',o=>o.status==='processing','#2f6fa3'],
    ['Shipped','/workspace/orders?status=shipped',o=>o.status==='shipped','#7a5bd6'],
    ['Delivered','/workspace/orders?status=delivered',o=>o.status==='delivered','#1f9d8a'],
  ].map(([name,to,test,colour])=>({name,to,colour,count:orders.filter(test).length})),[orders]);
  const largest=Math.max(1,...stages.map(s=>s.count)),cancelled=orders.filter(o=>o.status==='cancelled').length;
  return <div className="pipeline">
    {stages.map(s=><Link key={s.name} to={s.to} go={go} className="pipeline-row"><span className="pipeline-name">{s.name}</span><span className="pipeline-bar"><i style={{width:Math.max(s.count?4:0,s.count/largest*100)+'%',background:s.colour}}/></span><b>{s.count}</b><ArrowRight size={14}/></Link>)}
    <p className="muted small">Based on the {orders.length} most recent orders{cancelled?` · ${cancelled} cancelled not shown above`:''}.</p>
  </div>;
}

export function TopProducts({rows,go}){
  const largest=Math.max(1,...rows.map(r=>r.value));
  if(!rows.length)return <p className="muted small">No verified sales in this period yet.</p>;
  return <ol className="top-products">{rows.map((r,i)=><li key={r.id}><span className="rank">{i+1}</span><div><Link to={'/products/'+r.id} go={go}>{r.name}</Link><i><em style={{width:(r.value/largest*100)+'%'}}/></i></div><span className="top-value"><b>{money(r.value)}</b><small>{r.units} unit{r.units===1?'':'s'}</small></span></li>)}</ol>;
}

export function topProductsFrom(orders,days,limit=5,now=Date.now()){
  const since=now-days*864e5,map=new Map();
  for(const o of orders){
    if(o.payment_status!=='verified'||new Date(o.created_at).getTime()<since)continue;
    for(const i of o.items||[]){const row=map.get(i.product_id)||{id:i.product_id,name:i.name,units:0,value:0};row.units+=i.quantity;row.value+=i.line_total_cents??i.quantity*i.price_cents;map.set(i.product_id,row);}
  }
  return [...map.values()].sort((a,b)=>b.value-a.value).slice(0,limit);
}
