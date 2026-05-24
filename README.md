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
flutter pub get
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
npm audit
npm run build
npm run lint
npm run content:lint
```

Supabase verification in a linked environment:

```bash
supabase migration list
supabase db push --dry-run
supabase functions deploy delete-account
```

## Android Google Play internal testing build

```bash
/usr/local/share/flutter/bin/flutter build appbundle \
  --release \
  --dart-define=UFFICCIOFACILE_FLAVOR=production \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=... \
  --dart-define=UFFICCIOFACILE_ENABLE_PAYWALL=true \
  --dart-define=UFFICCIOFACILE_ENABLE_BETA_MODE=false
```

If production ads are enabled, also pass:

```bash
  --dart-define=UFFICIOFACILE_ADMOB_APP_ID_ANDROID=ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy \
  --dart-define=UFFICIOFACILE_ADMOB_BANNER_ANDROID=ca-app-pub-xxxxxxxxxxxxxxxx/zzzzzzzzzz \
  --dart-define=UFFICIOFACILE_ADMOB_INTERSTITIAL_ANDROID=ca-app-pub-xxxxxxxxxxxxxxxx/aaaaaaaaaa
```

If you are not ready to launch ads, leave those AdMob defines unset. Production builds now disable ads instead of falling back to Google test IDs.

Before building a signed bundle:

1. Create a local `android/key.properties` from `android/key.properties.example`, or export:
   - `ANDROID_KEYSTORE_PATH`
   - `ANDROID_KEYSTORE_PASSWORD`
   - `ANDROID_KEY_ALIAS`
   - `ANDROID_KEY_PASSWORD`
2. Generate the upload key locally and keep it out of git:

```bash
keytool -genkeypair \
  -v \
  -keystore /absolute/path/to/upload-keystore.jks \
  -alias upload \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000
```

3. Run the release doctor:

```bash
/usr/local/share/flutter/bin/dart run tool/google_play_release_doctor.dart
```

4. Optionally print the Android release config:

```bash
cd android && ./gradlew printAndroidReleaseInfo && cd ..
```

5. Build the `.aab`:

```bash
/usr/local/share/flutter/bin/flutter build appbundle \
  --release \
  --dart-define=UFFICCIOFACILE_FLAVOR=production \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=... \
  --dart-define=UFFICCIOFACILE_ENABLE_PAYWALL=true \
  --dart-define=UFFICCIOFACILE_ENABLE_BETA_MODE=false
```

You must increment `versionCode` on every Play Console upload. In Flutter, `versionName` is the part before `+` in `pubspec.yaml`, and `versionCode` is the number after `+`.

## iOS TestFlight / App Store build

```bash
/usr/local/share/flutter/bin/flutter build ipa \
  --release \
  --dart-define=UFFICCIOFACILE_FLAVOR=production \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=... \
  --dart-define=UFFICCIOFACILE_ENABLE_PAYWALL=true \
  --dart-define=UFFICCIOFACILE_ENABLE_BETA_MODE=false
```

If iOS ads are enabled, create a local untracked
`ios/Flutter/AdMob.local.xcconfig` with:

```xcconfig
ADMOB_APPLICATION_ID_IOS=ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy
```

Then run the iOS release doctor:

```bash
/usr/local/share/flutter/bin/dart run tool/apple_release_doctor.dart
```

## Before upload run this

```bash
dart format lib test tool
flutter pub get
flutter analyze
flutter test
dart run tool/content_doctor.dart
dart run tool/localization_doctor.dart
dart run tool/google_play_release_doctor.dart
dart run tool/print_google_play_commands.dart
/usr/local/share/flutter/bin/dart run tool/apple_release_doctor.dart
cd android && ./gradlew printAndroidReleaseInfo && cd ..
/usr/local/share/flutter/bin/flutter build appbundle \
  --release \
  --dart-define=UFFICCIOFACILE_FLAVOR=production \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=... \
  --dart-define=UFFICCIOFACILE_ENABLE_PAYWALL=true \
  --dart-define=UFFICCIOFACILE_ENABLE_BETA_MODE=false
```

## Flutter web production build

```bash
/usr/local/share/flutter/bin/flutter build web \
  --release \
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
See `docs/production_readiness_audit.md` for the current audit status.
See `docs/supabase_security_audit.md` for the current RLS/security summary.
See `docs/play_store/google_play_release_checklist.md` for the Android release gate.
See `docs/play_store/privacy_policy_draft.md` for the privacy draft.
See `docs/play_store/data_safety_draft.md` for the Play Data Safety draft.
See `docs/play_store/local_signing_step_by_step.md` for local signing setup.
See `docs/play_store/reviewer_instructions.md` for App Access prep.
See `docs/play_store/store_listing_draft.md` for store listing copy.
See `docs/play_store/account_deletion.md` for the deletion path.
See `docs/privacy/account_deletion_data_map.md` for the backend deletion scope.
See `docs/play_store/android_permissions.md` for the Android permission audit.
See `docs/play_store/play_console_copy.md` for Play Console copy-paste text.
See `docs/play_store/final_submission_checklist.md` for the final submission checklist.
See `docs/app_store/ios_release_checklist.md` for the iOS/TestFlight checklist.
Public privacy URL: [https://ufficio-facile.vercel.app/privacy](https://ufficio-facile.vercel.app/privacy)
Public account deletion URL: [https://ufficio-facile.vercel.app/account-deletion](https://ufficio-facile.vercel.app/account-deletion)

If the Next.js dev cache is corrupted and `.next/routes-manifest.json` is
missing:

```bash
cd apps/admin
rm -rf .next
npm run dev
```
