-- GearLane product questions and answers. Review, then run once in the Supabase SQL Editor on an EXISTING project.
-- (A new project gets it through setup.sql.) Safe to run more than once. No business data is changed.
--
-- Signed-in customers ask a question on a product page. It is private (visible to the asker and staff) until staff
-- answer it; then question and answer are public on that product. Admins can hide an answered question.
-- Signed-out visitors can read answered questions, but not who asked (only a first name and initial is stored for display).
begin;
create table if not exists public.product_questions(
  id uuid primary key default gen_random_uuid(),
  product_id text not null references public.products(id) on delete cascade,
  asker_id uuid not null references public.profiles(id) on delete cascade,
  asker_name text not null,
  question text not null check(char_length(question) between 10 and 500),
  answer text check(answer is null or char_length(answer) between 2 and 2000),
  answered_by uuid references public.profiles(id),
  answered_at timestamptz,
  published boolean not null default true,
  created_at timestamptz not null default now(),
  check((answer is null)=(answered_at is null))
);
create index if not exists product_questions_product on public.product_questions(product_id,created_at desc);
create index if not exists product_questions_open on public.product_questions(created_at) where answered_at is null;
alter table public.product_questions enable row level security;
revoke all on public.product_questions from anon, authenticated;
grant select on public.product_questions to authenticated;
-- Signed-out visitors read the public columns only (never asker_id).
grant select(id,product_id,asker_name,question,answer,answered_at,created_at) on public.product_questions to anon;
drop policy if exists product_questions_read on public.product_questions;
create policy product_questions_read on public.product_questions for select using(
  (answered_at is not null and published and exists(select 1 from public.products p where p.id=product_id and p.active))
  or asker_id=auth.uid()
  or public.app_role() in ('worker','admin')
);

create or replace function public.ask_question(p_product_id text,p_question text) returns uuid language plpgsql security definer set search_path=public,pg_temp as $$
declare prod public.products%rowtype;who text;qid uuid;clean text;
begin
 perform public.require_role(array['customer']);
 clean:=regexp_replace(coalesce(p_question,''),'^[[:space:]]+|[[:space:]]+$','','g');
 if char_length(clean) not between 10 and 500 then raise exception 'Write a question of 10 to 500 characters.';end if;
 select * into prod from public.products where id=p_product_id and active;
 if not found then raise exception 'Product unavailable.';end if;
 if(select count(*) from public.product_questions where asker_id=auth.uid() and created_at>now()-interval '24 hours')>=5 then raise exception 'You can ask up to 5 questions a day. Please try again tomorrow.';end if;
 if(select count(*) from public.product_questions where asker_id=auth.uid() and product_id=p_product_id and answered_at is null)>=2 then raise exception 'You already have questions waiting on this product. We will answer them soon.';end if;
 select split_part(trim(full_name),' ',1)||case when position(' ' in trim(full_name))>0 then ' '||left(regexp_replace(trim(full_name),'^.*[[:space:]]',''),1)||'.' else '' end into who from public.profiles where id=auth.uid();
 insert into public.product_questions(product_id,asker_id,asker_name,question) values(p_product_id,auth.uid(),coalesce(who,'Customer'),clean) returning id into qid;
 perform public.notify_staff('New product question',coalesce(who,'A customer')||' asked about '||left(prod.name,80),'/workspace/questions');
 return qid;
end$$;

create or replace function public.answer_question(p_id uuid,p_answer text) returns void language plpgsql security definer set search_path=public,pg_temp as $$
declare q public.product_questions%rowtype;clean text;pname text;
begin
 perform public.require_role(array['worker','admin']);
 clean:=regexp_replace(coalesce(p_answer,''),'^[[:space:]]+|[[:space:]]+$','','g');
 if char_length(clean) not between 2 and 2000 then raise exception 'Write an answer of 2 to 2000 characters.';end if;
 select * into q from public.product_questions where id=p_id;
 if not found then raise exception 'Question not found.';end if;
 update public.product_questions set answer=clean,answered_by=auth.uid(),answered_at=now() where id=p_id;
 select name into pname from public.products where id=q.product_id;
 if q.answered_at is null then perform public.notify_user(q.asker_id,'Your question was answered',left(coalesce(pname,'Your product question'),100),'/products/'||q.product_id);end if;
 perform public.audit('question_answered',p_id::text,jsonb_build_object('product_id',q.product_id));
end$$;

create or replace function public.moderate_question(p_id uuid,p_published boolean) returns void language plpgsql security definer set search_path=public,pg_temp as $$
begin
 perform public.require_role(array['admin']);
 update public.product_questions set published=coalesce(p_published,true) where id=p_id;
 if not found then raise exception 'Question not found.';end if;
 perform public.audit(case when p_published then 'question_restored' else 'question_hidden' end,p_id::text);
end$$;

revoke all on function public.ask_question(text,text),public.answer_question(uuid,text),public.moderate_question(uuid,boolean) from public,anon;
grant execute on function public.ask_question(text,text),public.answer_question(uuid,text),public.moderate_question(uuid,boolean) to authenticated;
commit;
