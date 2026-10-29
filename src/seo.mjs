/* Search-engine and social metadata for each page. Pure functions: easy to test, no DOM access.
   Public pages get a real title, description, canonical link and (for products) structured data.
   Private pages (cart, account, orders, staff) are marked noindex. */
const PRIVATE=/^\/(cart|checkout|account|orders|messages|wishlist|workspace)(\/|$)/;
const clip=(text,max)=>{const t=String(text||'').replace(/\s+/g,' ').trim();return t.length>max?t.slice(0,max-1).trimEnd()+'…':t;};

export function seoFor({route,origin,products=[],reviews=[],storeName='GearLane Auto Parts'}){
  const [path,query='']=route.split('?'),params=new URLSearchParams(query);
  const base={title:storeName+' — Parts for the road ahead',description:'Shop automotive service parts, oils, filters and workshop essentials. Get help confirming the correct part for your vehicle.',canonical:origin+'/',robots:'index,follow',jsonLd:null,type:'website'};
  if(PRIVATE.test(path))return{...base,title:storeName,canonical:origin+path,robots:'noindex,nofollow'};
  if(path==='/shop'){
    const category=params.get('category'),searching=params.get('q');
    const title=category?`${category} — ${storeName}`:`Shop all parts — ${storeName}`;
    const count=products.filter(p=>p.active&&(!category||p.category===category)).length;
    return{...base,title:searching?`Search results — ${storeName}`:title,description:category?`Browse ${count} ${category.toLowerCase()} products with specifications and prices. Ask the seller to confirm fitment before you order.`:`Browse ${count} automotive parts with specifications and prices. Ask the seller to confirm fitment before you order.`,canonical:origin+'/shop'+(category?'?category='+encodeURIComponent(category):''),robots:searching||params.get('page')||params.get('brand')||params.get('stock')||params.get('vehicle')?'noindex,follow':'index,follow'};
  }
  const match=/^\/products\/([^/]+)$/.exec(path);
  if(match){
    const product=products.find(p=>p.id===decodeURIComponent(match[1])&&p.active);
    if(!product)return{...base,title:'Page not found — '+storeName,robots:'noindex,nofollow',canonical:origin+path};
    const own=reviews.filter(r=>r.product_id===product.id&&r.published),url=origin+'/products/'+encodeURIComponent(product.id);
    const jsonLd={'@context':'https://schema.org','@type':'Product',name:product.name,sku:product.sku,brand:{'@type':'Brand',name:product.brand},category:product.category,description:clip(product.description,500),url};
    if(product.image_url)jsonLd.image=product.image_url;
    // Only state a price when the store has confirmed it; a supplier reference price must not appear as an offer.
    if(product.price_confirmed)jsonLd.offers={'@type':'Offer',url,priceCurrency:'MYR',price:(product.price_cents/100).toFixed(2),availability:product.stock>0?'https://schema.org/InStock':'https://schema.org/OutOfStock',itemCondition:'https://schema.org/NewCondition'};
    if(own.length)jsonLd.aggregateRating={'@type':'AggregateRating',ratingValue:(own.reduce((s,r)=>s+r.rating,0)/own.length).toFixed(1),reviewCount:own.length,bestRating:5,worstRating:1};
    return{...base,type:'product',title:`${product.name} — ${storeName}`,description:clip(`${product.brand} ${product.category}. ${product.description}`,155),canonical:url,jsonLd};
  }
  return path==='/'?base:{...base,title:'Page not found — '+storeName,robots:'noindex,nofollow',canonical:origin+path};
}

/* Writes the metadata into <head>. Existing tags are updated in place so nothing is duplicated. */
export function applySeo(seo,doc=document){
  doc.title=seo.title;
  const meta=(attr,key,value)=>{let el=doc.head.querySelector(`meta[${attr}="${key}"]`);if(!el){el=doc.createElement('meta');el.setAttribute(attr,key);doc.head.appendChild(el);}el.setAttribute('content',value);};
  meta('name','description',seo.description);meta('name','robots',seo.robots);
  meta('property','og:title',seo.title);meta('property','og:description',seo.description);meta('property','og:type',seo.type);meta('property','og:url',seo.canonical);
  let link=doc.head.querySelector('link[rel="canonical"]');if(!link){link=doc.createElement('link');link.rel='canonical';doc.head.appendChild(link);}link.href=seo.canonical;
  let script=doc.head.querySelector('script[data-seo="jsonld"]');
  if(seo.jsonLd){if(!script){script=doc.createElement('script');script.type='application/ld+json';script.dataset.seo='jsonld';doc.head.appendChild(script);}script.textContent=JSON.stringify(seo.jsonLd).replace(/</g,'\\u003c');}
  else script?.remove();
}
