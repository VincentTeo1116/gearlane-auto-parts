import test from 'node:test';
import assert from 'node:assert/strict';
import {seoFor} from '../src/seo.mjs';
import {buildSitemap,createHandler as sitemap} from '../api/sitemap.js';
import {robotsTxt,createHandler as robots} from '../api/robots.js';

const origin='https://store.example';
const products=[
  {id:'oil-1',sku:'OIL-1',name:'Engine Oil 4L',brand:'Toyota',category:'Engine Oil',description:'A synthetic oil for modern petrol engines.',price_cents:13000,price_confirmed:true,stock:5,active:true,image_url:null},
  {id:'ref-1',sku:'REF-1',name:'Reference Pads',brand:'Test',category:'Brake Pads',description:'Supplier reference listing only for brake pads.',price_cents:3800,price_confirmed:false,stock:0,active:true},
  {id:'old-1',sku:'OLD-1',name:'Archived Filter',brand:'Test',category:'Filters',description:'No longer sold in the store catalogue.',price_cents:1000,price_confirmed:true,stock:3,active:false},
];
const reviews=[{product_id:'oil-1',rating:5,published:true},{product_id:'oil-1',rating:4,published:true},{product_id:'oil-1',rating:1,published:false}];

test('public pages get descriptive metadata and canonical links',()=>{
  const home=seoFor({route:'/',origin,products});assert.equal(home.robots,'index,follow');assert.equal(home.canonical,origin+'/');
  const cat=seoFor({route:'/shop?category=Engine%20Oil&sort=price-low',origin,products});
  assert.match(cat.title,/^Engine Oil/);assert.equal(cat.canonical,origin+'/shop?category=Engine%20Oil','sort parameters never create duplicate canonicals');assert.match(cat.description,/1 engine oil products/);
  assert.equal(seoFor({route:'/shop?q=oil',origin,products}).robots,'noindex,follow','search results are not indexed');
  assert.equal(seoFor({route:'/shop?page=2',origin,products}).robots,'noindex,follow');
});
test('private and unknown pages are never indexed',()=>{
  for(const route of ['/cart','/checkout','/account','/orders/123','/messages','/wishlist','/workspace/orders'])assert.equal(seoFor({route,origin,products}).robots,'noindex,nofollow',route);
  assert.equal(seoFor({route:'/nope',origin,products}).robots,'noindex,nofollow');
  assert.equal(seoFor({route:'/products/old-1',origin,products}).robots,'noindex,nofollow','archived products disappear from search');
});
test('product pages carry structured data, and only confirmed prices become offers',()=>{
  const page=seoFor({route:'/products/oil-1',origin,products,reviews}),ld=page.jsonLd;
  assert.equal(ld['@type'],'Product');assert.equal(ld.offers.price,'130.00');assert.equal(ld.offers.priceCurrency,'MYR');assert.match(ld.offers.availability,/InStock/);
  assert.deepEqual([ld.aggregateRating.ratingValue,ld.aggregateRating.reviewCount],['4.5',2],'hidden reviews are not counted');
  assert.ok(page.description.length<=155);
  const unconfirmed=seoFor({route:'/products/ref-1',origin,products,reviews}).jsonLd;
  assert.equal('offers' in unconfirmed,false,'a supplier reference price is never published as an offer');assert.equal('aggregateRating' in unconfirmed,false);
});
test('sitemap lists public pages only and escapes everything',()=>{
  const xml=buildSitemap(origin,[{id:'a&b',category:'Oil & Fluids',updated_at:'2026-10-01T00:00:00Z'},{id:'x',category:'Filters'}]);
  assert.match(xml,/<loc>https:\/\/store\.example\/<\/loc>/);assert.match(xml,/products\/a%26b<\/loc><lastmod>2026-10-01/);assert.match(xml,/category=Oil%20%26%20Fluids/);
  assert.equal(xml.includes('/workspace'),false);assert.equal(xml.includes('/account'),false);assert.equal(xml.includes('a&b'),false,'raw ampersands never reach the XML');
});
test('sitemap and robots endpoints fail closed and use the public key only',async()=>{
  const res=()=>({code:200,headers:{},body:'',setHeader(k,v){this.headers[k]=v;},status(n){this.code=n;return this;},send(b){this.body=b;return this;},end(){return this;}});
  const env={SUPABASE_URL:'https://x.supabase.co',SUPABASE_PUBLISHABLE_KEY:'public',SUPABASE_SERVICE_ROLE_KEY:'secret',SITE_URL:origin};
  let usedKey,filters=[];
  const client=(url,key)=>{usedKey=key;return{from(){return{select(){return{eq(f,v){filters.push([f,v]);return{order(){return{limit:async()=>({data:[{id:'oil-1',category:'Engine Oil'}],error:null})};}};}};}};}};};
  let r=res();await sitemap({client,env})({method:'GET'},r);
  assert.equal(r.code,200);assert.equal(usedKey,'public');assert.deepEqual(filters,[['active',true]]);assert.match(r.headers['Content-Type'],/xml/);assert.match(r.body,/products\/oil-1/);
  r=res();await sitemap({client,env:{...env,SITE_URL:''}})({method:'GET'},r);assert.equal(r.code,503);
  r=res();await sitemap({client:()=>{throw new Error('x');},env})({method:'GET'},r);assert.equal(r.code,503);
  r=res();await sitemap({client,env})({method:'POST'},r);assert.equal(r.code,405);
  r=res();await robots({env})({method:'GET'},r);
  assert.match(r.body,/Disallow: \/workspace/);assert.match(r.body,/Sitemap: https:\/\/store\.example\/sitemap\.xml/);assert.equal(robotsTxt(origin).includes('secret'),false);
});
