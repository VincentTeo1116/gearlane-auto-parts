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
