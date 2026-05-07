-- Compatibility patch for older remote CMS tables created before the full admin CMS schema.
do $$
begin
  if to_regclass('public.ufficio_cms_categories') is not null then
    alter table public.ufficio_cms_categories
      add column if not exists is_active boolean not null default true,
      add column if not exists is_premium boolean not null default false,
      add column if not exists verification_status text not null default 'needsReview',
      add column if not exists metadata jsonb not null default '{}'::jsonb,
      add column if not exists admin_notes text;
  end if;

  if to_regclass('public.ufficio_cms_procedures') is not null then
    alter table public.ufficio_cms_procedures
      add column if not exists status text not null default 'published',
      add column if not exists is_active boolean not null default true,
      add column if not exists is_premium boolean not null default false,
      add column if not exists verification_status text not null default 'needsReview',
      add column if not exists metadata jsonb not null default '{}'::jsonb,
      add column if not exists admin_notes text;
  end if;

  if to_regclass('public.ufficio_cms_content_blocks') is not null then
    alter table public.ufficio_cms_content_blocks
      add column if not exists is_active boolean not null default true,
      add column if not exists is_premium boolean not null default false,
      add column if not exists metadata jsonb not null default '{}'::jsonb,
      add column if not exists warning_level text;
  end if;
end $$;

alter table public.ufficio_admin_users enable row level security;
alter table public.ufficio_admin_audit_logs enable row level security;
alter table public.ufficio_problem_requests enable row level security;
alter table public.ufficio_consultancy_requests enable row level security;
alter table public.ufficio_premium_events enable row level security;
alter table public.ufficio_cost_items enable row level security;
alter table public.ufficio_directory_contacts enable row level security;
alter table public.ufficio_documents_directory enable row level security;
alter table public.ufficio_cms_categories enable row level security;
alter table public.ufficio_cms_procedures enable row level security;
alter table public.ufficio_cms_content_blocks enable row level security;
alter table public.ufficio_cms_translations enable row level security;
alter table public.ufficio_cms_links enable row level security;
alter table public.ufficio_cms_contacts enable row level security;
alter table public.ufficio_cms_documents enable row level security;
alter table public.ufficio_cms_sources enable row level security;
alter table public.ufficio_cms_revisions enable row level security;
alter table public.ufficio_cms_drafts enable row level security;

drop policy if exists "admins_read_admin_users" on public.ufficio_admin_users;
create policy "admins_read_admin_users"
on public.ufficio_admin_users for select to authenticated
using (public.is_ufficio_admin());

drop policy if exists "owners_manage_admin_users" on public.ufficio_admin_users;
create policy "owners_manage_admin_users"
on public.ufficio_admin_users for all to authenticated
using (public.has_ufficio_role(array['owner']))
with check (public.has_ufficio_role(array['owner']));

drop policy if exists "admins_read_audit_logs" on public.ufficio_admin_audit_logs;
create policy "admins_read_audit_logs"
on public.ufficio_admin_audit_logs for select to authenticated
using (public.is_ufficio_admin());

drop policy if exists "admins_insert_audit_logs" on public.ufficio_admin_audit_logs;
create policy "admins_insert_audit_logs"
on public.ufficio_admin_audit_logs for insert to authenticated
with check (public.is_ufficio_admin());

drop policy if exists "users_insert_problem_requests" on public.ufficio_problem_requests;
create policy "users_insert_problem_requests"
on public.ufficio_problem_requests for insert to authenticated
with check (user_id = auth.uid() or user_id is null);

drop policy if exists "users_read_own_problem_requests" on public.ufficio_problem_requests;
create policy "users_read_own_problem_requests"
on public.ufficio_problem_requests for select to authenticated
using (user_id = auth.uid() or public.is_ufficio_admin());

drop policy if exists "admins_manage_problem_requests" on public.ufficio_problem_requests;
create policy "admins_manage_problem_requests"
on public.ufficio_problem_requests for update to authenticated
using (public.has_ufficio_role(array['owner','admin','support','editor']))
with check (public.has_ufficio_role(array['owner','admin','support','editor']));

drop policy if exists "users_insert_consultancy_requests" on public.ufficio_consultancy_requests;
create policy "users_insert_consultancy_requests"
on public.ufficio_consultancy_requests for insert to authenticated
with check (user_id = auth.uid() or user_id is null);

drop policy if exists "users_read_own_consultancy_requests" on public.ufficio_consultancy_requests;
create policy "users_read_own_consultancy_requests"
on public.ufficio_consultancy_requests for select to authenticated
using (user_id = auth.uid() or public.is_ufficio_admin());

drop policy if exists "admins_manage_consultancy_requests" on public.ufficio_consultancy_requests;
create policy "admins_manage_consultancy_requests"
on public.ufficio_consultancy_requests for update to authenticated
using (public.has_ufficio_role(array['owner','admin','support']))
with check (public.has_ufficio_role(array['owner','admin','support']));

drop policy if exists "users_read_own_premium_events" on public.ufficio_premium_events;
create policy "users_read_own_premium_events"
on public.ufficio_premium_events for select to authenticated
using (user_id = auth.uid() or public.is_ufficio_admin());

drop policy if exists "admins_manage_premium_events" on public.ufficio_premium_events;
create policy "admins_manage_premium_events"
on public.ufficio_premium_events for all to authenticated
using (public.has_ufficio_role(array['owner','admin','support']))
with check (public.has_ufficio_role(array['owner','admin','support']));

drop policy if exists "users_manage_cost_items" on public.ufficio_cost_items;
create policy "users_manage_cost_items"
on public.ufficio_cost_items for all to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

drop policy if exists "users_manage_directory_contacts" on public.ufficio_directory_contacts;
create policy "users_manage_directory_contacts"
on public.ufficio_directory_contacts for all to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

drop policy if exists "users_manage_documents_directory" on public.ufficio_documents_directory;
create policy "users_manage_documents_directory"
on public.ufficio_documents_directory for all to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

drop policy if exists "anon_read_cms_categories" on public.ufficio_cms_categories;
create policy "anon_read_cms_categories"
on public.ufficio_cms_categories for select to anon
using (is_active = true);

drop policy if exists "authenticated_read_cms_categories" on public.ufficio_cms_categories;
create policy "authenticated_read_cms_categories"
on public.ufficio_cms_categories for select to authenticated
using (is_active = true or public.is_ufficio_admin());

drop policy if exists "content_edit_cms_categories" on public.ufficio_cms_categories;
create policy "content_edit_cms_categories"
on public.ufficio_cms_categories for all to authenticated
using (public.has_ufficio_role(array['owner','admin','editor']))
with check (public.has_ufficio_role(array['owner','admin','editor']));

drop policy if exists "anon_read_cms_procedures" on public.ufficio_cms_procedures;
create policy "anon_read_cms_procedures"
on public.ufficio_cms_procedures for select to anon
using (is_active = true and status = 'published');

drop policy if exists "authenticated_read_cms_procedures" on public.ufficio_cms_procedures;
create policy "authenticated_read_cms_procedures"
on public.ufficio_cms_procedures for select to authenticated
using ((is_active = true and status = 'published') or public.is_ufficio_admin());

drop policy if exists "content_edit_cms_procedures" on public.ufficio_cms_procedures;
create policy "content_edit_cms_procedures"
on public.ufficio_cms_procedures for all to authenticated
using (public.has_ufficio_role(array['owner','admin','editor']))
with check (public.has_ufficio_role(array['owner','admin','editor']));

drop policy if exists "cms_blocks_public_read" on public.ufficio_cms_content_blocks;
create policy "cms_blocks_public_read"
on public.ufficio_cms_content_blocks for select to anon
using (
  is_active = true
  and exists (
    select 1
    from public.ufficio_cms_procedures p
    where p.slug = procedure_slug
      and p.is_active = true
      and p.status = 'published'
  )
);

drop policy if exists "cms_blocks_auth_read" on public.ufficio_cms_content_blocks;
create policy "cms_blocks_auth_read"
on public.ufficio_cms_content_blocks for select to authenticated
using (
  (
    is_active = true
    and exists (
      select 1
      from public.ufficio_cms_procedures p
      where p.slug = procedure_slug
        and p.is_active = true
        and p.status = 'published'
    )
  )
  or public.is_ufficio_admin()
);

drop policy if exists "cms_blocks_edit" on public.ufficio_cms_content_blocks;
create policy "cms_blocks_edit"
on public.ufficio_cms_content_blocks for all to authenticated
using (public.has_ufficio_role(array['owner','admin','editor']))
with check (public.has_ufficio_role(array['owner','admin','editor']));

drop policy if exists "cms_translations_read" on public.ufficio_cms_translations;
create policy "cms_translations_read"
on public.ufficio_cms_translations for select to authenticated
using (public.is_ufficio_admin());

drop policy if exists "cms_translations_edit" on public.ufficio_cms_translations;
create policy "cms_translations_edit"
on public.ufficio_cms_translations for all to authenticated
using (public.has_ufficio_role(array['owner','admin','editor']))
with check (public.has_ufficio_role(array['owner','admin','editor']));

drop policy if exists "cms_links_public_read" on public.ufficio_cms_links;
create policy "cms_links_public_read"
on public.ufficio_cms_links for select to anon
using (
  is_active = true
  and exists (
    select 1
    from public.ufficio_cms_procedures p
    where p.slug = procedure_slug
      and p.is_active = true
      and p.status = 'published'
  )
);

drop policy if exists "cms_links_auth_read" on public.ufficio_cms_links;
create policy "cms_links_auth_read"
on public.ufficio_cms_links for select to authenticated
using (
  (
    is_active = true
    and exists (
      select 1
      from public.ufficio_cms_procedures p
      where p.slug = procedure_slug
        and p.is_active = true
        and p.status = 'published'
    )
  )
  or public.is_ufficio_admin()
);

drop policy if exists "cms_links_edit" on public.ufficio_cms_links;
create policy "cms_links_edit"
on public.ufficio_cms_links for all to authenticated
using (public.has_ufficio_role(array['owner','admin','editor']))
with check (public.has_ufficio_role(array['owner','admin','editor']));

drop policy if exists "cms_contacts_public_read" on public.ufficio_cms_contacts;
create policy "cms_contacts_public_read"
on public.ufficio_cms_contacts for select to anon
using (
  is_active = true
  and exists (
    select 1
    from public.ufficio_cms_procedures p
    where p.slug = procedure_slug
      and p.is_active = true
      and p.status = 'published'
  )
);

drop policy if exists "cms_contacts_auth_read" on public.ufficio_cms_contacts;
create policy "cms_contacts_auth_read"
on public.ufficio_cms_contacts for select to authenticated
using (
  (
    is_active = true
    and exists (
      select 1
      from public.ufficio_cms_procedures p
      where p.slug = procedure_slug
        and p.is_active = true
        and p.status = 'published'
    )
  )
  or public.is_ufficio_admin()
);

drop policy if exists "cms_contacts_edit" on public.ufficio_cms_contacts;
create policy "cms_contacts_edit"
on public.ufficio_cms_contacts for all to authenticated
using (public.has_ufficio_role(array['owner','admin','editor']))
with check (public.has_ufficio_role(array['owner','admin','editor']));

drop policy if exists "cms_documents_public_read" on public.ufficio_cms_documents;
create policy "cms_documents_public_read"
on public.ufficio_cms_documents for select to anon
using (
  is_active = true
  and exists (
    select 1
    from public.ufficio_cms_procedures p
    where p.slug = procedure_slug
      and p.is_active = true
      and p.status = 'published'
  )
);

drop policy if exists "cms_documents_auth_read" on public.ufficio_cms_documents;
create policy "cms_documents_auth_read"
on public.ufficio_cms_documents for select to authenticated
using (
  (
    is_active = true
    and exists (
      select 1
      from public.ufficio_cms_procedures p
      where p.slug = procedure_slug
        and p.is_active = true
        and p.status = 'published'
    )
  )
  or public.is_ufficio_admin()
);

drop policy if exists "cms_documents_edit" on public.ufficio_cms_documents;
create policy "cms_documents_edit"
on public.ufficio_cms_documents for all to authenticated
using (public.has_ufficio_role(array['owner','admin','editor']))
with check (public.has_ufficio_role(array['owner','admin','editor']));

drop policy if exists "cms_sources_public_read" on public.ufficio_cms_sources;
create policy "cms_sources_public_read"
on public.ufficio_cms_sources for select to anon
using (
  is_active = true
  and exists (
    select 1
    from public.ufficio_cms_procedures p
    where p.slug = procedure_slug
      and p.is_active = true
      and p.status = 'published'
  )
);

drop policy if exists "cms_sources_auth_read" on public.ufficio_cms_sources;
create policy "cms_sources_auth_read"
on public.ufficio_cms_sources for select to authenticated
using (
  (
    is_active = true
    and exists (
      select 1
      from public.ufficio_cms_procedures p
      where p.slug = procedure_slug
        and p.is_active = true
        and p.status = 'published'
    )
  )
  or public.is_ufficio_admin()
);

drop policy if exists "cms_sources_edit" on public.ufficio_cms_sources;
create policy "cms_sources_edit"
on public.ufficio_cms_sources for all to authenticated
using (public.has_ufficio_role(array['owner','admin','editor']))
with check (public.has_ufficio_role(array['owner','admin','editor']));

drop policy if exists "cms_revisions_read" on public.ufficio_cms_revisions;
create policy "cms_revisions_read"
on public.ufficio_cms_revisions for select to authenticated
using (public.is_ufficio_admin());

drop policy if exists "cms_revisions_write" on public.ufficio_cms_revisions;
create policy "cms_revisions_write"
on public.ufficio_cms_revisions for insert to authenticated
with check (public.has_ufficio_role(array['owner','admin','editor']));

drop policy if exists "cms_drafts_read" on public.ufficio_cms_drafts;
create policy "cms_drafts_read"
on public.ufficio_cms_drafts for select to authenticated
using (public.is_ufficio_admin());

drop policy if exists "cms_drafts_edit" on public.ufficio_cms_drafts;
create policy "cms_drafts_edit"
on public.ufficio_cms_drafts for all to authenticated
using (public.has_ufficio_role(array['owner','admin','editor','support']))
with check (public.has_ufficio_role(array['owner','admin','editor','support']));
