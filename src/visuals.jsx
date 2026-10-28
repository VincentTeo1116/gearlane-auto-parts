import React from 'react';

export function SuccessMark() {
  return <div className="success-mark" aria-hidden="true"><svg viewBox="0 0 100 100"><circle className="success-ring" cx="50" cy="50" r="43"/><path className="success-tick" d="m29 51 14 14 29-31"/></svg><i/><i/><i/></div>;
}

export function EmptyVisual() {
  return <svg className="empty-visual" viewBox="0 0 160 120" aria-hidden="true"><ellipse cx="80" cy="107" rx="43" ry="5" fill="#e7ebed"/><path d="m40 49 40-21 40 21-40 22z" fill="#f3dbc3"/><path d="m40 49 40 22v36l-40-22z" fill="#e9c09b"/><path d="m80 71 40-22v36l-40 22z" fill="#d99963"/><path d="m40 49-15 13 40 22 15-13 15 13 40-22-15-13" fill="#f8e6d4" stroke="#c58b5d" strokeWidth="1.5"/><path d="M80 9v9m-35 0 6 7m64-7-6 7" fill="none" stroke="#c6d0d5" strokeWidth="3" strokeLinecap="round"/></svg>;
}

export function DetourVisual() {
  return <div className="detour-visual" aria-hidden="true"><svg viewBox="0 0 620 270"><path d="M0 231h620" stroke="#dde4e7" strokeWidth="2"/><path d="M46 231h50m22 0h80m230 0h70m22 0h54" stroke="#a6b6c0" strokeWidth="4" strokeLinecap="round"/><path d="M452 231V77" stroke="#536c7d" strokeWidth="8"/><rect x="397" y="28" width="110" height="79" rx="13" fill="#f5a45b" transform="rotate(7 452 68)"/><path d="m427 69 40 4m-15-17 15 17-19 14" stroke="#193342" strokeWidth="6" fill="none" strokeLinecap="round" strokeLinejoin="round"/><g className="detour-car"><path d="m127 175 27-48h113l41 48 39 10v36H103v-34z" fill="#213f52"/><path d="m168 138-19 35h61v-35zm53 0v35h64l-29-35z" fill="#d9e7eb"/><rect x="303" y="188" width="32" height="11" rx="4" fill="#ffc675"/><rect x="111" y="188" width="13" height="10" rx="3" fill="#ec9b7b"/><circle cx="155" cy="218" r="23" fill="#172b38"/><circle cx="155" cy="218" r="11" fill="#a0b1ba"/><circle cx="296" cy="218" r="23" fill="#172b38"/><circle cx="296" cy="218" r="11" fill="#a0b1ba"/><path d="M224 183h14" stroke="#a6b8be" strokeWidth="4" strokeLinecap="round"/></g><circle cx="349" cy="123" r="5" fill="#e1b98b"/><path d="m361 88 9-13m-25 5-5-16" stroke="#c9d4d6" strokeWidth="3" strokeLinecap="round"/></svg><span>404</span></div>;
}

export function GarageScene() {
  return <svg className="garage-scene" viewBox="0 0 650 400" aria-hidden="true"><defs><linearGradient id="garage-backdrop" x2="0" y2="1"><stop stopColor="#f0e7dc"/><stop offset="1" stopColor="#f8f2ea"/></linearGradient></defs><rect width="650" height="400" rx="20" fill="url(#garage-backdrop)"/><path d="M60 306h530" stroke="#d3c8ba" strokeWidth="2"/><rect x="98" y="65" width="388" height="241" rx="7" fill="#e6ddd0"/><path d="M112 87h360m-360 25h360m-360 25h360m-360 25h360m-360 25h360m-360 25h360" stroke="#d8cdbf" strokeWidth="3"/><rect x="83" y="56" width="20" height="250" fill="#c0b39f"/><rect x="482" y="56" width="20" height="250" fill="#c0b39f"/><g className="garage-car"><ellipse cx="302" cy="325" rx="208" ry="16" fill="#8c9c9f" opacity=".18"/><path d="m121 229 64-70h160l91 62 73 15 22 56H92v-40z" fill="#28495c"/><path d="m197 171-48 52h97v-52zm62 0v52h137l-62-52z" fill="#b8d3dc"/><path d="M259 175h9v44h-9" fill="#83a5b2"/><path d="M110 250h404" stroke="#496b7a" strokeWidth="3"/><path d="m449 238 49 6 6 14h-48" fill="#f9bd72"/><rect x="95" y="244" width="17" height="15" rx="3" fill="#e5a085"/><path d="M95 285h431" stroke="#1a3344" strokeWidth="14"/><circle cx="170" cy="292" r="40" fill="#192e3b"/><circle cx="170" cy="292" r="23" fill="#bbc9cd"/><circle cx="170" cy="292" r="10" fill="#496676"/><circle cx="440" cy="292" r="40" fill="#192e3b"/><circle cx="440" cy="292" r="23" fill="#bbc9cd"/><circle cx="440" cy="292" r="10" fill="#496676"/><path d="M283 237h20" stroke="#a0b7bd" strokeWidth="4" strokeLinecap="round"/></g><g><rect x="529" y="126" width="68" height="8" rx="4" fill="#b3a58f"/><rect x="532" y="182" width="68" height="8" rx="4" fill="#b3a58f"/><path d="M541 124v-27h15v27m18 0V88h13v36" fill="#d79557"/><path d="M547 180v-29h35v29" fill="#6b8084"/><path d="m559 304 22-42 22 42z" fill="#e8a05d"/><path d="M568 285h28" stroke="#fff1d8" strokeWidth="7"/></g><path d="M46 348h557" stroke="#d7cdbf" strokeWidth="2" strokeDasharray="18 11"/></svg>;
}

export function StoreLoading() {
  return <main className="container loading-screen store-skeleton" role="status" aria-label="Loading the store" aria-busy="true"><div className="loading-caption"><span className="loading-orbit"/><div><b>Getting your parts ready</b><p>Loading the catalogue and your account…</p></div></div><div className="skeleton-hero" aria-hidden="true"><div><i className="skeleton-line short"/><i className="skeleton-line title"/><i className="skeleton-line title"/><i className="skeleton-line"/></div><div className="skeleton-picture"/></div><div className="skeleton-grid" aria-hidden="true">{[0,1,2,3].map(i=><div className="skeleton-card" key={i}><i/><span/><span/></div>)}</div></main>;
}

export function InlineLoading({label='Loading…'}) {
  return <div className="inline-loading" role="status"><span className="loading-orbit"/><span>{label}</span></div>;
}

export function ScreenSkeleton({kind='products'}) {
  const label=kind==='orders'?'Loading your orders':kind==='messages'?'Loading conversations':kind==='dashboard'?'Loading workspace data':kind==='form'?'Loading account details':'Loading parts';
  return <section className={'container section loading-screen route-skeleton '+kind} role="status" aria-label={label} aria-busy="true"><div className="route-skeleton-heading"><i className="skeleton-line short"/><i className="skeleton-line title"/><i className="skeleton-line"/></div><div className={kind==='products'?'skeleton-grid':'skeleton-records'} aria-hidden="true">{Array.from({length:kind==='products'?8:kind==='form'?4:3},(_,i)=><div className="skeleton-record" key={i}><i className="skeleton-avatar"/><div><i className="skeleton-line title"/><i className="skeleton-line"/><i className="skeleton-line short"/></div></div>)}</div><span className="sr-only">{label}. Please wait.</span></section>;
}
