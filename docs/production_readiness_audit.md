# Production Readiness Audit

Last updated: 2026-05-21

## Self-service account deletion and privacy upgrade pass (2026-05-21)

### What was added or upgraded

- Added the secure Supabase Edge Function at `supabase/functions/delete-account/index.ts`
- Added the account-deletion data map at `docs/privacy/account_deletion_data_map.md`
- Added the Flutter client service for deletion requests in `lib/features/auth/data/account_deletion_service.dart`
- Added the destructive confirmation dialog with typed `DELETE` confirmation in `lib/features/auth/presentation/account_deletion_dialog.dart`
- Upgraded the Privacy Center to support:
  - `Delete my account`
  - `Request deletion by email`
- Added a visible delete-account entry in the Account screen
- Updated the public privacy page and public account deletion page to describe self-service deletion plus the support fallback
- Updated Play Store privacy, account deletion, Data Safety, store listing, and final submission docs to reflect the new self-service flow
- Strengthened the release doctor to verify the new function, data-map doc, public pages, config, and UI text

### Commands run

- `dart format lib test tool`
  - Result: passed
- `flutter pub get`
  - Result: passed
- `flutter analyze`
  - Result: passed
- `flutter test`
  - Result: passed
- `/usr/local/share/flutter/bin/dart run tool/content_doctor.dart`
  - Result: passed
- `/usr/local/share/flutter/bin/dart run tool/localization_doctor.dart`
  - Result: passed
- `/usr/local/share/flutter/bin/dart run tool/google_play_release_doctor.dart`
  - Result: passed, with versionCode warning and local untracked key warning only

### What remains manual

- Deploy the `delete-account` function to the real Supabase project
- Test the deletion flow against the linked Supabase environment
- Verify that expected profile, request, and connected-data rows are removed
- Verify that retained payment or audit rows are detached or anonymized as expected
- Deploy the updated web build so the public privacy and account-deletion URLs stay current
- Update Play Console with the privacy and account-deletion URLs
- Test the deletion flow from the Play-installed build

## Play Console content and privacy publication pass (2026-05-21)

### What files and pages were added or improved

- Added public privacy page at `/privacy` via `web/privacy/index.html`
- Added public account deletion page at `/account-deletion` via `web/account-deletion/index.html`
- Added compatibility redirects for:
  - `/ufficcio/privacy`
  - `/ufficio/privacy`
  - `/life-admin/privacy`
  - `/delete-account`
- Added `docs/play_store/play_console_copy.md`
- Added `docs/play_store/final_submission_checklist.md`
- Updated privacy, account deletion, store listing, data safety, and deployment docs to point at the public URLs
- Strengthened the release doctor to verify Play Console copy docs, public-page files, and doc safety checks

### Commands run

- `dart format lib test tool`
  - Result: passed
- `flutter pub get`
  - Result: passed
- `flutter analyze`
  - Result: passed
- `flutter test`
  - Result: passed
- `dart run tool/content_doctor.dart`
  - Result: failed in this environment due to Flutter SDK sandbox path issue
- `/usr/local/share/flutter/bin/dart run tool/content_doctor.dart`
  - Result: passed
- `dart run tool/localization_doctor.dart`
  - Result: failed in this environment due to Flutter SDK sandbox path issue
- `/usr/local/share/flutter/bin/dart run tool/localization_doctor.dart`
  - Result: passed
- `dart run tool/google_play_release_doctor.dart`
  - Result: failed in this environment due to Flutter SDK sandbox path issue
- `/usr/local/share/flutter/bin/dart run tool/google_play_release_doctor.dart`
  - Result: passed, with versionCode warning only
- `/usr/local/share/flutter/bin/dart run tool/print_google_play_commands.dart`
  - Result: passed

### What passed

- Public privacy page exists without login
- Public account deletion page exists without login
- Play Console copy doc exists
- Final submission checklist exists
- README and deployment docs link the Play Console docs and public URLs
- `flutter analyze` passes
- `flutter test` passes
- `tool/google_play_release_doctor.dart` passes

### What remains manual

- Fill Play Console forms
- Create the reviewer account and password
- Upload screenshots and graphics
- Upload the signed AAB
- Submit internal testing
- Review the pre-launch report
- Test Stripe and Supabase from the Play-installed build

## Internal testing prep follow-up pass (2026-05-21)

### What was fixed

- Fixed the remaining wrong app-config dart-define typo in the Android deployment docs by keeping the canonical `UFFICCIOFACILE_*` prefix for app config flags.
- Added `docs/play_store/local_signing_step_by_step.md` with the exact local keystore and `android/key.properties` flow.
- Added `tool/print_google_play_commands.dart` to print the local signing, doctor, Gradle, and AAB build commands.
- Strengthened `tool/google_play_release_doctor.dart` to check:
  - wrong non-AdMob `UFFICIOFACILE_*` app-config flags
  - Play docs and command-printer presence
  - tracked signing files
  - `android/key.properties.example`
  - account deletion UI evidence
  - local-signing guide presence
  - `CHANGE_ME` placeholder misuse
  - `versionCode` warning if still `1`
- Verified the in-app account deletion request action remains visible in the Privacy Center and improved the generated email body.
- Improved Play Store drafts for reviewer instructions, store listing, privacy policy, data safety, Android permissions, and account deletion proof.
- Added a concise “before upload run this” block to README and deployment docs.

### Commands run

- `dart format lib test tool`
  - Result: passed
- `flutter pub get`
  - Result: passed
- `flutter analyze`
  - Result: passed
- `flutter test`
  - Result: passed
- `dart run tool/content_doctor.dart`
  - Result: passed
- `dart run tool/localization_doctor.dart`
  - Result: passed
- `dart run tool/google_play_release_doctor.dart`
  - Result: passed, with versionCode warning expected while still at `1.0.0+1`
- `dart run tool/print_google_play_commands.dart`
  - Result: passed

### Remaining manual steps

- Create the local upload keystore.
- Fill local `android/key.properties` or export the release signing environment variables.
- Build the signed `.aab`.
- Publish the privacy policy URL and use the exact same URL in Play Console.
- Complete Play Console Data Safety, ads declaration, content rating, target audience/content, and reviewer access fields.
- Run Google Play Internal Testing and review the pre-launch report.
- Verify live Supabase and Stripe behavior before any broader rollout.

### Current status

- Repo is ready for Google Play Internal Testing preparation. Actual upload still requires local signing key, signed AAB, Play Console forms, privacy policy publication, and live Supabase/Stripe verification.

## Android Google Play readiness pass (2026-05-21)

### What was fixed

- Replaced the default Android package identity with `it.ufficiofacile.app`.
- Moved `MainActivity` into `android/app/src/main/kotlin/it/ufficiofacile/app/`.
- Updated `android/app/build.gradle.kts` so release signing loads from `android/key.properties` or `ANDROID_KEYSTORE_PATH`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, and `ANDROID_KEY_PASSWORD`.
- Removed release debug signing and made release bundle builds fail loudly when signing is missing.
- Added `android/key.properties.example` and ignored local keystore material in `.gitignore`.
- Enforced Play-compliant Android SDK floors in Gradle and added `printAndroidReleaseInfo`.
- Replaced the hardcoded sample AdMob app ID in the release manifest path with a Gradle placeholder.
- Added production-safe ad behavior so production builds disable ads unless real AdMob IDs are configured.
- Added a safe in-app account deletion request route in the privacy center.
- Added `tool/google_play_release_doctor.dart`.
- Added Play Store compliance drafts and release docs under `docs/play_store/`.
- Updated README and deployment docs with Android App Bundle, signing, redirect, and release-check instructions.
- Documented Supabase and Stripe production prerequisites, redirect URLs, and manual test flows.

### Commands run

From repo root:

- `/usr/local/share/flutter/bin/dart format lib test tool`
  - Result: passed
- `/usr/local/share/flutter/bin/flutter pub get`
  - Result: passed
- `/usr/local/share/flutter/bin/flutter analyze`
  - Result: passed
- `/usr/local/share/flutter/bin/flutter test`
  - Result: passed
- `/usr/local/share/flutter/bin/dart run tool/content_doctor.dart`
  - Result: passed
- `/usr/local/share/flutter/bin/dart run tool/localization_doctor.dart`
  - Result: passed after filling missing auth localization keys
- `/usr/local/share/flutter/bin/dart run tool/google_play_release_doctor.dart`
  - Result: passed
- `/usr/local/share/flutter/bin/flutter build appbundle --release --dart-define=UFFICCIOFACILE_FLAVOR=production --dart-define=SUPABASE_URL=https://example.supabase.co --dart-define=SUPABASE_ANON_KEY=example-anon-key --dart-define=UFFICCIOFACILE_ENABLE_PAYWALL=true --dart-define=UFFICCIOFACILE_ENABLE_BETA_MODE=false`
  - Result: failed as designed because release signing is not configured yet

From `android`:

- `./gradlew printAndroidReleaseInfo`
  - Result: passed
  - Output summary:
    - `applicationId=it.ufficiofacile.app`
    - `namespace=it.ufficiofacile.app`
    - `compileSdk=36`
    - `minSdk=24`
    - `targetSdk=36`
    - `versionCode=1`
    - `versionName=1.0.0`
    - `releaseSigningConfigured=false`
    - `releaseAdmobAppIdConfigured=false`

### What passed

- No active Android release file still uses `com.example.ufficiofacile`.
- Release signing no longer points at the debug signing config.
- The new Play release doctor passes.
- Flutter analysis passes.
- Flutter tests pass.
- Localization and content doctor scripts pass.
- The Android manifest deep links now match the documented native auth URLs.
- The Android release-info task confirms the final package identity and target SDK floor.

### What could not be fully verified here

- A signed `.aab` could not be produced in this environment because no local upload keystore or release signing values were supplied.
- Play Console declarations, screenshots, privacy policy publishing, content rating, and review access remain manual.
- Live Supabase and Stripe payment verification was not executed against a production-like deployed backend in this pass.

### Remaining manual Play Console and environment steps

- Generate or provide the upload keystore locally and configure `android/key.properties` or the `ANDROID_KEYSTORE_*` environment variables.
- Publish the privacy policy URL referenced by the Play listing.
- Complete the Play Console Data Safety, ads declaration, content rating, target audience/content, and app access sections.
- Provide a real reviewer account or equivalent reviewer-access instructions.
- If ads will ship, set real AdMob production IDs and ensure the Play ads declaration matches the build.
- Run internal testing, review the pre-launch report, and validate real-device behavior.
- Deploy Supabase functions and confirm live Stripe webhook and entitlement behavior before any production rollout.

### Current status

- Ready for Google Play internal testing only if local signing and environment setup are completed and the signed release bundle is built successfully.
- Not ready for production rollout until internal testing, Play pre-launch review, and live Supabase/Stripe checks all pass.

## Admin alignment pass (2026-05-14)

### What was broken

- The Next.js admin content pages were rendering raw `ufficio_cms_*` rows directly instead of a normalized admin model.
- `apps/admin/app/content/procedures/[categorySlug]/[procedureSlug]/page.tsx` assumed `procedure.category_slug`, `procedure.slug`, `procedure.title`, and other fields were always present and correctly shaped, so a missing or partially mismapped procedure row caused a runtime crash instead of a safe admin error state.
- Category and procedure screens were still modeling the catalog as flat category/procedure rows even though the Flutter app now uses a real category → subcategory → procedure hierarchy.
- Premium admin pages still surfaced legacy Plus-era products as first-class plans instead of treating them as backward-compatible legacy records.
- Problem and consultancy request screens still showed older field assumptions and copy that no longer matched the simplified premium model.

### Real current schema and app model

- Public app catalog model:
  - category
  - derived subcategory
  - procedure
- Admin CMS storage model:
  - `public.ufficio_cms_categories`
  - `public.ufficio_cms_procedures`
  - `public.ufficio_cms_content_blocks`
  - supporting `links`, `contacts`, `documents`, `sources`, `revisions`, `drafts`
- Current canonical public procedure identity remains `(category_slug, slug)`.
- Current public premium product model is only:
  - `premium_monthly`
  - `premium_yearly`
- Legacy plans and unlock products still exist in data for compatibility and history, but should not be treated as the primary public offering.

### Files being changed in this admin alignment pass

- `apps/admin/app/content/page.tsx`
- `apps/admin/app/content/categories/page.tsx`
- `apps/admin/app/content/categories/[slug]/page.tsx`
- `apps/admin/app/content/procedures/page.tsx`
- `apps/admin/app/content/procedures/[categorySlug]/[procedureSlug]/page.tsx`
- `apps/admin/app/premium/page.tsx`
- `apps/admin/app/premium/plans/page.tsx`
- `apps/admin/app/requests/problem/page.tsx`
- `apps/admin/app/requests/consultancy/page.tsx`
- `apps/admin/components/sidebar.tsx`
- `apps/admin/lib/catalog/types.ts`
- `apps/admin/lib/catalog/mappers.ts`
- `apps/admin/lib/catalog/queries.ts`
- `apps/admin/lib/db/mutations.ts`
- `apps/admin/lib/db/queries.ts`
- `apps/admin/lib/validation/schemas.ts`
- `apps/admin/package.json`
- `apps/admin/scripts/audit-user-facing-copy.mjs`

### Migration need

- No new Supabase migration has been added in this admin alignment pass so far.
- The current admin crash and model drift can be fixed in the application layer because the needed CMS/request/premium fields already exist in the current schema.

## Architecture summary

- Flutter client runtime: `lib/`
- Startup/config/bootstrap: `lib/app`
- Premium/catalog/product flows: `lib/features/italy_admin_copilot`
- Flutter CMS repository layer: `lib/features/admin_cms`
- Next.js admin: `apps/admin`
- Supabase migrations: `supabase/migrations`
- Supabase Edge Functions: `supabase/functions`
- Bundled CMS source: `lib/features/italy_admin_copilot/content/categories`
- Generated CMS exports:
  - `docs/generated/cms_bundled_content_export.json`
  - `apps/admin/data/cms_bundled_content_export.json`
- Canonical bundled catalog: `assets/catalog/ufficio_catalog.v1.json`

## What was fixed in this pass

### Flutter startup/config/auth/catalog/premium

- Premium entitlement resolution now treats server state as authoritative in Supabase mode.
- Expired, revoked, and cancelled premium states now resolve to non-premium access.
- Local debug premium is blocked outside development and blocked whenever Supabase is active.
- Premium usage counters now persist through server-backed RPC when Supabase is active.
- Premium category/subcategory/procedure navigation now checks access before navigation and the destination screens still check again.
- Search and direct route helpers now go through the same access gate used by the rest of the app.
- The plan screen now resolves exactly one current plan from the entitlement state instead of inferring from local products.
- The current plan card now shows a disabled current-plan button instead of an active purchase button.
- Startup/auth/paywall strings were localized on the release-critical surfaces and `tool/localization_doctor.dart` now passes.
- `HybridCatalogRepository.searchCatalog()` now merges remote and bundled search results instead of searching bundled data only.

### Admin auth/RBAC/content

- Admin CMS block lookup is now category-aware instead of relying on `procedure_slug` alone.
- Admin procedure reads now use `(category_slug, slug)` for canonical content-block detail loading.
- Premium plan-product writes now require `premium.manage`.
- Admin premium plan editing now supports `stripe_price_id` and provider metadata.
- Admin premium user detail now exposes source, period start/end, Stripe customer/subscription/price fields.

### Supabase/RLS/migrations

- Added a non-partial unique constraint for `public.ufficio_cms_procedures(category_slug, slug)` so Supabase upserts using `onConflict: "category_slug,slug"` have a matching database uniqueness target.
- Added `category_slug` to `public.ufficio_cms_content_blocks`, backfilled it, added category-aware foreign key/indexes, and updated public/authenticated read policies.
- Added hardened premium schema fields and indexes for:
  - `public.ufficio_user_entitlements`
  - `public.ufficio_premium_events`
  - `public.ufficio_plan_products`
  - `public.ufficio_user_content_unlocks`
  - `public.ufficio_usage_counters`
- Added `public.increment_ufficio_usage_counter(...)` as a security-definer RPC for server-backed usage updates.
- Added `supabase/config.toml` with `verify_jwt = false` for Stripe webhooks.

### Stripe / server-backed premium

- `supabase/functions/create-checkout-session/index.ts` now validates the authenticated user, validates `product_key` against active `ufficio_plan_products`, supports category/procedure metadata for single unlocks, and creates Stripe Checkout sessions server-side.
- `supabase/functions/stripe-webhook/index.ts` now verifies Stripe signatures from the raw request body, handles subscription and one-shot payment events, records idempotent `stripe_event_id` entries, updates entitlements/unlocks, and logs payment events.
- Flutter purchase actions now call the checkout-session function instead of relying on local-only state.

## Current risks and deferred issues

### Flutter startup/config/auth/catalog/premium

- Live Stripe/Supabase flow was not end-to-end exercised against a real deployed project in this environment.
- The premium implementation is now server-backed in code and schema, but live webhook deployment and secret wiring are still manual.

### Admin auth/RBAC/content

- Procedure identity is now category-aware in the DB and app code, but legacy slug-only compatibility routes still exist for old links by design.

### Supabase/RLS/migration

- Supabase CLI verification could not be completed in this environment because the `supabase` CLI binary is not installed here.
- Migrations were not dry-run against a linked project in this environment, so remote-apply verification remains manual.
- The repo still contains legacy `ufficcio_*` table/helper names alongside newer `ufficio_*` names. This remains compatibility debt, not a completed rename.

### Naming / route compatibility debt

- `/ufficcio/privacy` and related `Ufficcio` names still exist as compatibility routes/keys.
- No destructive rename was attempted for persisted keys, old routes, or legacy table names.

## Generated asset status

- `docs/generated/cms_bundled_content_export.json` exists and is non-empty.
- `apps/admin/data/cms_bundled_content_export.json` exists and is non-empty.
- `assets/catalog/ufficio_catalog.v1.json` remains the canonical committed catalog asset.

## Commands run

From repo root:

- `git status --short`
- `find . -maxdepth 4 -type f | sort`
- `sed -n ...` on audit target files and migrations
- `rg -n ...` across premium, CMS, routing, env, localization, and typo debt paths
- `/usr/local/share/flutter/bin/dart format lib test tool`
- `/usr/local/share/flutter/bin/flutter pub get`
- `/usr/local/share/flutter/bin/flutter analyze`
  - Result: passed
- `/usr/local/share/flutter/bin/flutter test`
  - Result: passed
- `/usr/local/share/flutter/bin/dart run tool/export_cms_seed.dart`
  - Result: passed
- `/usr/local/share/flutter/bin/dart run tool/content_doctor.dart`
  - Result: passed
- `/usr/local/share/flutter/bin/dart run tool/localization_doctor.dart`
  - Result: passed
- `supabase migration list`
  - Result: failed, `supabase: command not found`
- `supabase db push --dry-run`
  - Result: failed, `supabase: command not found`

From `apps/admin`:

- `npm install`
  - Result: passed, `2 moderate severity vulnerabilities`
- `npm audit`
  - Result: failed in this environment, `getaddrinfo ENOTFOUND registry.npmjs.org`
- `rm -rf .next`
  - Result: passed
- `npm run lint`
  - Result: passed
- `npm run content:lint`
  - Result: passed
- `npm run build`
  - Result: passed

## Manual SQL checks

Duplicate procedure identity:

```sql
select category_slug, slug, count(*)
from public.ufficio_cms_procedures
group by category_slug, slug
having count(*) > 1
order by count desc, category_slug, slug;
```

Current entitlement snapshot:

```sql
select user_id, plan, status, premium_access, current_period_end, revoked_at
from public.ufficio_user_entitlements
order by updated_at desc nulls last
limit 50;
```

Duplicate Stripe events:

```sql
select stripe_event_id, count(*)
from public.ufficio_premium_events
where stripe_event_id is not null
group by stripe_event_id
having count(*) > 1;
```

Unlock collisions:

```sql
select user_id, category_slug, procedure_slug, count(*)
from public.ufficio_user_content_unlocks
group by user_id, category_slug, procedure_slug
having count(*) > 1
order by count(*) desc;
```

## Files changed by this task

- `apps/admin/app/premium/plans/page.tsx`
- `apps/admin/app/premium/users/[id]/page.tsx`
- `apps/admin/data/cms_bundled_content_export.json`
- `apps/admin/lib/db/mutations.ts`
- `apps/admin/lib/db/queries.ts`
- `docs/generated/cms_bundled_content_export.json`
- `docs/production_readiness_audit.md`
- `lib/app/app.dart`
- `lib/app/app_localizations.dart`
- `lib/app/app_startup_widgets.dart`
- `lib/features/admin_cms/data/cms_repository.dart`
- `lib/features/admin_cms/data/local_cms_repository.dart`
- `lib/features/admin_cms/data/supabase_cms_repository.dart`
- `lib/features/admin_cms/domain/cms_models.dart`
- `lib/features/auth/presentation/account_screen.dart`
- `lib/features/auth/presentation/auth_screen.dart`
- `lib/features/auth/presentation/password_screens.dart`
- `lib/features/italy_admin_copilot/data/cms_content_repository.dart`
- `lib/features/italy_admin_copilot/data/hybrid_catalog_repository.dart`
- `lib/features/italy_admin_copilot/data/premium_service.dart`
- `lib/features/italy_admin_copilot/data/ufficcio_supabase_readiness.dart`
- `lib/features/italy_admin_copilot/data/ufficio_catalog_repository.dart`
- `lib/features/italy_admin_copilot/domain/premium_config.dart`
- `lib/features/italy_admin_copilot/domain/ufficcio_entitlement.dart`
- `lib/features/italy_admin_copilot/presentation/screens/catalog_screens.dart`
- `lib/features/italy_admin_copilot/presentation/screens/life_admin_screens.dart`
- `pubspec.lock`
- `pubspec.yaml`
- `supabase/config.toml`
- `supabase/functions/create-checkout-session/index.ts`
- `supabase/functions/stripe-webhook/index.ts`
- `supabase/migrations/20260512103000_fix_cms_category_aware_blocks_and_upsert.sql`
- `supabase/migrations/20260512113000_harden_premium_server_truth.sql`
- `test/service_intelligence_premium_test.dart`
- `tool/localization_doctor.dart`
