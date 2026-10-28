export const CHAT_SYNC_MS = 5000;
export const CHAT_PRIVACY_NOTICE = 'Never share passwords, OTP/TAC codes, PINs, card numbers, CVV codes or other private sensitive information in chat. Use your order page to submit payment receipts.';

export function mergeMessages(previous, incoming) {
  const rows = new Map(previous.map(row => [row.id, row]));
  for (const row of incoming) rows.set(row.id, row);
  return [...rows.values()].sort((a,b) => a.created_at.localeCompare(b.created_at) || a.id.localeCompare(b.id));
}

// One request at a time. Cleanup prevents old conversations updating a new view.
export function createChatSync(load, {onSuccess, onError, intervalMs=CHAT_SYNC_MS, schedule=setInterval, cancel=clearInterval}={}) {
  let stopped=false, flight=null;
  const sync=()=>{
    if(stopped) return Promise.resolve();
    if(flight) return flight;
    flight=Promise.resolve().then(load).then(value=>{if(!stopped)onSuccess?.(value);return value;}).catch(error=>{if(!stopped)onError?.(error);}).finally(()=>{flight=null;});
    return flight;
  };
  const timer=schedule(()=>void sync(),intervalMs);
  return {sync,stop(){stopped=true;cancel(timer);}};
}
