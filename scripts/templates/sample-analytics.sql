-- TEST PROJECT ONLY: fictional orders, placeholder customers and sample stock.
-- Run in Supabase SQL Editor as project owner, after the existing setup.
-- Do not rerun setup.sql. This example is intentionally excluded from setup.sql.
-- Existing orders, customer accounts, selling prices and store settings are preserved.
-- Adds remaining sample units to existing stock; confirms seeded products' test prices.
-- Rerunning this file is a no-op. Cleanup: supabase/examples/remove-analytics.sql.
begin;
do $seed$
declare
 data jsonb := $sample_payload$__SAMPLE_PAYLOAD__$sample_payload$::jsonb;
 marker constant text := 'gearlane-analytics-demo-v1';
 notice_id constant uuid := '31000000-0000-4000-8000-000000000001';
 shift interval;admin_id uuid;worker_id uuid;backup jsonb;expected jsonb;activity_ids jsonb;
begin
 perform pg_advisory_xact_lock(hashtext(marker));
 if exists(select 1 from public.audit_events where action='sample_scenario_seeded_v1' and target=marker) then
  raise notice 'This sample scenario is already installed. No rows or stock were changed.';return;
 end if;
 select id into admin_id from public.profiles where role='admin' and is_active order by created_at,id limit 1;
 if admin_id is null then raise exception 'Create and activate the first administrator before adding examples.';end if;
 select id into worker_id from public.profiles where role='worker' and is_active order by created_at,id limit 1;
 worker_id:=coalesce(worker_id,admin_id);
 shift:=now()-(data->'sample_summary'->>'generated_at')::timestamptz;
 if exists(select 1 from jsonb_array_elements(data->'users') u join auth.users a on a.id=(u->>'id')::uuid or lower(a.email)=lower(u->>'email')) then
  raise exception 'A sample customer ID or email is already in use. No data was changed.';
 end if;
 if exists(select 1 from jsonb_array_elements(data->'sample_inventory') i left join public.products p on p.id=i->>'product_id' where p.id is null) then
  raise exception 'Some catalogue products are missing. Apply 005-catalogue.sql before this example.';
 end if;
 perform p.id from public.products p join jsonb_array_elements(data->'sample_inventory') i on p.id=i->>'product_id' order by p.id for update of p;
 select jsonb_agg(jsonb_build_object('id',p.id,'stock',p.stock,'price_confirmed',p.price_confirmed,'version',p.version)) into backup
 from public.products p join jsonb_array_elements(data->'sample_inventory') i on p.id=i->>'product_id';

 -- Non-login Auth placeholders, matching Supabase's documented seed pattern.
 -- No password, identity, invitation, session or email is created.
 insert into auth.users(id,email,raw_user_meta_data)
 select (u->>'id')::uuid,u->>'email',jsonb_build_object('full_name',u->>'full_name','phone',u->>'phone','business_type',u->>'business_type') from jsonb_array_elements(data->'users') u;
 update public.profiles p set created_at=(u->>'created_at')::timestamptz+shift
 from jsonb_array_elements(data->'users') u where p.id=(u->>'id')::uuid;

 -- Remaining units = fictional opening receipts - sold/reserved units + returns.
 update public.products p set stock=p.stock+(i->>'closing_units')::integer,
 price_confirmed=case when p.stock+(i->>'closing_units')::integer>0 then true else p.price_confirmed end,version=p.version+1
 from jsonb_array_elements(data->'sample_inventory') i where p.id=i->>'product_id';
 select jsonb_agg(jsonb_build_object('id',p.id,'stock',p.stock,'price_confirmed',p.price_confirmed,'version',p.version)) into expected
 from public.products p join jsonb_array_elements(data->'sample_inventory') i on p.id=i->>'product_id';

 -- Use current database selling prices, product labels and delivery configuration.
 with totals as (
  select (o->>'id')::uuid id,sum((item->>'quantity')::integer*p.price_cents)::bigint subtotal
  from jsonb_array_elements(data->'orders') o cross join lateral jsonb_array_elements(o->'items') item
  join public.products p on p.id=item->>'product_id' group by o->>'id'
 )
 insert into public.orders(id,customer_id,status,payment_status,address,subtotal_cents,discount_cents,shipping_cents,total_cents,payment_reference,payment_note,paid_verified_by,tracking_number,carrier,received_at,cancel_reason,idempotency_key,created_at,expires_at,updated_at,payment_instructions)
 select (o->>'id')::uuid,(o->>'customer_id')::uuid,o->>'status',o->>'payment_status',o->'address',t.subtotal,0,
 case when s.free_shipping_cents>0 and t.subtotal>=s.free_shipping_cents then 0 else s.shipping_cents end,
 t.subtotal+case when s.free_shipping_cents>0 and t.subtotal>=s.free_shipping_cents then 0 else s.shipping_cents end,
 o->>'payment_reference','FICTIONAL TEST ORDER — no bank transfer occurred.',case when o->>'payment_status' in('verified','refunded') then worker_id else null end,
 o->>'tracking_number',o->>'carrier',(o->>'received_at')::timestamptz+shift,o->>'cancel_reason',(o->>'idempotency_key')::uuid,
 (o->>'created_at')::timestamptz+shift,(o->>'expires_at')::timestamptz+shift,(o->>'updated_at')::timestamptz+shift,
 jsonb_build_object('bank_name','DEMO — DO NOT TRANSFER','bank_account_name','FICTIONAL EXAMPLE ONLY','bank_account_number','0000000000')
 from jsonb_array_elements(data->'orders') o join totals t on t.id=(o->>'id')::uuid cross join public.store_settings s where s.id=1;

 insert into public.order_items(id,order_id,product_id,name,sku,category,quantity,price_cents,line_total_cents)
 select (i->>'id')::uuid,(o->>'id')::uuid,p.id,p.name,p.sku,p.category,(i->>'quantity')::integer,p.price_cents,(i->>'quantity')::integer*p.price_cents
 from jsonb_array_elements(data->'orders') o cross join lateral jsonb_array_elements(o->'items') i join public.products p on p.id=i->>'product_id';
 insert into public.order_events(id,order_id,actor_id,event,note,created_at)
 select (e->>'id')::uuid,(o->>'id')::uuid,case e->>'actor_id' when 'seed-admin' then admin_id when 'seed-worker' then worker_id else (e->>'actor_id')::uuid end,
 e->>'event',e->>'note',(e->>'created_at')::timestamptz+shift
 from jsonb_array_elements(data->'orders') o cross join lateral jsonb_array_elements(o->'events') e;
 insert into public.refunds(id,order_id,customer_id,reason,status,amount_cents,staff_note,transfer_reference,return_received,stock_restored,created_at,updated_at)
 select (r->>'id')::uuid,o.id,(r->>'customer_id')::uuid,r->>'reason',r->>'status',o.total_cents,r->>'staff_note',r->>'transfer_reference',(r->>'return_received')::boolean,(r->>'stock_restored')::boolean,(r->>'created_at')::timestamptz+shift,(r->>'updated_at')::timestamptz+shift
 from jsonb_array_elements(data->'refunds') r join public.orders o on o.id=(r->>'order_id')::uuid;
 insert into public.reviews(id,order_id,product_id,customer_id,display_name,rating,body,reply,reply_by,published,created_at)
 select (r->>'id')::uuid,(r->>'order_id')::uuid,r->>'product_id',(r->>'customer_id')::uuid,r->>'display_name',(r->>'rating')::integer,r->>'body',r->>'reply',case when r->>'reply_by' is not null then worker_id else null end,true,(r->>'created_at')::timestamptz+shift from jsonb_array_elements(data->'reviews') r;
 insert into public.wishlist(user_id,product_id,created_at)
 select (w->>'user_id')::uuid,w->>'product_id',(w->>'created_at')::timestamptz+shift from jsonb_array_elements(data->'wishlist') w;
 with added as (
  insert into public.activity_events(user_id,event,product_id,session_id,created_at)
  select (a->>'user_id')::uuid,a->>'event',a->>'product_id',(a->>'session_id')::uuid,(a->>'created_at')::timestamptz+shift from jsonb_array_elements(data->'activity') a returning id
 ) select jsonb_agg(id) into activity_ids from added;
 insert into public.announcements(id,title,body,active)
 values(notice_id,'Testing data enabled','This test store includes fictional customer orders, sales, reviews and stock quantities. No sample payment or shipment is real.',true);
 insert into public.audit_events(actor_id,action,target,details)
 values(admin_id,'sample_scenario_seeded_v1',marker,jsonb_build_object('summary',data->'sample_summary','products_before',backup,'products_after',expected,
 'order_ids',(select jsonb_agg(o->>'id') from jsonb_array_elements(data->'orders') o),
 'customer_ids',(select jsonb_agg(u->>'id') from jsonb_array_elements(data->'users') u),
 'activity_ids',activity_ids,'announcement_id',notice_id));
 raise notice 'Added 84 fictional orders, 12 non-login customers and sample inventory. Existing prices and settings were preserved.';
end $seed$;
commit;
select 'Sample analytics installed (or already present)' result,
 (select count(*) from public.profiles where email like 'sample-buyer-%@example.invalid') sample_customers,
 (select count(*) from public.orders o join public.profiles p on p.id=o.customer_id where p.email like 'sample-buyer-%@example.invalid') sample_orders;
