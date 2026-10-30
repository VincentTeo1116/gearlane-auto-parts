-- GearLane invoice details. Review, then run once in the Supabase SQL Editor on an EXISTING project.
-- (A new project gets it through setup.sql.) Safe to run more than once. No business data is changed.
--
-- Adds one admin-editable text block to the store settings: the seller's legal name, address and registration or SST
-- number exactly as they should appear on invoices. It is public business information (customers see it on their own
-- invoices), so it is added to the public settings view. Bank details stay hidden.
begin;
alter table public.store_settings add column if not exists invoice_details text not null default '' check(char_length(invoice_details)<=1000);

create or replace view public.public_store_settings as
  select id,store_name,shipping_cents,free_shipping_cents,checkout_enabled,contact_email,return_policy,invoice_details
  from public.store_settings;
revoke all on public.public_store_settings from anon, authenticated;
grant select on public.public_store_settings to anon, authenticated;

-- Same checks as before, plus invoice_details. A client that does not send the field leaves the saved text unchanged.
create or replace function public.admin_save_settings(p_settings jsonb) returns void language plpgsql security definer set search_path=public,pg_temp as $$
begin
 perform public.require_role(array['admin']);
 if coalesce(char_length(trim(p_settings->>'store_name')),0) not between 2 and 100 or coalesce(p_settings->>'shipping_cents','') !~ '^[0-9]{1,6}$' or coalesce(p_settings->>'free_shipping_cents','') !~ '^[0-9]{1,9}$' then raise exception 'Check store name and delivery prices.';end if;
 if (p_settings->>'checkout_enabled')::boolean and(coalesce(char_length(trim(p_settings->>'bank_name')),0)<2 or coalesce(char_length(trim(p_settings->>'bank_account_name')),0)<2 or coalesce(p_settings->>'bank_account_number','') !~ '^[0-9 -]{6,30}$') then raise exception 'Enter the actual business bank details before enabling checkout.';end if;
 if char_length(coalesce(p_settings->>'return_policy',''))>4000 or char_length(coalesce(p_settings->>'contact_email',''))>254 then raise exception 'Store details are too long.';end if;
 if char_length(coalesce(p_settings->>'invoice_details',''))>1000 then raise exception 'Invoice details are too long (1,000 characters at most).';end if;
 update public.store_settings set store_name=trim(p_settings->>'store_name'),bank_name=left(trim(p_settings->>'bank_name'),100),bank_account_name=left(trim(p_settings->>'bank_account_name'),120),bank_account_number=left(trim(p_settings->>'bank_account_number'),30),shipping_cents=(p_settings->>'shipping_cents')::integer,free_shipping_cents=(p_settings->>'free_shipping_cents')::integer,checkout_enabled=(p_settings->>'checkout_enabled')::boolean,contact_email=coalesce(p_settings->>'contact_email',''),return_policy=coalesce(p_settings->>'return_policy',''),invoice_details=case when p_settings ? 'invoice_details' then trim(p_settings->>'invoice_details') else invoice_details end where id=1;
 perform public.audit('store_settings_updated','1');
end $$;
revoke all on function public.admin_save_settings(jsonb) from public,anon;
grant execute on function public.admin_save_settings(jsonb) to authenticated;
commit;
