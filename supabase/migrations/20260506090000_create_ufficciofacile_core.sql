create extension if not exists pgcrypto;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create or replace function public.is_ufficcio_admin()
returns boolean
language sql
stable
as $$
  select false;
$$;

create table if not exists public.ufficcio_profiles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  full_name text,
  codice_fiscale text,
  date_of_birth date,
  nationality text,
  phone text,
  email text,
  city text,
  address text,
  preferred_language text not null default 'en',
  has_spid boolean not null default false,
  has_cie boolean not null default false,
  has_pec boolean not null default false,
  student_status text,
  university_name text,
  matricola text,
  work_status text,
  employer_name text,
  contract_type text,
  house_status text,
  landlord_name text,
  electricity_provider text,
  gas_provider text,
  internet_provider text,
  default_asl text,
  default_comune text,
  default_patronato text,
  notes text,
  is_demo boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(user_id)
);

create table if not exists public.ufficcio_user_settings (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  selected_language text not null default 'en',
  onboarding_completed boolean not null default false,
  sync_enabled boolean not null default false,
  analytics_enabled boolean not null default true,
  beta_mode_enabled boolean not null default true,
  admin_debug_enabled boolean not null default false,
  paywall_enabled boolean not null default false,
  theme_mode text not null default 'system',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(user_id),
  constraint ufficcio_user_settings_language_check
    check (selected_language in ('it','en','es','fa','ar')),
  constraint ufficcio_user_settings_theme_check
    check (theme_mode in ('system','light','dark'))
);

create table if not exists public.ufficcio_requests (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  local_id text,
  procedure_id text not null,
  procedure_title text not null,
  category text not null,
  subcategory text,
  status text not null default 'generated',
  priority text not null default 'normal',
  input_data jsonb not null default '{}'::jsonb,
  readiness jsonb not null default '{}'::jsonb,
  red_flags jsonb not null default '[]'::jsonb,
  recipient_contact_id uuid,
  recipient_name text,
  recipient_email text,
  recipient_pec text,
  subject text,
  deadline_date date,
  sent_at timestamptz,
  replied_at timestamptz,
  completed_at timestamptz,
  archived_at timestamptz,
  last_copied_at timestamptz,
  notes text,
  is_demo boolean not null default false,
  deleted_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint ufficcio_requests_status_check
    check (status in ('draft','generated','sent','follow_up_needed','replied','rejected','completed','archived')),
  constraint ufficcio_requests_priority_check
    check (priority in ('low','normal','high','urgent'))
);

create table if not exists public.ufficcio_generated_packs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  request_id uuid not null references public.ufficcio_requests(id) on delete cascade,
  local_id text,
  version int not null default 1,
  subject text,
  body_italian text,
  body_pec_italian text,
  short_message_italian text,
  whatsapp_message_italian text,
  whatsapp_follow_up_italian text,
  follow_up_italian text,
  strong_follow_up_italian text,
  user_explanation jsonb not null default '{}'::jsonb,
  attachment_checklist jsonb not null default '[]'::jsonb,
  next_steps jsonb not null default '[]'::jsonb,
  warnings jsonb not null default '[]'::jsonb,
  deadline_suggestions jsonb not null default '[]'::jsonb,
  full_text text,
  quality_report jsonb not null default '{}'::jsonb,
  disclaimer_included boolean not null default true,
  is_demo boolean not null default false,
  deleted_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.ufficcio_status_events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  request_id uuid not null references public.ufficcio_requests(id) on delete cascade,
  old_status text,
  new_status text not null,
  event_type text not null default 'status_change',
  note text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists public.ufficcio_reminders (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  request_id uuid references public.ufficcio_requests(id) on delete set null,
  document_id uuid,
  contract_id uuid,
  local_id text,
  title text not null,
  description text,
  reminder_date date not null,
  reminder_type text not null default 'follow_up',
  priority text not null default 'normal',
  is_done boolean not null default false,
  is_demo boolean not null default false,
  deleted_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint ufficcio_reminders_type_check
    check (reminder_type in ('follow_up','deadline','appointment','renewal','expiry','custom')),
  constraint ufficcio_reminders_priority_check
    check (priority in ('low','normal','high','urgent'))
);

create table if not exists public.ufficcio_documents (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  local_id text,
  household_member_id uuid,
  type text not null,
  title text not null,
  description text,
  has_document boolean not null default false,
  expiry_date date,
  file_name text,
  storage_bucket text,
  storage_path text,
  mime_type text,
  size_bytes bigint,
  notes text,
  is_demo boolean not null default false,
  deleted_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.ufficcio_contacts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  local_id text,
  type text not null,
  name text not null,
  email text,
  pec text,
  phone text,
  website text,
  address text,
  city text,
  notes text,
  is_demo boolean not null default false,
  deleted_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.ufficcio_household_members (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  local_id text,
  display_name text not null,
  relationship text not null default 'self',
  full_name text,
  codice_fiscale text,
  date_of_birth date,
  email text,
  phone text,
  nationality text,
  notes text,
  is_primary boolean not null default false,
  is_demo boolean not null default false,
  deleted_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint ufficcio_household_relationship_check
    check (relationship in ('self','spouse','partner','child','roommate','client','other'))
);

create table if not exists public.ufficcio_household_contracts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  local_id text,
  type text not null,
  provider_name text not null,
  contract_name text,
  monthly_cost numeric,
  annual_cost numeric,
  start_date date,
  end_date date,
  renewal_date date,
  cancellation_notice_days int,
  customer_code text,
  contract_number text,
  notes text,
  is_demo boolean not null default false,
  deleted_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.ufficcio_utility_comparisons (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  local_id text,
  utility_type text not null,
  input_data jsonb not null default '{}'::jsonb,
  result_data jsonb not null default '{}'::jsonb,
  best_offer_name text,
  estimated_annual_savings numeric,
  estimated_monthly_savings numeric,
  risk_flags jsonb not null default '[]'::jsonb,
  is_demo boolean not null default false,
  deleted_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint ufficcio_utility_type_check
    check (utility_type in ('electricity','gas','dual','water','internet','other'))
);

create table if not exists public.ufficcio_bill_analyses (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  local_id text,
  bill_type text not null,
  provider text,
  bill_period text,
  amount numeric,
  input_data jsonb not null default '{}'::jsonb,
  result_data jsonb not null default '{}'::jsonb,
  red_flags jsonb not null default '[]'::jsonb,
  recommended_procedure_ids text[] not null default '{}',
  is_demo boolean not null default false,
  deleted_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.ufficcio_proof_cases (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  local_id text,
  related_request_id uuid references public.ufficcio_requests(id) on delete set null,
  title text not null,
  category text not null,
  status text not null default 'open',
  notes text,
  is_demo boolean not null default false,
  deleted_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint ufficcio_proof_case_status_check
    check (status in ('open','sent','waiting','resolved','archived'))
);

create table if not exists public.ufficcio_proof_items (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  proof_case_id uuid not null references public.ufficcio_proof_cases(id) on delete cascade,
  local_id text,
  type text not null,
  title text not null,
  description text,
  item_date date,
  file_name text,
  storage_bucket text,
  storage_path text,
  mime_type text,
  size_bytes bigint,
  reference_number text,
  notes text,
  is_demo boolean not null default false,
  deleted_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.ufficcio_checklist_items (
  id text primary key,
  category text not null,
  title_key text not null,
  description_key text,
  mode text,
  priority text not null default 'normal',
  related_procedure_ids text[] not null default '{}',
  related_document_types text[] not null default '{}',
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.ufficcio_user_checklist_state (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  checklist_item_id text not null,
  status text not null default 'not_started',
  reminder_date date,
  notes text,
  updated_at timestamptz not null default now(),
  unique(user_id, checklist_item_id),
  constraint ufficcio_user_checklist_status_check
    check (status in ('not_started','in_progress','done','not_applicable'))
);

create table if not exists public.ufficcio_city_packs (
  id text primary key,
  city_name text not null,
  region text,
  description jsonb not null default '{}'::jsonb,
  recommended_procedure_ids text[] not null default '{}',
  common_topics jsonb not null default '[]'::jsonb,
  official_links jsonb not null default '[]'::jsonb,
  local_notes jsonb not null default '{}'::jsonb,
  student_tips jsonb not null default '{}'::jsonb,
  tenant_tips jsonb not null default '{}'::jsonb,
  utility_tips jsonb not null default '{}'::jsonb,
  health_tips jsonb not null default '{}'::jsonb,
  university_tips jsonb not null default '{}'::jsonb,
  warnings jsonb not null default '{}'::jsonb,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.ufficcio_official_links (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  category text not null,
  description jsonb not null default '{}'::jsonb,
  url text,
  country text not null default 'IT',
  region text,
  city text,
  related_procedure_ids text[] not null default '{}',
  verification_status text not null default 'unverified',
  last_verified_at timestamptz,
  warning jsonb not null default '{}'::jsonb,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint ufficcio_official_links_status_check
    check (verification_status in ('unverified','needs_review','verified'))
);

create table if not exists public.ufficcio_template_overrides (
  id uuid primary key default gen_random_uuid(),
  procedure_id text not null,
  override_data jsonb not null default '{}'::jsonb,
  is_active boolean not null default true,
  is_premium boolean not null default false,
  updated_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.ufficcio_community_templates (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete set null,
  title text not null,
  category text not null,
  language text not null default 'it',
  official_text_italian text,
  explanation jsonb not null default '{}'::jsonb,
  tags text[] not null default '{}',
  status text not null default 'draft',
  reviewed_by uuid references auth.users(id) on delete set null,
  reviewed_at timestamptz,
  is_demo boolean not null default false,
  deleted_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint ufficcio_community_templates_status_check
    check (status in ('draft','local','submitted','approved','rejected'))
);

create table if not exists public.ufficcio_usage_events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete set null,
  anonymous_session_id text,
  event_name text not null,
  procedure_id text,
  request_id uuid,
  category text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists public.ufficcio_feedback (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete set null,
  category text,
  message text not null,
  rating int,
  related_procedure_id text,
  contact_email text,
  status text not null default 'new',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint ufficcio_feedback_rating_check
    check (rating is null or rating between 1 and 5),
  constraint ufficcio_feedback_status_check
    check (status in ('new','reviewed','archived'))
);

create table if not exists public.ufficcio_entitlements (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  plan text not null default 'free',
  status text not null default 'active',
  free_pack_limit int not null default 5,
  free_packs_used int not null default 0,
  premium_access boolean not null default false,
  current_period_start timestamptz,
  current_period_end timestamptz,
  provider text,
  provider_customer_id text,
  provider_subscription_id text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(user_id),
  constraint ufficcio_entitlements_plan_check
    check (plan in ('free','pro','consultant','admin')),
  constraint ufficcio_entitlements_status_check
    check (status in ('active','trialing','past_due','cancelled','expired'))
);

create table if not exists public.ufficcio_admin_config (
  id uuid primary key default gen_random_uuid(),
  key text unique not null,
  value jsonb not null default '{}'::jsonb,
  updated_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.ufficcio_sync_log (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade,
  sync_type text not null,
  status text not null,
  started_at timestamptz not null default now(),
  completed_at timestamptz,
  error_code text,
  error_message text,
  pushed_count int not null default 0,
  pulled_count int not null default 0,
  conflict_count int not null default 0,
  metadata jsonb not null default '{}'::jsonb
);

create table if not exists public.ufficcio_delete_requests (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete set null,
  status text not null default 'requested',
  requested_at timestamptz not null default now(),
  completed_at timestamptz,
  notes text,
  constraint ufficcio_delete_requests_status_check
    check (status in ('requested','processing','completed','failed'))
);

create index if not exists idx_ufficcio_profiles_user_id on public.ufficcio_profiles(user_id);
create index if not exists idx_ufficcio_requests_user_id on public.ufficcio_requests(user_id);
create index if not exists idx_ufficcio_requests_local_id on public.ufficcio_requests(local_id);
create index if not exists idx_ufficcio_requests_procedure_id on public.ufficcio_requests(procedure_id);
create index if not exists idx_ufficcio_requests_category on public.ufficcio_requests(category);
create index if not exists idx_ufficcio_requests_status on public.ufficcio_requests(status);
create index if not exists idx_ufficcio_requests_deadline on public.ufficcio_requests(deadline_date);
create index if not exists idx_ufficcio_requests_deleted_at on public.ufficcio_requests(deleted_at);
create index if not exists idx_ufficcio_generated_packs_user_id on public.ufficcio_generated_packs(user_id);
create index if not exists idx_ufficcio_generated_packs_request_id on public.ufficcio_generated_packs(request_id);
create index if not exists idx_ufficcio_generated_packs_deleted_at on public.ufficcio_generated_packs(deleted_at);
create index if not exists idx_ufficcio_status_events_user_id on public.ufficcio_status_events(user_id);
create index if not exists idx_ufficcio_status_events_request_id on public.ufficcio_status_events(request_id);
create index if not exists idx_ufficcio_reminders_user_id on public.ufficcio_reminders(user_id);
create index if not exists idx_ufficcio_reminders_request_id on public.ufficcio_reminders(request_id);
create index if not exists idx_ufficcio_reminders_date on public.ufficcio_reminders(reminder_date);
create index if not exists idx_ufficcio_reminders_deleted_at on public.ufficcio_reminders(deleted_at);
create index if not exists idx_ufficcio_documents_user_id on public.ufficcio_documents(user_id);
create index if not exists idx_ufficcio_documents_type on public.ufficcio_documents(type);
create index if not exists idx_ufficcio_documents_expiry_date on public.ufficcio_documents(expiry_date);
create index if not exists idx_ufficcio_contacts_user_id on public.ufficcio_contacts(user_id);
create index if not exists idx_ufficcio_contacts_type on public.ufficcio_contacts(type);
create index if not exists idx_ufficcio_household_members_user_id on public.ufficcio_household_members(user_id);
create index if not exists idx_ufficcio_household_contracts_user_id on public.ufficcio_household_contracts(user_id);
create index if not exists idx_ufficcio_household_contracts_renewal_date on public.ufficcio_household_contracts(renewal_date);
create index if not exists idx_ufficcio_utility_comparisons_user_id on public.ufficcio_utility_comparisons(user_id);
create index if not exists idx_ufficcio_bill_analyses_user_id on public.ufficcio_bill_analyses(user_id);
create index if not exists idx_ufficcio_proof_cases_user_id on public.ufficcio_proof_cases(user_id);
create index if not exists idx_ufficcio_proof_items_user_id on public.ufficcio_proof_items(user_id);
create index if not exists idx_ufficcio_user_checklist_state_user_id on public.ufficcio_user_checklist_state(user_id);
create index if not exists idx_ufficcio_city_packs_active on public.ufficcio_city_packs(is_active);
create index if not exists idx_ufficcio_official_links_status on public.ufficcio_official_links(verification_status);
create index if not exists idx_ufficcio_template_overrides_procedure_id on public.ufficcio_template_overrides(procedure_id);
create index if not exists idx_ufficcio_community_templates_user_id on public.ufficcio_community_templates(user_id);
create index if not exists idx_ufficcio_usage_events_user_id on public.ufficcio_usage_events(user_id);
create index if not exists idx_ufficcio_usage_events_event_name on public.ufficcio_usage_events(event_name);
create index if not exists idx_ufficcio_feedback_user_id on public.ufficcio_feedback(user_id);
create index if not exists idx_ufficcio_entitlements_user_id on public.ufficcio_entitlements(user_id);
create index if not exists idx_ufficcio_sync_log_user_id on public.ufficcio_sync_log(user_id);
create index if not exists idx_ufficcio_delete_requests_user_id on public.ufficcio_delete_requests(user_id);

create or replace trigger trg_ufficcio_profiles_updated_at
before update on public.ufficcio_profiles
for each row execute function public.set_updated_at();
create or replace trigger trg_ufficcio_user_settings_updated_at
before update on public.ufficcio_user_settings
for each row execute function public.set_updated_at();
create or replace trigger trg_ufficcio_requests_updated_at
before update on public.ufficcio_requests
for each row execute function public.set_updated_at();
create or replace trigger trg_ufficcio_generated_packs_updated_at
before update on public.ufficcio_generated_packs
for each row execute function public.set_updated_at();
create or replace trigger trg_ufficcio_reminders_updated_at
before update on public.ufficcio_reminders
for each row execute function public.set_updated_at();
create or replace trigger trg_ufficcio_documents_updated_at
before update on public.ufficcio_documents
for each row execute function public.set_updated_at();
create or replace trigger trg_ufficcio_contacts_updated_at
before update on public.ufficcio_contacts
for each row execute function public.set_updated_at();
create or replace trigger trg_ufficcio_household_members_updated_at
before update on public.ufficcio_household_members
for each row execute function public.set_updated_at();
create or replace trigger trg_ufficcio_household_contracts_updated_at
before update on public.ufficcio_household_contracts
for each row execute function public.set_updated_at();
create or replace trigger trg_ufficcio_utility_comparisons_updated_at
before update on public.ufficcio_utility_comparisons
for each row execute function public.set_updated_at();
create or replace trigger trg_ufficcio_bill_analyses_updated_at
before update on public.ufficcio_bill_analyses
for each row execute function public.set_updated_at();
create or replace trigger trg_ufficcio_proof_cases_updated_at
before update on public.ufficcio_proof_cases
for each row execute function public.set_updated_at();
create or replace trigger trg_ufficcio_proof_items_updated_at
before update on public.ufficcio_proof_items
for each row execute function public.set_updated_at();
create or replace trigger trg_ufficcio_checklist_items_updated_at
before update on public.ufficcio_checklist_items
for each row execute function public.set_updated_at();
create or replace trigger trg_ufficcio_city_packs_updated_at
before update on public.ufficcio_city_packs
for each row execute function public.set_updated_at();
create or replace trigger trg_ufficcio_official_links_updated_at
before update on public.ufficcio_official_links
for each row execute function public.set_updated_at();
create or replace trigger trg_ufficcio_template_overrides_updated_at
before update on public.ufficcio_template_overrides
for each row execute function public.set_updated_at();
create or replace trigger trg_ufficcio_community_templates_updated_at
before update on public.ufficcio_community_templates
for each row execute function public.set_updated_at();
create or replace trigger trg_ufficcio_feedback_updated_at
before update on public.ufficcio_feedback
for each row execute function public.set_updated_at();
create or replace trigger trg_ufficcio_entitlements_updated_at
before update on public.ufficcio_entitlements
for each row execute function public.set_updated_at();
create or replace trigger trg_ufficcio_admin_config_updated_at
before update on public.ufficcio_admin_config
for each row execute function public.set_updated_at();
