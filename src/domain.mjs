import { z } from 'zod';

export const ROLES = ['customer', 'worker', 'admin'];
export const ORDER_STATUSES = ['awaiting_payment', 'processing', 'shipped', 'delivered', 'cancelled'];
export const money = cents => new Intl.NumberFormat('en-MY', {style:'currency',currency:'MYR'}).format((Number(cents)||0)/100);
export const dateTime = date => new Intl.DateTimeFormat('en-MY',{dateStyle:'medium',timeStyle:'short',timeZone:'Asia/Kuala_Lumpur'}).format(new Date(date));
export function cents(value) {
  const text=String(value).trim();
  if(!/^\d{1,8}(\.\d{1,2})?$/.test(text)) throw new Error('Enter a non-negative amount with at most 2 decimal places.');
  const [whole,fraction='']=text.split('.');return Number(whole)*100+Number(fraction.padEnd(2,'0'));
}
export const label = value => String(value||'').replaceAll('_',' ').replace(/\b\w/g,c=>c.toUpperCase());
const text = (min,max) => z.string().trim().min(min,`Enter at least ${min} characters.`).max(max,`Use no more than ${max} characters.`);
export const phoneSchema = z.string().trim().regex(/^\+?[0-9 ()-]{8,20}$/, 'Enter a valid phone number.');
export const addressSchema=z.object({name:text(2,100),phone:phoneSchema,line1:text(8,300),city:text(2,80),postcode:z.string().regex(/^\d{5}$/,'Use a 5-digit Malaysian postcode.'),state:text(2,80)});
export const signUpSchema=z.object({name:text(2,100),email:z.email().max(254),password:z.string().min(12,'Use at least 12 characters.').max(128),business_type:z.enum(['personal','workshop','retailer','distributor']),phone:phoneSchema});
export const productSchema=z.object({id:text(1,100),sku:text(2,80),name:text(3,180),brand:text(1,80),category:text(2,80),description:text(10,4000),price_cents:z.number().int().min(1).max(100000000),stock:z.number().int().min(0).max(1000000),image_url:z.union([z.literal(''),z.url().refine(v=>v.startsWith('https://'),'Use an HTTPS image URL.')]),specs:z.record(z.string().max(80),z.string().max(1000)),fitment_note:text(5,1000),price_confirmed:z.boolean(),active:z.boolean()});
export const messageSchema=z.object({body:text(1,2000).refine(v=>v.replace(/[\s\u200B-\u200D\uFEFF]/gu,'').length>0,'Write a message, not just whitespace.').refine(v=>!/[\u0000-\u0008\u000B\u000C\u000E-\u001F\u007F]/u.test(v),'Remove unsupported control characters.'),product_id:z.string().regex(/^[a-zA-Z0-9_-]{1,100}$/,'Choose a valid product.').nullable().optional()});
export const reviewSchema=z.object({order_id:z.uuid(),product_id:text(1,100),rating:z.number().int().min(1).max(5),body:text(10,2000)});
export const announcementSchema=z.object({title:text(3,160),body:text(5,3000),active:z.boolean()});
export const promotionSchema=z.object({code:z.string().trim().toUpperCase().regex(/^[A-Z0-9_-]{3,30}$/),kind:z.enum(['percent','fixed']),value:z.number().int().min(1),minimum_cents:z.number().int().min(0),maximum_uses:z.number().int().min(1).max(1000000),starts_at:z.string().min(10),ends_at:z.string().min(10),active:z.boolean()}).superRefine((p,c)=>{if(p.kind==='percent'&&p.value>100)c.addIssue({code:'custom',message:'Percentage must be between 1 and 100.',path:['value']});if(new Date(p.ends_at)<=new Date(p.starts_at))c.addIssue({code:'custom',message:'End date must follow the start date.',path:['ends_at']});});
export function validate(schema,input){const result=schema.safeParse(input);if(!result.success)throw new Error(result.error.issues.map(i=>`${i.path.join('.')}: ${i.message}`).join('\n'));return result.data;}
export function calculateCart(lines,products,settings,promotion=null) {
  const items=lines.map(line=>{
    const p=products.find(p=>p.id===line.product_id);
    if(!p||!p.active) throw new Error('An item is unavailable. Remove it from your cart.');
    if(!Number.isSafeInteger(line.quantity)||line.quantity<1||line.quantity>9999)throw new Error('Quantities must be whole numbers from 1 to 9,999.');
    if(line.quantity>p.stock)throw new Error(`${p.name}: only ${p.stock} available.`);
    if(!p.price_confirmed)throw new Error(`${p.name}: the store must confirm the selling price first.`);
    return {...line,name:p.name,price_cents:p.price_cents,line_total_cents:p.price_cents*line.quantity,category:p.category,sku:p.sku};
  });
  if(!items.length)throw new Error('Your cart is empty.');
  if(new Set(items.map(i=>i.product_id)).size!==items.length)throw new Error('Duplicate cart items are not allowed.');
  const subtotal=items.reduce((s,i)=>s+i.line_total_cents,0);
  let discount=0;
  if(promotion){if(!promotion.active||Date.now()<new Date(promotion.starts_at)||Date.now()>=new Date(promotion.ends_at))throw new Error('This promotion is not active.');if(subtotal<promotion.minimum_cents)throw new Error('The promotion minimum spend has not been reached.');discount=promotion.kind==='percent'?Math.floor(subtotal*promotion.value/100):promotion.value;discount=Math.min(subtotal,discount);}
  const shipping=settings.free_shipping_cents>0 && subtotal-discount>=settings.free_shipping_cents?0:settings.shipping_cents;
  return {items,subtotal_cents:subtotal,discount_cents:discount,shipping_cents:shipping,total_cents:subtotal-discount+shipping};
}
export function canReview(order,productId){return Boolean(order?.received_at&&order.payment_status==='verified'&&order.status!=='cancelled'&&order.items.some(i=>i.product_id===productId));}
export function canCancel(order){return order?.status==='awaiting_payment'&&['awaiting','rejected'].includes(order.payment_status);}
export function canTransition(order,next){return (order.status==='awaiting_payment'&&next==='processing'&&order.payment_status==='verified')||(order.status==='processing'&&next==='shipped'&&order.payment_status==='verified')||(order.status==='shipped'&&next==='delivered'&&order.payment_status==='verified');}
export const STATES=['Johor','Kedah','Kelantan','Melaka','Negeri Sembilan','Pahang','Penang','Perak','Perlis','Sabah','Sarawak','Selangor','Terengganu','Kuala Lumpur','Labuan','Putrajaya'];
export function friendlyError(error){const message=String(error?.message||error||'Something went wrong.');if(/fetch|network|Failed to load|offline/i.test(message))return 'Connection failed. Your action was not confirmed. Reconnect and refresh before trying again.';if(/JWT|expired|not authenticated/i.test(message))return 'Your session has expired. Please sign in again.';if(/duplicate|unique constraint/i.test(message))return 'This record already exists. Refresh to see the latest information.';return message.replace(/\s+CONTEXT:[\s\S]*/,'').slice(0,600);}
