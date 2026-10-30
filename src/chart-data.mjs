/* Turns the statistics the database returns into the bars the dashboard draws.
   The database only returns days that had sales, so quiet days are filled in with zero: a trend chart needs
   every day on the axis or the shape lies. Dates are Malaysia dates, matching how the database groups them. */
const KL_OFFSET=8*36e5,DAY=864e5;
const MONTHS=['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
const WEEKDAYS=['Sun','Mon','Tue','Wed','Thu','Fri','Sat'];

export const klDate=ms=>new Date(ms+KL_OFFSET).toISOString().slice(0,10);
const parts=key=>{const [y,m,d]=key.split('-').map(Number);return{y,m,d};};
export const formatDay=key=>{const {m,d}=parts(key);return `${d} ${MONTHS[m-1]}`;};
export const formatWeekday=key=>{const {y,m,d}=parts(key);return WEEKDAYS[new Date(Date.UTC(y,m-1,d)).getUTCDay()];};
export const formatHour=h=>h===0?'12 AM':h<12?`${h} AM`:h===12?'12 PM':`${h-12} PM`;

/* Every day of the period, oldest first, zero where nothing was sold */
export function dailySeries(rows,days,now=Date.now()){
  const sales=new Map((rows||[]).map(r=>[String(r.day),Number(r.value)||0]));
  const out=[];
  for(let i=days-1;i>=0;i--){
    const key=klDate(now-i*DAY);
    out.push({name:key,axis:formatDay(key),label:`${formatWeekday(key)} ${formatDay(key)}`,value:sales.get(key)||0});
  }
  return out;
}

/* Seven-day groups counted back from today, so the newest bar is always a full week */
export function weeklySeries(daily){
  const groups=[];
  for(let end=daily.length;end>0;end-=7)groups.unshift(daily.slice(Math.max(0,end-7),end));
  return groups.map(g=>{
    const first=g[0].name,last=g.at(-1).name;
    return{name:first,axis:formatDay(first),label:first===last?formatDay(first):`${formatDay(first)} to ${formatDay(last)}`,value:g.reduce((s,d)=>s+d.value,0)};
  });
}

export function hourlySeries(rows){
  const counts=new Map((rows||[]).map(r=>[Number(r.hour),Number(r.count)||0]));
  return Array.from({length:24},(_,h)=>({name:String(h).padStart(2,'0')+':00',axis:formatHour(h),label:`${formatHour(h)} to ${formatHour((h+1)%24)}`,value:counts.get(h)||0}));
}

/* What the chart shows for a metric and period: daily bars up to 45 days, weekly bars beyond that (90 thin bars cannot be read) */
export function buildSeries(metric,stats,days,now=Date.now()){
  if(metric!=='daily')return hourlySeries(stats?.active_hours);
  const daily=dailySeries(stats?.daily_sales,days,now);
  return days>45?weeklySeries(daily):daily;
}

/* Label every Nth bar, counted back from the newest, so labels never touch */
export function tickEvery(count,plotWidth,labelWidth,gap=12){
  if(count<=0||plotWidth<=0)return 1;
  return Math.max(1,Math.ceil((labelWidth+gap)/(plotWidth/count)));
}
