import {createClient} from '@supabase/supabase-js';
import {z} from 'zod';
const invitation=z.object({name:z.string().trim().min(2).max(100),email:z.email().max(254),role:z.enum(['customer','worker','admin'])}).strict();
const deletion=z.object({id:z.uuid()}).strict();
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
    if(error||!data?.user)return fail(400,'Invitation failed. Check whether the email already exists and inspect Supabase email delivery.');
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
