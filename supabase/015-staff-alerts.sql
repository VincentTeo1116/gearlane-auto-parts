-- GearLane staff email alerts. Review, then run once in the Supabase SQL Editor on an EXISTING project.
-- (A new project gets it through setup.sql.) Safe to run more than once. No business data is changed.
--
-- Remembers when the store owner was last emailed about each customer conversation, so a customer who sends
-- ten messages in a minute causes one email, not ten. Only the server (service-role key) can read or write it.
begin;
create table if not exists public.staff_alerts(
  conversation_id uuid primary key references public.conversations(id) on delete cascade,
  last_sent_at timestamptz not null default now()
);
alter table public.staff_alerts enable row level security;
revoke all on public.staff_alerts from anon, authenticated;
commit;
