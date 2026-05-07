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

create or replace function public.is_ufficio_admin()
returns boolean
language sql
stable
as $$
  select false;
$$;

create table if not exists public.ufficio_catalog_sources (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  source_type text not null,
  source_url text not null,
  source_label text not null default '',
  authority_name text,
  jurisdiction text not null default 'national',
  region text,
  city text,
  provider text,
  verification_status text not null default 'needsReview',
  last_verified_at timestamptz,
  warning jsonb not null default '{}'::jsonb,
  notes jsonb not null default '{}'::jsonb,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint ufficio_catalog_sources_verification_check
    check (verification_status in ('verified','needsReview','unverified'))
);

create table if not exists public.ufficio_official_links (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  url text,
  category text not null,
  description jsonb not null default '{}'::jsonb,
  procedure_ids text[] not null default '{}'::text[],
  jurisdiction text not null default 'national',
  region text,
  city text,
  provider_id text,
  provider_name text,
  source_url text,
  source_label text,
  verification_status text not null default 'needsReview',
  last_verified_at timestamptz,
  warning jsonb not null default '{}'::jsonb,
  notes jsonb not null default '{}'::jsonb,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint ufficio_official_links_verification_check
    check (verification_status in ('verified','needsReview','unverified')),
  constraint ufficio_official_links_verified_source_check
    check (
      verification_status <> 'verified'
      or coalesce(nullif(url, ''), nullif(source_url, '')) is not null
    )
);

create table if not exists public.ufficio_official_contacts (
  id uuid primary key default gen_random_uuid(),
  label text not null,
  contact_type text not null,
  value text,
  display_value text not null default '',
  category text not null,
  authority_type text,
  procedure_ids text[] not null default '{}'::text[],
  jurisdiction text not null default 'national',
  region text,
  city text,
  provider_id text,
  provider_name text,
  source_url text,
  source_label text,
  verification_status text not null default 'needsReview',
  last_verified_at timestamptz,
  warning jsonb not null default '{}'::jsonb,
  notes jsonb not null default '{}'::jsonb,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint ufficio_official_contacts_verification_check
    check (verification_status in ('verified','needsReview','unverified')),
  constraint ufficio_official_contacts_verified_source_check
    check (
      verification_status <> 'verified'
      or (
        nullif(source_url, '') is not null
        and last_verified_at is not null
      )
    )
);

create table if not exists public.ufficio_service_providers (
  id text primary key,
  name text not null,
  normalized_name text not null,
  category text not null,
  website_url text,
  customer_area_url text,
  cancellation_page_url text,
  complaint_page_url text,
  modem_return_guidance jsonb not null default '{}'::jsonb,
  cancellation_guidance jsonb not null default '{}'::jsonb,
  complaint_guidance jsonb not null default '{}'::jsonb,
  payment_plan_guidance jsonb not null default '{}'::jsonb,
  source_references text[] not null default '{}'::text[],
  verification_status text not null default 'needsReview',
  last_verified_at timestamptz,
  warning jsonb not null default '{}'::jsonb,
  notes jsonb not null default '{}'::jsonb,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint ufficio_service_providers_verification_check
    check (verification_status in ('verified','needsReview','unverified'))
);

create table if not exists public.ufficio_provider_forms (
  id text primary key,
  provider_id text not null references public.ufficio_service_providers(id) on delete cascade,
  provider_name text not null,
  form_type text not null,
  title text not null,
  description jsonb not null default '{}'::jsonb,
  url text,
  procedure_ids text[] not null default '{}'::text[],
  required_fields jsonb not null default '[]'::jsonb,
  required_documents jsonb not null default '[]'::jsonb,
  submission_channels text[] not null default '{}'::text[],
  source_url text,
  source_label text,
  verification_status text not null default 'needsReview',
  last_verified_at timestamptz,
  warning jsonb not null default '{}'::jsonb,
  notes jsonb not null default '{}'::jsonb,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint ufficio_provider_forms_verification_check
    check (verification_status in ('verified','needsReview','unverified')),
  constraint ufficio_provider_forms_verified_source_check
    check (
      verification_status <> 'verified'
      or coalesce(nullif(url, ''), nullif(source_url, '')) is not null
    )
);

create table if not exists public.ufficio_provider_contact_options (
  id text primary key,
  provider_id text not null references public.ufficio_service_providers(id) on delete cascade,
  provider_name text not null,
  contact_type text not null,
  label text not null,
  value text,
  url text,
  description jsonb not null default '{}'::jsonb,
  procedure_ids text[] not null default '{}'::text[],
  source_url text,
  source_label text,
  verification_status text not null default 'needsReview',
  last_verified_at timestamptz,
  warning jsonb not null default '{}'::jsonb,
  notes jsonb not null default '{}'::jsonb,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint ufficio_provider_contact_options_verification_check
    check (verification_status in ('verified','needsReview','unverified')),
  constraint ufficio_provider_contact_options_verified_source_check
    check (
      verification_status <> 'verified'
      or (
        nullif(source_url, '') is not null
        and last_verified_at is not null
      )
    )
);

create table if not exists public.ufficio_region_guidance (
  id text primary key,
  region text not null,
  category text not null,
  title text not null,
  description jsonb not null default '{}'::jsonb,
  procedure_ids text[] not null default '{}'::text[],
  portal_links jsonb not null default '[]'::jsonb,
  contact_guidance jsonb not null default '{}'::jsonb,
  in_person_guidance jsonb not null default '{}'::jsonb,
  source_url text,
  source_label text,
  verification_status text not null default 'needsReview',
  last_verified_at timestamptz,
  warning jsonb not null default '{}'::jsonb,
  notes jsonb not null default '{}'::jsonb,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint ufficio_region_guidance_verification_check
    check (verification_status in ('verified','needsReview','unverified'))
);

create table if not exists public.ufficio_city_guidance (
  id text primary key,
  city text not null,
  region text,
  category text not null,
  title text not null,
  description jsonb not null default '{}'::jsonb,
  procedure_ids text[] not null default '{}'::text[],
  office_links jsonb not null default '[]'::jsonb,
  contact_guidance jsonb not null default '{}'::jsonb,
  in_person_guidance jsonb not null default '{}'::jsonb,
  source_url text,
  source_label text,
  verification_status text not null default 'needsReview',
  last_verified_at timestamptz,
  warning jsonb not null default '{}'::jsonb,
  notes jsonb not null default '{}'::jsonb,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint ufficio_city_guidance_verification_check
    check (verification_status in ('verified','needsReview','unverified'))
);

create table if not exists public.ufficio_authority_guidance (
  id text primary key,
  authority_name text not null,
  authority_type text not null,
  category text not null,
  title text not null,
  description jsonb not null default '{}'::jsonb,
  procedure_ids text[] not null default '{}'::text[],
  official_links jsonb not null default '[]'::jsonb,
  contact_guidance jsonb not null default '{}'::jsonb,
  source_url text,
  source_label text,
  verification_status text not null default 'needsReview',
  last_verified_at timestamptz,
  warning jsonb not null default '{}'::jsonb,
  notes jsonb not null default '{}'::jsonb,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint ufficio_authority_guidance_verification_check
    check (verification_status in ('verified','needsReview','unverified'))
);

create table if not exists public.ufficio_procedure_guidance (
  id text primary key,
  procedure_id text unique not null,
  category text not null,
  title text not null,
  summary jsonb not null default '{}'::jsonb,
  destination_guidance jsonb not null default '{}'::jsonb,
  contact_rules jsonb not null default '{}'::jsonb,
  provider_rules jsonb not null default '{}'::jsonb,
  city_region_rules jsonb not null default '{}'::jsonb,
  submission_channels text[] not null default '{}'::text[],
  official_links text[] not null default '{}'::text[],
  official_contacts text[] not null default '{}'::text[],
  provider_ids text[] not null default '{}'::text[],
  region_ids text[] not null default '{}'::text[],
  city_ids text[] not null default '{}'::text[],
  required_documents text[] not null default '{}'::text[],
  recommended_documents text[] not null default '{}'::text[],
  proof_items text[] not null default '{}'::text[],
  source_references text[] not null default '{}'::text[],
  before_sending_checklist text[] not null default '{}'::text[],
  warning jsonb not null default '{}'::jsonb,
  verification_status text not null default 'needsReview',
  last_verified_at timestamptz,
  notes jsonb not null default '{}'::jsonb,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint ufficio_procedure_guidance_verification_check
    check (verification_status in ('verified','needsReview','unverified'))
);

create table if not exists public.ufficio_source_references (
  id text primary key,
  title text not null,
  source_type text not null,
  reference_label text,
  url text,
  explanation jsonb not null default '{}'::jsonb,
  relevance jsonb not null default '{}'::jsonb,
  procedure_ids text[] not null default '{}'::text[],
  verification_status text not null default 'needsReview',
  last_verified_at timestamptz,
  warning jsonb not null default '{}'::jsonb,
  notes jsonb not null default '{}'::jsonb,
  not_legal_advice boolean not null default true,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint ufficio_source_references_verification_check
    check (verification_status in ('verified','needsReview','unverified'))
);

create table if not exists public.ufficio_service_terms (
  id text primary key,
  term text not null,
  short_definition jsonb not null default '{}'::jsonb,
  long_explanation jsonb not null default '{}'::jsonb,
  related_links text[] not null default '{}'::text[],
  provider_examples text[] not null default '{}'::text[],
  warnings jsonb not null default '{}'::jsonb,
  verification_status text not null default 'needsReview',
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint ufficio_service_terms_verification_check
    check (verification_status in ('verified','needsReview','unverified'))
);

create table if not exists public.ufficio_submission_channels (
  id text primary key,
  type text not null,
  title_localized jsonb not null default '{}'::jsonb,
  description_localized jsonb not null default '{}'::jsonb,
  when_to_use_localized jsonb not null default '{}'::jsonb,
  pros_localized jsonb not null default '{}'::jsonb,
  cons_localized jsonb not null default '{}'::jsonb,
  required_data text[] not null default '{}'::text[],
  required_documents text[] not null default '{}'::text[],
  proof_to_keep text[] not null default '{}'::text[],
  cost_notes_localized jsonb not null default '{}'::jsonb,
  time_notes_localized jsonb not null default '{}'::jsonb,
  legal_weight_localized jsonb not null default '{}'::jsonb,
  steps_localized text[] not null default '{}'::text[],
  official_links text[] not null default '{}'::text[],
  verification_status text not null default 'needsReview',
  warning jsonb not null default '{}'::jsonb,
  related_terms text[] not null default '{}'::text[],
  is_recommended_for_procedure boolean not null default false,
  priority int not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint ufficio_submission_channels_verification_check
    check (verification_status in ('verified','needsReview','unverified'))
);

create table if not exists public.ufficio_app_public_config (
  key text primary key,
  value jsonb not null default '{}'::jsonb,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.ufficio_premium_public_config (
  key text primary key,
  value jsonb not null default '{}'::jsonb,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create trigger ufficio_catalog_sources_updated_at
before update on public.ufficio_catalog_sources
for each row execute function public.ufficio_set_updated_at();

create trigger ufficio_official_links_updated_at
before update on public.ufficio_official_links
for each row execute function public.ufficio_set_updated_at();

create trigger ufficio_official_contacts_updated_at
before update on public.ufficio_official_contacts
for each row execute function public.ufficio_set_updated_at();

create trigger ufficio_service_providers_updated_at
before update on public.ufficio_service_providers
for each row execute function public.ufficio_set_updated_at();

create trigger ufficio_provider_forms_updated_at
before update on public.ufficio_provider_forms
for each row execute function public.ufficio_set_updated_at();

create trigger ufficio_provider_contact_options_updated_at
before update on public.ufficio_provider_contact_options
for each row execute function public.ufficio_set_updated_at();

create trigger ufficio_region_guidance_updated_at
before update on public.ufficio_region_guidance
for each row execute function public.ufficio_set_updated_at();

create trigger ufficio_city_guidance_updated_at
before update on public.ufficio_city_guidance
for each row execute function public.ufficio_set_updated_at();

create trigger ufficio_authority_guidance_updated_at
before update on public.ufficio_authority_guidance
for each row execute function public.ufficio_set_updated_at();

create trigger ufficio_procedure_guidance_updated_at
before update on public.ufficio_procedure_guidance
for each row execute function public.ufficio_set_updated_at();

create trigger ufficio_source_references_updated_at
before update on public.ufficio_source_references
for each row execute function public.ufficio_set_updated_at();

create trigger ufficio_service_terms_updated_at
before update on public.ufficio_service_terms
for each row execute function public.ufficio_set_updated_at();

create trigger ufficio_submission_channels_updated_at
before update on public.ufficio_submission_channels
for each row execute function public.ufficio_set_updated_at();

create trigger ufficio_app_public_config_updated_at
before update on public.ufficio_app_public_config
for each row execute function public.ufficio_set_updated_at();

create trigger ufficio_premium_public_config_updated_at
before update on public.ufficio_premium_public_config
for each row execute function public.ufficio_set_updated_at();
