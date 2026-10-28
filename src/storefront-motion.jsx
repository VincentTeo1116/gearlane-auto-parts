import React,{useLayoutEffect} from 'react';
import {ArrowRight,MessageCircle,ShieldCheck,SlidersHorizontal} from 'lucide-react';
import {useApp} from './context.jsx';
import {Link,ProductArt} from './components.jsx';

export function ServiceShowcase({products}){
 const {go,openSupport}=useApp();
 const oil=products.find(p=>p.category==='Engine Oil'),brakes=products.find(p=>p.category==='Brake Pads'),filters=products.find(p=>p.category==='Filters');
 return <section className="container service-showcase"><div className="showcase-primary"><div className="showcase-grid" aria-hidden="true"/><div className="showcase-copy"><span className="eyebrow"><span/>THE PARTS BEHIND A BETTER SERVICE</span><h1>The right parts.<br/>For your<br/><em>next service.</em></h1><p>Find your essentials. Check the specification. Get a helpful answer before you order.</p><div className="actions"><Link to="/shop" go={go} className="button">Explore all parts<ArrowRight size={18}/></Link><button className="showcase-help" onClick={()=>openSupport(null)}><MessageCircle size={18}/>Ask the team</button></div><div className="showcase-trust"><ShieldCheck size={15}/>Your complete total, before you order.</div></div><div className="showcase-product"><div className="showcase-orbit" aria-hidden="true"/><ProductArt product={oil}/><span>Illustrated service essentials</span></div><div className="showcase-bottom"><b>{products.length}<span>catalogue parts to explore</span></b><span><SlidersHorizontal size={14}/>Find by category, brand or part number</span></div></div><div className="showcase-secondary">
  <Link to="/shop?category=Brake%20Pads" go={go} className="showcase-tile brakes"><div><span className="eyebrow">THE NEXT CHECK ON YOUR LIST</span><h2>Brake pads.<br/>Details that matter.</h2><span className="tile-action">Explore brake pads<ArrowRight size={15}/></span></div><ProductArt product={brakes}/></Link>
  <Link to="/shop?category=Filters" go={go} className="showcase-tile filters"><div><span className="eyebrow">KEEP YOUR SERVICE SIMPLE</span><h2>A fresh start.<br/>Find your filter.</h2><span className="tile-action">Shop filter parts<ArrowRight size={15}/></span></div><ProductArt product={filters}/></Link>
 </div></section>;
}

export function CategoryGlyph({category}){
 const key=category.toLowerCase(),oil=/oil|fluid|coolant|cleaner/.test(key),brake=/brake pad/.test(key),filter=/filter/.test(key),wiper=/wiper/.test(key),spark=/spark/.test(key);
 return <svg className="category-glyph" viewBox="0 0 64 64" aria-hidden="true"><rect x="3" y="3" width="58" height="58" rx="17" fill={oil?'#f9e7d5':brake?'#e4edf3':filter?'#e8eedf':'#eee8f5'}/>{oil?<><path d="M25 15h14v9l8 6v24H18V29l7-5z" fill="#385c70"/><rect x="25" y="11" width="14" height="6" rx="2" fill="#e9ac75"/><path d="m32 30-6 10a7 7 0 1 0 12 0z" fill="#f6d7b7"/></>:brake?<><circle cx="32" cy="32" r="18" fill="#829cac"/><circle cx="32" cy="32" r="12" fill="#d4e2e8"/><circle cx="32" cy="32" r="5" fill="#48697c"/><path d="M45 18q14 14 2 28l-8-6q7-9-1-17z" fill="#c78d5d"/></>:filter?<><rect x="16" y="15" width="33" height="35" rx="5" fill="#537166"/><rect x="21" y="20" width="23" height="25" rx="2" fill="#e8d4ad"/><path d="M25 23v19m7-19v19m7-19v19" stroke="#b49b71" strokeWidth="3"/></>:wiper?<><path d="M14 45q13-26 37-28" fill="none" stroke="#537085" strokeWidth="6" strokeLinecap="round"/><path d="m29 34 7 17" stroke="#a3b7c3" strokeWidth="5" strokeLinecap="round"/></>:spark?<><path d="m24 13 8-3 7 20-8 3z" fill="#f2f4ee" stroke="#b0bfbd" strokeWidth="2"/><path d="m29 32 13-4 4 12-13 4z" fill="#62818a"/><path d="m34 44 10-3 4 12-9 3z" fill="#b5c6c8"/></>:<><path d="m18 42 12-8V18h13v17l10 7" fill="none" stroke="#708596" strokeWidth="8" strokeLinejoin="round"/><circle cx="17" cy="42" r="5" fill="#c8d4db"/></>}</svg>;
}

export function PageReveals(){
 useLayoutEffect(()=>{
  if(matchMedia('(prefers-reduced-motion: reduce)').matches||!('IntersectionObserver' in window))return;
  const elements=[...document.querySelectorAll('.customer-home .category-section,.customer-home .home-products,.customer-home .order-explained,.customer-home .human-help')];
  const observer=new IntersectionObserver(entries=>{for(const entry of entries)if(entry.isIntersecting){entry.target.classList.add('is-revealed');observer.unobserve(entry.target);}},{threshold:.06,rootMargin:'0px 0px 40px 0px'});
  elements.forEach(el=>{el.classList.add('reveal-ready');observer.observe(el);});
  return()=>{observer.disconnect();elements.forEach(el=>el.classList.remove('reveal-ready','is-revealed'));};
 },[]);
 return null;
}
