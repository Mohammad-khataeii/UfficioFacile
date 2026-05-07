-- UfficcioFacile future backend schema
-- Prepared for a Supabase-style backend if/when remote sync is added.

create table if not exists life_admin_profiles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  full_name text,
  codice_fiscale text,
  date_of_birth date,
  phone text,
  email text,
  address text,
  city text,
  nationality text,
  preferred_language text default 'en',
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists life_admin_requests (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade,
  anonymous_session_id text,
  procedure_id text not null,
  procedure_title text not null,
  category text not null,
  subcategory text,
  status text not null default 'generated',
  priority text not null default 'normal',
  input_data jsonb not null default '{}',
  generated_pack jsonb not null default '{}',
  recipient_name text,
  recipient_email text,
  recipient_pec text,
  subject text,
  deadline_date date,
  sent_at timestamptz,
  replied_at timestamptz,
  completed_at timestamptz,
  last_copied_at timestamptz,
  notes text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists life_admin_attachments (
  id uuid primary key default gen_random_uuid(),
  request_id uuid not null references life_admin_requests(id) on delete cascade,
  user_id uuid references auth.users(id) on delete cascade,
  name text not null,
  description text,
  required boolean default false,
  user_has_it boolean default false,
  uploaded_file_name text,
  uploaded_file_path text,
  uploaded_mime_type text,
  uploaded_size_bytes bigint,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists life_admin_status_events (
  id uuid primary key default gen_random_uuid(),
  request_id uuid not null references life_admin_requests(id) on delete cascade,
  user_id uuid references auth.users(id) on delete cascade,
  old_status text,
  new_status text not null,
  note text,
  created_at timestamptz default now()
);

create table if not exists life_admin_reminders (
  id uuid primary key default gen_random_uuid(),
  request_id uuid references life_admin_requests(id) on delete cascade,
  user_id uuid references auth.users(id) on delete cascade,
  title text not null,
  reminder_date date not null,
  reminder_type text not null default 'follow_up',
  is_done boolean default false,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists life_admin_usage_events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete set null,
  anonymous_session_id text,
  event_name text not null,
  procedure_id text,
  request_id uuid,
  category text,
  metadata jsonb not null default '{}',
  created_at timestamptz default now()
);

create table if not exists life_admin_utility_comparisons (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade,
  anonymous_session_id text,
  utility_type text not null,
  input_data jsonb not null default '{}',
  result_data jsonb not null default '{}',
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists life_admin_bill_analyses (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade,
  anonymous_session_id text,
  bill_type text not null,
  provider text,
  bill_period text,
  amount numeric,
  input_data jsonb not null default '{}',
  result_data jsonb not null default '{}',
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists life_admin_admin_config (
  id uuid primary key default gen_random_uuid(),
  key text unique not null,
  value jsonb not null default '{}',
  updated_by uuid references auth.users(id),
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists life_admin_template_overrides (
  id uuid primary key default gen_random_uuid(),
  procedure_id text not null,
  override_data jsonb not null default '{}',
  is_active boolean default true,
  updated_by uuid references auth.users(id),
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);
