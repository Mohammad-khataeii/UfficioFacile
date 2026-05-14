# City Catalog Architecture

- `assets/catalog/ufficio_catalog.v1.json` is the legacy Torino catalog.
- Preferred future city files live beside it:
  - `assets/catalog/ufficio_catalog.torino.v1.json`
  - `assets/catalog/ufficio_catalog.milano.v1.json`
  - `assets/catalog/ufficio_catalog.roma.v1.json`
  - `assets/catalog/ufficio_catalog.bologna.v1.json`

## Resolution rules

- `torino`
  1. `assets/catalog/ufficio_catalog.torino.v1.json`
  2. `assets/catalog/ufficio_catalog.v1.json`
- `milano`
  1. `assets/catalog/ufficio_catalog.milano.v1.json`
  2. no fallback to Torino
- any future city
  1. `assets/catalog/ufficio_catalog.<city_slug>.v1.json`
  2. no fallback to Torino

If a non-Torino city file is missing, the app shows a clear unavailable state and a city-request CTA instead of loading Torino data.

## Current behavior

- Existing users default to `torino` to preserve the current app behavior.
- City selection is persisted locally in the profile payload as `selectedCityPackId`.
- Supabase profile sync does not yet have a dedicated catalog-city column, so city selection is currently local-first by design.

## How to add a new city

1. Add the city slug and label to `lib/features/italy_admin_copilot/data/ufficio_city_registry.dart`
2. Add `assets/catalog/ufficio_catalog.<city_slug>.v1.json`
3. Rebuild the app
4. Run:
   - `flutter test`
   - `dart run tool/content_doctor.dart`

No other code change is required for the bundled catalog loader.

## Validation

- `tool/content_doctor.dart` accepts `ufficio_catalog.v1.json` as the legacy Torino catalog.
- Any present `ufficio_catalog.<city_slug>.v1.json` file is parsed and validated as a catalog JSON object.
