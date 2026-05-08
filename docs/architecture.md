# UfficioFacile Architecture

UfficioFacile has three main layers:

1. Flutter consumer app under `lib/`
2. Next.js admin backoffice under `apps/admin`
3. Supabase for auth, CMS, requests, entitlements, and audit data

## Runtime flow

- Flutter prefers Supabase-backed CMS content when it is available.
- If remote CMS calls fail or time out, Flutter falls back to the bundled CMS export.
- The bundled CMS export is generated from the category registry in:
  - `lib/features/italy_admin_copilot/content/categories`
  - `lib/features/italy_admin_copilot/content/category_registry.dart`

## Content identity

- Category identity is the category slug.
- Procedure identity should be treated as `category_slug + slug`.
- Premium visibility is decided in the UI and entitlement layer, not by filtering premium rows out of repositories.

## Stability rules

- Remote CMS fetches should time out quickly.
- Bundled fallback must keep the app usable when Supabase CMS is unavailable.
- Admin pages should degrade gracefully when optional premium tables are missing.
