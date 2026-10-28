import {readFile,writeFile,mkdir} from 'node:fs/promises';
import {addSampleScenario} from '../src/sample-scenario.mjs';
import {previewAnalytics} from '../src/preview-analytics.mjs';
const root=new URL('../',import.meta.url),now=Date.now();
const catalogue=JSON.parse(await readFile(new URL('data/catalogue.json',root),'utf8'));
const base={users:[{id:'seed-admin',role:'admin'},{id:'seed-worker',role:'worker'}],products:catalogue.map((p,i)=>({...p,stock:i>=catalogue.length-3?0:i>=catalogue.length-8?4+i%5:120+(i*7)%140,price_cents:Math.round(p.price*100),price_confirmed:true,active:true})),settings:{shipping_cents:1500,free_shipping_cents:25000,bank_name:'DEMO — DO NOT TRANSFER',bank_account_name:'FICTIONAL EXAMPLE ONLY',bank_account_number:'0000000000'},orders:[],refunds:[],reviews:[],wishlist:[],activity:[]};
const scenario=addSampleScenario(base,{now});
const payload={...scenario,sample_summary:scenario.sample_summary,users:scenario.users.filter(u=>u.role==='customer'),products:undefined,settings:undefined};
const template=await readFile(new URL('scripts/templates/sample-analytics.sql',root),'utf8');
await mkdir(new URL('supabase/examples/',root),{recursive:true});
await writeFile(new URL('supabase/examples/seed-analytics.sql',root),template.replace('__SAMPLE_PAYLOAD__',JSON.stringify(payload,null,2)));
console.log('Generated test-only supabase/examples/seed-analytics.sql. Nothing was sent to Supabase.');
for(const days of [7,30,90]){const report=previewAnalytics(scenario,days,now);console.log(`${days} days: ${report.orders} orders, ${report.paid_orders} verified, RM ${(report.paid_sales_cents/100).toFixed(2)} paid sales.`);}
console.log(`Inventory: ${scenario.products.filter(p=>p.stock>=10).length} available, ${scenario.products.filter(p=>p.stock>0&&p.stock<10).length} low-stock, ${scenario.products.filter(p=>p.stock===0).length} sold-out products.`);
