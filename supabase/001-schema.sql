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
