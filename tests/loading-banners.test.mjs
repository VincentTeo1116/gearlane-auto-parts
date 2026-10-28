import test from 'node:test';import assert from 'node:assert/strict';
import {sectionsForRoute,mergeSnapshot} from '../src/data-loading.mjs';
import {bannerSchema,validBannerLink} from '../src/banners.mjs';

test('catalogue requests exclude bulk private records and workspace queries follow the task',()=>{
 assert.deepEqual(sectionsForRoute(null,'/shop'),[]);
 assert.deepEqual(sectionsForRoute('customer','/shop'),['notifications','wishlist']);
 assert.ok(!sectionsForRoute('customer','/messages').includes('orders'));
 assert.ok(sectionsForRoute('customer','/orders/abc').includes('refunds'));
 assert.ok(sectionsForRoute('admin','/workspace/users').includes('users'));
 assert.ok(!sectionsForRoute('worker','/workspace/users').includes('users'));
 assert.ok(sectionsForRoute('admin','/workspace/banners').includes('banners'));
});
test('partial snapshots retain loaded records only for the same account',()=>{
 const before={orders:[{id:'private-order'}],users:[{id:'admin-user'}]};
 assert.equal(mergeSnapshot(before,{products:[]},true).orders[0].id,'private-order');
 assert.deepEqual(mergeSnapshot(before,{products:[]},false).orders,[]);
 assert.deepEqual(mergeSnapshot(before,{products:[]},false).users,[]);
});
test('banner validation permits drafts and requires real image and descriptive text for publishing',()=>{
 const draft={title:'Service promotion',alt_text:'',image_url:null,mobile_image_url:null,link_path:'/shop',position:0,published:false};
 assert.equal(bannerSchema.safeParse(draft).success,true);
 assert.equal(bannerSchema.safeParse({...draft,published:true}).success,false);
 assert.equal(bannerSchema.safeParse({...draft,published:true,image_url:'https://example.com/promo.webp',alt_text:'Engine oil promotion'}).success,true);
 for(const url of ['javascript:alert(1)','data:image/svg+xml,bad','http://insecure.example/img'])assert.equal(bannerSchema.safeParse({...draft,image_url:url}).success,false);
 for(const path of ['https://external.example','//external.example','/\\external.example','/workspace','/shop#fragment','/shop\n'])assert.equal(validBannerLink(path),false);
 for(const path of ['','/','/shop','/shop?category=Engine%20Oil','/products/oil-001','/messages'])assert.equal(validBannerLink(path),true);
});
