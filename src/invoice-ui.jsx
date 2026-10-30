import React,{useState} from 'react';
import {FileText} from 'lucide-react';
import {useApp} from './context.jsx';
import {Button} from './components.jsx';
import {buildInvoice,canInvoice,downloadPdf,invoiceFileName} from './invoice.mjs';

/* "Download invoice (PDF)". The PDF is built in the browser from the order, so nothing is uploaded anywhere. */
export function InvoiceButton({order,variant='secondary small',label='Download invoice (PDF)'}){
  const {data,notify}=useApp(),[busy,setBusy]=useState(false);
  if(!canInvoice(order))return null;
  const download=()=>{
    setBusy(true);
    try{downloadPdf(invoiceFileName(order),buildInvoice(order,{settings:data.settings}));}
    catch{notify('The invoice could not be created. Please try again or contact the store.','error');}
    finally{setBusy(false);}
  };
  return <Button variant={variant} busy={busy} onClick={download}><FileText size={15}/>{label}</Button>;
}
