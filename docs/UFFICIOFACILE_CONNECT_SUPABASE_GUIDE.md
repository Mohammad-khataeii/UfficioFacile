# UfficioFacile Supabase Connection Guide

## 1. Current Supabase Readiness Status

UfficioFacile is already **Supabase-capable**, but it is not yet a fully connected production Supabase app out of the box. The current repository includes:
- `supabase_flutter` in Flutter
- startup-safe optional Supabase initialization
- local-first fallback behavior
- a repository factory that switches between local and Supabase repositories
- real SQL migrations under `supabase/migrations/`
- RLS policies for the current `ufficcio_*` schema

Important current limitation:
- the current SQL schema is mostly designed around **authenticated user-owned tables**
- the newer **anonymous public catalog** direction is only partially reflected in code/docs
- current RLS does **not** expose catalog tables to `anon`; catalog reads are mostly `authenticated` only in the shipped migration
- normal app usage still works without account because the app stays local-first and falls back to local repositories

| Area | Status | Files | Notes |
| --- | --- | --- | --- |
| Supabase Flutter dependency | Implemented | [pubspec.yaml](/Users/mohammadkhataei/Desktop/UfficioFacile/pubspec.yaml) | `supabase_flutter: ^2.10.0` is present. |
| Supabase client bootstrap | Implemented | [lib/app/supabase_bootstrap.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/app/supabase_bootstrap.dart), [lib/main.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/main.dart) | Uses URL + anon key only; bounded timeout; app still starts locally on failure. |
| Backend mode config | Implemented | [lib/app/app_config.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/app/app_config.dart) | `UFFICCIOFACILE_BACKEND_MODE` selects `local` or `supabase`. |
| Repository switching | Implemented | [lib/features/italy_admin_copilot/data/ufficcio_supabase_readiness.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/data/ufficcio_supabase_readiness.dart) | Switches only when Supabase is enabled, sync is enabled, and user is authenticated. |
| Local fallback | Implemented | [lib/main.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/main.dart), [lib/app/app_startup.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/app/app_startup.dart) | Startup continues local-first if credentials are missing or bootstrap fails. |
| SQL migrations | Implemented | [supabase/migrations/20260506090000_create_ufficciofacile_core.sql](/Users/mohammadkhataei/Desktop/UfficioFacile/supabase/migrations/20260506090000_create_ufficciofacile_core.sql), [supabase/migrations/20260506091000_create_ufficciofacile_rls.sql](/Users/mohammadkhataei/Desktop/UfficioFacile/supabase/migrations/20260506091000_create_ufficciofacile_rls.sql), [supabase/migrations/20260506092000_seed_ufficciofacile_catalog.sql](/Users/mohammadkhataei/Desktop/UfficioFacile/supabase/migrations/20260506092000_seed_ufficciofacile_catalog.sql) | Real migrations exist and can be pushed. |
| RLS | Implemented, but auth-centric | [supabase/migrations/20260506091000_create_ufficciofacile_rls.sql](/Users/mohammadkhataei/Desktop/UfficioFacile/supabase/migrations/20260506091000_create_ufficciofacile_rls.sql) | Current policies favor authenticated users and admin-only writes. |
| Public catalog | Partial | SQL + local services | There is seeded data in `ufficcio_city_packs`, `ufficcio_official_links`, but no full anon-read hybrid catalog repository yet. |
| No-account behavior | Implemented locally | [lib/app/app_scope.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/app/app_scope.dart), [lib/features/italy_admin_copilot/presentation/screens/life_admin_supabase_screens.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/presentation/screens/life_admin_supabase_screens.dart) | App is usable without login; sync is optional. |
| Premium / entitlement | Local-first implemented | [lib/features/italy_admin_copilot/data/premium_service.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/data/premium_service.dart), [lib/features/italy_admin_copilot/domain/ufficcio_entitlement.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/domain/ufficcio_entitlement.dart) | Real local entitlement logic exists; no real payment provider is wired. |
| Admin | Local/debug-oriented | [lib/features/italy_admin_copilot/presentation/screens/life_admin_screens.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/presentation/screens/life_admin_screens.dart) | Admin UI exists, but secure remote admin writes are not fully implemented. |

## 2. What Supabase Is Used For in UfficioFacile

In the current repository, Supabase is intended for:
- optional remote profile storage
- optional remote request/generated-pack storage
- optional sync of user settings
- optional entitlement persistence
- future catalog/config hosting
- future admin-managed content
- future auth-backed sync
- future payment verification and entitlement enforcement

Current reality in this repo:
- users can use the app without account
- generated requests, drafts, reminders, documents, contacts, proof items, deadlines, templates, and entitlement state are stored locally
- the app can start and operate fully in local mode
- sync is only meaningful when Supabase is enabled **and** a user is authenticated

What Supabase should be used for going forward:
- public catalog data such as official links, city packs, provider guidance, service terms, and app config
- admin-managed catalog verification
- optional future user sync
- optional future auth
- optional future payment verification

What Supabase must **not** be used for in the Flutter app:
- never use the service role key in Flutter
- never put admin secret keys in mobile/web builds

## 3. Required Supabase Project Setup

Step-by-step for this repository:

1. Create a Supabase project in the Supabase dashboard.
2. Choose the region closest to your users.
3. Copy the **Project URL**.
4. Copy the **anon/public key**.
5. Do **not** copy the service role key into Flutter.
6. Install the Supabase CLI if it is not already installed.
7. Log in with the CLI.
8. Link this repo to the remote project.
9. Push the local migrations.
10. Verify that the expected `ufficcio_*` tables exist.
11. Verify that RLS is enabled.
12. Verify that intended read policies behave as expected.
13. Verify that admin writes are not open to anon users.

Commands:

```bash
supabase login
supabase link --project-ref YOUR_PROJECT_REF
supabase db push
supabase status
supabase migration list
```

Current repo note:
- migrations live under [supabase/migrations](/Users/mohammadkhataei/Desktop/UfficioFacile/supabase/migrations)
- `supabase db push` is the correct command for this repo

## 4. Environment Variables / Dart Defines

| Variable | Required? | Example | Purpose | Missing Behavior |
| --- | --- | --- | --- | --- |
| `UFFICCIOFACILE_BACKEND_MODE` | Yes for explicit mode | `local` or `supabase` | Selects backend mode in [lib/app/app_config.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/app/app_config.dart). | Defaults to `local`. |
| `SUPABASE_URL` | Required only for Supabase mode | `https://YOUR_PROJECT_REF.supabase.co` | Used by [lib/app/supabase_bootstrap.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/app/supabase_bootstrap.dart). | App falls back to local behavior. |
| `SUPABASE_ANON_KEY` | Required only for Supabase mode | `YOUR_PUBLIC_ANON_KEY` | Used by [lib/app/supabase_bootstrap.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/app/supabase_bootstrap.dart). | App falls back to local behavior. |
| `UFFICCIOFACILE_ENABLE_SYNC` | Optional | `true` | Default sync toggle in config. | Defaults to `false`. |
| `UFFICCIOFACILE_ENABLE_ADMIN_DEBUG` | Optional | `true` | Enables local admin debug behavior. | Defaults to `false`. |
| `UFFICCIOFACILE_ENABLE_BETA_MODE` | Optional | `true` | Default premium beta behavior. | Defaults to `true`. |
| `UFFICCIOFACILE_ENABLE_PAYWALL` | Optional | `false` | Default premium paywall behavior. | Defaults to `false`. |
| `UFFICCIOFACILE_ENABLE_ANALYTICS` | Optional | `true` | Default analytics toggle. | Defaults to `true`. |
| `APP_BACKEND_MODE` | Legacy compatibility | `local` | Older compatibility alias. | Ignored if `UFFICCIOFACILE_BACKEND_MODE` is set. |
| `GYMPAL_BACKEND_MODE` | Legacy compatibility | `local` | Backward-compatibility alias still read by config. | Ignored if newer variables are set. |

Exact run commands for this repo:

Local mode:

```bash
flutter run -d chrome --dart-define=UFFICCIOFACILE_BACKEND_MODE=local
```

Supabase mode:

```bash
flutter run -d chrome \
  --dart-define=UFFICCIOFACILE_BACKEND_MODE=supabase \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT_REF.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_PUBLIC_ANON_KEY
```

macOS:

```bash
flutter run -d macos \
  --dart-define=UFFICCIOFACILE_BACKEND_MODE=local
```

Android:

```bash
flutter run -d android \
  --dart-define=UFFICCIOFACILE_BACKEND_MODE=local
```

iOS:

```bash
flutter run -d <DEVICE_ID> \
  --dart-define=UFFICCIOFACILE_BACKEND_MODE=local
```

Build examples:

```bash
flutter build web --dart-define=UFFICCIOFACILE_BACKEND_MODE=local
flutter build apk --release --dart-define=UFFICCIOFACILE_BACKEND_MODE=local
flutter build ios --release --dart-define=UFFICCIOFACILE_BACKEND_MODE=local
```

## 5. Supabase Migrations to Apply

| Migration File | Purpose | Tables/Policies Created | Safe to Push? | Notes |
| --- | --- | --- | --- | --- |
| [20260506090000_create_ufficciofacile_core.sql](/Users/mohammadkhataei/Desktop/UfficioFacile/supabase/migrations/20260506090000_create_ufficciofacile_core.sql) | Core schema | Creates `ufficcio_*` tables and helper functions | Yes | Main schema migration. |
| [20260506091000_create_ufficciofacile_rls.sql](/Users/mohammadkhataei/Desktop/UfficioFacile/supabase/migrations/20260506091000_create_ufficciofacile_rls.sql) | RLS and policies | Enables RLS and creates policies | Yes | Current policies are mostly `authenticated`-centric. |
| [20260506092000_seed_ufficciofacile_catalog.sql](/Users/mohammadkhataei/Desktop/UfficioFacile/supabase/migrations/20260506092000_seed_ufficciofacile_catalog.sql) | Seed config/catalog | Seeds admin config, city packs, official links, checklist items | Yes | Seed content is small and safe. |

Migration order is the folder order:
1. core schema
2. RLS
3. seed data

This repo also has documentation SQL files:
- [docs/life_admin_copilot_schema.sql](/Users/mohammadkhataei/Desktop/UfficioFacile/docs/life_admin_copilot_schema.sql)
- [docs/life_admin_phase5_schema.sql](/Users/mohammadkhataei/Desktop/UfficioFacile/docs/life_admin_phase5_schema.sql)

Those docs files are **not** the active Supabase migrations for the current repo. Use the files under `supabase/migrations` first.

## 6. Database Tables

The current real migrations create these actual tables:

| Table | Purpose | Public/Private | RLS Policy | Used By App? |
| --- | --- | --- | --- | --- |
| `ufficcio_profiles` | User profile | Private | Own row for authenticated user | Yes |
| `ufficcio_user_settings` | User settings and sync flags | Private | Own row for authenticated user | Yes |
| `ufficcio_requests` | Saved generated requests | Private | Own row for authenticated user | Yes |
| `ufficcio_generated_packs` | Generated pack payloads | Private | Own row for authenticated user | Yes |
| `ufficcio_status_events` | Request status history | Private | Own row select/insert | Yes |
| `ufficcio_reminders` | Reminders | Private | Own row for authenticated user | Yes |
| `ufficcio_documents` | Document metadata | Private | Own row for authenticated user | Partially |
| `ufficcio_contacts` | Contact metadata | Private | Own row for authenticated user | Partially |
| `ufficcio_household_members` | Household members | Private | Own row for authenticated user | Partially |
| `ufficcio_household_contracts` | Household contracts | Private | Own row for authenticated user | Partially |
| `ufficcio_utility_comparisons` | Utility comparison runs | Private | Own row for authenticated user | Partially |
| `ufficcio_bill_analyses` | Bill analysis runs | Private | Own row for authenticated user | Partially |
| `ufficcio_proof_cases` | Proof folders | Private | Own row for authenticated user | Partially |
| `ufficcio_proof_items` | Proof items | Private | Own row for authenticated user | Partially |
| `ufficcio_checklist_items` | Global checklist catalog | Shared catalog | Authenticated read on active rows | Seeded |
| `ufficcio_user_checklist_state` | User checklist completion | Private | Own row for authenticated user | Planned |
| `ufficcio_city_packs` | Global city pack catalog | Shared catalog | Authenticated read on active rows | Seeded |
| `ufficcio_official_links` | Global official links directory | Shared catalog | Authenticated read on active rows | Seeded/local UI analog exists |
| `ufficcio_template_overrides` | Admin template overrides | Admin/shared | Admin write | Yes |
| `ufficcio_community_templates` | User/community templates | Mixed private/shared | Own row | Partial |
| `ufficcio_usage_events` | Analytics events | Private | Own row for authenticated user | Partial |
| `ufficcio_feedback` | Feedback items | Private | Own row | Partial |
| `ufficcio_entitlements` | Premium entitlements | Private | Own row | Yes |
| `ufficcio_admin_config` | App/admin config | Admin/shared | Authenticated read, admin write | Seeded |
| `ufficcio_sync_log` | Sync log | Private | Own row | Partial |
| `ufficcio_delete_requests` | Delete/export requests | Private | Own row | Planned |

Current gap:
- the repo does **not** yet include the newer `ufficio_*` public catalog tables described in newer planning docs
- if you need true anon public catalog reads, you will need follow-up migrations

## 7. RLS Policies and Security

Current security model from the real migration:
- RLS is enabled on exposed tables
- private user tables are limited to `authenticated` users and `auth.uid()`
- some shared catalog-like tables are readable only by `authenticated` users, not `anon`
- admin writes depend on `public.is_ufficcio_admin()`
- in the current core migration, `public.is_ufficcio_admin()` always returns `false`, so safe remote admin writes are effectively disabled unless you replace that logic

Important implications:
- this is safe by default
- this is **not yet** the anonymous public catalog model requested later in product planning

Example SQL checks after pushing migrations:

```sql
select * from public.ufficcio_official_links limit 5;
select * from public.ufficcio_city_packs limit 5;
select * from public.ufficcio_admin_config limit 5;
```

What to verify manually:
- RLS is enabled on all expected tables
- anon users cannot write
- authenticated users cannot write admin tables unless you explicitly implement admin role logic
- no service role key is present in Flutter

## 8. Public Catalog Data Setup

Current seeded catalog-like data is limited but real:
- `ufficcio_city_packs`
- `ufficcio_official_links`
- `ufficcio_checklist_items`
- `ufficcio_admin_config`

Source files:
- [supabase/migrations/20260506092000_seed_ufficciofacile_catalog.sql](/Users/mohammadkhataei/Desktop/UfficioFacile/supabase/migrations/20260506092000_seed_ufficciofacile_catalog.sql)
- bundled/local UI services in [lib/features/italy_admin_copilot/data/life_admin_phase5_services.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/data/life_admin_phase5_services.dart)
- service intelligence definitions in [lib/features/italy_admin_copilot/data/service_intelligence_definitions.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/data/service_intelligence_definitions.dart)
- term dictionary in [lib/features/italy_admin_copilot/data/service_terms_dictionary.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/data/service_terms_dictionary.dart)

How catalog works today:
- some guidance is bundled directly in Dart
- some future-ready tables exist in Supabase
- there is no single finished `HybridCatalogRepository` yet

Verification status meaning in the app/docs:
- `verified`: trusted source exists
- `needsReview`: likely useful, but user should verify before use
- `unverified`: placeholder or incomplete

## 9. Flutter Supabase Integration

Exact files/classes:
- startup config: [lib/app/app_config.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/app/app_config.dart)
- bootstrap: [lib/app/supabase_bootstrap.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/app/supabase_bootstrap.dart)
- app startup: [lib/main.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/main.dart)
- dependency injection: [lib/app/app_scope.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/app/app_scope.dart)
- repository factory: [lib/features/italy_admin_copilot/data/ufficcio_supabase_readiness.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/data/ufficcio_supabase_readiness.dart)

How it works:
1. `main()` creates `_BootstrapApp` with `UfficcioFacileConfig.fromEnv`.
2. SharedPreferences is loaded with a 3-second timeout.
3. `SupabaseBootstrap.initializeIfNeeded(config)` runs with a 3-second timeout.
4. If bootstrap fails or credentials are missing, the app still builds `AppScope`.
5. `AppScope` always creates local repositories and services.
6. `UfficcioRepositoryFactory` switches to Supabase repositories only when:
   - backend mode is `supabase`
   - sync is enabled
   - Supabase is initialized
   - user is authenticated

Current practical effect:
- Supabase mode alone is not enough
- authenticated user state is also required before request/profile/settings repositories switch remote

## 10. No-Account Mode

Current MVP behavior:
- no login is required to open the app
- no login is required to generate request packs
- no login is required to save locally
- no login is required to use city packs, service intelligence, or local guidance
- no login is required to use premium beta/debug logic

Local-only storage still covers:
- generated requests
- drafts
- profile
- reminders
- documents
- contacts
- proof folder
- deadlines
- templates
- entitlement state

Sync UI exists in:
- [lib/features/italy_admin_copilot/presentation/screens/life_admin_supabase_screens.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/presentation/screens/life_admin_supabase_screens.dart)

It explicitly tells the user:
- they can continue using the app locally without an account

## 11. Optional Auth / Future User Sync

Auth is **not required for the current MVP**.

Current status:
- there is an auth facade: `UfficcioAuthFacade`
- it only reads `SupabaseBootstrap.client.auth.currentUser`
- there is no complete sign-in/sign-up UI flow in the repository

Future path:
1. enable Supabase Auth
2. add sign-in UI
3. keep local-first mode as default
4. allow opt-in sync only after authentication
5. preserve RLS by `auth.uid()`
6. add conflict handling and last-sync UI

## 12. Premium and Entitlements

Current premium setup:
- plans: Free / Pro / Consultant
- beta mode and paywall flags
- local premium config repository
- local entitlement repository
- optional Supabase entitlement repository exists
- no real payment provider is implemented

Important files:
- [lib/features/italy_admin_copilot/data/premium_service.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/data/premium_service.dart)
- [lib/features/italy_admin_copilot/domain/premium_config.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/domain/premium_config.dart)
- [lib/features/italy_admin_copilot/domain/ufficcio_entitlement.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/domain/ufficcio_entitlement.dart)

How to test:
- open admin premium screen at `/life-admin/admin/premium`
- toggle beta mode
- toggle paywall
- activate local Pro for debug

What is not implemented:
- secure server-side payment verification
- production subscription enforcement

## 13. Admin Panel and Catalog Updates

Admin routes:
- `/life-admin/admin`
- `/life-admin/admin/premium`

Current status:
- admin is mainly local/debug-oriented
- remote admin writes are not production-ready
- the SQL admin function currently returns `false`, which prevents accidental writes

What admin can do today:
- inspect local quality data
- use premium debug toggles
- seed demo data
- review generated pack quality

## 14. Storage Buckets

Supabase Storage is not required for the current MVP.

Current app behavior:
- documents are tracked as local metadata
- there is no finished Supabase Storage workflow in the inspected repo

## 15. Exact Commands to Run

A. Install dependencies:

```bash
flutter clean
flutter pub get
```

B. Run local:

```bash
flutter run -d chrome --dart-define=UFFICCIOFACILE_BACKEND_MODE=local
```

C. Run with Supabase:

```bash
flutter run -d chrome \
  --dart-define=UFFICCIOFACILE_BACKEND_MODE=supabase \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT_REF.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_PUBLIC_ANON_KEY
```

D. Push migrations:

```bash
supabase login
supabase link --project-ref YOUR_PROJECT_REF
supabase db push
```

E. Build:

```bash
flutter build web --dart-define=UFFICCIOFACILE_BACKEND_MODE=local
flutter build apk --release --dart-define=UFFICCIOFACILE_BACKEND_MODE=local
flutter build ios --release --dart-define=UFFICCIOFACILE_BACKEND_MODE=local
```

## 16. Verification Checklist

Supabase side:
- [ ] project created
- [ ] migrations pushed
- [ ] tables visible
- [ ] RLS enabled
- [ ] anon/public access checked against intended policy
- [ ] anon cannot write catalog
- [ ] authenticated users only see their own private rows
- [ ] no service role key in app

Flutter side:
- [ ] local mode works
- [ ] Supabase mode boots
- [ ] app still opens if Supabase is unavailable
- [ ] no account required for local usage
- [ ] sync screen shows accurate status
- [ ] premium config still works locally
- [ ] generated request flow still works
- [ ] procedure detail pages still render

## 17. Troubleshooting

Missing `SUPABASE_URL`
- Symptom: app reports local mode or does not initialize Supabase.
- Likely cause: missing dart-define.
- Fix: pass `--dart-define=SUPABASE_URL=...`.

Missing `SUPABASE_ANON_KEY`
- Symptom: Supabase mode falls back local.
- Likely cause: missing anon key.
- Fix: pass `--dart-define=SUPABASE_ANON_KEY=...`.

Invalid API key
- Symptom: bootstrap error from Supabase.
- Likely cause: wrong key or wrong project.
- Fix: use the public anon key from the correct project.

RLS blocks data
- Symptom: remote reads return empty or permission errors.
- Likely cause: current policies require authenticated user ownership.
- Fix: sign in for private tables, or add new anon-readable catalog policies if you are implementing public catalog mode.

Catalog empty
- Symptom: no seeded rows in expected tables.
- Likely cause: migrations not pushed or seed migration not applied.
- Fix: run `supabase db push` and verify migration list.

Migration failed
- Symptom: `supabase db push` aborts.
- Likely cause: project mismatch, SQL drift, or existing conflicting objects.
- Fix: inspect migration output, compare remote schema, and repair drift before retrying.

Table does not exist
- Symptom: repository or SQL query fails on `ufficcio_*` table.
- Likely cause: migrations not applied.
- Fix: push migrations and verify in Supabase Table Editor.

App stuck loading
- Symptom: startup spinner stays too long.
- Likely cause: slow storage or bootstrap path.
- Fix: wait for fallback button, then continue in local mode; also inspect startup logs in debug mode.

Local fallback not working
- Symptom: app cannot recover from missing Supabase.
- Likely cause: unexpected startup exception outside handled path.
- Fix: run local mode explicitly and inspect `StartupErrorScreen` debug details.

Wrong table prefix
- Symptom: docs or expectations mention `ufficio_*`, but SQL has `ufficcio_*`.
- Likely cause: current repo uses `ufficcio_*` everywhere in real migrations.
- Fix: use the existing `ufficcio_*` names unless you intentionally create a migration to rename or bridge them.

Accidentally using service role key
- Symptom: unsafe client configuration.
- Likely cause: wrong key copied from dashboard.
- Fix: replace with anon/public key immediately; never ship service role key.

“Could not find table in schema cache”
- Symptom: Supabase client errors after adding schema.
- Likely cause: migration not applied or wrong schema/table name.
- Fix: confirm `public.ufficcio_*` table exists and re-run migration if needed.

## 18. Known Gaps Before Production

- no full anonymous public catalog table set yet
- current RLS does not expose catalog to anon as the later product direction expects
- no real auth UI flow
- no real remote sync UX beyond scaffolding
- no real payment verification
- no secure remote admin workflow
- official catalog completeness is still partial
- iOS environment still needs CocoaPods working locally
- macOS platform folder is not present in this repo snapshot

## 19. Final Step-by-Step Quick Start

1. Create a Supabase project.
2. Copy the Project URL.
3. Copy the anon key.
4. Run `supabase login`.
5. Run `supabase link --project-ref YOUR_PROJECT_REF`.
6. Run `supabase db push`.
7. Start the app with Supabase dart-defines.
8. Open the sync screen and verify backend status.
9. Test a local-only run too.
10. Test a real procedure flow and confirm the app still works if Supabase is unavailable.
