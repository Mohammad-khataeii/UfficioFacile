# Content System

## Source of truth

The canonical content source is the Dart category registry:

- `lib/features/italy_admin_copilot/content/categories`
- `lib/features/italy_admin_copilot/content/category_registry.dart`

Each top-level category lives in one dedicated source file and exports one normalized category seed.

## Export pipeline

Run:

```bash
dart run tool/export_cms_seed.dart
```

This generates:

- `docs/generated/cms_bundled_content_export.json`
- `apps/admin/data/cms_bundled_content_export.json`

## Canonical export shape

The bundled export now includes a canonical `categories` tree plus compatibility arrays:

- `categories`
- `cmsCategories`
- `cmsProcedures`
- `cmsContentBlocks`
- `cmsSources`

Compatibility-only shapes remain for legacy paths:

- `richCategories`
- `healthCategory`
- `housingCategory`

## Bootstrap behavior

Admin content loading is CMS-first:

1. Read Supabase CMS rows
2. If owner/admin is viewing content, upsert missing bundled categories/procedures
3. Fall back to bundled export if remote CMS is unavailable

Missing bundled categories are inserted without overwriting existing edited Supabase rows.
