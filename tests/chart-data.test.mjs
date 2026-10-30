import test from 'node:test';
import assert from 'node:assert/strict';
import {buildSeries,dailySeries,formatDay,formatHour,formatWeekday,hourlySeries,klDate,tickEvery,weeklySeries} from '../src/chart-data.mjs';

const NOW=Date.parse('2026-10-31T10:00:00Z');   // 6 pm on 31 Oct in Malaysia

test('Malaysia dates, not UTC dates, decide which day an instant belongs to',()=>{
  assert.equal(klDate(Date.parse('2026-10-31T10:00:00Z')),'2026-10-31');
  assert.equal(klDate(Date.parse('2026-10-31T17:00:00Z')),'2026-11-01','1 am the next morning in Malaysia');
  assert.equal(klDate(Date.parse('2026-10-31T15:59:00Z')),'2026-10-31');
});
test('dates and hours read like words',()=>{
  assert.equal(formatDay('2026-10-01'),'1 Oct');assert.equal(formatDay('2026-12-25'),'25 Dec');assert.equal(formatWeekday('2026-10-31'),'Sat');assert.equal(formatWeekday('2026-11-01'),'Sun');
  assert.deepEqual([0,1,11,12,13,23].map(formatHour),['12 AM','1 AM','11 AM','12 PM','1 PM','11 PM']);
});
test('every day is on the axis, oldest first, with zero for days nothing was sold',()=>{
  const series=dailySeries([{day:'2026-10-31',value:'5000'},{day:'2026-10-29',value:1200},{day:'2026-10-01',value:99999}],7,NOW);
  assert.equal(series.length,7);assert.deepEqual(series.map(s=>s.name),['2026-10-25','2026-10-26','2026-10-27','2026-10-28','2026-10-29','2026-10-30','2026-10-31']);
  assert.deepEqual(series.map(s=>s.value),[0,0,0,0,1200,0,5000],'a day outside the period is ignored, a text amount is read as a number');
  assert.equal(series.at(-1).label,'Sat 31 Oct');assert.equal(series.at(-1).axis,'31 Oct');
  assert.equal(new Set(series.map(s=>s.name)).size,7);
  assert.equal(dailySeries(undefined,3,NOW).every(s=>s.value===0),true);assert.deepEqual(dailySeries([],0,NOW),[]);
});
test('the period can cross a month and a year boundary without gaps',()=>{
  const series=dailySeries([],5,Date.parse('2027-01-02T04:00:00Z'));
  assert.deepEqual(series.map(s=>s.axis),['29 Dec','30 Dec','31 Dec','1 Jan','2 Jan']);
  const long=dailySeries([],90,NOW);assert.equal(long.length,90);assert.equal(long[0].name,klDate(NOW-89*864e5));
});
test('weekly bars hold exactly the daily total, newest week complete, oldest week possibly short',()=>{
  const daily=dailySeries([{day:'2026-10-31',value:100},{day:'2026-10-12',value:50},{day:'2026-08-05',value:25}],90,NOW);
  const weeks=weeklySeries(daily);
  assert.equal(weeks.length,13);assert.equal(weeks.reduce((s,w)=>s+w.value,0),daily.reduce((s,d)=>s+d.value,0),'nothing is lost or counted twice');
  assert.equal(weeks.at(-1).label,'25 Oct to 31 Oct','the newest bar is a full seven days ending today');assert.equal(weeks.at(-1).value,100);
  assert.equal(weeks.length,Math.ceil(90/7));assert.equal(new Set(weeks.map(w=>w.name)).size,13);
  assert.equal(weeklySeries(dailySeries([],7,NOW)).length,1);assert.deepEqual(weeklySeries([]),[]);
  const odd=weeklySeries(dailySeries([],8,NOW));assert.equal(odd.length,2);assert.equal(odd[0].label,formatDay(odd[0].name),'a one-day first week shows a single date');
});
test('activity by hour always has 24 bars with readable labels',()=>{
  const hours=hourlySeries([{hour:'9',count:'4'},{hour:23,count:1}]);
  assert.equal(hours.length,24);assert.equal(hours[9].value,4);assert.equal(hours[9].axis,'9 AM');assert.equal(hours[9].label,'9 AM to 10 AM');assert.equal(hours[23].label,'11 PM to 12 AM');assert.equal(hours[0].axis,'12 AM');
  assert.equal(hours.reduce((s,h)=>s+h.value,0),5);assert.equal(hourlySeries(null).length,24);
});
test('the chart shows daily bars for short periods and weekly bars for long ones',()=>{
  const stats={daily_sales:[{day:'2026-10-31',value:700}],active_hours:[{hour:10,count:3}]};
  assert.equal(buildSeries('daily',stats,7,NOW).length,7);assert.equal(buildSeries('daily',stats,30,NOW).length,30);assert.equal(buildSeries('daily',stats,90,NOW).length,13);
  assert.equal(buildSeries('hours',stats,30,NOW).length,24);assert.equal(buildSeries('daily',null,30,NOW).length,30);
  for(const days of [7,30,90])assert.equal(buildSeries('daily',stats,days,NOW).reduce((s,b)=>s+b.value,0),700,days+' days keeps the total');
});
test('labels are spaced so they cannot touch',()=>{
  // 30 bars in 600px = 20px each; a 44px label plus a 12px gap needs every 3rd bar
  assert.equal(tickEvery(30,600,44),3);assert.equal(tickEvery(7,600,44),1,'a few wide bars: label them all');assert.equal(tickEvery(13,600,44),2);assert.equal(tickEvery(24,300,38),4);
  assert.equal(tickEvery(30,300,44),6,'a narrower chart labels fewer bars');assert.equal(tickEvery(0,600,44),1);assert.equal(tickEvery(10,0,44),1);
  for(const [count,width,label] of [[30,320,44],[90,300,44],[24,280,40],[13,600,44]]){const step=tickEvery(count,width,label);assert.ok(step*(width/count)>=label+12-0.001,`${count} bars in ${width}px at step ${step}`);}
});
