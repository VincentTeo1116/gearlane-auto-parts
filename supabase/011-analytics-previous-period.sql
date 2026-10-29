-- GearLane dashboard comparison. Review, then run once in the Supabase SQL Editor on an EXISTING project.
-- (A new project gets it through setup.sql.) Safe to run more than once. No business data is changed.
--
-- Returns the same headline figures as dashboard_stats, for the period of equal length that ENDS where
-- the selected period BEGINS (for example, days 31-60 ago when the dashboard shows the last 30 days).
begin;
create or replace function public.dashboard_previous_period(p_days integer default 30) returns jsonb language plpgsql stable security definer set search_path=public,pg_temp as $$
declare since_time timestamptz;until_time timestamptz;
begin
 perform public.require_role(array['admin']);
 if p_days not in(7,30,90) then raise exception 'Choose 7, 30 or 90 days.';end if;
 until_time:=now()-make_interval(days=>p_days);since_time:=until_time-make_interval(days=>p_days);
 return jsonb_build_object(
  'paid_sales_cents',coalesce((select sum(total_cents) from public.orders where created_at>=since_time and created_at<until_time and payment_status='verified'),0),
  'paid_orders',(select count(*) from public.orders where created_at>=since_time and created_at<until_time and payment_status='verified'),
  'active_customers',(select count(distinct user_id) from public.activity_events where created_at>=since_time and created_at<until_time)
 );
end $$;
revoke all on function public.dashboard_previous_period(integer) from public,anon;
grant execute on function public.dashboard_previous_period(integer) to authenticated;
commit;
