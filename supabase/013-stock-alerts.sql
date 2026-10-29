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
