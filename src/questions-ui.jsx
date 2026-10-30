import React,{useState} from 'react';
import {CircleHelp,Clock,Eye,EyeOff,MessageSquareReply} from 'lucide-react';
import {useApp,useTask} from './context.jsx';
import {Badge,Button,Empty,Field,Link,Modal,Notice} from './components.jsx';
import {QUESTION_MAX,askLimits,checkAnswer,checkQuestion,privacyWarning,questionsForProduct,staffOrder} from './qa.mjs';
import {formatWaiting} from './order-logic.mjs';
import {dateTime} from './domain.mjs';

const isMissing=error=>['PGRST202','42883'].includes(error?.code);

/* "Questions" tab on a product page: public answers for everyone, a form for signed-in customers */
export function QuestionsPanel({product}){
  const {data,profile,repository,route,go}=useApp(),task=useTask(),[text,setText]=useState('');
  const all=data.questions||[],{answered,mine}=questionsForProduct(all,product.id,profile?.id);
  const customer=profile?.role==='customer',check=checkQuestion(text),limits=customer?askLimits(all,profile.id,product.id):{blocked:false,message:''},warning=privacyWarning(text);
  const submit=async e=>{
    e.preventDefault();if(!check.ok||limits.blocked)return;
    const result=await task.perform(async()=>{
      try{return await repository.rpc('ask_question',{p_product_id:product.id,p_question:check.clean});}
      catch(error){if(isMissing(error))throw new Error('Questions are not switched on yet (supabase/017-product-questions.sql).');throw error;}
    },'Question sent. We will answer it soon.');
    if(result.ok)setText('');
  };
  return <section className="qa-panel" aria-label="Questions about this product">
    <div className="qa-head"><div><h3>Questions about this part</h3><p className="muted">Ask the store about fitment, use or delivery. Once answered, your question and the answer are shown here for everyone.</p></div></div>
    {customer?<form className="qa-form" onSubmit={submit}>
      <Field label="Your question"><textarea required minLength={10} maxLength={QUESTION_MAX} placeholder="For example: Will this fit a 2019 Proton X50 1.5 turbo?" value={text} onChange={e=>setText(e.target.value)}/></Field>
      <div className="qa-meta"><span className={text.length>QUESTION_MAX-40?'warn':''}>{text.length}/{QUESTION_MAX}</span>{warning?<span className="qa-warning" role="status">{warning}</span>:null}</div>
      {limits.blocked?<Notice>{limits.message}</Notice>:null}
      {task.error?<Notice type="error">{task.error}</Notice>:null}
      <Button busy={task.busy} disabled={!check.ok||limits.blocked}>Ask the store</Button>
    </form>:profile?<Notice>Staff answer questions from the workspace. <Link to="/workspace/questions" go={go}>Open questions</Link></Notice>:<Notice>Sign in to ask the store a question. <Link to={'/account?next='+encodeURIComponent(route.split('?')[0])} go={go}>Sign in</Link></Notice>}
    {mine.length?<div className="qa-mine"><h4>Waiting for an answer</h4>{mine.map(q=><article key={q.id} className="qa-item waiting"><span className="qa-mark q" aria-hidden="true">Q</span><div><p>{q.question}</p><small className="muted"><Clock size={13}/> Sent {dateTime(q.created_at)}. Only you can see this until it is answered.</small></div></article>)}</div>:null}
    {answered.length?<div className="qa-list">{answered.map(q=><article key={q.id} className="qa-item">
      <span className="qa-mark q" aria-hidden="true">Q</span>
      <div><p>{q.question}</p><small className="muted">Asked by {q.asker_name} · {dateTime(q.created_at)}</small>
        <div className="qa-answer"><span className="qa-mark a" aria-hidden="true">A</span><div><b>Store answer</b><p>{q.answer}</p><small className="muted">{dateTime(q.answered_at)}</small></div></div></div>
    </article>)}</div>:!mine.length?<Empty title="No questions yet">Be the first to ask. Other customers will see the answer.</Empty>:null}
  </section>;
}

/* Staff: questions waiting for an answer, oldest first, then the answered ones */
export function QuestionsPage(){
  const {data,profile,go,repository}=useApp(),task=useTask();
  const [tab,setTab]=useState('open'),[answering,setAnswering]=useState(null),[text,setText]=useState('');
  const {open,done}=staffOrder(data.questions||[]),list=tab==='open'?open:done,now=Date.now();
  const name=id=>data.products.find(p=>p.id===id)?.name||id;
  const answer=checkAnswer(text);
  const begin=q=>{setAnswering(q);setText(q.answer||'');task.setError('');};
  const send=async e=>{
    e.preventDefault();if(!answer.ok)return;
    const result=await task.perform(()=>repository.rpc('answer_question',{p_id:answering.id,p_answer:answer.clean}),answering.answered_at?'Answer updated.':'Answer published.');
    if(result.ok)setAnswering(null);
  };
  return <>
    <div className="section-heading"><div><span className="eyebrow">PRODUCT QUESTIONS</span><h1>Questions</h1><p>Customers ask about parts on the product page. Once you answer, the question and answer appear there for everyone.</p></div></div>
    <div className="order-tabs" role="tablist" aria-label="Question status">
      <button type="button" role="tab" aria-selected={tab==='open'} className={tab==='open'?'selected':''} onClick={()=>setTab('open')}>Needs an answer{open.length?<span>{open.length}</span>:null}</button>
      <button type="button" role="tab" aria-selected={tab==='done'} className={tab==='done'?'selected':''} onClick={()=>setTab('done')}>Answered</button>
    </div>
    {list.length?<div className="question-list">{list.map(q=>{const hours=(now-new Date(q.created_at).getTime())/36e5;return <article key={q.id} className={'panel question-card'+(!q.answered_at&&hours>=72?' overdue':'')}>
      <div className="question-top"><Link className="question-product" to={'/products/'+q.product_id} go={go}><CircleHelp size={15}/>{name(q.product_id)}</Link>{q.answered_at?<Badge value={q.published===false?'cancelled':'verified'}>{q.published===false?'Hidden':'Published'}</Badge>:<span className={'task-wait '+(hours>=72?'urgent':hours>=24?'soon':'')}><Clock size={14}/>Waiting {formatWaiting(hours)}</span>}</div>
      <p className="question-text">{q.question}</p>
      <small className="muted">From {q.asker_name} · {dateTime(q.created_at)}</small>
      {q.answered_at?<div className="qa-answer staff"><b>Your answer</b><p>{q.answer}</p><small className="muted">{dateTime(q.answered_at)}</small></div>:null}
      <div className="actions">
        <Button variant={q.answered_at?'secondary small':'small'} onClick={()=>begin(q)}><MessageSquareReply size={15}/>{q.answered_at?'Edit answer':'Answer'}</Button>
        {q.answered_at&&profile.role==='admin'?<Button variant="secondary small" busy={task.busy} onClick={()=>task.perform(()=>repository.rpc('moderate_question',{p_id:q.id,p_published:q.published===false}),q.published===false?'Question is public again.':'Question hidden from the product page.')}>{q.published===false?<><Eye size={14}/>Show</>:<><EyeOff size={14}/>Hide</>}</Button>:null}
      </div>
    </article>;})}</div>:<Empty title={tab==='open'?'Nothing is waiting':'No answered questions yet'}>{tab==='open'?'New customer questions will appear here.':'Answered questions appear here.'}</Empty>}
    {task.error&&!answering?<Notice type="error">{task.error}</Notice>:null}
    {answering?<Modal title={answering.answered_at?'Edit your answer':'Answer this question'} onClose={()=>setAnswering(null)}>
      <p className="muted small">About: {name(answering.product_id)}</p>
      <blockquote className="question-quote">{answering.question}</blockquote>
      <form onSubmit={send}>
        <Field label="Your answer" hint="Shown publicly on the product page. Do not include personal details."><textarea required minLength={2} maxLength={2000} value={text} onChange={e=>setText(e.target.value)}/></Field>
        {task.error?<Notice type="error">{task.error}</Notice>:null}
        <Button busy={task.busy} disabled={!answer.ok}>{answering.answered_at?'Save answer':'Publish answer'}</Button>
      </form>
    </Modal>:null}
  </>;
}
