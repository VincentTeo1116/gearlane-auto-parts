/* Change between two periods, as a percentage, for the dashboard's "vs previous period" labels. */
export function deltaInfo(current,previous){
  const now=Number(current),before=Number(previous);
  if(!Number.isFinite(now)||!Number.isFinite(before)||now<0||before<0)return null;
  if(before===0)return now===0?null:{kind:'new',pct:null,dir:'up'};
  const pct=(now-before)/before*100;
  if(Math.abs(pct)<0.05)return{kind:'same',pct:0,dir:'flat'};
  return{kind:'change',pct,dir:pct>0?'up':'down'};
}
export function deltaLabel(info,days){
  if(!info)return '';
  const span=`previous ${days} days`;
  if(info.kind==='new')return `New · none in the ${span}`;
  if(info.kind==='same')return `No change vs ${span}`;
  const value=Math.abs(info.pct)>=100?Math.round(Math.abs(info.pct)):Math.abs(info.pct).toFixed(1).replace(/\.0$/,'');
  return `${info.dir==='up'?'▲':'▼'} ${value}% vs ${span}`;
}
