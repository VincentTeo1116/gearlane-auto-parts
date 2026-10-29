import {createClient} from '@supabase/supabase-js';
import {z} from 'zod';

/* POST /api/order-email  { order_id, event }
   Sends the customer one email for an order milestone (placed, payment verified/rejected, shipped, delivered,
   cancelled). The browser calls it right after the action succeeds. The server never trusts the caller:
   - the caller must be signed in and able to read that order (customer: own order; staff: any), checked with RLS;
   - the event must match the order's real current state, so nobody can trigger "shipped" for an unshipped order;
   - each (order, event) is sent once, claimed in order_emails before sending and released if sending fails;
   - the recipient is always the order's customer, never taken from the request;
   - emails contain the order number, amount and a link, never bank details or card data. */
const body=z.object({order_id:z.uuid(),event:z.enum(['placed','payment_verified','payment_rejected','shipped','delivered','cancelled'])}).strict();

const STATE={
  placed:o=>o.status==='awaiting_payment',
  payment_verified:o=>o.payment_status==='verified',
  payment_rejected:o=>o.payment_status==='rejected',
  shipped:o=>o.status==='shipped',
  delivered:o=>o.status==='delivered',
  cancelled:o=>o.status==='cancelled',
};
export const esc=s=>String(s??'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
const rm=cents=>'RM '+(Number(cents||0)/100).toFixed(2);

export function composeEmail(event,order,{storeName,link}){
  const ref='GL-'+order.order_number,name=String(order.address?.name||'there').split(' ')[0];
  const lines={
    placed:{subject:`We received your order ${ref}`,intro:`Thanks for your order, ${name}. Your order ${ref} (${rm(order.total_cents)}) is reserved for 24 hours.`,next:'Open your order for the bank-transfer instructions, make the transfer, then submit your bank reference so we can verify it.'},
    payment_verified:{subject:`Payment verified for ${ref}`,intro:`Good news, ${name}. We have verified your payment for order ${ref}.`,next:'We are now preparing your parts. You will get another email when it ships.'},
    payment_rejected:{subject:`Action needed: payment details for ${ref}`,intro:`Hi ${name}, we could not verify the payment details you submitted for order ${ref}.`,next:'Please open your order, check the reference and amount, and submit your details again.'},
    shipped:{subject:`Your order ${ref} has shipped`,intro:`Your order ${ref} is on its way, ${name}.`+(order.carrier?` Carrier: ${order.carrier}.`:'')+(order.tracking_number?` Tracking number: ${order.tracking_number}.`:''),next:'When it arrives, open your order and confirm receipt. Then you can review your items.'},
    delivered:{subject:`Order ${ref} delivered`,intro:`Your order ${ref} is marked as delivered, ${name}.`,next:'If everything is in order, please confirm receipt and tell other buyers what you think of your parts.'},
    cancelled:{subject:`Order ${ref} cancelled`,intro:`Hi ${name}, your order ${ref} has been cancelled.`,next:'If you did not ask for this or you already transferred money, please contact us from your order page.'},
  }[event];
  const text=`${lines.intro}\n\n${lines.next}\n\nView your order: ${link}\n\n${storeName}\nWe will never ask for your banking password or card details by email or chat.`;
  const html=`<div style="font-family:Arial,Helvetica,sans-serif;max-width:560px;margin:auto;color:#1b3547"><h2 style="margin:0 0 12px">${esc(lines.subject)}</h2><p>${esc(lines.intro)}</p><p>${esc(lines.next)}</p><p><a href="${esc(link)}" style="display:inline-block;background:#c2410c;color:#fff;text-decoration:none;padding:12px 20px;border-radius:8px;font-weight:bold">View your order</a></p><p style="color:#5b6c76;font-size:13px">${esc(storeName)}. We will never ask for your banking password or card details by email or chat.</p></div>`;
  return {subject:lines.subject,text,html};
}

export function createHandler({client=createClient,env=process.env,fetcher=fetch}={}){
 return async(req,res)=>{
  res.setHeader('Cache-Control','no-store');
  const fail=(code,error)=>res.status(code).json({error});
  if(req.method!=='POST'){res.setHeader('Allow','POST');return fail(405,'Method not allowed.');}
  // Off by default. Resend can only send to customers once a domain is verified; until then set nothing and no attempt is made.
  if(env.EMAIL_CUSTOMERS!=='true')return res.status(200).json({sent:false,reason:'customer_emails_off'});
  const url=env.SUPABASE_URL,publicKey=env.SUPABASE_PUBLISHABLE_KEY,secret=env.SUPABASE_SERVICE_ROLE_KEY;
  if(!url||!publicKey||!secret||!env.SITE_URL||!env.RESEND_API_KEY||!env.EMAIL_FROM)return fail(503,'Order emails are not configured.');
  let origin;try{origin=new URL(env.SITE_URL).origin;}catch{return fail(503,'Order emails are not configured.');}
  if(req.headers.origin!==origin)return fail(403,'Request origin is not allowed.');
  const token=/^Bearer ([A-Za-z0-9._-]+)$/.exec(req.headers.authorization||'')?.[1];
  if(!token)return fail(401,'Sign in again.');
  if(Number(req.headers['content-length']||0)>1024)return fail(413,'Request is too large.');
  let payload=req.body;if(typeof payload==='string'){if(payload.length>1024)return fail(413,'Request is too large.');try{payload=JSON.parse(payload);}catch{return fail(400,'Provide valid JSON.');}}
  const parsed=body.safeParse(payload);if(!parsed.success)return fail(400,'Check the order and event.');
  const {order_id,event}=parsed.data;
  let claimed=false,service;
  try{
   const caller=client(url,publicKey,{auth:{persistSession:false,autoRefreshToken:false},global:{headers:{Authorization:'Bearer '+token}}});
   const {data:auth,error:authError}=await caller.auth.getUser(token);
   if(authError||!auth?.user)return fail(401,'Your session is invalid or expired.');
   // Reading through the caller's own client applies row-level security: only someone allowed to see this order gets a row.
   const {data:order,error:orderError}=await caller.from('orders').select('id,order_number,customer_id,status,payment_status,total_cents,address,carrier,tracking_number').eq('id',order_id).maybeSingle();
   if(orderError)return fail(503,'Could not check the order.');
   if(!order)return fail(404,'Order not found.');
   if(!STATE[event](order))return fail(409,'This order is not in that state.');
   service=client(url,secret,{auth:{persistSession:false,autoRefreshToken:false}});
   const claim=await service.from('order_emails').insert({order_id,event});
   if(claim.error){if(claim.error.code==='23505')return res.status(200).json({sent:false,reason:'already_sent'});return fail(503,'Could not record the email.');}
   claimed=true;
   const {data:profile}=await service.from('profiles').select('email,is_active').eq('id',order.customer_id).single();
   if(!profile?.email||profile.is_active===false){await service.from('order_emails').delete().match({order_id,event});return res.status(200).json({sent:false,reason:'no_recipient'});}
   const {data:settings}=await service.from('public_store_settings').select('store_name').eq('id',1).single();
   const mail=composeEmail(event,order,{storeName:settings?.store_name||'GearLane Auto Parts',link:origin+'/orders/'+order.id});
   const response=await fetcher('https://api.resend.com/emails',{method:'POST',headers:{Authorization:'Bearer '+env.RESEND_API_KEY,'Content-Type':'application/json'},body:JSON.stringify({from:env.EMAIL_FROM,to:[profile.email],subject:mail.subject,html:mail.html,text:mail.text})});
   if(!response.ok){await service.from('order_emails').delete().match({order_id,event});claimed=false;return fail(502,'The email provider did not accept the message.');}
   return res.status(200).json({sent:true});
  }catch{
   if(claimed&&service)try{await service.from('order_emails').delete().match({order_id,event});}catch{}
   return fail(503,'Order emails are temporarily unavailable.');
  }
 };
}
export default createHandler();
