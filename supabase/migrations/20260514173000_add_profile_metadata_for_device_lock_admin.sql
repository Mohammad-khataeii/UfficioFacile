comment on table public.ufficio_profiles is
  'Canonical user profile table used by the app and admin panel.';

alter table if exists public.ufficio_profiles
  add column if not exists metadata jsonb not null default '{}'::jsonb;

comment on column public.ufficio_profiles.metadata is
  'Profile metadata, including selected_city_pack_id and device_binding state.';

alter table if exists public.ufficcio_profiles
  add column if not exists metadata jsonb not null default '{}'::jsonb;

comment on column public.ufficcio_profiles.metadata is
  'Legacy profile metadata kept for compatibility while older profile tables still exist.';
