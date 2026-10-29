/* Vehicle fitment helpers. A product only "fits" a vehicle when an admin has listed it for that vehicle.
   No row for a product means "no fitment information", which is never the same as "does not fit". */
const norm=s=>String(s||'').trim().toLowerCase().replace(/\s+/g,' ');
const YEAR_MIN=1950,YEAR_MAX=2100;

/* "Proton, X50, 2020-2024" | "Perodua | Myvi | 2019" | "Honda, Civic" (all years), one per line */
export function parseFitmentText(text){
  const rows=[],errors=[];
  String(text||'').split(/\r?\n/).forEach((raw,index)=>{
    const line=raw.trim();if(!line)return;
    const parts=line.split(/[|,]/).map(p=>p.trim());
    const fail=message=>errors.push(`Line ${index+1}: ${message}`);
    if(parts.length<2||parts.length>3)return fail('use "Make, Model, Years" (years are optional).');
    const [make,model,years]=parts;
    if(make.length<2||make.length>40)return fail('make must be 2 to 40 characters.');
    if(!model||model.length>60)return fail('model must be 1 to 60 characters.');
    let year_from=null,year_to=null;
    if(years){
      const match=/^(\d{4})(?:\s*[-–]\s*(\d{4}))?$/.exec(years);
      if(!match)return fail('years must look like 2020 or 2018-2023.');
      year_from=Number(match[1]);year_to=Number(match[2]??match[1]);
      if(year_from<YEAR_MIN||year_to>YEAR_MAX)return fail(`years must be between ${YEAR_MIN} and ${YEAR_MAX}.`);
      if(year_from>year_to)return fail('the first year must not be after the last year.');
    }
    if(rows.some(r=>norm(r.make)===norm(make)&&norm(r.model)===norm(model)&&r.year_from===year_from&&r.year_to===year_to))return fail('this vehicle is already listed.');
    rows.push({make,model,year_from,year_to});
  });
  if(rows.length>60)errors.push('List at most 60 vehicles per product.');
  return{rows,errors};
}

export const formatYears=row=>row.year_from==null?'all years':row.year_from===row.year_to?String(row.year_from):`${row.year_from}–${row.year_to}`;
export const formatFitmentText=rows=>rows.map(r=>[r.make,r.model,r.year_from==null?'':r.year_from===r.year_to?r.year_from:`${r.year_from}-${r.year_to}`].filter(x=>x!=='').join(', ')).join('\n');

export function vehicleLabel(vehicle){return vehicle?[vehicle.make,vehicle.model,vehicle.year].filter(Boolean).join(' '):'';}
/* "Make|Model|Year" <-> object, for the URL and for storage */
export function parseVehicle(value){
  const [make,model,year]=String(value||'').split('|');
  if(!make||!model)return null;
  const y=year?Number(year):null;
  return{make,model,year:Number.isInteger(y)&&y>=YEAR_MIN&&y<=YEAR_MAX?y:null};
}
export const serialiseVehicle=v=>v?[v.make,v.model,v.year||''].join('|'):'';

export function vehicleOptions(fitment){
  const makes=new Map();
  for(const row of fitment){
    const make=makes.get(norm(row.make))||{name:row.make,models:new Map()};makes.set(norm(row.make),make);
    const model=make.models.get(norm(row.model))||{name:row.model,years:new Set(),anyYear:false};make.models.set(norm(row.model),model);
    if(row.year_from==null)model.anyYear=true;else for(let y=row.year_from;y<=row.year_to;y++)model.years.add(y);
  }
  const byName=(a,b)=>a.localeCompare(b);
  return{
    makes:[...makes.values()].map(m=>m.name).sort(byName),
    models:make=>[...(makes.get(norm(make))?.models.values()||[])].map(m=>m.name).sort(byName),
    years:(make,model)=>{const m=makes.get(norm(make))?.models.get(norm(model));return m?[...m.years].sort((a,b)=>b-a):[];},
  };
}

/* 'yes' = listed for this vehicle, 'no' = the store lists vehicles for this product but not this one, 'unknown' = no information */
export function fitStatus(rows,vehicle){
  if(!rows.length)return 'unknown';
  if(!vehicle)return 'unknown';
  const match=rows.some(r=>norm(r.make)===norm(vehicle.make)&&norm(r.model)===norm(vehicle.model)&&(vehicle.year==null||r.year_from==null||(vehicle.year>=r.year_from&&vehicle.year<=r.year_to)));
  return match?'yes':'no';
}
export function fitmentByProduct(fitment){
  const map=new Map();
  for(const row of fitment){if(!map.has(row.product_id))map.set(row.product_id,[]);map.get(row.product_id).push(row);}
  return map;
}

/* Demo data only: catalogue names such as "Cabin Filter for Proton X50" or "Brake Pads for Proton Gen 2 / Persona / Neo"
   already name the vehicles in the supplier listing. The live store starts empty and an admin enters real fitment. */
const MAKES=['Proton','Perodua','Toyota','Honda','Nissan','Mazda','Hyundai','Kia','Mitsubishi','Suzuki','Isuzu','Ford','Volkswagen','BMW','Mercedes'];
export function fitmentFromNames(products){
  const rows=[];
  for(const product of products){
    const match=/\bfor\s+(.+?)(?:\s+[—–-]\s+|$)/i.exec(product.name);
    if(!match)continue;
    const list=match[1].split(/\s*\/\s*/);
    let make=null;
    for(const [i,part] of list.entries()){
      const found=MAKES.find(m=>new RegExp('^'+m+'\\b','i').test(part));
      let model=part.trim();
      if(found){make=found;model=part.trim().slice(found.length).trim();}
      else if(i===0)continue;
      if(!make||!model||model.length>60)continue;
      rows.push({id:`demo-${product.id}-${rows.length}`,product_id:product.id,make,model,year_from:null,year_to:null});
    }
  }
  return rows;
}
