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
