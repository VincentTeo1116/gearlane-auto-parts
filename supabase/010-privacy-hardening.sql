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
