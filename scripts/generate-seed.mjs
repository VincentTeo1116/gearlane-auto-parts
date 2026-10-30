import {readFile,writeFile,mkdir} from 'node:fs/promises';
const root=new URL('../',import.meta.url);
const records=JSON.parse(await readFile(new URL('data/catalogue.json',root),'utf8'));
const quote=value=>value==null?'null':"'"+String(value).replaceAll("'","''")+"'";
const seen=new Set();
const lines=records.map(p=>{
  const id=p.id.slice(0,100);if(seen.has(id))throw new Error('Duplicate product ID: '+id);seen.add(id);
  if(!Number.isFinite(p.price)||p.price<=0||p.currency!=='MYR')throw new Error('Invalid researched price.');
  return `(${[id,p.sku,p.name,p.brand,p.category,p.description,JSON.stringify(p.specs),Math.round(p.price*100),p.fitmentNote,p.sourceUrl,p.priceSourceUrl||p.sourceUrl,p.observedAt,p.priceNote||'Supplier reference price; confirm the shop selling price.'].map((v,i)=>i===7?String(v):quote(v)).join(',')})`;
});
const sql=`-- ${records.length} researched reference products. No stock or selling-price confirmation is fabricated.\n-- Existing prices, inventory and product edits are preserved when the seed is rerun.\ninsert into public.products(id,sku,name,brand,category,description,specs,price_cents,fitment_note,source_url,price_source_url,source_observed_at,source_note) values\n${lines.join(',\n')}\non conflict(id) do nothing;\nupdate public.products set reference_price_cents=price_cents where reference_price_cents is null and not price_confirmed;\n`;
await mkdir(new URL('supabase/',root),{recursive:true});
await writeFile(new URL('supabase/005-catalogue.sql',root),sql);
const migrations=await Promise.all(['001-schema.sql','002-commerce.sql','003-workspace.sql','004-storage-realtime.sql','005-catalogue.sql','007-chat-delivery.sql','008-promotion-banners.sql','009-chat-inbox.sql','010-privacy-hardening.sql','011-analytics-previous-period.sql','012-order-emails.sql','013-stock-alerts.sql','014-vehicle-fitment.sql','015-staff-alerts.sql','016-address-book-and-garage.sql','017-product-questions.sql','018-invoice-details.sql'].map(name=>readFile(new URL('supabase/'+name,root),'utf8')));
await writeFile(new URL('supabase/setup.sql',root),'-- GearLane Auto Parts — run once on a NEW Supabase project.\n-- Review before execution. Keep this file with the application version.\n'+migrations.join('\n\n'));
console.log(`Generated ${records.length} reference products and supabase/setup.sql.`);
