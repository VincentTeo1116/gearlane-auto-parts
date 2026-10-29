import React,{useId,useRef,useState} from 'react';
import {Check,Star} from 'lucide-react';
import {useApp,useTask} from './context.jsx';
import {Badge,Button,Empty,Field,Modal,Notice} from './components.jsx';
import {dateTime,reviewSchema,validate} from './domain.mjs';
import {REVIEW_TAGS,RATING_WORDS,parseReview,composeReview,maxReviewText} from './review-tags.mjs';

export {REVIEW_TAGS,RATING_WORDS,parseReview,composeReview};

/* Read-only stars, supports fractions for averages */
export function Stars({value,size=16,label}){
  const pct=Math.max(0,Math.min(5,value))/5*100;
  return <span className="stars" role="img" aria-label={label||`${value.toFixed(1)} out of 5 stars`} style={{'--size':size+'px'}}><span className="stars-base" aria-hidden="true">{'★★★★★'}</span><span className="stars-fill" aria-hidden="true" style={{width:pct+'%'}}>{'★★★★★'}</span></span>;
}

/* Interactive 5-star picker: click, hover preview, arrow keys */
export function StarInput({value,onChange,label='Overall rating'}){
  const [hover,setHover]=useState(0),refs=useRef([]),id=useId(),shown=hover||value;
  const move=(next)=>{const n=Math.max(1,Math.min(5,next));onChange(n);refs.current[n-1]?.focus();};
  return <div className="star-input">
    <div role="radiogroup" aria-labelledby={id} className="star-row" onMouseLeave={()=>setHover(0)}>
      <span id={id} className="sr-only">{label}</span>
      {[1,2,3,4,5].map(n=><button key={n} type="button" ref={el=>refs.current[n-1]=el} role="radio" aria-checked={value===n} aria-label={`${n} star${n===1?'':'s'}, ${RATING_WORDS[n]}`} tabIndex={value===n||(!value&&n===1)?0:-1} className={n<=shown?'on':''} onMouseEnter={()=>setHover(n)} onFocus={()=>setHover(0)} onClick={()=>onChange(n)} onKeyDown={e=>{if(e.key==='ArrowRight'||e.key==='ArrowUp'){e.preventDefault();move(value+1);}else if(e.key==='ArrowLeft'||e.key==='ArrowDown'){e.preventDefault();move(value-1);}else if(e.key==='Home'){e.preventDefault();move(1);}else if(e.key==='End'){e.preventDefault();move(5);}}}><Star size={34} fill={n<=shown?'currentColor':'none'} strokeWidth={1.6}/></button>)}
    </div>
    <b className="star-word" aria-live="polite">{shown?`${shown}/5 · ${RATING_WORDS[shown]}`:'Tap a star'}</b>
  </div>;
}

export function ReviewForm({order,item,onClose}){
  const {repository}=useApp(),task=useTask();
  const [rating,setRating]=useState(5),[body,setBody]=useState(''),[tags,setTags]=useState([]);
  const toggle=t=>setTags(list=>list.includes(t)?list.filter(x=>x!==t):[...list,t]);
  return <Modal title="Review your purchased item" onClose={onClose}>
    <p className="review-item-name">{item.name}</p>
    <form className="review-form" onSubmit={async e=>{e.preventDefault();const result=await task.perform(()=>{const v=validate(reviewSchema,{order_id:order.id,product_id:item.product_id,rating,body:composeReview(body,tags)});return repository.rpc('submit_review',{p_order_id:v.order_id,p_product_id:v.product_id,p_rating:v.rating,p_body:v.body});},'Review submitted.');if(result.ok)onClose();}}>
      <div className="field"><label>How would you rate it?</label><StarInput value={rating} onChange={setRating}/></div>
      <div className="field"><label id="tag-label">What stood out? <span className="muted">(optional)</span></label>
        <div className="tag-picker" role="group" aria-labelledby="tag-label">{REVIEW_TAGS.map(t=><button key={t} type="button" aria-pressed={tags.includes(t)} className={tags.includes(t)?'selected':''} onClick={()=>toggle(t)}>{tags.includes(t)?<Check size={14}/>:null}{t}</button>)}</div>
      </div>
      <Field label="Your feedback"><textarea required minLength={10} maxLength={maxReviewText(tags)} placeholder="Tell other buyers what you liked or what could be better." value={body} onChange={e=>setBody(e.target.value)}/></Field>
      {task.error?<Notice type="error">{task.error}</Notice>:null}
      <Button busy={task.busy}>Submit verified review</Button>
    </form>
  </Modal>;
}

/* Product-page review summary: average, 5-to-1 histogram and filters, then the list */
export function ReviewSection({reviews}){
  const [filter,setFilter]=useState('all'),[limit,setLimit]=useState(10);
  if(!reviews.length)return <Empty title="No reviews yet">Only buyers who have confirmed receipt can leave a review.</Empty>;
  const parsed=reviews.map(r=>({...r,...parseReview(r.body)}));
  const average=reviews.reduce((s,r)=>s+r.rating,0)/reviews.length;
  const counts=[5,4,3,2,1].map(n=>[n,reviews.filter(r=>r.rating===n).length]);
  const tagCounts=REVIEW_TAGS.map(t=>[t,parsed.filter(r=>r.tags.includes(t)).length]).filter(([,n])=>n>0);
  const withText=parsed.filter(r=>r.text).length;
  const shown=parsed.filter(r=>filter==='all'?true:filter==='tags'?r.tags.length>0:r.rating===Number(filter));
  const chips=[['all','All ('+reviews.length+')'],...counts.filter(([,n])=>n).map(([n,c])=>[String(n),n+' star ('+c+')'])];
  if(tagCounts.length)chips.push(['tags','With highlights']);
  return <div className="review-section">
    <div className="review-summary">
      <div className="review-score"><b>{average.toFixed(1)}</b><span>out of 5</span><Stars value={average} size={20}/><small>{reviews.length} verified review{reviews.length===1?'':'s'}</small></div>
      <div className="review-bars" aria-label="Rating breakdown">{counts.map(([n,c])=><button type="button" key={n} onClick={()=>{setFilter(String(n));setLimit(10);}} disabled={!c} aria-label={`${n} star: ${c} review${c===1?'':'s'}`}><span>{n}★</span><i><em style={{width:(c/reviews.length*100)+'%'}}/></i><span>{c}</span></button>)}</div>
      {tagCounts.length?<div className="review-tags-summary"><b>What buyers mention</b><div>{tagCounts.map(([t,n])=><span key={t}>{t} <em>{n}</em></span>)}</div></div>:null}
    </div>
    <div className="review-filters" role="group" aria-label="Filter reviews">{chips.map(([key,text])=><button type="button" key={key} aria-pressed={filter===key} className={filter===key?'selected':''} onClick={()=>{setFilter(key);setLimit(10);}}>{text}</button>)}</div>
    {shown.length?<div className="reviews-list">{shown.slice(0,limit).map(r=><ReviewCard key={r.id} review={r}/>)}</div>:<p className="muted">No reviews match this filter.</p>}{shown.length>limit?<button type="button" className="button secondary review-more" onClick={()=>setLimit(n=>n+10)}>Show more reviews ({shown.length-limit} left)</button>:null}
    <small className="muted">{withText} of {reviews.length} {reviews.length===1?'review includes':'reviews include'} written feedback.</small>
  </div>;
}

export function ReviewCard({review:r,staff=false,product}){
  const {text,tags}=r.text!==undefined?r:{...r,...parseReview(r.body)};
  return <article className="review-card">
    <div className="review-top"><span className="review-avatar" aria-hidden="true">{(r.display_name||'?').trim().charAt(0).toUpperCase()}</span><div><b>{r.display_name}</b><Stars value={r.rating} size={15}/></div>{staff?<Badge value={r.published?'verified':'cancelled'}>{r.published?'Published':'Hidden'}</Badge>:<Badge value="verified">Verified purchase</Badge>}</div>
    {product?<small className="muted">{product}</small>:null}
    {tags.length?<div className="review-tags">{tags.map(t=><span key={t}>{t}</span>)}</div>:null}
    <p>{text}</p>
    <small className="muted">{dateTime(r.created_at)}</small>
    {r.reply?<div className="seller-reply"><b>{staff?'Store reply':'Seller response'}</b><p>{r.reply}</p></div>:null}
  </article>;
}
