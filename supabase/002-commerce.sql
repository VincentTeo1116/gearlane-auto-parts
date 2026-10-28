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
