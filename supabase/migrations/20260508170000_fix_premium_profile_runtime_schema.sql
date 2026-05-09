create extension if not exists pgcrypto;

create table if not exists public.ufficio_profiles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  full_name text,
  codice_fiscale text,
  email text,
  phone text,
  city text,
  address text,
  preferred_language text default 'en',
  nationality text,
  date_of_birth date,
  student_status text,
  university_name text,
  work_status text,
  house_status text,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(user_id)
);

alter table if exists public.ufficio_profiles
  add column if not exists user_id uuid references auth.users(id) on delete cascade,
  add column if not exists full_name text,
  add column if not exists codice_fiscale text,
  add column if not exists email text,
  add column if not exists phone text,
  add column if not exists city text,
  add column if not exists address text,
  add column if not exists preferred_language text default 'en',
  add column if not exists nationality text,
  add column if not exists date_of_birth date,
  add column if not exists student_status text,
  add column if not exists university_name text,
  add column if not exists work_status text,
  add column if not exists house_status text,
  add column if not exists notes text,
  add column if not exists created_at timestamptz not null default now(),
  add column if not exists updated_at timestamptz not null default now();

do $$
begin
  if exists (
    select 1
    from information_schema.tables
    where table_schema = 'public'
      and table_name = 'ufficcio_profiles'
  ) then
    execute $sql$
      insert into public.ufficio_profiles (
        user_id,
        full_name,
        codice_fiscale,
        email,
        phone,
        city,
        address,
        preferred_language,
        nationality,
        date_of_birth,
        student_status,
        university_name,
        work_status,
        house_status,
        notes,
        created_at,
        updated_at
      )
      select
        legacy.user_id,
        legacy.full_name,
        legacy.codice_fiscale,
        legacy.email,
        legacy.phone,
        legacy.city,
        legacy.address,
        coalesce(legacy.preferred_language, 'en'),
        legacy.nationality,
        legacy.date_of_birth,
        legacy.student_status,
        legacy.university_name,
        legacy.work_status,
        legacy.house_status,
        legacy.notes,
        coalesce(legacy.created_at, now()),
        coalesce(legacy.updated_at, now())
      from public.ufficcio_profiles as legacy
      on conflict (user_id) do update
      set
        full_name = coalesce(public.ufficio_profiles.full_name, excluded.full_name),
        codice_fiscale = coalesce(public.ufficio_profiles.codice_fiscale, excluded.codice_fiscale),
        email = coalesce(public.ufficio_profiles.email, excluded.email),
        phone = coalesce(public.ufficio_profiles.phone, excluded.phone),
        city = coalesce(public.ufficio_profiles.city, excluded.city),
        address = coalesce(public.ufficio_profiles.address, excluded.address),
        preferred_language = coalesce(public.ufficio_profiles.preferred_language, excluded.preferred_language),
        nationality = coalesce(public.ufficio_profiles.nationality, excluded.nationality),
        date_of_birth = coalesce(public.ufficio_profiles.date_of_birth, excluded.date_of_birth),
        student_status = coalesce(public.ufficio_profiles.student_status, excluded.student_status),
        university_name = coalesce(public.ufficio_profiles.university_name, excluded.university_name),
        work_status = coalesce(public.ufficio_profiles.work_status, excluded.work_status),
        house_status = coalesce(public.ufficio_profiles.house_status, excluded.house_status),
        notes = coalesce(public.ufficio_profiles.notes, excluded.notes)
    $sql$;
  end if;
end $$;

create unique index if not exists idx_ufficio_profiles_user_id
  on public.ufficio_profiles(user_id);

do $$
begin
  if not exists (
    select 1
    from pg_trigger
    where tgname = 'trg_ufficio_profiles_updated_at'
  ) then
    create trigger trg_ufficio_profiles_updated_at
    before update on public.ufficio_profiles
    for each row execute function public.set_updated_at();
  end if;
end $$;

alter table if exists public.ufficio_user_entitlements
  add column if not exists provider_customer_id text,
  add column if not exists provider_subscription_id text,
  add column if not exists provider_product_id text,
  add column if not exists provider_price_id text,
  add column if not exists trial_end timestamptz,
  add column if not exists cancelled_at timestamptz,
  add column if not exists revoked_at timestamptz,
  add column if not exists metadata jsonb not null default '{}'::jsonb;

create unique index if not exists idx_ufficio_user_entitlements_user_id
  on public.ufficio_user_entitlements(user_id);

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
      and status in ('active', 'trialing')
      and revoked_at is null
      and (current_period_end is null or current_period_end >= now())
      and (
        premium_access = true
        or plan in (
          'plus_monthly',
          'plus_yearly',
          'premium_monthly',
          'premium_yearly',
          'admin_grant',
          'lifetime',
          'trial',
          'pro',
          'admin'
        )
      )
  );
$$;

alter table public.ufficio_profiles enable row level security;

drop policy if exists "ufficio_profiles_read_own_v1" on public.ufficio_profiles;
create policy "ufficio_profiles_read_own_v1"
on public.ufficio_profiles for select to authenticated
using (user_id = auth.uid() or public.is_ufficio_admin());

drop policy if exists "ufficio_profiles_write_own_v1" on public.ufficio_profiles;
create policy "ufficio_profiles_write_own_v1"
on public.ufficio_profiles for insert to authenticated
with check (user_id = auth.uid() or public.is_ufficio_admin());

drop policy if exists "ufficio_profiles_update_own_v1" on public.ufficio_profiles;
create policy "ufficio_profiles_update_own_v1"
on public.ufficio_profiles for update to authenticated
using (user_id = auth.uid() or public.is_ufficio_admin())
with check (user_id = auth.uid() or public.is_ufficio_admin());
