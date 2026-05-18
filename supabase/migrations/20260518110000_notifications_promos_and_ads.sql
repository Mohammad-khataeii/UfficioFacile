create extension if not exists pgcrypto;

create table if not exists public.ufficio_promo_codes (
  id uuid primary key default gen_random_uuid(),
  code text not null,
  title text not null,
  description text,
  plan_key text not null default 'premium_monthly',
  duration_days int not null default 30,
  max_redemptions int,
  redeemed_count int not null default 0,
  starts_at timestamptz,
  ends_at timestamptz,
  assigned_user_id uuid references auth.users(id) on delete set null,
  is_active boolean not null default true,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint ufficio_promo_codes_plan_key_check
    check (
      plan_key in (
        'premium_monthly',
        'premium_yearly',
        'trial',
        'admin_grant'
      )
    ),
  constraint ufficio_promo_codes_duration_check
    check (duration_days > 0)
);

create unique index if not exists idx_ufficio_promo_codes_code_upper
  on public.ufficio_promo_codes (upper(code));

create index if not exists idx_ufficio_promo_codes_active_window
  on public.ufficio_promo_codes (is_active, starts_at, ends_at);

create index if not exists idx_ufficio_promo_codes_assigned_user
  on public.ufficio_promo_codes (assigned_user_id)
  where assigned_user_id is not null;

drop trigger if exists ufficio_promo_codes_updated_at on public.ufficio_promo_codes;
create trigger ufficio_promo_codes_updated_at
before update on public.ufficio_promo_codes
for each row execute function public.ufficio_set_updated_at();

create table if not exists public.ufficio_promo_redemptions (
  id uuid primary key default gen_random_uuid(),
  promo_code_id uuid not null references public.ufficio_promo_codes(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  code text not null,
  status text not null default 'redeemed',
  message text,
  plan_key text,
  expires_at timestamptz,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint ufficio_promo_redemptions_status_check
    check (status in ('redeemed', 'rejected'))
);

create unique index if not exists idx_ufficio_promo_redemptions_unique_user_code
  on public.ufficio_promo_redemptions (promo_code_id, user_id)
  where status = 'redeemed';

create index if not exists idx_ufficio_promo_redemptions_user_created
  on public.ufficio_promo_redemptions (user_id, created_at desc);

drop trigger if exists ufficio_promo_redemptions_updated_at on public.ufficio_promo_redemptions;
create trigger ufficio_promo_redemptions_updated_at
before update on public.ufficio_promo_redemptions
for each row execute function public.ufficio_set_updated_at();

alter table public.ufficio_promo_codes enable row level security;
alter table public.ufficio_promo_redemptions enable row level security;

drop policy if exists "promo_codes_admin_read" on public.ufficio_promo_codes;
create policy "promo_codes_admin_read"
on public.ufficio_promo_codes
for select to authenticated
using (public.is_ufficio_admin());

drop policy if exists "promo_codes_admin_insert" on public.ufficio_promo_codes;
create policy "promo_codes_admin_insert"
on public.ufficio_promo_codes
for insert to authenticated
with check (public.is_ufficio_admin());

drop policy if exists "promo_codes_admin_update" on public.ufficio_promo_codes;
create policy "promo_codes_admin_update"
on public.ufficio_promo_codes
for update to authenticated
using (public.is_ufficio_admin())
with check (public.is_ufficio_admin());

drop policy if exists "promo_codes_admin_delete" on public.ufficio_promo_codes;
create policy "promo_codes_admin_delete"
on public.ufficio_promo_codes
for delete to authenticated
using (public.is_ufficio_owner() or public.is_ufficio_admin());

drop policy if exists "promo_redemptions_read_own" on public.ufficio_promo_redemptions;
create policy "promo_redemptions_read_own"
on public.ufficio_promo_redemptions
for select to authenticated
using (user_id = auth.uid());

drop policy if exists "promo_redemptions_admin_read" on public.ufficio_promo_redemptions;
create policy "promo_redemptions_admin_read"
on public.ufficio_promo_redemptions
for select to authenticated
using (public.is_ufficio_admin());

drop policy if exists "promo_redemptions_admin_write" on public.ufficio_promo_redemptions;
create policy "promo_redemptions_admin_write"
on public.ufficio_promo_redemptions
for all to authenticated
using (public.is_ufficio_admin())
with check (public.is_ufficio_admin());

create or replace function public.redeem_ufficio_promo_code(input_code text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  target_user_id uuid := auth.uid();
  normalized_code text := upper(trim(coalesce(input_code, '')));
  promo_row public.ufficio_promo_codes%rowtype;
  redeemed_total int;
  existing_entitlement public.ufficio_user_entitlements%rowtype;
  next_start timestamptz := now();
  next_end timestamptz;
  next_plan text;
begin
  if target_user_id is null then
    return jsonb_build_object(
      'ok', false,
      'message', 'Log in to redeem a code.'
    );
  end if;

  if normalized_code = '' then
    return jsonb_build_object(
      'ok', false,
      'message', 'Enter a valid code.'
    );
  end if;

  select *
  into promo_row
  from public.ufficio_promo_codes
  where upper(code) = normalized_code
  limit 1;

  if not found or promo_row.is_active is not true then
    return jsonb_build_object(
      'ok', false,
      'message', 'This code is not active.'
    );
  end if;

  if promo_row.starts_at is not null and now() < promo_row.starts_at then
    return jsonb_build_object(
      'ok', false,
      'message', 'This code is not active yet.'
    );
  end if;

  if promo_row.ends_at is not null and now() > promo_row.ends_at then
    return jsonb_build_object(
      'ok', false,
      'message', 'This code has expired.'
    );
  end if;

  if promo_row.assigned_user_id is not null and promo_row.assigned_user_id <> target_user_id then
    return jsonb_build_object(
      'ok', false,
      'message', 'This code is assigned to another account.'
    );
  end if;

  if exists (
    select 1
    from public.ufficio_promo_redemptions
    where promo_code_id = promo_row.id
      and user_id = target_user_id
      and status = 'redeemed'
  ) then
    return jsonb_build_object(
      'ok', false,
      'message', 'This code was already used on this account.'
    );
  end if;

  redeemed_total := coalesce(promo_row.redeemed_count, 0);
  if promo_row.max_redemptions is not null and redeemed_total >= promo_row.max_redemptions then
    return jsonb_build_object(
      'ok', false,
      'message', 'This code reached its usage limit.'
    );
  end if;

  select *
  into existing_entitlement
  from public.ufficio_user_entitlements
  where user_id = target_user_id
  limit 1;

  if found and existing_entitlement.current_period_end is not null and existing_entitlement.current_period_end > now() then
    next_start := existing_entitlement.current_period_end;
  else
    next_start := now();
  end if;

  next_end := next_start + make_interval(days => promo_row.duration_days);
  next_plan := promo_row.plan_key;

  insert into public.ufficio_user_entitlements (
    user_id,
    plan,
    status,
    source,
    premium_access,
    current_period_start,
    current_period_end,
    premium_since,
    metadata
  )
  values (
    target_user_id,
    next_plan,
    'active',
    'promo_code',
    true,
    now(),
    next_end,
    now(),
    jsonb_build_object(
      'promo_code', promo_row.code,
      'promo_code_id', promo_row.id,
      'promo_duration_days', promo_row.duration_days
    )
  )
  on conflict (user_id) do update
  set plan = excluded.plan,
      status = 'active',
      source = 'promo_code',
      premium_access = true,
      current_period_start = now(),
      current_period_end = greatest(
        coalesce(public.ufficio_user_entitlements.current_period_end, now()),
        next_end
      ),
      premium_since = coalesce(public.ufficio_user_entitlements.premium_since, now()),
      metadata = coalesce(public.ufficio_user_entitlements.metadata, '{}'::jsonb) || excluded.metadata,
      updated_at = now();

  insert into public.ufficio_promo_redemptions (
    promo_code_id,
    user_id,
    code,
    status,
    message,
    plan_key,
    expires_at,
    metadata
  )
  values (
    promo_row.id,
    target_user_id,
    promo_row.code,
    'redeemed',
    'Promo code applied successfully.',
    next_plan,
    next_end,
    jsonb_build_object(
      'promo_title', promo_row.title,
      'assigned_user_id', promo_row.assigned_user_id
    )
  );

  update public.ufficio_promo_codes
  set redeemed_count = coalesce(redeemed_count, 0) + 1,
      updated_at = now()
  where id = promo_row.id;

  insert into public.ufficio_premium_events (
    user_id,
    event_type,
    plan,
    source,
    payload,
    metadata
  )
  values (
    target_user_id,
    'promo_code_redeemed',
    next_plan,
    'promo_code',
    jsonb_build_object(
      'code', promo_row.code,
      'promo_code_id', promo_row.id,
      'duration_days', promo_row.duration_days,
      'expires_at', next_end
    ),
    jsonb_build_object(
      'code', promo_row.code,
      'title', promo_row.title
    )
  );

  return jsonb_build_object(
    'ok', true,
    'message', 'Promo code applied.',
    'plan', next_plan,
    'expires_at', next_end
  );
end;
$$;

grant execute on function public.redeem_ufficio_promo_code(text) to authenticated;

insert into public.ufficio_app_public_config (key, value, is_active)
values (
  'freeUserAds',
  jsonb_build_object(
    'enabled', false,
    'provider', 'google_mobile_ads',
    'testMode', false,
    'screens', jsonb_build_array('home', 'profile_folder', 'promo_codes'),
    'bannerUnitIdAndroid', '',
    'bannerUnitIdIos', '',
    'interstitialUnitIdAndroid', '',
    'interstitialUnitIdIos', ''
  ),
  true
)
on conflict (key) do nothing;
