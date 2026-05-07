# UfficcioFacile Supabase Setup

## Required dart-defines

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `UFFICCIOFACILE_BACKEND_MODE=local|supabase`
- `UFFICCIOFACILE_ENABLE_SYNC=true|false`
- `UFFICCIOFACILE_ENABLE_ADMIN_DEBUG=true|false`

Optional compatibility fallbacks:
- `APP_BACKEND_MODE`
- `GYMPAL_BACKEND_MODE`

## Local-only mode

If `SUPABASE_URL` or `SUPABASE_ANON_KEY` is missing, the app stays in local-only mode.
This is intentional and must not crash startup.

## Supabase mode

Use:

```bash
flutter run \
  --dart-define=UFFICCIOFACILE_BACKEND_MODE=supabase \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=... \
  --dart-define=UFFICCIOFACILE_ENABLE_SYNC=true
```

## Migrations

Recommended commands once a real project is linked:

```bash
supabase db push
supabase db diff
```

This repo currently adds SQL under `supabase/migrations/`.

## RLS

All user-owned tables are scoped by `auth.uid()`.
Global catalog tables are read-only for authenticated users.
Admin writes stay protected behind `is_ufficcio_admin()`.

## Storage

Suggested private buckets:
- `ufficcio-user-documents`
- `ufficcio-proof-items`

Use signed URLs only. Do not make user files public.

## Auth

The app does not require login for local-only use.
Sync should only be enabled after authenticated Supabase session detection.

## Admin role notes

If a real RBAC table exists later, update `public.is_ufficcio_admin()`.
Until then, it safely defaults to `false`.

## Troubleshooting

- Missing env vars: app remains local-only
- No session: app remains local-only for data storage, even if Supabase is configured
- CocoaPods missing: iOS build will fail until CocoaPods is installed locally
