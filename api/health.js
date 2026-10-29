import {createClient} from '@supabase/supabase-js';

/* Uptime probe: GET /api/health.
   200 means the site is up AND the database answers a public read; 503 means point your alert at it.
   It returns no configuration, versions or error details. */
export function createHandler({client=createClient,env=process.env}={}){
 return async(req,res)=>{
  res.setHeader('Cache-Control','no-store');
  if(!['GET','HEAD'].includes(req.method)){res.setHeader('Allow','GET, HEAD');return res.status(405).json({status:'error'});}
  const url=env.SUPABASE_URL||env.VITE_SUPABASE_URL,key=env.SUPABASE_PUBLISHABLE_KEY||env.VITE_SUPABASE_PUBLISHABLE_KEY;
  if(!url||!key)return res.status(503).json({status:'unconfigured'});
  try{
   const supabase=client(url,key,{auth:{persistSession:false,autoRefreshToken:false}});
   const started=Date.now();
   const {error}=await Promise.race([
    supabase.from('public_store_settings').select('id').eq('id',1).single(),
    new Promise((_,reject)=>setTimeout(()=>reject(new Error('timeout')),5000)),
   ]);
   if(error)return res.status(503).json({status:'database_error'});
   return res.status(200).json({status:'ok',database_ms:Date.now()-started});
  }catch{return res.status(503).json({status:'database_unreachable'});}
 };
}
export default createHandler();
