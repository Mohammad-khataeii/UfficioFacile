drop policy if exists "ufficcio_profiles_admin_read" on public.ufficcio_profiles;
create policy "ufficcio_profiles_admin_read"
on public.ufficcio_profiles
for select
to authenticated
using (public.is_ufficcio_admin());

drop policy if exists "ufficcio_user_settings_admin_read" on public.ufficcio_user_settings;
create policy "ufficcio_user_settings_admin_read"
on public.ufficcio_user_settings
for select
to authenticated
using (public.is_ufficcio_admin());

drop policy if exists "ufficcio_requests_admin_read" on public.ufficcio_requests;
create policy "ufficcio_requests_admin_read"
on public.ufficcio_requests
for select
to authenticated
using (public.is_ufficcio_admin());

drop policy if exists "ufficcio_generated_packs_admin_read" on public.ufficcio_generated_packs;
create policy "ufficcio_generated_packs_admin_read"
on public.ufficcio_generated_packs
for select
to authenticated
using (public.is_ufficcio_admin());

drop policy if exists "ufficcio_status_events_admin_read" on public.ufficcio_status_events;
create policy "ufficcio_status_events_admin_read"
on public.ufficcio_status_events
for select
to authenticated
using (public.is_ufficcio_admin());

drop policy if exists "ufficcio_reminders_admin_read" on public.ufficcio_reminders;
create policy "ufficcio_reminders_admin_read"
on public.ufficcio_reminders
for select
to authenticated
using (public.is_ufficcio_admin());

drop policy if exists "ufficcio_documents_admin_read" on public.ufficcio_documents;
create policy "ufficcio_documents_admin_read"
on public.ufficcio_documents
for select
to authenticated
using (public.is_ufficcio_admin());

drop policy if exists "ufficcio_contacts_admin_read" on public.ufficcio_contacts;
create policy "ufficcio_contacts_admin_read"
on public.ufficcio_contacts
for select
to authenticated
using (public.is_ufficcio_admin());

drop policy if exists "ufficcio_household_members_admin_read" on public.ufficcio_household_members;
create policy "ufficcio_household_members_admin_read"
on public.ufficcio_household_members
for select
to authenticated
using (public.is_ufficcio_admin());

drop policy if exists "ufficcio_household_contracts_admin_read" on public.ufficcio_household_contracts;
create policy "ufficcio_household_contracts_admin_read"
on public.ufficcio_household_contracts
for select
to authenticated
using (public.is_ufficcio_admin());

drop policy if exists "ufficcio_utility_comparisons_admin_read" on public.ufficcio_utility_comparisons;
create policy "ufficcio_utility_comparisons_admin_read"
on public.ufficcio_utility_comparisons
for select
to authenticated
using (public.is_ufficcio_admin());

drop policy if exists "ufficcio_bill_analyses_admin_read" on public.ufficcio_bill_analyses;
create policy "ufficcio_bill_analyses_admin_read"
on public.ufficcio_bill_analyses
for select
to authenticated
using (public.is_ufficcio_admin());

drop policy if exists "ufficcio_proof_cases_admin_read" on public.ufficcio_proof_cases;
create policy "ufficcio_proof_cases_admin_read"
on public.ufficcio_proof_cases
for select
to authenticated
using (public.is_ufficcio_admin());

drop policy if exists "ufficcio_proof_items_admin_read" on public.ufficcio_proof_items;
create policy "ufficcio_proof_items_admin_read"
on public.ufficcio_proof_items
for select
to authenticated
using (public.is_ufficcio_admin());

drop policy if exists "ufficcio_sync_log_admin_read" on public.ufficcio_sync_log;
create policy "ufficcio_sync_log_admin_read"
on public.ufficcio_sync_log
for select
to authenticated
using (public.is_ufficcio_admin());
