import test from 'node:test';
import assert from 'node:assert/strict';
import {buildInvoice,canInvoice,invoiceFileName,invoiceNumber,issueDate} from '../src/invoice.mjs';
import {measure} from '../src/pdf.mjs';
import {money} from '../src/domain.mjs';
import {parsePdf} from './pdf-helpers.mjs';

const GENERATED=new Date('2026-10-30T04:00:00Z');
const settings={store_name:'GearLane Auto Parts',invoice_details:'GearLane Sdn Bhd (Reg. 123456-X)\nSST No: W10-1234\n1 Jalan Demo, 50000 Kuala Lumpur',contact_email:'hello@gearlane.example'};
const order=(extra={})=>({order_number:10001,created_at:'2026-10-27T08:12:00Z',status:'delivered',payment_status:'verified',payment_reference:'MBB-REF-1',subtotal_cents:26000,discount_cents:2600,shipping_cents:1500,total_cents:24900,promotion_code:'SAVE10',address:{name:'Amir Rahman',phone:'0123456789',line1:'12 Jalan Demo, Taman Contoh',city:'Petaling Jaya',postcode:'47300',state:'Selangor'},events:[{event:'payment_verified',created_at:'2026-10-28T02:30:00Z'}],items:[{name:'Toyota Fully Synthetic 0W-20 Engine Oil 4L',sku:'GL-0001',quantity:2,price_cents:13000,line_total_cents:26000}],...extra});
const make=(o=order(),s=settings)=>parsePdf(buildInvoice(o,{settings:s,generatedAt:GENERATED}));
const clean=text=>text.replace(/\s+/g,' ');

test('only orders whose payment was verified (or later refunded) can be invoiced',()=>{
  for(const [state,expected] of [['verified',true],['refunded',true],['awaiting',false],['submitted',false],['rejected',false]])assert.equal(canInvoice(order({payment_status:state})),expected,state);
  assert.equal(canInvoice(null),false);assert.equal(canInvoice(undefined),false);
  assert.throws(()=>buildInvoice(order({payment_status:'submitted'}),{settings}),/once payment has been verified/);
  assert.equal(invoiceNumber(order()),'INV-10001');assert.equal(invoiceFileName(order()),'invoice-GL-10001.pdf');
});
test('the invoice date is the date payment was confirmed, falling back to the order date',()=>{
  assert.equal(issueDate(order()),'2026-10-28T02:30:00Z');
  assert.equal(issueDate(order({events:[]})),'2026-10-27T08:12:00Z');
  assert.equal(issueDate(order({events:[{event:'payment_verified',created_at:'2026-10-26T01:00:00Z'},{event:'payment_verified',created_at:'2026-10-29T01:00:00Z'}]})),'2026-10-29T01:00:00Z','the latest confirmation wins');
});
test('the invoice shows seller, buyer, items, every amount and the payment',()=>{
  const pdf=make();assert.deepEqual(pdf.problems,[]);
  const all=pdf.allText.join('\n');
  for(const expected of ['INVOICE','INV-10001','GL-10001','28 Oct 2026','PAID','GearLane Auto Parts','GearLane Sdn Bhd (Reg. 123456-X)','SST No: W10-1234','1 Jalan Demo, 50000 Kuala Lumpur','hello@gearlane.example','Amir Rahman','12 Jalan Demo, Taman Contoh','47300 Petaling Jaya','Selangor','0123456789','Toyota Fully Synthetic 0W-20 Engine Oil 4L','SKU GL-0001'])assert.ok(all.includes(expected),'missing: '+expected);
  const amounts=pdf.allText.map(clean);
  for(const [text,cents] of [['qty price',13000],['line total',26000],['subtotal',26000],['delivery',1500],['total',24900]])assert.ok(amounts.includes(clean(money(cents))),`${text} ${money(cents)} is shown`);
  assert.ok(amounts.includes('-'+clean(money(2600))),'the discount is shown as a deduction');assert.ok(amounts.includes('Discount (SAVE10)'));
  assert.ok(all.includes('Paid by bank transfer, reference MBB-REF-1, confirmed 28 Oct 2026.'));
  assert.equal(pdf.title,'Invoice INV-10001');assert.ok(all.includes('Amounts are in Malaysian ringgit (MYR). Generated from order GL-10001 on 30 Oct 2026.'));
  assert.ok(all.includes('Page 1 of 1'));
});
test('arithmetic on the page is the order\'s own arithmetic',()=>{
  const o=order();assert.equal(o.subtotal_cents-o.discount_cents+o.shipping_cents,o.total_cents,'the fixture is consistent');
  const text=make(o).allText.map(clean);
  assert.ok(text.includes(clean(money(o.total_cents))));assert.equal(text.includes(clean(money(o.total_cents+100))),false);
});
test('no discount line without a discount, and a refunded order is clearly marked',()=>{
  const none=make(order({discount_cents:0,promotion_code:null,subtotal_cents:26000,total_cents:27500})).allText.join('\n');
  assert.equal(none.includes('Discount'),false);
  const refunded=make(order({payment_status:'refunded',status:'cancelled'}));
  assert.deepEqual(refunded.problems,[]);const text=refunded.allText.join('\n');
  assert.ok(text.includes('REFUNDED'));assert.equal(text.includes('\nPAID'),false);assert.ok(text.includes('A refund was recorded for this order. This invoice is kept for your records.'));
});
test('missing optional details never break the invoice',()=>{
  const minimal=make(order({payment_reference:null,promotion_code:null,events:[],address:{name:'Siti',line1:'1 Lorong Satu, Kampung Baru',city:'KL',postcode:'50300',state:'Kuala Lumpur'}}),{});
  assert.deepEqual(minimal.problems,[]);const text=minimal.allText.join('\n');
  assert.ok(text.includes('GearLane Auto Parts'),'falls back to the default store name');assert.ok(text.includes('Paid by bank transfer.'));assert.equal(text.includes('undefined'),false);assert.equal(text.includes('null'),false);
  assert.deepEqual(make(order({items:[]})).problems,[],'an order with no lines still produces a valid file');
});
test('customer text is escaped, shortened to ASCII and cannot break the file',()=>{
  const hostile=order({address:{name:'Eve (the) \\ Tester 中文',phone:'+60 12-345 6789',line1:'Unit 5) /Type /Page (fake, Jalan Aneh',city:'Shah Alam',postcode:'40000',state:'Selangor'},items:[{name:'Part (A) \\ <b>bold</b> “smart” — dash',sku:'X)Y',quantity:1,price_cents:100,line_total_cents:100}],subtotal_cents:100,discount_cents:0,shipping_cents:0,total_cents:100,promotion_code:null});
  const pdf=make(hostile,{store_name:'Store (Test)',invoice_details:'Reg (1)\n\\ backslash'});
  assert.deepEqual(pdf.problems,[]);const all=pdf.allText.join('\n');
  assert.ok(all.includes('Eve (the) \\ Tester ??'));assert.ok(all.includes('Unit 5) /Type /Page (fake, Jalan Aneh'),'PDF syntax typed by a customer is just text');
  assert.ok(all.includes('Part (A) \\ <b>bold</b> "smart" - dash'));
  assert.equal(pdf.pages.length,1,'no page was injected');
});
test('a long order flows onto more pages with the table header and page numbers on each',()=>{
  const items=Array.from({length:60},(_,i)=>({name:i===4?'A very long product name that has to wrap across several lines because it just keeps going and going without any break at all for real':'Product '+(i+1),sku:'S'+i,quantity:1+i%3,price_cents:1000+i,line_total_cents:(1+i%3)*(1000+i)}));
  const subtotal=items.reduce((s,i)=>s+i.line_total_cents,0);
  const pdf=make(order({items,subtotal_cents:subtotal,discount_cents:0,promotion_code:null,shipping_cents:0,total_cents:subtotal}));
  assert.deepEqual(pdf.problems,[]);assert.ok(pdf.pages.length>=3);
  pdf.pages.forEach((page,i)=>{assert.ok(page.text.includes(`Page ${i+1} of ${pdf.pages.length}`),'page number on page '+(i+1));assert.ok(page.text.includes('DESCRIPTION'),'table header on page '+(i+1));});
  const all=pdf.allText.join('\n');for(const n of [1,30,60])assert.ok(all.includes(`Product ${n}`)||all.includes(`Product ${n}\n`),'Product '+n);
  assert.equal(pdf.pages.at(-1).text.includes(clean(money(subtotal))),true,'the total is on the last page');
  assert.equal(pdf.pages[0].text.includes('Total (MYR)'),false,'totals are not squeezed onto a full first page');
});
test('nothing is drawn outside the page or past the margins',()=>{
  const items=Array.from({length:25},(_,i)=>({name:'W'.repeat(60)+' '+'long wrapping name '.repeat(6)+i,sku:'SKU-'+'9'.repeat(30),quantity:99,price_cents:99999999,line_total_cents:99999999*99}));
  const pdf=make(order({items,subtotal_cents:1,total_cents:1,discount_cents:0,shipping_cents:0,promotion_code:null,address:{name:'N'.repeat(60),line1:'Very long address '.repeat(12),city:'C'.repeat(40),postcode:'47300',state:'Selangor',phone:'0123456789'}}),{store_name:'S'.repeat(50),invoice_details:'Long line without breaks '.repeat(30)});
  assert.deepEqual(pdf.problems,[]);
  for(const page of pdf.pages)for(const run of page.runs){
    const w=measure(run.text,run.size,run.font==='F2');
    const right=/RM|^-RM|^Page \d|^INV-|^GL-|^\d+ \w+ \d{4}$|^[A-Z .)(-]+$/.test(run.text)?run.x+w:run.x+w;
    assert.ok(run.x>=40&&right<=page.width-40+0.5,`text runs off the page: "${run.text.slice(0,40)}" x=${run.x} right=${right.toFixed(1)}`);
    assert.ok(run.y>=20&&run.y<=page.height-20,`text outside vertical bounds: y=${run.y}`);
  }
});
test('the same order and time always make the same file',()=>{
  assert.deepEqual(buildInvoice(order(),{settings,generatedAt:GENERATED}),buildInvoice(order(),{settings,generatedAt:GENERATED}));
});
