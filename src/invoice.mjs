import {Pdf,measure,wrap} from './pdf.mjs';
import {money} from './domain.mjs';

/* A PDF invoice for one order, drawn from the order record itself (the prices the customer actually paid).
   Only paid orders get one: an unpaid order is not yet a sale. */
const PAGE={width:595.28,height:841.89,margin:48};
const INK=[26,38,52],MUTED=[91,108,118],LINE=[213,224,232],ACCENT=[194,65,12],GREEN=[31,122,77],GREEN_BG=[228,244,234],RED=[154,52,18],RED_BG=[251,230,225],HEAD_BG=[241,246,250];
const KL={timeZone:'Asia/Kuala_Lumpur'};

/* Shortens a one-line label with "..." until it fits the width */
const fit=(text,width,size)=>{let s=String(text);if(measure(s,size)<=width)return s;while(s.length>1&&measure(s+'...',size)>width)s=s.slice(0,-1);return s.trimEnd()+'...';};
export const canInvoice=order=>Boolean(order)&&['verified','refunded'].includes(order.payment_status);
export const invoiceNumber=order=>'INV-'+order.order_number;
export const invoiceFileName=order=>`invoice-GL-${order.order_number}.pdf`;
export const formatDate=iso=>iso?new Date(iso).toLocaleDateString('en-MY',{...KL,day:'numeric',month:'short',year:'numeric'}):'';
const latest=(events,name)=>(events||[]).filter(e=>e.event===name).map(e=>e.created_at).sort().at(-1)||null;

/* The date a payment was confirmed is the date of sale; fall back to the order date for older records */
export function issueDate(order){return latest(order.events,'payment_verified')||order.created_at;}

export function buildInvoice(order,{settings={},generatedAt=new Date()}={}){
  if(!canInvoice(order))throw new Error('An invoice is available once payment has been verified.');
  const pdf=new Pdf({title:`Invoice ${invoiceNumber(order)}`,created:generatedAt}),{width,margin}=PAGE,right=width-margin;
  const refunded=order.payment_status==='refunded';
  pdf.addPage();
  let y=margin;

  // ----- title block
  pdf.text(margin,y+22,'INVOICE',{size:26,bold:true,color:INK});
  const meta=[['Invoice no.',invoiceNumber(order)],['Issued',formatDate(issueDate(order))],['Order',`GL-${order.order_number}`]];
  let metaY=y+6;
  for(const [label,value] of meta){pdf.text(right-120,metaY,label,{size:8.5,color:MUTED,align:'right'});pdf.text(right,metaY,value,{size:10,bold:true,align:'right'});metaY+=14;}
  const badge=refunded?'REFUNDED':'PAID';
  pdf.rect(margin,y+34,refunded?74:46,18,{fill:refunded?RED_BG:GREEN_BG});
  pdf.text(margin+(refunded?37:23),y+46.5,badge,{size:9,bold:true,color:refunded?RED:GREEN,align:'center'});
  y+=78;

  // ----- from / bill to
  const columnWidth=(right-margin-24)/2,midX=margin+columnWidth+24;
  const store=settings.store_name||'GearLane Auto Parts';
  // every free-text value is wrapped to its column: names, addresses and company details are customer or admin typed
  const sellerLines=[...(settings.invoice_details?wrap(settings.invoice_details,columnWidth,9.5):[]),...(settings.contact_email?wrap(settings.contact_email,columnWidth,9.5):[])];
  const addr=order.address||{};
  const billLines=[...wrap(addr.line1||'',columnWidth,9.5),...wrap([addr.postcode,addr.city].filter(Boolean).join(' '),columnWidth,9.5),...wrap(addr.state||'',columnWidth,9.5),...wrap(addr.phone||'',columnWidth,9.5)].filter(Boolean);
  pdf.text(margin,y,'FROM',{size:8,bold:true,color:MUTED});pdf.text(midX,y,'BILL TO',{size:8,bold:true,color:MUTED});
  let ly=y+15,ry=y+15;
  for(const line of wrap(store,columnWidth,11,true)){pdf.text(margin,ly,line,{size:11,bold:true});ly+=14;}
  for(const line of sellerLines){if(line){pdf.text(margin,ly,line,{size:9.5,color:MUTED});}ly+=12.5;}
  for(const line of wrap(addr.name||'Customer',columnWidth,11,true)){pdf.text(midX,ry,line,{size:11,bold:true});ry+=14;}
  for(const line of billLines){pdf.text(midX,ry,line,{size:9.5,color:MUTED});ry+=12.5;}
  y=Math.max(ly,ry)+14;
  pdf.line(margin,y,right,y,{color:LINE});y+=16;

  // ----- items table
  const col={desc:margin,qty:right-190,unit:right-95,amount:right};
  const descWidth=col.qty-col.desc-34;
  const header=()=>{
    pdf.rect(margin,y-11,right-margin,20,{fill:HEAD_BG});
    pdf.text(col.desc+8,y+3,'DESCRIPTION',{size:8,bold:true,color:MUTED});pdf.text(col.qty,y+3,'QTY',{size:8,bold:true,color:MUTED,align:'right'});pdf.text(col.unit,y+3,'UNIT PRICE',{size:8,bold:true,color:MUTED,align:'right'});pdf.text(col.amount-8,y+3,'AMOUNT',{size:8,bold:true,color:MUTED,align:'right'});
    y+=24;
  };
  const footerReserve=70,pageBottom=PAGE.height-margin-footerReserve;
  header();
  const items=order.items||[],totalsHeight=(order.discount_cents>0?18:0)+18*2+34+80;
  for(const [index,item] of items.entries()){
    const lines=wrap(item.name,descWidth,10),skuLines=item.sku?wrap('SKU '+item.sku,descWidth,8):[],rowHeight=lines.length*13+(skuLines.length?skuLines.length*11+1:0)+12;
    // the last line item travels with the totals, so the totals are never alone on a page
    if(y+rowHeight+(index===items.length-1?totalsHeight:0)>pageBottom){pdf.addPage();y=margin;header();}
    lines.forEach((line,i)=>pdf.text(col.desc+8,y+i*13,line,{size:10}));
    skuLines.forEach((line,i)=>pdf.text(col.desc+8,y+lines.length*13+i*11,line,{size:8,color:MUTED}));
    pdf.text(col.qty,y,String(item.quantity),{size:10,align:'right'});
    pdf.text(col.unit,y,money(item.price_cents),{size:10,align:'right'});
    pdf.text(col.amount-8,y,money(item.line_total_cents),{size:10,bold:true,align:'right'});
    y+=rowHeight;pdf.line(margin,y-10,right,y-10,{color:[232,239,244]});
  }

  // ----- totals
  if(!items.length&&y+totalsHeight>pageBottom){pdf.addPage();y=margin;}
  y+=8;
  const labelX=right-190,valueX=right-8;
  const row=(label,value,opts={})=>{pdf.text(labelX,y,label,{size:opts.size||10,color:opts.color||MUTED,bold:opts.bold});pdf.text(valueX,y,value,{size:opts.size||10,bold:opts.bold,align:'right',color:opts.valueColor});y+=18;};
  row('Subtotal',money(order.subtotal_cents));
  if(order.discount_cents>0)row(fit('Discount'+(order.promotion_code?` (${order.promotion_code})`:''),128,10),'-'+money(order.discount_cents));
  row('Delivery',money(order.shipping_cents));
  pdf.line(labelX,y-8,right,y-8,{color:INK,width:0.8});y+=8;
  row('Total (MYR)',money(order.total_cents),{size:13,bold:true,color:INK,valueColor:ACCENT});

  // ----- payment
  y+=12;
  const verified=latest(order.events,'payment_verified');
  const paymentLines=[`Paid by bank transfer${order.payment_reference?`, reference ${order.payment_reference}`:''}${verified?`, confirmed ${formatDate(verified)}`:''}.`,...(refunded?['A refund was recorded for this order. This invoice is kept for your records.']:[])];
  pdf.text(margin,y,'PAYMENT',{size:8,bold:true,color:MUTED});y+=14;
  for(const text of paymentLines)for(const line of wrap(text,right-margin,9.5)){pdf.text(margin,y,line,{size:9.5});y+=13;}

  // ----- footer and page numbers on every page
  const total=pdf.pages.length;
  pdf.pages.forEach((page,index)=>{
    pdf.page=page;
    pdf.line(margin,PAGE.height-margin-20,right,PAGE.height-margin-20,{color:LINE});
    pdf.text(margin,PAGE.height-margin-6,`Amounts are in Malaysian ringgit (MYR). Generated from order GL-${order.order_number} on ${formatDate(generatedAt.toISOString())}.`,{size:7.5,color:MUTED});
    pdf.text(right,PAGE.height-margin-6,`Page ${index+1} of ${total}`,{size:7.5,color:MUTED,align:'right'});
  });
  return pdf.build();
}

/* Browser download. The bytes never leave the device. */
export function downloadPdf(filename,bytes){
  const url=URL.createObjectURL(new Blob([bytes],{type:'application/pdf'})),link=document.createElement('a');
  link.href=url;link.download=filename;document.body.appendChild(link);link.click();link.remove();
  setTimeout(()=>URL.revokeObjectURL(url),1500);
}
export{measure};
