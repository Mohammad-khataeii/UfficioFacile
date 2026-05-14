# Production Readiness Audit

Last updated: 2026-05-14

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
