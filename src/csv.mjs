/* CSV export for staff. Customer-controlled text (names, addresses, product names) ends up in these
   files, so any cell that a spreadsheet could read as a formula is neutralised with a leading apostrophe. */
const FORMULA_START=/^[=+\-@\t\r]/;

export function csvCell(value){
  if(value===null||value===undefined)return '';
  let text=value instanceof Date?value.toISOString():typeof value==='object'?JSON.stringify(value):String(value);
  if(typeof value!=='number'&&FORMULA_START.test(text))text="'"+text;
  return /[",\r\n]/.test(text)?'"'+text.replace(/"/g,'""')+'"':text;
}

/* columns: [[header, row=>value], ...] */
export function toCsv(rows,columns){
  const lines=[columns.map(([header])=>csvCell(header)).join(',')];
  for(const row of rows)lines.push(columns.map(([,get])=>csvCell(get(row))).join(','));
  return '\uFEFF'+lines.join('\r\n')+'\r\n'; // BOM so Excel reads UTF-8 names correctly
}

export const ringgit=cents=>(Number(cents||0)/100).toFixed(2);

export const orderColumns=[
  ['Order',o=>'GL-'+o.order_number],['Placed',o=>o.created_at],['Customer',o=>o.address?.name],['Phone',o=>o.address?.phone],
  ['Delivery address',o=>[o.address?.line1,o.address?.postcode,o.address?.city,o.address?.state].filter(Boolean).join(', ')],
  ['Order status',o=>o.status],['Payment status',o=>o.payment_status],
  ['Items',o=>(o.items||[]).map(i=>i.quantity+' x '+i.name).join('; ')],
  ['Subtotal (RM)',o=>ringgit(o.subtotal_cents)],['Discount (RM)',o=>ringgit(o.discount_cents)],['Delivery (RM)',o=>ringgit(o.shipping_cents)],['Total (RM)',o=>ringgit(o.total_cents)],
  ['Promotion code',o=>o.promotion_code],['Received by customer',o=>o.received_at],
];
export const productColumns=[
  ['SKU',p=>p.sku],['Name',p=>p.name],['Brand',p=>p.brand],['Category',p=>p.category],['Price (RM)',p=>ringgit(p.price_cents)],
  ['Price confirmed',p=>p.price_confirmed?'yes':'no'],['Stock',p=>p.stock],['Active',p=>p.active?'yes':'no'],
];

export function downloadCsv(filename,text){
  const url=URL.createObjectURL(new Blob([text],{type:'text/csv;charset=utf-8'})),link=document.createElement('a');
  link.href=url;link.download=filename;document.body.appendChild(link);link.click();link.remove();
  setTimeout(()=>URL.revokeObjectURL(url),1000);
}
export const stamp=()=>new Date().toISOString().slice(0,10);
