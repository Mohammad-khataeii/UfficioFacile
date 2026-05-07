create extension if not exists pgcrypto;

create or replace function public.ufficio_touch_updated_at()
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
  display_name text,
  role text not null default 'viewer',
  is_active boolean not null default true,
  created_by uuid references auth.users(id) on delete set null,
  updated_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint ufficio_admin_users_role_check
    check (role in ('owner','admin','editor','support','viewer'))
);

create table if not exists public.ufficio_admin_audit_logs (
  id uuid primary key default gen_random_uuid(),
  actor_user_id uuid references auth.users(id) on delete set null,
  actor_email text,
  actor_role text,
  action text not null,
  target_table text not null,
  target_id text,
  target_user_id uuid,
  summary text,
  before_value jsonb not null default '{}'::jsonb,
  after_value jsonb not null default '{}'::jsonb,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists public.ufficio_problem_requests (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete set null,
  user_email text,
  category_id text,
  subcategory_id text,
  title text not null,
  description text not null,
  city text not null default 'Torino',
  region text not null default 'Piemonte',
  urgency text not null default 'normal',
  language text not null default 'English',
  attachment_placeholder text,
  status text not null default 'new',
  is_premium_user boolean not null default false,
  source_page text not null default '',
  admin_notes text,
  linked_category_slug text,
  linked_procedure_slug text,
  reviewed_by uuid references auth.users(id) on delete set null,
  reviewed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint ufficio_problem_requests_status_check
    check (status in ('new','reviewing','planned','added','rejected')),
  constraint ufficio_problem_requests_urgency_check
    check (urgency in ('low','normal','urgent'))
);

create table if not exists public.ufficio_consultancy_requests (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete set null,
  user_email text,
  full_name text not null,
  category_id text,
  subcategory_id text,
  problem_type text not null default '',
  description text not null,
  desired_result text not null default '',
  city text not null default 'Torino',
  region text not null default 'Piemonte',
  documents_available text not null default '',
  attachment_urls text[] not null default '{}'::text[],
  user_plan text not null default 'free',
  payment_status text not null default 'paymentRequired',
  status text not null default 'newRequest',
  source_page text not null default '',
  admin_notes text,
  response_notes text,
  reviewed_by uuid references auth.users(id) on delete set null,
  reviewed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint ufficio_consultancy_requests_status_check
    check (status in ('newRequest','waitingPayment','reviewing','replied','closed')),
  constraint ufficio_consultancy_requests_payment_check
    check (
      payment_status in (
        'freeForPremium',
        'paymentRequired',
        'waitingPayment',
        'paid',
        'failed',
        'notAvailable'
      )
    ),
  constraint ufficio_consultancy_requests_plan_check
    check (user_plan in ('free','pro','consultant'))
);

create table if not exists public.ufficio_premium_events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  actor_user_id uuid references auth.users(id) on delete set null,
  event_type text not null,
  plan_before text,
  plan_after text,
  premium_access_before boolean,
  premium_access_after boolean,
  notes text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

do $$
begin
  if to_regclass('public.ufficio_user_entitlements') is null then
    create view public.ufficio_user_entitlements as
    select
      id,
      user_id,
      plan,
      status,
      free_pack_limit,
      free_packs_used,
      premium_access,
      current_period_start,
      current_period_end,
      provider,
      provider_customer_id,
      provider_subscription_id,
      created_at,
      updated_at
    from public.ufficcio_entitlements;
  end if;
end $$;

create table if not exists public.ufficio_cost_items (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  category_id text,
  subcategory_id text,
  title text not null,
  description text,
  amount numeric not null default 0,
  currency text not null default 'EUR',
  item_type text not null default 'expense',
  status text not null default 'estimated',
  due_date timestamptz,
  paid_date timestamptz,
  related_contact_id text,
  related_document_id text,
  source text not null default 'manual',
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint ufficio_cost_items_type_check
    check (item_type in ('expense','refund','deposit','installment','estimate')),
  constraint ufficio_cost_items_status_check
    check (status in ('estimated','planned','paid','refunded','disputed','cancelled')),
  constraint ufficio_cost_items_source_check
    check (source in ('manual','generatedFromCategory','imported'))
);

create table if not exists public.ufficio_directory_contacts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  source text not null default 'userSaved',
  category_id text,
  subcategory_id text,
  name text not null,
  description text,
  address text,
  phone text,
  email text,
  pec text,
  website text,
  opening_hours text,
  use_for text[] not null default '{}'::text[],
  warning text,
  city text,
  region text,
  tags text[] not null default '{}'::text[],
  contact_type text not null default 'other',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint ufficio_directory_contacts_source_check
    check (source in ('official','userSaved','categoryGenerated')),
  constraint ufficio_directory_contacts_type_check
    check (
      contact_type in (
        'publicOffice','authority','unionSupport','support','operator','personal',
        'patronato','caf','healthcare','housing','other'
      )
    )
);

create table if not exists public.ufficio_documents_directory (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  category_id text,
  subcategory_id text,
  title text not null,
  description text,
  document_type text not null default 'other',
  status text not null default 'needed',
  due_date timestamptz,
  storage_bucket text,
  storage_path text,
  notes text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint ufficio_documents_directory_status_check
    check (status in ('needed','collected','uploaded','sent','rejectedOrExpired')),
  constraint ufficio_documents_directory_type_check
    check (
      document_type in (
        'identity','residence','income','rental','study','health','employment','other'
      )
    )
);

create table if not exists public.ufficio_cms_categories (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  internal_label text,
  title jsonb not null default '{}'::jsonb,
  subtitle jsonb not null default '{}'::jsonb,
  description jsonb not null default '{}'::jsonb,
  icon text,
  color text,
  sort_order int not null default 0,
  is_active boolean not null default true,
  is_premium boolean not null default false,
  premium_visibility_rule text,
  seo_title jsonb not null default '{}'::jsonb,
  seo_description jsonb not null default '{}'::jsonb,
  source_reference_notes text,
  verification_status text not null default 'needsReview',
  last_verified_at timestamptz,
  admin_notes text,
  metadata jsonb not null default '{}'::jsonb,
  public_snapshot jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint ufficio_cms_categories_verification_check
    check (verification_status in ('verified','needsReview','unverified')),
  constraint ufficio_cms_categories_slug_check
    check (slug ~ '^[a-z0-9_\\-/]+$')
);

create table if not exists public.ufficio_cms_procedures (
  id uuid primary key default gen_random_uuid(),
  category_slug text not null references public.ufficio_cms_categories(slug) on delete cascade,
  slug text not null unique,
  internal_label text,
  title jsonb not null default '{}'::jsonb,
  subtitle jsonb not null default '{}'::jsonb,
  summary jsonb not null default '{}'::jsonb,
  what_is_it jsonb not null default '{}'::jsonb,
  why_you_may_need_it jsonb not null default '[]'::jsonb,
  who_needs_it jsonb not null default '[]'::jsonb,
  eligibility_rules jsonb not null default '[]'::jsonb,
  how_to_do_it jsonb not null default '[]'::jsonb,
  online_process jsonb not null default '[]'::jsonb,
  in_person_process jsonb not null default '[]'::jsonb,
  pec_process jsonb not null default '[]'::jsonb,
  email_process jsonb not null default '[]'::jsonb,
  normal_mail_process jsonb not null default '[]'::jsonb,
  phone_process jsonb not null default '[]'::jsonb,
  required_documents jsonb not null default '[]'::jsonb,
  optional_documents jsonb not null default '[]'::jsonb,
  costs jsonb not null default '[]'::jsonb,
  timing jsonb not null default '[]'::jsonb,
  deadlines jsonb not null default '[]'::jsonb,
  addresses jsonb not null default '[]'::jsonb,
  offices jsonb not null default '[]'::jsonb,
  official_links jsonb not null default '[]'::jsonb,
  forms jsonb not null default '[]'::jsonb,
  pec_addresses jsonb not null default '[]'::jsonb,
  email_addresses jsonb not null default '[]'::jsonb,
  phone_numbers jsonb not null default '[]'::jsonb,
  opening_hours jsonb not null default '[]'::jsonb,
  common_mistakes jsonb not null default '[]'::jsonb,
  warnings jsonb not null default '[]'::jsonb,
  proof_to_keep jsonb not null default '[]'::jsonb,
  next_steps jsonb not null default '[]'::jsonb,
  faq jsonb not null default '[]'::jsonb,
  premium_only_guidance jsonb not null default '[]'::jsonb,
  consultancy_cta jsonb not null default '{}'::jsonb,
  problem_request_cta jsonb not null default '{}'::jsonb,
  related_procedures jsonb not null default '[]'::jsonb,
  related_terms jsonb not null default '[]'::jsonb,
  source_references jsonb not null default '[]'::jsonb,
  verification_status text not null default 'needsReview',
  last_verified_at timestamptz,
  is_active boolean not null default true,
  is_premium boolean not null default false,
  status text not null default 'draft',
  sort_order int not null default 0,
  admin_notes text,
  metadata jsonb not null default '{}'::jsonb,
  public_snapshot jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint ufficio_cms_procedures_verification_check
    check (verification_status in ('verified','needsReview','unverified')),
  constraint ufficio_cms_procedures_status_check
    check (status in ('draft','published','archived')),
  constraint ufficio_cms_procedures_slug_check
    check (slug ~ '^[a-z0-9_\\-/]+$')
);

create table if not exists public.ufficio_cms_content_blocks (
  id uuid primary key default gen_random_uuid(),
  procedure_slug text not null references public.ufficio_cms_procedures(slug) on delete cascade,
  block_type text not null,
  title jsonb not null default '{}'::jsonb,
  body jsonb not null default '{}'::jsonb,
  items jsonb not null default '[]'::jsonb,
  sort_order int not null default 0,
  is_active boolean not null default true,
  is_premium boolean not null default false,
  visibility text not null default 'public',
  warning_level text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint ufficio_cms_blocks_type_check
    check (
      block_type in (
        'intro','what_is_it','why_you_need_it','eligibility','steps','documents',
        'cost','timing','contacts','links','addresses','warning',
        'common_mistakes','proof_to_keep','faq','premium_gate',
        'consultancy_offer','problem_request_cta','source_references',
        'custom_json'
      )
    ),
  constraint ufficio_cms_blocks_visibility_check
    check (visibility in ('public','admin_only','hidden')),
  constraint ufficio_cms_blocks_warning_check
    check (warning_level is null or warning_level in ('info','warning','danger'))
);

create table if not exists public.ufficio_cms_translations (
  id uuid primary key default gen_random_uuid(),
  entity_type text not null,
  entity_id uuid,
  entity_slug text,
  field_name text not null,
  language_code text not null,
  value jsonb not null default '{}'::jsonb,
  is_active boolean not null default true,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint ufficio_cms_translations_entity_check
    check (
      entity_type in (
        'category','procedure','block','link','contact','document','source'
      )
    ),
  constraint ufficio_cms_translations_language_check
    check (language_code in ('en','it','fr','es','fa','ar'))
);

create table if not exists public.ufficio_cms_links (
  id uuid primary key default gen_random_uuid(),
  procedure_slug text not null references public.ufficio_cms_procedures(slug) on delete cascade,
  block_id uuid references public.ufficio_cms_content_blocks(id) on delete cascade,
  link_type text not null default 'official',
  label jsonb not null default '{}'::jsonb,
  description jsonb not null default '{}'::jsonb,
  url text not null,
  sort_order int not null default 0,
  is_active boolean not null default true,
  verification_status text not null default 'needsReview',
  last_verified_at timestamptz,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint ufficio_cms_links_type_check
    check (link_type in ('official','portal','form','reference','related')),
  constraint ufficio_cms_links_verification_check
    check (verification_status in ('verified','needsReview','unverified'))
);

create table if not exists public.ufficio_cms_contacts (
  id uuid primary key default gen_random_uuid(),
  procedure_slug text not null references public.ufficio_cms_procedures(slug) on delete cascade,
  block_id uuid references public.ufficio_cms_content_blocks(id) on delete cascade,
  contact_type text not null default 'office',
  name jsonb not null default '{}'::jsonb,
  label jsonb not null default '{}'::jsonb,
  address jsonb not null default '{}'::jsonb,
  phone text,
  email text,
  pec text,
  url text,
  opening_hours jsonb not null default '{}'::jsonb,
  sort_order int not null default 0,
  is_active boolean not null default true,
  verification_status text not null default 'needsReview',
  last_verified_at timestamptz,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint ufficio_cms_contacts_verification_check
    check (verification_status in ('verified','needsReview','unverified'))
);

create table if not exists public.ufficio_cms_documents (
  id uuid primary key default gen_random_uuid(),
  procedure_slug text not null references public.ufficio_cms_procedures(slug) on delete cascade,
  block_id uuid references public.ufficio_cms_content_blocks(id) on delete cascade,
  label jsonb not null default '{}'::jsonb,
  description jsonb not null default '{}'::jsonb,
  is_required boolean not null default true,
  sort_order int not null default 0,
  is_active boolean not null default true,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.ufficio_cms_sources (
  id uuid primary key default gen_random_uuid(),
  procedure_slug text not null references public.ufficio_cms_procedures(slug) on delete cascade,
  block_id uuid references public.ufficio_cms_content_blocks(id) on delete cascade,
  source_label text not null,
  source_url text not null,
  source_type text not null default 'official',
  notes text,
  last_verified_at timestamptz,
  is_active boolean not null default true,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.ufficio_cms_revisions (
  id uuid primary key default gen_random_uuid(),
  entity_type text not null,
  entity_id uuid,
  entity_slug text,
  action text not null,
  before_value jsonb not null default '{}'::jsonb,
  after_value jsonb not null default '{}'::jsonb,
  actor_user_id uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now()
);

create table if not exists public.ufficio_cms_drafts (
  id uuid primary key default gen_random_uuid(),
  entity_type text not null,
  entity_id uuid,
  entity_slug text,
  draft_value jsonb not null default '{}'::jsonb,
  status text not null default 'draft',
  actor_user_id uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint ufficio_cms_drafts_status_check
    check (status in ('draft','review','published','archived'))
);

create index if not exists idx_ufficio_admin_users_role
  on public.ufficio_admin_users(role, is_active);
create index if not exists idx_ufficio_problem_requests_user_id
  on public.ufficio_problem_requests(user_id, status, created_at desc);
create index if not exists idx_ufficio_consultancy_requests_user_id
  on public.ufficio_consultancy_requests(user_id, status, payment_status, created_at desc);
create index if not exists idx_ufficio_premium_events_user_id
  on public.ufficio_premium_events(user_id, created_at desc);
do $$
begin
  if exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'ufficio_cost_items'
      and column_name = 'user_id'
  )
  and exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'ufficio_cost_items'
      and column_name = 'status'
  )
  and exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'ufficio_cost_items'
      and column_name = 'due_date'
  ) then
    create index if not exists idx_ufficio_cost_items_user_id
      on public.ufficio_cost_items(user_id, status, due_date);
  end if;
end $$;
create index if not exists idx_ufficio_directory_contacts_user_id
  on public.ufficio_directory_contacts(user_id, category_id);
create index if not exists idx_ufficio_documents_directory_user_id
  on public.ufficio_documents_directory(user_id, category_id, status);
create index if not exists idx_ufficio_cms_categories_sort
  on public.ufficio_cms_categories(sort_order, slug);
create index if not exists idx_ufficio_cms_procedures_category
  on public.ufficio_cms_procedures(category_slug, sort_order, slug);
do $$
begin
  if exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'ufficio_cms_procedures'
      and column_name = 'status'
  )
  and exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'ufficio_cms_procedures'
      and column_name = 'is_active'
  )
  and exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'ufficio_cms_procedures'
      and column_name = 'category_slug'
  ) then
    create index if not exists idx_ufficio_cms_procedures_status
      on public.ufficio_cms_procedures(status, is_active, category_slug);
  end if;
end $$;
create index if not exists idx_ufficio_cms_blocks_procedure
  on public.ufficio_cms_content_blocks(procedure_slug, sort_order);
create index if not exists idx_ufficio_cms_links_procedure
  on public.ufficio_cms_links(procedure_slug, sort_order);
create index if not exists idx_ufficio_cms_contacts_procedure
  on public.ufficio_cms_contacts(procedure_slug, sort_order);
create index if not exists idx_ufficio_cms_documents_procedure
  on public.ufficio_cms_documents(procedure_slug, sort_order);
create index if not exists idx_ufficio_cms_sources_procedure
  on public.ufficio_cms_sources(procedure_slug, created_at desc);
create index if not exists idx_ufficio_cms_revisions_entity
  on public.ufficio_cms_revisions(entity_type, entity_slug, created_at desc);
create index if not exists idx_ufficio_cms_drafts_entity
  on public.ufficio_cms_drafts(entity_type, entity_slug, updated_at desc);

drop trigger if exists trg_ufficio_admin_users_updated_at on public.ufficio_admin_users;
create trigger trg_ufficio_admin_users_updated_at
before update on public.ufficio_admin_users
for each row execute function public.ufficio_touch_updated_at();

drop trigger if exists trg_ufficio_problem_requests_updated_at on public.ufficio_problem_requests;
create trigger trg_ufficio_problem_requests_updated_at
before update on public.ufficio_problem_requests
for each row execute function public.ufficio_touch_updated_at();

drop trigger if exists trg_ufficio_consultancy_requests_updated_at on public.ufficio_consultancy_requests;
create trigger trg_ufficio_consultancy_requests_updated_at
before update on public.ufficio_consultancy_requests
for each row execute function public.ufficio_touch_updated_at();

drop trigger if exists trg_ufficio_cost_items_updated_at on public.ufficio_cost_items;
create trigger trg_ufficio_cost_items_updated_at
before update on public.ufficio_cost_items
for each row execute function public.ufficio_touch_updated_at();

drop trigger if exists trg_ufficio_directory_contacts_updated_at on public.ufficio_directory_contacts;
create trigger trg_ufficio_directory_contacts_updated_at
before update on public.ufficio_directory_contacts
for each row execute function public.ufficio_touch_updated_at();

drop trigger if exists trg_ufficio_documents_directory_updated_at on public.ufficio_documents_directory;
create trigger trg_ufficio_documents_directory_updated_at
before update on public.ufficio_documents_directory
for each row execute function public.ufficio_touch_updated_at();

drop trigger if exists trg_ufficio_cms_categories_updated_at on public.ufficio_cms_categories;
create trigger trg_ufficio_cms_categories_updated_at
before update on public.ufficio_cms_categories
for each row execute function public.ufficio_touch_updated_at();

drop trigger if exists trg_ufficio_cms_procedures_updated_at on public.ufficio_cms_procedures;
create trigger trg_ufficio_cms_procedures_updated_at
before update on public.ufficio_cms_procedures
for each row execute function public.ufficio_touch_updated_at();

drop trigger if exists trg_ufficio_cms_content_blocks_updated_at on public.ufficio_cms_content_blocks;
create trigger trg_ufficio_cms_content_blocks_updated_at
before update on public.ufficio_cms_content_blocks
for each row execute function public.ufficio_touch_updated_at();

drop trigger if exists trg_ufficio_cms_translations_updated_at on public.ufficio_cms_translations;
create trigger trg_ufficio_cms_translations_updated_at
before update on public.ufficio_cms_translations
for each row execute function public.ufficio_touch_updated_at();

drop trigger if exists trg_ufficio_cms_links_updated_at on public.ufficio_cms_links;
create trigger trg_ufficio_cms_links_updated_at
before update on public.ufficio_cms_links
for each row execute function public.ufficio_touch_updated_at();

drop trigger if exists trg_ufficio_cms_contacts_updated_at on public.ufficio_cms_contacts;
create trigger trg_ufficio_cms_contacts_updated_at
before update on public.ufficio_cms_contacts
for each row execute function public.ufficio_touch_updated_at();

drop trigger if exists trg_ufficio_cms_documents_updated_at on public.ufficio_cms_documents;
create trigger trg_ufficio_cms_documents_updated_at
before update on public.ufficio_cms_documents
for each row execute function public.ufficio_touch_updated_at();

drop trigger if exists trg_ufficio_cms_sources_updated_at on public.ufficio_cms_sources;
create trigger trg_ufficio_cms_sources_updated_at
before update on public.ufficio_cms_sources
for each row execute function public.ufficio_touch_updated_at();

drop trigger if exists trg_ufficio_cms_drafts_updated_at on public.ufficio_cms_drafts;
create trigger trg_ufficio_cms_drafts_updated_at
before update on public.ufficio_cms_drafts
for each row execute function public.ufficio_touch_updated_at();

create or replace function public.get_current_admin_role()
returns text
language sql
stable
security definer
set search_path = public
as $$
  select role
  from public.ufficio_admin_users
  where user_id = auth.uid()
    and is_active = true
  limit 1;
$$;

create or replace function public.has_ufficio_role(required_roles text[])
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(public.get_current_admin_role() = any(required_roles), false);
$$;

create or replace function public.is_ufficio_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select auth.uid() is not null
    and public.has_ufficio_role(array['owner','admin','editor','support','viewer']);
$$;

create or replace function public.is_ufficcio_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select public.is_ufficio_admin();
$$;

create or replace function public.prevent_removing_last_owner()
returns trigger
language plpgsql
set search_path = public
as $$
declare
  active_owner_count integer;
begin
  if tg_op = 'DELETE' then
    if old.role = 'owner' and old.is_active then
      select count(*) into active_owner_count
      from public.ufficio_admin_users
      where role = 'owner' and is_active = true;
      if active_owner_count <= 1 then
        raise exception 'Cannot remove the last active owner.';
      end if;
    end if;
    return old;
  end if;

  if old.role = 'owner'
     and old.is_active = true
     and (new.role <> 'owner' or new.is_active = false) then
    select count(*) into active_owner_count
    from public.ufficio_admin_users
    where role = 'owner' and is_active = true;
    if active_owner_count <= 1 then
      raise exception 'Cannot deactivate or demote the last active owner.';
    end if;
  end if;
  return new;
end;
$$;

drop trigger if exists trg_prevent_removing_last_owner on public.ufficio_admin_users;
create trigger trg_prevent_removing_last_owner
before update or delete on public.ufficio_admin_users
for each row execute function public.prevent_removing_last_owner();

do $$
begin
  if exists (
    select 1
    from pg_constraint
    where conname = 'ufficcio_user_settings_language_check'
      and conrelid = 'public.ufficcio_user_settings'::regclass
  ) then
    alter table public.ufficcio_user_settings
      drop constraint ufficcio_user_settings_language_check;
  end if;
end $$;

alter table public.ufficcio_user_settings
  add constraint ufficcio_user_settings_language_check
  check (selected_language in ('it','en','fr','es','fa','ar'));
