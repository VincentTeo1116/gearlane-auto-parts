import {z} from 'zod';
export const enquiryTitleSchema=z.string().trim().min(3,'Add a topic with at least 3 characters.').max(120,'Keep the topic within 120 characters.').refine(v=>!/[\u0000-\u001F\u007F]/u.test(v),'Remove unsupported control characters.');
export const conversationTime=c=>c.last_message?.created_at||c.created_at;
export function conversationTitle(c){return c.title&&c.title!=='Customer support'?c.title:c.last_message?.product_name||'Customer support';}
export function conversationPreview(c,profileId){if(!Object.hasOwn(c,'last_message'))return 'Open to view your conversation.';if(!c.last_message)return 'No messages yet. Send your first question.';return (c.last_message.sender_id===profileId?'You: ':'Seller: ')+c.last_message.body;}
export function inboxDate(value,now=Date.now()){
 const date=new Date(value);if(!Number.isFinite(date.getTime()))return '';
 const day=v=>new Date(v+8*3600000).toISOString().slice(0,10);
 if(day(date.getTime())===day(now))return new Intl.DateTimeFormat('en-MY',{hour:'numeric',minute:'2-digit',timeZone:'Asia/Kuala_Lumpur'}).format(date);
 if(day(date.getTime())===day(now-86400000))return 'Yesterday';
 return new Intl.DateTimeFormat('en-MY',{day:'numeric',month:'short',timeZone:'Asia/Kuala_Lumpur'}).format(date);
}
export function filterConversations(rows,{query='',status='all'}={}){
 const term=query.trim().toLowerCase();return rows.filter(c=>(status==='all'||(status==='closed'?Boolean(c.closed_at):!c.closed_at))&&(!term||[conversationTitle(c),c.title,c.last_message?.body,c.id.slice(-6)].some(text=>text?.toLowerCase().includes(term)))).sort((a,b)=>String(conversationTime(b)).localeCompare(String(conversationTime(a)))||b.id.localeCompare(a.id));
}
export function previewInbox(state,user,access){
 return state.conversations.filter(c=>access(c,user)).map(c=>{
  const rows=state.messages.filter(m=>m.conversation_id===c.id).sort((a,b)=>b.created_at.localeCompare(a.created_at)||b.id.localeCompare(a.id));
  const last=rows[0],read=c.members?.find(m=>m.user_id===user.id)?.last_read_at||'1970-01-01';
  return {...c,customer_name:state.users?.find(u=>u.id===c.customer_id)?.full_name||null,last_message:last?{id:last.id,body:last.body.slice(0,240),created_at:last.created_at,sender_id:last.sender_id,product_name:last.product_name}:null,unread_count:rows.filter(m=>m.sender_id!==user.id&&m.created_at>read).length};
 }).sort((a,b)=>String(conversationTime(b)).localeCompare(String(conversationTime(a)))||b.id.localeCompare(a.id)).slice(0,100);
}
