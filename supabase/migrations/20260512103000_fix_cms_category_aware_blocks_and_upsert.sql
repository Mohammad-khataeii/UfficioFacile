-- Canonical CMS procedure identity is category_slug + slug.
-- Keep the best row for each public identity, then enforce a non-partial
-- uniqueness guarantee that matches Supabase/PostgREST onConflict usage.
--
-- Note: procedure.slug is still globally unique in the legacy schema because
-- other CMS child tables still reference it directly. This migration adds the
-- composite uniqueness required by the admin app and makes content blocks
-- category-aware without breaking existing slug-based compatibility paths.

create extension if not exists pgcrypto;

with ranked as (
  select
    id,
    category_slug,
    slug,
    status,
    is_active,
    row_number() over (
      partition by category_slug, slug
      order by
        case
          when is_active = true and status = 'published' then 5
          when is_active = true then 4
          when status = 'draft' then 3
          when status = 'archived' then 2
          else 1
        end desc,
        (
          jsonb_object_length(coalesce(title, '{}'::jsonb)) +
          jsonb_object_length(coalesce(summary, '{}'::jsonb)) +
          jsonb_object_length(coalesce(what_is_it, '{}'::jsonb)) +
          jsonb_array_length(coalesce(why_you_may_need_it, '[]'::jsonb)) +
          jsonb_array_length(coalesce(how_to_do_it, '[]'::jsonb)) +
          jsonb_array_length(coalesce(required_documents, '[]'::jsonb)) +
          jsonb_array_length(coalesce(optional_documents, '[]'::jsonb)) +
          jsonb_array_length(coalesce(warnings, '[]'::jsonb)) +
          jsonb_array_length(coalesce(common_mistakes, '[]'::jsonb)) +
          jsonb_array_length(coalesce(proof_to_keep, '[]'::jsonb)) +
          jsonb_array_length(coalesce(faq, '[]'::jsonb)) +
          jsonb_array_length(coalesce(official_links, '[]'::jsonb)) +
          jsonb_object_length(coalesce(metadata, '{}'::jsonb)) +
          jsonb_object_length(coalesce(public_snapshot, '{}'::jsonb))
        ) desc,
        updated_at desc nulls last,
        created_at desc nulls last,
        sort_order asc,
        id asc
    ) as preference_rank
  from public.ufficio_cms_procedures
),
duplicate_rows as (
  select id
  from ranked
  where preference_rank > 1
)
delete from public.ufficio_cms_procedures
where id in (select id from duplicate_rows);

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'ufficio_cms_procedures_category_slug_slug_key'
      and conrelid = 'public.ufficio_cms_procedures'::regclass
  ) then
    alter table public.ufficio_cms_procedures
      add constraint ufficio_cms_procedures_category_slug_slug_key
      unique (category_slug, slug);
  end if;
end $$;

create index if not exists idx_ufficio_cms_procedures_public_identity_lookup
  on public.ufficio_cms_procedures(category_slug, slug, status, sort_order);

alter table public.ufficio_cms_content_blocks
  add column if not exists category_slug text;

update public.ufficio_cms_content_blocks as blocks
set category_slug = procedures.category_slug
from public.ufficio_cms_procedures as procedures
where blocks.category_slug is null
  and procedures.slug = blocks.procedure_slug;

do $$
begin
  if exists (
    select 1
    from public.ufficio_cms_content_blocks
    where category_slug is null
  ) then
    raise notice 'ufficio_cms_content_blocks still contains rows without category_slug; leaving column nullable until data is repaired.';
  else
    alter table public.ufficio_cms_content_blocks
      alter column category_slug set not null;
  end if;
end $$;

alter table public.ufficio_cms_content_blocks
  drop constraint if exists ufficio_cms_content_blocks_procedure_slug_fkey;

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'ufficio_cms_content_blocks_category_procedure_fkey'
      and conrelid = 'public.ufficio_cms_content_blocks'::regclass
  ) then
    alter table public.ufficio_cms_content_blocks
      add constraint ufficio_cms_content_blocks_category_procedure_fkey
      foreign key (category_slug, procedure_slug)
      references public.ufficio_cms_procedures(category_slug, slug)
      on delete cascade;
  end if;
end $$;

create index if not exists idx_ufficio_cms_content_blocks_category_procedure
  on public.ufficio_cms_content_blocks(category_slug, procedure_slug, sort_order);

create index if not exists idx_ufficio_cms_content_blocks_procedure_slug
  on public.ufficio_cms_content_blocks(procedure_slug, sort_order);

drop policy if exists "cms_blocks_public_read" on public.ufficio_cms_content_blocks;
create policy "cms_blocks_public_read"
on public.ufficio_cms_content_blocks for select to anon
using (
  is_active = true
  and exists (
    select 1
    from public.ufficio_cms_procedures p
    where p.category_slug = ufficio_cms_content_blocks.category_slug
      and p.slug = ufficio_cms_content_blocks.procedure_slug
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
      where p.category_slug = ufficio_cms_content_blocks.category_slug
        and p.slug = ufficio_cms_content_blocks.procedure_slug
        and p.is_active = true
        and p.status = 'published'
    )
  )
  or public.is_ufficio_admin()
);

comment on constraint ufficio_cms_procedures_category_slug_slug_key on public.ufficio_cms_procedures is
  'Matches the admin upsert conflict target. Public procedure identity is category_slug + slug.';

comment on column public.ufficio_cms_content_blocks.category_slug is
  'Canonical procedure category for category-aware CMS block lookup. Use together with procedure_slug.';
