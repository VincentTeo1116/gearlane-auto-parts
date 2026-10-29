import test from 'node:test';
import assert from 'node:assert/strict';
import {composeReview,maxReviewText,parseReview,REVIEW_TAGS} from '../src/review-tags.mjs';
import {reviewSchema} from '../src/domain.mjs';

test('highlights round-trip through the single review text field',()=>{
  const body=composeReview('  Arrived quickly and fits well.  ',['Fast delivery','Quality']);
  assert.equal(body,'Arrived quickly and fits well.\n\n[Highlights: Quality, Fast delivery]');
  assert.deepEqual(parseReview(body),{text:'Arrived quickly and fits well.',tags:['Quality','Fast delivery']});
});
test('reviews without highlights and legacy reviews are unchanged',()=>{
  assert.equal(composeReview('Plain feedback text.',[]),'Plain feedback text.');
  assert.deepEqual(parseReview('Legacy review with no tags.'),{text:'Legacy review with no tags.',tags:[]});
  assert.deepEqual(parseReview(undefined),{text:'',tags:[]});
});
test('unknown or injected highlight names are dropped',()=>{
  assert.equal(composeReview('Good part, thanks.',['Hacked']),'Good part, thanks.');
  assert.deepEqual(parseReview('Text here ok.\n\n[Highlights: Quality, <b>x</b>]').tags,['Quality']);
});
test('the text limit shrinks with highlights so a full review always fits the 2000-character limit',()=>{
  assert.equal(maxReviewText([]),2000);
  const max=maxReviewText(REVIEW_TAGS),body=composeReview('x'.repeat(max),REVIEW_TAGS);
  assert.equal(body.length,2000);
  assert.equal(reviewSchema.safeParse({order_id:crypto.randomUUID(),product_id:'p1',rating:5,body}).success,true);
});
