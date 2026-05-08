create extension if not exists pgcrypto;

create or replace function public.current_ufficio_admin_role()
returns text
language sql
security definer
stable
set search_path = public
as $$
  select role
  from public.ufficio_admin_users
  where user_id = auth.uid()
    and is_active = true
  limit 1;
$$;

create table if not exists public.ufficio_plan_products (
  id uuid primary key default gen_random_uuid(),
  product_key text not null unique,
  title jsonb not null default '{}'::jsonb,
  description jsonb not null default '{}'::jsonb,
  plan_type text not null,
  billing_interval text,
  amount_cents int,
  currency text not null default 'EUR',
  is_active boolean not null default true,
  sort_order int not null default 0,
  features jsonb not null default '{}'::jsonb,
  limits jsonb not null default '{}'::jsonb,
  provider_metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint ufficio_plan_products_plan_type_check
    check (plan_type in ('free', 'subscription', 'one_time', 'admin_only')),
  constraint ufficio_plan_products_billing_interval_check
    check (
      billing_interval is null
      or billing_interval in ('none', 'month', 'year', 'one_time')
    )
);

drop trigger if exists ufficio_plan_products_updated_at on public.ufficio_plan_products;
create trigger ufficio_plan_products_updated_at
before update on public.ufficio_plan_products
for each row execute function public.ufficio_set_updated_at();

alter table public.ufficio_user_entitlements
  add column if not exists premium_access boolean not null default false,
  add column if not exists current_period_start timestamptz,
  add column if not exists trial_end timestamptz,
  add column if not exists cancelled_at timestamptz,
  add column if not exists revoked_at timestamptz,
  add column if not exists provider text,
  add column if not exists provider_customer_id text,
  add column if not exists provider_subscription_id text,
  add column if not exists provider_product_id text,
  add column if not exists provider_price_id text;

create table if not exists public.ufficio_usage_counters (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  period_key text not null,
  generated_packs_used int not null default 0,
  saved_requests_used int not null default 0,
  documents_used int not null default 0,
  contacts_used int not null default 0,
  cost_items_used int not null default 0,
  consultancy_requests_used int not null default 0,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(user_id, period_key)
);

drop trigger if exists ufficio_usage_counters_updated_at on public.ufficio_usage_counters;
create trigger ufficio_usage_counters_updated_at
before update on public.ufficio_usage_counters
for each row execute function public.ufficio_set_updated_at();

create table if not exists public.ufficio_payment_events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete set null,
  provider text not null,
  event_id text,
  event_type text not null,
  product_key text,
  product_type text,
  category_slug text,
  procedure_slug text,
  amount_cents int,
  currency text default 'EUR',
  status text,
  raw_payload jsonb not null default '{}'::jsonb,
  processed_at timestamptz,
  created_at timestamptz not null default now()
);

create unique index if not exists idx_ufficio_payment_events_provider_event
  on public.ufficio_payment_events(provider, event_id)
  where event_id is not null;

create table if not exists public.ufficio_consultancy_payments (
  id uuid primary key default gen_random_uuid(),
  consultancy_request_id uuid references public.ufficio_consultancy_requests(id) on delete cascade,
  user_id uuid references auth.users(id) on delete set null,
  product_key text not null default 'consultancy_one_shot',
  status text not null default 'required',
  amount_cents int,
  currency text default 'EUR',
  provider text,
  provider_checkout_id text,
  provider_payment_id text,
  paid_at timestamptz,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint ufficio_consultancy_payments_status_check
    check (status in ('not_required', 'required', 'pending', 'paid', 'failed', 'waived', 'refunded'))
);

drop trigger if exists ufficio_consultancy_payments_updated_at on public.ufficio_consultancy_payments;
create trigger ufficio_consultancy_payments_updated_at
before update on public.ufficio_consultancy_payments
for each row execute function public.ufficio_set_updated_at();

create table if not exists public.ufficio_user_content_unlocks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  category_slug text not null,
  procedure_slug text not null,
  unlock_type text not null default 'single_purchase',
  status text not null default 'active',
  product_key text not null default 'subcategory_unlock',
  amount_cents int,
  currency text not null default 'EUR',
  provider text,
  provider_payment_id text,
  provider_checkout_id text,
  purchased_at timestamptz,
  expires_at timestamptz,
  revoked_at timestamptz,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(user_id, category_slug, procedure_slug),
  constraint ufficio_user_content_unlocks_type_check
    check (unlock_type in ('single_purchase', 'admin_grant', 'promotional', 'migration')),
  constraint ufficio_user_content_unlocks_status_check
    check (status in ('active', 'refunded', 'revoked', 'expired'))
);

drop trigger if exists ufficio_user_content_unlocks_updated_at on public.ufficio_user_content_unlocks;
create trigger ufficio_user_content_unlocks_updated_at
before update on public.ufficio_user_content_unlocks
for each row execute function public.ufficio_set_updated_at();

alter table public.ufficio_cms_categories
  add column if not exists monetization_type text not null default 'free',
  add column if not exists allow_single_unlock boolean not null default true,
  add column if not exists single_unlock_price_cents int,
  add column if not exists single_unlock_currency text not null default 'EUR',
  add column if not exists premium_reason jsonb not null default '{}'::jsonb,
  add column if not exists premium_teaser jsonb not null default '{}'::jsonb;

alter table public.ufficio_cms_procedures
  add column if not exists monetization_type text not null default 'free',
  add column if not exists allow_single_unlock boolean not null default true,
  add column if not exists single_unlock_price_cents int,
  add column if not exists single_unlock_currency text not null default 'EUR',
  add column if not exists premium_reason jsonb not null default '{}'::jsonb,
  add column if not exists premium_teaser jsonb not null default '{}'::jsonb;

alter table public.ufficio_cms_content_blocks
  add column if not exists monetization_type text not null default 'free',
  add column if not exists allow_single_unlock boolean not null default true,
  add column if not exists single_unlock_price_cents int,
  add column if not exists single_unlock_currency text not null default 'EUR',
  add column if not exists premium_reason jsonb not null default '{}'::jsonb,
  add column if not exists premium_teaser jsonb not null default '{}'::jsonb;

create or replace function public.user_has_premium(target_user_id uuid default auth.uid())
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select exists (
    select 1
    from public.ufficio_user_entitlements
    where user_id = target_user_id
      and premium_access = true
      and status in ('active', 'trialing')
      and revoked_at is null
      and (current_period_end is null or current_period_end >= now())
  );
$$;

create or replace function public.user_has_content_unlock(
  target_category_slug text,
  target_procedure_slug text,
  target_user_id uuid default auth.uid()
)
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select public.user_has_premium(target_user_id)
    or exists (
      select 1
      from public.ufficio_user_content_unlocks
      where user_id = target_user_id
        and category_slug = target_category_slug
        and procedure_slug = target_procedure_slug
        and status = 'active'
        and revoked_at is null
        and (expires_at is null or expires_at >= now())
    );
$$;

create or replace function public.get_my_entitlement()
returns setof public.ufficio_user_entitlements
language sql
security definer
stable
set search_path = public
as $$
  select *
  from public.ufficio_user_entitlements
  where user_id = auth.uid()
  limit 1;
$$;

alter table public.ufficio_plan_products enable row level security;
alter table public.ufficio_usage_counters enable row level security;
alter table public.ufficio_payment_events enable row level security;
alter table public.ufficio_consultancy_payments enable row level security;
alter table public.ufficio_user_content_unlocks enable row level security;

drop policy if exists "plan_products_public_read" on public.ufficio_plan_products;
create policy "plan_products_public_read"
on public.ufficio_plan_products for select to anon, authenticated
using (is_active = true);

drop policy if exists "plan_products_admin_write" on public.ufficio_plan_products;
create policy "plan_products_admin_write"
on public.ufficio_plan_products for all to authenticated
using (public.is_ufficio_admin())
with check (public.is_ufficio_admin());

drop policy if exists "usage_counters_read_own" on public.ufficio_usage_counters;
create policy "usage_counters_read_own"
on public.ufficio_usage_counters for select to authenticated
using (user_id = auth.uid());

drop policy if exists "usage_counters_admin_all" on public.ufficio_usage_counters;
create policy "usage_counters_admin_all"
on public.ufficio_usage_counters for all to authenticated
using (public.is_ufficio_admin())
with check (public.is_ufficio_admin());

drop policy if exists "payment_events_admin_all" on public.ufficio_payment_events;
create policy "payment_events_admin_all"
on public.ufficio_payment_events for all to authenticated
using (public.is_ufficio_admin())
with check (public.is_ufficio_admin());

drop policy if exists "consultancy_payments_read_own" on public.ufficio_consultancy_payments;
create policy "consultancy_payments_read_own"
on public.ufficio_consultancy_payments for select to authenticated
using (user_id = auth.uid());

drop policy if exists "consultancy_payments_admin_all" on public.ufficio_consultancy_payments;
create policy "consultancy_payments_admin_all"
on public.ufficio_consultancy_payments for all to authenticated
using (public.is_ufficio_admin())
with check (public.is_ufficio_admin());

drop policy if exists "content_unlocks_read_own" on public.ufficio_user_content_unlocks;
create policy "content_unlocks_read_own"
on public.ufficio_user_content_unlocks for select to authenticated
using (user_id = auth.uid());

drop policy if exists "content_unlocks_admin_all" on public.ufficio_user_content_unlocks;
create policy "content_unlocks_admin_all"
on public.ufficio_user_content_unlocks for all to authenticated
using (public.is_ufficio_admin())
with check (public.is_ufficio_admin());

create index if not exists idx_ufficio_usage_counters_user_period
  on public.ufficio_usage_counters(user_id, period_key);
create index if not exists idx_ufficio_content_unlocks_user
  on public.ufficio_user_content_unlocks(user_id);
create index if not exists idx_ufficio_content_unlocks_target
  on public.ufficio_user_content_unlocks(category_slug, procedure_slug);
create index if not exists idx_ufficio_content_unlocks_status
  on public.ufficio_user_content_unlocks(status);

insert into public.ufficio_plan_products (
  product_key,
  title,
  description,
  plan_type,
  billing_interval,
  amount_cents,
  currency,
  is_active,
  sort_order,
  features,
  limits
)
values
  (
    'free',
    '{"en":"Free","it":"Gratis"}'::jsonb,
    '{"en":"Basic access with limits.","it":"Accesso base con limiti."}'::jsonb,
    'free',
    'none',
    0,
    'EUR',
    true,
    0,
    '{"premium_sections":false,"priority_requests":false}'::jsonb,
    '{"generated_packs_per_month":3,"saved_requests_limit":5,"documents_limit":5,"contacts_limit":5,"cost_items_limit":5,"consultancy_included_per_month":0}'::jsonb
  ),
  (
    'premium_monthly',
    '{"en":"Premium Monthly","it":"Premium mensile"}'::jsonb,
    '{"en":"Full premium access each month.","it":"Accesso premium completo ogni mese."}'::jsonb,
    'subscription',
    'month',
    999,
    'EUR',
    true,
    1,
    '{"premium_sections":true,"priority_requests":true}'::jsonb,
    '{"generated_packs_per_month":100,"saved_requests_limit":500,"documents_limit":500,"contacts_limit":500,"cost_items_limit":500,"consultancy_included_per_month":2}'::jsonb
  ),
  (
    'premium_yearly',
    '{"en":"Premium Yearly","it":"Premium annuale"}'::jsonb,
    '{"en":"Full premium access for one year.","it":"Accesso premium completo per un anno."}'::jsonb,
    'subscription',
    'year',
    7999,
    'EUR',
    true,
    2,
    '{"premium_sections":true,"priority_requests":true}'::jsonb,
    '{"generated_packs_per_month":100,"saved_requests_limit":500,"documents_limit":500,"contacts_limit":500,"cost_items_limit":500,"consultancy_included_per_month":2}'::jsonb
  ),
  (
    'consultancy_one_shot',
    '{"en":"One-shot Consultancy","it":"Consulenza una tantum"}'::jsonb,
    '{"en":"Pay once for one private consultancy request.","it":"Paga una volta per una richiesta di consulenza privata."}'::jsonb,
    'one_time',
    'one_time',
    1499,
    'EUR',
    true,
    3,
    '{"private_consultancy":true}'::jsonb,
    '{"procedure_count":1}'::jsonb
  ),
  (
    'subcategory_unlock',
    '{"en":"Single Guide Unlock","it":"Sblocco guida singola"}'::jsonb,
    '{"en":"Unlock one premium guide without subscribing.","it":"Sblocca una guida premium senza abbonarti."}'::jsonb,
    'one_time',
    'one_time',
    299,
    'EUR',
    true,
    4,
    '{"unlocks_single_procedure":true}'::jsonb,
    '{"procedure_count":1}'::jsonb
  ),
  (
    'admin_grant',
    '{"en":"Admin Grant","it":"Concessione admin"}'::jsonb,
    '{"en":"Manual premium access by admin.","it":"Accesso premium manuale da admin."}'::jsonb,
    'admin_only',
    'none',
    0,
    'EUR',
    true,
    5,
    '{"premium_sections":true,"priority_requests":true}'::jsonb,
    '{"generated_packs_per_month":100,"saved_requests_limit":500,"documents_limit":500,"contacts_limit":500,"cost_items_limit":500,"consultancy_included_per_month":2}'::jsonb
  )
on conflict (product_key) do update
set
  title = excluded.title,
  description = excluded.description,
  plan_type = excluded.plan_type,
  billing_interval = excluded.billing_interval,
  amount_cents = excluded.amount_cents,
  currency = excluded.currency,
  is_active = excluded.is_active,
  sort_order = excluded.sort_order,
  features = excluded.features,
  limits = excluded.limits;
