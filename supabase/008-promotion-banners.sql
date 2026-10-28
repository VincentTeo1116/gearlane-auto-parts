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
