begin;
alter table public.messages add column if not exists product_name text;
create or replace function public.staff_directory() returns table(id uuid,full_name text,role text) language plpgsql security definer set search_path=public,pg_temp as $$
begin perform public.require_role(array['worker','admin']);return query select p.id,p.full_name,p.role from public.profiles p where p.is_active and p.role in ('worker','admin') order by p.full_name;end $$;
create or replace function public.start_conversation(p_kind text,p_recipient_id uuid default null) returns uuid language plpgsql security definer set search_path=public,pg_temp as $$
declare cid uuid;
begin
 perform public.require_role(array['customer','worker','admin']);
 if p_kind='support' then
   perform public.require_role(array['customer']);perform pg_advisory_xact_lock(hashtext(auth.uid()::text||'support'));
   select id into cid from public.conversations where kind='support' and customer_id=auth.uid() and closed_at is null;
   if cid is not null then return cid;end if;
   insert into public.conversations(kind,customer_id,title,created_by) values('support',auth.uid(),'Customer support',auth.uid()) returning id into cid;
   insert into public.conversation_members(conversation_id,user_id) values(cid,auth.uid());
 elsif p_kind='internal' then
   perform public.require_role(array['worker','admin']);
   if p_recipient_id is null or p_recipient_id=auth.uid() or not exists(select 1 from public.profiles where id=p_recipient_id and is_active and role in ('worker','admin')) then raise exception 'Choose another active staff member.';end if;
   insert into public.conversations(kind,title,created_by) values('internal','Staff conversation',auth.uid()) returning id into cid;
   insert into public.conversation_members(conversation_id,user_id) values(cid,auth.uid()),(cid,p_recipient_id);
 else raise exception 'Unknown conversation type.';end if;
 return cid;
end $$;
create or replace function public.send_message(p_conversation_id uuid,p_body text,p_product_id text default null) returns uuid language plpgsql security definer set search_path=public,pg_temp as $$
declare cid public.conversations%rowtype;mid uuid;sender text;product_name_text text;recipient record;
begin
 perform public.require_role(array['customer','worker','admin']);
 if not public.can_access_conversation(p_conversation_id) then raise exception 'Conversation unavailable.' using errcode='42501';end if;
 select * into cid from public.conversations where id=p_conversation_id for update;
 if cid.closed_at is not null then raise exception 'This conversation is closed. Start a new support conversation.';end if;
 if coalesce(char_length(trim(p_body)),0) not between 1 and 2000 then raise exception 'Messages must contain 1 to 2000 characters.';end if;
 if (select count(*) from public.messages where sender_id=auth.uid() and created_at>now()-interval '1 minute')>=30 then raise exception 'Message limit reached. Wait a minute before trying again.';end if;
 if p_product_id is not null then
   if cid.kind<>'support' then raise exception 'Product attachments are available in customer-support conversations.';end if;
   select name into product_name_text from public.products where id=p_product_id and active;
   if not found then raise exception 'The attached product is unavailable.';end if;
 end if;
 select full_name into sender from public.profiles where id=auth.uid();
 insert into public.messages(conversation_id,sender_id,sender_name,body,product_id,product_name) values(cid.id,auth.uid(),sender,trim(p_body),p_product_id,product_name_text) returning id into mid;
 if cid.kind='support' and public.app_role()='customer' then
   if cid.assigned_to is not null then perform public.notify_user(cid.assigned_to,'Customer message','A customer has sent a support message.','/workspace/messages');
   else perform public.notify_staff('Customer support message','A customer is waiting for a response.','/workspace/messages');end if;
 elsif cid.kind='support' then perform public.notify_user(cid.customer_id,'Support replied','The store has replied to your enquiry.','/messages');
 else for recipient in select user_id from public.conversation_members where conversation_id=cid.id and user_id<>auth.uid() loop perform public.notify_user(recipient.user_id,'Staff message',sender||' sent you a message.','/workspace/messages');end loop;end if;
 return mid;
end $$;
create or replace function public.manage_conversation(p_conversation_id uuid,p_action text) returns void language plpgsql security definer set search_path=public,pg_temp as $$
begin
 perform public.require_role(array['customer','worker','admin']);
 if not public.can_access_conversation(p_conversation_id) then raise exception 'Conversation unavailable.';end if;
 if p_action='read' then insert into public.conversation_members(conversation_id,user_id,last_read_at) values(p_conversation_id,auth.uid(),now()) on conflict(conversation_id,user_id) do update set last_read_at=now();
 elsif p_action='assign' then perform public.require_role(array['worker','admin']);update public.conversations set assigned_to=auth.uid() where id=p_conversation_id and kind='support';
 elsif p_action='close' then perform public.require_role(array['worker','admin']);update public.conversations set closed_at=now() where id=p_conversation_id;
 else raise exception 'Unknown conversation action.';end if;
end $$;
create or replace function public.read_notifications() returns void language plpgsql security definer set search_path=public,pg_temp as $$begin perform public.require_role(array['customer','worker','admin']);update public.notifications set read_at=now() where user_id=auth.uid() and read_at is null;end $$;
create or replace function public.request_restock(p_product_id text,p_quantity integer,p_reason text) returns uuid language plpgsql security definer set search_path=public,pg_temp as $$
declare rid uuid;
begin
 perform public.require_role(array['worker','admin']);
 if not exists(select 1 from public.products where id=p_product_id) or p_quantity is null or p_quantity not between 1 and 1000000 or coalesce(char_length(trim(p_reason)),0) not between 5 and 1000 then raise exception 'Choose a product, valid quantity and reason.';end if;
 insert into public.restock_requests(product_id,requester_id,quantity,reason) values(p_product_id,auth.uid(),p_quantity,trim(p_reason)) returning id into rid;
 perform public.notify_staff('Restock requested','Review the stock request before purchasing or adding received stock.','/workspace/restock',true);return rid;
end $$;
create or replace function public.resolve_restock(p_request_id uuid,p_units_received integer,p_note text) returns void language plpgsql security definer set search_path=public,pg_temp as $$
declare r public.restock_requests%rowtype;
begin
 perform public.require_role(array['admin']);select * into r from public.restock_requests where id=p_request_id for update;
 if not found or r.status='resolved' then raise exception 'Request is already resolved or unavailable.';end if;
 if p_units_received is null or p_units_received not between 1 and 1000000 or coalesce(char_length(trim(p_note)),0) not between 5 and 1000 then raise exception 'Record physically received units and a clear note.';end if;
 update public.products set stock=stock+p_units_received,version=version+1,updated_at=now() where id=r.product_id;
 update public.restock_requests set status='resolved',admin_note=trim(p_note),resolved_at=now() where id=r.id;
 perform public.audit('restock_received',r.id::text,jsonb_build_object('units',p_units_received));perform public.notify_user(r.requester_id,'Restock received',trim(p_note),'/workspace/restock');
end $$;
create or replace function public.admin_save_product(p_product jsonb,p_expected_version integer default null) returns text language plpgsql security definer set search_path=public,pg_temp as $$
declare pid text;existing public.products%rowtype;
begin
 perform public.require_role(array['admin']);
 if jsonb_typeof(p_product)<>'object' then raise exception 'Invalid product data.';end if;
 pid:=p_product->>'id';
 if pid is null or pid !~ '^[a-zA-Z0-9_-]{1,100}$' then raise exception 'Use a valid product identifier.';end if;
 select * into existing from public.products where id=pid for update;
 if found and(p_expected_version is null or existing.version<>p_expected_version) then raise exception 'Another person changed this product. Refresh before saving.';end if;
 if p_product->>'price_cents' !~ '^[1-9][0-9]{0,8}$' or p_product->>'stock' !~ '^[0-9]{1,7}$' then raise exception 'Price and stock must be non-negative whole amounts (price in cents).';end if;
 if coalesce(char_length(p_product->>'fitment_note'),0) not between 5 and 1000 then raise exception 'Provide a fitment note of 5 to 1000 characters.';end if;
 insert into public.products(id,sku,name,brand,category,description,specs,price_cents,stock,image_url,fitment_note,price_confirmed,active)
 values(pid,trim(p_product->>'sku'),trim(p_product->>'name'),trim(p_product->>'brand'),trim(p_product->>'category'),trim(p_product->>'description'),coalesce(p_product->'specs','{}'),(p_product->>'price_cents')::bigint,(p_product->>'stock')::integer,nullif(p_product->>'image_url',''),p_product->>'fitment_note',coalesce((p_product->>'price_confirmed')::boolean,false),coalesce((p_product->>'active')::boolean,true))
 on conflict(id) do update set sku=excluded.sku,name=excluded.name,brand=excluded.brand,category=excluded.category,description=excluded.description,specs=excluded.specs,price_cents=excluded.price_cents,stock=excluded.stock,image_url=excluded.image_url,fitment_note=excluded.fitment_note,price_confirmed=excluded.price_confirmed,active=excluded.active,version=public.products.version+1,updated_at=now();
 perform public.audit('product_saved',pid,jsonb_build_object('price_cents',p_product->>'price_cents','stock',p_product->>'stock'));return pid;
end $$;
create or replace function public.admin_archive_product(p_product_id text) returns void language plpgsql security definer set search_path=public,pg_temp as $$begin perform public.require_role(array['admin']);update public.products set active=false,version=version+1,updated_at=now() where id=p_product_id;perform public.audit('product_archived',p_product_id);end $$;
create or replace function public.admin_save_announcement(p_id uuid,p_title text,p_body text,p_active boolean) returns uuid language plpgsql security definer set search_path=public,pg_temp as $$
declare aid uuid:=coalesce(p_id,gen_random_uuid());
begin perform public.require_role(array['admin']);insert into public.announcements(id,title,body,active) values(aid,trim(p_title),trim(p_body),p_active) on conflict(id) do update set title=excluded.title,body=excluded.body,active=excluded.active;perform public.audit('announcement_saved',aid::text);return aid;end $$;
create or replace function public.admin_delete_announcement(p_id uuid) returns void language plpgsql security definer set search_path=public,pg_temp as $$begin perform public.require_role(array['admin']);delete from public.announcements where id=p_id;perform public.audit('announcement_deleted',p_id::text);end $$;
create or replace function public.admin_save_promotion(p_promotion jsonb) returns uuid language plpgsql security definer set search_path=public,pg_temp as $$
declare pid uuid:=coalesce(nullif(p_promotion->>'id','')::uuid,gen_random_uuid());
begin
 perform public.require_role(array['admin']);
 insert into public.promotions(id,code,kind,value,minimum_cents,maximum_uses,starts_at,ends_at,active)
 values(pid,upper(trim(p_promotion->>'code')),p_promotion->>'kind',(p_promotion->>'value')::bigint,(p_promotion->>'minimum_cents')::bigint,(p_promotion->>'maximum_uses')::integer,(p_promotion->>'starts_at')::timestamptz,(p_promotion->>'ends_at')::timestamptz,(p_promotion->>'active')::boolean)
 on conflict(id) do update set code=excluded.code,kind=excluded.kind,value=excluded.value,minimum_cents=excluded.minimum_cents,maximum_uses=excluded.maximum_uses,starts_at=excluded.starts_at,ends_at=excluded.ends_at,active=excluded.active;
 perform public.audit('promotion_saved',pid::text);return pid;
end $$;
create or replace function public.admin_delete_promotion(p_id uuid) returns void language plpgsql security definer set search_path=public,pg_temp as $$begin perform public.require_role(array['admin']);if exists(select 1 from public.orders where promotion_id=p_id) then update public.promotions set active=false where id=p_id;else delete from public.promotions where id=p_id;end if;perform public.audit('promotion_removed',p_id::text);end $$;
create or replace function public.admin_update_profile(p_user_id uuid,p_name text,p_role text,p_active boolean) returns void language plpgsql security definer set search_path=public,pg_temp as $$
declare target public.profiles%rowtype;
begin
 perform public.require_role(array['admin']);
 -- Serialize admin membership changes so two admins cannot remove the last one.
 perform pg_advisory_xact_lock(748391);
 select * into target from public.profiles where id=p_user_id for update;
 if not found or p_role not in ('customer','worker','admin') or p_active is null or coalesce(char_length(trim(p_name)),0) not between 2 and 100 then raise exception 'Check the user, name, role and active state.';end if;
 if p_user_id=auth.uid() and(p_role<>'admin' or not p_active) then raise exception 'You cannot remove your own administrator access.';end if;
 if target.role='admin' and target.is_active and(p_role<>'admin' or not p_active) and(select count(*) from public.profiles where role='admin' and is_active)<2 then raise exception 'Keep at least one active administrator.';end if;
 update public.profiles set full_name=trim(p_name),role=p_role,is_active=p_active where id=p_user_id;
 perform public.audit('profile_updated',p_user_id::text,jsonb_build_object('role',p_role,'active',p_active));
end $$;
create or replace function public.admin_save_settings(p_settings jsonb) returns void language plpgsql security definer set search_path=public,pg_temp as $$
begin
 perform public.require_role(array['admin']);
 if coalesce(char_length(trim(p_settings->>'store_name')),0) not between 2 and 100 or coalesce(p_settings->>'shipping_cents','') !~ '^[0-9]{1,6}$' or coalesce(p_settings->>'free_shipping_cents','') !~ '^[0-9]{1,9}$' then raise exception 'Check store name and delivery prices.';end if;
 if (p_settings->>'checkout_enabled')::boolean and(coalesce(char_length(trim(p_settings->>'bank_name')),0)<2 or coalesce(char_length(trim(p_settings->>'bank_account_name')),0)<2 or coalesce(p_settings->>'bank_account_number','') !~ '^[0-9 -]{6,30}$') then raise exception 'Enter the actual business bank details before enabling checkout.';end if;
 if char_length(coalesce(p_settings->>'return_policy',''))>4000 or char_length(coalesce(p_settings->>'contact_email',''))>254 then raise exception 'Store details are too long.';end if;
 update public.store_settings set store_name=trim(p_settings->>'store_name'),bank_name=left(trim(p_settings->>'bank_name'),100),bank_account_name=left(trim(p_settings->>'bank_account_name'),120),bank_account_number=left(trim(p_settings->>'bank_account_number'),30),shipping_cents=(p_settings->>'shipping_cents')::integer,free_shipping_cents=(p_settings->>'free_shipping_cents')::integer,checkout_enabled=(p_settings->>'checkout_enabled')::boolean,contact_email=coalesce(p_settings->>'contact_email',''),return_policy=coalesce(p_settings->>'return_policy','') where id=1;
 perform public.audit('store_settings_updated','1');
end $$;
create or replace function public.record_event(p_event text,p_product_id text,p_session_id uuid) returns void language plpgsql security definer set search_path=public,pg_temp as $$
begin
 perform public.require_role(array['customer']);
 if p_event not in ('session_started','view_product','checkout_started','order_placed') or p_session_id is null then raise exception 'Invalid activity event.';end if;
 if(select count(*) from public.activity_events where user_id=auth.uid() and created_at>now()-interval '1 minute')>=30 then return;end if;
 insert into public.activity_events(user_id,event,product_id,session_id) values(auth.uid(),p_event,p_product_id,p_session_id);
end $$;
create or replace function public.dashboard_stats(p_days integer default 30) returns jsonb language plpgsql security definer set search_path=public,pg_temp as $$
declare since_time timestamptz;result jsonb;
begin
 perform public.require_role(array['admin']);if p_days not in(7,30,90) then raise exception 'Choose 7, 30 or 90 days.';end if;since_time:=now()-make_interval(days=>p_days);
 select jsonb_build_object(
 'paid_sales_cents',coalesce((select sum(total_cents) from public.orders where created_at>=since_time and payment_status='verified'),0),
 'paid_orders',(select count(*) from public.orders where created_at>=since_time and payment_status='verified'),
 'orders',(select count(*) from public.orders where created_at>=since_time),
 'customers',(select count(*) from public.profiles where role='customer' and is_active),
 'active_customers',(select count(distinct user_id) from public.activity_events where created_at>=since_time),
 'awaiting_payment',(select count(*) from public.orders where status='awaiting_payment'),
 'low_stock',(select count(*) from public.products where active and stock<10),
 'customer_types',coalesce((select jsonb_agg(x) from(select business_type,count(*) as count from public.profiles where role='customer' and is_active group by business_type)x),'[]'::jsonb),
 'daily_sales',coalesce((select jsonb_agg(x order by x.day) from(select to_char(created_at at time zone 'Asia/Kuala_Lumpur','YYYY-MM-DD') as day,sum(total_cents) as value from public.orders where created_at>=since_time and payment_status='verified' group by 1)x),'[]'::jsonb),
 'active_hours',coalesce((select jsonb_agg(x order by x.hour) from(select extract(hour from created_at at time zone 'Asia/Kuala_Lumpur')::integer as hour,count(*) as count from public.activity_events where created_at>=since_time group by 1)x),'[]'::jsonb),
 'categories',coalesce((select jsonb_agg(x) from(select i.category,sum(i.quantity) as units,sum(i.line_total_cents) as value from public.order_items i join public.orders o on o.id=i.order_id where o.created_at>=since_time and o.payment_status='verified' group by i.category order by value desc)x),'[]'::jsonb),
 'wishlist_categories',coalesce((select jsonb_agg(x) from(select p.category,count(*) as count from public.wishlist w join public.products p on p.id=w.product_id group by p.category order by count desc)x),'[]'::jsonb)
 ) into result;return result;
end $$;

-- Functions are not implicitly public RPC endpoints. Grant only named actions.
do $$declare r record;begin for r in select p.oid::regprocedure as signature from pg_proc p join pg_namespace n on n.oid=p.pronamespace where n.nspname='public' and p.proname in ('update_my_profile','toggle_wishlist','create_order','submit_payment','verify_payment','cancel_order','expire_unpaid_orders','set_order_status','confirm_receipt','request_refund','review_refund','confirm_refund','submit_review','reply_review','moderate_review','staff_directory','start_conversation','send_message','manage_conversation','read_notifications','request_restock','resolve_restock','admin_save_product','admin_archive_product','admin_save_announcement','admin_delete_announcement','admin_save_promotion','admin_delete_promotion','admin_update_profile','admin_save_settings','record_event','dashboard_stats') loop execute format('revoke all on function %s from public,anon',r.signature);execute format('grant execute on function %s to authenticated',r.signature);end loop;end$$;
commit;
