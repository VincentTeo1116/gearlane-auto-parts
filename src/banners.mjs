import {z} from 'zod';
export function validBannerLink(value){
 if(!value)return true;
 if(value.length>500||/[\u0000-\u001F\u007F\\#]/u.test(value))return false;
 return /^(\/|\/shop(?:\?[^#]*)?|\/products\/[a-zA-Z0-9_-]{1,100}|\/messages)$/.test(value);
}
const image=z.union([z.literal(''),z.url().refine(v=>v.startsWith('https://'),'Use an HTTPS image URL.')]).nullable();
export const bannerSchema=z.object({id:z.uuid().optional(),title:z.string().trim().min(3).max(120),alt_text:z.string().trim().max(300),image_url:image,mobile_image_url:image,link_path:z.string().trim().max(500).refine(validBannerLink,'Choose /shop, /messages or a /products/product-id page.'),position:z.number().int().min(0).max(9999),published:z.boolean()}).superRefine((b,c)=>{if(b.published&&!b.image_url)c.addIssue({code:'custom',path:['image_url'],message:'Upload a main image before publishing.'});if(b.published&&b.alt_text.length<5)c.addIssue({code:'custom',path:['alt_text'],message:'Describe the advertisement in at least 5 characters.'});});
