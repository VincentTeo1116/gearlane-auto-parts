import {createClient} from '@supabase/supabase-js';
import {z} from 'zod';
const invitation=z.object({name:z.string().trim().min(2).max(100),email:z.email().max(254),role:z.enum(['customer','worker','admin'])}).strict();
const deletion=z.object({id:z.uuid()}).strict();
function invitationFailure(error){
 const code=String(error?.code||''),message=String(error?.message||'');
 if(['over_email_send_rate_limit','over_request_rate_limit'].includes(code)||error?.status===429||/rate.?limit|too many (?:requests|emails)/i.test(message))return{status:429,code:'invitation_rate_limited',error:'Supabase email sending is rate-limited. Wait for the quota to reset before retrying. For regular invitations, configure custom SMTP in Supabase Authentication settings.'};
 if(['email_exists','user_already_exists'].includes(code)||/already.*(?:registered|exists)/i.test(message))return{status:409,code:'invitation_email_exists',error:'An account already exists for this email. Review its status in Users & roles or Supabase Authentication → Users instead of creating another account.'};
 if(code==='email_address_not_authorized'||/can only send.*email|email.*not authorized/i.test(message))return{status:422,code:'invitation_recipient_restricted',error:'Supabase email delivery is restricted for this recipient. Configure custom SMTP in Supabase Authentication settings to invite other email addresses.'};
 if(code==='email_address_invalid')return{status:422,code:'invitation_invalid_email',error:'Supabase rejected this email address. Check the address before retrying.'};
 if(['signup_disabled','email_provider_disabled'].includes(code))return{status:503,code:'invitation_email_disabled',error:'Email invitations are disabled in Supabase. Review the email provider and signup settings.'};
 if(['not_admin','no_authorization','bad_jwt'].includes(code)||[401,403].includes(error?.status))return{status:503,code:'invitation_server_config',error:'Supabase rejected the server invitation credentials. Verify that SUPABASE_SERVICE_ROLE_KEY belongs to the configured Supabase project.'};
 if(Number(error?.status)>=500)return{status:502,code:'invitation_delivery_failed',error:'Supabase could not send the invitation. Check Authentication logs and SMTP settings before retrying.'};
 return{status:400,code:'invitation_rejected',error:'Supabase rejected the invitation. Check its Authentication logs for the detailed reason.'};
}
export function createHandler({client=createClient,env=process.env}={}){
 return async(req,res)=>{
  res.setHeader('Cache-Control','no-store');
  const fail=(code,error)=>res.status(code).json({error});
  if(!['POST','DELETE'].includes(req.method)){res.setHeader('Allow','POST, DELETE');return fail(405,'Method not allowed.');}
  const url=env.SUPABASE_URL,publicKey=env.SUPABASE_PUBLISHABLE_KEY,secret=env.SUPABASE_SERVICE_ROLE_KEY;
  if(!url||!publicKey||!secret||!env.SITE_URL)return fail(503,'User administration requires the Vercel server environment.');
  let origin;try{origin=new URL(env.SITE_URL).origin;}catch{return fail(503,'Invalid server site configuration.');}
  if(req.headers.origin!==origin)return fail(403,'Request origin is not allowed.');
  const token=/^Bearer ([A-Za-z0-9._-]+)$/.exec(req.headers.authorization||'')?.[1];
  if(!token)return fail(401,'Sign in again before managing users.');
  if(Number(req.headers['content-length']||0)>4096)return fail(413,'Request is too large.');
  try{
   const caller=client(url,publicKey,{auth:{persistSession:false,autoRefreshToken:false},global:{headers:{Authorization:'Bearer '+token}}});
   const {data:auth,error:authError}=await caller.auth.getUser(token);
   if(authError||!auth?.user)return fail(401,'Your session is invalid or expired.');
   const {data:profile,error:profileError}=await caller.from('profiles').select('role,is_active').eq('id',auth.user.id).single();
   if(profileError||profile?.role!=='admin'||!profile.is_active)return fail(403,'Active administrator access is required.');
   let body=req.body;if(typeof body==='string'){if(body.length>4096)return fail(413,'Request is too large.');try{body=JSON.parse(body);}catch{return fail(400,'Provide valid JSON.');}}
   if(JSON.stringify(body||{}).length>4096)return fail(413,'Request is too large.');
   const parsed=(req.method==='POST'?invitation:deletion).safeParse(body);
   if(!parsed.success)return fail(400,'Check the email, name, role or user identifier.');
   const service=client(url,secret,{auth:{persistSession:false,autoRefreshToken:false}});
   if(req.method==='POST'){
    const value=parsed.data;
    const {data,error}=await service.auth.admin.inviteUserByEmail(value.email,{redirectTo:origin+'/account?reset=1',data:{full_name:value.name}});
    if(error){const failure=invitationFailure(error);return res.status(failure.status).json({error:failure.error,code:failure.code});}
    if(!data?.user)return fail(502,'Supabase did not confirm an invited account. Check Authentication logs before retrying.');
    const assigned=await caller.rpc('admin_update_profile',{p_user_id:data.user.id,p_name:value.name,p_role:value.role,p_active:true});
    if(assigned.error){await service.auth.admin.deleteUser(data.user.id);return fail(409,'Role assignment failed. Refresh and try again.');}
    return res.status(201).json({id:data.user.id,message:'Invitation created.'});
   }
   if(parsed.data.id===auth.user.id)return fail(409,'You cannot delete your own administrator account.');
   const {count,error:historyError}=await service.from('orders').select('id',{count:'exact',head:true}).eq('customer_id',parsed.data.id);
   if(historyError)return fail(503,'Could not verify account history.');
   if(count)return fail(409,'This user has order history. Deactivate the account to preserve business records.');
   const {error}=await service.auth.admin.deleteUser(parsed.data.id);
   if(error)return fail(409,'This account has related records. Deactivate it instead.');
   return res.status(200).json({message:'User deleted.'});
  }catch{return fail(503,'User administration is temporarily unavailable. Please try again.');}
 };
}
export default createHandler();
