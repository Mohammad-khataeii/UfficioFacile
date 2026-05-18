## UfficioFacile investigation note — 2026-05-14

### Stale or placeholder-heavy areas

- `lib/features/italy_admin_copilot/presentation/screens/life_admin_phase5_screens.dart`
  - `ScanMySituationScreen` uses hardcoded keyword detection and example text.
  - `ItalyLifeChecklistScreen` uses static checklist templates from `ItalyLifeChecklistService`.
  - `DeadlineWatchScreen` creates a fake `Canone RAI reminder` with the add button.
  - `ProofFolderScreen` creates placeholder proof cases.
  - `CostSavingDashboardScreen` depends on generic local cost items and old summaries.
- `lib/features/italy_admin_copilot/data/life_admin_phase5_services.dart`
  - `ItalyLifeChecklistService` is static and disconnected from the catalog.
  - `SituationScannerService` is static keyword matching and returns fake fallback procedures.
  - `CostInsightService` uses heuristics on local contracts, not real procedure cost data.
  - `CityPackService` is partly static and not the real catalog source of truth.
- `lib/features/italy_admin_copilot/application/procedure_controller.dart`
  - Still searches `procedure_definitions.dart` legacy procedures instead of the current catalog.
- `lib/features/italy_admin_copilot/presentation/screens/life_admin_screens.dart`
  - `ProblemIntakeScreen` still relies on `IntelligentProblemRouter` over CMS categories/procedures only.
  - `ProcedureSelectionScreen` still falls back to `ProcedureController` legacy procedures.
- `lib/features/italy_admin_copilot/domain/admin_copilot_profile.dart`
  - Profile model is old and centered on broad personal form fields, not the practical product folder structure.

### Disconnected from current catalog data

- `ProcedureSelectionScreen` mixes the new bundled catalog route with the old `ProcedureController` fallback.
- `ProblemIntakeScreen` and home search depend on `IntelligentProblemRouter`, which reads CMS categories/procedures but not the normalized bundled city catalog structure.
- `ScanMySituationScreen`, checklist, deadlines, proof folder, and costs do not resolve from the current category/subcategory/procedure catalog.
- `HybridCatalogRepository` / `CatalogRepository` public catalog and `UfficioCatalogRepository` bundled/CMS catalog are parallel systems with different models and search paths.

### Hardcoded or fake/random placeholder data

- Static checklist items in `ItalyLifeChecklistService`.
- Static scan suggestions in `SituationScannerService`.
- Static “Canone RAI reminder” add flow in `DeadlineWatchScreen`.
- Placeholder proof case creation in `ProofFolderScreen`.
- Cost insights based on broad heuristics in `CostInsightService`.
- Old legacy procedures in `procedure_definitions.dart` and `ProcedureController`.

### Old category/procedure model drift

- `UfficioCatalogRepository` uses `UfficioCatalog`, but the parser currently drops some richer catalog fields like category-level contacts/official links that exist in the asset.
- Remote CMS subcategories are not treated as first-class records even though `CmsCategory` already supports `parentSlug`.
- Admin normalized catalog queries derive subcategories from procedure groups instead of a stable subcategory source.
- Premium gating is spread across booleans and monetization fields:
  - `is_premium`
  - `monetization_type`
  - derived `premiumVisibility`
  - ad hoc metadata reads

### Replace / merge / rebuild

- Replace route-level production use of:
  - `ProcedureController`
  - `ItalyLifeChecklistService`
  - `SituationScannerService`
  - `DeadlineWatchScreen`
  - `ProofFolderScreen`
  - `CostSavingDashboardScreen`
- Keep old flows only as implementation fallback or dev-only utilities, not production UX.
- Rebuild around:
  - one normalized catalog resolver
  - one normalized search index
  - one location context
  - one user-product data layer for scans, checklist, deadlines, saved procedures, and costs

### DB / schema changes likely required

- Add user tables:
  - `public.ufficio_situation_scans`
  - `public.ufficio_checklist_items`
  - `public.ufficio_deadlines`
  - `public.ufficio_saved_procedures`
- Extend `public.ufficio_cost_items` to support connected cost dashboard fields instead of the older minimal schema.
- Normalize CMS premium visibility with explicit columns such as:
  - `premium_visibility`
  - `required_plan`
- Use real CMS subcategory rows via `ufficio_cms_categories.parent_slug` instead of deriving everything from procedures only.
