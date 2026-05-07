create extension if not exists pgcrypto;

create or replace function public.ufficio_set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create table if not exists public.ufficio_admin_users (
  user_id uuid primary key references auth.users(id) on delete cascade,
  email text,
  role text not null default 'admin',
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid references auth.users(id),
  constraint ufficio_admin_users_role_check
    check (role in ('owner', 'admin', 'editor', 'support', 'viewer'))
);

create or replace function public.is_ufficio_admin()
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select exists (
    select 1
    from public.ufficio_admin_users
    where user_id = auth.uid()
      and is_active = true
      and role in ('owner', 'admin', 'editor')
  );
$$;

create or replace function public.is_ufficio_owner()
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select exists (
    select 1
    from public.ufficio_admin_users
    where user_id = auth.uid()
      and is_active = true
      and role = 'owner'
  );
$$;

create or replace function public.is_ufficcio_admin()
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select public.is_ufficio_admin();
$$;

drop trigger if exists ufficio_admin_users_updated_at on public.ufficio_admin_users;
create trigger ufficio_admin_users_updated_at
before update on public.ufficio_admin_users
for each row execute function public.ufficio_set_updated_at();

alter table public.ufficio_admin_users enable row level security;

drop policy if exists "admin_users_self_read" on public.ufficio_admin_users;
create policy "admin_users_self_read"
on public.ufficio_admin_users
for select
to authenticated
using (user_id = auth.uid());

drop policy if exists "admin_users_admin_read_all" on public.ufficio_admin_users;
create policy "admin_users_admin_read_all"
on public.ufficio_admin_users
for select
to authenticated
using (public.is_ufficio_admin());

drop policy if exists "admin_users_owner_admin_insert" on public.ufficio_admin_users;
create policy "admin_users_owner_admin_insert"
on public.ufficio_admin_users
for insert
to authenticated
with check (public.is_ufficio_owner() or public.is_ufficio_admin());

drop policy if exists "admin_users_owner_admin_update" on public.ufficio_admin_users;
create policy "admin_users_owner_admin_update"
on public.ufficio_admin_users
for update
to authenticated
using (public.is_ufficio_owner() or public.is_ufficio_admin())
with check (public.is_ufficio_owner() or public.is_ufficio_admin());

drop policy if exists "admin_users_owner_admin_delete" on public.ufficio_admin_users;
create policy "admin_users_owner_admin_delete"
on public.ufficio_admin_users
for delete
to authenticated
using (public.is_ufficio_owner() or public.is_ufficio_admin());

create table if not exists public.ufficio_user_entitlements (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references auth.users(id) on delete cascade,
  plan text not null default 'free',
  status text not null default 'active',
  source text not null default 'manual',
  stripe_customer_id text,
  stripe_subscription_id text,
  current_period_end timestamptz,
  premium_since timestamptz,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint ufficio_user_entitlements_plan_check
    check (plan in ('free', 'premium', 'pro', 'admin_grant')),
  constraint ufficio_user_entitlements_status_check
    check (status in ('active', 'trialing', 'past_due', 'canceled', 'expired'))
);

drop trigger if exists ufficio_user_entitlements_updated_at on public.ufficio_user_entitlements;
create trigger ufficio_user_entitlements_updated_at
before update on public.ufficio_user_entitlements
for each row execute function public.ufficio_set_updated_at();

alter table public.ufficio_user_entitlements enable row level security;

drop policy if exists "entitlements_read_own" on public.ufficio_user_entitlements;
create policy "entitlements_read_own"
on public.ufficio_user_entitlements
for select
to authenticated
using (user_id = auth.uid());

drop policy if exists "entitlements_admin_read_all" on public.ufficio_user_entitlements;
create policy "entitlements_admin_read_all"
on public.ufficio_user_entitlements
for select
to authenticated
using (public.is_ufficio_admin());

drop policy if exists "entitlements_admin_insert" on public.ufficio_user_entitlements;
create policy "entitlements_admin_insert"
on public.ufficio_user_entitlements
for insert
to authenticated
with check (public.is_ufficio_admin());

drop policy if exists "entitlements_admin_update" on public.ufficio_user_entitlements;
create policy "entitlements_admin_update"
on public.ufficio_user_entitlements
for update
to authenticated
using (public.is_ufficio_admin())
with check (public.is_ufficio_admin());

drop policy if exists "entitlements_admin_delete" on public.ufficio_user_entitlements;
create policy "entitlements_admin_delete"
on public.ufficio_user_entitlements
for delete
to authenticated
using (public.is_ufficio_owner() or public.is_ufficio_admin());

create table if not exists public.ufficio_premium_events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete set null,
  event_type text not null,
  source text not null,
  payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

alter table public.ufficio_premium_events enable row level security;

drop policy if exists "premium_events_read_own" on public.ufficio_premium_events;
create policy "premium_events_read_own"
on public.ufficio_premium_events
for select
to authenticated
using (user_id = auth.uid());

drop policy if exists "premium_events_admin_read_all" on public.ufficio_premium_events;
create policy "premium_events_admin_read_all"
on public.ufficio_premium_events
for select
to authenticated
using (public.is_ufficio_admin());

drop policy if exists "premium_events_admin_insert" on public.ufficio_premium_events;
create policy "premium_events_admin_insert"
on public.ufficio_premium_events
for insert
to authenticated
with check (public.is_ufficio_admin());

create table if not exists public.ufficio_problem_requests (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete set null,
  email text,
  category text,
  problem_title text not null,
  problem_description text not null,
  language_code text not null default 'en',
  status text not null default 'new',
  admin_notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint ufficio_problem_requests_status_check
    check (status in ('new', 'reviewing', 'planned', 'added', 'rejected'))
);

drop trigger if exists ufficio_problem_requests_updated_at on public.ufficio_problem_requests;
create trigger ufficio_problem_requests_updated_at
before update on public.ufficio_problem_requests
for each row execute function public.ufficio_set_updated_at();

alter table public.ufficio_problem_requests enable row level security;

drop policy if exists "problem_requests_insert_public" on public.ufficio_problem_requests;
create policy "problem_requests_insert_public"
on public.ufficio_problem_requests
for insert
to anon, authenticated
with check (
  case
    when auth.uid() is null then user_id is null
    else user_id is null or user_id = auth.uid()
  end
);

drop policy if exists "problem_requests_read_own" on public.ufficio_problem_requests;
create policy "problem_requests_read_own"
on public.ufficio_problem_requests
for select
to authenticated
using (user_id = auth.uid());

drop policy if exists "problem_requests_admin_read_all" on public.ufficio_problem_requests;
create policy "problem_requests_admin_read_all"
on public.ufficio_problem_requests
for select
to authenticated
using (public.is_ufficio_admin());

drop policy if exists "problem_requests_admin_update_all" on public.ufficio_problem_requests;
create policy "problem_requests_admin_update_all"
on public.ufficio_problem_requests
for update
to authenticated
using (public.is_ufficio_admin())
with check (public.is_ufficio_admin());

create table if not exists public.ufficio_consultancy_requests (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete set null,
  email text,
  category text,
  subject text not null,
  message text not null,
  language_code text not null default 'en',
  is_premium_snapshot boolean not null default false,
  payment_status text not null default 'not_required',
  status text not null default 'new',
  admin_notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint ufficio_consultancy_requests_payment_status_check
    check (payment_status in ('not_required', 'required', 'pending', 'paid', 'failed', 'waived')),
  constraint ufficio_consultancy_requests_status_check
    check (status in ('new', 'reviewing', 'waiting_user', 'answered', 'closed'))
);

drop trigger if exists ufficio_consultancy_requests_updated_at on public.ufficio_consultancy_requests;
create trigger ufficio_consultancy_requests_updated_at
before update on public.ufficio_consultancy_requests
for each row execute function public.ufficio_set_updated_at();

alter table public.ufficio_consultancy_requests enable row level security;

drop policy if exists "consultancy_requests_insert_public" on public.ufficio_consultancy_requests;
create policy "consultancy_requests_insert_public"
on public.ufficio_consultancy_requests
for insert
to anon, authenticated
with check (
  case
    when auth.uid() is null then user_id is null
    else user_id is null or user_id = auth.uid()
  end
);

drop policy if exists "consultancy_requests_read_own" on public.ufficio_consultancy_requests;
create policy "consultancy_requests_read_own"
on public.ufficio_consultancy_requests
for select
to authenticated
using (user_id = auth.uid());

drop policy if exists "consultancy_requests_admin_read_all" on public.ufficio_consultancy_requests;
create policy "consultancy_requests_admin_read_all"
on public.ufficio_consultancy_requests
for select
to authenticated
using (public.is_ufficio_admin());

drop policy if exists "consultancy_requests_admin_update_all" on public.ufficio_consultancy_requests;
create policy "consultancy_requests_admin_update_all"
on public.ufficio_consultancy_requests
for update
to authenticated
using (public.is_ufficio_admin())
with check (public.is_ufficio_admin());

create table if not exists public.ufficio_admin_audit_logs (
  id uuid primary key default gen_random_uuid(),
  actor_user_id uuid references auth.users(id) on delete set null,
  action text not null,
  target_table text not null,
  target_id text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

alter table public.ufficio_admin_audit_logs enable row level security;

drop policy if exists "admin_audit_read_all" on public.ufficio_admin_audit_logs;
create policy "admin_audit_read_all"
on public.ufficio_admin_audit_logs
for select
to authenticated
using (public.is_ufficio_admin());

drop policy if exists "admin_audit_insert_own" on public.ufficio_admin_audit_logs;
create policy "admin_audit_insert_own"
on public.ufficio_admin_audit_logs
for insert
to authenticated
with check (
  public.is_ufficio_admin()
  and (actor_user_id is null or actor_user_id = auth.uid())
);

create index if not exists idx_ufficio_admin_users_user_id
  on public.ufficio_admin_users(user_id);
create index if not exists idx_ufficio_user_entitlements_user_id
  on public.ufficio_user_entitlements(user_id);
create index if not exists idx_ufficio_problem_requests_user_status_created
  on public.ufficio_problem_requests(user_id, status, created_at desc);
create index if not exists idx_ufficio_consultancy_requests_user_status_created
  on public.ufficio_consultancy_requests(user_id, status, created_at desc);

create table if not exists public.ufficio_cost_items (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  type text not null default 'other',
  provider_or_authority text,
  amount numeric(12, 2) not null default 0,
  due_date timestamptz,
  recurrence text,
  notes text,
  attachment_reference text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

drop trigger if exists ufficio_cost_items_updated_at on public.ufficio_cost_items;
create trigger ufficio_cost_items_updated_at
before update on public.ufficio_cost_items
for each row execute function public.ufficio_set_updated_at();

alter table public.ufficio_cost_items enable row level security;

drop policy if exists "cost_items_read_own" on public.ufficio_cost_items;
create policy "cost_items_read_own"
on public.ufficio_cost_items
for select
to authenticated
using (user_id = auth.uid());

drop policy if exists "cost_items_insert_own" on public.ufficio_cost_items;
create policy "cost_items_insert_own"
on public.ufficio_cost_items
for insert
to authenticated
with check (user_id = auth.uid());

drop policy if exists "cost_items_update_own" on public.ufficio_cost_items;
create policy "cost_items_update_own"
on public.ufficio_cost_items
for update
to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

drop policy if exists "cost_items_delete_own" on public.ufficio_cost_items;
create policy "cost_items_delete_own"
on public.ufficio_cost_items
for delete
to authenticated
using (user_id = auth.uid());

create index if not exists idx_ufficio_cost_items_user_id
  on public.ufficio_cost_items(user_id);

comment on table public.ufficio_admin_users is
  'Production admin roles for UfficioFacile. Seed with SQL editor or trusted CLI only. Never write from anon/mobile/web client.';
comment on function public.is_ufficio_admin() is
  'Checks active admin/editor roles for the authenticated Supabase user.';
