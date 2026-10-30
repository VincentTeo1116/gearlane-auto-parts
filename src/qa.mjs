/* Product questions and answers: the rules the database enforces, mirrored so the form can explain them
   before the customer submits, and so the demo store behaves the same way. */
export const QUESTION_MIN=10,QUESTION_MAX=500,ANSWER_MIN=2,ANSWER_MAX=2000,DAILY_LIMIT=5,PENDING_PER_PRODUCT=2;

/* "Amir Rahman" -> "Amir R.", "Siti" -> "Siti", "Mary Ann Lee" -> "Mary L." (the same rule as the database) */
export function questionDisplayName(fullName){
  const name=String(fullName||'').trim().replace(/\s+/g,' ');
  if(!name)return 'Customer';
  const parts=name.split(' ');
  return parts.length>1?`${parts[0]} ${parts.at(-1).charAt(0)}.`:parts[0];
}

const trimText=text=>String(text??'').replace(/^\s+|\s+$/g,'');

export function checkQuestion(text){
  const clean=trimText(text);
  if(clean.length<QUESTION_MIN)return{ok:false,clean,message:`Write at least ${QUESTION_MIN} characters so the store can answer properly.`};
  if(clean.length>QUESTION_MAX)return{ok:false,clean,message:`Keep your question under ${QUESTION_MAX} characters.`};
  return{ok:true,clean,message:''};
}
export function checkAnswer(text){
  const clean=trimText(text);
  if(clean.length<ANSWER_MIN||clean.length>ANSWER_MAX)return{ok:false,clean,message:`Write an answer of ${ANSWER_MIN} to ${ANSWER_MAX} characters.`};
  return{ok:true,clean,message:''};
}

/* Words that suggest the customer is sharing private details. A gentle warning only: they can still post. */
export function privacyWarning(text){
  const t=String(text||'');
  if(/\b\+?\d[\d\s().-]{8,}\d\b/.test(t))return 'This looks like it contains a phone number. Questions are shown publicly once answered, so please leave it out.';
  if(/[^\s@]+@[^\s@]+\.[^\s@]+/.test(t))return 'This looks like it contains an email address. Questions are shown publicly once answered, so please leave it out.';
  return '';
}

const byNewest=(a,b)=>new Date(b.created_at)-new Date(a.created_at);
export const isPublic=q=>Boolean(q.answered_at)&&q.published!==false;

/* What a product page shows: the public answers, and (for the signed-in asker) their own waiting questions */
export function questionsForProduct(questions,productId,profileId){
  const own=questions.filter(q=>q.product_id===productId);
  return{
    answered:own.filter(isPublic).sort(byNewest),
    mine:profileId?own.filter(q=>q.asker_id===profileId&&!q.answered_at).sort(byNewest):[],
  };
}

/* How many answered questions each product has, for the tab label */
export const publicCount=(questions,productId)=>questions.filter(q=>q.product_id===productId&&isPublic(q)).length;

/* Staff queue: unanswered first, oldest first (they have waited longest), then answered newest first */
export function staffOrder(questions){
  const open=questions.filter(q=>!q.answered_at).sort((a,b)=>new Date(a.created_at)-new Date(b.created_at));
  const done=questions.filter(q=>q.answered_at).sort((a,b)=>new Date(b.answered_at)-new Date(a.answered_at));
  return{open,done};
}

/* The same limits the database applies, so the form can say "try tomorrow" instead of failing */
export function askLimits(questions,profileId,productId,now=Date.now()){
  const mine=questions.filter(q=>q.asker_id===profileId);
  const today=mine.filter(q=>now-new Date(q.created_at).getTime()<864e5).length;
  const waiting=mine.filter(q=>q.product_id===productId&&!q.answered_at).length;
  if(today>=DAILY_LIMIT)return{blocked:true,message:`You have asked ${DAILY_LIMIT} questions today. Please try again tomorrow.`};
  if(waiting>=PENDING_PER_PRODUCT)return{blocked:true,message:'You already have questions waiting on this product. We will answer them soon.'};
  return{blocked:false,message:''};
}
