select 'ufficio_cms_categories' as table_name, slug as entity_slug, title::text as snippet
from public.ufficio_cms_categories
where lower(title::text) like any (
  array[
    '%to help the user%',
    '%the user should%',
    '%the user can%',
    '%do not show%',
    '%do not dump%',
    '%internal%',
    '%developer note%',
    '%prompt%',
    '%todo%',
    '%placeholder%',
    '%lorem ipsum%',
    '%fake%',
    '%random stuff%'
  ]
)
union all
select 'ufficio_cms_procedures', slug, row_to_json(p)::text
from public.ufficio_cms_procedures p
where lower(row_to_json(p)::text) like any (
  array[
    '%to help the user%',
    '%the user should%',
    '%the user can%',
    '%do not show%',
    '%do not dump%',
    '%internal%',
    '%developer note%',
    '%prompt%',
    '%todo%',
    '%placeholder%',
    '%lorem ipsum%',
    '%fake%',
    '%random stuff%'
  ]
)
union all
select 'ufficio_cms_content_blocks', procedure_slug, row_to_json(b)::text
from public.ufficio_cms_content_blocks b
where lower(row_to_json(b)::text) like any (
  array[
    '%to help the user%',
    '%the user should%',
    '%the user can%',
    '%do not show%',
    '%do not dump%',
    '%internal%',
    '%developer note%',
    '%prompt%',
    '%todo%',
    '%placeholder%',
    '%lorem ipsum%',
    '%fake%',
    '%random stuff%'
  ]
)
order by table_name, entity_slug;
