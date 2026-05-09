# Catalog Rendering Fix

## Root cause

The app had two separate problems at the same time:

1. The canonical bundled asset existed in source but was not treated as a hard production requirement, so legacy fallback content could still mask missing or stale builds.
2. The canonical catalog generator was grouping many legacy procedures by raw procedure slug, which created one-procedure-per-subcategory pages and exposed internal routing-style text in user-facing screens.

That combination made production look “alive” while actually rendering the wrong catalog structure.

## Asset declaration fix

Flutter only bundles files that are declared in `pubspec.yaml`.

The app now declares the catalog folder directly:

```yaml
flutter:
  assets:
    - assets/catalog/
```

This is safer than declaring a single file path because future versioned catalog files will also be included.

## How Flutter bundles the catalog

At build time, Flutter copies declared assets into the web output and records them in:

- `build/web/assets/AssetManifest.json`

The catalog file must appear there as:

- `assets/catalog/ufficio_catalog.v1.json`

The actual built file must exist at:

- `build/web/assets/assets/catalog/ufficio_catalog.v1.json`

The double `assets/` is normal in Flutter web output.

## Why legacy fallback was masking the bug

The app previously tried the canonical catalog and silently fell back to legacy bundled CMS exports when the asset was missing. That meant users could still navigate the app, but they saw flattened “one procedure = one subcategory” screens instead of the intended grouped catalog.

The runtime behavior is now:

- debug/dev:
  - legacy fallback is allowed for diagnosis
  - a loud debug warning is printed
- release/production:
  - legacy fallback is disabled by default
  - if the canonical asset is missing, the UI shows a clear catalog error state

The release build can explicitly enforce this with:

- `UFFICCIOFACILE_ALLOW_LEGACY_CATALOG_FALLBACK=false`

## Canonical category grouping

The canonical exporter now groups procedures into meaningful subcategories instead of deriving one top-level card from every raw procedure slug.

Example for `health_asl`:

- `ssn_asl_access`
- `doctor_health_card`
- `bookings_prescriptions_cup`
- `ticket_exemptions`
- `digital_health_record`
- `asl_problems`
- `student_insurance`

This same grouping rule now applies across the other categories too.

## How to add new catalog content safely

1. Update the category seed files under:
   - `lib/features/italy_admin_copilot/content/categories/`
2. If a new procedure belongs inside an existing subcategory group, update:
   - `lib/features/italy_admin_copilot/content/ufficio_catalog_exporter.dart`
3. Regenerate:

```bash
/usr/local/share/flutter/bin/dart run tool/export_cms_seed.dart
```

4. Validate:

```bash
/usr/local/share/flutter/bin/dart run tool/validate_catalog.dart
flutter test
flutter build web --release
```

## How to verify AssetManifest

After a release build:

```bash
cat build/web/assets/AssetManifest.json
```

Check that it contains:

- `assets/catalog/ufficio_catalog.v1.json`

Then verify the file exists:

```bash
ls -l build/web/assets/assets/catalog/ufficio_catalog.v1.json
```

## How to test deployed web

1. Run:

```bash
flutter clean
flutter pub get
/usr/local/share/flutter/bin/dart run tool/export_cms_seed.dart
/usr/local/share/flutter/bin/dart run tool/validate_catalog.dart
flutter build web --release
```

2. Serve locally from `build/web`.
3. Open browser dev tools.
4. Confirm there is no error for:
   - `assets/catalog/ufficio_catalog.v1.json`
5. Open Health / ASL and verify it shows grouped subcategories rather than resident-status cards.
