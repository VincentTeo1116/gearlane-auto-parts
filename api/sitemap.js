import {createClient} from '@supabase/supabase-js';

/* GET /sitemap.xml (rewritten here by vercel.json). Lists the home page, the shop, every category and every
   active product, using only the public (anon) key, so it can never expose anything a visitor cannot already see. */
const esc=s=>String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');

export function buildSitemap(origin,products){
  const urls=[{loc:origin+'/'},{loc:origin+'/shop'}];
  for(const category of [...new Set(products.map(p=>p.category))].sort())urls.push({loc:origin+'/shop?category='+encodeURIComponent(category)});
  for(const p of products)urls.push({loc:origin+'/products/'+encodeURIComponent(p.id),lastmod:p.updated_at?String(p.updated_at).slice(0,10):undefined});
  return '<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n'+urls.map(u=>`  <url><loc>${esc(u.loc)}</loc>${u.lastmod?`<lastmod>${esc(u.lastmod)}</lastmod>`:''}</url>`).join('\n')+'\n</urlset>\n';
}

export function createHandler({client=createClient,env=process.env}={}){
 return async(req,res)=>{
  if(!['GET','HEAD'].includes(req.method)){res.setHeader('Allow','GET, HEAD');return res.status(405).end();}
  const url=env.SUPABASE_URL||env.VITE_SUPABASE_URL,key=env.SUPABASE_PUBLISHABLE_KEY||env.VITE_SUPABASE_PUBLISHABLE_KEY;
  let origin;try{origin=new URL(env.SITE_URL).origin;}catch{return res.status(503).end();}
  if(!url||!key)return res.status(503).end();
  try{
   const supabase=client(url,key,{auth:{persistSession:false,autoRefreshToken:false}});
   const {data,error}=await supabase.from('products').select('id,category,updated_at').eq('active',true).order('id').limit(5000);
   if(error)return res.status(503).end();
   res.setHeader('Content-Type','application/xml; charset=utf-8');
   res.setHeader('Cache-Control','public, s-maxage=3600, stale-while-revalidate=86400');
   return res.status(200).send(buildSitemap(origin,data||[]));
  }catch{return res.status(503).end();}
 };
}
export default createHandler();
