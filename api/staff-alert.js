import {createClient} from '@supabase/supabase-js';
import {z} from 'zod';

/* POST /api/staff-alert  { conversation_id }
   Emails the STORE OWNER (STAFF_ALERT_EMAIL) when a customer writes to the seller, so they know to reply in the
   workspace. This works with Resend's free onboarding sender, which can only deliver to the account owner.
   The browser calls it after a message is sent. The server never trusts the request for content:
   - the caller must be signed in and be the customer of that support conversation (checked with row-level security);
   - the text comes from the newest message in the database, which must be the caller's own and under 3 minutes old,
     so the endpoint cannot be used to email arbitrary text or to replay old messages;
   - at most one email per conversation every 5 minutes (staff_alerts), however many messages arrive;
   - the recipient is always STAFF_ALERT_EMAIL, never taken from the request. */
const body=z.object({conversation_id:z.uuid()}).strict();
export const THROTTLE_MS=5*60*1000,FRESH_MS=3*60*1000;
export const esc=s=>String(s??'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
const clip=(text,max)=>{const t=String(text||'').replace(/\s+/g,' ').trim();return t.length>max?t.slice(0,max-1).trimEnd()+'…':t;};

export function composeAlert({customerName,message,productName,link,storeName}){
  const who=clip(customerName,60)||'A customer',snippet=clip(message,300),subject=`New message from ${who}`;
  const intro=`${who} wrote to ${storeName}:`;
  const text=`${intro}\n\n"${snippet}"\n${productName?`\nAbout: ${productName}\n`:''}\nReply in the workspace (replying to this email does not reach the customer):\n${link}\n`;
  const html=`<div style="font-family:Arial,Helvetica,sans-serif;max-width:560px;margin:auto;color:#1b3547"><h2 style="margin:0 0 12px">${esc(subject)}</h2><p>${esc(intro)}</p><blockquote style="margin:0 0 12px;padding:12px 16px;background:#f1f6fa;border-left:4px solid #c2410c;border-radius:6px">${esc(snippet)}</blockquote>${productName?`<p style="margin:0 0 12px">About: <b>${esc(productName)}</b></p>`:''}<p><a href="${esc(link)}" style="display:inline-block;background:#c2410c;color:#fff;text-decoration:none;padding:12px 20px;border-radius:8px;font-weight:bold">Open the conversation</a></p><p style="color:#5b6c76;font-size:13px">Reply to the customer inside the workspace. Replying to this email does not reach them.</p></div>`;
  return {subject,text,html};
}

export function createHandler({client=createClient,env=process.env,fetcher=fetch,now=()=>Date.now()}={}){
 return async(req,res)=>{
  res.setHeader('Cache-Control','no-store');
  const fail=(code,error)=>res.status(code).json({error});
  if(req.method!=='POST'){res.setHeader('Allow','POST');return fail(405,'Method not allowed.');}
  const url=env.SUPABASE_URL,publicKey=env.SUPABASE_PUBLISHABLE_KEY,secret=env.SUPABASE_SERVICE_ROLE_KEY;
  if(!url||!publicKey||!secret||!env.SITE_URL||!env.RESEND_API_KEY||!env.EMAIL_FROM||!env.STAFF_ALERT_EMAIL)return fail(503,'Staff alerts are not configured.');
  let origin;try{origin=new URL(env.SITE_URL).origin;}catch{return fail(503,'Staff alerts are not configured.');}
  if(req.headers.origin!==origin)return fail(403,'Request origin is not allowed.');
  const token=/^Bearer ([A-Za-z0-9._-]+)$/.exec(req.headers.authorization||'')?.[1];
  if(!token)return fail(401,'Sign in again.');
  if(Number(req.headers['content-length']||0)>512)return fail(413,'Request is too large.');
  let payload=req.body;if(typeof payload==='string'){if(payload.length>512)return fail(413,'Request is too large.');try{payload=JSON.parse(payload);}catch{return fail(400,'Provide valid JSON.');}}
  const parsed=body.safeParse(payload);if(!parsed.success)return fail(400,'Check the conversation.');
  const conversationId=parsed.data.conversation_id;
  let service,claim=null;
  try{
   const caller=client(url,publicKey,{auth:{persistSession:false,autoRefreshToken:false},global:{headers:{Authorization:'Bearer '+token}}});
   const {data:auth,error:authError}=await caller.auth.getUser(token);
   if(authError||!auth?.user)return fail(401,'Your session is invalid or expired.');
   // Row-level security means only a participant gets a row back.
   const {data:conversation,error:conversationError}=await caller.from('conversations').select('id,kind,customer_id,title').eq('id',conversationId).maybeSingle();
   if(conversationError)return fail(503,'Could not check the conversation.');
   if(!conversation)return fail(404,'Conversation not found.');
   if(conversation.kind!=='support'||conversation.customer_id!==auth.user.id)return res.status(200).json({sent:false,reason:'not_a_customer_message'});
   const {data:latest,error:messageError}=await caller.from('messages').select('id,body,sender_id,sender_name,product_id,created_at').eq('conversation_id',conversationId).order('created_at',{ascending:false}).limit(1).maybeSingle();
   if(messageError)return fail(503,'Could not check the message.');
   if(!latest||latest.sender_id!==auth.user.id||now()-new Date(latest.created_at).getTime()>FRESH_MS)return res.status(200).json({sent:false,reason:'no_recent_message'});
   let productName=null;
   if(latest.product_id){const {data:product}=await caller.from('products').select('name').eq('id',latest.product_id).maybeSingle();productName=product?.name||null;}
   service=client(url,secret,{auth:{persistSession:false,autoRefreshToken:false}});
   // One email per conversation per 5 minutes. Claim the slot first so two quick messages cannot both send.
   const stamp=new Date(now()).toISOString(),cutoff=new Date(now()-THROTTLE_MS).toISOString();
   const inserted=await service.from('staff_alerts').insert({conversation_id:conversationId,last_sent_at:stamp});
   if(!inserted.error)claim='inserted';
   else if(inserted.error.code==='23505'){
    const updated=await service.from('staff_alerts').update({last_sent_at:stamp}).eq('conversation_id',conversationId).lt('last_sent_at',cutoff).select('conversation_id');
    if(updated.error)return fail(503,'Could not record the alert.');
    if(!updated.data?.length)return res.status(200).json({sent:false,reason:'throttled'});
    claim='updated';
   }else return fail(503,'Could not record the alert.');
   const {data:settings}=await service.from('public_store_settings').select('store_name').eq('id',1).single();
   const mail=composeAlert({customerName:latest.sender_name,message:latest.body,productName,link:origin+'/workspace/messages?conversation='+conversationId,storeName:settings?.store_name||'GearLane Auto Parts'});
   const response=await fetcher('https://api.resend.com/emails',{method:'POST',headers:{Authorization:'Bearer '+env.RESEND_API_KEY,'Content-Type':'application/json'},body:JSON.stringify({from:env.EMAIL_FROM,to:[env.STAFF_ALERT_EMAIL],subject:mail.subject,html:mail.html,text:mail.text})});
   if(!response.ok){await release(service,conversationId,claim);claim=null;return fail(502,'The email provider did not accept the message.');}
   return res.status(200).json({sent:true});
  }catch{
   if(claim&&service)try{await release(service,conversationId,claim);}catch{}
   return fail(503,'Staff alerts are temporarily unavailable.');
  }
 };
}
// A failed send must not silence the next attempt: remove a new slot, or make an updated one old again.
async function release(service,conversationId,claim){
 if(claim==='inserted')await service.from('staff_alerts').delete().eq('conversation_id',conversationId);
 else await service.from('staff_alerts').update({last_sent_at:new Date(0).toISOString()}).eq('conversation_id',conversationId);
}
export default createHandler();
