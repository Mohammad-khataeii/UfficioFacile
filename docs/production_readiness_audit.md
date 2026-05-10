# Production Readiness Audit

Last updated: 2026-05-10

## Architecture Summary

- Flutter client runtime lives under `lib/` with startup/config in `lib/app`, product flows in `lib/features/italy_admin_copilot`, and local persistence via `SharedPreferences`.
- Next.js admin lives under `apps/admin` and reads CMS/auth/premium data from Supabase.
- Supabase schema and policies live in `supabase/migrations`.
- Bundled CMS content source of truth lives in `lib/features/italy_admin_copilot/content/categories` and `lib/features/italy_admin_copilot/content/category_registry.dart`.
- Generated CMS exports are written to:
  - `docs/generated/cms_bundled_content_export.json`
  - `apps/admin/data/cms_bundled_content_export.json`
- Canonical Flutter bundled catalog is `assets/catalog/ufficio_catalog.v1.json`.

## Audit Findings

### Flutter startup/config/auth/catalog/premium risks

- Startup previously allowed `supabase` backend builds to degrade into local-only mode when credentials were missing.
- Production bootstrap previously kept offering local fallback UI even for broken Supabase builds.
- Startup diagnostics were too sparse to quickly separate bad config from transient runtime failure.
- Localization fallback logic is sane (`selected -> en -> it -> first available -> fallback`), but there was no dedicated doctor script for missing locale keys or likely raw-key leaks.
- Premium flow still needs a deeper server-authority audit: `MergedUfficcioEntitlementRepository` merges remote state into local cache, but broader enforcement, webhook idempotency, and admin visibility were not fully reworked in this pass.

### Admin auth/RBAC/content risks

- Procedure identity previously preferred database `id` over `category_slug + slug`, which could preserve duplicate public routes and duplicate React keys.
- Legacy slug-only route lookup (`/content/procedures/[slug]`) previously redirected to the first match, even when ambiguous.
- Admin Supabase middleware and browser/server factories previously accepted empty env vars and silently created bad clients.
- Service-role boundaries were implicit rather than clearly marked with `server-only`.
- RBAC definitions exist in `apps/admin/lib/auth/permissions.ts`; this pass audited them, but did not comprehensively re-check every page action beyond the content and env paths touched here.

### Supabase/RLS/migration risks

- CMS procedure public identity was not enforced at the database level by `category_slug + slug`.
- Existing schema still carries a global `slug` uniqueness assumption through `ufficio_cms_content_blocks.procedure_slug`; that prevents a safe drop of legacy slug-only uniqueness without a broader block-schema migration.
- This pass added a migration to archive duplicate active public identities and add a partial unique index on active `(category_slug, slug)` rows.
- A full table-by-table RLS re-audit is still deferred and should land in a dedicated follow-up.

### Content pipeline risks

- Generated exports existed and were non-empty at audit time:
  - `docs/generated/cms_bundled_content_export.json`: 8,047,321 bytes
  - `apps/admin/data/cms_bundled_content_export.json`: 8,047,321 bytes
  - `assets/catalog/ufficio_catalog.v1.json`: 830,684 bytes
- `tool/content_doctor.dart` and `apps/admin/scripts/content-lint.mjs` already checked translations and forbidden phrases, but were missing stronger duplicate-route/public-identity checks.
- This pass strengthened both tools with duplicate category, duplicate procedure identity, duplicate route, missing slug, and empty export checks.

## Commands Run

From repo root:

- `git status --short`
- `find . -maxdepth 3 -type f | sort`
- `rg -n "Ufficcio|ufficcio|/ufficcio|getProcedureCanonicalKey|getProcedureRoutePath|getAdminProcedureBySlug|procedure\.slug|category_slug|subcategory_slug|Math\.random|Date\.now|key=\{|SUPABASE_SERVICE_ROLE_KEY|NEXT_PUBLIC_SUPABASE|UFFICCIOFACILE_BACKEND_MODE|UFFICIOFACILE_ENABLE_PAYWALL|UFFICIOFACILE_ENABLE_BETA_MODE|allowLocalDebugPro|localDebugPro|beta access active|demo data|do not show|internal note|for codex|to help the user|the user should" .`
- `sed -n ...` on the inspected admin, Flutter, migration, and tooling files used during this audit
- `wc -c docs/generated/cms_bundled_content_export.json apps/admin/data/cms_bundled_content_export.json assets/catalog/ufficio_catalog.v1.json`
- `dart format lib test tool`

Verification results:

- `flutter analyze`
  Result: passed, no issues found.
- `flutter test`
  Result: passed, `All tests passed!`
- `/usr/local/share/flutter/bin/dart run tool/export_cms_seed.dart`
  Result: passed, rewrote both generated CMS export files.
- `/usr/local/share/flutter/bin/dart run tool/content_doctor.dart`
  Result: passed after export/check updates.
- `/usr/local/share/flutter/bin/dart run tool/localization_doctor.dart`
  Result: failed. Current app still has substantial missing locale keys and hardcoded UI text across startup/auth/life-admin screens.
- `cd apps/admin && npm install`
  Result: passed; repo already up to date, `2 moderate severity vulnerabilities` reported by npm audit.
- `cd apps/admin && rm -rf .next`
  Result: passed.
- `cd apps/admin && npm run lint`
  Result: passed.
- `cd apps/admin && npm run content:lint`
  Result: passed after aligning lint rules with canonical export structure.
- `cd apps/admin && npm run build`
  Result: passed.
- `supabase migration list`
  Result: failed because `SUPABASE_ACCESS_TOKEN` was not configured locally.
- `supabase db push --dry-run`
  Result: failed because `SUPABASE_ACCESS_TOKEN` was not configured locally.

## Manual SQL Check For Procedure Duplicates

```sql
select category_slug, slug, count(*)
from public.ufficio_cms_procedures
group by category_slug, slug
having count(*) > 1
order by count desc, category_slug, slug;
```

## Files Changed By This Task

- `apps/admin/app/content/procedures/[slug]/page.tsx`
- `apps/admin/app/content/procedures/[categorySlug]/[procedureSlug]/page.tsx`
- `apps/admin/lib/content/load-content-tree.ts`
- `apps/admin/lib/db/mutations.ts`
- `apps/admin/lib/env.ts`
- `apps/admin/lib/supabase/server.ts`
- `apps/admin/lib/supabase/middleware.ts`
- `apps/admin/lib/supabase/client.ts`
- `apps/admin/lib/auth/require-admin.ts`
- `apps/admin/lib/db/queries.ts`
- `apps/admin/scripts/content-lint.mjs`
- `docs/production_readiness_audit.md`
- `lib/app/app_config.dart`
- `lib/app/app_startup.dart`
- `lib/app/app_startup_widgets.dart`
- `lib/main.dart`
- `lib/features/italy_admin_copilot/application/italy_admin_copilot_controller.dart`
- `supabase/migrations/20260510120000_harden_cms_procedure_identity.sql`
- `test/startup_test.dart`
- `tool/content_doctor.dart`
- `tool/localization_doctor.dart`

## Deferred Issues

- Full premium/Stripe/server-backed entitlement hardening is not complete in this pass.
- Flutter search/runtime unification across bundled and Supabase CMS content is not complete in this pass.
- The `Ufficcio`/`Ufficio` typo debt audit was started via search, but a compatibility migration/redirect sweep is still incomplete.
- Full Supabase RLS audit docs (`docs/supabase_security_audit.md`) are still pending.
- `ufficio_cms_content_blocks` still references `procedure_slug` alone, so a deeper schema migration is required before removing any legacy global slug assumptions entirely.
