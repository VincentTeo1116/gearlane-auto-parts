-- GearLane Auto Parts — run once on a NEW Supabase project.
-- Review before execution. Keep this file with the application version.
-- GearLane schema. Run through Supabase SQL Editor as the project owner.
-- Fresh-project migration; existing business data is never dropped.
begin;
revoke create on schema public from public;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null check (char_length(full_name) between 2 and 100),
  email text not null,
  phone text not null default '',
  business_type text not null default 'personal' check (business_type in ('personal','workshop','retailer','distributor')),
  role text not null default 'customer' check (role in ('customer','worker','admin')),
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);
create or replace function public.handle_new_user() returns trigger language plpgsql security definer set search_path=public,pg_temp as $$
begin
  insert into public.profiles(id,full_name,email,phone,business_type)
  values(new.id,left(coalesce(nullif(trim(new.raw_user_meta_data->>'full_name'),''),'New customer'),100),coalesce(new.email,''),left(coalesce(new.raw_user_meta_data->>'phone',''),20),
    case when new.raw_user_meta_data->>'business_type' in ('personal','workshop','retailer','distributor') then new.raw_user_meta_data->>'business_type' else 'personal' end);
  return new;
end $$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users for each row execute function public.handle_new_user();
create or replace function public.app_role() returns text language sql stable security definer set search_path=public,pg_temp as $$select role from public.profiles where id=auth.uid() and is_active$$;
create or replace function public.require_role(allowed text[]) returns void language plpgsql security definer set search_path=public,pg_temp as $$
begin if public.app_role() is null or not(public.app_role()=any(allowed)) then raise exception 'You do not have permission for this action.' using errcode='42501';end if;end $$;

create table if not exists public.products (
  id text primary key check (id ~ '^[a-zA-Z0-9_-]{1,100}$'),
  sku text unique not null check(char_length(sku) between 2 and 80),
  name text not null check(char_length(name) between 3 and 180),
  brand text not null check(char_length(brand) between 1 and 80),
  category text not null check(char_length(category) between 2 and 80),
  description text not null check(char_length(description) between 10 and 4000),
  specs jsonb not null default '{}' check(jsonb_typeof(specs)='object' and octet_length(specs::text)<=16000),
  price_cents bigint not null check(price_cents between 1 and 100000000),
  price_confirmed boolean not null default false,
  stock integer not null default 0 check(stock between 0 and 1000000),
  image_url text check(image_url is null or image_url ~ '^https://'),
  fitment_note text not null default 'Confirm the vehicle application with the seller.',
  source_url text check(source_url is null or source_url ~ '^https://'),
  price_source_url text check(price_source_url is null or price_source_url ~ '^https://'),
  reference_price_cents bigint,
  source_observed_at date,
  source_note text,
  active boolean not null default true,
  version integer not null default 1,
  updated_at timestamptz not null default now()
);
create table if not exists public.store_settings (
  id integer primary key default 1 check(id=1),
  store_name text not null default 'GearLane Auto Parts',
  bank_name text not null default '',bank_account_name text not null default '',bank_account_number text not null default '',
  shipping_cents integer not null default 0 check(shipping_cents between 0 and 100000),
  free_shipping_cents integer not null default 0 check(free_shipping_cents between 0 and 100000000),
  checkout_enabled boolean not null default false,
  contact_email text not null default '',return_policy text not null default 'Contact the seller to confirm return eligibility before purchasing.'
);
insert into public.store_settings(id) values(1) on conflict do nothing;
create table if not exists public.announcements(id uuid primary key default gen_random_uuid(),title text not null check(char_length(title) between 3 and 160),body text not null check(char_length(body) between 5 and 3000),active boolean not null default true,created_at timestamptz not null default now());
create table if not exists public.promotions (
  id uuid primary key default gen_random_uuid(),code text unique not null check(code ~ '^[A-Z0-9_-]{3,30}$'),kind text not null check(kind in ('percent','fixed')),
  value bigint not null check(value>0),minimum_cents bigint not null default 0 check(minimum_cents>=0),maximum_uses integer not null default 100 check(maximum_uses>0),used_count integer not null default 0 check(used_count>=0),
  starts_at timestamptz not null,ends_at timestamptz not null,active boolean not null default true,
  check(ends_at>starts_at),check(kind<>'percent' or value<=100)
);
create table if not exists public.wishlist(user_id uuid not null references public.profiles(id) on delete cascade,product_id text not null references public.products(id),created_at timestamptz not null default now(),primary key(user_id,product_id));
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),order_number bigint generated by default as identity(start with 10001) unique,
  customer_id uuid not null references public.profiles(id),
  status text not null default 'awaiting_payment' check(status in ('awaiting_payment','processing','shipped','delivered','cancelled')),
  payment_status text not null default 'awaiting' check(payment_status in ('awaiting','submitted','verified','rejected','refunded')),
  address jsonb not null,subtotal_cents bigint not null check(subtotal_cents>0),discount_cents bigint not null default 0 check(discount_cents>=0),shipping_cents bigint not null check(shipping_cents>=0),total_cents bigint not null check(total_cents>=0),
  promotion_id uuid references public.promotions(id),promotion_code text,
  payment_reference text,payment_proof_path text,payment_note text,paid_verified_by uuid references public.profiles(id),
  tracking_number text,carrier text,received_at timestamptz,cancel_reason text,
  idempotency_key uuid not null,created_at timestamptz not null default now(),expires_at timestamptz not null default(now()+interval '24 hours'),updated_at timestamptz not null default now(),
  unique(customer_id,idempotency_key),check(total_cents=subtotal_cents-discount_cents+shipping_cents),check(discount_cents<=subtotal_cents)
);
alter table public.orders add column if not exists payment_instructions jsonb;
create table if not exists public.order_items(id uuid primary key default gen_random_uuid(),order_id uuid not null references public.orders(id),product_id text not null references public.products(id),name text not null,sku text not null,category text not null,quantity integer not null check(quantity between 1 and 9999),price_cents bigint not null check(price_cents>0),line_total_cents bigint not null,unique(order_id,product_id),check(line_total_cents=quantity*price_cents));
create table if not exists public.order_events(id uuid primary key default gen_random_uuid(),order_id uuid not null references public.orders(id),actor_id uuid references public.profiles(id),event text not null,note text not null default '',created_at timestamptz not null default now());
create table if not exists public.promotion_redemptions(promotion_id uuid not null references public.promotions(id),customer_id uuid not null references public.profiles(id),order_id uuid not null references public.orders(id),primary key(promotion_id,customer_id),unique(order_id));
create table if not exists public.refunds(id uuid primary key default gen_random_uuid(),order_id uuid unique not null references public.orders(id),customer_id uuid not null references public.profiles(id),reason text not null check(char_length(reason) between 10 and 2000),status text not null default 'requested' check(status in ('requested','approved','rejected','paid')),amount_cents bigint not null check(amount_cents>=0),staff_note text,transfer_reference text,return_received boolean not null default false,stock_restored boolean not null default false,created_at timestamptz not null default now(),updated_at timestamptz not null default now());
create table if not exists public.reviews(id uuid primary key default gen_random_uuid(),order_id uuid not null references public.orders(id),product_id text not null references public.products(id),customer_id uuid not null references public.profiles(id),display_name text not null,rating integer not null check(rating between 1 and 5),body text not null check(char_length(body) between 10 and 2000),reply text check(reply is null or char_length(reply)<=2000),reply_by uuid references public.profiles(id),published boolean not null default true,created_at timestamptz not null default now(),unique(order_id,product_id));
create table if not exists public.conversations(id uuid primary key default gen_random_uuid(),kind text not null check(kind in ('support','internal')),customer_id uuid references public.profiles(id),title text not null check(char_length(title) between 1 and 180),assigned_to uuid references public.profiles(id),created_by uuid not null references public.profiles(id),closed_at timestamptz,created_at timestamptz not null default now());
create unique index if not exists one_open_support_per_customer on public.conversations(customer_id) where kind='support' and closed_at is null;
create table if not exists public.conversation_members(conversation_id uuid not null references public.conversations(id) on delete cascade,user_id uuid not null references public.profiles(id),last_read_at timestamptz not null default '1970-01-01',primary key(conversation_id,user_id));
create table if not exists public.messages(id uuid primary key default gen_random_uuid(),conversation_id uuid not null references public.conversations(id),sender_id uuid not null references public.profiles(id),sender_name text not null,body text not null check(char_length(body) between 1 and 2000),product_id text references public.products(id),created_at timestamptz not null default now());
create table if not exists public.notifications(id uuid primary key default gen_random_uuid(),user_id uuid not null references public.profiles(id) on delete cascade,title text not null,body text not null,route text not null default '/orders',read_at timestamptz,created_at timestamptz not null default now());
create table if not exists public.restock_requests(id uuid primary key default gen_random_uuid(),product_id text not null references public.products(id),requester_id uuid not null references public.profiles(id),quantity integer not null check(quantity between 1 and 1000000),reason text not null check(char_length(reason) between 5 and 1000),status text not null default 'open' check(status in ('open','acknowledged','resolved')),admin_note text,created_at timestamptz not null default now(),resolved_at timestamptz);
create unique index if not exists one_open_restock on public.restock_requests(product_id,requester_id) where status<>'resolved';
create table if not exists public.activity_events(id bigint generated by default as identity primary key,user_id uuid not null references public.profiles(id),event text not null check(event in ('session_started','view_product','checkout_started','order_placed')),product_id text references public.products(id),session_id uuid not null,created_at timestamptz not null default now());
create table if not exists public.audit_events(id bigint generated by default as identity primary key,actor_id uuid references public.profiles(id),action text not null,target text not null,details jsonb not null default '{}',created_at timestamptz not null default now());
create index if not exists orders_customer_created on public.orders(customer_id,created_at desc);
create index if not exists messages_conversation_created on public.messages(conversation_id,created_at);
create index if not exists activity_user_created on public.activity_events(user_id,created_at);
create index if not exists notifications_user_created on public.notifications(user_id,created_at desc);
create index if not exists order_items_order on public.order_items(order_id);

create or replace function public.can_access_conversation(cid uuid) returns boolean language sql stable security definer set search_path=public,pg_temp as $$
 select public.app_role() is not null and exists(select 1 from public.conversations c where c.id=cid and ((c.kind='support' and(c.customer_id=auth.uid() or public.app_role() in ('worker','admin'))) or(c.kind='internal' and exists(select 1 from public.conversation_members m where m.conversation_id=c.id and m.user_id=auth.uid()))))
$$;
create or replace function public.notify_user(uid uuid,title_text text,body_text text,route_text text default '/orders') returns void language sql security definer set search_path=public,pg_temp as $$insert into public.notifications(user_id,title,body,route) values(uid,title_text,body_text,route_text)$$;
create or replace function public.notify_staff(title_text text,body_text text,route_text text default '/workspace/orders',admins_only boolean default false) returns void language sql security definer set search_path=public,pg_temp as $$insert into public.notifications(user_id,title,body,route) select id,title_text,body_text,route_text from public.profiles where is_active and(case when admins_only then role='admin' else role in ('worker','admin') end)$$;
create or replace function public.audit(action_text text,target_text text,details_json jsonb default '{}') returns void language sql security definer set search_path=public,pg_temp as $$insert into public.audit_events(actor_id,action,target,details) values(auth.uid(),action_text,target_text,details_json)$$;

-- All writes go through validated functions. RLS also protects reads/realtime.
do $$declare t text;begin foreach t in array array['profiles','products','store_settings','announcements','promotions','wishlist','orders','order_items','order_events','promotion_redemptions','refunds','reviews','conversations','conversation_members','messages','notifications','restock_requests','activity_events','audit_events'] loop execute format('alter table public.%I enable row level security',t);execute format('revoke all on public.%I from anon, authenticated',t);execute format('grant select on public.%I to authenticated',t);end loop;end$$;
grant select on public.products,public.store_settings,public.announcements,public.promotions,public.reviews to anon;
create policy profiles_read on public.profiles for select to authenticated using(public.app_role() is not null and(id=auth.uid() or public.app_role()='admin'));
create policy products_read on public.products for select using(active or public.app_role() in ('worker','admin'));
create policy settings_read on public.store_settings for select using(true);
create policy announcements_read on public.announcements for select using(active or public.app_role()='admin');
create policy promotions_read on public.promotions for select using((active and starts_at<=now() and ends_at>now()) or public.app_role()='admin');
create policy wishlist_read on public.wishlist for select to authenticated using(user_id=auth.uid() and public.app_role()='customer');
create policy orders_read on public.orders for select to authenticated using(public.app_role() in ('worker','admin') or(customer_id=auth.uid() and public.app_role()='customer'));
create policy order_items_read on public.order_items for select to authenticated using(exists(select 1 from public.orders o where o.id=order_id));
create policy order_events_read on public.order_events for select to authenticated using(exists(select 1 from public.orders o where o.id=order_id));
create policy redemptions_read on public.promotion_redemptions for select to authenticated using(public.app_role()='admin' or(customer_id=auth.uid() and public.app_role()='customer'));
create policy refunds_read on public.refunds for select to authenticated using(public.app_role() in ('worker','admin') or(customer_id=auth.uid() and public.app_role()='customer'));
create policy reviews_read on public.reviews for select using(published or public.app_role() in ('worker','admin') or(customer_id=auth.uid() and public.app_role()='customer'));
create policy conversations_read on public.conversations for select to authenticated using(public.can_access_conversation(id));
create policy members_read on public.conversation_members for select to authenticated using(public.can_access_conversation(conversation_id));
create policy messages_read on public.messages for select to authenticated using(public.can_access_conversation(conversation_id));
create policy notifications_read on public.notifications for select to authenticated using(user_id=auth.uid() and public.app_role() is not null);
create policy restock_read on public.restock_requests for select to authenticated using(public.app_role()='admin' or(requester_id=auth.uid() and public.app_role()='worker'));
create policy activity_read on public.activity_events for select to authenticated using(public.app_role()='admin');
create policy audit_read on public.audit_events for select to authenticated using(public.app_role()='admin');
revoke execute on function public.handle_new_user(), public.require_role(text[]),public.notify_user(uuid,text,text,text),public.notify_staff(text,text,text,boolean),public.audit(text,text,jsonb) from public,anon,authenticated;
grant execute on function public.app_role(),public.can_access_conversation(uuid) to anon,authenticated;
commit;


begin;
create or replace function public.update_my_profile(p_name text,p_phone text,p_business_type text) returns void language plpgsql security definer set search_path=public,pg_temp as $$
begin
 perform public.require_role(array['customer','worker','admin']);
 if char_length(trim(p_name)) not between 2 and 100 or p_phone !~ '^\+?[0-9 ()-]{8,20}$' or p_business_type not in ('personal','workshop','retailer','distributor') then raise exception 'Check your name, phone and customer type.';end if;
 update public.profiles set full_name=trim(p_name),phone=trim(p_phone),business_type=p_business_type where id=auth.uid();
end $$;
create or replace function public.toggle_wishlist(p_product_id text) returns boolean language plpgsql security definer set search_path=public,pg_temp as $$
begin
 perform public.require_role(array['customer']);
 if exists(select 1 from public.wishlist where user_id=auth.uid() and product_id=p_product_id) then delete from public.wishlist where user_id=auth.uid() and product_id=p_product_id;return false;end if;
 if not exists(select 1 from public.products where id=p_product_id and active) then raise exception 'Product unavailable.';end if;
 insert into public.wishlist(user_id,product_id) values(auth.uid(),p_product_id) on conflict do nothing;return true;
end $$;
create or replace function public.create_order(p_items jsonb,p_address jsonb,p_code text,p_idempotency_key uuid,p_expected_total bigint) returns uuid language plpgsql security definer set search_path=public,pg_temp as $$
declare row_item jsonb; p public.products%rowtype; cfg public.store_settings%rowtype; promo public.promotions%rowtype; subtotal bigint:=0;discount bigint:=0;shipping bigint;qty integer;oid uuid;item_count integer;
begin
 perform public.require_role(array['customer']);
 if p_idempotency_key is null then raise exception 'A checkout reference is required.';end if;
 perform pg_advisory_xact_lock(hashtext(auth.uid()::text));
 select id into oid from public.orders where customer_id=auth.uid() and idempotency_key=p_idempotency_key;
 if oid is not null then return oid;end if;
 if (select count(*) from public.orders where customer_id=auth.uid() and created_at>now()-interval '1 minute')>=5 or (select count(*) from public.orders where customer_id=auth.uid() and status='awaiting_payment')>=5 then raise exception 'You have several recent or unpaid orders. Complete or cancel them before reserving more stock.';end if;
 if p_items is null or jsonb_typeof(p_items)<>'array' then raise exception 'Provide a valid cart.';end if;
 item_count:=jsonb_array_length(p_items);
 if item_count<1 or item_count>100 then raise exception 'Cart must contain between 1 and 100 different products.';end if;
 if exists(select 1 from jsonb_array_elements(p_items) i group by i->>'product_id' having count(*)>1) then raise exception 'Duplicate cart lines are not allowed.';end if;
 if p_address is null or jsonb_typeof(p_address)<>'object' or coalesce(char_length(trim(p_address->>'name')),0) not between 2 and 100 or coalesce(p_address->>'phone','') !~ '^\+?[0-9 ()-]{8,20}$' or coalesce(char_length(trim(p_address->>'line1')),0) not between 8 and 300 or coalesce(p_address->>'postcode','') !~ '^[0-9]{5}$' or coalesce(char_length(p_address->>'city'),0) not between 2 and 80 or coalesce(char_length(p_address->>'state'),0) not between 2 and 80 then raise exception 'Complete a valid Malaysian delivery address.';end if;
 select * into cfg from public.store_settings where id=1;
 if not cfg.checkout_enabled or cfg.bank_name='' or cfg.bank_account_name='' or cfg.bank_account_number='' then raise exception 'Checkout is not enabled. Contact the store for assistance.';end if;
 for row_item in select value from jsonb_array_elements(p_items) order by value->>'product_id' loop
   if coalesce(row_item->>'quantity','') !~ '^[1-9][0-9]{0,3}$' then raise exception 'Use whole quantities from 1 to 9999.';end if;
   qty:=(row_item->>'quantity')::integer;
   select * into p from public.products where id=row_item->>'product_id' for update;
   if not found or not p.active then raise exception 'An item is no longer available.';end if;
   if not p.price_confirmed then raise exception 'The selling price of % is awaiting store confirmation.',p.name;end if;
   if p.stock<qty then raise exception 'Insufficient stock for %. Available: %.',p.name,p.stock;end if;
   subtotal:=subtotal+p.price_cents*qty;
 end loop;
 if nullif(trim(p_code),'') is not null then
   if char_length(p_code)>30 then raise exception 'Invalid promotion code.';end if;
   select * into promo from public.promotions where code=upper(trim(p_code)) for update;
   if not found or not promo.active or now()<promo.starts_at or now()>=promo.ends_at or promo.used_count>=promo.maximum_uses then raise exception 'Promotion is unavailable or expired.';end if;
   if subtotal<promo.minimum_cents then raise exception 'Promotion minimum spend has not been reached.';end if;
   if exists(select 1 from public.promotion_redemptions where promotion_id=promo.id and customer_id=auth.uid()) then raise exception 'This promotion has already been used by your account.';end if;
   discount:=least(subtotal,case when promo.kind='percent' then floor(subtotal*promo.value/100.0)::bigint else promo.value end);
 end if;
 shipping:=case when cfg.free_shipping_cents>0 and subtotal-discount>=cfg.free_shipping_cents then 0 else cfg.shipping_cents end;
 if subtotal-discount+shipping<=0 then raise exception 'Contact the store about a zero-total order.';end if;
 if p_expected_total is null or p_expected_total<>subtotal-discount+shipping then raise exception 'Prices or delivery charges changed. Refresh your cart before ordering.';end if;
 insert into public.orders(customer_id,address,subtotal_cents,discount_cents,shipping_cents,total_cents,promotion_id,promotion_code,idempotency_key,payment_instructions)
 values(auth.uid(),p_address,subtotal,discount,shipping,subtotal-discount+shipping,promo.id,promo.code,p_idempotency_key,jsonb_build_object('bank_name',cfg.bank_name,'bank_account_name',cfg.bank_account_name,'bank_account_number',cfg.bank_account_number)) returning id into oid;
 for row_item in select value from jsonb_array_elements(p_items) loop
   select * into p from public.products where id=row_item->>'product_id';qty:=(row_item->>'quantity')::integer;
   insert into public.order_items(order_id,product_id,name,sku,category,quantity,price_cents,line_total_cents) values(oid,p.id,p.name,p.sku,p.category,qty,p.price_cents,p.price_cents*qty);
   update public.products set stock=stock-qty,version=version+1,updated_at=now() where id=p.id;
 end loop;
 if promo.id is not null then insert into public.promotion_redemptions values(promo.id,auth.uid(),oid);update public.promotions set used_count=used_count+1 where id=promo.id;end if;
 insert into public.order_events(order_id,actor_id,event,note) values(oid,auth.uid(),'order_created','Stock reserved. Awaiting manual bank transfer.');
 perform public.notify_user(auth.uid(),'Order placed','Your order is awaiting bank transfer. Check the order for payment instructions.');
 perform public.notify_staff('New order','A customer placed an order. Payment has not yet been verified.');
 return oid;
end $$;
create or replace function public.submit_payment(p_order_id uuid,p_reference text,p_proof_path text default null) returns void language plpgsql security definer set search_path=public,pg_temp as $$
declare o public.orders%rowtype;
begin
 perform public.require_role(array['customer']);
 select * into o from public.orders where id=p_order_id and customer_id=auth.uid() for update;
 if not found then raise exception 'Order not found.';end if;
 if o.status<>'awaiting_payment' or o.payment_status not in ('awaiting','rejected') then raise exception 'Payment details cannot be changed in this order state.';end if;
 if now()>o.expires_at then raise exception 'Reservation expired. Contact support before making a transfer.';end if;
 if coalesce(char_length(trim(p_reference)),0) not between 5 and 100 then raise exception 'Provide a bank transfer reference of 5 to 100 characters.';end if;
 if p_proof_path is not null and(not p_proof_path like auth.uid()::text||'/'||o.id::text||'/%' or not exists(select 1 from storage.objects where bucket_id='payment-proofs' and name=p_proof_path)) then raise exception 'Receipt file is not available for this order.';end if;
 update public.orders set payment_status='submitted',payment_reference=trim(p_reference),payment_proof_path=p_proof_path,payment_note=null,updated_at=now() where id=o.id;
 insert into public.order_events(order_id,actor_id,event,note) values(o.id,auth.uid(),'payment_submitted','Awaiting staff verification.');
 perform public.notify_staff('Payment needs verification','Check the bank account and receipt before approving payment.');
end $$;
create or replace function public.verify_payment(p_order_id uuid,p_approved boolean,p_note text default '') returns void language plpgsql security definer set search_path=public,pg_temp as $$
declare o public.orders%rowtype;
begin
 perform public.require_role(array['worker','admin']);
 select * into o from public.orders where id=p_order_id for update;
 if not found or o.status<>'awaiting_payment' or o.payment_status<>'submitted' then raise exception 'This order has no submitted payment awaiting review.';end if;
 if char_length(coalesce(p_note,''))>1000 or (not p_approved and char_length(trim(coalesce(p_note,'')))<5) then raise exception 'Give a clear rejection reason (5 to 1000 characters).';end if;
 update public.orders set payment_status=case when p_approved then 'verified' else 'rejected' end,status=case when p_approved then 'processing' else status end,payment_note=trim(p_note),paid_verified_by=case when p_approved then auth.uid() else null end,updated_at=now() where id=o.id;
 insert into public.order_events(order_id,actor_id,event,note) values(o.id,auth.uid(),case when p_approved then 'payment_verified' else 'payment_rejected' end,trim(p_note));
 perform public.audit('payment_review',o.id::text,jsonb_build_object('approved',p_approved));
 perform public.notify_user(o.customer_id,case when p_approved then 'Payment verified' else 'Payment needs attention' end,case when p_approved then 'Your order is now being prepared.' else trim(p_note) end);
end $$;
create or replace function public.cancel_order(p_order_id uuid,p_reason text) returns void language plpgsql security definer set search_path=public,pg_temp as $$
declare o public.orders%rowtype;i public.order_items%rowtype;
begin
 perform public.require_role(array['customer','worker','admin']);
 select * into o from public.orders where id=p_order_id for update;
 if not found or(public.app_role()='customer' and o.customer_id<>auth.uid()) then raise exception 'Order not found.';end if;
 if o.status='cancelled' then return;end if;
 if o.status<>'awaiting_payment' or o.payment_status not in ('awaiting','rejected') then raise exception 'Paid or submitted-payment orders need staff review or the refund process.';end if;
 if coalesce(char_length(trim(p_reason)),0) not between 5 and 1000 then raise exception 'Give a cancellation reason of 5 to 1000 characters.';end if;
 update public.orders set status='cancelled',cancel_reason=trim(p_reason),updated_at=now() where id=o.id;
 for i in select * from public.order_items where order_id=o.id order by product_id loop update public.products set stock=stock+i.quantity,version=version+1,updated_at=now() where id=i.product_id;end loop;
 if o.promotion_id is not null then delete from public.promotion_redemptions where order_id=o.id;update public.promotions set used_count=greatest(0,used_count-1) where id=o.promotion_id;end if;
 insert into public.order_events(order_id,actor_id,event,note) values(o.id,auth.uid(),'cancelled',trim(p_reason));
 perform public.notify_user(o.customer_id,'Order cancelled','Your unpaid order has been cancelled and reserved stock released.');
end $$;
create or replace function public.expire_unpaid_orders() returns integer language plpgsql security definer set search_path=public,pg_temp as $$
declare o record;counter integer:=0;
begin perform public.require_role(array['worker','admin']);for o in select id from public.orders where status='awaiting_payment' and payment_status in ('awaiting','rejected') and expires_at<now() order by created_at limit 200 loop perform public.cancel_order(o.id,'Unpaid reservation expired after 24 hours.');counter:=counter+1;end loop;return counter;end $$;
create or replace function public.set_order_status(p_order_id uuid,p_status text,p_carrier text default '',p_tracking text default '') returns void language plpgsql security definer set search_path=public,pg_temp as $$
declare o public.orders%rowtype;
begin
 perform public.require_role(array['worker','admin']);select * into o from public.orders where id=p_order_id for update;
 if not found or o.payment_status<>'verified' or not((o.status='processing' and p_status='shipped') or(o.status='shipped' and p_status='delivered')) then raise exception 'Invalid order transition. Verify payment before shipping.';end if;
 if exists(select 1 from public.refunds where order_id=o.id and status in ('requested','approved')) then raise exception 'Resolve the active refund request before fulfilment.';end if;
 if p_status='shipped' and(coalesce(char_length(trim(p_carrier)),0) not between 2 and 80 or coalesce(char_length(trim(p_tracking)),0) not between 2 and 100) then raise exception 'Provide the actual carrier and tracking reference.';end if;
 update public.orders set status=p_status,carrier=case when p_status='shipped' then trim(p_carrier) else carrier end,tracking_number=case when p_status='shipped' then trim(p_tracking) else tracking_number end,updated_at=now() where id=o.id;
 insert into public.order_events(order_id,actor_id,event,note) values(o.id,auth.uid(),p_status,case when p_status='shipped' then trim(p_carrier)||' / '||trim(p_tracking) else 'Carrier delivery recorded; customer receipt confirmation remains separate.' end);
 perform public.notify_user(o.customer_id,'Order '||p_status,'Your order status has been updated. Open orders for details.');
end $$;
create or replace function public.confirm_receipt(p_order_id uuid) returns void language plpgsql security definer set search_path=public,pg_temp as $$
declare o public.orders%rowtype;
begin
 perform public.require_role(array['customer']);select * into o from public.orders where id=p_order_id and customer_id=auth.uid() for update;
 if not found or o.status not in ('shipped','delivered') or o.payment_status<>'verified' then raise exception 'Only the buyer can confirm receipt of a paid, shipped order.';end if;
 if o.received_at is not null then return;end if;
 update public.orders set status='delivered',received_at=now(),updated_at=now() where id=o.id;
 insert into public.order_events(order_id,actor_id,event,note) values(o.id,auth.uid(),'receipt_confirmed','Customer confirmed receipt. Product reviews are now available.');
end $$;
create or replace function public.request_refund(p_order_id uuid,p_reason text) returns uuid language plpgsql security definer set search_path=public,pg_temp as $$
declare o public.orders%rowtype;rid uuid;
begin
 perform public.require_role(array['customer']);select * into o from public.orders where id=p_order_id and customer_id=auth.uid() for update;
 if not found or o.payment_status<>'verified' or o.status='cancelled' then raise exception 'Only a paid order can be submitted for refund review.';end if;
 if coalesce(char_length(trim(p_reason)),0) not between 10 and 2000 then raise exception 'Explain the refund request in 10 to 2000 characters.';end if;
 if exists(select 1 from public.refunds where order_id=o.id) then raise exception 'A refund request already exists. Contact support to discuss it.';end if;
 insert into public.refunds(order_id,customer_id,reason,amount_cents) values(o.id,auth.uid(),trim(p_reason),o.total_cents) returning id into rid;
 insert into public.order_events(order_id,actor_id,event,note) values(o.id,auth.uid(),'refund_requested',trim(p_reason));perform public.notify_staff('Refund requested','Review the reason and return eligibility. No money has been returned.','/workspace/refunds');return rid;
end $$;
create or replace function public.review_refund(p_refund_id uuid,p_approved boolean,p_note text,p_return_received boolean default false) returns void language plpgsql security definer set search_path=public,pg_temp as $$
declare r public.refunds%rowtype;
begin
 perform public.require_role(array['worker','admin']);select * into r from public.refunds where id=p_refund_id for update;
 if not found or r.status not in ('requested','approved') then raise exception 'Refund is no longer awaiting review.';end if;
 if coalesce(char_length(trim(p_note)),0) not between 5 and 1000 then raise exception 'Provide a clear review note.';end if;
 update public.refunds set status=case when p_approved then 'approved' else 'rejected' end,staff_note=trim(p_note),return_received=p_return_received,updated_at=now() where id=r.id;
 perform public.notify_user(r.customer_id,case when p_approved then 'Refund approved for processing' else 'Refund request declined' end,trim(p_note));perform public.audit('refund_review',r.id::text,jsonb_build_object('approved',p_approved));
end $$;
create or replace function public.confirm_refund(p_refund_id uuid,p_reference text,p_restock boolean default false) returns void language plpgsql security definer set search_path=public,pg_temp as $$
declare r public.refunds%rowtype;o public.orders%rowtype;i public.order_items%rowtype;
begin
 perform public.require_role(array['admin']);select * into r from public.refunds where id=p_refund_id for update;
 if not found or r.status<>'approved' then raise exception 'Only an approved refund can be recorded as paid.';end if;
 if coalesce(char_length(trim(p_reference)),0) not between 5 and 100 then raise exception 'Enter the actual refund transfer reference.';end if;
 if p_restock and not r.return_received then raise exception 'Confirm returned goods were received before restocking.';end if;
 select * into o from public.orders where id=r.order_id for update;
 update public.refunds set status='paid',transfer_reference=trim(p_reference),stock_restored=p_restock,updated_at=now() where id=r.id;
 update public.orders set status='cancelled',payment_status='refunded',updated_at=now() where id=o.id;
 if p_restock then for i in select * from public.order_items where order_id=o.id order by product_id loop update public.products set stock=stock+i.quantity,version=version+1,updated_at=now() where id=i.product_id;end loop;end if;
 insert into public.order_events(order_id,actor_id,event,note) values(o.id,auth.uid(),'refund_paid','Manual refund recorded: '||trim(p_reference));perform public.audit('refund_paid',r.id::text,jsonb_build_object('reference',p_reference,'restocked',p_restock));perform public.notify_user(o.customer_id,'Refund transfer recorded','The store recorded your refund. Contact support if the transfer has not arrived.');
end $$;
create or replace function public.submit_review(p_order_id uuid,p_product_id text,p_rating integer,p_body text) returns uuid language plpgsql security definer set search_path=public,pg_temp as $$
declare rid uuid;display text;
begin
 perform public.require_role(array['customer']);
 if not exists(select 1 from public.orders o join public.order_items i on i.order_id=o.id where o.id=p_order_id and o.customer_id=auth.uid() and o.received_at is not null and o.payment_status='verified' and o.status<>'cancelled' and i.product_id=p_product_id) then raise exception 'Confirm receipt of a purchased item before reviewing it.';end if;
 if p_rating is null or p_rating not between 1 and 5 or coalesce(char_length(trim(p_body)),0) not between 10 and 2000 then raise exception 'Choose 1 to 5 stars and write 10 to 2000 characters.';end if;
 select split_part(full_name,' ',1) into display from public.profiles where id=auth.uid();
 insert into public.reviews(order_id,product_id,customer_id,display_name,rating,body) values(p_order_id,p_product_id,auth.uid(),display,p_rating,trim(p_body)) returning id into rid;return rid;
end $$;
create or replace function public.reply_review(p_review_id uuid,p_reply text) returns void language plpgsql security definer set search_path=public,pg_temp as $$
begin perform public.require_role(array['worker','admin']);if coalesce(char_length(trim(p_reply)),0) not between 2 and 2000 then raise exception 'Write a reply of 2 to 2000 characters.';end if;update public.reviews set reply=trim(p_reply),reply_by=auth.uid() where id=p_review_id;if not found then raise exception 'Review not found.';end if;end $$;
create or replace function public.moderate_review(p_review_id uuid,p_published boolean,p_reason text) returns void language plpgsql security definer set search_path=public,pg_temp as $$
begin perform public.require_role(array['admin']);if coalesce(char_length(trim(p_reason)),0)<5 then raise exception 'Record a moderation reason.';end if;update public.reviews set published=p_published where id=p_review_id;perform public.audit('review_moderation',p_review_id::text,jsonb_build_object('published',p_published,'reason',p_reason));end $$;
commit;


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


-- Supabase-only services (kept separate for database-only tests).
begin;
insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types) values
 ('product-images','product-images',true,5242880,array['image/jpeg','image/png','image/webp']),
 ('payment-proofs','payment-proofs',false,5242880,array['image/jpeg','image/png','application/pdf'])
on conflict(id) do update set public=excluded.public,file_size_limit=excluded.file_size_limit,allowed_mime_types=excluded.allowed_mime_types;
create policy product_images_read on storage.objects for select using(bucket_id='product-images');
create policy product_images_insert on storage.objects for insert to authenticated with check(bucket_id='product-images' and public.app_role()='admin');
create policy product_images_update on storage.objects for update to authenticated using(bucket_id='product-images' and public.app_role()='admin') with check(bucket_id='product-images' and public.app_role()='admin');
create policy product_images_delete on storage.objects for delete to authenticated using(bucket_id='product-images' and public.app_role()='admin');
create policy proof_read on storage.objects for select to authenticated using(bucket_id='payment-proofs' and(public.app_role() in ('worker','admin') or(public.app_role()='customer' and(storage.foldername(name))[1]=auth.uid()::text and exists(select 1 from public.orders o where o.id::text=(storage.foldername(name))[2] and o.customer_id=auth.uid()))));
create policy proof_insert on storage.objects for insert to authenticated with check(bucket_id='payment-proofs' and public.app_role()='customer' and(storage.foldername(name))[1]=auth.uid()::text and exists(select 1 from public.orders o where o.id::text=(storage.foldername(name))[2] and o.customer_id=auth.uid() and o.status='awaiting_payment' and o.payment_status in ('awaiting','rejected')));
create policy orphan_proof_delete on storage.objects for delete to authenticated using(bucket_id='payment-proofs' and public.app_role()='customer' and(storage.foldername(name))[1]=auth.uid()::text and not exists(select 1 from public.orders o where o.payment_proof_path=name));
do $$declare t text;begin foreach t in array array['orders','order_events','products','messages','conversations','notifications','refunds','restock_requests','reviews'] loop
 if not exists(select 1 from pg_publication_tables where pubname='supabase_realtime' and schemaname='public' and tablename=t) then execute format('alter publication supabase_realtime add table public.%I',t);end if;
end loop;end$$;
commit;


-- 56 researched reference products. No stock or selling-price confirmation is fabricated.
-- Existing prices, inventory and product edits are preserved when the seed is rerun.
insert into public.products(id,sku,name,brand,category,description,specs,price_cents,fitment_note,source_url,price_source_url,source_observed_at,source_note) values
('toyota-fully-synthetic-0w-20-engine-oil-4l','GL-0001','Toyota Fully Synthetic 0W-20 Engine Oil 4L','Toyota','Engine Oil','Toyota Fully Synthetic 0W-20 Engine Oil 4L. Supplier reference listing; confirm specification and vehicle application before ordering.','{"viscosity":"0W-20","volume":"4 L","formulation":"Fully synthetic"}',13000,'Confirm vehicle application with seller','https://protonperoduaparts.com.my/product/toyota-0w-20-fully-synthetic-engine-oil-4-litres-minyak-enjin-hitam/','https://protonperoduaparts.com.my/product/toyota-0w-20-fully-synthetic-engine-oil-4-litres-minyak-enjin-hitam/','2026-10-28','Displayed supplier reference price; GearLane sale price requires admin confirmation.'),
('sae-40-engine-oil-1l','GL-0002','SAE 40 Engine Oil 1L','Not specified','Engine Oil','SAE 40 Engine Oil 1L. Supplier reference listing; confirm specification and vehicle application before ordering.','{"viscosity":"SAE 40","volume":"1 L"}',1000,'Confirm vehicle application with seller','https://protonperoduaparts.com.my/product/sae-40-engine-oil-petrol-diesel-ngv-engine-1liter/','https://protonperoduaparts.com.my/product/sae-40-engine-oil-petrol-diesel-ngv-engine-1liter/','2026-10-28','Displayed supplier reference price; GearLane sale price requires admin confirmation.'),
('bendix-dot-4-brake-and-clutch-fluid-1l','GL-0003','Bendix DOT 4 Brake and Clutch Fluid 1L','Bendix','Brake Fluid','Bendix DOT 4 Brake and Clutch Fluid 1L. Supplier reference listing; confirm specification and vehicle application before ordering.','{"fluidStandard":"DOT 4","volume":"1 L"}',2200,'Confirm vehicle application with seller','https://protonperoduaparts.com.my/product/bendix-brake-oil-dot-4-minyak-brek-dot4-brake-clutch-oil-fluid-1liter/','https://protonperoduaparts.com.my/product/bendix-brake-oil-dot-4-minyak-brek-dot4-brake-clutch-oil-fluid-1liter/','2026-10-28','Displayed supplier reference price; GearLane sale price requires admin confirmation.'),
('castrol-gtx-ultraclean-15w-40-engine-oil-4l','GL-0004','Castrol GTX Ultraclean 15W-40 Engine Oil 4L','Castrol','Engine Oil','Castrol GTX Ultraclean 15W-40 Engine Oil 4L. Supplier reference listing; confirm specification and vehicle application before ordering.','{"viscosity":"15W-40","volume":"4 L","formulation":"Semi synthetic"}',9500,'Confirm vehicle application with seller','https://protonperoduaparts.com.my/product/castrol-15w-40-gtx-ultraclean-semi-synthetic-engine-oil-4-litres-minyak-enjin-hitam-15-40/','https://protonperoduaparts.com.my/product/castrol-15w-40-gtx-ultraclean-semi-synthetic-engine-oil-4-litres-minyak-enjin-hitam-15-40/','2026-10-28','Displayed supplier reference price; GearLane sale price requires admin confirmation.'),
('proton-cvt-transmission-fluid-1l','GL-0005','Proton CVT Transmission Fluid 1L','Proton','Transmission Fluid','Proton CVT Transmission Fluid 1L. Supplier reference listing; confirm specification and vehicle application before ordering.','{"volume":"1 L","transmissionType":"CVT","supplierApplication":"Proton Inspira"}',5500,'Confirm vehicle application with seller','https://protonperoduaparts.com.my/product/proton-cvt-atf-minyak-auto-mitsubishi-transmission-proton-inspira-1litre/','https://protonperoduaparts.com.my/product/proton-cvt-atf-minyak-auto-mitsubishi-transmission-proton-inspira-1litre/','2026-10-28','Displayed supplier reference price; GearLane sale price requires admin confirmation.'),
('x-traseal-carburetor-and-choke-cleaner-400ml','GL-0006','X''traseal Carburetor and Choke Cleaner 400ml','X''traseal','Cleaners & Additives','X''traseal Carburetor and Choke Cleaner 400ml. Supplier reference listing; confirm specification and vehicle application before ordering.','{"volume":"400 ml"}',999,'Confirm vehicle application with seller','https://protonperoduaparts.com.my/product/carburetor-choke-fuel-injector-cleaner-xtraseal-400ml/','https://protonperoduaparts.com.my/product/carburetor-choke-fuel-injector-cleaner-xtraseal-400ml/','2026-10-28','Displayed supplier reference price; GearLane sale price requires admin confirmation.'),
('proton-blue-radiator-coolant-4l','GL-0007','Proton Blue Radiator Coolant 4L','Proton','Coolant','Proton Blue Radiator Coolant 4L. Supplier reference listing; confirm specification and vehicle application before ordering.','{"volume":"4 L","colour":"Blue"}',4400,'Confirm vehicle application with seller','https://protonperoduaparts.com.my/product/coolant-radiator-cecair-penyejuk-blue-original-proton-4-liter/','https://protonperoduaparts.com.my/product/coolant-radiator-cecair-penyejuk-blue-original-proton-4-liter/','2026-10-28','Displayed supplier reference price; GearLane sale price requires admin confirmation.'),
('automatic-gearbox-filter-for-axia-bezza','GL-0008','Automatic Gearbox Filter for Axia / Bezza','Not specified','Filters','Automatic Gearbox Filter for Axia / Bezza. Supplier reference listing; confirm specification and vehicle application before ordering.','{"supplierApplication":"Perodua Axia / Bezza"}',5500,'Confirm vehicle application with seller','https://protonperoduaparts.com.my/product/auto-gear-box-filter-perodua-axia-bezza/','https://protonperoduaparts.com.my/product/auto-gear-box-filter-perodua-axia-bezza/','2026-10-28','Displayed supplier reference price; GearLane sale price requires admin confirmation.'),
('cabin-filter-for-proton-x50','GL-0009','Cabin Filter for Proton X50','OEM or equivalent','Filters','Cabin Filter for Proton X50. Supplier reference listing; confirm specification and vehicle application before ordering.','{"supplierApplication":"Proton X50 / Geely Binyue"}',2500,'Confirm vehicle application with seller','https://protonperoduaparts.com.my/product/cabin-air-conditioner-penapis-aircond-filter-proton-x50-geely-binyue/','https://protonperoduaparts.com.my/product/cabin-air-conditioner-penapis-aircond-filter-proton-x50-geely-binyue/','2026-10-28','Displayed supplier reference price; GearLane sale price requires admin confirmation.'),
('cabin-filter-for-proton-x70','GL-0010','Cabin Filter for Proton X70','OEM or equivalent','Filters','Cabin Filter for Proton X70. Supplier reference listing; confirm specification and vehicle application before ordering.','{"supplierApplication":"Proton X70 / Geely Boyue"}',2000,'Confirm vehicle application with seller','https://protonperoduaparts.com.my/product/cabin-air-conditioner-penapis-aircond-filter-proton-x70-geely-boyue/','https://protonperoduaparts.com.my/product/cabin-air-conditioner-penapis-aircond-filter-proton-x70-geely-boyue/','2026-10-28','Displayed supplier reference price; GearLane sale price requires admin confirmation.'),
('engine-air-filter-for-proton-x50','GL-0011','Engine Air Filter for Proton X50','OEM or equivalent','Filters','Engine Air Filter for Proton X50. Supplier reference listing; confirm specification and vehicle application before ordering.','{"supplierApplication":"Proton X50 / Geely Binyue"}',2800,'Confirm vehicle application with seller','https://protonperoduaparts.com.my/product/engine-air-filter-penapis-angin-proton-x50geely-binyue/','https://protonperoduaparts.com.my/product/engine-air-filter-penapis-angin-proton-x50geely-binyue/','2026-10-28','Displayed supplier reference price; GearLane sale price requires admin confirmation.'),
('engine-air-filter-for-proton-x70','GL-0012','Engine Air Filter for Proton X70','OEM or equivalent','Filters','Engine Air Filter for Proton X70. Supplier reference listing; confirm specification and vehicle application before ordering.','{"supplierApplication":"Proton X70 / Geely Boyue"}',1800,'Confirm vehicle application with seller','https://protonperoduaparts.com.my/product/engine-air-filter-penapis-angin-proton-x70-geely-boyue/','https://protonperoduaparts.com.my/product/engine-air-filter-penapis-angin-proton-x70-geely-boyue/','2026-10-28','Displayed supplier reference price; GearLane sale price requires admin confirmation.'),
('top-1-green-radiator-coolant-500ml','GL-0013','Top 1 Green Radiator Coolant 500ml','Top 1','Coolant','Top 1 Green Radiator Coolant 500ml. Supplier reference listing; confirm specification and vehicle application before ordering.','{"volume":"500 ml","colour":"Green"}',1000,'Confirm vehicle application with seller','https://protonperoduaparts.com.my/product/coolant-radiator-cecair-penyejuk-green-top-1-500ml/','https://protonperoduaparts.com.my/product/coolant-radiator-cecair-penyejuk-green-top-1-500ml/','2026-10-28','Displayed supplier reference price; GearLane sale price requires admin confirmation.'),
('cvt-gearbox-filter-and-gasket-set','GL-0014','CVT Gearbox Filter and Gasket Set','Not specified','Filters','CVT Gearbox Filter and Gasket Set. Supplier reference listing; confirm specification and vehicle application before ordering.','{"supplierApplication":"Proton Saga FLX / Exora Bold / Preve / Iriz / Suprima / Saga VVT / Persona VVT","includes":"Filter and rubber compound gasket"}',3000,'Confirm vehicle application with seller','https://protonperoduaparts.com.my/product/auto-gear-box-filter-for-proton-saga-flx-exora-bold-preve-iriz-suprima-saga-vvt-persona-vvt-premium-filter-heavy-duty-gasket-made-of-rubber-compound/','https://protonperoduaparts.com.my/product/auto-gear-box-filter-for-proton-saga-flx-exora-bold-preve-iriz-suprima-saga-vvt-persona-vvt-premium-filter-heavy-duty-gasket-made-of-rubber-compound/','2026-10-28','Displayed supplier reference price; GearLane sale price requires admin confirmation.'),
('manual-gear-oil-80w-90-4l','GL-0015','Manual Gear Oil 80W-90 4L','Supplier-selected brand','Transmission Fluid','Manual Gear Oil 80W-90 4L. Supplier reference listing; confirm specification and vehicle application before ordering.','{"viscosity":"80W-90","volume":"4 L","supplierClaimedStandard":"API GL-5","brandAlternatives":"HKK / Power Up / Hi Power / EVO or equivalent"}',5000,'Confirm vehicle application with seller','https://protonperoduaparts.com.my/product/4l-manual-gear-oil-80w90-manual-transmission-fluid-80-90-minyak-gear-manual-4-liter/','https://protonperoduaparts.com.my/product/4l-manual-gear-oil-80w90-manual-transmission-fluid-80-90-minyak-gear-manual-4-liter/','2026-10-28','Displayed supplier reference price; GearLane sale price requires admin confirmation.'),
('manual-gear-oil-ep-140-1l','GL-0016','Manual Gear Oil EP 140 1L','Supplier-selected brand','Transmission Fluid','Manual Gear Oil EP 140 1L. Supplier reference listing; confirm specification and vehicle application before ordering.','{"viscosity":"EP 140","volume":"1 L","supplierClaimedStandard":"API GL-4","brandAlternatives":"HKK / Power Up / Hi Power / EVO or equivalent"}',1500,'Confirm vehicle application with seller','https://protonperoduaparts.com.my/product/manual-gear-oil-ep-140-manual-transmission-fluid-gl4-minyak-gear-manual-1-liter/','https://protonperoduaparts.com.my/product/manual-gear-oil-ep-140-manual-transmission-fluid-gl4-minyak-gear-manual-1-liter/','2026-10-28','Displayed supplier reference price; GearLane sale price requires admin confirmation.'),
('petrol-filter-for-proton-iriz-saga-vvt-persona-vvt','GL-0017','Petrol Filter for Proton Iriz / Saga VVT / Persona VVT','Not specified','Filters','Petrol Filter for Proton Iriz / Saga VVT / Persona VVT. Supplier reference listing; confirm specification and vehicle application before ordering.','{"supplierApplication":"Proton Iriz / Saga VVT / Persona VVT"}',2800,'Confirm vehicle application with seller','https://protonperoduaparts.com.my/product/fuel-petrol-filter-proton-iriz-saga-vvt-persona-vvt/','https://protonperoduaparts.com.my/product/fuel-petrol-filter-proton-iriz-saga-vvt-persona-vvt/','2026-10-28','Displayed supplier reference price; GearLane sale price requires admin confirmation.'),
('denso-k20tnr-s-spark-plugs-4-pack','GL-0018','Denso K20TNR-S Spark Plugs — 4 Pack','Denso','Spark Plugs','Denso K20TNR-S Spark Plugs — 4 Pack. Supplier reference listing; confirm specification and vehicle application before ordering.','{"partNumber":"K20TNR-S","packQuantity":4}',5500,'Confirm vehicle application with seller','https://protonperoduaparts.com.my/product/spark-plug-denso-for-perodua-kembara-old-rusa-1-3-1-6-4pcs-set/','https://protonperoduaparts.com.my/product/spark-plug-denso-for-perodua-kembara-old-rusa-1-3-1-6-4pcs-set/','2026-10-28','Displayed supplier reference price; GearLane sale price requires admin confirmation.'),
('aftermarket-engine-oil-filters-10-pack','GL-0019','Aftermarket Engine Oil Filters — 10 Pack','Supplier-selected brand','Filters','Aftermarket Engine Oil Filters — 10 Pack. Supplier reference listing; confirm specification and vehicle application before ordering.','{"packQuantity":10,"brandAlternatives":"Dosan / Filgard / Filton / OSK / WAX or equivalent"}',4000,'Confirm vehicle application with seller','https://protonperoduaparts.com.my/product/10pcs-engine-oil-filter-for-perodua-kancil-kenari-kelisa-viva-myvi-alza-kembara-rusa-10biji/','https://protonperoduaparts.com.my/product/10pcs-engine-oil-filter-for-perodua-kancil-kenari-kelisa-viva-myvi-alza-kembara-rusa-10biji/','2026-10-28','Displayed supplier reference price; GearLane sale price requires admin confirmation.'),
('perodua-fully-synthetic-0w-20-oil-3-5l-filter','GL-0020','Perodua Fully Synthetic 0W-20 Oil 3.5L + Filter','Perodua','Engine Oil','Perodua Fully Synthetic 0W-20 Oil 3.5L + Filter. Supplier reference listing; confirm specification and vehicle application before ordering.','{"viscosity":"0W-20","volume":"3.5 L","formulation":"Fully synthetic","includes":"Oil filter"}',16500,'Confirm vehicle application with seller','https://protonperoduaparts.com.my/product/perodua-fully-synthetic-0w-20-engine-oil-4-litres-minyak-enjin-0-20-oil-filter-for-perodua-cars-minyak-hitam/','https://protonperoduaparts.com.my/product/perodua-fully-synthetic-0w-20-engine-oil-4-litres-minyak-enjin-0-20-oil-filter-for-perodua-cars-minyak-hitam/','2026-10-28','Displayed supplier reference price; GearLane sale price requires admin confirmation.'),
('ngk-lkar7c-9-spark-plugs-4-pack','GL-0021','NGK LKAR7C-9 Spark Plugs — 4 Pack','NGK','Spark Plugs','NGK LKAR7C-9 Spark Plugs — 4 Pack. Supplier reference listing; confirm specification and vehicle application before ordering.','{"partNumber":"LKAR7C-9","packQuantity":4}',6000,'Confirm vehicle application with seller','https://protonperoduaparts.com.my/product/ngk-spark-plug-lkar7c-9-for-proton-iriz-persona-vvt-saga-vvt-4pcs-set/','https://protonperoduaparts.com.my/product/ngk-spark-plug-lkar7c-9-for-proton-iriz-persona-vvt-saga-vvt-4pcs-set/','2026-10-28','Displayed supplier reference price; GearLane sale price requires admin confirmation.'),
('silicone-air-filter-housing-bush-1-piece','GL-0022','Silicone Air Filter Housing Bush — 1 Piece','Not specified','Filters','Silicone Air Filter Housing Bush — 1 Piece. Supplier reference listing; confirm specification and vehicle application before ordering.','{"material":"Silicone","packQuantity":1}',800,'Confirm vehicle application with seller','https://protonperoduaparts.com.my/product/air-filter-housing-silicone-bush-for-perodua-myvi-alza-avanza-1-piece/','https://protonperoduaparts.com.my/product/air-filter-housing-silicone-bush-for-perodua-myvi-alza-avanza-1-piece/','2026-10-28','Displayed supplier reference price; GearLane sale price requires admin confirmation.'),
('castrol-140-manual-gear-oil-4l','GL-0023','Castrol 140 Manual Gear Oil 4L','Castrol','Transmission Fluid','Castrol 140 Manual Gear Oil 4L. Supplier reference listing; confirm specification and vehicle application before ordering.','{"viscosity":"140","volume":"4 L"}',7500,'Confirm vehicle application with seller','https://protonperoduaparts.com.my/product/castrol-140-gear-oil-manual-transmission-fluid-140-4-liter-minyak-gear-manual/','https://protonperoduaparts.com.my/product/castrol-140-gear-oil-manual-transmission-fluid-140-4-liter-minyak-gear-manual/','2026-10-28','Displayed supplier reference price; GearLane sale price requires admin confirmation.'),
('perodua-radiator-coolant-1l','GL-0024','Perodua Radiator Coolant 1L','Perodua','Coolant','Perodua Radiator Coolant 1L. Supplier reference listing; confirm specification and vehicle application before ordering.','{"volume":"1 L"}',2500,'Confirm vehicle application with seller','https://protonperoduaparts.com.my/product/coolant-original-perodua-1-liter/','https://protonperoduaparts.com.my/product/coolant-original-perodua-1-liter/','2026-10-28','Displayed supplier reference price; GearLane sale price requires admin confirmation.'),
('ngk-lkr6c-spark-plug','GL-0025','NGK LKR6C Spark Plug','NGK','Spark Plugs','NGK LKR6C Spark Plug. Supplier reference listing; confirm specification and vehicle application before ordering.','{"supplierPartNumber":"LKR6C or equivalent"}',2500,'Confirm vehicle application with seller','https://protonperoduaparts.com.my/product/ngk-spark-plug-for-proton-axia-bezza-1-0-lkr6c/','https://protonperoduaparts.com.my/product/ngk-spark-plug-for-proton-axia-bezza-1-0-lkr6c/','2026-10-28','Displayed supplier reference price; GearLane sale price requires admin confirmation.'),
('power-up-power-steering-fluid-1l','GL-0026','Power Up Power Steering Fluid 1L','Power Up','Steering Fluid','Power Up Power Steering Fluid 1L. Supplier reference listing; confirm specification and vehicle application before ordering.','{"volume":"1 L"}',1400,'Confirm vehicle application with seller','https://protonperoduaparts.com.my/product/power-steering-fluid-oil-minyak-power-steering-1-liter/','https://protonperoduaparts.com.my/product/power-steering-fluid-oil-minyak-power-steering-1-liter/','2026-10-28','Displayed supplier reference price; GearLane sale price requires admin confirmation.'),
('denso-k16pru-11-spark-plugs-3-pack','GL-0027','Denso K16PRU-11 Spark Plugs — 3 Pack','Denso','Spark Plugs','Denso K16PRU-11 Spark Plugs — 3 Pack. Supplier reference listing; confirm specification and vehicle application before ordering.','{"partNumber":"K16PRU-11","packQuantity":3}',3000,'Confirm vehicle application with seller','https://protonperoduaparts.com.my/product/denso-spark-plugs-for-perodua-kenari-kelisa-viva-k16pru-11-3pcs-set/','https://protonperoduaparts.com.my/product/denso-spark-plugs-for-perodua-kenari-kelisa-viva-k16pru-11-3pcs-set/','2026-10-28','Displayed supplier reference price; GearLane sale price requires admin confirmation.'),
('bardahl-15w-40-engine-oil-4l','GL-0028','Bardahl 15W-40 Engine Oil 4L','Bardahl','Engine Oil','Bardahl 15W-40 Engine Oil 4L. Supplier reference listing; confirm specification and vehicle application before ordering.','{"viscosity":"15W-40","volume":"4 L"}',6500,'Confirm vehicle application with seller','https://protonperoduaparts.com.my/product/bardahl-15w40-engine-oil-4-liters-minyak-enjin-15-40/','https://protonperoduaparts.com.my/product/bardahl-15w40-engine-oil-4-liters-minyak-enjin-15-40/','2026-10-28','Displayed supplier reference price; GearLane sale price requires admin confirmation.'),
('bardahl-10w-30-engine-oil-3-quarts','GL-0029','Bardahl 10W-30 Engine Oil 3 Quarts','Bardahl','Engine Oil','Bardahl 10W-30 Engine Oil 3 Quarts. Supplier reference listing; confirm specification and vehicle application before ordering.','{"viscosity":"10W-30","volume":"3 quarts"}',5200,'Confirm vehicle application with seller','https://protonperoduaparts.com.my/product/bardahl-10w30-engine-oil-3-quarts-minyak-enjin-10-30/','https://protonperoduaparts.com.my/product/bardahl-10w30-engine-oil-3-quarts-minyak-enjin-10-30/','2026-10-28','Displayed supplier reference price; GearLane sale price requires admin confirmation.'),
('10w-30-engine-oil-perodua-oil-filter-bundle','GL-0030','10W-30 Engine Oil + Perodua Oil Filter Bundle','Not specified','Engine Oil','10W-30 Engine Oil + Perodua Oil Filter Bundle. Supplier reference listing; confirm specification and vehicle application before ordering.','{"viscosity":"10W-30","includes":"Oil filter","reviewRequired":"Confirm oil brand and volume before sale"}',4800,'Confirm vehicle application with seller','https://protonperoduaparts.com.my/product/poix-10w-30-3-quarts-engine-oil-oil-filter-for-perodua-cars/','https://protonperoduaparts.com.my/product/poix-10w-30-3-quarts-engine-oil-oil-filter-for-perodua-cars/','2026-10-28','Displayed supplier reference price; GearLane sale price requires admin confirmation.'),
('castrol-gtx-10w-30-engine-oil-3l','GL-0031','Castrol GTX 10W-30 Engine Oil 3L','Castrol','Engine Oil','Castrol GTX 10W-30 Engine Oil 3L. Supplier reference listing; confirm specification and vehicle application before ordering.','{"viscosity":"10W-30","volume":"3 L"}',5000,'Confirm vehicle application with seller','https://protonperoduaparts.com.my/product/castrol-gtx-10w-30-engine-oil-3-litres-minyak-enjin-10-30/','https://protonperoduaparts.com.my/product/castrol-gtx-10w-30-engine-oil-3-litres-minyak-enjin-10-30/','2026-10-28','Displayed supplier reference price; GearLane sale price requires admin confirmation.'),
('castrol-magnatec-10w-40-engine-oil-4l','GL-0032','Castrol Magnatec 10W-40 Engine Oil 4L','Castrol','Engine Oil','Castrol Magnatec 10W-40 Engine Oil 4L. Supplier reference listing; confirm specification and vehicle application before ordering.','{"viscosity":"10W-40","volume":"4 L","formulation":"Semi synthetic","supplierClaimedStandard":"API SN/CF"}',13500,'Confirm vehicle application with seller','https://protonperoduaparts.com.my/product/castrol-magnatec-10w-40-engine-oil-semi-synthetic-api-sn-cf-4-litre-minyak-enjin-10-40-minyak-hitam/','https://protonperoduaparts.com.my/product/castrol-magnatec-10w-40-engine-oil-semi-synthetic-api-sn-cf-4-litre-minyak-enjin-10-40-minyak-hitam/','2026-10-28','Displayed supplier reference price; GearLane sale price requires admin confirmation.'),
('castrol-80w-90-manual-gear-oil-4l','GL-0033','Castrol 80W-90 Manual Gear Oil 4L','Castrol','Transmission Fluid','Castrol 80W-90 Manual Gear Oil 4L. Supplier reference listing; confirm specification and vehicle application before ordering.','{"viscosity":"80W-90","volume":"4 L"}',7500,'Confirm vehicle application with seller','https://protonperoduaparts.com.my/product/castrol-80w-90-gear-oil-manual-transmission-fluid-80-90-4-liter-minyak-gear-manual/','https://protonperoduaparts.com.my/product/castrol-80w-90-gear-oil-manual-transmission-fluid-80-90-4-liter-minyak-gear-manual/','2026-10-28','Displayed supplier reference price; GearLane sale price requires admin confirmation.'),
('castrol-gtx-10w-30-engine-oil-4l','GL-0034','Castrol GTX 10W-30 Engine Oil 4L','Castrol','Engine Oil','Castrol GTX 10W-30 Engine Oil 4L. Supplier reference listing; confirm specification and vehicle application before ordering.','{"viscosity":"10W-30","volume":"4 L"}',7700,'Confirm vehicle application with seller','https://protonperoduaparts.com.my/product/castrol-gtx-10w-30-engine-oil-4-litres-minyak-enjin-10-30/','https://protonperoduaparts.com.my/product/castrol-gtx-10w-30-engine-oil-4-litres-minyak-enjin-10-30/','2026-10-28','Displayed supplier reference price; GearLane sale price requires admin confirmation.'),
('dexron-iii-atf-d3-transmission-fluid-1l','GL-0035','Dexron III ATF D3 Transmission Fluid 1L','Supplier-selected brand','Transmission Fluid','Dexron III ATF D3 Transmission Fluid 1L. Supplier reference listing; confirm specification and vehicle application before ordering.','{"fluidType":"Dexron III / ATF D3","volume":"1 L","brandAlternatives":"Power Up / Hi Power / EVO or equivalent"}',1300,'Confirm vehicle application with seller','https://protonperoduaparts.com.my/product/dexron-iii-atf-d3-1-litre-automatic-transmission-fluid/','https://protonperoduaparts.com.my/product/dexron-iii-atf-d3-1-litre-automatic-transmission-fluid/','2026-10-28','Displayed supplier reference price; GearLane sale price requires admin confirmation.'),
('toyota-5w-30-engine-oil-4l','GL-0036','Toyota 5W-30 Engine Oil 4L','Toyota','Engine Oil','Toyota 5W-30 Engine Oil 4L. Supplier reference listing; confirm specification and vehicle application before ordering.','{"viscosity":"5W-30","volume":"4 L","supplierClaimedStandard":"API SN/CF"}',10000,'Confirm vehicle application with seller','https://protonperoduaparts.com.my/product/toyota-original-5w-30-engine-oil-api-sn-cf-4-litre/','https://protonperoduaparts.com.my/product/toyota-original-5w-30-engine-oil-api-sn-cf-4-litre/','2026-10-28','Displayed supplier reference price; GearLane sale price requires admin confirmation.'),
('cabin-filter-for-perodua-myvi-alza-axia-bezza','GL-0037','Cabin Filter for Perodua Myvi / Alza / Axia / Bezza','Not specified','Filters','Cabin Filter for Perodua Myvi / Alza / Axia / Bezza. Supplier reference listing; confirm specification and vehicle application before ordering.','{"supplierApplication":"Perodua Myvi / Alza / Axia / Bezza"}',1500,'Confirm vehicle application with seller','https://protonperoduaparts.com.my/product/cabin-air-conditioner-filter-for-perodua-myvi-new-alza/','https://protonperoduaparts.com.my/product/cabin-air-conditioner-filter-for-perodua-myvi-new-alza/','2026-10-28','Displayed supplier reference price; GearLane sale price requires admin confirmation.'),
('bosch-super-4-fr78x-spark-plugs-4-pack','GL-0038','Bosch Super 4 FR78X Spark Plugs — 4 Pack','Bosch','Spark Plugs','Bosch Super 4 FR78X Spark Plugs — 4 Pack. Supplier reference listing; confirm specification and vehicle application before ordering.','{"partNumber":"FR78X","packQuantity":4}',6000,'Confirm vehicle application with seller','https://protonperoduaparts.com.my/product/bosch-super-4-spark-plugs-for-proton-wira-satria-perdana-fr78x/','https://protonperoduaparts.com.my/product/bosch-super-4-spark-plugs-for-proton-wira-satria-perdana-fr78x/','2026-10-28','Displayed supplier reference price; GearLane sale price requires admin confirmation.'),
('bosch-super-4-wr78x-spark-plugs-4-pack','GL-0039','Bosch Super 4 WR78X Spark Plugs — 4 Pack','Bosch','Spark Plugs','Bosch Super 4 WR78X Spark Plugs — 4 Pack. Supplier reference listing; confirm specification and vehicle application before ordering.','{"partNumber":"WR78X","packQuantity":4}',6000,'Confirm vehicle application with seller','https://protonperoduaparts.com.my/product/bosch-super-4-spark-plugs-for-proton-saga-iswara-wira1-3-wr78x-4pcs-set/','https://protonperoduaparts.com.my/product/bosch-super-4-spark-plugs-for-proton-saga-iswara-wira1-3-wr78x-4pcs-set/','2026-10-28','Displayed supplier reference price; GearLane sale price requires admin confirmation.'),
('ngk-lzkar7a-spark-plug','GL-0040','NGK LZKAR7A Spark Plug','NGK','Spark Plugs','NGK LZKAR7A Spark Plug. Supplier reference listing; confirm specification and vehicle application before ordering.','{"partNumber":"LZKAR7A","supplierApplication":"Proton Savvy"}',8000,'Confirm vehicle application with seller','https://protonperoduaparts.com.my/product/ngk-spark-plugs-for-proton-savvy-lzkar7a/','https://protonperoduaparts.com.my/product/ngk-spark-plugs-for-proton-savvy-lzkar7a/','2026-10-28','Displayed supplier reference price; GearLane sale price requires admin confirmation.'),
('proton-atf-hts-4at-fully-synthetic-fluid-3l','GL-0041','Proton ATF HTS 4AT Fully Synthetic Fluid 3L','Proton','Transmission Fluid','Proton ATF HTS 4AT Fully Synthetic Fluid 3L. Supplier reference listing; confirm specification and vehicle application before ordering.','{"volume":"3 L","formulation":"Fully synthetic","fluidType":"ATF HTS 4AT","supplierPartNumber":"PW913191V2-3L or equivalent"}',11500,'Confirm vehicle application with seller','https://protonperoduaparts.com.my/product/proton-atf-hts-4at-fully-synthetic-3-litre-proton-atf-hts-4at-genuine-multifunctional-automatic-transmission-fluid/','https://protonperoduaparts.com.my/product/proton-atf-hts-4at-fully-synthetic-3-litre-proton-atf-hts-4at-genuine-multifunctional-automatic-transmission-fluid/','2026-10-28','Displayed supplier reference price; GearLane sale price requires admin confirmation.'),
('front-brake-pads-for-proton-gen-2-persona-neo','GL-0042','Front Brake Pads for Proton Gen 2 / Persona / Neo','Perfect or equivalent','Brake Pads','Front Brake Pads for Proton Gen 2 / Persona / Neo. Supplier reference listing; confirm specification and vehicle application before ordering.','{"packQuantity":4,"supplierApplication":"Proton Gen 2 / Persona / Neo","reviewRequired":"Supplier page conflicts between D6806 and D6804 part numbers; confirm before sale"}',3800,'Confirm vehicle application with seller','https://protonperoduaparts.com.my/product/front-brake-pad-proton-gen-2-persona-neo/','https://protonperoduaparts.com.my/product/front-brake-pad-proton-gen-2-persona-neo/','2026-10-28','Displayed supplier reference price; GearLane sale price requires admin confirmation.'),
('trw-gdb7707-front-brake-pads','GL-0043','TRW GDB7707 Front Brake Pads','TRW','Brake Pads','TRW GDB7707 Front Brake Pads. Supplier reference listing; confirm specification and vehicle application before ordering.','{"partNumber":"GDB7707","position":"Front","supplierApplication":"Proton Saga BLM / FL / FLX / Saga VVT 2016 / Savvy / Chevrolet Aveo"}',5500,'Confirm vehicle application with seller','https://www.zhapalang.com.my/showproducts/productid/6344270/cid/549622/original-trw-front-brake-pad-proton-saga-blm-fl-flx-saga-vvt-2016-savvy-chevrolet-aveo-gdb7707/','https://www.zhapalang.com.my/ourproducts/cid/549622/cat/brake-system/pn/13/','2026-10-28','Exact fixed price observed on supplier category listing; linked product page could not be fetched. Confirm price and fitment before sale.'),
('trw-gdb7742-front-brake-pads','GL-0044','TRW GDB7742 Front Brake Pads','TRW','Brake Pads','TRW GDB7742 Front Brake Pads. Supplier reference listing; confirm specification and vehicle application before ordering.','{"partNumber":"GDB7742","position":"Front","supplierApplication":"Nissan Almera / Grand Livina / Latio"}',6700,'Confirm vehicle application with seller','https://www.zhapalang.com.my/showproducts/productid/6344267/cid/549622/original-trw-front-brake-pad-nissan-almera-grand-livina-latio-gdb7742/','https://www.zhapalang.com.my/ourproducts/cid/549622/cat/brake-system/pn/13/','2026-10-28','Exact fixed price observed on supplier category listing; linked product page could not be fetched. Confirm price and fitment before sale.'),
('trw-gdb7986-front-brake-pads','GL-0045','TRW GDB7986 Front Brake Pads','TRW','Brake Pads','TRW GDB7986 Front Brake Pads. Supplier reference listing; confirm specification and vehicle application before ordering.','{"partNumber":"GDB7986","position":"Front","supplierApplication":"Proton Iriz / Persona VVT / Saga VVT 2019-Present"}',7700,'Confirm vehicle application with seller','https://www.zhapalang.com.my/showproducts/productid/6344266/cid/549622/original-trw-front-brake-pad-proton-iriz-persona-vvt-saga-vvt-2019present-gdb7986/','https://www.zhapalang.com.my/ourproducts/cid/549622/cat/brake-system/pn/13/','2026-10-28','Exact fixed price observed on supplier category listing; linked product page could not be fetched. Confirm price and fitment before sale.'),
('trw-gdb1198-front-brake-pads','GL-0046','TRW GDB1198 Front Brake Pads','TRW','Brake Pads','TRW GDB1198 Front Brake Pads. Supplier reference listing; confirm specification and vehicle application before ordering.','{"partNumber":"GDB1198","position":"Front","supplierApplication":"Perodua Alza 2009-2013"}',5200,'Confirm vehicle application with seller','https://www.zhapalang.com.my/showproducts/productid/6344250/cid/549622/original-trw-front-brake-pad-perodua-alza-20092013-gdb1198/','https://www.zhapalang.com.my/ourproducts/cid/549622/cat/brake-system/pn/13/','2026-10-28','Exact fixed price observed on supplier category listing; linked product page could not be fetched. Confirm price and fitment before sale.'),
('trw-gdb8977-front-brake-pads','GL-0047','TRW GDB8977 Front Brake Pads','TRW','Brake Pads','TRW GDB8977 Front Brake Pads. Supplier reference listing; confirm specification and vehicle application before ordering.','{"partNumber":"GDB8977","position":"Front","supplierApplication":"Perodua Myvi D20N 2018-2024"}',7500,'Confirm vehicle application with seller','https://www.zhapalang.com.my/showproducts/productid/6344243/cid/549622/original-trw-front-brake-pad-perodua-myvi-new-20182024-d20n-gdb8977/','https://www.zhapalang.com.my/ourproducts/cid/549622/cat/brake-system/pn/13/','2026-10-28','Exact fixed price observed on supplier category listing; linked product page could not be fetched. Confirm price and fitment before sale.'),
('trw-gdb3459-front-brake-pads','GL-0048','TRW GDB3459 Front Brake Pads','TRW','Brake Pads','TRW GDB3459 Front Brake Pads. Supplier reference listing; confirm specification and vehicle application before ordering.','{"partNumber":"GDB3459","position":"Front","supplierApplication":"Toyota Vios NCP93 J/E / Perodua Alza 2014"}',6700,'Confirm vehicle application with seller','https://www.zhapalang.com.my/showproducts/productid/6344225/cid/549622/original-trw-front-brake-pad-toyota-vios-ncp93-je-spec-perodua-alza-2014-gdb3459/','https://www.zhapalang.com.my/ourproducts/cid/549622/cat/brake-system/pn/13/','2026-10-28','Exact fixed price observed on supplier category listing; linked product page could not be fetched. Confirm price and fitment before sale.'),
('trw-gdb7856-front-brake-pads','GL-0049','TRW GDB7856 Front Brake Pads','TRW','Brake Pads','TRW GDB7856 Front Brake Pads. Supplier reference listing; confirm specification and vehicle application before ordering.','{"partNumber":"GDB7856","position":"Front","supplierApplication":"Perodua Myvi Lagi Best / Axia / Bezza"}',4500,'Confirm vehicle application with seller','https://www.zhapalang.com.my/showproducts/productid/6344208/cid/549622/original-trw-front-brake-pad-perodua-myvi-lagi-best-axia-bezza-gdb7856/','https://www.zhapalang.com.my/ourproducts/cid/549622/cat/brake-system/pn/13/','2026-10-28','Exact fixed price observed on supplier category listing; linked product page could not be fetched. Confirm price and fitment before sale.'),
('trw-gdb7690-front-brake-pads','GL-0050','TRW GDB7690 Front Brake Pads','TRW','Brake Pads','TRW GDB7690 Front Brake Pads. Supplier reference listing; confirm specification and vehicle application before ordering.','{"partNumber":"GDB7690","position":"Front","supplierApplication":"Perodua Myvi 1.0/1.3 2005-2010"}',4200,'Confirm vehicle application with seller','https://www.zhapalang.com.my/showproducts/productid/6344145/cid/549622/original-trw-front-brake-pads-for-perodua-myvi-1013-20052010-gdb7690/','https://www.zhapalang.com.my/ourproducts/cid/549622/cat/brake-system/pn/13/','2026-10-28','Exact fixed price observed on supplier category listing; linked product page could not be fetched. Confirm price and fitment before sale.'),
('supercircuit-proton-x70-downpipe','GL-0051','SUPERCIRCUIT Proton X70 Downpipe','SUPERCIRCUIT','Exhaust','SUPERCIRCUIT Proton X70 Downpipe. Supplier reference listing; confirm specification and vehicle application before ordering.','{"component":"Downpipe","supplierApplication":"Proton X70"}',150000,'Confirm vehicle application with seller','https://www.h-performance.com.my/collections/proton-exhaust-products/products/proton-x70-downpipe','https://www.h-performance.com.my/collections/proton-exhaust-products','2026-10-28','Exact fixed price observed on the SUPERCIRCUIT supplier collection; linked product page could not be fetched. Material, installation and vehicle compatibility require confirmation.'),
('supercircuit-proton-x50-downpipe','GL-0052','SUPERCIRCUIT Proton X50 Downpipe','SUPERCIRCUIT','Exhaust','SUPERCIRCUIT Proton X50 Downpipe. Supplier reference listing; confirm specification and vehicle application before ordering.','{"component":"Downpipe","supplierApplication":"Proton X50"}',120000,'Confirm vehicle application with seller','https://www.h-performance.com.my/collections/proton-exhaust-products/products/proton-x50-downpipe','https://www.h-performance.com.my/collections/proton-exhaust-products','2026-10-28','Exact fixed price observed on the SUPERCIRCUIT supplier collection; linked product page could not be fetched. Material, installation and vehicle compatibility require confirmation.'),
('supercircuit-proton-preve-suprima-s-exora-bold-downpipe','GL-0053','SUPERCIRCUIT Proton Preve / Suprima S / Exora Bold Downpipe','SUPERCIRCUIT','Exhaust','SUPERCIRCUIT Proton Preve / Suprima S / Exora Bold Downpipe. Supplier reference listing; confirm specification and vehicle application before ordering.','{"component":"Downpipe","supplierApplication":"Proton Preve / Suprima S / Exora Bold"}',113000,'Confirm vehicle application with seller','https://www.h-performance.com.my/collections/proton-exhaust-products/products/proton-preve-suprima-s-exora-bolt-downpipe','https://www.h-performance.com.my/collections/proton-exhaust-products','2026-10-28','Exact fixed price observed on the SUPERCIRCUIT supplier collection; linked product page could not be fetched. Material, installation and vehicle compatibility require confirmation.'),
('liqui-moly-dot-4-brake-fluid-500ml','GL-0054','Liqui Moly DOT 4 Brake Fluid 500ml','Liqui Moly','Brake Fluid','Liqui Moly DOT 4 Brake Fluid 500ml. Supplier reference listing; confirm specification and vehicle application before ordering.','{"fluidStandard":"DOT 4","volume":"500 ml"}',6500,'Confirm vehicle application with seller','https://lmem.my/product/repair-services/brake-system/brake-fluid-dot-4-500ml/','https://lmem.my/product/repair-services/brake-system/brake-fluid-dot-4-500ml/','2026-10-28','Main product price RM65.00; related-product cards elsewhere showed RM50.00. Main product price retained; reconfirm before sale.'),
('liqui-moly-dot-5-1-ev-brake-fluid-500ml','GL-0055','Liqui Moly DOT 5.1 EV Brake Fluid 500ml','Liqui Moly','Brake Fluid','Liqui Moly DOT 5.1 EV Brake Fluid 500ml. Supplier reference listing; confirm specification and vehicle application before ordering.','{"fluidStandard":"DOT 5.1 EV","volume":"500 ml"}',11800,'Confirm vehicle application with seller','https://lmem.my/product/lubricants/brake-fluids/liqui-moly-brake-fluid-dot-5-1-ev-500ml-outstanding-corrosion-and-oxidation-resistance-specially-for-evs-excellent-wet-and-dry-boiling-point/','https://lmem.my/product/lubricants/brake-fluids/liqui-moly-brake-fluid-dot-5-1-ev-500ml-outstanding-corrosion-and-oxidation-resistance-specially-for-evs-excellent-wet-and-dry-boiling-point/','2026-10-28','Main product price RM118.00; category page showed RM135.00. Main product price retained; reconfirm before sale.'),
('bosch-aerotwin-plus-ap32-wiper-blade-single-pack','GL-0056','Bosch Aerotwin Plus AP32 Wiper Blade — Single Pack','Bosch','Wipers','Bosch Aerotwin Plus AP32 Wiper Blade — Single Pack. Supplier reference listing; confirm specification and vehicle application before ordering.','{"partNumber":"AP32","packQuantity":1,"armRestriction":"Not for U-hook arms","reviewRequired":"Description contains an AP18 copy error; AP32 verified from title and SKU. Confirm blade size and adapters."}',11557,'Confirm vehicle application with seller','https://www.zhapalang.com.my/showproducts/productid/5810419/cid/549444/bosch-aerotwin-plus-ap32-flat-wiper-blade-for-continental-car-single-pack-not-for-u-hook-arm/','https://www.zhapalang.com.my/showproducts/productid/5810419/cid/549444/bosch-aerotwin-plus-ap32-flat-wiper-blade-for-continental-car-single-pack-not-for-u-hook-arm/','2026-10-28','Exact RM115.57 observed on the supplier product result and matching category listing. Package/physical blade dimensions are not inferred from shipping dimensions.')
on conflict(id) do nothing;
update public.products set reference_price_cents=price_cents where reference_price_cents is null and not price_confirmed;


-- Apply to the existing project after its original setup and migration 006.
-- Non-destructive: retain messages, memberships, permissions and notifications.
begin;
alter table public.messages add column if not exists client_message_id uuid;
create unique index if not exists messages_sender_client_unique
 on public.messages(sender_id,client_message_id) where client_message_id is not null;

create or replace function public.send_chat_message(
 p_conversation_id uuid,p_body text,p_product_id text,p_client_message_id uuid
) returns uuid language plpgsql security definer set search_path=public,pg_temp as $$
declare existing public.messages%rowtype; clean_body text; message_id uuid;
begin
 perform public.require_role(array['customer','worker','admin']);
 if not public.can_access_conversation(p_conversation_id) then
  raise exception 'Conversation unavailable.' using errcode='42501';
 end if;
 if p_client_message_id is null then raise exception 'A message delivery reference is required.';end if;
 clean_body:=regexp_replace(p_body,'^[[:space:]]+|[[:space:]]+$','','g');
 if coalesce(char_length(clean_body),0) not between 1 and 2000
    or regexp_replace(translate(coalesce(clean_body,''),U&'\200B\200C\200D\FEFF',''),'[[:space:]]','','g')='' then
  raise exception 'Write a message of 1 to 2000 characters.';
 end if;
 if regexp_replace(clean_body,E'[\n\r\t]','','g') ~ '[[:cntrl:]]' then
  raise exception 'The message contains unsupported control characters.';
 end if;
 -- Lock all sends by the same user to enforce the existing per-minute limit.
 perform pg_advisory_xact_lock(hashtext('chat:'||auth.uid()::text));
 select * into existing from public.messages where sender_id=auth.uid() and client_message_id=p_client_message_id;
 if found then
  if existing.conversation_id is distinct from p_conversation_id
     or existing.body is distinct from clean_body
     or existing.product_id is distinct from p_product_id then
   raise exception 'This delivery reference belongs to a different message.';
  end if;
  return existing.id;
 end if;
 -- Existing function checks active membership, closure, product and rate limits.
 message_id:=public.send_message(p_conversation_id,clean_body,p_product_id);
 update public.messages set client_message_id=p_client_message_id where id=message_id;
 return message_id;
end $$;
revoke all on function public.send_chat_message(uuid,text,text,uuid) from public,anon;
grant execute on function public.send_chat_message(uuid,text,text,uuid) to authenticated;
commit;


-- Run once after the existing setup (including 007). Safe to rerun.
begin;
create table if not exists public.promotion_banners(
 id uuid primary key default gen_random_uuid(),
 title text not null check(char_length(trim(title)) between 3 and 120),
 alt_text text not null default '' check(char_length(alt_text)<=300),
 image_url text check(image_url is null or (image_url ~ '^https://[^[:space:]]+$' and char_length(image_url)<=2000)),
 mobile_image_url text check(mobile_image_url is null or (mobile_image_url ~ '^https://[^[:space:]]+$' and char_length(mobile_image_url)<=2000)),
 link_path text check(link_path is null or char_length(link_path)<=500),
 position integer not null default 0 check(position between 0 and 9999),
 published boolean not null default false,
 version integer not null default 1,
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now(),
 check(not published or (image_url is not null and char_length(trim(alt_text))>=5))
);
alter table public.promotion_banners enable row level security;
revoke all on public.promotion_banners from anon,authenticated;
grant select on public.promotion_banners to anon,authenticated;
drop policy if exists promotion_banners_read on public.promotion_banners;
create policy promotion_banners_read on public.promotion_banners for select
 using((published and image_url is not null) or public.app_role()='admin');
create index if not exists promotion_banners_order on public.promotion_banners(position,created_at);

create or replace function public.admin_save_banner(p_banner jsonb,p_expected_version integer default null)
returns uuid language plpgsql security definer set search_path=public,pg_temp as $$
declare bid uuid;existing public.promotion_banners%rowtype;target_path text;
begin
 perform public.require_role(array['admin']);
 if p_banner is null or jsonb_typeof(p_banner)<>'object' then raise exception 'Provide valid banner details.';end if;
 bid:=coalesce(nullif(p_banner->>'id','')::uuid,gen_random_uuid());
 target_path:=nullif(trim(p_banner->>'link_path'),'');
 if target_path is not null and(char_length(target_path)>500 or position(chr(92) in target_path)>0
   or target_path !~ '^(/|/shop(\?[^#[:cntrl:]]*)?|/products/[A-Za-z0-9_-]{1,100}|/messages)$') then
  raise exception 'Choose a store page such as /shop or /products/product-id. External links are not accepted.';
 end if;
 select * into existing from public.promotion_banners where id=bid for update;
 if found and(p_expected_version is null or existing.version<>p_expected_version) then raise exception 'This banner changed. Refresh before saving.';end if;
 insert into public.promotion_banners(id,title,alt_text,image_url,mobile_image_url,link_path,position,published)
 values(bid,trim(p_banner->>'title'),trim(coalesce(p_banner->>'alt_text','')),nullif(trim(p_banner->>'image_url'),''),nullif(trim(p_banner->>'mobile_image_url'),''),target_path,(p_banner->>'position')::integer,(p_banner->>'published')::boolean)
 on conflict(id) do update set title=excluded.title,alt_text=excluded.alt_text,image_url=excluded.image_url,mobile_image_url=excluded.mobile_image_url,link_path=excluded.link_path,position=excluded.position,published=excluded.published,version=public.promotion_banners.version+1,updated_at=now();
 perform public.audit('promotion_banner_saved',bid::text);return bid;
end $$;
create or replace function public.admin_delete_banner(p_id uuid) returns void language plpgsql security definer set search_path=public,pg_temp as $$
begin
 perform public.require_role(array['admin']);
 delete from public.promotion_banners where id=p_id;
 perform public.audit('promotion_banner_deleted',p_id::text);
end $$;
revoke all on function public.admin_save_banner(jsonb,integer),public.admin_delete_banner(uuid) from public,anon;
grant execute on function public.admin_save_banner(jsonb,integer),public.admin_delete_banner(uuid) to authenticated;
commit;

-- Supabase Storage
begin;
insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types)
 values('promotion-banners','promotion-banners',true,5242880,array['image/jpeg','image/png','image/webp'])
 on conflict(id) do update set public=excluded.public,file_size_limit=excluded.file_size_limit,allowed_mime_types=excluded.allowed_mime_types;
drop policy if exists promotion_banner_images_read on storage.objects;
create policy promotion_banner_images_read on storage.objects for select using(bucket_id='promotion-banners');
drop policy if exists promotion_banner_images_insert on storage.objects;
create policy promotion_banner_images_insert on storage.objects for insert to authenticated with check(bucket_id='promotion-banners' and public.app_role()='admin');
drop policy if exists promotion_banner_images_update on storage.objects;
create policy promotion_banner_images_update on storage.objects for update to authenticated using(bucket_id='promotion-banners' and public.app_role()='admin') with check(bucket_id='promotion-banners' and public.app_role()='admin');
drop policy if exists promotion_banner_images_delete on storage.objects;
create policy promotion_banner_images_delete on storage.objects for delete to authenticated using(bucket_id='promotion-banners' and public.app_role()='admin');
do $$begin
 if not exists(select 1 from pg_publication_tables where pubname='supabase_realtime' and schemaname='public' and tablename='promotion_banners') then alter publication supabase_realtime add table public.promotion_banners;end if;
end $$;
commit;


-- Apply after existing setup, 007 and 008. Preserves all existing chats/messages.
begin;
-- Separate enquiries may remain open independently; creation is serialised/rate-limited.
drop index if exists public.one_open_support_per_customer;
create index if not exists support_customer_history on public.conversations(customer_id,created_at desc,id desc) where kind='support';
create index if not exists chat_inbox_latest on public.messages(conversation_id,created_at desc,id desc);

create or replace function public.chat_inbox() returns jsonb language plpgsql stable security definer set search_path=public,pg_temp as $$
declare result jsonb;
begin
 perform public.require_role(array['customer','worker','admin']);
 select coalesce(jsonb_agg(row order by sort_at desc,id desc),'[]'::jsonb) into result from(
  select c.id,coalesce(last.created_at,c.created_at) sort_at,to_jsonb(c)||jsonb_build_object(
   'customer_name',(select p.full_name from public.profiles p where p.id=c.customer_id),
   'members',coalesce((select jsonb_agg(m) from public.conversation_members m where m.conversation_id=c.id),'[]'::jsonb),
   'last_message',case when last.id is null then null else jsonb_build_object('id',last.id,'body',left(last.body,240),'created_at',last.created_at,'sender_id',last.sender_id,'product_name',last.product_name) end,
   'unread_count',(select count(*) from public.messages unread where unread.conversation_id=c.id and unread.sender_id<>auth.uid() and unread.created_at>coalesce((select cm.last_read_at from public.conversation_members cm where cm.conversation_id=c.id and cm.user_id=auth.uid()),'-infinity'::timestamptz))
  ) row from public.conversations c
  left join lateral(select m.* from public.messages m where m.conversation_id=c.id order by m.created_at desc,m.id desc limit 1) last on true
  where public.can_access_conversation(c.id)
  order by coalesce(last.created_at,c.created_at) desc,c.id desc limit 100
 ) inbox;
 return result;
end $$;

create or replace function public.start_support_enquiry(p_title text,p_request_id uuid) returns uuid language plpgsql security definer set search_path=public,pg_temp as $$
declare existing public.conversations%rowtype;subject text:=trim(p_title);
begin
 perform public.require_role(array['customer']);
 if p_request_id is null or subject is null or char_length(subject) not between 3 and 120 or subject ~ '[[:cntrl:]]' or subject !~ '[^[:space:]]' then raise exception 'Enter an enquiry topic from 3 to 120 characters.';end if;
 perform pg_advisory_xact_lock(hashtext(auth.uid()::text||'support'));
 select * into existing from public.conversations where id=p_request_id;
 if found then
  if existing.kind<>'support' or existing.customer_id<>auth.uid() or existing.title<>subject then raise exception 'This enquiry reference is unavailable.' using errcode='42501';end if;
  return existing.id;
 end if;
 if (select count(*) from public.conversations where customer_id=auth.uid() and kind='support' and created_at>now()-interval '1 minute')>=3
 or (select count(*) from public.conversations where customer_id=auth.uid() and kind='support' and created_at>now()-interval '1 hour')>=12 then
  raise exception 'Too many new enquiries. Continue an existing chat or try again later.';
 end if;
 insert into public.conversations(id,kind,customer_id,title,created_by) values(p_request_id,'support',auth.uid(),subject,auth.uid());
 insert into public.conversation_members(conversation_id,user_id) values(p_request_id,auth.uid());
 return p_request_id;
end $$;

-- Product enquiries still resume an open support chat, choosing the latest one.
create or replace function public.start_conversation(p_kind text,p_recipient_id uuid default null) returns uuid language plpgsql security definer set search_path=public,pg_temp as $$
declare cid uuid;
begin
 perform public.require_role(array['customer','worker','admin']);
 if p_kind='support' then
  perform public.require_role(array['customer']);perform pg_advisory_xact_lock(hashtext(auth.uid()::text||'support'));
  select id into cid from public.conversations where kind='support' and customer_id=auth.uid() and closed_at is null order by created_at desc,id desc limit 1;
  if cid is not null then return cid;end if;
  insert into public.conversations(kind,customer_id,title,created_by) values('support',auth.uid(),'Customer support',auth.uid()) returning id into cid;
  insert into public.conversation_members(conversation_id,user_id) values(cid,auth.uid());
 elsif p_kind='internal' then
  perform public.require_role(array['worker','admin']);
  if p_recipient_id is null or p_recipient_id=auth.uid() or not exists(select 1 from public.profiles where id=p_recipient_id and is_active and role in('worker','admin')) then raise exception 'Choose another active staff member.';end if;
  insert into public.conversations(kind,title,created_by) values('internal','Staff conversation',auth.uid()) returning id into cid;
  insert into public.conversation_members(conversation_id,user_id) values(cid,auth.uid()),(cid,p_recipient_id);
 else raise exception 'Unknown conversation type.';end if;
 return cid;
end $$;
revoke all on function public.chat_inbox(),public.start_support_enquiry(text,uuid),public.start_conversation(text,uuid) from public,anon;
grant execute on function public.chat_inbox(),public.start_support_enquiry(text,uuid),public.start_conversation(text,uuid) to authenticated;
commit;


-- GearLane privacy hardening. Review, then run once in the Supabase SQL Editor on an EXISTING project.
-- (A new project gets it through setup.sql.) Safe to run more than once. No business data is changed.
--
-- 1. Bank details were readable by anyone, including signed-out visitors.
-- 2. Every active promotion code could be listed by anyone.
-- 3. Signed-out visitors could read reviewer and order identifiers.
begin;

-- 1. Public settings view without bank details; admins read the full row through a role-checked function.
-- Customers still see the bank account on their own order: it is copied into the order when it is placed.
create or replace view public.public_store_settings as
  select id,store_name,shipping_cents,free_shipping_cents,checkout_enabled,contact_email,return_policy
  from public.store_settings;
revoke all on public.store_settings from anon, authenticated;
revoke all on public.public_store_settings from anon, authenticated;
grant select on public.public_store_settings to anon, authenticated;

create or replace function public.admin_get_settings() returns jsonb language plpgsql stable security definer set search_path=public,pg_temp as $$
begin
 perform public.require_role(array['admin']);
 return (select to_jsonb(s) from public.store_settings s where s.id=1);
end$$;
revoke all on function public.admin_get_settings() from public,anon;
grant execute on function public.admin_get_settings() to authenticated;

-- 2. Promotions are no longer listable. Admins manage them; customers check one code at a time.
drop policy if exists promotions_read on public.promotions;
create policy promotions_read on public.promotions for select to authenticated using(public.app_role()='admin');
revoke select on public.promotions from anon;

create or replace function public.check_promotion(p_code text) returns jsonb language plpgsql security definer set search_path=public,pg_temp as $$
declare promo public.promotions%rowtype;
begin
 perform public.require_role(array['customer']);
 if p_code is null or char_length(p_code)>30 then perform pg_sleep(.5);raise exception 'That promotion code is not valid.';end if;
 select * into promo from public.promotions where code=upper(trim(p_code));
 -- One generic message and a short delay for every failure, so codes cannot be guessed quickly or told apart.
 if not found or not promo.active or now()<promo.starts_at or now()>=promo.ends_at or promo.used_count>=promo.maximum_uses
    or exists(select 1 from public.promotion_redemptions where promotion_id=promo.id and customer_id=auth.uid()) then
  perform pg_sleep(.5);raise exception 'That promotion code is not valid.';
 end if;
 return jsonb_build_object('id',promo.id,'code',promo.code,'kind',promo.kind,'value',promo.value,'minimum_cents',promo.minimum_cents,'starts_at',promo.starts_at,'ends_at',promo.ends_at,'active',promo.active);
end$$;
revoke all on function public.check_promotion(text) from public,anon;
grant execute on function public.check_promotion(text) to authenticated;

-- 3. Signed-out visitors may read the public review text only, not who wrote it or which order it came from.
revoke select on public.reviews from anon;
grant select(id,product_id,rating,body,display_name,reply,published,created_at) on public.reviews to anon;

commit;


-- GearLane dashboard comparison. Review, then run once in the Supabase SQL Editor on an EXISTING project.
-- (A new project gets it through setup.sql.) Safe to run more than once. No business data is changed.
--
-- Returns the same headline figures as dashboard_stats, for the period of equal length that ENDS where
-- the selected period BEGINS (for example, days 31-60 ago when the dashboard shows the last 30 days).
begin;
create or replace function public.dashboard_previous_period(p_days integer default 30) returns jsonb language plpgsql stable security definer set search_path=public,pg_temp as $$
declare since_time timestamptz;until_time timestamptz;
begin
 perform public.require_role(array['admin']);
 if p_days not in(7,30,90) then raise exception 'Choose 7, 30 or 90 days.';end if;
 until_time:=now()-make_interval(days=>p_days);since_time:=until_time-make_interval(days=>p_days);
 return jsonb_build_object(
  'paid_sales_cents',coalesce((select sum(total_cents) from public.orders where created_at>=since_time and created_at<until_time and payment_status='verified'),0),
  'paid_orders',(select count(*) from public.orders where created_at>=since_time and created_at<until_time and payment_status='verified'),
  'active_customers',(select count(distinct user_id) from public.activity_events where created_at>=since_time and created_at<until_time)
 );
end $$;
revoke all on function public.dashboard_previous_period(integer) from public,anon;
grant execute on function public.dashboard_previous_period(integer) to authenticated;
commit;


-- GearLane order emails. Review, then run once in the Supabase SQL Editor on an EXISTING project.
-- (A new project gets it through setup.sql.) Safe to run more than once. No business data is changed.
--
-- Records which email has been sent for which order so a customer gets each message once, however many
-- times the browser asks. Only the server (service-role key) can read or write it; browsers cannot.
begin;
create table if not exists public.order_emails(
  order_id uuid not null references public.orders(id) on delete cascade,
  event text not null check(event in ('placed','payment_verified','payment_rejected','shipped','delivered','cancelled')),
  sent_at timestamptz not null default now(),
  primary key(order_id,event)
);
alter table public.order_emails enable row level security;
revoke all on public.order_emails from anon, authenticated;
commit;


-- GearLane "notify me when back in stock". Review, then run once in the Supabase SQL Editor on an EXISTING project.
-- (A new project gets it through setup.sql.) Safe to run more than once. No business data is changed.
--
-- A customer follows an out-of-stock product. When its stock goes from 0 to above 0 (restock, edit or a
-- cancelled order returning stock) every follower gets an in-app notification and the follow ends.
begin;
create table if not exists public.stock_alerts(
  user_id uuid not null references public.profiles(id) on delete cascade,
  product_id text not null references public.products(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key(user_id,product_id)
);
alter table public.stock_alerts enable row level security;
revoke all on public.stock_alerts from anon, authenticated;
grant select on public.stock_alerts to authenticated;
drop policy if exists stock_alerts_read on public.stock_alerts;
create policy stock_alerts_read on public.stock_alerts for select to authenticated using(user_id=auth.uid() and public.app_role()='customer');

create or replace function public.toggle_stock_alert(p_product_id text) returns boolean language plpgsql security definer set search_path=public,pg_temp as $$
declare p public.products%rowtype;
begin
 perform public.require_role(array['customer']);
 if exists(select 1 from public.stock_alerts where user_id=auth.uid() and product_id=p_product_id) then
  delete from public.stock_alerts where user_id=auth.uid() and product_id=p_product_id;return false;
 end if;
 select * into p from public.products where id=p_product_id and active;
 if not found then raise exception 'Product unavailable.';end if;
 if p.stock>0 then raise exception 'This product is in stock now.';end if;
 if(select count(*) from public.stock_alerts where user_id=auth.uid())>=50 then raise exception 'You can follow up to 50 products. Remove one first.';end if;
 insert into public.stock_alerts(user_id,product_id) values(auth.uid(),p_product_id);
 return true;
end$$;
revoke all on function public.toggle_stock_alert(text) from public,anon;
grant execute on function public.toggle_stock_alert(text) to authenticated;

create or replace function public.notify_back_in_stock() returns trigger language plpgsql security definer set search_path=public,pg_temp as $$
begin
 if old.stock=0 and new.stock>0 and new.active and new.price_confirmed then
  perform public.notify_user(a.user_id,'Back in stock: '||left(new.name,80),'You asked to hear when this part is available again. Stock is limited.','/products/'||new.id) from public.stock_alerts a where a.product_id=new.id;
  delete from public.stock_alerts where product_id=new.id;
 end if;
 return new;
end$$;
revoke all on function public.notify_back_in_stock() from public,anon,authenticated;
drop trigger if exists products_back_in_stock on public.products;
create trigger products_back_in_stock after update of stock on public.products for each row when(old.stock=0 and new.stock>0) execute function public.notify_back_in_stock();
commit;


-- GearLane vehicle fitment. Review, then run once in the Supabase SQL Editor on an EXISTING project.
-- (A new project gets it through setup.sql.) Safe to run more than once. No business data is changed.
--
-- Admins record which vehicles a product is listed for. Customers pick their vehicle and see which parts the
-- store has listed for it. Nothing is invented: a product with no rows simply has no fitment information, and the
-- storefront says so instead of guessing. The listing is the store's information, not a manufacturer guarantee.
begin;
create table if not exists public.product_fitment(
  id uuid primary key default gen_random_uuid(),
  product_id text not null references public.products(id) on delete cascade,
  make text not null check(char_length(trim(make)) between 2 and 40),
  model text not null check(char_length(trim(model)) between 1 and 60),
  year_from integer check(year_from between 1950 and 2100),
  year_to integer check(year_to between 1950 and 2100),
  check((year_from is null)=(year_to is null)),
  check(year_from is null or year_from<=year_to)
);
create index if not exists product_fitment_vehicle on public.product_fitment(lower(make),lower(model));
create index if not exists product_fitment_product on public.product_fitment(product_id);
alter table public.product_fitment enable row level security;
revoke all on public.product_fitment from anon, authenticated;
grant select on public.product_fitment to anon, authenticated;
drop policy if exists product_fitment_read on public.product_fitment;
create policy product_fitment_read on public.product_fitment for select using(exists(select 1 from public.products p where p.id=product_id and (p.active or public.app_role() in ('worker','admin'))));

-- Replaces the whole list for one product in a single step. p_rows: [{"make":"Proton","model":"X50","year_from":2020,"year_to":2024}, ...]
create or replace function public.admin_set_fitment(p_product_id text,p_rows jsonb) returns integer language plpgsql security definer set search_path=public,pg_temp as $$
declare r jsonb;n integer:=0;
begin
 perform public.require_role(array['admin']);
 if not exists(select 1 from public.products where id=p_product_id) then raise exception 'Product not found.';end if;
 if jsonb_typeof(p_rows)<>'array' or jsonb_array_length(p_rows)>60 then raise exception 'Provide up to 60 vehicles.';end if;
 delete from public.product_fitment where product_id=p_product_id;
 for r in select * from jsonb_array_elements(p_rows) loop
  insert into public.product_fitment(product_id,make,model,year_from,year_to)
  values(p_product_id,trim(r->>'make'),trim(r->>'model'),nullif(r->>'year_from','')::integer,nullif(r->>'year_to','')::integer);
  n:=n+1;
 end loop;
 perform public.audit('fitment_saved',p_product_id,jsonb_build_object('vehicles',n));
 return n;
end$$;
revoke all on function public.admin_set_fitment(text,jsonb) from public,anon;
grant execute on function public.admin_set_fitment(text,jsonb) to authenticated;
commit;


-- GearLane staff email alerts. Review, then run once in the Supabase SQL Editor on an EXISTING project.
-- (A new project gets it through setup.sql.) Safe to run more than once. No business data is changed.
--
-- Remembers when the store owner was last emailed about each customer conversation, so a customer who sends
-- ten messages in a minute causes one email, not ten. Only the server (service-role key) can read or write it.
begin;
create table if not exists public.staff_alerts(
  conversation_id uuid primary key references public.conversations(id) on delete cascade,
  last_sent_at timestamptz not null default now()
);
alter table public.staff_alerts enable row level security;
revoke all on public.staff_alerts from anon, authenticated;
commit;
