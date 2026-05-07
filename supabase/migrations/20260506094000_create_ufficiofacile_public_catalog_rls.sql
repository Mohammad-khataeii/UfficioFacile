alter table public.ufficio_catalog_sources enable row level security;
alter table public.ufficio_official_links enable row level security;
alter table public.ufficio_official_contacts enable row level security;
alter table public.ufficio_service_providers enable row level security;
alter table public.ufficio_provider_forms enable row level security;
alter table public.ufficio_provider_contact_options enable row level security;
alter table public.ufficio_region_guidance enable row level security;
alter table public.ufficio_city_guidance enable row level security;
alter table public.ufficio_authority_guidance enable row level security;
alter table public.ufficio_procedure_guidance enable row level security;
alter table public.ufficio_source_references enable row level security;
alter table public.ufficio_service_terms enable row level security;
alter table public.ufficio_submission_channels enable row level security;
alter table public.ufficio_app_public_config enable row level security;
alter table public.ufficio_premium_public_config enable row level security;

create policy "anon_read_ufficio_catalog_sources"
on public.ufficio_catalog_sources for select to anon
using (is_active = true);
create policy "authenticated_read_ufficio_catalog_sources"
on public.ufficio_catalog_sources for select to authenticated
using (is_active = true);
create policy "admin_write_ufficio_catalog_sources"
on public.ufficio_catalog_sources for all to authenticated
using (public.is_ufficio_admin())
with check (public.is_ufficio_admin());

create policy "anon_read_ufficio_official_links"
on public.ufficio_official_links for select to anon
using (is_active = true);
create policy "authenticated_read_ufficio_official_links"
on public.ufficio_official_links for select to authenticated
using (is_active = true);
create policy "admin_write_ufficio_official_links"
on public.ufficio_official_links for all to authenticated
using (public.is_ufficio_admin())
with check (public.is_ufficio_admin());

create policy "anon_read_ufficio_official_contacts"
on public.ufficio_official_contacts for select to anon
using (is_active = true);
create policy "authenticated_read_ufficio_official_contacts"
on public.ufficio_official_contacts for select to authenticated
using (is_active = true);
create policy "admin_write_ufficio_official_contacts"
on public.ufficio_official_contacts for all to authenticated
using (public.is_ufficio_admin())
with check (public.is_ufficio_admin());

create policy "anon_read_ufficio_service_providers"
on public.ufficio_service_providers for select to anon
using (is_active = true);
create policy "authenticated_read_ufficio_service_providers"
on public.ufficio_service_providers for select to authenticated
using (is_active = true);
create policy "admin_write_ufficio_service_providers"
on public.ufficio_service_providers for all to authenticated
using (public.is_ufficio_admin())
with check (public.is_ufficio_admin());

create policy "anon_read_ufficio_provider_forms"
on public.ufficio_provider_forms for select to anon
using (is_active = true);
create policy "authenticated_read_ufficio_provider_forms"
on public.ufficio_provider_forms for select to authenticated
using (is_active = true);
create policy "admin_write_ufficio_provider_forms"
on public.ufficio_provider_forms for all to authenticated
using (public.is_ufficio_admin())
with check (public.is_ufficio_admin());

create policy "anon_read_ufficio_provider_contact_options"
on public.ufficio_provider_contact_options for select to anon
using (is_active = true);
create policy "authenticated_read_ufficio_provider_contact_options"
on public.ufficio_provider_contact_options for select to authenticated
using (is_active = true);
create policy "admin_write_ufficio_provider_contact_options"
on public.ufficio_provider_contact_options for all to authenticated
using (public.is_ufficio_admin())
with check (public.is_ufficio_admin());

create policy "anon_read_ufficio_region_guidance"
on public.ufficio_region_guidance for select to anon
using (is_active = true);
create policy "authenticated_read_ufficio_region_guidance"
on public.ufficio_region_guidance for select to authenticated
using (is_active = true);
create policy "admin_write_ufficio_region_guidance"
on public.ufficio_region_guidance for all to authenticated
using (public.is_ufficio_admin())
with check (public.is_ufficio_admin());

create policy "anon_read_ufficio_city_guidance"
on public.ufficio_city_guidance for select to anon
using (is_active = true);
create policy "authenticated_read_ufficio_city_guidance"
on public.ufficio_city_guidance for select to authenticated
using (is_active = true);
create policy "admin_write_ufficio_city_guidance"
on public.ufficio_city_guidance for all to authenticated
using (public.is_ufficio_admin())
with check (public.is_ufficio_admin());

create policy "anon_read_ufficio_authority_guidance"
on public.ufficio_authority_guidance for select to anon
using (is_active = true);
create policy "authenticated_read_ufficio_authority_guidance"
on public.ufficio_authority_guidance for select to authenticated
using (is_active = true);
create policy "admin_write_ufficio_authority_guidance"
on public.ufficio_authority_guidance for all to authenticated
using (public.is_ufficio_admin())
with check (public.is_ufficio_admin());

create policy "anon_read_ufficio_procedure_guidance"
on public.ufficio_procedure_guidance for select to anon
using (is_active = true);
create policy "authenticated_read_ufficio_procedure_guidance"
on public.ufficio_procedure_guidance for select to authenticated
using (is_active = true);
create policy "admin_write_ufficio_procedure_guidance"
on public.ufficio_procedure_guidance for all to authenticated
using (public.is_ufficio_admin())
with check (public.is_ufficio_admin());

create policy "anon_read_ufficio_source_references"
on public.ufficio_source_references for select to anon
using (is_active = true);
create policy "authenticated_read_ufficio_source_references"
on public.ufficio_source_references for select to authenticated
using (is_active = true);
create policy "admin_write_ufficio_source_references"
on public.ufficio_source_references for all to authenticated
using (public.is_ufficio_admin())
with check (public.is_ufficio_admin());

create policy "anon_read_ufficio_service_terms"
on public.ufficio_service_terms for select to anon
using (is_active = true);
create policy "authenticated_read_ufficio_service_terms"
on public.ufficio_service_terms for select to authenticated
using (is_active = true);
create policy "admin_write_ufficio_service_terms"
on public.ufficio_service_terms for all to authenticated
using (public.is_ufficio_admin())
with check (public.is_ufficio_admin());

create policy "anon_read_ufficio_submission_channels"
on public.ufficio_submission_channels for select to anon
using (is_active = true);
create policy "authenticated_read_ufficio_submission_channels"
on public.ufficio_submission_channels for select to authenticated
using (is_active = true);
create policy "admin_write_ufficio_submission_channels"
on public.ufficio_submission_channels for all to authenticated
using (public.is_ufficio_admin())
with check (public.is_ufficio_admin());

create policy "anon_read_ufficio_app_public_config"
on public.ufficio_app_public_config for select to anon
using (is_active = true);
create policy "authenticated_read_ufficio_app_public_config"
on public.ufficio_app_public_config for select to authenticated
using (is_active = true);
create policy "admin_write_ufficio_app_public_config"
on public.ufficio_app_public_config for all to authenticated
using (public.is_ufficio_admin())
with check (public.is_ufficio_admin());

create policy "anon_read_ufficio_premium_public_config"
on public.ufficio_premium_public_config for select to anon
using (is_active = true);
create policy "authenticated_read_ufficio_premium_public_config"
on public.ufficio_premium_public_config for select to authenticated
using (is_active = true);
create policy "admin_write_ufficio_premium_public_config"
on public.ufficio_premium_public_config for all to authenticated
using (public.is_ufficio_admin())
with check (public.is_ufficio_admin());
