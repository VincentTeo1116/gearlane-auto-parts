import React,{useEffect,useMemo,useState} from 'react';
import {Bell,Car,Check,TriangleAlert,X} from 'lucide-react';
import {useApp} from './context.jsx';
import {friendlyError} from './domain.mjs';
import {fitStatus,formatYears,vehicleLabel,vehicleOptions} from './fitment.mjs';
import {useVehicle} from './vehicle-state.jsx';

export{loadVehicle,saveVehicle}from './vehicle-state.jsx';

/* "My vehicle" bar on the shop page. Options come only from fitment the store has listed;
   with no fitment entered yet it renders nothing rather than an empty control. */
export function VehiclePicker({vehicle,onChange,counts,onShowAll}){
  const {data}=useApp(),fitment=data.fitment||[],options=useMemo(()=>vehicleOptions(fitment),[fitment]);
  const {local:saved,setVehicle}=useVehicle();
  /* A make on its own is not yet a vehicle: keep it as a draft until a model is chosen, then apply it. */
  const [draft,setDraft]=useState(vehicle);
  useEffect(()=>{setDraft(vehicle);},[vehicle?.make,vehicle?.model,vehicle?.year]);
  if(!options.makes.length)return null;
  const models=draft?options.models(draft.make):[],years=draft?.model?options.years(draft.make,draft.model):[];
  const choose=next=>{setDraft(next);if(!next||next.model){setVehicle(next);onChange(next);}};
  return <section className="vehicle-bar" aria-label="Find parts for your vehicle">
    <div className="vehicle-title"><Car size={20} aria-hidden="true"/><div><b>Find parts for your vehicle</b><small>Shows parts the store has listed for it</small></div></div>
    <div className="vehicle-fields">
      <label><span className="sr-only">Vehicle make</span><select value={draft?.make||''} onChange={e=>choose(e.target.value?{make:e.target.value,model:'',year:null}:null)}><option value="">Make</option>{options.makes.map(m=><option key={m}>{m}</option>)}</select></label>
      <label><span className="sr-only">Vehicle model</span><select value={draft?.model||''} disabled={!draft} onChange={e=>choose({make:draft.make,model:e.target.value,year:null})}><option value="">Model</option>{models.map(m=><option key={m}>{m}</option>)}</select></label>
      {years.length?<label><span className="sr-only">Vehicle year</span><select value={draft?.year||''} disabled={!draft?.model} onChange={e=>choose({...draft,year:e.target.value?Number(e.target.value):null})}><option value="">Any year</option>{years.map(y=><option key={y}>{y}</option>)}</select></label>:null}
      {draft?<button type="button" className="vehicle-clear" aria-label="Clear vehicle" onClick={()=>choose(null)}><X size={15}/>Clear</button>:saved?<button type="button" className="vehicle-saved" onClick={()=>onChange(saved)}>Use saved: {vehicleLabel(saved)}</button>:null}
    </div>
    {vehicle?.model&&counts?<p className="vehicle-summary" role="status"><b>{counts.yes}</b> part{counts.yes===1?'':'s'} listed for {vehicleLabel(vehicle)}.{counts.unknown?<> {counts.unknown} more {counts.unknown===1?'has':'have'} no fitment information yet. Ask the team before ordering.</>:null}{onShowAll?<> <button type="button" className="text-button" onClick={onShowAll}>Show all parts</button></>:null}</p>:null}
  </section>;
}

/* Product page: where the part is listed, and how it relates to the customer's saved vehicle */
export function FitmentPanel({product}){
  const {data}=useApp(),{vehicle}=useVehicle(),rows=(data.fitment||[]).filter(f=>f.product_id===product.id),status=vehicle?fitStatus(rows,vehicle):'unknown';
  if(!rows.length)return <p className="fitment-none">No vehicle list for this part yet. Ask the seller to confirm it fits before you order.</p>;
  return <div className="fitment-panel">
    {vehicle&&status==='yes'?<p className="fit-yes"><Check size={16}/>Listed for your {vehicleLabel(vehicle)}</p>:null}
    {vehicle&&status==='no'?<p className="fit-no"><TriangleAlert size={16}/>Not listed for your {vehicleLabel(vehicle)}. Ask the seller before ordering.</p>:null}
    <b>Listed for</b>
    <ul>{rows.map(r=><li key={r.id||r.make+r.model+r.year_from}>{r.make} {r.model}<span>{formatYears(r)}</span></li>)}</ul>
    <small>This is the store's own listing, not a manufacturer guarantee. Confirm with the seller if you are unsure.</small>
  </div>;
}

/* Follow an out-of-stock product; customers are notified in the app when it returns */
export function StockAlertButton({product,compact=false}){
  const {data,profile,go,repository,run,notify}=useApp(),[busy,setBusy]=useState(false),following=(data.stock_alerts||[]).some(a=>a.product_id===product.id);
  if(product.stock>0||!product.price_confirmed)return null;
  const click=async()=>{
    if(!profile){go('/account?next='+encodeURIComponent(location.pathname+location.search));return;}
    if(profile.role!=='customer'){notify('Stock alerts are available to customer accounts.','error');return;}
    setBusy(true);
    try{await run(()=>repository.rpc('toggle_stock_alert',{p_product_id:product.id}),following?'You will no longer be notified about this part.':'We will tell you when it is back in stock.');}
    catch(error){notify(friendlyError(error),'error');}
    finally{setBusy(false);}
  };
  return <button type="button" className={'stock-alert'+(following?' on':'')+(compact?' compact':'')} aria-pressed={following} disabled={busy} onClick={click}><Bell size={15} fill={following?'currentColor':'none'}/>{following?'Following. Tap to stop':'Notify me when back in stock'}</button>;
}
