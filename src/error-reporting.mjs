/* Reports uncaught browser errors to /api/client-error (production, live mode only).
   At most five reports per page load, and the same message is never sent twice. */
let sent=0;
const seen=new Set();

export function reportError(error,kind='error'){
  try{
    if(sent>=5||typeof navigator==='undefined'||!navigator.sendBeacon)return false;
    const message=String(error?.message||error||'Unknown error');
    if(seen.has(message))return false;
    seen.add(message);sent++;
    const payload={message,kind,stack:error?.stack,route:location.pathname,source:error?.filename,userAgent:navigator.userAgent};
    return navigator.sendBeacon('/api/client-error',new Blob([JSON.stringify(payload)],{type:'application/json'}));
  }catch{return false;}
}

export function installErrorReporting(){
  addEventListener('error',event=>reportError(event.error||event.message,'error'));
  addEventListener('unhandledrejection',event=>reportError(event.reason,'promise'));
}
