-- OPTIONAL: remove only the fictional scenario created by seed-analytics.sql.
-- Run as project owner. Stops if seeded products changed after installation,
-- so later stock receipts, orders or edits cannot be silently overwritten.
begin;
do $cleanup$
declare entry public.audit_events%rowtype;info jsonb;admin_id uuid;
begin
 perform pg_advisory_xact_lock(hashtext('gearlane-analytics-demo-v1'));
 select * into entry from public.audit_events where action='sample_scenario_seeded_v1' and target='gearlane-analytics-demo-v1' order by id desc limit 1 for update;
 if not found then raise notice 'No installed sample scenario was found. Nothing was removed.';return;end if;
 info:=entry.details;admin_id:=entry.actor_id;
 perform p.id from public.products p join jsonb_array_elements(info->'products_after') expected on p.id=expected->>'id' order by p.id for update of p;
 if exists(select 1 from jsonb_array_elements(info->'products_after') expected left join public.products p on p.id=expected->>'id'
  where p.id is null or p.stock<>(expected->>'stock')::integer or p.version<>(expected->>'version')::integer or p.price_confirmed<>(expected->>'price_confirmed')::boolean) then
  raise exception 'Sample products changed after seeding. Cleanup stopped; no data was removed. Reconcile subsequent stock/order edits before removing the scenario.';
 end if;
 if exists(select 1 from public.orders o where o.customer_id in(select value::uuid from jsonb_array_elements_text(info->'customer_ids')) and o.id not in(select value::uuid from jsonb_array_elements_text(info->'order_ids'))) then
  raise exception 'A sample customer has additional orders. Cleanup stopped to preserve them.';
 end if;
 delete from public.reviews where order_id in(select value::uuid from jsonb_array_elements_text(info->'order_ids'));
 delete from public.refunds where order_id in(select value::uuid from jsonb_array_elements_text(info->'order_ids'));
 delete from public.order_events where order_id in(select value::uuid from jsonb_array_elements_text(info->'order_ids'));
 delete from public.order_items where order_id in(select value::uuid from jsonb_array_elements_text(info->'order_ids'));
 delete from public.orders where id in(select value::uuid from jsonb_array_elements_text(info->'order_ids'));
 delete from public.activity_events where id in(select value::bigint from jsonb_array_elements_text(info->'activity_ids'));
 delete from public.wishlist where user_id in(select value::uuid from jsonb_array_elements_text(info->'customer_ids'));
 -- Foreign keys stop the transaction if later records still reference these users.
 delete from auth.users where id in(select value::uuid from jsonb_array_elements_text(info->'customer_ids'));
 update public.products p set stock=(before->>'stock')::integer,price_confirmed=(before->>'price_confirmed')::boolean,version=p.version+1
 from jsonb_array_elements(info->'products_before') before where p.id=before->>'id';
 delete from public.announcements where id=(info->>'announcement_id')::uuid;
 delete from public.audit_events where id=entry.id;
 insert into public.audit_events(actor_id,action,target,details) values(admin_id,'sample_scenario_removed_v1','gearlane-analytics-demo-v1',jsonb_build_object('removed_at',now()));
 raise notice 'Fictional orders and placeholder customers removed. Earlier stock and price-confirmation values restored.';
end $cleanup$;
commit;
