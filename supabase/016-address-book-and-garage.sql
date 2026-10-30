-- GearLane address book and "my vehicle" garage. Review, then run once in the Supabase SQL Editor on an EXISTING project.
-- (A new project gets it through setup.sql.) Safe to run more than once. No business data is changed.
--
-- A customer can keep up to 10 delivery addresses (one default) and up to 8 vehicles (one active).
-- Only the owner can read their rows, and every change goes through a checked function, so nobody can
-- write to another customer's address book or garage.
begin;

-- ---------- Address book ----------
create table if not exists public.saved_addresses(
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  label text not null default '' check(char_length(label)<=40),
  name text not null check(char_length(name) between 2 and 100),
  phone text not null check(phone ~ '^\+?[0-9 ()-]{8,20}$'),
  line1 text not null check(char_length(line1) between 8 and 300),
  city text not null check(char_length(city) between 2 and 80),
  postcode text not null check(postcode ~ '^[0-9]{5}$'),
  state text not null check(char_length(state) between 2 and 80),
  is_default boolean not null default false,
  created_at timestamptz not null default now()
);
create unique index if not exists one_default_address on public.saved_addresses(user_id) where is_default;
create index if not exists saved_addresses_user on public.saved_addresses(user_id);
alter table public.saved_addresses enable row level security;
revoke all on public.saved_addresses from anon, authenticated;
grant select on public.saved_addresses to authenticated;
drop policy if exists saved_addresses_read on public.saved_addresses;
create policy saved_addresses_read on public.saved_addresses for select to authenticated using(user_id=auth.uid() and public.app_role()='customer');

-- p_address: {"label":"Home","name":"..","phone":"..","line1":"..","city":"..","postcode":"47300","state":"Selangor"}
create or replace function public.save_address(p_address jsonb,p_id uuid default null,p_make_default boolean default false) returns uuid language plpgsql security definer set search_path=public,pg_temp as $$
declare aid uuid;make_default boolean:=coalesce(p_make_default,false);
begin
 perform public.require_role(array['customer']);
 if jsonb_typeof(p_address)<>'object' then raise exception 'Check the address details.';end if;
 if p_id is null then
  if(select count(*) from public.saved_addresses where user_id=auth.uid())>=10 then raise exception 'You can keep up to 10 addresses. Remove one first.';end if;
  if not exists(select 1 from public.saved_addresses where user_id=auth.uid()) then make_default:=true;end if;
 elsif not exists(select 1 from public.saved_addresses where id=p_id and user_id=auth.uid()) then
  raise exception 'Address not found.';
 end if;
 if make_default then update public.saved_addresses set is_default=false where user_id=auth.uid() and is_default;end if;
 if p_id is null then
  insert into public.saved_addresses(user_id,label,name,phone,line1,city,postcode,state,is_default)
  values(auth.uid(),trim(coalesce(p_address->>'label','')),trim(coalesce(p_address->>'name','')),trim(coalesce(p_address->>'phone','')),trim(coalesce(p_address->>'line1','')),trim(coalesce(p_address->>'city','')),trim(coalesce(p_address->>'postcode','')),trim(coalesce(p_address->>'state','')),make_default)
  returning id into aid;
 else
  update public.saved_addresses set label=trim(coalesce(p_address->>'label','')),name=trim(coalesce(p_address->>'name','')),phone=trim(coalesce(p_address->>'phone','')),line1=trim(coalesce(p_address->>'line1','')),city=trim(coalesce(p_address->>'city','')),postcode=trim(coalesce(p_address->>'postcode','')),state=trim(coalesce(p_address->>'state','')),is_default=case when make_default then true else is_default end
  where id=p_id and user_id=auth.uid() returning id into aid;
 end if;
 return aid;
end$$;

create or replace function public.set_default_address(p_id uuid) returns void language plpgsql security definer set search_path=public,pg_temp as $$
begin
 perform public.require_role(array['customer']);
 if not exists(select 1 from public.saved_addresses where id=p_id and user_id=auth.uid()) then raise exception 'Address not found.';end if;
 update public.saved_addresses set is_default=false where user_id=auth.uid() and is_default and id<>p_id;
 update public.saved_addresses set is_default=true where id=p_id and user_id=auth.uid();
end$$;

create or replace function public.delete_address(p_id uuid) returns void language plpgsql security definer set search_path=public,pg_temp as $$
declare was_default boolean;
begin
 perform public.require_role(array['customer']);
 delete from public.saved_addresses where id=p_id and user_id=auth.uid() returning is_default into was_default;
 if not found then raise exception 'Address not found.';end if;
 if was_default then
  update public.saved_addresses set is_default=true where id=(select id from public.saved_addresses where user_id=auth.uid() order by created_at desc limit 1);
 end if;
end$$;

-- ---------- Garage ----------
create table if not exists public.garage_vehicles(
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  make text not null check(char_length(make) between 2 and 40),
  model text not null check(char_length(model) between 1 and 60),
  year integer check(year is null or year between 1950 and 2100),
  nickname text not null default '' check(char_length(nickname)<=40),
  is_active boolean not null default false,
  created_at timestamptz not null default now()
);
create unique index if not exists one_active_vehicle on public.garage_vehicles(user_id) where is_active;
create unique index if not exists garage_unique_vehicle on public.garage_vehicles(user_id,lower(make),lower(model),coalesce(year,0));
alter table public.garage_vehicles enable row level security;
revoke all on public.garage_vehicles from anon, authenticated;
grant select on public.garage_vehicles to authenticated;
drop policy if exists garage_vehicles_read on public.garage_vehicles;
create policy garage_vehicles_read on public.garage_vehicles for select to authenticated using(user_id=auth.uid() and public.app_role()='customer');

-- Adds a vehicle (or finds the same one again) and, by default, makes it the active one.
create or replace function public.add_garage_vehicle(p_make text,p_model text,p_year integer default null,p_nickname text default '',p_activate boolean default true) returns uuid language plpgsql security definer set search_path=public,pg_temp as $$
declare vid uuid;
begin
 perform public.require_role(array['customer']);
 select id into vid from public.garage_vehicles where user_id=auth.uid() and lower(make)=lower(trim(p_make)) and lower(model)=lower(trim(p_model)) and coalesce(year,0)=coalesce(p_year,0);
 if vid is null then
  if(select count(*) from public.garage_vehicles where user_id=auth.uid())>=8 then raise exception 'Your garage holds up to 8 vehicles. Remove one first.';end if;
  if coalesce(p_activate,true) then update public.garage_vehicles set is_active=false where user_id=auth.uid() and is_active;end if;
  insert into public.garage_vehicles(user_id,make,model,year,nickname,is_active) values(auth.uid(),trim(p_make),trim(p_model),p_year,trim(coalesce(p_nickname,'')),coalesce(p_activate,true)) returning id into vid;
 elsif coalesce(p_activate,true) then
  perform public.set_active_vehicle(vid);
 end if;
 return vid;
end$$;

-- p_id null switches the active vehicle off (the store then shows every part).
create or replace function public.set_active_vehicle(p_id uuid default null) returns void language plpgsql security definer set search_path=public,pg_temp as $$
begin
 perform public.require_role(array['customer']);
 if p_id is not null and not exists(select 1 from public.garage_vehicles where id=p_id and user_id=auth.uid()) then raise exception 'Vehicle not found.';end if;
 update public.garage_vehicles set is_active=false where user_id=auth.uid() and is_active and id is distinct from p_id;
 if p_id is not null then update public.garage_vehicles set is_active=true where id=p_id and user_id=auth.uid();end if;
end$$;

create or replace function public.remove_garage_vehicle(p_id uuid) returns void language plpgsql security definer set search_path=public,pg_temp as $$
begin
 perform public.require_role(array['customer']);
 delete from public.garage_vehicles where id=p_id and user_id=auth.uid();
 if not found then raise exception 'Vehicle not found.';end if;
end$$;

revoke all on function public.save_address(jsonb,uuid,boolean),public.set_default_address(uuid),public.delete_address(uuid),public.add_garage_vehicle(text,text,integer,text,boolean),public.set_active_vehicle(uuid),public.remove_garage_vehicle(uuid) from public,anon;
grant execute on function public.save_address(jsonb,uuid,boolean),public.set_default_address(uuid),public.delete_address(uuid),public.add_garage_vehicle(text,text,integer,text,boolean),public.set_active_vehicle(uuid),public.remove_garage_vehicle(uuid) to authenticated;
commit;
