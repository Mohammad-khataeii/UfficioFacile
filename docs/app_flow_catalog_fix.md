# App Flow And Catalog Fix

## What was broken

- New unauthenticated users could land directly on the dashboard instead of a clear onboarding and auth flow.
- The app had no obvious logout action in the main authenticated experience.
- Dashboard category badges were unstable because the home screen mixed deferred CMS data, fallback content, and entitlement state.
- Category, subcategory, and procedure navigation had drifted across older procedure routes and newer CMS routes.
- Detail pages could show the wrong content shape because the app no longer had one canonical app-facing catalog structure.

## Files changed

- `/Users/mohammadkhataei/Desktop/UfficioFacile/lib/app/app.dart`
- `/Users/mohammadkhataei/Desktop/UfficioFacile/lib/app/app_routes.dart`
- `/Users/mohammadkhataei/Desktop/UfficioFacile/lib/app/app_startup.dart`
- `/Users/mohammadkhataei/Desktop/UfficioFacile/lib/app/app_scope.dart`
- `/Users/mohammadkhataei/Desktop/UfficioFacile/lib/app/app_localizations.dart`
- `/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/auth/presentation/auth_screen.dart`
- `/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/auth/presentation/account_screen.dart`
- `/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/data/local_onboarding_repository.dart`
- `/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/data/premium_service.dart`
- `/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/data/catalog_premium_marker.dart`
- `/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/data/ufficio_catalog_repository.dart`
- `/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/domain/ufficio_catalog.dart`
- `/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/content/ufficio_catalog_exporter.dart`
- `/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/presentation/screens/catalog_screens.dart`
- `/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/presentation/screens/life_admin_screens.dart`
- `/Users/mohammadkhataei/Desktop/UfficioFacile/tool/export_cms_seed.dart`
- `/Users/mohammadkhataei/Desktop/UfficioFacile/test/startup_test.dart`
- `/Users/mohammadkhataei/Desktop/UfficioFacile/test/ufficio_catalog_test.dart`

## New app flow

- First launch with no session and onboarding not seen:
  - `/life-admin/onboarding`
  - then `/life-admin/auth`
  - then `/life-admin/dashboard`
- Returning signed-out user with onboarding already seen:
  - `/life-admin/auth`
- Returning authenticated user:
  - `/life-admin/dashboard`

The onboarding completion flag is stored in SharedPreferences with:

- `ufficio_onboarding_seen`

Legacy onboarding storage is still read for compatibility.

## New catalog and content structure

The app now has one app-facing catalog model:

- `UfficioCatalog`
- `UfficioCategory`
- `UfficioSubcategory`
- `UfficioProcedure`
- `UfficioContentSection`
- `UfficioOfficialLink`
- `UfficioContact`

Bundled runtime content is exported into:

- `/Users/mohammadkhataei/Desktop/UfficioFacile/assets/catalog/ufficio_catalog.v1.json`

The bundled JSON is versioned and meant to stay human-editable. The structure is:

- Catalog
  - categories
    - subcategories
      - procedures
        - sections
        - official links
        - contacts
        - warnings
        - premium teaser

The runtime repository is:

- `/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/data/ufficio_catalog_repository.dart`

It loads bundled catalog data first, then overlays remote CMS category and procedure updates when Supabase responds in time.

## How premium badges are decided now

Dashboard badges are now catalog-driven, not entitlement-driven.

The helper is:

- `/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/data/catalog_premium_marker.dart`

Rules:

- Show badge if `category.isPremiumOnly`
- Or `category.hasPremiumContent`
- Or any child subcategory or procedure is premium

The badge means premium content exists in that category.

User entitlement decides whether locked sections can be opened, but it no longer decides whether the dashboard badge exists.

## How to add or edit a category later

1. Edit the category seed files in:
   - `/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/content/categories`
2. Regenerate bundled content:
   - `/usr/local/share/flutter/bin/dart run tool/export_cms_seed.dart`
3. This updates:
   - `/Users/mohammadkhataei/Desktop/UfficioFacile/docs/generated/cms_bundled_content_export.json`
   - `/Users/mohammadkhataei/Desktop/UfficioFacile/apps/admin/data/cms_bundled_content_export.json`
   - `/Users/mohammadkhataei/Desktop/UfficioFacile/assets/catalog/ufficio_catalog.v1.json`

For a procedure, keep content structured:

- shortDescription
- sections
- officialLinks
- contacts
- warnings
- premiumTeaser when needed

## Manual test checklist

Fresh app state:

1. Clear local storage or reinstall.
2. Open the app.
3. Confirm onboarding appears first.
4. Tap Next or Skip.
5. Confirm auth screen opens.
6. Log in or create an account.
7. Confirm the app lands on the dashboard.

Authenticated flow:

1. Relaunch with an active session.
2. Confirm the app opens directly on the dashboard.

Logout:

1. Open the dashboard overflow menu or profile screen.
2. Tap Log out.
3. Confirm the snackbar appears.
4. Confirm the app returns to auth.

Catalog:

1. Open the dashboard.
2. Confirm categories render with stable premium badges.
3. Open a category.
4. Confirm subcategories render.
5. Open a subcategory.
6. Confirm procedures render.
7. Open a procedure.
8. Confirm structured sections, links, contacts, and warnings render.

Premium gating:

1. Open a premium procedure while signed out or on a free plan.
2. Confirm title, summary, and locked CTA render.
3. Open the same procedure with premium entitlement.
4. Confirm premium sections are visible.
