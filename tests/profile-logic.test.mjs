import test from 'node:test';
import assert from 'node:assert/strict';
import {askLimits,checkAnswer,checkQuestion,isPublic,privacyWarning,publicCount,questionDisplayName,questionsForProduct,staffOrder} from '../src/qa.mjs';
import {activeVehicle,addressLines,addressTitle,defaultAddress,normaliseSavedAddress,sameAddress,sameVehicle,sortAddresses,startingAddress,vehicleTitle} from '../src/address-book.mjs';

const NOW=Date.parse('2026-10-31T12:00:00Z'),ago=h=>new Date(NOW-h*36e5).toISOString();

test('the public name is a first name and an initial, exactly as the database makes it',()=>{
  assert.equal(questionDisplayName('Amir Rahman'),'Amir R.');assert.equal(questionDisplayName('Siti'),'Siti');assert.equal(questionDisplayName('  Mary   Ann  Lee '),'Mary L.');
  assert.equal(questionDisplayName(''),'Customer');assert.equal(questionDisplayName(null),'Customer');assert.equal(questionDisplayName('lim wei'),'lim w.');
});
test('question and answer length rules match the database limits',()=>{
  assert.equal(checkQuestion('too short').ok,false);assert.equal(checkQuestion('exactly 10').ok,true);assert.equal(checkQuestion('x'.repeat(500)).ok,true);assert.equal(checkQuestion('x'.repeat(501)).ok,false);
  assert.equal(checkQuestion('   Will it fit my car?   ').clean,'Will it fit my car?');assert.equal(checkQuestion('            ').ok,false,'spaces alone are not a question');
  assert.equal(checkAnswer('x').ok,false);assert.equal(checkAnswer('Yes').ok,true);assert.equal(checkAnswer('y'.repeat(2001)).ok,false);assert.equal(checkAnswer(null).ok,false);
});
test('a gentle warning appears for phone numbers and email addresses only',()=>{
  assert.match(privacyWarning('Call me on 012-345 6789 please'),/phone number/);assert.match(privacyWarning('Reach me at amir@example.com'),/email/);
  assert.equal(privacyWarning('Does the 0W-20 oil suit a 2019 X50 with 4 litres?'),'');assert.equal(privacyWarning('Part number 12345 fits?'),'');assert.equal(privacyWarning(''),'');
});
test('a product page shows public answers to everyone and waiting questions only to their asker',()=>{
  const qs=[
    {id:'a',product_id:'p1',asker_id:'u1',question:'q',answer:'a',answered_at:ago(3),published:true,created_at:ago(10)},
    {id:'b',product_id:'p1',asker_id:'u2',question:'q',answer:'a',answered_at:ago(2),published:true,created_at:ago(9)},
    {id:'hidden',product_id:'p1',asker_id:'u2',question:'q',answer:'a',answered_at:ago(2),published:false,created_at:ago(8)},
    {id:'wait-u1',product_id:'p1',asker_id:'u1',question:'q',answer:null,answered_at:null,published:true,created_at:ago(1)},
    {id:'wait-u2',product_id:'p1',asker_id:'u2',question:'q',answer:null,answered_at:null,published:true,created_at:ago(1)},
    {id:'other',product_id:'p2',asker_id:'u1',question:'q',answer:'a',answered_at:ago(1),published:true,created_at:ago(1)},
  ];
  const guest=questionsForProduct(qs,'p1',null);assert.deepEqual(guest.answered.map(q=>q.id),['b','a'],'newest first, hidden ones excluded');assert.deepEqual(guest.mine,[]);
  assert.deepEqual(questionsForProduct(qs,'p1','u1').mine.map(q=>q.id),['wait-u1']);assert.deepEqual(questionsForProduct(qs,'p1','u2').mine.map(q=>q.id),['wait-u2']);
  assert.equal(publicCount(qs,'p1'),2);assert.equal(publicCount(qs,'p2'),1);assert.equal(publicCount(qs,'none'),0);
  assert.equal(isPublic({answered_at:ago(1)}),true);assert.equal(isPublic({answered_at:ago(1),published:false}),false);assert.equal(isPublic({answered_at:null}),false);
});
test('staff see the question that has waited longest first',()=>{
  const {open,done}=staffOrder([{id:'new',created_at:ago(1)},{id:'old',created_at:ago(50)},{id:'d1',created_at:ago(90),answered_at:ago(5)},{id:'d2',created_at:ago(80),answered_at:ago(2)}]);
  assert.deepEqual(open.map(q=>q.id),['old','new']);assert.deepEqual(done.map(q=>q.id),['d2','d1']);
});
test('the form knows the daily and per-product limits before the customer hits them',()=>{
  const mk=(n,extra={})=>Array.from({length:n},(_,i)=>({asker_id:'u1',product_id:'p'+i,created_at:ago(1),answered_at:ago(0.5),...extra}));
  assert.equal(askLimits(mk(4),'u1','px',NOW).blocked,false);assert.equal(askLimits(mk(5),'u1','px',NOW).blocked,true);assert.match(askLimits(mk(5),'u1','px',NOW).message,/tomorrow/);
  assert.equal(askLimits(mk(5).map(q=>({...q,created_at:ago(30)})),'u1','px',NOW).blocked,false,'older questions do not count towards today');
  const waiting=[{asker_id:'u1',product_id:'p1',answered_at:null,created_at:ago(30)},{asker_id:'u1',product_id:'p1',answered_at:null,created_at:ago(31)}];
  assert.match(askLimits(waiting,'u1','p1',NOW).message,/already have questions waiting/);assert.equal(askLimits(waiting,'u1','p2',NOW).blocked,false);assert.equal(askLimits(waiting,'u2','p1',NOW).blocked,false);
});

const good={label:' Home ',name:'Amir Rahman',phone:'0123456789',line1:'12 Jalan Demo, Taman Contoh',city:'Petaling Jaya',postcode:'47300',state:'Selangor'};
test('a saved address is checked with the same rules as checkout and trimmed',()=>{
  assert.deepEqual(normaliseSavedAddress(good),{...good,label:'Home'});
  assert.equal(normaliseSavedAddress({...good,label:undefined}).label,'');
  for(const bad of [{postcode:'1234'},{postcode:'ABCDE'},{phone:'abc'},{line1:'short'},{name:'A'},{city:''}])assert.throws(()=>normaliseSavedAddress({...good,...bad}),Error,JSON.stringify(bad));
  assert.throws(()=>normaliseSavedAddress({...good,label:'x'.repeat(41)}),/40 characters/);assert.throws(()=>normaliseSavedAddress(null),Error);
});
test('address helpers sort, compare and format predictably',()=>{
  const a={id:'a',...good,is_default:false,created_at:ago(5)},b={id:'b',...good,line1:'88 Jalan Bengkel',is_default:true,created_at:ago(50)},c={id:'c',...good,line1:'5 Lorong Baru, Subang',is_default:false,created_at:ago(1)};
  assert.deepEqual(sortAddresses([a,b,c]).map(x=>x.id),['b','c','a'],'default first, then newest');assert.equal(defaultAddress([a,b,c]).id,'b');assert.equal(defaultAddress([]),null);
  assert.equal(sameAddress(a,{...a,name:'  amir   RAHMAN '}),true);assert.equal(sameAddress(a,b),false);assert.equal(sameAddress(null,a),false);
  assert.deepEqual(addressLines(a),['Amir Rahman','12 Jalan Demo, Taman Contoh','47300 Petaling Jaya, Selangor','0123456789']);
  assert.equal(addressTitle({...a,label:'Workshop'}),'Workshop');assert.equal(addressTitle({...a,label:''}),'12 Jalan Demo');
});
test('checkout starts from the default saved address, then the last order, then the profile',()=>{
  const profile={full_name:'Amir Rahman',phone:'0111111111'};
  const saved=[{id:'s1',...good,line1:'Saved default 1, Jalan A',is_default:true,created_at:ago(9)},{id:'s2',...good,line1:'Saved other 2, Jalan B',is_default:false,created_at:ago(1)}];
  const orders=[{created_at:ago(100),address:{...good,line1:'Old order address, Jalan C'}},{created_at:ago(2),address:{...good,line1:'Latest order address, Jalan D'}}];
  assert.equal(startingAddress({saved,orders,profile}).line1,'Saved default 1, Jalan A');assert.equal(startingAddress({saved,orders,profile}).savedId,'s1');
  assert.equal(startingAddress({saved:[],orders,profile}).line1,'Latest order address, Jalan D');assert.equal(startingAddress({saved:[],orders,profile}).savedId,null);
  const blank=startingAddress({saved:[],orders:[],profile});assert.deepEqual([blank.name,blank.phone,blank.line1,blank.state],['Amir Rahman','0111111111','','Selangor']);
  assert.equal(startingAddress({}).state,'Selangor');
});
test('garage helpers',()=>{
  assert.equal(vehicleTitle({make:'Proton',model:'X50',year:2022}),'Proton X50 2022');assert.equal(vehicleTitle({make:'Perodua',model:'Myvi',year:null}),'Perodua Myvi');
  assert.equal(sameVehicle({make:'Proton',model:'X50',year:2022},{make:' proton ',model:'x50',year:2022}),true);assert.equal(sameVehicle({make:'Proton',model:'X50',year:2022},{make:'Proton',model:'X50',year:null}),false);
  assert.equal(activeVehicle([{id:1},{id:2,is_active:true}]).id,2);assert.equal(activeVehicle([{id:1}]),null);
});
