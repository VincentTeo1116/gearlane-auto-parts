-- Apply after the original setup. Existing orders retain current bank-setting fallback.
begin;
alter table public.orders add column if not exists payment_instructions jsonb;
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
commit;
