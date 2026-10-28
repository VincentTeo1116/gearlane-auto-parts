import {createContext,useContext,useRef,useState} from 'react';
import {friendlyError} from './domain.mjs';
export const AppContext=createContext(null);
export const useApp=()=>useContext(AppContext);
export function useTask(){const{run}=useApp(),[busy,setBusy]=useState(false),[error,setError]=useState(''),lock=useRef(false);return{busy,error,setError,async perform(task,success){if(lock.current)return{ok:false};lock.current=true;setBusy(true);setError('');try{return{ok:true,value:await run(task,success)};}catch(e){setError(friendlyError(e));return{ok:false};}finally{lock.current=false;setBusy(false);}}};}
