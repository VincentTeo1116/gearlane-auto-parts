import {readFile} from 'node:fs/promises';
const content=await readFile(new URL('../.env.local',import.meta.url),'utf8');
const env=Object.fromEntries(content.split(/\r?\n/).filter(l=>l&&!l.startsWith('#')).map(l=>{const i=l.indexOf('=');return[l.slice(0,i),l.slice(i+1)];}));
const response=await fetch(env.VITE_SUPABASE_URL+'/rest/v1/products?select=id&limit=100',{headers:{apikey:env.VITE_SUPABASE_PUBLISHABLE_KEY}});
const data=await response.json();
if(!response.ok)throw new Error('Public database check failed: '+response.status+' '+(data.message||''));
console.log(`Supabase public catalogue reachable: ${data.length} products. No private credentials or customer data printed.`);
