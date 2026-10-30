/* "Recently viewed" products, kept in the browser only. The storage is passed in so tests can use a fake. */
const KEY='gearlane_recent';
const MAX=12;
const defaultStore=()=>{try{return localStorage;}catch{return null;}};

export function readRecent(store=defaultStore()){
  try{
    const list=JSON.parse(store?.getItem(KEY)||'[]');
    return Array.isArray(list)?list.filter(id=>typeof id==='string'&&id.length<=100).slice(0,MAX):[];
  }catch{return [];}
}
export function pushRecent(id,store=defaultStore()){
  if(typeof id!=='string'||!id)return readRecent(store);
  const next=[id,...readRecent(store).filter(x=>x!==id)].slice(0,MAX);
  try{store?.setItem(KEY,JSON.stringify(next));}catch{/* private mode: the list simply is not remembered */}
  return next;
}
export function clearRecent(store=defaultStore()){try{store?.removeItem(KEY);}catch{/* nothing to clear */}}
