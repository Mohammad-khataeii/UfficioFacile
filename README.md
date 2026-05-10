# UfficioFacile

UfficioFacile is a Flutter consumer app with a Next.js admin backoffice and a
Supabase-backed CMS, entitlement, and request workflow.

## Workspaces

- Flutter app: `lib/`
- Next.js admin: `apps/admin`
- Supabase migrations: `supabase/migrations`
- Canonical bundled CMS export: `docs/generated/cms_bundled_content_export.json`

## Content pipeline

The category source of truth is the Dart category registry under:

- `lib/features/italy_admin_copilot/content/categories`
- `lib/features/italy_admin_copilot/content/category_registry.dart`

Generate the canonical bundled CMS export with:

```bash
dart run tool/export_cms_seed.dart
```

Validate the generated export with:

```bash
dart run tool/content_doctor.dart
dart run tool/localization_doctor.dart
```

This writes both:

- `docs/generated/cms_bundled_content_export.json`
- `apps/admin/data/cms_bundled_content_export.json`

Runtime priority is:

1. Supabase CMS content
2. Bundled CMS export fallback
3. Older compatibility content only where still required by legacy flows

## Local checks

From the repo root:

```bash
dart format lib test tool
flutter analyze
flutter test
/usr/local/share/flutter/bin/dart run tool/export_cms_seed.dart
dart run tool/content_doctor.dart
dart run tool/localization_doctor.dart
```

For the admin app:

```bash
cd apps/admin
npm install
npm run build
npm run lint
npm run content:lint
```

## Production Flutter Build

```bash
flutter build web \
  --release \
  --dart-define=UFFICCIOFACILE_BACKEND_MODE=supabase \
  --dart-define=UFFICCIOFACILE_FLAVOR=production \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=... \
  --dart-define=UFFICCIOFACILE_ENABLE_PAYWALL=true \
  --dart-define=UFFICCIOFACILE_ENABLE_BETA_MODE=false
```

Production notes:

- Production Supabase builds fail loud if `SUPABASE_URL` or `SUPABASE_ANON_KEY` is missing.
- Keep `SUPABASE_SERVICE_ROLE_KEY` server-side only.
- Do not enable `UFFICCIOFACILE_ALLOW_LOCAL_FALLBACK` for production builds.

See `docs/deployment_production.md` for the full deployment checklist.

If the Next.js dev cache is corrupted and `.next/routes-manifest.json` is
missing:

```bash
cd apps/admin
rm -rf .next
npm run dev
```
