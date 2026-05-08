alter table if exists public.ufficio_cms_categories
  add column if not exists tags text[] not null default '{}'::text[],
  add column if not exists synonyms text[] not null default '{}'::text[],
  add column if not exists searchable_keywords text[] not null default '{}'::text[];

alter table if exists public.ufficio_cms_procedures
  add column if not exists tags text[] not null default '{}'::text[],
  add column if not exists synonyms text[] not null default '{}'::text[],
  add column if not exists searchable_keywords text[] not null default '{}'::text[];

create index if not exists idx_ufficio_cms_categories_tags_gin
  on public.ufficio_cms_categories using gin (tags);

create index if not exists idx_ufficio_cms_categories_synonyms_gin
  on public.ufficio_cms_categories using gin (synonyms);

create index if not exists idx_ufficio_cms_categories_searchable_keywords_gin
  on public.ufficio_cms_categories using gin (searchable_keywords);

create index if not exists idx_ufficio_cms_procedures_tags_gin
  on public.ufficio_cms_procedures using gin (tags);

create index if not exists idx_ufficio_cms_procedures_synonyms_gin
  on public.ufficio_cms_procedures using gin (synonyms);

create index if not exists idx_ufficio_cms_procedures_searchable_keywords_gin
  on public.ufficio_cms_procedures using gin (searchable_keywords);
