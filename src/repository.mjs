import {createClient} from '@supabase/supabase-js';

const url=import.meta.env.VITE_SUPABASE_URL,key=import.meta.env.VITE_SUPABASE_PUBLISHABLE_KEY;
export const preview=import.meta.env.VITE_DEMO_MODE==='true'||(!url&&!key&&import.meta.env.DEV);
export const configured=Boolean(url&&key);
export const companyName=import.meta.env.VITE_COMPANY_NAME||'GearLane Auto Parts';
/* Signed-out visitors may read review text only; identifiers are hidden by the database (supabase/010-privacy-hardening.sql). */
const REVIEW_PUBLIC_COLUMNS='id,product_id,rating,body,display_name,reply,published,created_at';
const result=async promise=>{const {data,error}=await promise;if(error)throw error;return data;};
function createLiveRepository(){
 const supabase=createClient(url,key,{auth:{storage:window.sessionStorage,persistSession:true,autoRefreshToken:true,detectSessionInUrl:true},global:{fetch:(input,options={})=>fetch(input,{...options,signal:options.signal?AbortSignal.any([options.signal,AbortSignal.timeout(20000)]):AbortSignal.timeout(20000)})}});
 let onChange=()=>{};
 const coreCache=new Map();
 const invalidate=()=>coreCache.clear();
 const reads=new Set(['record_event','dashboard_stats','staff_directory','manage_conversation','read_notifications','start_conversation','send_message','send_chat_message','toggle_wishlist','chat_inbox','start_support_enquiry','check_promotion','admin_get_settings']);
 const rpc=async(name,args={})=>{if(!reads.has(name))invalidate();try{return await result(supabase.rpc(name,args));}finally{if(!reads.has(name))invalidate();}};
 const banners=async(optional=false)=>{const response=await supabase.from('promotion_banners').select('*').order('position').order('created_at',{ascending:false}).limit(100);if(response.error){if(optional)return [];throw response.error;}return response.data;};
 const core=profile=>{
  const cacheKey=(profile?.id||'guest')+':'+(profile?.role||'guest');
  const cached=coreCache.get(cacheKey);if(cached&&cached.until>Date.now())return cached.promise;
  const queries={products:supabase.from('products').select('*').order('name'),settings:profile?.role==='admin'?supabase.rpc('admin_get_settings'):supabase.from('public_store_settings').select('*').eq('id',1).single(),announcements:supabase.from('announcements').select('*').order('created_at',{ascending:false}),promotions:profile?.role==='admin'?supabase.from('promotions').select('*'):Promise.resolve({data:[],error:null}),reviews:supabase.from('reviews').select(profile?'*':REVIEW_PUBLIC_COLUMNS).order('created_at',{ascending:false}).limit(500)};
  const promise=Promise.all([...Object.entries(queries).map(async([name,query])=>[name,await result(query)]),banners(true).then(rows=>['banners',rows])]).then(Object.fromEntries).catch(error=>{if(coreCache.get(cacheKey)?.promise===promise)coreCache.delete(cacheKey);throw error;});
  coreCache.set(cacheKey,{promise,until:Date.now()+15000});return promise;
 };
 return {
  mode:'live',supabase,
  async session(){const {data,error}=await supabase.auth.getSession();if(error)throw error;return data.session?.user||null;},
  onAuth(callback){const {data}=supabase.auth.onAuthStateChange((event,session)=>{setTimeout(()=>{invalidate();callback(session?.user||null,event);},0);});return()=>data.subscription.unsubscribe();},
  async signIn(email,password){return result(supabase.auth.signInWithPassword({email,password}));},
  async signUp(values){const data=await result(supabase.auth.signUp({email:values.email,password:values.password,options:{emailRedirectTo:location.origin+'/account',data:{full_name:values.name,phone:values.phone,business_type:values.business_type}}}));return{confirmationRequired:!data.session};},
  async signOut(){return result(supabase.auth.signOut());},
  async resetPassword(email){return result(supabase.auth.resetPasswordForEmail(email,{redirectTo:location.origin+'/account?reset=1'}));},
  async changePassword(password){return result(supabase.auth.updateUser({password}));},
  async profile(id){const rows=await result(supabase.from('profiles').select('*').eq('id',id).limit(1));if(!rows.length)throw new Error('Your account profile is unavailable or inactive. Contact the administrator.');return rows[0];},
  async snapshot(profile,{sections}={}){
   const want=new Set(sections||['orders','refunds','conversations','notifications','wishlist','restock','directory','users','audit','banners']),queries={};
   if(profile){
    if(want.has('orders'))queries.orders=supabase.from('orders').select('*,items:order_items(*),events:order_events(*)').order('created_at',{ascending:false}).limit(200);
    if(want.has('refunds'))queries.refunds=supabase.from('refunds').select('*').order('created_at',{ascending:false}).limit(200);
    if(want.has('conversations'))queries.conversations=supabase.from('conversations').select('*,members:conversation_members(*)').order('created_at',{ascending:false}).limit(100);
    if(want.has('notifications'))queries.notifications=supabase.from('notifications').select('*').order('created_at',{ascending:false}).limit(100);
    if(profile.role==='customer'&&want.has('wishlist'))queries.wishlist=supabase.from('wishlist').select('*');
    if(['worker','admin'].includes(profile.role)){
     if(want.has('restock'))queries.restock=supabase.from('restock_requests').select('*').order('created_at',{ascending:false});
     if(want.has('directory'))queries.directory=supabase.rpc('staff_directory');
    }
    if(profile.role==='admin'){
     if(want.has('users'))queries.users=supabase.from('profiles').select('*').order('created_at',{ascending:false});
     if(want.has('audit'))queries.audit=supabase.from('audit_events').select('*').order('created_at',{ascending:false}).limit(100);
    }
   }
   const [base,entries]=await Promise.all([core(profile),Promise.all(Object.entries(queries).map(async([name,query])=>[name,await result(query)]))]);
   return {...base,...Object.fromEntries(entries)};
  },
  banners(){return banners();},
  rpc,
  async conversations(){const response=await supabase.rpc('chat_inbox');if(!response.error)return response.data||[];if(!['PGRST202','42883'].includes(response.error.code))throw response.error;return result(supabase.from('conversations').select('*,members:conversation_members(*)').order('created_at',{ascending:false}).limit(100));},
  async startSupportEnquiry({title,requestId}){try{return await rpc('start_support_enquiry',{p_title:title,p_request_id:requestId});}catch(error){if(['PGRST202','42883'].includes(error.code))throw new Error('New enquiry topics need supabase/009-chat-inbox.sql. Ask the project owner to apply this update. Existing chats are still available.');throw error;}},
  sendMessage({conversationId,body,productId=null,clientId}){return rpc('send_chat_message',{p_conversation_id:conversationId,p_body:body,p_product_id:productId,p_client_message_id:clientId});},
  order(id){return result(supabase.from('orders').select('*,items:order_items(*),events:order_events(*)').eq('id',id).maybeSingle());},
  messages(id,before){let q=supabase.from('messages').select('*').eq('conversation_id',id).order('created_at',{ascending:false}).limit(100);if(before)q=q.lt('created_at',before);return result(q);},
  stats(days){return rpc('dashboard_stats',{p_days:days});},
  subscribe(callback){onChange=callback;const channel=supabase.channel('app-'+crypto.randomUUID());for(const table of ['orders','order_events','products','messages','conversations','notifications','refunds','restock_requests','reviews','promotion_banners'])channel.on('postgres_changes',{event:'*',schema:'public',table},()=>{if(['products','reviews','promotion_banners'].includes(table))invalidate();onChange(table);});channel.subscribe();return()=>supabase.removeChannel(channel);},
  async upload(file,bucket,orderId){
   if(!file||file.size>5*1024*1024)throw new Error('Choose a file smaller than 5 MB.');
   const types=bucket==='payment-proofs'?['image/jpeg','image/png','application/pdf']:['image/jpeg','image/png','image/webp'];
   if(!types.includes(file.type))throw new Error('Unsupported file type. Use JPG, PNG'+(bucket==='payment-proofs'?' or PDF.':' or WebP.'));
   const user=await this.session();if(!user)throw new Error('Sign in before uploading.');
   let body=file,type=file.type,extension=type==='application/pdf'?'pdf':type==='image/png'?'png':type==='image/webp'?'webp':'jpg';
   if(type==='application/pdf'){const header=new TextDecoder().decode(await file.slice(0,5).arrayBuffer());if(header!=='%PDF-')throw new Error('This does not appear to be a PDF file.');}
   else {
    const bitmap=await createImageBitmap(file).catch(()=>{throw new Error('This image cannot be decoded. Choose a valid image.');});
    if(bitmap.width>6000||bitmap.height>6000){bitmap.close();throw new Error('Use an image no larger than 6000 × 6000 pixels.');}
    const scale=Math.min(1,(bucket==='promotion-banners'?1920:1600)/Math.max(bitmap.width,bitmap.height)),canvas=document.createElement('canvas');canvas.width=Math.round(bitmap.width*scale);canvas.height=Math.round(bitmap.height*scale);canvas.getContext('2d').drawImage(bitmap,0,0,canvas.width,canvas.height);bitmap.close();
    const outputType=bucket==='promotion-banners'?'image/webp':'image/jpeg';body=await new Promise(resolve=>canvas.toBlob(resolve,outputType,.86));if(!body)throw new Error('Image processing failed.');type=outputType;extension=outputType==='image/webp'?'webp':'jpg';
   }
   const path=bucket==='payment-proofs'?`${user.id}/${orderId}/${crypto.randomUUID()}.${extension}`:`${user.id}/${crypto.randomUUID()}.${extension}`;
   await result(supabase.storage.from(bucket).upload(path,body,{contentType:type,upsert:false}));
   return bucket==='payment-proofs'?path:supabase.storage.from(bucket).getPublicUrl(path).data.publicUrl;
  },
  async proofUrl(path){const data=await result(supabase.storage.from('payment-proofs').createSignedUrl(path,60));return data.signedUrl;},
  async inviteUser(values){const session=await supabase.auth.getSession();const response=await fetch('/api/admin-users',{method:'POST',headers:{'Content-Type':'application/json',Authorization:'Bearer '+session.data.session?.access_token},body:JSON.stringify(values)});const data=await response.json().catch(()=>({error:'Server response could not be read.'}));if(!response.ok)throw new Error(data.error||'User creation failed.');return data;},
  async deleteUser(id){const session=await supabase.auth.getSession();const response=await fetch('/api/admin-users',{method:'DELETE',headers:{'Content-Type':'application/json',Authorization:'Bearer '+session.data.session?.access_token},body:JSON.stringify({id})});const data=await response.json().catch(()=>({error:'Server response could not be read.'}));if(!response.ok)throw new Error(data.error||'User deletion failed.');return data;}
 };
}
export const repository=preview?(await import('./preview-repository.mjs')).createPreviewRepository():configured?createLiveRepository():null;
