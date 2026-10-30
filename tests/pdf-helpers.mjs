/* A strict little PDF reader for tests: it checks the file's own bookkeeping (header, cross-reference table,
   stream lengths, trailer) and pulls the drawn text back out. It only understands files made by src/pdf.mjs,
   but it fails loudly on any structural mistake that would make a real viewer complain. */
const latin1=bytes=>{let s='';for(let i=0;i<bytes.length;i++)s+=String.fromCharCode(bytes[i]);return s;};
const unescapeText=s=>s.replace(/\\([()\\])/g,'$1');

export function parsePdf(bytes){
  const text=latin1(bytes),problems=[];
  if(!text.startsWith('%PDF-1.'))problems.push('missing header');
  if(!text.trimEnd().endsWith('%%EOF'))problems.push('missing %%EOF');
  const start=/startxref\n(\d+)\n%%EOF/.exec(text);
  if(!start)problems.push('missing startxref');
  const xrefAt=start?Number(start[1]):-1;
  if(xrefAt<0||text.slice(xrefAt,xrefAt+4)!=='xref')problems.push('startxref does not point at the xref table');
  const header=/xref\n0 (\d+)\n/.exec(text.slice(xrefAt));
  const count=header?Number(header[1]):0;
  const entries=[...text.slice(xrefAt).matchAll(/(\d{10}) (\d{5}) ([nf]) \n/g)].map(m=>({offset:Number(m[1]),gen:Number(m[2]),kind:m[3]}));
  if(entries.length!==count)problems.push(`xref lists ${entries.length} of ${count} entries`);
  entries.forEach((e,i)=>{if(i===0)return;if(text.slice(e.offset,e.offset+(`${i} 0 obj`).length)!==`${i} 0 obj`)problems.push(`object ${i} is not at offset ${e.offset}`);});
  const trailer=/trailer\n<< \/Size (\d+) \/Root (\d+) 0 R \/Info (\d+) 0 R >>/.exec(text);
  if(!trailer)problems.push('bad trailer');else if(Number(trailer[1])!==count)problems.push('trailer Size does not match the xref');
  const objects=[...text.matchAll(/(\d+) 0 obj\n([\s\S]*?)\nendobj\n/g)].map(m=>({id:Number(m[1]),body:m[2]}));
  if(objects.length!==count-1)problems.push(`found ${objects.length} objects, expected ${count-1}`);
  const pages=[];
  for(const o of objects){
    if(/^<< \/Type \/Page /.test(o.body)){
      const contents=/\/Contents (\d+) 0 R/.exec(o.body),media=/\/MediaBox \[0 0 ([\d.]+) ([\d.]+)\]/.exec(o.body);
      const stream=objects.find(x=>x.id===Number(contents?.[1]));
      if(!stream){problems.push(`page ${o.id} has no content stream`);continue;}
      const m=/^<< \/Length (\d+) >>\nstream\n([\s\S]*)\nendstream$/.exec(stream.body);
      if(!m){problems.push(`stream ${stream.id} is malformed`);continue;}
      if(Number(m[1])!==m[2].length)problems.push(`stream ${stream.id} declares length ${m[1]} but holds ${m[2].length}`);
      const runs=[...m[2].matchAll(/BT \/(F[12]) ([\d.]+) Tf [\d. ]+ rg ([\d.-]+) ([\d.-]+) Td \(((?:\\.|[^\\)])*)\) Tj ET/g)].map(r=>({font:r[1],size:Number(r[2]),x:Number(r[3]),y:Number(r[4]),text:unescapeText(r[5])}));
      pages.push({width:Number(media?.[1]),height:Number(media?.[2]),content:m[2],runs,text:runs.map(r=>r.text)});
    }
  }
  const pagesRoot=objects.find(o=>/^<< \/Type \/Pages /.test(o.body));
  if(!pagesRoot||Number(/\/Count (\d+)/.exec(pagesRoot.body)?.[1])!==pages.length)problems.push('page count does not match');
  const title=/\/Title \(((?:\\.|[^\\)])*)\)/.exec(text)?.[1];
  return{problems,pages,objectCount:count-1,title:title?unescapeText(title):null,allText:pages.flatMap(p=>p.text)};
}
export const pdfIsValid=bytes=>parsePdf(bytes).problems;
