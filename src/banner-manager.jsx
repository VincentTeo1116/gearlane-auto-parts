import React,{useEffect,useState,useRef} from 'react';
import {ImagePlus,Plus,Trash2,Upload,Eye,EyeOff,ArrowUpRight} from 'lucide-react';
import {useApp,useTask} from './context.jsx';
import {Button,Confirm,Empty,Field,Modal,Notice,Badge} from './components.jsx';
import {bannerSchema} from './banners.mjs';
import {friendlyError,validate} from './domain.mjs';
import {ScreenSkeleton} from './visuals.jsx';

export function BannerManager(){
 const {repository,revision,go}=useApp(),task=useTask();
 const [rows,setRows]=useState([]),[loading,setLoading]=useState(true),[error,setError]=useState(''),[editing,setEditing]=useState(null),[removing,setRemoving]=useState(null),[reload,setReload]=useState(0);
 useEffect(()=>{let alive=true;repository.banners().then(value=>{if(alive){setRows(value);setError('');}}).catch(e=>{if(alive)setError(/PGRST205|42P01|schema cache|does not exist/i.test(String(e.code)+' '+e.message)?'Banner storage is not installed. Run supabase/008-promotion-banners.sql as the project owner.':friendlyError(e));}).finally(()=>alive&&setLoading(false));return()=>{alive=false;};},[repository,revision,reload]);
 const published=rows.filter(b=>b.published&&b.image_url).length;
 return <><div className="section-heading"><div><span className="eyebrow">YOUR HOMEPAGE CAMPAIGNS</span><h1>Promotion banners</h1><p>Upload your advertisement artwork, choose its order, and publish it on the homepage.</p></div><Button onClick={()=>setEditing({new:true})}><Plus size={18}/>Add banner</Button></div>
  <div className="banner-summary"><ImagePlus size={24}/><div><b>{published} published banner{published!==1?'s':''}</b><p>With no published image, the homepage banner stays hidden. Customers can swipe or use the arrows.</p></div><Button variant="secondary small" onClick={()=>go('/')}>View homepage<ArrowUpRight size={16}/></Button></div>
  {error?<Notice type="error">{error}<Button variant="secondary small" onClick={()=>{setLoading(true);setReload(n=>n+1);}}>Try again</Button></Notice>:null}
  {loading?<ScreenSkeleton kind="products"/>:rows.length?<div className="banner-management-grid">{rows.map(b=><article key={b.id} className="panel banner-management-card"><div className="banner-admin-preview">{b.image_url?<img src={b.image_url} alt={b.alt_text||b.title} loading="lazy"/>:<div><ImagePlus size={30}/><span>No image yet</span></div>}</div><div className="panel-heading"><div><h3>{b.title}</h3><small>Display order: {b.position}</small></div><Badge value={b.published?'verified':'cancelled'}>{b.published?'Published':'Draft'}</Badge></div><p>{b.alt_text||'Add a description before publishing.'}</p>{b.link_path?<small>Links to: {b.link_path}</small>:null}<div className="actions"><Button variant="secondary small" onClick={()=>setEditing(b)}>Edit banner</Button><Button variant="secondary small" busy={task.busy} disabled={!b.image_url||b.alt_text.length<5} onClick={()=>task.perform(()=>repository.rpc('admin_save_banner',{p_banner:{...b,published:!b.published},p_expected_version:b.version}),b.published?'Banner hidden.':'Banner published.')}>{b.published?<EyeOff size={16}/>:<Eye size={16}/>} {b.published?'Hide':'Publish'}</Button><button className="icon-button" aria-label={'Delete '+b.title} onClick={()=>setRemoving(b)}><Trash2 size={17}/></button></div></article>)}</div>:!error?<Empty title="No promotion banners yet" action={<Button onClick={()=>setEditing({new:true})}><Upload size={17}/>Upload your first banner</Button>}>Your homepage stays clean until you publish an image. Drafts do not appear to customers.</Empty>:null}
  {task.error?<Notice type="error">{task.error}</Notice>:null}
  {editing?<BannerEditor banner={editing} onClose={()=>setEditing(null)}/>:null}
  {removing?<Confirm title="Delete this banner?" onClose={()=>setRemoving(null)} onConfirm={async()=>{const result=await task.perform(()=>repository.rpc('admin_delete_banner',{p_id:removing.id}),'Banner deleted.');if(!result.ok)throw new Error('The banner could not be deleted. Try again.');}}>This removes the advertisement from the homepage. Other banners and promotion codes are unaffected.</Confirm>:null}
 </>;
}

function BannerEditor({banner,onClose}){
 const {repository,preview}=useApp(),task=useTask();
 const mainInput=useRef(null),mobileInput=useRef(null);
 const [values,setValues]=useState(banner.new?{id:crypto.randomUUID(),title:'',alt_text:'',image_url:'',mobile_image_url:'',link_path:'',position:0,published:false}:{...banner,link_path:banner.link_path||'',image_url:banner.image_url||'',mobile_image_url:banner.mobile_image_url||''});
 const [mainFile,setMainFile]=useState(null),[mobileFile,setMobileFile]=useState(null),[mainPreview,setMainPreview]=useState(null),[mobilePreview,setMobilePreview]=useState(null);
 useEffect(()=>{if(!mainFile){setMainPreview(null);return;}const url=URL.createObjectURL(mainFile);setMainPreview(url);return()=>URL.revokeObjectURL(url);},[mainFile]);
 useEffect(()=>{if(!mobileFile){setMobilePreview(null);return;}const url=URL.createObjectURL(mobileFile);setMobilePreview(url);return()=>URL.revokeObjectURL(url);},[mobileFile]);
 const update=(key,value)=>setValues(v=>({...v,[key]:value}));
 const selectFile=(event,setFile)=>{const file=event.target.files[0];if(!file){setFile(null);return;}if(file.size>5242880||!['image/jpeg','image/png','image/webp'].includes(file.type)){task.setError('Choose a JPG, PNG or WebP image no larger than 5 MB.');event.target.value='';return;}task.setError('');setFile(file);};
 const submit=async e=>{e.preventDefault();const result=await task.perform(async()=>{
   const temporary={...values,position:Number(values.position),image_url:mainFile?'https://pending.invalid/main':values.image_url,mobile_image_url:mobileFile?'https://pending.invalid/mobile':values.mobile_image_url};
   const safe=({...temporary,image_url:preview&&temporary.image_url.startsWith('data:image/')?'https://preview.invalid/main':temporary.image_url,mobile_image_url:preview&&temporary.mobile_image_url.startsWith('data:image/')?'https://preview.invalid/mobile':temporary.mobile_image_url});
   validate(bannerSchema,safe);
   const image_url=mainFile?await repository.upload(mainFile,'promotion-banners'):values.image_url,mobile_image_url=mobileFile?await repository.upload(mobileFile,'promotion-banners'):values.mobile_image_url;
   return repository.rpc('admin_save_banner',{p_banner:{...values,title:values.title.trim(),alt_text:values.alt_text.trim(),position:Number(values.position),image_url,mobile_image_url},p_expected_version:banner.new?null:banner.version});
  },values.published?'Banner saved and published.':'Banner draft saved.');if(result.ok)onClose();};
 return <Modal title={banner.new?'Add promotion banner':'Edit promotion banner'} wide onClose={()=>!task.busy&&onClose()}><form onSubmit={submit}>
  <Notice>Use artwork you own or are authorised to publish. Recommended: 1920 × 640 for the main image; an optional 960 × 480 design can improve readability on phones. Artwork is fitted without cutting off its text.</Notice>
  <div className="form-grid"><Field label="Banner name"><input required minLength={3} maxLength={120} disabled={task.busy} value={values.title} onChange={e=>update('title',e.target.value)}/></Field><Field label="Display order" hint="Smaller numbers appear first."><input type="number" required min={0} max={9999} step={1} disabled={task.busy} value={values.position} onChange={e=>update('position',e.target.value)}/></Field>
   <Field label="Advertisement description" className="full" hint="Describe the offer and important text for people who cannot see the image."><textarea required={values.published} minLength={values.published?5:0} maxLength={300} disabled={task.busy} value={values.alt_text} onChange={e=>update('alt_text',e.target.value)}/></Field>
   <Field label="Main advertisement image" hint="JPG, PNG or WebP · maximum 5 MB"><input ref={mainInput} type="file" accept="image/jpeg,image/png,image/webp" disabled={task.busy} onChange={e=>selectFile(e,setMainFile)}/></Field><Field label="Phone advertisement image (optional)"><input ref={mobileInput} type="file" accept="image/jpeg,image/png,image/webp" disabled={task.busy} onChange={e=>selectFile(e,setMobileFile)}/></Field>
   <Field label="Destination in this store (optional)" className="full" hint="For example /shop?category=Engine%20Oil. Leave empty for an image-only advertisement."><input maxLength={500} disabled={task.busy} placeholder="/shop" value={values.link_path} onChange={e=>update('link_path',e.target.value)}/></Field>
  </div>
  {mainPreview||values.image_url?<div className="banner-editor-preview"><b>Main artwork preview</b><img src={mainPreview||values.image_url} alt={values.alt_text||'Main banner preview'}/><Button type="button" variant="secondary small" disabled={task.busy} onClick={()=>{setMainFile(null);if(mainInput.current)mainInput.current.value="";setValues(v=>({...v,image_url:'',published:false}));}}>Remove main image</Button></div>:null}
  {mobilePreview||values.mobile_image_url?<div className="banner-editor-preview phone-preview"><b>Phone artwork preview</b><img src={mobilePreview||values.mobile_image_url} alt={values.alt_text||'Phone banner preview'}/><Button type="button" variant="secondary small" disabled={task.busy} onClick={()=>{setMobileFile(null);if(mobileInput.current)mobileInput.current.value="";update('mobile_image_url','');}}>Remove phone image</Button></div>:null}
  <label className="checkbox"><input type="checkbox" disabled={task.busy} checked={values.published} onChange={e=>update('published',e.target.checked)}/>Publish on the homepage</label>
  {task.error?<Notice type="error">{task.error}</Notice>:null}<div className="actions"><Button busy={task.busy}>{task.busy?'Saving banner…':'Save banner'}</Button><Button type="button" variant="secondary" disabled={task.busy} onClick={onClose}>Cancel</Button></div>
 </form></Modal>;
}
