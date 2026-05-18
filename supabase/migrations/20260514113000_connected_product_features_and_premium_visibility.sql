create extension if not exists pgcrypto;

alter table if exists public.ufficio_cms_categories
  add column if not exists required_plan text,
  add column if not exists premium_visibility text;

alter table if exists public.ufficio_cms_procedures
  add column if not exists required_plan text,
  add column if not exists premium_visibility text;

update public.ufficio_cms_categories
set premium_visibility = coalesce(
  premium_visibility,
  metadata->>'premium_visibility',
  case
    when is_active = false then 'hidden'
    when is_premium = true then 'premium_only'
    else 'free'
  end
),
required_plan = coalesce(
  required_plan,
  metadata->>'required_plan',
  case when is_premium = true then 'premium' else null end
)
where true;

update public.ufficio_cms_procedures
set premium_visibility = coalesce(
  premium_visibility,
  metadata->>'premium_visibility',
  case
    when is_active = false or status = 'archived' then 'hidden'
    when is_premium = true then 'premium_only'
    else 'free'
  end
),
required_plan = coalesce(
  required_plan,
  metadata->>'required_plan',
  case when is_premium = true then 'premium' else null end
)
where true;

do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'ufficio_cms_categories_premium_visibility_check'
  ) then
    alter table public.ufficio_cms_categories
      add constraint ufficio_cms_categories_premium_visibility_check
      check (premium_visibility in ('free', 'premium_preview', 'premium_only', 'hidden'));
  end if;

  if not exists (
    select 1 from pg_constraint
    where conname = 'ufficio_cms_procedures_premium_visibility_check'
  ) then
    alter table public.ufficio_cms_procedures
      add constraint ufficio_cms_procedures_premium_visibility_check
      check (premium_visibility in ('free', 'premium_preview', 'premium_only', 'hidden'));
  end if;

  if not exists (
    select 1 from pg_constraint
    where conname = 'ufficio_cms_categories_required_plan_check'
  ) then
    alter table public.ufficio_cms_categories
      add constraint ufficio_cms_categories_required_plan_check
      check (required_plan is null or required_plan in ('premium'));
  end if;

  if not exists (
    select 1 from pg_constraint
    where conname = 'ufficio_cms_procedures_required_plan_check'
  ) then
    alter table public.ufficio_cms_procedures
      add constraint ufficio_cms_procedures_required_plan_check
      check (required_plan is null or required_plan in ('premium'));
  end if;
end $$;

create index if not exists idx_ufficio_cms_categories_premium_visibility
  on public.ufficio_cms_categories(premium_visibility);

create index if not exists idx_ufficio_cms_procedures_premium_visibility
  on public.ufficio_cms_procedures(premium_visibility);

create table if not exists public.ufficio_situation_scans (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade,
  city text,
  region text,
  status_tags text[] not null default '{}'::text[],
  problem_tags text[] not null default '{}'::text[],
  urgency jsonb not null default '{}'::jsonb,
  matched_procedures jsonb not null default '[]'::jsonb,
  recommended_documents jsonb not null default '[]'::jsonb,
  recommended_deadlines jsonb not null default '[]'::jsonb,
  recommended_cost_items jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.ufficio_checklist_items (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  source_type text not null default 'manual',
  source_procedure_id text,
  title text not null,
  description text,
  status text not null default 'todo',
  due_date timestamptz,
  priority integer not null default 1,
  category_slug text,
  procedure_slug text,
  document_required text,
  official_link text,
  note text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint ufficio_checklist_items_status_check
    check (status in ('todo', 'inProgress', 'done', 'skipped'))
);

create table if not exists public.ufficio_deadlines (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  description text,
  due_date timestamptz not null,
  source_type text not null default 'manual',
  source_procedure_id text,
  category_slug text,
  procedure_slug text,
  status text not null default 'upcoming',
  reminder_enabled boolean not null default true,
  reminder_offset_days integer not null default 7,
  official_link text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint ufficio_deadlines_status_check
    check (status in ('upcoming', 'dueSoon', 'overdue', 'done', 'canceled'))
);

create table if not exists public.ufficio_saved_procedures (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  category_slug text not null,
  subcategory_slug text,
  procedure_slug text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table if exists public.ufficio_cost_items
  add column if not exists amount_min numeric(12,2),
  add column if not exists amount_max numeric(12,2),
  add column if not exists frequency text,
  add column if not exists source_type text,
  add column if not exists source_procedure_id text,
  add column if not exists category_slug text,
  add column if not exists provider_name text,
  add column if not exists official_link text;

do $$
declare
  has_amount boolean;
  has_recurrence boolean;
  has_source boolean;
  has_category_id boolean;
  has_provider_or_authority boolean;
begin
  if to_regclass('public.ufficio_cost_items') is null then
    return;
  end if;

  select exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'ufficio_cost_items'
      and column_name = 'amount'
  ) into has_amount;

  select exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'ufficio_cost_items'
      and column_name = 'recurrence'
  ) into has_recurrence;

  select exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'ufficio_cost_items'
      and column_name = 'source'
  ) into has_source;

  select exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'ufficio_cost_items'
      and column_name = 'category_id'
  ) into has_category_id;

  select exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'ufficio_cost_items'
      and column_name = 'provider_or_authority'
  ) into has_provider_or_authority;

  execute format(
    'update public.ufficio_cost_items set
      amount_min = %s,
      amount_max = %s,
      frequency = %s,
      source_type = %s,
      category_slug = %s,
      provider_name = %s
    where true',
    case
      when has_amount then 'coalesce(amount_min, amount, 0)'
      else 'coalesce(amount_min, 0)'
    end,
    case
      when has_amount then 'coalesce(amount_max, amount, 0)'
      else 'coalesce(amount_max, 0)'
    end,
    case
      when has_recurrence then 'coalesce(frequency, recurrence, ''unknown'')'
      else 'coalesce(frequency, ''unknown'')'
    end,
    case
      when has_source then 'coalesce(source_type, source, ''manual'')'
      else 'coalesce(source_type, ''manual'')'
    end,
    case
      when has_category_id then 'coalesce(category_slug, category_id)'
      else 'category_slug'
    end,
    case
      when has_provider_or_authority then 'coalesce(provider_name, provider_or_authority)'
      else 'provider_name'
    end
  );
end $$;

drop trigger if exists ufficio_situation_scans_updated_at on public.ufficio_situation_scans;
create trigger ufficio_situation_scans_updated_at
before update on public.ufficio_situation_scans
for each row execute function public.ufficio_set_updated_at();

drop trigger if exists ufficio_checklist_items_updated_at on public.ufficio_checklist_items;
create trigger ufficio_checklist_items_updated_at
before update on public.ufficio_checklist_items
for each row execute function public.ufficio_set_updated_at();

drop trigger if exists ufficio_deadlines_updated_at on public.ufficio_deadlines;
create trigger ufficio_deadlines_updated_at
before update on public.ufficio_deadlines
for each row execute function public.ufficio_set_updated_at();

drop trigger if exists ufficio_saved_procedures_updated_at on public.ufficio_saved_procedures;
create trigger ufficio_saved_procedures_updated_at
before update on public.ufficio_saved_procedures
for each row execute function public.ufficio_set_updated_at();

alter table public.ufficio_situation_scans enable row level security;
alter table public.ufficio_checklist_items enable row level security;
alter table public.ufficio_deadlines enable row level security;
alter table public.ufficio_saved_procedures enable row level security;

drop policy if exists "situation_scans_read_own" on public.ufficio_situation_scans;
create policy "situation_scans_read_own"
on public.ufficio_situation_scans for select to authenticated
using (user_id = auth.uid() or (user_id is null and public.is_ufficio_admin()));

drop policy if exists "situation_scans_insert_own" on public.ufficio_situation_scans;
create policy "situation_scans_insert_own"
on public.ufficio_situation_scans for insert to authenticated
with check (user_id = auth.uid() or user_id is null);

drop policy if exists "situation_scans_update_own" on public.ufficio_situation_scans;
create policy "situation_scans_update_own"
on public.ufficio_situation_scans for update to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

drop policy if exists "situation_scans_delete_own" on public.ufficio_situation_scans;
create policy "situation_scans_delete_own"
on public.ufficio_situation_scans for delete to authenticated
using (user_id = auth.uid());

drop policy if exists "checklist_items_read_own" on public.ufficio_checklist_items;
create policy "checklist_items_read_own"
on public.ufficio_checklist_items for select to authenticated
using (user_id = auth.uid());

drop policy if exists "checklist_items_insert_own" on public.ufficio_checklist_items;
create policy "checklist_items_insert_own"
on public.ufficio_checklist_items for insert to authenticated
with check (user_id = auth.uid());

drop policy if exists "checklist_items_update_own" on public.ufficio_checklist_items;
create policy "checklist_items_update_own"
on public.ufficio_checklist_items for update to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

drop policy if exists "checklist_items_delete_own" on public.ufficio_checklist_items;
create policy "checklist_items_delete_own"
on public.ufficio_checklist_items for delete to authenticated
using (user_id = auth.uid());

drop policy if exists "deadlines_read_own" on public.ufficio_deadlines;
create policy "deadlines_read_own"
on public.ufficio_deadlines for select to authenticated
using (user_id = auth.uid());

drop policy if exists "deadlines_insert_own" on public.ufficio_deadlines;
create policy "deadlines_insert_own"
on public.ufficio_deadlines for insert to authenticated
with check (user_id = auth.uid());

drop policy if exists "deadlines_update_own" on public.ufficio_deadlines;
create policy "deadlines_update_own"
on public.ufficio_deadlines for update to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

drop policy if exists "deadlines_delete_own" on public.ufficio_deadlines;
create policy "deadlines_delete_own"
on public.ufficio_deadlines for delete to authenticated
using (user_id = auth.uid());

drop policy if exists "saved_procedures_read_own" on public.ufficio_saved_procedures;
create policy "saved_procedures_read_own"
on public.ufficio_saved_procedures for select to authenticated
using (user_id = auth.uid());

drop policy if exists "saved_procedures_insert_own" on public.ufficio_saved_procedures;
create policy "saved_procedures_insert_own"
on public.ufficio_saved_procedures for insert to authenticated
with check (user_id = auth.uid());

drop policy if exists "saved_procedures_update_own" on public.ufficio_saved_procedures;
create policy "saved_procedures_update_own"
on public.ufficio_saved_procedures for update to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

drop policy if exists "saved_procedures_delete_own" on public.ufficio_saved_procedures;
create policy "saved_procedures_delete_own"
on public.ufficio_saved_procedures for delete to authenticated
using (user_id = auth.uid());

create index if not exists idx_ufficio_situation_scans_user_updated
  on public.ufficio_situation_scans(user_id, updated_at desc);

create index if not exists idx_ufficio_checklist_items_user_status
  on public.ufficio_checklist_items(user_id, status, due_date);

create index if not exists idx_ufficio_deadlines_user_due
  on public.ufficio_deadlines(user_id, due_date);

create index if not exists idx_ufficio_saved_procedures_user_created
  on public.ufficio_saved_procedures(user_id, created_at desc);

create index if not exists idx_ufficio_cost_items_user_due
  on public.ufficio_cost_items(user_id, due_date);