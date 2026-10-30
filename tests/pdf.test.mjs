import test from 'node:test';
import assert from 'node:assert/strict';
import {Pdf,measure,toPdfText,wrap} from '../src/pdf.mjs';
import {parsePdf} from './pdf-helpers.mjs';

const built=(draw,pages=1)=>{const pdf=new Pdf({title:'Test (doc)',created:new Date('2026-10-30T04:00:00Z')});for(let i=0;i<pages;i++){pdf.addPage();draw(pdf,i);}return pdf.build();};

test('a PDF has correct header, cross-reference table, stream lengths and trailer for one or many pages',()=>{
  for(const pages of [0,1,3,12]){
    const bytes=built((pdf,i)=>{pdf.text(50,60,'Page '+(i+1),{size:14,bold:true});pdf.line(50,70,500,70);pdf.rect(50,80,100,20,{fill:[240,240,240],stroke:[0,0,0]});},Math.max(pages,0)||0);
    const parsed=parsePdf(bytes);
    assert.deepEqual(parsed.problems,[],`${pages} pages`);
    assert.equal(parsed.pages.length,Math.max(pages,1),'an empty document still gets one page');
    assert.equal(parsed.title,'Test (doc)','parentheses in the title are escaped');
  }
});
test('text with brackets, backslashes and long unicode survives exactly',()=>{
  const parsed=parsePdf(built(pdf=>{pdf.text(50,60,'Total (RM) \\ path (nested (brackets))');pdf.text(50,80,'Price — “quoted” café ½ 中文\tTabbed');}));
  assert.deepEqual(parsed.problems,[]);
  assert.equal(parsed.pages[0].text[0],'Total (RM) \\ path (nested (brackets))');
  assert.equal(parsed.pages[0].text[1],'Price - "quoted" cafe ? ?? Tabbed','dashes and quotes are mapped, accents stripped, unsupported characters become ?');
  assert.ok(/^[\x00-\x7F]*$/.test(parsed.pages[0].content.replace(/[âãÏÓ]/g,'')),'the content stream is plain ASCII');
});
test('unsupported characters never break the file',()=>{
  assert.equal(toPdfText('a\u0000b\u0007c\u007Fd\te'),'abcd e');
  assert.equal(toPdfText('Ångström naïve'),'Angstrom naive');assert.match(toPdfText('😀 ok'),/^\?+ ok$/,'an emoji becomes question marks');
  assert.equal(toPdfText(null),'');assert.equal(toPdfText(undefined),'');assert.equal(toPdfText(42),'42');
  assert.deepEqual(parsePdf(built(pdf=>pdf.text(10,10,'\u0000\u0001😀 ​ end'))).problems,[]);
});
test('text widths match the real Helvetica metrics',()=>{
  const close=(a,b)=>assert.ok(Math.abs(a-b)<0.01,`${a} vs ${b}`);
  close(measure('Hello World',10),51.67);close(measure('Hello World',10,true),55.56);close(measure('RM 1,234.56',10),57.25);
  close(measure('Toyota Fully Synthetic 0W-20 Engine Oil 4L',10),193.41);close(measure('WWWWWWWW iiiiiiii',10,true),100.54);
  assert.equal(measure('',12),0);close(measure('abc',20),measure('abc',10)*2);
});
test('wrapping respects the width, keeps blank lines and splits very long words',()=>{
  const lines=wrap('The quick brown fox jumps over the lazy dog and keeps running far away',120,10);
  assert.ok(lines.length>=3);for(const l of lines)assert.ok(measure(l,10)<=120.01,l);
  assert.equal(lines.join(' '),'The quick brown fox jumps over the lazy dog and keeps running far away');
  assert.deepEqual(wrap('one\n\ntwo',200,10),['one','','two']);
  const long=wrap('A'.repeat(80),100,10);assert.ok(long.length>1);for(const l of long)assert.ok(measure(l,10)<=100.01);assert.equal(long.join(''),'A'.repeat(80));
  assert.deepEqual(wrap('',100,10),['']);assert.deepEqual(wrap('   ',100,10),['']);
});
test('right and centre alignment place the text where it should end',()=>{
  const parsed=parsePdf(built(pdf=>{pdf.text(500,100,'RM 99.00',{size:10,align:'right'});pdf.text(300,120,'Centre',{size:10,align:'center'});pdf.text(60,140,'Left',{size:10});}));
  const [right,centre,left]=parsed.pages[0].runs;
  assert.ok(Math.abs(right.x+measure('RM 99.00',10)-500)<0.02);assert.ok(Math.abs(centre.x+measure('Centre',10)/2-300)<0.02);assert.equal(left.x,60);
  assert.equal(right.y,parsed.pages[0].height-100,'y is measured from the top of the page');
});
test('the same drawing always produces the same bytes',()=>{
  const draw=pdf=>{pdf.text(50,60,'Stable');pdf.rect(10,10,50,50,{fill:[1,2,3]});};
  assert.deepEqual(built(draw),built(draw));
});
