import test from 'node:test';
import assert from 'node:assert/strict';
import {readFile} from 'node:fs/promises';
import {fitStatus,fitmentByProduct,fitmentFromNames,formatFitmentText,parseFitmentText,parseVehicle,serialiseVehicle,vehicleLabel,vehicleOptions} from '../src/fitment.mjs';

test('admin text becomes validated rows, with clear line-by-line errors',()=>{
  const ok=parseFitmentText('Proton, X50, 2020-2024\nPerodua | Myvi | 2019\nHonda, Civic\n\n  ');
  assert.deepEqual(ok.errors,[]);
  assert.deepEqual(ok.rows,[{make:'Proton',model:'X50',year_from:2020,year_to:2024},{make:'Perodua',model:'Myvi',year_from:2019,year_to:2019},{make:'Honda',model:'Civic',year_from:null,year_to:null}]);
  const bad=parseFitmentText('Proton\nP, X50\nProton, X50, 2024-2020\nProton, X50, soon\nProton, X50, 1900\nProton, X50, 2020\nProton, X50, 2020');
  assert.equal(bad.errors.length,6);assert.match(bad.errors[0],/Line 1/);assert.match(bad.errors[2],/first year/);assert.match(bad.errors[5],/already listed/);
  assert.equal(parseFitmentText(Array.from({length:61},(_,i)=>'Make, M'+i).join('\n')).errors.at(-1),'List at most 60 vehicles per product.');
});
test('text round-trips through the editor',()=>{
  const {rows}=parseFitmentText('Proton, X50, 2020-2024\nPerodua, Myvi, 2019\nHonda, Civic');
  assert.equal(formatFitmentText(rows),'Proton, X50, 2020-2024\nPerodua, Myvi, 2019\nHonda, Civic');
  assert.deepEqual(parseFitmentText(formatFitmentText(rows)).rows,rows);
});
test('fit status never treats missing information as "does not fit"',()=>{
  const rows=[{make:'Proton',model:'X50',year_from:2020,year_to:2024}];
  assert.equal(fitStatus(rows,{make:'proton',model:' x50 ',year:2022}),'yes','case and spacing do not matter');
  assert.equal(fitStatus(rows,{make:'Proton',model:'X50',year:2018}),'no','year outside the listed range');
  assert.equal(fitStatus(rows,{make:'Proton',model:'X50',year:null}),'yes','no year chosen: model match is enough');
  assert.equal(fitStatus(rows,{make:'Proton',model:'X70',year:2022}),'no');
  assert.equal(fitStatus([],{make:'Proton',model:'X50',year:2022}),'unknown','nothing listed means unknown');
  assert.equal(fitStatus(rows,null),'unknown');
  assert.equal(fitStatus([{make:'Honda',model:'Civic',year_from:null,year_to:null}],{make:'Honda',model:'Civic',year:1999}),'yes','all-years rows match any year');
});
test('vehicle picker options come only from listed fitment',()=>{
  const fitment=[{product_id:'a',make:'Proton',model:'X50',year_from:2020,year_to:2022},{product_id:'b',make:'proton',model:'X70',year_from:2021,year_to:2021},{product_id:'b',make:'Perodua',model:'Myvi',year_from:null,year_to:null}];
  const options=vehicleOptions(fitment);
  assert.deepEqual(options.makes,['Perodua','Proton']);assert.deepEqual(options.models('Proton'),['X50','X70']);assert.deepEqual(options.models('Nope'),[]);
  assert.deepEqual(options.years('Proton','X50'),[2022,2021,2020]);assert.deepEqual(options.years('Perodua','Myvi'),[],'all-years models have no fixed list');
  assert.equal(fitmentByProduct(fitment).get('b').length,2);
});
test('vehicle values survive the URL and storage safely',()=>{
  assert.deepEqual(parseVehicle('Proton|X50|2022'),{make:'Proton',model:'X50',year:2022});
  assert.deepEqual(parseVehicle('Proton|X50'),{make:'Proton',model:'X50',year:null});
  assert.equal(parseVehicle('Proton'),null);assert.equal(parseVehicle(''),null);assert.equal(parseVehicle('A|B|abc').year,null);assert.equal(parseVehicle('A|B|1').year,null);
  assert.equal(serialiseVehicle({make:'Proton',model:'X50',year:2022}),'Proton|X50|2022');assert.equal(vehicleLabel({make:'Proton',model:'X50',year:null}),'Proton X50');
});
test('demo fitment is derived only from vehicles the catalogue names already state',async()=>{
  const catalogue=JSON.parse(await readFile(new URL('../data/catalogue.json',import.meta.url),'utf8'));
  const products=(Array.isArray(catalogue)?catalogue:catalogue.products).map((p,i)=>({id:'p'+i,name:p.name}));
  const rows=fitmentFromNames([{id:'x',name:'Cabin Filter for Proton X50'},{id:'y',name:'Front Brake Pads for Proton Gen 2 / Persona / Neo'},{id:'z',name:'Cabin Filter for Perodua Myvi / Alza / Axia / Bezza'},{id:'n',name:'Engine Oil 4L'},{id:'d',name:'Spark Plugs for Honda Civic — 4 Pack'}]);
  assert.deepEqual(rows.filter(r=>r.product_id==='x').map(r=>r.make+' '+r.model),['Proton X50']);
  assert.deepEqual(rows.filter(r=>r.product_id==='y').map(r=>r.make+' '+r.model),['Proton Gen 2','Proton Persona','Proton Neo'],'later models inherit the make');
  assert.deepEqual(rows.filter(r=>r.product_id==='z').map(r=>r.model),['Myvi','Alza','Axia','Bezza']);
  assert.deepEqual(rows.filter(r=>r.product_id==='d').map(r=>r.make+' '+r.model),['Honda Civic'],'a " — 4 Pack" suffix is not part of the model');
  assert.equal(rows.some(r=>r.product_id==='n'),false,'no vehicle in the name, no fitment invented');
  const all=fitmentFromNames(products);assert.ok(all.length>0);assert.ok(all.every(r=>r.make&&r.model&&r.year_from===null));
});
