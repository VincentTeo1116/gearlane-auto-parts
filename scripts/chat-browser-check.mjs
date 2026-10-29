import assert from 'node:assert/strict';
import {chromium} from 'playwright';
import {createServer} from 'vite';
import {mkdir} from 'node:fs/promises';

const server=await createServer({mode:'demo',server:{host:'127.0.0.1',port:5190,strictPort:true}});
await server.listen();let browser;const errors=[];
try{
  browser=await chromium.launch({headless:true});
  const context=await browser.newContext({viewport:{width:1280,height:1000}});
  // Suppress preview push notifications to prove polling works independently.
  await context.addInitScript(()=>{const original=window.addEventListener.bind(window);window.addEventListener=(name,...args)=>{if(!['storage','gearlane-preview-change'].includes(name))return original(name,...args);};});
  const base='http://127.0.0.1:5190';
  const pageFor=async role=>{
    const page=await context.newPage();page.setDefaultTimeout(12000);page.setDefaultNavigationTimeout(15000);page.on('pageerror',e=>errors.push(e.message));
    await page.goto(base+'/account');await page.getByLabel('Email address',{exact:true}).fill(role+'@gearlane.demo');await page.getByLabel('Password',{exact:true}).fill('Demo'+role[0].toUpperCase()+role.slice(1)+'123!');await page.locator('form').filter({has:page.getByLabel('Password',{exact:true})}).getByRole('button',{name:'Sign in',exact:true}).click();await page.waitForURL(role==='customer'?'**/shop':'**/workspace');
    await page.goto(base+(role==='customer'?'/messages':'/workspace/messages'));await page.getByLabel('Message',{exact:true}).waitFor();return page;
  };
  const customer=await pageFor('customer'),worker=await pageFor('worker');
  await customer.evaluate(async()=>{const {repository}=await import('/src/repository.mjs');window.__realSend=repository.sendMessage.bind(repository);window.__realMessages=repository.messages.bind(repository);window.__sendCount=0;repository.sendMessage=async value=>{window.__sendCount++;await new Promise(resolve=>setTimeout(resolve,1000));return window.__realSend(value);};});
  assert.equal(await customer.getByRole('button',{name:'Send',exact:true}).isDisabled(),true);
  await customer.getByLabel('Message',{exact:true}).fill('   \n\t');assert.equal(await customer.getByRole('button',{name:'Send',exact:true}).isDisabled(),true);
  await customer.getByRole('button',{name:'Chat options',exact:true}).click();
  await customer.locator('.chat-privacy summary').click();
  assert.match(await customer.locator('.chat-privacy').innerText(),/passwords.*OTP\/TAC.*card numbers.*CVV/);
  await customer.getByRole('button',{name:'Chat options',exact:true}).click();
  await customer.getByLabel('Message',{exact:true}).fill('Customer message delivered by five-second polling.');
  await customer.getByRole('button',{name:'Send',exact:true}).click();
  assert.equal(await customer.getByRole('button',{name:'Sending…',exact:true}).isDisabled(),true);
  await customer.locator('.message-composer').evaluate(form=>{form.requestSubmit();form.requestSubmit();});
  assert.equal(await customer.locator('.pending-message').count(),1);
  await worker.getByText('Customer message delivered by five-second polling.',{exact:true}).waitFor();
  assert.equal(await customer.evaluate(()=>window.__sendCount),1,'Repeated submit cannot send twice');
  await customer.getByRole('button',{name:'Send',exact:true}).waitFor();
  await worker.getByLabel('Message',{exact:true}).fill('Worker reply, line one.');await worker.getByLabel('Message',{exact:true}).press('Shift+Enter');await worker.getByLabel('Message',{exact:true}).pressSequentially('Line two.');await worker.getByLabel('Message',{exact:true}).press('Enter');
  await customer.getByText('Worker reply, line one.\nLine two.',{exact:true}).waitFor();
  console.log('Two-way polling, multiline input and pending-send locking passed.');

  await customer.evaluate(async()=>{const {repository}=await import('/src/repository.mjs');repository.messages=async()=>{throw new Error('Network temporarily unavailable');};repository.sendMessage=async value=>{await window.__realSend(value);throw new Error('Network response lost after commit');};});
  await customer.getByLabel('Message',{exact:true}).fill('Retry this message without a duplicate.');await customer.getByRole('button',{name:'Send',exact:true}).click();
  await customer.getByRole('button',{name:'Retry message',exact:true}).waitFor();assert.equal(await customer.getByRole('button',{name:'Send',exact:true}).isDisabled(),true);
  assert.equal(await customer.getByLabel('Message',{exact:true}).inputValue(),'Retry this message without a duplicate.');
  await customer.evaluate(async()=>{const {repository}=await import('/src/repository.mjs');repository.messages=window.__realMessages;repository.sendMessage=window.__realSend;});
  await customer.getByRole('button',{name:'Retry message',exact:true}).click();await customer.locator('.pending-message').waitFor({state:'hidden'});
  assert.equal(await customer.evaluate(()=>JSON.parse(localStorage.getItem('gearlane_preview_v1')).messages.filter(m=>m.body==='Retry this message without a duplicate.').length),1);
  assert.equal(await customer.locator('.message').filter({hasText:'Retry this message without a duplicate.'}).count(),1);
  console.log('Ambiguous network failure and duplicate-safe retry passed.');

  await context.setOffline(true);await customer.getByLabel('Message',{exact:true}).fill('Offline draft stays here.');
  await customer.getByText('Offline · draft kept on this page',{exact:true}).waitFor();assert.equal(await customer.getByRole('button',{name:'Send',exact:true}).isDisabled(),true);
  await context.setOffline(false);await customer.waitForFunction(()=>navigator.onLine);assert.equal(await customer.getByLabel('Message',{exact:true}).inputValue(),'Offline draft stays here.');
  await customer.getByLabel('Message',{exact:true}).fill('');

  await customer.evaluate(()=>{const state=JSON.parse(localStorage.getItem('gearlane_preview_v1')),conversation=state.conversations.find(c=>c.kind==='support'&&!c.closed_at);for(let i=0;i<120;i++)state.messages.push({id:crypto.randomUUID(),conversation_id:conversation.id,sender_id:conversation.customer_id,sender_name:'Test buyer',body:'History item '+String(i).padStart(3,'0'),product_id:null,created_at:new Date(Date.now()-(140-i)*60000).toISOString()});localStorage.setItem('gearlane_preview_v1',JSON.stringify(state));});
  await customer.reload();await customer.getByRole('button',{name:'Load older messages',exact:true}).click();await customer.getByText('History item 000',{exact:true}).waitFor({state:'attached'});
  const loaded=await customer.locator('.message').count();assert.ok(loaded>100);
  await customer.locator('.message-list').evaluate(el=>{el.scrollTop=0;el.dispatchEvent(new Event('scroll'));});
  await worker.getByLabel('Message',{exact:true}).fill('A new message while you read older history.');await worker.getByRole('button',{name:'Send',exact:true}).click();
  await customer.getByText('A new message while you read older history.',{exact:true}).waitFor({state:'attached'});
  assert.equal(await customer.getByText('History item 000',{exact:true}).count(),1);assert.ok(await customer.locator('.message').count()>=loaded+1);
  assert.ok(await customer.locator('.message-list').evaluate(el=>el.scrollTop)<100,'Incoming messages do not jump away from old history');await customer.getByRole('button',{name:'New messages',exact:true}).click();
  console.log('Loaded history and reading position survive background sync.');

  const admin=await pageFor('admin');await worker.getByRole('button',{name:'New staff chat',exact:true}).click();await worker.getByLabel('Staff member',{exact:true}).selectOption({label:'GearLane Admin (admin)'});await worker.getByRole('button',{name:'Open conversation',exact:true}).click();await worker.getByRole('dialog').waitFor({state:'hidden'});
  await worker.getByLabel('Message',{exact:true}).fill('Private staff chat message.');await worker.getByRole('button',{name:'Send',exact:true}).click();
  await admin.locator('.conversation-list button').filter({hasText:'Team chat'}).first().waitFor();await admin.locator('.conversation-list button').filter({hasText:'Team chat'}).first().click();await admin.getByText('Private staff chat message.',{exact:true}).waitFor();
  assert.equal(await customer.locator('.conversation-list button').filter({hasText:'Team chat'}).count(),0);
  await admin.setViewportSize({width:390,height:844});assert.ok(await admin.evaluate(()=>document.documentElement.scrollWidth<=innerWidth+1));
  await mkdir('.generated/chat',{recursive:true});await admin.screenshot({path:'.generated/chat/staff-mobile.png',fullPage:true});await customer.screenshot({path:'.generated/chat/customer-desktop.png',fullPage:true});

  await worker.locator('.conversation-list button').filter({hasText:'Customer support'}).first().click();await worker.getByRole('button',{name:'Close',exact:true}).click();await customer.getByText('This conversation is closed. Start another support enquiry if you need more help.',{exact:true}).waitFor();assert.equal(await customer.getByLabel('Message',{exact:true}).count(),0);
  await customer.evaluate(async()=>{const {repository}=await import('/src/repository.mjs');window.__reads=0;const real=repository.messages.bind(repository);repository.messages=(...args)=>{window.__reads++;return real(...args);};});
  await customer.getByRole('navigation',{name:'Store navigation'}).getByRole('link',{name:'Shop parts',exact:true}).click();await customer.waitForURL('**/shop');await customer.locator('.seller-chat-window').getByRole('button',{name:'Minimise chat',exact:true}).click();const before=await customer.evaluate(()=>window.__reads);await new Promise(resolve=>setTimeout(resolve,5500));assert.equal(await customer.evaluate(()=>window.__reads),before,'Polling pauses after minimising the chat');
  assert.deepEqual(errors,[]);console.log('Chat checks passed: five-second polling without push events, pending lock, retries, offline drafts, history/scroll, private staff chat, closed state, mobile layout and cleanup.');
}finally{await browser?.close();await server.close();}
