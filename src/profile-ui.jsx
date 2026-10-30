import React,{useState} from 'react';
import {MapPin,Pencil,Plus,Star,Trash2} from 'lucide-react';
import {useApp,useTask} from './context.jsx';
import {Badge,Button,Field,Modal,Notice} from './components.jsx';
import {MAX_ADDRESSES,addressLines,addressTitle,normaliseSavedAddress,sortAddresses} from './address-book.mjs';
import {STATES} from './domain.mjs';

const blank={label:'',name:'',phone:'',line1:'',city:'',postcode:'',state:'Selangor'};
const isMissing=error=>['PGRST202','42883'].includes(error?.code);

/* Add or edit one saved address. The same rules as checkout are applied before anything is sent. */
function AddressForm({initial,defaultName,defaultPhone,isFirst,onClose}){
  const {repository}=useApp(),task=useTask();
  const [values,setValues]=useState(initial?{label:initial.label||'',name:initial.name,phone:initial.phone,line1:initial.line1,city:initial.city,postcode:initial.postcode,state:initial.state}:{...blank,name:defaultName||'',phone:defaultPhone||''});
  const [makeDefault,setMakeDefault]=useState(initial?.is_default||isFirst);
  const change=key=>e=>setValues(v=>({...v,[key]:e.target.value}));
  const submit=async e=>{
    e.preventDefault();
    const result=await task.perform(async()=>{
      const clean=normaliseSavedAddress(values);
      try{return await repository.rpc('save_address',{p_address:clean,p_id:initial?.id??null,p_make_default:makeDefault});}
      catch(error){if(isMissing(error))throw new Error('The address book needs the latest database update (supabase/016-address-book-and-garage.sql).');throw error;}
    },initial?'Address updated.':'Address saved.');
    if(result.ok)onClose();
  };
  return <Modal title={initial?'Edit address':'Add an address'} onClose={onClose}>
    <form onSubmit={submit} className="address-form">
      <div className="form-grid">
        <Field label="Label (optional)" hint="For example Home or Workshop"><input maxLength={40} value={values.label} onChange={change('label')}/></Field>
        <Field label="Full name"><input required minLength={2} maxLength={100} autoComplete="name" value={values.name} onChange={change('name')}/></Field>
        <Field label="Phone number"><input required maxLength={20} inputMode="tel" autoComplete="tel" value={values.phone} onChange={change('phone')}/></Field>
        <Field label="Delivery address" className="full"><input required minLength={8} maxLength={300} autoComplete="street-address" value={values.line1} onChange={change('line1')}/></Field>
        <Field label="City"><input required minLength={2} maxLength={80} autoComplete="address-level2" value={values.city} onChange={change('city')}/></Field>
        <Field label="Postcode"><input required maxLength={5} inputMode="numeric" autoComplete="postal-code" value={values.postcode} onChange={change('postcode')}/></Field>
        <Field label="State / territory"><select value={values.state} onChange={change('state')}>{STATES.map(s=><option key={s}>{s}</option>)}</select></Field>
      </div>
      <label className="checkbox"><input type="checkbox" checked={makeDefault} disabled={isFirst||initial?.is_default} onChange={e=>setMakeDefault(e.target.checked)}/>Use as my default address</label>
      {task.error?<Notice type="error">{task.error}</Notice>:null}
      <div className="actions"><Button busy={task.busy}>{initial?'Save changes':'Save address'}</Button><Button type="button" variant="secondary" onClick={onClose}>Cancel</Button></div>
    </form>
  </Modal>;
}

/* My account: the delivery addresses a customer keeps, with one default that checkout starts from */
export function AddressBook(){
  const {data,profile,repository}=useApp(),task=useTask(),[editing,setEditing]=useState(null);
  const addresses=sortAddresses(data.saved_addresses||[]);
  const act=(name,args,success)=>task.perform(()=>repository.rpc(name,args),success);
  return <section className="panel address-book" aria-labelledby="address-book-title">
    <div className="panel-heading"><div><h2 id="address-book-title">Address book</h2><small className="muted">Save the places you receive parts. Checkout starts from your default.</small></div>
      <Button variant="secondary small" disabled={addresses.length>=MAX_ADDRESSES} onClick={()=>setEditing({})}><Plus size={15}/>Add address</Button></div>
    {addresses.length?<ul className="address-list">{addresses.map(a=><li key={a.id} className={a.is_default?'default':''}>
      <span className="address-icon" aria-hidden="true"><MapPin size={18}/></span>
      <div className="address-body"><b>{addressTitle(a)}{a.is_default?<Badge value="verified">Default</Badge>:null}</b>{addressLines(a).map((line,i)=><span key={i}>{line}</span>)}</div>
      <div className="address-actions">
        {!a.is_default?<Button variant="secondary small" busy={task.busy} onClick={()=>act('set_default_address',{p_id:a.id},'Default address updated.')}><Star size={14}/>Make default</Button>:null}
        <Button variant="secondary small" onClick={()=>setEditing(a)}><Pencil size={14}/>Edit</Button>
        <button type="button" className="icon-button" aria-label={'Delete address '+addressTitle(a)} onClick={()=>act('delete_address',{p_id:a.id},'Address deleted.')}><Trash2 size={17}/></button>
      </div>
    </li>)}</ul>:<p className="muted">No saved addresses yet. Add one to skip typing it at checkout.</p>}
    {task.error?<Notice type="error">{task.error}</Notice>:null}
    {addresses.length>=MAX_ADDRESSES?<p className="muted small">You have reached the limit of {MAX_ADDRESSES} addresses. Delete one to add another.</p>:null}
    {editing?<AddressForm initial={editing.id?editing:null} defaultName={profile.full_name} defaultPhone={profile.phone} isFirst={!addresses.length} onClose={()=>setEditing(null)}/>:null}
  </section>;
}

/* Checkout: pick a saved address, or keep typing a new one */
export function AddressPicker({saved,selectedId,onPick}){
  if(!saved.length)return null;
  return <fieldset className="address-picker"><legend>Deliver to</legend>
    <div className="address-options">{sortAddresses(saved).map(a=><label key={a.id} className={'address-option'+(selectedId===a.id?' selected':'')}>
      <input type="radio" name="saved-address" checked={selectedId===a.id} onChange={()=>onPick(a)}/>
      <span><b>{addressTitle(a)}{a.is_default?<em>Default</em>:null}</b><small>{a.name}, {a.line1}, {a.postcode} {a.city}</small></span>
    </label>)}
    <label className={'address-option'+(!selectedId?' selected':'')}><input type="radio" name="saved-address" checked={!selectedId} onChange={()=>onPick(null)}/><span><b>A different address</b><small>Type it below</small></span></label></div>
  </fieldset>;
}
