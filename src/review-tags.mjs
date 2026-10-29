/* Reviews keep a single text field in the database. Highlights chosen by the buyer are stored as a
   final "[Highlights: A, B]" line and split back out for display, so no schema change is needed. */
export const REVIEW_TAGS=['Quality','Value for money','Matches description','Fast delivery','Packaging','Seller service'];
export const RATING_WORDS={1:'Terrible',2:'Poor',3:'Average',4:'Good',5:'Excellent'};
const TAG_LINE=/\n*\[Highlights: ([^\]]+)\]\s*$/;

export function parseReview(body=''){
  const text=String(body),match=text.match(TAG_LINE);
  if(!match)return{text,tags:[]};
  return{text:text.replace(TAG_LINE,'').trim(),tags:match[1].split(',').map(t=>t.trim()).filter(t=>REVIEW_TAGS.includes(t))};
}
export function composeReview(text,tags=[]){
  const clean=text.trim(),known=REVIEW_TAGS.filter(t=>tags.includes(t));
  return known.length?`${clean}\n\n[Highlights: ${known.join(', ')}]`:clean;
}

/* The database allows 2000 characters in total, so the visible text shrinks as highlights are added */
export const REVIEW_LIMIT=2000;
export function maxReviewText(tags=[]){return REVIEW_LIMIT-composeReview('',tags).length;}
