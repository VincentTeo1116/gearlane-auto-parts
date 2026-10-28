-- Apply to the existing project after its original setup and migration 006.
-- Non-destructive: retain messages, memberships, permissions and notifications.
begin;
alter table public.messages add column if not exists client_message_id uuid;
create unique index if not exists messages_sender_client_unique
 on public.messages(sender_id,client_message_id) where client_message_id is not null;

create or replace function public.send_chat_message(
 p_conversation_id uuid,p_body text,p_product_id text,p_client_message_id uuid
) returns uuid language plpgsql security definer set search_path=public,pg_temp as $$
declare existing public.messages%rowtype; clean_body text; message_id uuid;
begin
 perform public.require_role(array['customer','worker','admin']);
 if not public.can_access_conversation(p_conversation_id) then
  raise exception 'Conversation unavailable.' using errcode='42501';
 end if;
 if p_client_message_id is null then raise exception 'A message delivery reference is required.';end if;
 clean_body:=regexp_replace(p_body,'^[[:space:]]+|[[:space:]]+$','','g');
 if coalesce(char_length(clean_body),0) not between 1 and 2000
    or regexp_replace(translate(coalesce(clean_body,''),U&'\200B\200C\200D\FEFF',''),'[[:space:]]','','g')='' then
  raise exception 'Write a message of 1 to 2000 characters.';
 end if;
 if regexp_replace(clean_body,E'[\n\r\t]','','g') ~ '[[:cntrl:]]' then
  raise exception 'The message contains unsupported control characters.';
 end if;
 -- Lock all sends by the same user to enforce the existing per-minute limit.
 perform pg_advisory_xact_lock(hashtext('chat:'||auth.uid()::text));
 select * into existing from public.messages where sender_id=auth.uid() and client_message_id=p_client_message_id;
 if found then
  if existing.conversation_id is distinct from p_conversation_id
     or existing.body is distinct from clean_body
     or existing.product_id is distinct from p_product_id then
   raise exception 'This delivery reference belongs to a different message.';
  end if;
  return existing.id;
 end if;
 -- Existing function checks active membership, closure, product and rate limits.
 message_id:=public.send_message(p_conversation_id,clean_body,p_product_id);
 update public.messages set client_message_id=p_client_message_id where id=message_id;
 return message_id;
end $$;
revoke all on function public.send_chat_message(uuid,text,text,uuid) from public,anon;
grant execute on function public.send_chat_message(uuid,text,text,uuid) to authenticated;
commit;
