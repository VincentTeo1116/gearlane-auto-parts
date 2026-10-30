import React,{useMemo,useState} from 'react';
import {Car,Check,Plus,Trash2,TriangleAlert} from 'lucide-react';
import {useApp,useTask} from './context.jsx';
import {Badge,Button,Link,Modal} from './components.jsx';
import {fitStatus,fitmentByProduct,vehicleLabel,vehicleOptions} from './fitment.mjs';
import {vehicleTitle} from './address-book.mjs';
import {saveVehicle,useVehicle,useVehicleMigration} from './vehicle-state.jsx';

const isMissing=error=>['PGRST202','42883'].includes(error?.code);

/* "My vehicle" in the header: always visible, shows what the store is filtering by */
export function GarageChip(){
  const {setDialog}=useApp(),{vehicle}=useVehicle();useVehicleMigration();
  return <button type="button" className={'garage-chip'+(vehicle?' has-vehicle':'')} onClick={()=>setDialog({type:'garage'})} aria-label={vehicle?'My vehicle: '+vehicleLabel(vehicle)+'. Change vehicle':'Add my vehicle'}>
    <Car size={17} aria-hidden="true"/>{vehicle?<><span>My vehicle</span><b>{vehicleLabel(vehicle)}</b></>:<span>Add my vehicle</span>}
  </button>;
}

/* The same control as a compact icon for the phone header, where the labelled chip would not fit */
export function GarageIcon(){
  const {setDialog}=useApp(),{vehicle}=useVehicle();
  return <button type="button" className={'icon-link garage-btn'+(vehicle?' has-vehicle':'')} onClick={()=>setDialog({type:'garage'})} aria-label={vehicle?'My vehicle: '+vehicleLabel(vehicle)+'. Change vehicle':'Add my vehicle'}><Car size={22} aria-hidden="true"/>{vehicle?<i aria-hidden="true"/>:null}</button>;
}

/* The garage: the vehicles a customer owns, which one the store filters by, and a way to add one.
   Options come only from vehicles the store has listed parts for, so choosing one always means something. */
export function GarageManager({onDone}){
  const {data,profile,repository,notify}=useApp(),{vehicle,garage,local,setVehicle,customer}=useVehicle(),task=useTask();
  const options=useMemo(()=>vehicleOptions(data.fitment||[]),[data.fitment]);
  const [make,setMake]=useState(''),[model,setModel]=useState(''),[year,setYear]=useState('');
  const models=make?options.models(make):[],years=make&&model?options.years(make,model):[];
  const rows=customer&&garage.length?garage:local?[{id:'local',make:local.make,model:local.model,year:local.year,is_active:true}]:[];
  const call=(name,args,success)=>task.perform(async()=>{
    try{return await repository.rpc(name,args);}
    catch(error){
      if(!isMissing(error))throw error;
      throw new Error('Your garage needs the latest database update. Until then, your vehicle is remembered on this device only.');
    }
  },success);
  const add=async e=>{
    e.preventDefault();if(!make||!model)return;
    const chosen={make,model,year:year?Number(year):null};
    if(!customer){saveVehicle(chosen);notify('Vehicle saved on this device.');}
    else{
      const result=await call('add_garage_vehicle',{p_make:chosen.make,p_model:chosen.model,p_year:chosen.year,p_nickname:'',p_activate:true},'Added to your garage.');
      if(!result.ok){saveVehicle(chosen);return;}
    }
    setMake('');setModel('');setYear('');onDone?.();
  };
  return <div className="garage">
    {!customer?<p className="muted small">{profile?'Staff accounts do not have a garage.':'Saved on this device. Sign in to keep your garage on every device.'}</p>:null}
    {rows.length?<ul className="garage-list">{rows.map(v=><li key={v.id} className={v.is_active?'active':''}>
      <span className="garage-icon" aria-hidden="true"><Car size={18}/></span>
      <span className="garage-name"><b>{vehicleTitle(v)}</b>{v.nickname?<small>{v.nickname}</small>:null}</span>
      {v.is_active?<Badge value="verified">In use</Badge>:<Button variant="secondary small" busy={task.busy} onClick={()=>call('set_active_vehicle',{p_id:v.id},'Now showing parts for '+vehicleTitle(v)+'.')}>Use this vehicle</Button>}
      <button type="button" className="icon-button" aria-label={'Remove '+vehicleTitle(v)} onClick={async()=>{if(v.id==='local'){saveVehicle(null);return;}await call('remove_garage_vehicle',{p_id:v.id},'Removed from your garage.');}}><Trash2 size={17}/></button>
    </li>)}</ul>:<p className="muted">No vehicle yet. Add yours and the store will show the parts that are listed for it.</p>}
    {vehicle&&rows.length?<Button variant="secondary small" busy={task.busy} onClick={()=>setVehicle(null)}>Show all parts (no vehicle)</Button>:null}
    {options.makes.length?<form className="garage-add" onSubmit={add}>
      <h3>Add a vehicle</h3>
      <div className="garage-fields">
        <label><span className="sr-only">Make</span><select value={make} onChange={e=>{setMake(e.target.value);setModel('');setYear('');}}><option value="">Make</option>{options.makes.map(m=><option key={m}>{m}</option>)}</select></label>
        <label><span className="sr-only">Model</span><select value={model} disabled={!make} onChange={e=>{setModel(e.target.value);setYear('');}}><option value="">Model</option>{models.map(m=><option key={m}>{m}</option>)}</select></label>
        {years.length?<label><span className="sr-only">Year</span><select value={year} onChange={e=>setYear(e.target.value)}><option value="">Any year</option>{years.map(y=><option key={y}>{y}</option>)}</select></label>:null}
        <Button busy={task.busy} disabled={!make||!model}><Plus size={16}/>Add vehicle</Button>
      </div>
      {task.error?<p className="field-error" role="alert">{task.error}</p>:null}
    </form>:<p className="muted small">The store has not listed parts by vehicle yet, so there is nothing to choose from. Ask the team if you are unsure what fits.</p>}
  </div>;
}

export function GarageDialog({onClose}){
  return <Modal title="My garage" onClose={onClose}><p>Choose the vehicle you are buying for. The store then shows parts listed for it, and marks each part as fitting or not.</p><GarageManager onDone={onClose}/></Modal>;
}

/* A small note on a product card: does this part fit the customer's active vehicle? Says nothing when the store has no list. */
export function FitChip({product}){
  const {data}=useApp(),{vehicle}=useVehicle();
  if(!vehicle)return null;
  const rows=(data.fitment||[]).filter(f=>f.product_id===product.id),status=fitStatus(rows,vehicle);
  if(status==='yes')return <span className="fit-chip yes"><Check size={13}/>Fits your {vehicle.model}</span>;
  if(status==='no')return <span className="fit-chip no"><TriangleAlert size={13}/>Not listed for your {vehicle.model}</span>;
  return null;
}

/* Home page shelf: parts the store lists for the customer's vehicle, in-stock first */
export function VehicleShelf({ProductCard}){
  const {data,go}=useApp(),{vehicle}=useVehicle();
  const list=useMemo(()=>{
    if(!vehicle)return[];
    const rows=fitmentByProduct(data.fitment||[]);
    return data.products.filter(p=>p.active&&fitStatus(rows.get(p.id)||[],vehicle)==='yes').sort((a,b)=>Number(b.stock>0&&b.price_confirmed)-Number(a.stock>0&&a.price_confirmed));
  },[vehicle?.make,vehicle?.model,vehicle?.year,data.fitment,data.products]);
  if(!vehicle||!list.length)return null;
  return <section className="container section vehicle-shelf" aria-label={'Parts for your '+vehicleLabel(vehicle)}>
    <div className="section-heading"><div><span className="eyebrow">MADE FOR YOUR VEHICLE</span><h2>Parts for your {vehicleLabel(vehicle)}</h2><p>Listed by the store for this vehicle. Confirm with the seller if you are unsure.</p></div><Link to="/shop" go={go} className="text-link">See all {list.length}</Link></div>
    <div className="product-grid">{list.slice(0,4).map(p=><ProductCard key={p.id} product={p}/>)}</div>
  </section>;
}
