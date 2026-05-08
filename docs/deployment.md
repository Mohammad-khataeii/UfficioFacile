# Deployment

## Flutter checks

From repo root:

```bash
dart format lib test tool
flutter analyze
flutter test
/usr/local/share/flutter/bin/dart run tool/export_cms_seed.dart
/usr/local/share/flutter/bin/dart run tool/content_doctor.dart
```

## Admin checks

```bash
cd apps/admin
rm -rf .next
npm run build
npm run lint
npm run content:lint
```

If local Next.js development fails with `routes-manifest.json` missing:

```bash
cd apps/admin
rm -rf .next
npm run dev
```

Or use:

```bash
npm run clean
npm run dev:clean
```

## Supabase migrations

Apply local migrations with:

```bash
supabase db push
```

If this machine is not authenticated, the command will fail until `supabase login` or `SUPABASE_ACCESS_TOKEN` is configured.
