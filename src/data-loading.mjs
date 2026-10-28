export const DATA_SECTIONS=['orders','refunds','conversations','notifications','wishlist','restock','directory','users','audit','banners'];

export function sectionsForRoute(role,path) {
 if(!role)return [];
 const sections=['notifications',...(role==='customer'?['wishlist']:[])];
 if(role==='customer'){
  if(path==='/'||path==='/account'||path==='/checkout'||path==='/orders'||path.startsWith('/orders/'))sections.push('orders');
  if(path.startsWith('/orders/'))sections.push('refunds');
  if(path==='/account')sections.push('conversations');
 }else if(path.startsWith('/workspace')){
  sections.push('orders');
  if(path==='/workspace'||path==='/workspace/refunds'||path.startsWith('/workspace/orders/'))sections.push('refunds');
  if(path==='/workspace/restock')sections.push('restock');
  if(path==='/workspace/messages')sections.push('directory');
  if(role==='admin'){
   if(path==='/workspace/users')sections.push('users');
   if(path==='/workspace/audit')sections.push('users','audit');
   if(path==='/workspace/banners')sections.push('banners');
  }
 }
 return [...new Set(sections)];
}

export function mergeSnapshot(previous,next,sameOwner) {
 const empty=Object.fromEntries(DATA_SECTIONS.map(key=>[key,[]]));
 return {...empty,...(sameOwner?previous:{}),...next};
}

export function screenKind(path) {
 if(path.includes('orders'))return 'orders';
 if(path.includes('messages'))return 'messages';
 if(path.includes('account')||path.includes('users')||path.includes('settings'))return 'form';
 if(path.startsWith('/workspace'))return 'dashboard';
 return 'products';
}
