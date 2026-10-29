-- Apply after existing setup, 007 and 008. Preserves all existing chats/messages.
begin;
-- Separate enquiries may remain open independently; creation is serialised/rate-limited.
drop index if exists public.one_open_support_per_customer;
create index if not exists support_customer_history on public.conversations(customer_id,created_at desc,id desc) where kind='support';
create index if not exists chat_inbox_latest on public.messages(conversation_id,created_at desc,id desc);

create or replace function public.chat_inbox() returns jsonb language plpgsql stable security definer set search_path=public,pg_temp as $$
declare result jsonb;
begin
 perform public.require_role(array['customer','worker','admin']);
 select coalesce(jsonb_agg(row order by sort_at desc,id desc),'[]'::jsonb) into result from(
  select c.id,coalesce(last.created_at,c.created_at) sort_at,to_jsonb(c)||jsonb_build_object(
   'customer_name',(select p.full_name from public.profiles p where p.id=c.customer_id),
   'members',coalesce((select jsonb_agg(m) from public.conversation_members m where m.conversation_id=c.id),'[]'::jsonb),
   'last_message',case when last.id is null then null else jsonb_build_object('id',last.id,'body',left(last.body,240),'created_at',last.created_at,'sender_id',last.sender_id,'product_name',last.product_name) end,
   'unread_count',(select count(*) from public.messages unread where unread.conversation_id=c.id and unread.sender_id<>auth.uid() and unread.created_at>coalesce((select cm.last_read_at from public.conversation_members cm where cm.conversation_id=c.id and cm.user_id=auth.uid()),'-infinity'::timestamptz))
  ) row from public.conversations c
  left join lateral(select m.* from public.messages m where m.conversation_id=c.id order by m.created_at desc,m.id desc limit 1) last on true
  where public.can_access_conversation(c.id)
  order by coalesce(last.created_at,c.created_at) desc,c.id desc limit 100
 ) inbox;
 return result;
end $$;

create or replace function public.start_support_enquiry(p_title text,p_request_id uuid) returns uuid language plpgsql security definer set search_path=public,pg_temp as $$
declare existing public.conversations%rowtype;subject text:=trim(p_title);
begin
 perform public.require_role(array['customer']);
 if p_request_id is null or subject is null or char_length(subject) not between 3 and 120 or subject ~ '[[:cntrl:]]' or subject !~ '[^[:space:]]' then raise exception 'Enter an enquiry topic from 3 to 120 characters.';end if;
 perform pg_advisory_xact_lock(hashtext(auth.uid()::text||'support'));
 select * into existing from public.conversations where id=p_request_id;
 if found then
  if existing.kind<>'support' or existing.customer_id<>auth.uid() or existing.title<>subject then raise exception 'This enquiry reference is unavailable.' using errcode='42501';end if;
  return existing.id;
 end if;
 if (select count(*) from public.conversations where customer_id=auth.uid() and kind='support' and created_at>now()-interval '1 minute')>=3
 or (select count(*) from public.conversations where customer_id=auth.uid() and kind='support' and created_at>now()-interval '1 hour')>=12 then
  raise exception 'Too many new enquiries. Continue an existing chat or try again later.';
 end if;
 insert into public.conversations(id,kind,customer_id,title,created_by) values(p_request_id,'support',auth.uid(),subject,auth.uid());
 insert into public.conversation_members(conversation_id,user_id) values(p_request_id,auth.uid());
 return p_request_id;
end $$;

-- Product enquiries still resume an open support chat, choosing the latest one.
create or replace function public.start_conversation(p_kind text,p_recipient_id uuid default null) returns uuid language plpgsql security definer set search_path=public,pg_temp as $$
declare cid uuid;
begin
 perform public.require_role(array['customer','worker','admin']);
 if p_kind='support' then
  perform public.require_role(array['customer']);perform pg_advisory_xact_lock(hashtext(auth.uid()::text||'support'));
  select id into cid from public.conversations where kind='support' and customer_id=auth.uid() and closed_at is null order by created_at desc,id desc limit 1;
  if cid is not null then return cid;end if;
  insert into public.conversations(kind,customer_id,title,created_by) values('support',auth.uid(),'Customer support',auth.uid()) returning id into cid;
  insert into public.conversation_members(conversation_id,user_id) values(cid,auth.uid());
 elsif p_kind='internal' then
  perform public.require_role(array['worker','admin']);
  if p_recipient_id is null or p_recipient_id=auth.uid() or not exists(select 1 from public.profiles where id=p_recipient_id and is_active and role in('worker','admin')) then raise exception 'Choose another active staff member.';end if;
  insert into public.conversations(kind,title,created_by) values('internal','Staff conversation',auth.uid()) returning id into cid;
  insert into public.conversation_members(conversation_id,user_id) values(cid,auth.uid()),(cid,p_recipient_id);
 else raise exception 'Unknown conversation type.';end if;
 return cid;
end $$;
revoke all on function public.chat_inbox(),public.start_support_enquiry(text,uuid),public.start_conversation(text,uuid) from public,anon;
grant execute on function public.chat_inbox(),public.start_support_enquiry(text,uuid),public.start_conversation(text,uuid) to authenticated;
commit;
