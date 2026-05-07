alter table public.ufficcio_profiles enable row level security;
alter table public.ufficcio_user_settings enable row level security;
alter table public.ufficcio_requests enable row level security;
alter table public.ufficcio_generated_packs enable row level security;
alter table public.ufficcio_status_events enable row level security;
alter table public.ufficcio_reminders enable row level security;
alter table public.ufficcio_documents enable row level security;
alter table public.ufficcio_contacts enable row level security;
alter table public.ufficcio_household_members enable row level security;
alter table public.ufficcio_household_contracts enable row level security;
alter table public.ufficcio_utility_comparisons enable row level security;
alter table public.ufficcio_bill_analyses enable row level security;
alter table public.ufficcio_proof_cases enable row level security;
alter table public.ufficcio_proof_items enable row level security;
alter table public.ufficcio_checklist_items enable row level security;
alter table public.ufficcio_user_checklist_state enable row level security;
alter table public.ufficcio_city_packs enable row level security;
alter table public.ufficcio_official_links enable row level security;
alter table public.ufficcio_template_overrides enable row level security;
alter table public.ufficcio_community_templates enable row level security;
alter table public.ufficcio_usage_events enable row level security;
alter table public.ufficcio_feedback enable row level security;
alter table public.ufficcio_entitlements enable row level security;
alter table public.ufficcio_admin_config enable row level security;
alter table public.ufficcio_sync_log enable row level security;
alter table public.ufficcio_delete_requests enable row level security;

create policy "ufficcio_profiles_own_all"
on public.ufficcio_profiles
for all
to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

create policy "ufficcio_user_settings_own_all"
on public.ufficcio_user_settings
for all
to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

create policy "ufficcio_requests_own_all"
on public.ufficcio_requests
for all
to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

create policy "ufficcio_generated_packs_own_all"
on public.ufficcio_generated_packs
for all
to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

create policy "ufficcio_status_events_select_insert_own"
on public.ufficcio_status_events
for select
to authenticated
using (user_id = auth.uid());
create policy "ufficcio_status_events_insert_own"
on public.ufficcio_status_events
for insert
to authenticated
with check (user_id = auth.uid());

create policy "ufficcio_reminders_own_all"
on public.ufficcio_reminders
for all
to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

create policy "ufficcio_documents_own_all"
on public.ufficcio_documents
for all
to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

create policy "ufficcio_contacts_own_all"
on public.ufficcio_contacts
for all
to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

create policy "ufficcio_household_members_own_all"
on public.ufficcio_household_members
for all
to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

create policy "ufficcio_household_contracts_own_all"
on public.ufficcio_household_contracts
for all
to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

create policy "ufficcio_utility_comparisons_own_all"
on public.ufficcio_utility_comparisons
for all
to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

create policy "ufficcio_bill_analyses_own_all"
on public.ufficcio_bill_analyses
for all
to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

create policy "ufficcio_proof_cases_own_all"
on public.ufficcio_proof_cases
for all
to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

create policy "ufficcio_proof_items_own_all"
on public.ufficcio_proof_items
for all
to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

create policy "ufficcio_user_checklist_state_own_all"
on public.ufficcio_user_checklist_state
for all
to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

create policy "ufficcio_community_templates_own_all"
on public.ufficcio_community_templates
for all
to authenticated
using (coalesce(user_id, auth.uid()) = auth.uid())
with check (coalesce(user_id, auth.uid()) = auth.uid());

create policy "ufficcio_feedback_own_all"
on public.ufficcio_feedback
for all
to authenticated
using (coalesce(user_id, auth.uid()) = auth.uid())
with check (coalesce(user_id, auth.uid()) = auth.uid());

create policy "ufficcio_entitlements_own_all"
on public.ufficcio_entitlements
for all
to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

create policy "ufficcio_sync_log_own_all"
on public.ufficcio_sync_log
for all
to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

create policy "ufficcio_delete_requests_own_all"
on public.ufficcio_delete_requests
for all
to authenticated
using (coalesce(user_id, auth.uid()) = auth.uid())
with check (coalesce(user_id, auth.uid()) = auth.uid());

create policy "ufficcio_checklist_items_active_read"
on public.ufficcio_checklist_items
for select
to authenticated
using (is_active = true);

create policy "ufficcio_city_packs_active_read"
on public.ufficcio_city_packs
for select
to authenticated
using (is_active = true);

create policy "ufficcio_official_links_active_read"
on public.ufficcio_official_links
for select
to authenticated
using (is_active = true);

create policy "ufficcio_template_overrides_admin_read"
on public.ufficcio_template_overrides
for select
to authenticated
using (true);
create policy "ufficcio_template_overrides_admin_write"
on public.ufficcio_template_overrides
for all
to authenticated
using (public.is_ufficcio_admin())
with check (public.is_ufficcio_admin());

create policy "ufficcio_admin_config_read_authenticated"
on public.ufficcio_admin_config
for select
to authenticated
using (true);
create policy "ufficcio_admin_config_admin_write"
on public.ufficcio_admin_config
for all
to authenticated
using (public.is_ufficcio_admin())
with check (public.is_ufficcio_admin());
