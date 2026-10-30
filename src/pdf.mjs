/* A small PDF writer: A4 pages, text in Helvetica and Helvetica Bold, lines and rectangles. No dependencies.
   It is deliberately limited to what an invoice needs. Text is reduced to plain ASCII (the PDF standard fonts
   cannot draw other scripts), and anything it cannot draw becomes "?" rather than corrupting the file. */

/* Advance widths (1000 units per em) for ASCII 32 to 126 from the standard Helvetica metrics */
const REGULAR=[278,278,355,556,556,889,667,191,333,333,389,584,278,333,278,278,556,556,556,556,556,556,556,556,556,556,278,278,584,584,584,556,1015,667,667,722,722,667,611,778,722,278,500,667,556,833,722,778,667,778,722,667,611,722,667,944,667,667,611,278,278,278,469,556,333,556,556,500,556,556,278,556,556,222,222,500,222,833,556,556,556,556,333,500,278,556,500,722,500,500,500,334,260,334,584];
const BOLD=[278,333,474,556,556,889,722,238,333,333,389,584,278,333,278,278,556,556,556,556,556,556,556,556,556,556,333,333,584,584,584,611,975,722,722,722,722,667,611,778,722,278,556,722,611,833,722,778,667,778,722,667,611,722,667,944,667,667,611,333,278,333,584,556,333,556,611,556,611,556,333,611,611,278,278,556,278,889,611,611,611,611,389,556,333,611,556,778,556,556,500,389,280,389,584];

const REPLACEMENTS={'–':'-','—':'-','‘':"'",'’':"'",'“':'"','”':'"','…':'...','×':'x',' ':' ','•':'-','−':'-'};

/* Plain printable ASCII only. Accents are stripped (é becomes e); anything else becomes "?" */
export function toPdfText(value){
  let out='';
  for(const ch of String(value??'').replace(/\r\n?/g,'\n')){
    if(ch==='\n'){out+='\n';continue;}
    if(ch==='\t'){out+=' ';continue;}
    if(ch.charCodeAt(0)<32||ch.charCodeAt(0)===127)continue; // other control characters are dropped
    if(REPLACEMENTS[ch]!==undefined){out+=REPLACEMENTS[ch];continue;}
    const code=ch.charCodeAt(0);
    if(code>=32&&code<=126){out+=ch;continue;}
    const base=ch.normalize('NFD').replace(/[̀-ͯ]/g,'');
    out+=base.length===1&&base.charCodeAt(0)>=32&&base.charCodeAt(0)<=126?base:'?';
  }
  return out;
}
const escapeText=s=>s.replace(/\\/g,'\\\\').replace(/\(/g,'\\(').replace(/\)/g,'\\)');
const number=n=>(Math.round(n*100)/100).toString();
const colour=c=>c.map(v=>number(v/255)).join(' ');

export function measure(text,size,bold=false){
  const table=bold?BOLD:REGULAR;let total=0;
  for(const ch of toPdfText(text)){const code=ch.charCodeAt(0);total+=ch==='\n'?0:table[code-32]??556;}
  return total*size/1000;
}

/* Word-wraps to a width. Explicit line breaks are kept and a word longer than the width is split. */
export function wrap(text,maxWidth,size,bold=false){
  const lines=[];
  for(const paragraph of toPdfText(text).split('\n')){
    if(!paragraph.trim()){lines.push('');continue;}
    let current='';
    for(const word of paragraph.split(/\s+/).filter(Boolean)){
      let piece=word;
      while(measure(piece,size,bold)>maxWidth&&piece.length>1){
        let cut=piece.length-1;while(cut>1&&measure(piece.slice(0,cut),size,bold)>maxWidth)cut--;
        if(current){lines.push(current);current='';}
        lines.push(piece.slice(0,cut));piece=piece.slice(cut);
      }
      const attempt=current?current+' '+piece:piece;
      if(measure(attempt,size,bold)<=maxWidth)current=attempt;else{lines.push(current);current=piece;}
    }
    if(current)lines.push(current);
  }
  return lines;
}

export class Pdf{
  constructor({title='Document',width=595.28,height=841.89,created=new Date()}={}){
    this.title=toPdfText(title).replace(/\n/g,' ');this.width=width;this.height=height;this.created=created;this.pages=[];this.page=null;
  }
  addPage(){this.page={ops:[]};this.pages.push(this.page);return this.pages.length;}
  /* y is measured from the TOP of the page in points; (x, y) is the left end of the text baseline */
  text(x,y,value,{size=10,bold=false,align='left',color=[26,38,52]}={}){
    const str=toPdfText(value).replace(/\n/g,' ');if(!str)return;
    const w=measure(str,size,bold),left=align==='right'?x-w:align==='center'?x-w/2:x;
    this.page.ops.push(`BT /${bold?'F2':'F1'} ${number(size)} Tf ${colour(color)} rg ${number(left)} ${number(this.height-y)} Td (${escapeText(str)}) Tj ET`);
  }
  line(x1,y1,x2,y2,{width=0.6,color=[200,210,220]}={}){
    this.page.ops.push(`${colour(color)} RG ${number(width)} w ${number(x1)} ${number(this.height-y1)} m ${number(x2)} ${number(this.height-y2)} l S`);
  }
  rect(x,y,w,h,{fill=null,stroke=null,width=0.6}={}){
    const parts=[];
    if(fill)parts.push(`${colour(fill)} rg`);
    if(stroke)parts.push(`${colour(stroke)} RG ${number(width)} w`);
    parts.push(`${number(x)} ${number(this.height-y-h)} ${number(w)} ${number(h)} re ${fill&&stroke?'B':fill?'f':'S'}`);
    this.page.ops.push(parts.join(' '));
  }
  /* Returns the finished file as bytes */
  build(){
    if(!this.pages.length)this.addPage();
    const objects=[];
    const add=body=>{objects.push(body);return objects.length;};
    const catalog=add(''),pagesRoot=add(''),font1=add('<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica /Encoding /WinAnsiEncoding >>'),font2=add('<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica-Bold /Encoding /WinAnsiEncoding >>');
    const kids=[];
    for(const page of this.pages){
      const content=page.ops.join('\n'),stream=add(`<< /Length ${content.length} >>\nstream\n${content}\nendstream`);
      kids.push(add(`<< /Type /Page /Parent ${pagesRoot} 0 R /MediaBox [0 0 ${number(this.width)} ${number(this.height)}] /Resources << /Font << /F1 ${font1} 0 R /F2 ${font2} 0 R >> >> /Contents ${stream} 0 R >>`));
    }
    const d=this.created,pad=n=>String(n).padStart(2,'0');
    const stamp=`D:${d.getUTCFullYear()}${pad(d.getUTCMonth()+1)}${pad(d.getUTCDate())}${pad(d.getUTCHours())}${pad(d.getUTCMinutes())}${pad(d.getUTCSeconds())}Z`;
    const info=add(`<< /Title (${escapeText(this.title)}) /Producer (GearLane) /CreationDate (${stamp}) >>`);
    objects[catalog-1]=`<< /Type /Catalog /Pages ${pagesRoot} 0 R >>`;
    objects[pagesRoot-1]=`<< /Type /Pages /Kids [${kids.map(k=>k+' 0 R').join(' ')}] /Count ${kids.length} >>`;
    let out='%PDF-1.4\n%âãÏÓ\n';const offsets=[];
    objects.forEach((body,i)=>{offsets.push(out.length);out+=`${i+1} 0 obj\n${body}\nendobj\n`;});
    const xref=out.length;
    out+=`xref\n0 ${objects.length+1}\n0000000000 65535 f \n`+offsets.map(o=>String(o).padStart(10,'0')+' 00000 n \n').join('');
    out+=`trailer\n<< /Size ${objects.length+1} /Root ${catalog} 0 R /Info ${info} 0 R >>\nstartxref\n${xref}\n%%EOF\n`;
    const bytes=new Uint8Array(out.length);for(let i=0;i<out.length;i++)bytes[i]=out.charCodeAt(i)&0xFF;
    return bytes;
  }
}
