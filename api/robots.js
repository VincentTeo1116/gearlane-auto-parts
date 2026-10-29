/* GET /robots.txt (rewritten here by vercel.json). The sitemap line must be an absolute URL, so it is built from SITE_URL. */
export function robotsTxt(origin){
  return ['User-agent: *','Allow: /','Disallow: /workspace','Disallow: /account','Disallow: /cart','Disallow: /checkout','Disallow: /orders','Disallow: /messages','Disallow: /wishlist','Disallow: /api/','','Sitemap: '+origin+'/sitemap.xml',''].join('\n');
}
export function createHandler({env=process.env}={}){
 return async(req,res)=>{
  let origin;try{origin=new URL(env.SITE_URL).origin;}catch{return res.status(503).end();}
  res.setHeader('Content-Type','text/plain; charset=utf-8');
  res.setHeader('Cache-Control','public, s-maxage=86400');
  return res.status(200).send(robotsTxt(origin));
 };
}
export default createHandler();
