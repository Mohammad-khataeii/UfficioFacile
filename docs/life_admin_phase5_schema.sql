-- Phase 5 local/backend readiness schema notes for Italy Life Admin Copilot.
-- This file is documentation-only in the current workspace.

create table if not exists life_admin_household_members (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade,
  display_name text not null,
  relationship text not null,
  full_name text,
  codice_fiscale text,
  date_of_birth date,
  email text,
  phone text,
  nationality text,
  notes text,
  is_primary boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists life_admin_clients (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade,
  display_name text not null,
  full_name text,
  email text,
  phone text,
  city text,
  preferred_language text,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists life_admin_city_packs (
  id text primary key,
  city_name text not null,
  region text not null,
  description_localized jsonb not null default '{}',
  recommended_procedures jsonb not null default '[]',
  common_topics jsonb not null default '[]',
  official_links jsonb not null default '[]',
  local_notes jsonb not null default '[]',
  student_tips jsonb not null default '[]',
  tenant_tips jsonb not null default '[]',
  utility_tips jsonb not null default '[]',
  health_tips jsonb not null default '[]',
  university_tips jsonb not null default '[]',
  warnings jsonb not null default '[]',
  is_active boolean not null default true
);

create table if not exists life_admin_proof_cases (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade,
  title text not null,
  category text not null,
  related_request_id uuid,
  status text not null default 'open',
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists life_admin_proof_items (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade,
  case_id uuid not null references life_admin_proof_cases(id) on delete cascade,
  type text not null,
  title text not null,
  description text,
  date timestamptz,
  file_name text,
  local_file_path text,
  reference_number text,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists life_admin_deadlines (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade,
  title text not null,
  category text not null,
  date timestamptz not null,
  related_request_id uuid,
  related_document_id uuid,
  related_contract_id uuid,
  is_done boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists life_admin_checklist_items (
  id text primary key,
  category text not null,
  title text not null,
  description_localized jsonb not null default '{}',
  related_procedure_ids jsonb not null default '[]',
  related_document_types jsonb not null default '[]',
  priority integer not null default 1
);

create table if not exists life_admin_user_checklist_state (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade,
  checklist_item_id text not null,
  status text not null default 'notStarted',
  reminder_date timestamptz,
  notes text,
  updated_at timestamptz not null default now()
);

create table if not exists life_admin_community_templates (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade,
  title text not null,
  category text not null,
  language text not null,
  official_text_italian text not null,
  explanation_localized jsonb not null default '{}',
  tags jsonb not null default '[]',
  status text not null default 'draft',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists life_admin_official_links (
  id text primary key,
  title text not null,
  category text not null,
  description_localized jsonb not null default '{}',
  url text not null,
  country text not null default 'Italy',
  region text,
  city text,
  related_procedure_ids jsonb not null default '[]',
  last_verified_at timestamptz,
  verification_status text not null default 'unverified',
  warning_localized jsonb not null default '{}'
);

create table if not exists life_admin_before_sending_checklists (
  request_id uuid primary key,
  user_id uuid references auth.users(id) on delete cascade,
  personal_data_checked boolean not null default false,
  recipient_verified boolean not null default false,
  attachments_ready boolean not null default false,
  placeholders_removed boolean not null default false,
  statement_truthful boolean not null default false,
  official_rules_verified boolean not null default false,
  proof_saved boolean not null default false,
  skip_future_prompt boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- RLS guidance:
-- - user-scoped tables should allow CRUD only for the owning authenticated user
-- - official links / city packs / checklist catalogs should be read-only for users
-- - admin writes to global catalogs only if a real role system exists
