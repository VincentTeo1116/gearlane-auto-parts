import React,{useState} from 'react';
import {ArrowRight,Check,MessageCircle,Plus,Search} from 'lucide-react';
import {Button} from './components.jsx';
import {conversationPreview,conversationTitle,conversationTime,filterConversations,inboxDate} from './chat-inbox.mjs';

export function ConversationInbox({rows,profileId,selected,pending,loading,onSelect,onNew}){
 const [query,setQuery]=useState(''),[status,setStatus]=useState('all');
 const filtered=filterConversations(rows,{query,status});
 return <section className="seller-inbox" aria-label="Conversation history">
  <div className="inbox-intro"><h3>Your conversations</h3><Button disabled={pending} onClick={onNew}><Plus size={18}/>New enquiry</Button></div>
  <label className="inbox-search"><Search size={18}/><input type="search" aria-label="Search conversations" placeholder="Search your chats" maxLength={120} value={query} onChange={e=>setQuery(e.target.value)}/></label>
  <div className="inbox-filters" aria-label="Filter conversations">{[['all','All chats'],['open','Open'],['closed','Closed']].map(([value,title])=><button key={value} aria-pressed={status===value} onClick={()=>setStatus(value)}>{title}</button>)}</div>
  {pending?<p className="inbox-pending-note" role="status">A message is pending. You can return to that chat while delivery is checked.</p>:null}
  <div className="inbox-records">{loading&&!rows.length?<div className="inbox-loading" role="status" aria-label="Loading conversations">{[0,1,2].map(n=><div className="inbox-skeleton" key={n}><i className="skeleton-avatar"/><span className="skeleton-line title"/><span className="skeleton-line"/></div>)}</div>:filtered.length?filtered.map(c=><button className={'inbox-conversation '+(c.unread_count?'unread ':'')+(c.id===selected?'current':'')} key={c.id} aria-label={'Open conversation: '+conversationTitle(c)} disabled={Boolean(pending)&&selected!==c.id} onClick={()=>onSelect(c.id)}><span className="inbox-avatar"><MessageCircle size={21}/></span><span className="inbox-card-body"><span className="inbox-card-top"><b>{conversationTitle(c)}</b><time dateTime={conversationTime(c)}>{inboxDate(conversationTime(c))}</time></span><span className="inbox-preview">{conversationPreview(c,profileId)}</span><span className="inbox-card-bottom"><span className={'inbox-state '+(c.closed_at?'closed':'open')}>{c.closed_at?<Check size={12}/>:<i/>}{c.closed_at?'Closed':'Open'}</span><small>#{c.id.slice(-6).toUpperCase()}</small>{c.unread_count?<span className="inbox-unread">{Math.min(c.unread_count,99)} new</span>:<ArrowRight size={15}/>}</span></span></button>):<div className="inbox-empty"><MessageCircle size={30}/><h4>{rows.length?'No matching chats':'Let’s start a conversation'}</h4><p>{rows.length?'Try another topic or filter.':'Your enquiries and seller replies will appear here.'}</p>{rows.length?<Button variant="secondary small" onClick={()=>{setQuery('');setStatus('all');}}>Clear filters</Button>:null}</div>}</div>
  {rows.length===100?<small className="inbox-limit">Showing your 100 most recently active conversations.</small>:null}
 </section>;
}
