create extension if not exists pgcrypto;

create table if not exists public.ufficio_cms_categories (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  parent_slug text,
  title jsonb not null default '{}'::jsonb,
  short_description jsonb not null default '{}'::jsonb,
  long_description jsonb not null default '{}'::jsonb,
  icon_name text,
  color_token text,
  sort_order integer not null default 0,
  is_active boolean not null default true,
  is_premium boolean not null default false,
  visibility text not null default 'public',
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint ufficio_cms_categories_visibility_check
    check (visibility in ('public', 'authenticated', 'premium', 'adminOnly', 'hidden'))
);

create table if not exists public.ufficio_cms_procedures (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  category_slug text not null,
  subcategory_slug text,
  title jsonb not null default '{}'::jsonb,
  subtitle jsonb not null default '{}'::jsonb,
  summary jsonb not null default '{}'::jsonb,
  what_is_it jsonb not null default '{}'::jsonb,
  why_you_need_it jsonb not null default '{}'::jsonb,
  how_to_do_it jsonb not null default '{}'::jsonb,
  documents_needed jsonb not null default '{}'::jsonb,
  costs_and_timing jsonb not null default '{}'::jsonb,
  common_mistakes jsonb not null default '{}'::jsonb,
  warnings jsonb not null default '{}'::jsonb,
  official_links jsonb not null default '[]'::jsonb,
  official_contacts jsonb not null default '[]'::jsonb,
  checklist jsonb not null default '[]'::jsonb,
  faqs jsonb not null default '[]'::jsonb,
  premium_notes jsonb not null default '{}'::jsonb,
  cta_config jsonb not null default '{}'::jsonb,
  source_ids uuid[] not null default '{}',
  verification_status text not null default 'needsReview',
  last_verified_at timestamptz,
  sort_order integer not null default 0,
  is_active boolean not null default true,
  is_premium boolean not null default false,
  visibility text not null default 'public',
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint ufficio_cms_procedures_verification_check
    check (verification_status in ('verified', 'needsReview', 'outdated', 'unverified')),
  constraint ufficio_cms_procedures_visibility_check
    check (visibility in ('public', 'authenticated', 'premium', 'adminOnly', 'hidden'))
);

create table if not exists public.ufficio_cms_content_blocks (
  id uuid primary key default gen_random_uuid(),
  procedure_slug text not null,
  block_type text not null,
  title jsonb not null default '{}'::jsonb,
  body jsonb not null default '{}'::jsonb,
  items jsonb not null default '[]'::jsonb,
  config jsonb not null default '{}'::jsonb,
  sort_order integer not null default 0,
  is_active boolean not null default true,
  is_premium boolean not null default false,
  visibility text not null default 'public',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint ufficio_cms_content_blocks_type_check
    check (block_type in ('info', 'steps', 'checklist', 'documents', 'warning', 'cost', 'timing', 'officialLinks', 'contacts', 'providerForms', 'faq', 'premium', 'cta', 'custom')),
  constraint ufficio_cms_content_blocks_visibility_check
    check (visibility in ('public', 'authenticated', 'premium', 'adminOnly', 'hidden'))
);

create table if not exists public.ufficio_cms_revisions (
  id uuid primary key default gen_random_uuid(),
  entity_type text not null,
  entity_id uuid,
  entity_slug text,
  action text not null,
  before_value jsonb,
  after_value jsonb,
  actor_user_id uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  constraint ufficio_cms_revisions_action_check
    check (action in ('create', 'update', 'deactivate', 'reactivate', 'delete', 'publish', 'unpublish', 'reorder', 'import', 'export'))
);

create table if not exists public.ufficio_cms_drafts (
  id uuid primary key default gen_random_uuid(),
  entity_type text not null,
  entity_slug text not null,
  draft_value jsonb not null,
  status text not null default 'draft',
  actor_user_id uuid references auth.users(id) on delete set null,
  reviewed_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint ufficio_cms_drafts_status_check
    check (status in ('draft', 'pendingReview', 'approved', 'rejected', 'published'))
);

drop trigger if exists ufficio_cms_categories_updated_at on public.ufficio_cms_categories;
create trigger ufficio_cms_categories_updated_at
before update on public.ufficio_cms_categories
for each row execute function public.ufficio_set_updated_at();

drop trigger if exists ufficio_cms_procedures_updated_at on public.ufficio_cms_procedures;
create trigger ufficio_cms_procedures_updated_at
before update on public.ufficio_cms_procedures
for each row execute function public.ufficio_set_updated_at();

drop trigger if exists ufficio_cms_content_blocks_updated_at on public.ufficio_cms_content_blocks;
create trigger ufficio_cms_content_blocks_updated_at
before update on public.ufficio_cms_content_blocks
for each row execute function public.ufficio_set_updated_at();

drop trigger if exists ufficio_cms_drafts_updated_at on public.ufficio_cms_drafts;
create trigger ufficio_cms_drafts_updated_at
before update on public.ufficio_cms_drafts
for each row execute function public.ufficio_set_updated_at();

alter table public.ufficio_cms_categories enable row level security;
alter table public.ufficio_cms_procedures enable row level security;
alter table public.ufficio_cms_content_blocks enable row level security;
alter table public.ufficio_cms_revisions enable row level security;
alter table public.ufficio_cms_drafts enable row level security;

create or replace function public.ufficio_has_active_premium()
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select public.is_ufficio_admin()
    or exists (
      select 1
      from public.ufficio_user_entitlements
      where user_id = auth.uid()
        and status in ('active', 'trialing')
        and plan in ('premium', 'pro', 'admin_grant')
    );
$$;

drop policy if exists "cms_categories_public_read" on public.ufficio_cms_categories;
create policy "cms_categories_public_read"
on public.ufficio_cms_categories
for select
to anon, authenticated
using (
  is_active = true
  and visibility = 'public'
);

drop policy if exists "cms_categories_authenticated_read" on public.ufficio_cms_categories;
create policy "cms_categories_authenticated_read"
on public.ufficio_cms_categories
for select
to authenticated
using (
  is_active = true
  and visibility = 'authenticated'
);

drop policy if exists "cms_categories_premium_read" on public.ufficio_cms_categories;
create policy "cms_categories_premium_read"
on public.ufficio_cms_categories
for select
to authenticated
using (
  is_active = true
  and visibility = 'premium'
  and public.ufficio_has_active_premium()
);

drop policy if exists "cms_categories_admin_read_all" on public.ufficio_cms_categories;
create policy "cms_categories_admin_read_all"
on public.ufficio_cms_categories
for select
to authenticated
using (public.is_ufficio_admin());

drop policy if exists "cms_categories_admin_write" on public.ufficio_cms_categories;
create policy "cms_categories_admin_write"
on public.ufficio_cms_categories
for all
to authenticated
using (public.is_ufficio_admin())
with check (public.is_ufficio_admin());

drop policy if exists "cms_procedures_public_read" on public.ufficio_cms_procedures;
create policy "cms_procedures_public_read"
on public.ufficio_cms_procedures
for select
to anon, authenticated
using (
  is_active = true
  and visibility = 'public'
);

drop policy if exists "cms_procedures_authenticated_read" on public.ufficio_cms_procedures;
create policy "cms_procedures_authenticated_read"
on public.ufficio_cms_procedures
for select
to authenticated
using (
  is_active = true
  and visibility = 'authenticated'
);

drop policy if exists "cms_procedures_premium_read" on public.ufficio_cms_procedures;
create policy "cms_procedures_premium_read"
on public.ufficio_cms_procedures
for select
to authenticated
using (
  is_active = true
  and visibility = 'premium'
  and public.ufficio_has_active_premium()
);

drop policy if exists "cms_procedures_admin_read_all" on public.ufficio_cms_procedures;
create policy "cms_procedures_admin_read_all"
on public.ufficio_cms_procedures
for select
to authenticated
using (public.is_ufficio_admin());

drop policy if exists "cms_procedures_admin_write" on public.ufficio_cms_procedures;
create policy "cms_procedures_admin_write"
on public.ufficio_cms_procedures
for all
to authenticated
using (public.is_ufficio_admin())
with check (public.is_ufficio_admin());

drop policy if exists "cms_blocks_public_read" on public.ufficio_cms_content_blocks;
create policy "cms_blocks_public_read"
on public.ufficio_cms_content_blocks
for select
to anon, authenticated
using (
  is_active = true
  and visibility = 'public'
);

drop policy if exists "cms_blocks_authenticated_read" on public.ufficio_cms_content_blocks;
create policy "cms_blocks_authenticated_read"
on public.ufficio_cms_content_blocks
for select
to authenticated
using (
  is_active = true
  and visibility = 'authenticated'
);

drop policy if exists "cms_blocks_premium_read" on public.ufficio_cms_content_blocks;
create policy "cms_blocks_premium_read"
on public.ufficio_cms_content_blocks
for select
to authenticated
using (
  is_active = true
  and visibility = 'premium'
  and public.ufficio_has_active_premium()
);

drop policy if exists "cms_blocks_admin_read_all" on public.ufficio_cms_content_blocks;
create policy "cms_blocks_admin_read_all"
on public.ufficio_cms_content_blocks
for select
to authenticated
using (public.is_ufficio_admin());

drop policy if exists "cms_blocks_admin_write" on public.ufficio_cms_content_blocks;
create policy "cms_blocks_admin_write"
on public.ufficio_cms_content_blocks
for all
to authenticated
using (public.is_ufficio_admin())
with check (public.is_ufficio_admin());

drop policy if exists "cms_revisions_admin_read" on public.ufficio_cms_revisions;
create policy "cms_revisions_admin_read"
on public.ufficio_cms_revisions
for select
to authenticated
using (public.is_ufficio_admin());

drop policy if exists "cms_revisions_admin_insert" on public.ufficio_cms_revisions;
create policy "cms_revisions_admin_insert"
on public.ufficio_cms_revisions
for insert
to authenticated
with check (public.is_ufficio_admin());

drop policy if exists "cms_drafts_admin_read_write" on public.ufficio_cms_drafts;
create policy "cms_drafts_admin_read_write"
on public.ufficio_cms_drafts
for all
to authenticated
using (public.is_ufficio_admin())
with check (public.is_ufficio_admin());

create index if not exists idx_ufficio_cms_categories_slug
  on public.ufficio_cms_categories(slug);
create index if not exists idx_ufficio_cms_categories_parent_slug
  on public.ufficio_cms_categories(parent_slug);
create index if not exists idx_ufficio_cms_categories_active_order
  on public.ufficio_cms_categories(is_active, sort_order);
create index if not exists idx_ufficio_cms_procedures_slug
  on public.ufficio_cms_procedures(slug);
create index if not exists idx_ufficio_cms_procedures_category_slug
  on public.ufficio_cms_procedures(category_slug);
create index if not exists idx_ufficio_cms_procedures_subcategory_slug
  on public.ufficio_cms_procedures(subcategory_slug);
create index if not exists idx_ufficio_cms_procedures_active_order
  on public.ufficio_cms_procedures(is_active, sort_order);
create index if not exists idx_ufficio_cms_blocks_procedure_order
  on public.ufficio_cms_content_blocks(procedure_slug, sort_order);
create index if not exists idx_ufficio_cms_revisions_entity_created
  on public.ufficio_cms_revisions(entity_type, entity_slug, created_at desc);
create index if not exists idx_ufficio_cms_drafts_entity_status
  on public.ufficio_cms_drafts(entity_type, entity_slug, status);

comment on table public.ufficio_cms_categories is
  'No-code category configuration. Bundled Dart definitions remain fallback only.';
comment on table public.ufficio_cms_procedures is
  'No-code procedure content with localized sections, warnings, links, and premium messaging.';
