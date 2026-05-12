create extension if not exists pgcrypto;

alter table if exists public.ufficio_user_entitlements
  add column if not exists source text not null default 'system',
  add column if not exists current_period_start timestamptz,
  add column if not exists current_period_end timestamptz,
  add column if not exists trial_end timestamptz,
  add column if not exists cancelled_at timestamptz,
  add column if not exists revoked_at timestamptz,
  add column if not exists stripe_customer_id text,
  add column if not exists stripe_subscription_id text,
  add column if not exists stripe_price_id text,
  add column if not exists metadata jsonb not null default '{}'::jsonb,
  add column if not exists created_at timestamptz not null default now(),
  add column if not exists updated_at timestamptz not null default now();

create unique index if not exists idx_ufficio_user_entitlements_user_id_v2
  on public.ufficio_user_entitlements(user_id);

create index if not exists idx_ufficio_user_entitlements_status_period
  on public.ufficio_user_entitlements(status, current_period_end desc);

create index if not exists idx_ufficio_user_entitlements_stripe_customer
  on public.ufficio_user_entitlements(stripe_customer_id)
  where stripe_customer_id is not null;

create index if not exists idx_ufficio_user_entitlements_stripe_subscription
  on public.ufficio_user_entitlements(stripe_subscription_id)
  where stripe_subscription_id is not null;

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'ufficio_user_entitlements_status_check_v2'
      and conrelid = 'public.ufficio_user_entitlements'::regclass
  ) then
    alter table public.ufficio_user_entitlements
      add constraint ufficio_user_entitlements_status_check_v2
      check (status in ('active', 'trialing', 'past_due', 'cancelled', 'expired', 'revoked'));
  end if;
end $$;

alter table if exists public.ufficio_premium_events
  add column if not exists plan text,
  add column if not exists source text,
  add column if not exists stripe_event_id text,
  add column if not exists metadata jsonb not null default '{}'::jsonb,
  add column if not exists created_at timestamptz not null default now();

alter table if exists public.ufficio_premium_events
  alter column user_id drop not null;

create unique index if not exists idx_ufficio_premium_events_stripe_event_id
  on public.ufficio_premium_events(stripe_event_id)
  where stripe_event_id is not null;

create index if not exists idx_ufficio_premium_events_user_created
  on public.ufficio_premium_events(user_id, created_at desc);

alter table if exists public.ufficio_plan_products
  add column if not exists stripe_price_id text;

create index if not exists idx_ufficio_plan_products_active_sort
  on public.ufficio_plan_products(is_active, sort_order);

alter table if exists public.ufficio_user_content_unlocks
  add column if not exists stripe_payment_intent_id text,
  add column if not exists stripe_checkout_session_id text,
  add column if not exists purchased_at timestamptz,
  add column if not exists metadata jsonb not null default '{}'::jsonb,
  add column if not exists created_at timestamptz not null default now(),
  add column if not exists updated_at timestamptz not null default now();

create index if not exists idx_ufficio_user_content_unlocks_user_lookup
  on public.ufficio_user_content_unlocks(user_id, category_slug, procedure_slug, status);

create index if not exists idx_ufficio_user_content_unlocks_checkout
  on public.ufficio_user_content_unlocks(stripe_checkout_session_id)
  where stripe_checkout_session_id is not null;

create index if not exists idx_ufficio_user_content_unlocks_payment_intent
  on public.ufficio_user_content_unlocks(stripe_payment_intent_id)
  where stripe_payment_intent_id is not null;

alter table if exists public.ufficio_usage_counters
  add column if not exists reminders_used int not null default 0,
  add column if not exists utility_comparisons_used int not null default 0,
  add column if not exists bill_analyses_used int not null default 0,
  add column if not exists household_members_used int not null default 0,
  add column if not exists proof_cases_used int not null default 0;

create index if not exists idx_ufficio_usage_counters_user_period
  on public.ufficio_usage_counters(user_id, period_key);

create or replace function public.increment_ufficio_usage_counter(
  counter_key text,
  delta_amount int default 1,
  target_user_id uuid default auth.uid()
)
returns public.ufficio_usage_counters
language plpgsql
security definer
set search_path = public
as $$
declare
  period_key_value text := to_char(date_trunc('month', now()), 'YYYY-MM');
  result_row public.ufficio_usage_counters;
begin
  if target_user_id is null then
    raise exception 'target_user_id is required';
  end if;

  if auth.uid() is distinct from target_user_id and not public.is_ufficio_admin() then
    raise exception 'not allowed';
  end if;

  insert into public.ufficio_usage_counters (
    user_id,
    period_key
  )
  values (
    target_user_id,
    period_key_value
  )
  on conflict (user_id, period_key) do nothing;

  update public.ufficio_usage_counters
  set
    generated_packs_used = generated_packs_used + case when counter_key = 'generated_packs_used' then delta_amount else 0 end,
    saved_requests_used = saved_requests_used + case when counter_key = 'saved_requests_used' then delta_amount else 0 end,
    reminders_used = reminders_used + case when counter_key = 'reminders_used' then delta_amount else 0 end,
    documents_used = documents_used + case when counter_key = 'documents_used' then delta_amount else 0 end,
    contacts_used = contacts_used + case when counter_key = 'contacts_used' then delta_amount else 0 end,
    cost_items_used = cost_items_used + case when counter_key = 'cost_items_used' then delta_amount else 0 end,
    utility_comparisons_used = utility_comparisons_used + case when counter_key = 'utility_comparisons_used' then delta_amount else 0 end,
    bill_analyses_used = bill_analyses_used + case when counter_key = 'bill_analyses_used' then delta_amount else 0 end,
    household_members_used = household_members_used + case when counter_key = 'household_members_used' then delta_amount else 0 end,
    proof_cases_used = proof_cases_used + case when counter_key = 'proof_cases_used' then delta_amount else 0 end,
    consultancy_requests_used = consultancy_requests_used + case when counter_key = 'consultancy_requests_used' then delta_amount else 0 end,
    updated_at = now()
  where user_id = target_user_id
    and period_key = period_key_value
  returning * into result_row;

  return result_row;
end;
$$;

comment on function public.increment_ufficio_usage_counter(text, int, uuid) is
  'Server-backed usage counter increment for authenticated users and admins. Keeps premium/free limits out of client authority.';
