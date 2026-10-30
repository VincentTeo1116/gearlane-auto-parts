import {useCallback,useEffect,useRef,useState} from 'react';
import {useApp} from './context.jsx';
import {parseVehicle,serialiseVehicle} from './fitment.mjs';

/* The customer's active vehicle, available everywhere in the store.
   Signed-in customers keep a garage in their account (so it follows them to every device); everyone's choice is
   also remembered in this browser, which is all a signed-out visitor has. */
const KEY='gearlane_vehicle',EVENT='gearlane-vehicle-change';

export const loadVehicle=()=>{try{return parseVehicle(localStorage.getItem(KEY));}catch{return null;}};
export const saveVehicle=vehicle=>{
  try{if(vehicle)localStorage.setItem(KEY,serialiseVehicle(vehicle));else localStorage.removeItem(KEY);}catch{/* private mode: it still works for this visit */}
  window.dispatchEvent(new Event(EVENT));
};
const toVehicle=row=>row?{make:row.make,model:row.model,year:row.year??null}:null;

export function useVehicle(){
  const {data,profile,repository,run}=useApp(),[local,setLocal]=useState(loadVehicle);
  useEffect(()=>{
    const sync=()=>setLocal(loadVehicle());
    addEventListener(EVENT,sync);addEventListener('storage',sync);
    return()=>{removeEventListener(EVENT,sync);removeEventListener('storage',sync);};
  },[]);
  const customer=profile?.role==='customer',garage=customer?(data.garage_vehicles||[]):[];
  // With a garage, the garage decides (including "no vehicle"); without one, the browser's choice applies.
  const vehicle=garage.length?toVehicle(garage.find(v=>v.is_active)):local;

  const setVehicle=useCallback(async next=>{
    saveVehicle(next);
    if(!customer)return;
    try{
      if(next)await run(()=>repository.rpc('add_garage_vehicle',{p_make:next.make,p_model:next.model,p_year:next.year??null,p_nickname:'',p_activate:true}));
      else await run(()=>repository.rpc('set_active_vehicle',{p_id:null}));
    }catch{/* before migration 016, or offline: the choice still works on this device */}
  },[customer,repository,run]);

  return{vehicle,garage,local,setVehicle,customer};
}

/* A vehicle chosen while signed out moves into the account the first time the customer signs in.
   Call this from ONE component (the header chip), not from every card, or the move would be attempted many times. */
export function useVehicleMigration(){
  const {garage,local,setVehicle,customer}=useVehicle(),moved=useRef(false);
  useEffect(()=>{
    if(customer&&!garage.length&&local&&!moved.current){moved.current=true;setVehicle(local);}
  },[customer,garage.length,local,setVehicle]);
}
