import {addressSchema,validate} from './domain.mjs';

/* Saved delivery addresses: the shape stored per customer, validated with the same rules as checkout. */
export const MAX_ADDRESSES=10,MAX_VEHICLES=8;
const norm=s=>String(s??'').trim().toLowerCase().replace(/\s+/g,' ');

/* Returns {label,name,phone,line1,city,postcode,state}, trimmed, or throws an Error that says what is wrong */
export function normaliseSavedAddress(input){
  const label=String(input?.label??'').trim();
  if(label.length>40)throw new Error('label: use 40 characters or fewer.');
  const checked=validate(addressSchema,{name:input?.name,phone:input?.phone,line1:input?.line1,city:input?.city,postcode:input?.postcode,state:input?.state});
  return{label,...checked};
}

export const addressLines=a=>[a.name,a.line1,`${a.postcode} ${a.city}, ${a.state}`,a.phone].filter(Boolean);
export const addressTitle=a=>a.label||a.line1.split(',')[0];
export const sameAddress=(a,b)=>['name','phone','line1','city','postcode','state'].every(k=>norm(a?.[k])===norm(b?.[k]));

/* Default first, then newest */
export function sortAddresses(list){
  return [...list].sort((a,b)=>Number(Boolean(b.is_default))-Number(Boolean(a.is_default))||new Date(b.created_at)-new Date(a.created_at));
}
export const defaultAddress=list=>sortAddresses(list)[0]||null;

/* What checkout should start with: the default saved address, else the last order's address, else a blank form */
export function startingAddress({saved=[],orders=[],profile={}}){
  const pick=defaultAddress(saved);
  const last=[...orders].filter(o=>o.address?.line1).sort((a,b)=>new Date(b.created_at)-new Date(a.created_at))[0]?.address;
  const from=pick||last;
  return{name:from?.name||profile.full_name||'',phone:from?.phone||profile.phone||'',line1:from?.line1||'',city:from?.city||'',postcode:from?.postcode||'',state:from?.state||'Selangor',savedId:pick?.id||null};
}

/* Garage helpers */
export const vehicleTitle=v=>[v.make,v.model,v.year].filter(Boolean).join(' ');
export const sameVehicle=(a,b)=>norm(a?.make)===norm(b?.make)&&norm(a?.model)===norm(b?.model)&&(a?.year??null)===(b?.year??null);
export const activeVehicle=list=>list.find(v=>v.is_active)||null;
