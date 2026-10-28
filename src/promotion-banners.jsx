import React,{useEffect,useRef,useState} from 'react';
import {ChevronLeft,ChevronRight,Pause,Play} from 'lucide-react';
import {useApp} from './context.jsx';
import {Link} from './components.jsx';

function PromotionArtwork({banner,first,onError}){
 const [ready,setReady]=useState(false),image=useRef(null);
 useEffect(()=>{setReady(Boolean(image.current?.complete&&image.current?.naturalWidth));},[banner.image_url,banner.mobile_image_url]);
 return <picture className={'promotion-artwork '+(ready?'is-loaded':'is-loading')}>{banner.mobile_image_url?<source media="(max-width: 760px)" srcSet={banner.mobile_image_url}/>:null}<img ref={image} src={banner.image_url} alt={banner.alt_text} width={1920} height={640} loading={first?'eager':'lazy'} fetchPriority={first?'high':'low'} decoding="async" onLoad={()=>setReady(true)} onError={onError}/></picture>;
}

export function PromotionCarousel(){
 const {data,go}=useApp(),track=useRef(null),activeRef=useRef(0);
 const [index,setIndex]=useState(0),[failed,setFailed]=useState(new Set()),[playing,setPlaying]=useState(false),[hovered,setHovered]=useState(false),[reduced,setReduced]=useState(()=>matchMedia('(prefers-reduced-motion: reduce)').matches),[visible,setVisible]=useState(!document.hidden);
 const rows=(data?.banners||[]).filter(b=>b.published&&b.image_url&&!failed.has(b.id)).sort((a,b)=>a.position-b.position||String(b.created_at).localeCompare(String(a.created_at)));
 const signature=rows.map(b=>b.id+':'+b.version).join('|');
 activeRef.current=index;
 const navigate=next=>{if(!track.current||!rows.length)return;const target=(next+rows.length)%rows.length;track.current.scrollTo({left:target*track.current.clientWidth,behavior:reduced?'instant':'smooth'});if(reduced)setIndex(target);};
 useEffect(()=>{const media=matchMedia('(prefers-reduced-motion: reduce)'),change=()=>{setReduced(media.matches);if(media.matches)setPlaying(false);};media.addEventListener('change',change);const visibility=()=>setVisible(!document.hidden);document.addEventListener('visibilitychange',visibility);return()=>{media.removeEventListener('change',change);document.removeEventListener('visibilitychange',visibility);};},[]);
 useEffect(()=>{setIndex(0);if(track.current)track.current.scrollLeft=0;},[signature]);
 useEffect(()=>{const resize=()=>{if(track.current)track.current.scrollLeft=activeRef.current*track.current.clientWidth;};window.addEventListener('resize',resize);return()=>window.removeEventListener('resize',resize);},[]);
 useEffect(()=>{if(!playing||hovered||reduced||!visible||rows.length<2)return;const timer=setInterval(()=>navigate(activeRef.current+1),6000);return()=>clearInterval(timer);},[playing,hovered,reduced,visible,signature]);
 if(!rows.length)return null;
 return <section className="container promotion-carousel" role="region" aria-roledescription="carousel" aria-label="Store promotions" onMouseEnter={()=>setHovered(true)} onMouseLeave={()=>setHovered(false)} onFocusCapture={()=>setPlaying(false)}>
  <div className="promotion-track" ref={track} onScroll={e=>{const el=e.currentTarget;if(el.clientWidth)setIndex(Math.min(rows.length-1,Math.round(el.scrollLeft/el.clientWidth)));}}>
   {rows.map((b,i)=>{
    const content=<PromotionArtwork banner={b} first={i===0} onError={()=>setFailed(old=>new Set([...old,b.id]))}/>;
    return <div key={b.id} className="promotion-slide" role="group" aria-roledescription="slide" aria-label={(i+1)+' of '+rows.length+': '+b.title} aria-hidden={i!==index} inert={i!==index?true:undefined}>{b.link_path?<Link to={b.link_path} go={go} aria-label={b.alt_text}>{content}</Link>:content}</div>;
   })}
  </div>
  {rows.length>1?<div className="promotion-controls"><div className="promotion-arrows"><button aria-label="Previous promotion" onClick={()=>navigate(index-1)}><ChevronLeft size={19}/></button><span>{index+1}<i>/</i>{rows.length}</span><button aria-label="Next promotion" onClick={()=>navigate(index+1)}><ChevronRight size={19}/></button></div><div className="promotion-dots">{rows.map((b,i)=><button key={b.id} aria-label={'Show promotion '+(i+1)} aria-current={i===index?'true':undefined} onClick={()=>navigate(i)}><span/></button>)}</div><button className="promotion-play" aria-label={playing?'Pause promotions':'Play promotions'} disabled={reduced} onClick={()=>setPlaying(!playing)}>{playing?<Pause size={15}/>:<Play size={15}/>}<span>{playing?'Pause':'Play'}</span></button></div>:null}
  <span className="sr-only" role="status" aria-live={playing?'off':'polite'}>{rows[index]?.title}</span>
 </section>;
}
