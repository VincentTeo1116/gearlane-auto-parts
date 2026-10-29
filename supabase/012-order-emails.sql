-- GearLane order emails. Review, then run once in the Supabase SQL Editor on an EXISTING project.
-- (A new project gets it through setup.sql.) Safe to run more than once. No business data is changed.
--
-- Records which email has been sent for which order so a customer gets each message once, however many
-- times the browser asks. Only the server (service-role key) can read or write it; browsers cannot.
begin;
create table if not exists public.order_emails(
  order_id uuid not null references public.orders(id) on delete cascade,
  event text not null check(event in ('placed','payment_verified','payment_rejected','shipped','delivered','cancelled')),
  sent_at timestamptz not null default now(),
  primary key(order_id,event)
);
alter table public.order_emails enable row level security;
revoke all on public.order_emails from anon, authenticated;
commit;
