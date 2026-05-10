-- Public CMS procedure identity is category_slug + slug.
-- Database UUIDs are internal only and must not be used for public routing.

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
duplicates as (
  select id
  from ranked
  where preference_rank > 1
)
update public.ufficio_cms_procedures as procedures
set
  is_active = false,
  status = case
    when procedures.status = 'published' then 'archived'
    else procedures.status
  end,
  admin_notes = concat_ws(
    E'\n',
    nullif(procedures.admin_notes, ''),
    'Archived automatically while hardening duplicate public procedure identities.'
  )
where procedures.id in (select id from duplicates);

create unique index if not exists idx_ufficio_cms_procedures_public_identity_active
  on public.ufficio_cms_procedures(category_slug, slug)
  where is_active = true;

create index if not exists idx_ufficio_cms_procedures_public_identity_lookup
  on public.ufficio_cms_procedures(category_slug, slug, status, sort_order);

comment on index public.idx_ufficio_cms_procedures_public_identity_active is
  'Public route identity for procedures is category_slug + slug among active rows.';

comment on column public.ufficio_cms_procedures.category_slug is
  'Part of the public procedure identity. URLs and admin routing must use category_slug + slug.';

comment on column public.ufficio_cms_procedures.slug is
  'Part of the public procedure identity. Database UUIDs are internal only.';
