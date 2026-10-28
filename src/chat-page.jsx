import React, {useEffect, useRef, useState} from 'react';
import {ArrowDown, ArrowRight, Check, Clock, LoaderCircle, MessageCircle, Package, Plus, RefreshCw, Send, ShieldCheck, WifiOff} from 'lucide-react';
import {useApp, useTask} from './context.jsx';
import {Button, Empty, Field, Link, Modal, Notice, ProductArt} from './components.jsx';
import {dateTime, friendlyError, messageSchema, validate} from './domain.mjs';
import {CHAT_PRIVACY_NOTICE, createChatSync, mergeMessages} from './chat.mjs';

export function ChatPrivacy() {
  return <div className="chat-privacy" role="note"><ShieldCheck size={19}/><div><b>Keep your information safe</b><p>{CHAT_PRIVACY_NOTICE}</p></div></div>;
}

export function SupportCompose({product, onClose}) {
  const {repository, go} = useApp();
  const task=useTask(), reference=useRef(null);
  const [include,setInclude]=useState(Boolean(product)), [body,setBody]=useState('');
  const send=async e=>{
    e.preventDefault();
    const result=await task.perform(async()=>{
      const value=body.trim()||include?validate(messageSchema,{body:body.trim()||'Please help me with this product.',product_id:include?product?.id:null}):null;
      const fingerprint=JSON.stringify(value);
      if(reference.current?.fingerprint!==fingerprint)reference.current={fingerprint,id:crypto.randomUUID()};
      const id=await repository.rpc('start_conversation',{p_kind:'support',p_recipient_id:null});
      if(value)await repository.sendMessage({conversationId:id,body:value.body,productId:value.product_id,clientId:reference.current.id});
      return id;
    });
    if(result.ok){onClose();go('/messages?conversation='+result.value);}
  };
  return <Modal title="Chat with the seller" onClose={()=>!task.busy&&onClose()}><p>Open a conversation and continue chatting here. Include your model, year and engine code for fitment enquiries.</p><ChatPrivacy/><form onSubmit={send}>
    {product?<div className="chat-product-choice"><ProductArt product={product}/><div><b>{product.name}</b><label className="checkbox"><input type="checkbox" disabled={task.busy} checked={include} onChange={e=>setInclude(e.target.checked)}/>Include this item in the conversation</label></div></div>:null}
    <Field label="Your enquiry (optional)"><textarea maxLength={2000} readOnly={task.busy} value={body} onChange={e=>setBody(e.target.value)} placeholder="Write a message now, or open the conversation first."/></Field>
    {task.error?<Notice type="error">{task.error}</Notice>:null}<Button busy={task.busy} className="full-width">{task.busy?'Opening conversation…':body.trim()||include?'Send to the seller':'Open conversation'}<MessageCircle size={18}/></Button>
  </form></Modal>;
}

export function MessagesPage({workspace=false}) {
  const {data,profile,repository,go,route,revision,openSupport}=useApp();
  const task=useTask(),params=new URLSearchParams(route.split('?')[1]);
  const [conversations,setConversations]=useState(data.conversations||[]);
  const [selected,setSelected]=useState(params.get('conversation')||data.conversations?.[0]?.id||'');
  const [messages,setMessages]=useState([]),[drafts,setDrafts]=useState({});
  const [pending,setPending]=useState(null),[sending,setSending]=useState(false);
  const [loading,setLoading]=useState(Boolean(selected)),[syncing,setSyncing]=useState(false),[syncError,setSyncError]=useState(''),[lastSync,setLastSync]=useState(null);
  const [online,setOnline]=useState(navigator.onLine),[older,setOlder]=useState(false),[loadingOlder,setLoadingOlder]=useState(false),[newMessages,setNewMessages]=useState(false);
  const [newInternal,setNewInternal]=useState(false),[recipient,setRecipient]=useState('');
  const mounted=useRef(true),active=useRef(selected),syncRef=useRef(null),listRef=useRef(null),draftRef=useRef({}),pendingRef=useRef(null),sendLock=useRef(false),stickToBottom=useRef(true),seen=useRef(new Map()),confirmed=useRef(new Set());
  active.current=selected;
  const conversation=conversations.find(c=>c.id===selected);
  const draft=drafts[selected]||{body:'',productId:'',clientId:null};
  const writeDraft=(id,value)=>{draftRef.current={...draftRef.current,[id]:value};setDrafts(draftRef.current);};
  const updatePending=value=>{pendingRef.current=value;setPending(value);};
  const clearDelivered=(id,clientId)=>{
    if(draftRef.current[id]?.clientId===clientId)writeDraft(id,{body:'',productId:'',clientId:null});
    if(pendingRef.current?.clientId===clientId)updatePending(null);
  };
  useEffect(()=>{mounted.current=true;return()=>{mounted.current=false;};},[]);
  useEffect(()=>{const id=new URLSearchParams(route.split('?')[1]).get('conversation');if(id&&id!==active.current)setSelected(id);},[route]);
  useEffect(()=>{if(!selected&&conversations.length)setSelected(conversations[0].id);},[selected,conversations]);
  useEffect(()=>{
    let first=true;
    setMessages([]);setLoading(Boolean(selected));setOlder(false);setNewMessages(false);setSyncError('');stickToBottom.current=true;
    const controller=createChatSync(async()=>{
      setSyncing(true);
      const [list,rows]=await Promise.all([repository.conversations(),selected?repository.messages(selected):Promise.resolve([])]);
      return {list,rows};
    },{
      onSuccess:({list,rows})=>{
        setConversations(list);setMessages(previous=>mergeMessages(previous,rows));setSyncError('');setLoading(false);setSyncing(false);setLastSync(new Date());
        if(first){setOlder(rows.length===100);first=false;}
        rows.forEach(row=>{if(row.client_message_id)confirmed.current.add(row.client_message_id);});
        const savedDraft=draftRef.current[selected];
        if(savedDraft?.clientId&&rows.some(row=>row.client_message_id===savedDraft.clientId)&&!sendLock.current)clearDelivered(selected,savedDraft.clientId);
        const newest=rows[0]?.id;
        if(newest&&document.visibilityState==='visible'&&stickToBottom.current&&seen.current.get(selected)!==newest){
          repository.rpc('manage_conversation',{p_conversation_id:selected,p_action:'read'}).then(()=>seen.current.set(selected,newest)).catch(()=>{});
        }
      },
      onError:error=>{setSyncError(friendlyError(error));setLoading(false);setSyncing(false);}
    });
    syncRef.current=controller;void controller.sync();
    const wake=()=>{setOnline(navigator.onLine);if(navigator.onLine&&document.visibilityState==='visible')void controller.sync();};
    window.addEventListener('online',wake);window.addEventListener('offline',wake);window.addEventListener('focus',wake);document.addEventListener('visibilitychange',wake);
    return()=>{controller.stop();if(syncRef.current===controller)syncRef.current=null;window.removeEventListener('online',wake);window.removeEventListener('offline',wake);window.removeEventListener('focus',wake);document.removeEventListener('visibilitychange',wake);};
  },[selected,repository,profile.id]);
  useEffect(()=>{void syncRef.current?.sync();},[revision]);
  useEffect(()=>{
    if(!listRef.current)return;
    if(stickToBottom.current){listRef.current.scrollTop=listRef.current.scrollHeight;setNewMessages(false);}else setNewMessages(true);
  },[messages.at(-1)?.id,pending?.clientId]);

  const transmit=async item=>{
    if(sendLock.current||!navigator.onLine)return;
    sendLock.current=true;setSending(true);updatePending({...item,status:'sending',error:''});stickToBottom.current=true;
    try{
      const id=await repository.sendMessage(item);
      if(!mounted.current)return;
      confirmed.current.add(item.clientId);
      if(active.current===item.conversationId)setMessages(previous=>mergeMessages(previous,[{id,conversation_id:item.conversationId,sender_id:profile.id,sender_name:profile.full_name,body:item.body,product_id:item.productId,product_name:item.productName,client_message_id:item.clientId,created_at:new Date().toISOString()}]));
      clearDelivered(item.conversationId,item.clientId);
    }catch(error){
      if(!mounted.current)return;
      if(confirmed.current.has(item.clientId))clearDelivered(item.conversationId,item.clientId);
      else updatePending({...item,status:'unconfirmed',error:friendlyError(error)});
    }finally{
      sendLock.current=false;
      if(mounted.current){setSending(false);void syncRef.current?.sync();}
    }
  };
  const send=e=>{
    e.preventDefault();
    if(sendLock.current||pendingRef.current)return;
    try{
      if(!conversation||conversation.closed_at)throw new Error('This conversation is unavailable or closed. Start another conversation.');
      if(!navigator.onLine)throw new Error('You are offline. Your draft is kept here; reconnect before sending.');
      const value=validate(messageSchema,{body:draft.body,product_id:draft.productId||null});
      const product=value.product_id?data.products.find(p=>p.id===value.product_id&&p.active):null;
      if(value.product_id&&(!product||conversation.kind!=='support'))throw new Error('Choose an available product for this support conversation.');
      const item={conversationId:selected,body:value.body,productId:value.product_id||null,productName:product?.name||null,clientId:draft.clientId||crypto.randomUUID()};
      writeDraft(selected,{body:item.body,productId:item.productId||'',clientId:item.clientId});task.setError('');void transmit(item);
    }catch(error){task.setError(friendlyError(error));}
  };
  const editDraft=change=>{const next={...draft,...change};if(next.body!==draft.body||next.productId!==draft.productId)next.clientId=null;writeDraft(selected,next);task.setError('');};
  const olderMessages=async()=>{
    if(loadingOlder||!messages.length)return;
    const id=selected,element=listRef.current,oldHeight=element.scrollHeight,oldTop=element.scrollTop;
    setLoadingOlder(true);
    try{const rows=await repository.messages(id,messages[0].created_at);if(active.current!==id||!mounted.current)return;setMessages(previous=>mergeMessages(previous,rows));setOlder(rows.length===100);requestAnimationFrame(()=>{if(active.current===id&&element)element.scrollTop=oldTop+element.scrollHeight-oldHeight;});}
    catch(error){if(mounted.current)task.setError(friendlyError(error));}
    finally{if(mounted.current)setLoadingOlder(false);}
  };
  const nameOf=c=>c.kind==='support'?(workspace?'Customer '+c.customer_id.slice(0,8):'GearLane support'):(c.members||[]).filter(m=>m.user_id!==profile.id).map(m=>data.directory?.find(u=>u.id===m.user_id)?.full_name||'Team member').join(', ')||'Staff conversation';
  const meaningful=draft.body.replace(/[\s\u200B-\u200D\uFEFF]/gu,'').length>0;
  const pendingHere=pending?.conversationId===selected?pending:null;
  const pendingVisible=pendingHere&&!messages.some(m=>m.client_message_id===pendingHere.clientId);
  return <section className={workspace?'conversation-page':'container section conversation-page'}>
    <div className="section-heading"><div><span className="eyebrow">{workspace?'CUSTOMERS & YOUR TEAM':'TALK TO THE STORE'}</span><h1>{workspace?'Messages':'Your support messages'}</h1><p>Continue the conversation here. New messages sync automatically every five seconds.</p></div><Button variant="secondary" disabled={sending||Boolean(pending)} onClick={()=>workspace?setNewInternal(true):openSupport(null)}>{workspace?'New staff chat':'New support enquiry'}<Plus size={18}/></Button></div>
    {!conversation&&syncError?<Notice type="error">{syncError} Automatic sync will try again.<Button variant="secondary small" onClick={()=>void syncRef.current?.sync()}>Try sync again</Button></Notice>:null}
    <div className="chat-layout"><aside className="conversation-list" aria-label="Conversations"><div className="conversation-list-heading"><b>Conversations</b><span>{conversations.length}</span></div>{conversations.length?conversations.map(c=><button key={c.id} aria-pressed={selected===c.id} disabled={Boolean(pending)&&selected!==c.id} className={selected===c.id?'selected':''} onClick={()=>{setSelected(c.id);task.setError('');}}><span>{c.kind==='internal'?'Team chat':'Customer support'}</span><b>{nameOf(c)}</b><small>{c.closed_at?'Closed':c.assigned_to===profile.id?'Assigned to you':c.kind==='support'?'Open conversation':'Private to members'}</small></button>):<p>No conversations yet. Start a chat to get help.</p>}{pending?<p className="conversation-lock-note">Finish sending or keep the pending message as a draft before switching conversations.</p>:null}</aside>
      <section className="chat-thread" aria-label="Selected conversation">
        {conversation?<>
          <header className="thread-header"><div><b>{nameOf(conversation)}</b><small>{conversation.closed_at?'This conversation is closed.':conversation.kind==='internal'?'Private staff conversation':'Human support · replies depend on staff availability'}</small></div>{workspace&&!conversation.closed_at&&conversation.kind==='support'?<div className="actions"><Button variant="secondary small" disabled={sending||Boolean(pending)} busy={task.busy} onClick={()=>task.perform(()=>repository.rpc('manage_conversation',{p_conversation_id:selected,p_action:'assign'}),'Conversation assigned to you.')}>Assign to me</Button><Button variant="secondary small" disabled={sending||Boolean(pending)} busy={task.busy} onClick={()=>task.perform(()=>repository.rpc('manage_conversation',{p_conversation_id:selected,p_action:'close'}),'Conversation closed.')}>Close</Button></div>:null}</header>
          <ChatPrivacy/>
          <div className="chat-sync-bar"><span className={!online||syncError?'sync-warning':'sync-ok'}>{!online?<WifiOff size={14}/>:syncing?<LoaderCircle size={14} className="spin"/>:<span className="sync-dot"/>}{!online?'Offline · draft kept on this page':syncError?'Connection interrupted · retrying':lastSync?'Auto-sync every 5 seconds':'Connecting…'}</span><Button variant="secondary small" busy={syncing} onClick={()=>void syncRef.current?.sync()} disabled={!online}><RefreshCw size={14}/>Sync now</Button></div>
          {syncError?<Notice type="error">{syncError} Messages already shown are kept. Automatic sync will try again.</Notice>:null}
          <div className="message-list" ref={listRef} role="log" aria-label="Conversation messages" aria-live="polite" aria-relevant="additions" onScroll={e=>{const el=e.currentTarget;stickToBottom.current=el.scrollHeight-el.scrollTop-el.clientHeight<80;if(stickToBottom.current)setNewMessages(false);}}>
            {older?<Button variant="secondary small" busy={loadingOlder} onClick={olderMessages}>Load older messages</Button>:null}
            {loading&&!messages.length?<p className="chat-placeholder">Loading the conversation…</p>:!messages.length&&!pendingHere?<div className="chat-placeholder"><MessageCircle size={28}/><b>You can start the conversation.</b><p>Ask about a product or order. Never include passwords or payment-card details.</p></div>:null}
            {messages.map(m=><article className={'message '+(m.sender_id===profile.id?'mine':'')} key={m.id}><b>{m.sender_id===profile.id?'You':m.sender_name}</b>{m.product_id?<Link className="message-product" to={'/products/'+m.product_id} go={go}><Package size={18}/><span>{m.product_name||m.product_id}<small>Attached product · view details</small></span></Link>:null}<p>{m.body}</p><small className="message-meta">{dateTime(m.created_at)}{m.sender_id===profile.id?<span><Check size={13}/>Sent</span>:null}</small></article>)}
            {pendingVisible?<article className={'message mine pending-message '+(pendingHere.status==='unconfirmed'?'unconfirmed':'')} aria-label="Pending message"><b>You</b>{pendingHere.productName?<div className="message-product"><Package size={18}/>{pendingHere.productName}</div>:null}<p>{pendingHere.body}</p><small className="message-meta">{pendingHere.status==='sending'?<><LoaderCircle size={13} className="spin"/>Sending…</>:<><Clock size={13}/>Delivery not confirmed</>}</small>{pendingHere.status==='unconfirmed'?<div className="pending-recovery"><p>{pendingHere.error}</p><p>We’ll check for confirmation during sync. Retrying uses the same reference to avoid a duplicate.</p><div className="actions"><Button variant="secondary small" disabled={!online} onClick={()=>void transmit(pendingHere)}>Retry message</Button><Button variant="secondary small" onClick={()=>updatePending(null)}>Keep as draft</Button></div></div>:null}</article>:null}
          </div>
          {newMessages?<button className="new-messages-button" onClick={()=>{stickToBottom.current=true;listRef.current.scrollTop=listRef.current.scrollHeight;setNewMessages(false);}}>New messages <ArrowDown size={15}/></button>:null}
          {!conversation.closed_at?<form className="message-composer" onSubmit={send} aria-busy={sending}>
            {conversation.kind==='support'?<select aria-label="Attach a product to the message" value={draft.productId} disabled={sending||Boolean(pending)} onChange={e=>editDraft({productId:e.target.value})}><option value="">No product attachment</option>{data.products.filter(p=>p.active).map(p=><option key={p.id} value={p.id}>{p.sku} · {p.name}</option>)}</select>:null}
            <textarea aria-label="Message" aria-describedby="chat-composer-help" required maxLength={2000} readOnly={sending||Boolean(pending)} value={draft.body} placeholder="Write a message…" onChange={e=>editDraft({body:e.target.value})} onKeyDown={e=>{if(e.key==='Enter'&&!e.shiftKey&&!e.nativeEvent.isComposing&&e.keyCode!==229){e.preventDefault();e.currentTarget.form.requestSubmit();}}}/>
            <div className="composer-footer"><small id="chat-composer-help">Enter to send · Shift+Enter for a new line <span>{draft.body.length}/2,000</span></small><Button type="submit" busy={sending} disabled={!online||!meaningful||sending||Boolean(pending)||loading||task.busy}>{sending?'Sending…':'Send'}<Send size={17}/></Button></div>
          </form>:<Notice>This conversation is closed. Start another support enquiry if you need more help.</Notice>}
        </>:<Empty title="Choose a conversation">Select a conversation or start a new chat.</Empty>}
        {task.error?<Notice type="error">{task.error}</Notice>:null}
      </section>
    </div>
    {newInternal?<Modal title="Start a private staff chat" onClose={()=>!task.busy&&setNewInternal(false)}><form onSubmit={async e=>{e.preventDefault();const result=await task.perform(()=>{if(!data.directory?.some(u=>u.id===recipient&&u.id!==profile.id))throw new Error('Choose an available staff member.');return repository.rpc('start_conversation',{p_kind:'internal',p_recipient_id:recipient});});if(result.ok){setSelected(result.value);setNewInternal(false);}}}><ChatPrivacy/><Field label="Staff member"><select required disabled={task.busy} value={recipient} onChange={e=>setRecipient(e.target.value)}><option value="">Choose a colleague</option>{data.directory.filter(u=>u.id!==profile.id).map(u=><option key={u.id} value={u.id}>{u.full_name} ({u.role})</option>)}</select></Field>{task.error?<Notice type="error">{task.error}</Notice>:null}<Button busy={task.busy}>Open conversation</Button></form></Modal>:null}
  </section>;
}
