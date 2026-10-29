import test from 'node:test';
import assert from 'node:assert/strict';
import {csvCell,toCsv,orderColumns,productColumns} from '../src/csv.mjs';

test('cells that a spreadsheet could run as formulas are neutralised',()=>{
  for(const evil of ['=HYPERLINK("http://evil","x")','+1+1','-2+3','@SUM(A1)','\tcmd','\rcmd'])assert.ok(csvCell(evil).replace(/^"/,'').startsWith("'"),evil);
  assert.equal(csvCell(-5),'-5','real negative numbers stay numbers');
  assert.equal(csvCell('Normal name'),'Normal name');
});
test('commas, quotes and line breaks are quoted correctly and nothing is lost',()=>{
  assert.equal(csvCell('Jalan 1, Taman "A"'),'"Jalan 1, Taman ""A"""');
  assert.equal(csvCell('line1\nline2'),'"line1\nline2"');
  assert.equal(csvCell(null),'');assert.equal(csvCell(undefined),'');assert.equal(csvCell(0),'0');assert.equal(csvCell(false),'false');
});
test('orders export has one row per order, ringgit amounts and a UTF-8 marker',()=>{
  const order={order_number:10002,created_at:'2026-10-29T02:46:00Z',address:{name:'=Evil, Ltd',phone:'0123',line1:'1 Jalan Ampang',postcode:'50450',city:'Kuala Lumpur',state:'Kuala Lumpur'},status:'processing',payment_status:'verified',items:[{quantity:2,name:'Oil 4L'},{quantity:1,name:'Filter'}],subtotal_cents:12345,discount_cents:0,shipping_cents:1500,total_cents:13845,promotion_code:null,received_at:null};
  const csv=toCsv([order,order],orderColumns),lines=csv.replace('\uFEFF','').trim().split('\r\n');
  assert.ok(csv.startsWith('\uFEFF'));assert.equal(lines.length,3);
  assert.equal(lines[0].split(',').length,orderColumns.length);
  assert.match(lines[1],/GL-10002/);assert.match(lines[1],/2 x Oil 4L; 1 x Filter/);assert.match(lines[1],/138\.45/);
  assert.match(lines[1],/"'=Evil, Ltd"/,'customer-controlled name is neutralised and quoted');
});
test('products export lists price, stock and status',()=>{
  const csv=toCsv([{sku:'OIL-1',name:'Engine Oil',brand:'Test',category:'Oil',price_cents:5000,price_confirmed:true,stock:7,active:true}],productColumns);
  assert.match(csv,/OIL-1,Engine Oil,Test,Oil,50\.00,yes,7,yes/);
});
