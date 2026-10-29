/* Browser error log: POST /api/client-error.
   The page reports uncaught errors here and they are written as ONE structured line to the Vercel
   function logs (searchable, and forwardable through a Vercel log drain). Nothing is stored and no
   account is needed. Because it is unauthenticated it is deliberately small and defensive:
   same-origin only, tiny body, fixed fields, text truncated, and a per-instance rate limit. */
const FIELDS={message:300,source:200,stack:1500,route:200,kind:20,userAgent:200};
const buckets=new Map();

export function allow(key,now=Date.now(),limit=20,windowMs=60000){
 const bucket=buckets.get(key)?.filter(t=>now-t<windowMs)||[];
 if(bucket.length>=limit){buckets.set(key,bucket);return false;}
 bucket.push(now);buckets.set(key,bucket);
 if(buckets.size>500)for(const [k,v] of buckets)if(!v.some(t=>now-t<windowMs))buckets.delete(k);
 return true;
}
const clean=(value,max)=>String(value??'').replace(/[\u0000-\u001f\u007f]/g,' ').slice(0,max);

export function createHandler({env=process.env,log=entry=>console.error(JSON.stringify(entry)),now=()=>Date.now()}={}){
 return async(req,res)=>{
  res.setHeader('Cache-Control','no-store');
  if(req.method!=='POST'){res.setHeader('Allow','POST');return res.status(405).json({ok:false});}
  let origin;try{origin=new URL(env.SITE_URL).origin;}catch{return res.status(503).json({ok:false});}
  if(req.headers.origin!==origin)return res.status(403).json({ok:false});
  if(Number(req.headers['content-length']||0)>4096)return res.status(413).json({ok:false});
  let body=req.body;
  if(typeof body==='string'){if(body.length>4096)return res.status(413).json({ok:false});try{body=JSON.parse(body);}catch{return res.status(400).json({ok:false});}}
  if(!body||typeof body!=='object'||Array.isArray(body))return res.status(400).json({ok:false});
  const ip=String(req.headers['x-forwarded-for']||'unknown').split(',')[0].trim();
  if(!allow(ip,now()))return res.status(429).json({ok:false});
  const entry={type:'client_error',at:new Date(now()).toISOString()};
  for(const [field,max] of Object.entries(FIELDS))if(body[field]!==undefined)entry[field]=clean(body[field],max);
  if(!entry.message)return res.status(400).json({ok:false});
  log(entry);
  return res.status(204).end();
 };
}
export default createHandler();
