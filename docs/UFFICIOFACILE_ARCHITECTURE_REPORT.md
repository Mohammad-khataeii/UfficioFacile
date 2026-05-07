# UfficioFacile Architecture Report

## 1. Executive Summary

UfficioFacile is a local-first Flutter app organized as a single feature module, `italy_admin_copilot`, wrapped by a small `app/` bootstrap layer. The current codebase is strongest in local storage flows, startup resilience, request generation, service-intelligence presentation, and premium gating. It is partially Supabase-ready through real migrations, repository scaffolding, sync status plumbing, and optional bootstrap logic, but the remote data model is still more auth-centric and less complete than the newer anonymous public-catalog product direction. The app supports Android, iOS, and web in the repo today; macOS support is not present as a folder. The current biggest deployment blockers are the incomplete public-catalog backend model, partial localization coverage outside the central localization map, no real auth UX, and no production-grade payment or remote admin path.

## 2. Repository Inventory

Root files:
- [pubspec.yaml](/Users/mohammadkhataei/Desktop/UfficioFacile/pubspec.yaml)
- [pubspec.lock](/Users/mohammadkhataei/Desktop/UfficioFacile/pubspec.lock)
- [analysis_options.yaml](/Users/mohammadkhataei/Desktop/UfficioFacile/analysis_options.yaml)
- [README.md](/Users/mohammadkhataei/Desktop/UfficioFacile/README.md)
- [lib/main.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/main.dart)

Major folders:
- `lib/`: Flutter app source
- `test/`: unit/widget tests
- `docs/`: schema, privacy, sync, premium, and architecture docs
- `android/`: Android host app
- `ios/`: iOS host app
- `web/`: web host assets and manifest
- `supabase/`: SQL migrations
- `build/`: generated build artifacts

High-level tree:

```text
UfficioFacile/
  android/
  docs/
  ios/
  lib/
    app/
    features/
      italy_admin_copilot/
        application/
        data/
        domain/
        presentation/screens/
  supabase/migrations/
  test/
  web/
```

Folder responsibilities:
- `lib/app`: bootstrap, routing, config, theme, localization shell, dependency injection
- `lib/features/italy_admin_copilot/application`: ChangeNotifier controllers
- `lib/features/italy_admin_copilot/domain`: app models and enums
- `lib/features/italy_admin_copilot/data`: repositories, generators, services, Supabase-ready scaffolding
- `lib/features/italy_admin_copilot/presentation/screens`: all UI screens and many reusable widgets
- `supabase/migrations`: actual SQL migrations for current remote schema

Platform folders:
- `android/` exists and built successfully in debug during prior verification
- `ios/` exists, but local iOS build is currently blocked by CocoaPods state
- `web/` exists and built successfully in debug during prior verification
- `macos/` does not exist in the current repo snapshot

Pubspec dependencies of note:
- `flutter_localizations`
- `intl`
- `shared_preferences`
- `share_plus`
- `supabase_flutter`
- `uuid`

## 3. App Startup and Bootstrap

Entrypoint:
- [lib/main.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/main.dart)

Startup sequence:

```text
main()
  -> WidgetsFlutterBinding.ensureInitialized()
  -> create UfficcioFacileConfig.fromEnv
  -> run _BootstrapApp
  -> load SharedPreferences with 3s timeout
  -> initialize Supabase if needed with 3s timeout
  -> build AppScope
  -> run LifeAdminApp
  -> app controller initialize()
  -> load onboarding/admin config/language
  -> route to loading / error / onboarding / home
```

Bootstrap details:
- `_BootstrapApp` owns the earliest startup state
- SharedPreferences is mandatory for local-first use
- Supabase is optional and wrapped in timeout/failure-safe logic
- if Supabase credentials are missing, the app still launches

Files:
- [lib/main.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/main.dart)
- [lib/app/supabase_bootstrap.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/app/supabase_bootstrap.dart)
- [lib/app/app_startup.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/app/app_startup.dart)
- [lib/app/app_startup_widgets.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/app/app_startup_widgets.dart)

Notable startup behavior:
- startup loading screen offers fallback after 5 seconds
- startup error screen offers retry, continue local-only, and reset startup data
- app can work without Supabase and without authentication

## 4. Configuration and Environment Variables

Primary config file:
- [lib/app/app_config.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/app/app_config.dart)

| Variable | Purpose | Required? | Example | Missing Behavior |
| --- | --- | --- | --- | --- |
| `UFFICCIOFACILE_BACKEND_MODE` | Backend mode select | Optional but recommended | `local` | Defaults to local. |
| `SUPABASE_URL` | Supabase project URL | Required for Supabase mode | `https://project.supabase.co` | Supabase disabled. |
| `SUPABASE_ANON_KEY` | Public anon key | Required for Supabase mode | `ey...` | Supabase disabled. |
| `UFFICCIOFACILE_ENABLE_SYNC` | Default sync-enabled flag | Optional | `true` | Defaults false. |
| `UFFICCIOFACILE_ENABLE_ADMIN_DEBUG` | Admin debug UI behaviors | Optional | `true` | Defaults false. |
| `UFFICCIOFACILE_ENABLE_BETA_MODE` | Premium beta access | Optional | `true` | Defaults true. |
| `UFFICCIOFACILE_ENABLE_PAYWALL` | Premium blocking | Optional | `false` | Defaults false. |
| `UFFICCIOFACILE_ENABLE_ANALYTICS` | Default analytics enabled | Optional | `true` | Defaults true. |
| `APP_BACKEND_MODE` | Legacy alias | Optional | `local` | Compatibility fallback only. |
| `GYMPAL_BACKEND_MODE` | Legacy alias | Optional | `local` | Compatibility fallback only. |

Important note:
- config class is named `UfficcioFacileConfig`
- the repo mixes `Ufficio` and `Ufficcio` spellings internally

## 5. Routing and Navigation

Routing pattern:
- `MaterialApp.onGenerateRoute`
- route constants in [lib/app/app_routes.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/app/app_routes.dart)
- entry decision via `_EntryRouter`

Unknown route behavior:
- falls back to `LifeAdminHomeScreen`

Route table:

| Route | Screen | Purpose | Params | Access |
| --- | --- | --- | --- | --- |
| `/life-admin` | `LifeAdminHomeScreen` | Home/dashboard | None | Public/local |
| `/life-admin/onboarding` | `OnboardingScreen` | First-run onboarding | None | Public/local |
| `/life-admin/start` | `ProblemIntakeScreen` | Problem-to-procedure entry | None | Public/local |
| `/life-admin/scan` | `ScanMySituationScreen` | Situation scan | None | Public/local |
| `/life-admin/city-packs` | `CityPacksScreen` | City guidance catalog | None | Public/local |
| `/life-admin/modes/student` | `ModeScreen` | Student checklist mode | None | Public/local |
| `/life-admin/modes/tenant` | `ModeScreen` | Tenant checklist mode | None | Public/local |
| `/life-admin/checklist` | `ItalyLifeChecklistScreen` | Checklist | None | Public/local |
| `/life-admin/attachments-helper` | `AttachmentHelperScreen` | Attachment planning | None | Public/local |
| `/life-admin/household` | `HouseholdScreen` | Household/contracts | None | Premium-gated in actions |
| `/life-admin/consultant` | `ConsultantModePreviewScreen` | Consultant teaser | None | Premium/coming soon |
| `/life-admin/deadlines` | `DeadlineWatchScreen` | Deadlines | None | Public/local |
| `/life-admin/templates` | `TemplateLibraryScreen` | Template library | None | Public/local |
| `/life-admin/proof-folder` | `ProofFolderScreen` | Proof cases | None | Premium-gated in actions |
| `/life-admin/costs` | `CostSavingDashboardScreen` | Cost dashboard | None | Premium-gated in actions |
| `/life-admin/official-links` | `OfficialLinksDirectoryScreen` | Official links directory | None | Public/local |
| `/life-admin/document-vault` | `DocumentVaultScreen` | Document metadata | None | Premium-gated in actions |
| `/life-admin/contacts` | `ContactsDirectoryScreen` | Contacts | None | Public/local |
| `/life-admin/calendar` | `LifeAdminCalendarScreen` | Calendar | None | Public/local |
| `/life-admin/procedures` | `ProcedureSelectionScreen` | Procedure list | None | Public/local |
| `/life-admin/procedure-detail` | `ProcedureDetailScreen` | Procedure guide | `ProcedureRouteArgs` | Public/local |
| `/life-admin/procedure-start` | `GuidedFormScreen` | Procedure form | `ProcedureRouteArgs` | Public/local |
| `/life-admin/generated` | `GeneratedPackScreen` | Generated output | `GeneratedRouteArgs` | Public/local |
| `/life-admin/requests` | `SavedRequestsScreen` | Saved requests | None | Public/local |
| `/life-admin/request-detail` | `RequestDetailScreen` | Request detail | `RequestRouteArgs` | Public/local |
| `/life-admin/plan` | `PlanScreen` | Plan/premium page | None | Public/local |
| `/life-admin/terms` | `TermExplanationScreen` | Term explanation | `TermRouteArgs` | Public/local |
| `/life-admin/profile` | `ProfileScreen` | Profile | None | Public/local |
| `/ufficcio/privacy` | `PrivacyCenterScreen` | Privacy/export/delete | None | Public/local |
| `/ufficcio/sync` | `SyncSettingsScreen` | Sync UI | None | Public/local |
| `/life-admin/help` | `HelpScreen` | Help | None | Public/local |
| `/life-admin/utilities` | `UtilityHubScreen` | Utilities hub | None | Public/local |
| `/life-admin/utilities/compare` | `UtilityComparisonScreen` | Utility comparison | None | Premium-gated |
| `/life-admin/utilities/bill-analyzer` | `BillAnalyzerChecklistScreen` | Bill analysis | None | Premium-gated |
| `/life-admin/canone-rai` | `CanoneRaiHubScreen` | Canone RAI hub | None | Public/local |
| `/life-admin/canone-rai/guide` | `CanoneRaiDecisionFlowScreen` | Canone guide flow | None | Premium-gated |
| `/life-admin/telecom` | `TelecomHubScreen` | Telecom hub | None | Public/local |
| `/life-admin/admin` | `AdminPanelScreen` | Admin UI | None | Local/debug practical |
| `/life-admin/admin/premium` | `AdminPremiumScreen` | Premium config debug | None | Local/debug practical |

## 6. Frontend/UI Architecture

Main UI files:
- [lib/features/italy_admin_copilot/presentation/screens/life_admin_screens.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/presentation/screens/life_admin_screens.dart)
- [lib/features/italy_admin_copilot/presentation/screens/life_admin_phase5_screens.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/presentation/screens/life_admin_phase5_screens.dart)
- [lib/features/italy_admin_copilot/presentation/screens/life_admin_supabase_screens.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/presentation/screens/life_admin_supabase_screens.dart)

Theme:
- [lib/app/app_theme.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/app/app_theme.dart)
- Material 3 with a teal seed color
- rounded cards and inputs
- light/dark themes

UI structure observations:
- most UI is screen-centric rather than deeply componentized
- `life_admin_screens.dart` is very large and contains both screens and reusable widgets
- mobile behavior is primary
- web/desktop works, but there is limited dedicated desktop layout specialization

Major screen maturity:

Home/dashboard:
- file: `life_admin_screens.dart`
- purpose: entry hub, quick links, usage banner, premium awareness
- maturity: solid but string coverage is mixed

Onboarding:
- file: `life_admin_screens.dart`
- purpose: simple first-run intro
- maturity: functional

Problem intake:
- file: `life_admin_screens.dart`
- purpose: start from problem statement
- maturity: functional

Procedure list/detail:
- file: `life_admin_screens.dart`
- purpose: browse procedures and see service guidance
- maturity: improved with service intelligence, but still partly local-definition driven

Guided form:
- file: `life_admin_screens.dart`
- purpose: collect request inputs and submission details
- maturity: functional, dynamic fields, limited deep per-channel validation

Generated pack:
- file: `life_admin_screens.dart`
- purpose: show email/PEC/follow-up/checklists
- maturity: good for local generation, no server generation pipeline

Saved requests/detail:
- file: `life_admin_screens.dart`
- purpose: local request management
- maturity: functional

Utilities/bills:
- file: `life_admin_screens.dart`
- purpose: compare offers / analyze bills / canone rai
- maturity: useful but still partly generalized

Documents/proof:
- file: `life_admin_phase5_screens.dart`
- purpose: local metadata and proof organization
- maturity: functional, local-first

Profile/settings/privacy:
- files: `life_admin_screens.dart`, `life_admin_supabase_screens.dart`
- maturity: functional, local-first, sync-aware

Premium/paywall:
- file: `life_admin_screens.dart`
- maturity: real logic exists; payment backend absent

Admin:
- file: `life_admin_screens.dart`
- maturity: local/debug utility panel, not a secure production admin console

## 7. State Management

Pattern:
- `InheritedWidget` for app-level scope via `AppScope`
- `ChangeNotifier` controllers
- local state inside stateful screens

Controllers:

| File | Controller | Responsibility | Dependencies | Risks |
| --- | --- | --- | --- | --- |
| [italy_admin_copilot_controller.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/application/italy_admin_copilot_controller.dart) | `ItalyAdminCopilotController` | Startup, onboarding, language, admin config | onboarding/admin config/language repos | Central but small; okay |
| [procedure_controller.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/application/procedure_controller.dart) | `ProcedureController` | Search/recommend procedures | local definitions | No async caching needed |
| [profile_controller.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/application/profile_controller.dart) | `ProfileController` | Load/save profile | profile repo | Simple |
| [request_controller.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/application/request_controller.dart) | `RequestController` | Save requests, reminders, drafts | request repo, draft repo, analytics | No remote conflict handling in normal UI |
| [utility_controller.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/application/utility_controller.dart) | `UtilityController` | Utility compare / bill analysis / canone flow | utility services | Mostly local calculators |
| [admin_controller.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/application/admin_controller.dart) | `AdminController` | Overrides, events, demo data, quality checks | template repo, analytics, request/profile controllers | Debug-heavy, not secure admin |

## 8. Domain Models

The domain layer is broad and local-JSON friendly. Most models implement `toJson`/`fromJson` and are stored in SharedPreferences-backed JSON blobs or lists.

Key models:
- [admin_procedure.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/domain/admin_procedure.dart): procedure catalog entries
- [procedure_field.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/domain/procedure_field.dart): dynamic form fields
- [admin_request.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/domain/admin_request.dart): saved request aggregate
- [generated_pack.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/domain/generated_pack.dart): generated output package
- [admin_copilot_profile.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/domain/admin_copilot_profile.dart): profile
- [reminder.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/domain/reminder.dart): reminders
- [life_admin_document.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/domain/life_admin_document.dart): document metadata
- [life_admin_contact.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/domain/life_admin_contact.dart): contacts
- [household_member.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/domain/household_member.dart): household members
- [household_contract.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/domain/household_contract.dart): contracts
- [utility_offer.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/domain/utility_offer.dart): utility offers
- [utility_comparison.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/domain/utility_comparison.dart): comparison input/output
- [bill_analysis.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/domain/bill_analysis.dart): bill analysis
- [canone_rai_models.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/domain/canone_rai_models.dart): canone flow
- [proof_folder.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/domain/proof_folder.dart): proof cases/items
- [city_pack.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/domain/city_pack.dart): city guidance bundles
- [official_link.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/domain/official_link.dart): official link entries
- [service_intelligence.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/domain/service_intelligence.dart): service intelligence layer
- [premium_config.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/domain/premium_config.dart): premium config
- [ufficcio_entitlement.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/domain/ufficcio_entitlement.dart): plan/usage/entitlement
- [sync_models.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/domain/sync_models.dart): sync status/log structs
- [usage_event.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/domain/usage_event.dart): analytics events
- [ufficcio_feedback.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/domain/ufficcio_feedback.dart): feedback

Relationship summary:

```text
Profile
  -> Requests
    -> GeneratedPack
    -> Reminders
  -> Documents
  -> Contacts
  -> HouseholdMembers
  -> HouseholdContracts
  -> ProofCases / ProofItems
  -> UsageEvents
  -> Entitlement / Settings
```

## 9. Procedure and Template System

Procedure definitions live in:
- [lib/features/italy_admin_copilot/data/procedure_definitions.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/data/procedure_definitions.dart)

Procedure count:
- 35 major procedure definitions in the current static catalog

Characteristics:
- static list of `AdminProcedure`
- category, title, short description, tags, fields, suggested attachments
- premium flags via `kPremiumProcedureIds`

Adding a new procedure currently requires editing:
1. `procedure_definitions.dart`
2. possibly a generator in `data/generators/`
3. service intelligence definitions
4. optional premium config defaults
5. UI/tests if special routing is needed

## 10. Generated Pack Engine

Entry point:
- [lib/features/italy_admin_copilot/data/pack_generator.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/data/pack_generator.dart)

Generation flow:

```text
Guided form input
  -> PackGenerator.generate()
  -> procedure-specific generator or standard fallback
  -> service intelligence enrichment
  -> GeneratedPack
  -> save request
  -> render/copy/share
```

Procedure-specific generators:
- appointment
- change doctor
- comune residence
- generic formal request
- landlord issue
- NASpI
- permesso documents
- refund complaint
- rejected request
- rental contract
- tessera sanitaria
- university office

Fallback behavior:
- many utilities/telecom/canone procedures still use `buildStandardPack(...)`
- this means some categories remain more generic than the user’s desired long-term depth

Generated pack now includes:
- subject/body variants
- WhatsApp/follow-up variants
- localized explanations
- attachment checklist
- next steps and warnings
- destination guidance
- recipient verification checklist
- submission method
- in-person/portal checklist
- official links to check
- selected contact snapshot
- service intelligence warnings

## 11. Service Intelligence System

Files:
- [domain/service_intelligence.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/domain/service_intelligence.dart)
- [data/service_intelligence_definitions.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/data/service_intelligence_definitions.dart)
- [data/service_intelligence_quality_service.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/data/service_intelligence_quality_service.dart)
- [data/service_terms_dictionary.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/data/service_terms_dictionary.dart)

What exists:
- procedure-level destination guidance
- official link references
- online/in-person options
- detailed documents
- before-sending and follow-up guidance
- verification status
- clickable term explanations for PEC/SPID/CIE and more

What does not fully exist yet:
- a fully separate remote catalog repository for official data
- a fully populated verified provider/contact database
- a complete anonymous public catalog backend

## 12. Local Persistence

Storage mechanism:
- SharedPreferences
- list/object JSON wrappers via `LocalStorageListRepository`

Important keys:

| Storage Key | Data Type | Repository | Used By | Sensitive? |
| --- | --- | --- | --- | --- |
| `italy_life_admin_onboarding_completed_v1` | onboarding state | local onboarding repo | startup | Low |
| `italy_life_admin_selected_language_v1` | language code | local language repo | localization | Low |
| `italy_life_admin_profile_v1` | profile JSON | local profile repo | profile/autofill | High |
| `italy_life_admin_requests_v1` | request list | local request repo | saved requests | High |
| `italy_life_admin_drafts_v1` | draft list | local draft repo | guided form drafts | Medium |
| `italy_life_admin_usage_events_v1` | usage events | analytics service | analytics/admin | Medium |
| `italy_life_admin_admin_config_v1` | admin config | admin config repo | startup/admin | Medium |
| `italy_life_admin_documents_v1` | documents list | phase5 local repo | document vault | High |
| `italy_life_admin_contacts_v1` | contacts list | phase5 local repo | contacts | High |
| `italy_life_admin_household_members_v1` | household list | phase5 local repo | household | High |
| `italy_life_admin_household_contracts_v1` | contracts list | phase5 local repo | household | High |
| `italy_life_admin_clients_v1` | client list | phase5 local repo | consultant preview | High |
| `italy_life_admin_deadlines_v1` | deadlines list | phase5 local repo | deadlines | Medium |
| `italy_life_admin_templates_v1` | templates list | phase5 local repo | templates | Medium |
| `italy_life_admin_proof_cases_v1` | proof cases | phase5 local repo | proof folder | High |
| `italy_life_admin_proof_items_v1` | proof items | phase5 local repo | proof folder | High |
| `italy_life_admin_before_sending_v1` | checklists | phase5 local repo | before-sending | Medium |
| `italy_life_admin_official_links_overrides_v1` | link overrides | phase5 local repo | admin links | Low |
| `italy_life_admin_telegram_handoffs_v1` | handoff payloads | phase5 local repo | telegram | Medium |
| `ufficcio_user_settings_v1` | user settings | Supabase readiness local repo | sync/privacy/settings | Medium |
| `ufficcio_entitlement_v1` | entitlement | entitlement repo | premium | Medium |
| `ufficiofacile_premium_config_v1` | premium config | premium repo | premium admin/debug | Medium |

Corruption handling:
- many local repos catch JSON errors and fall back to empty/default values
- tests exist for several corrupted-storage scenarios

## 13. Backend and Supabase Readiness

Current backend status:
- **Supabase partially integrated**

Checklist:

| Item | Status | File(s) | Notes |
| --- | --- | --- | --- |
| `supabase_flutter` dependency | Done | `pubspec.yaml` | Present |
| Bootstrap/init | Done | `main.dart`, `supabase_bootstrap.dart` | Optional and bounded |
| Env config | Done | `app_config.dart` | Real dart-defines |
| Local/remote repository switch | Done | `ufficcio_supabase_readiness.dart` | Requires auth + sync |
| Auth UI | Missing/partial | same file | Facade exists, UX does not |
| Public catalog repo | Missing as standalone abstraction | local services only | Gap versus newer design |
| Sync service | Partial | `ufficcio_supabase_readiness.dart` | Status/plumbing exists, full sync does not |
| Premium remote repo | Partial | same file | Entitlement repo exists |
| Admin remote writes | Effectively disabled | SQL function returns false | Safer than exposing writes |

## 14. Database Schema and Migrations

Migrations:
- [20260506090000_create_ufficciofacile_core.sql](/Users/mohammadkhataei/Desktop/UfficioFacile/supabase/migrations/20260506090000_create_ufficciofacile_core.sql)
- [20260506091000_create_ufficciofacile_rls.sql](/Users/mohammadkhataei/Desktop/UfficioFacile/supabase/migrations/20260506091000_create_ufficciofacile_rls.sql)
- [20260506092000_seed_ufficciofacile_catalog.sql](/Users/mohammadkhataei/Desktop/UfficioFacile/supabase/migrations/20260506092000_seed_ufficciofacile_catalog.sql)

Schema summary:
- current prefix is `ufficcio_`
- schema includes user data, catalog-like tables, admin config, sync, feedback, entitlements
- RLS exists

Important risk:
- newer docs/plans often say `ufficio_`
- actual code and migrations currently use `ufficcio_`

## 15. Authentication and User Data

Current auth behavior:
- no required login
- no visible full sign-up/sign-in flow
- local-only use is the default real behavior
- `UfficcioAuthFacade` simply reports current Supabase auth state if configured

User data:
- local by default
- remote only if future auth + sync path is used

## 16. Sync Architecture

Current sync files:
- [lib/features/italy_admin_copilot/data/ufficcio_supabase_readiness.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/data/ufficcio_supabase_readiness.dart)
- [lib/features/italy_admin_copilot/presentation/screens/life_admin_supabase_screens.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/presentation/screens/life_admin_supabase_screens.dart)

Current sync model:
- opt-in via settings
- requires Supabase mode
- requires auth
- `syncAll()` currently mostly reports status and writes a sync log object in memory
- conflict resolution helpers exist for request records

This is scaffolding, not a full bidirectional sync system.

## 17. Premium and Entitlements

Files:
- [data/premium_service.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/data/premium_service.dart)
- [domain/premium_config.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/domain/premium_config.dart)
- [domain/ufficcio_entitlement.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/domain/ufficcio_entitlement.dart)

Feature table:

| Feature | Free | Pro | Consultant | Gate File/Service |
| --- | --- | --- | --- | --- |
| Generate packs | Limited | Higher/unlimited | Higher/unlimited | `UfficioPremiumEntitlementService` |
| Saved requests | Limited | More | More | same |
| Reminders | Limited | More | More | same |
| Document vault | Limited | More | More | same |
| Proof folder | Gated | Yes | Yes | same |
| Household features | Limited/gated | Yes | Yes | same |
| Utility comparison | Limited/gated | Yes | Yes | same |
| Bill analysis | Limited/gated | Yes | Yes | same |
| Canone RAI advanced | Gated | Yes | Yes | same |
| Telecom advanced | Gated | Yes | Yes | same |
| Export full pack | Gated | Yes | Yes | same |
| Consultant mode | No | No by default | Future | same |

Current limitations:
- no real payment provider
- local debug Pro exists
- premium is strong at UX/logic level, not secure payment enforcement level

## 18. Admin Panel

Admin screens live mostly in:
- [life_admin_screens.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/presentation/screens/life_admin_screens.dart)

Current admin capabilities:
- generated pack quality checks
- template override management
- premium debug/config screen
- demo data seed
- event review
- service-intelligence quality summary

Current access model:
- route is visible locally
- secure remote admin role enforcement is not finished in app UX
- SQL helper returns false for admin writes by default

## 19. Localization and RTL

Localization file:
- [lib/app/app_localizations.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/app/app_localizations.dart)

Supported languages:

| Language | Code | RTL? | Status |
| --- | --- | --- | --- |
| Italian | `it` | No | Partial |
| English | `en` | No | Best fallback |
| Spanish | `es` | No | Partial |
| Persian | `fa` | Yes | Partial |
| Arabic | `ar` | Yes | Partial |

RTL:
- handled via `AppLocalizations.isRtl`
- `Directionality` is applied app-wide in `LifeAdminApp`

Important limitation:
- central localization exists, but many screens still contain hardcoded strings outside the map
- especially in startup/privacy/sync/admin/detail helper text

## 20. Platform Support

Android:
- folder exists
- debug APK build previously passed
- command: `flutter run -d android`

iOS:
- folder exists
- build currently blocked by CocoaPods in current environment
- command: `flutter build ios --debug --no-codesign`

Web:
- folder exists
- debug web build previously passed
- command: `flutter run -d chrome --dart-define=UFFICCIOFACILE_BACKEND_MODE=local`

macOS:
- folder missing
- not currently configured in repo

## 21. Build, Run, and Deployment Guide

Local dev:

```bash
flutter pub get
flutter run -d chrome --dart-define=UFFICCIOFACILE_BACKEND_MODE=local
```

Android debug:

```bash
flutter build apk --debug --dart-define=UFFICCIOFACILE_BACKEND_MODE=local
```

Web build:

```bash
flutter build web --debug --dart-define=UFFICCIOFACILE_BACKEND_MODE=local
```

Supabase run:

```bash
flutter run -d chrome \
  --dart-define=UFFICCIOFACILE_BACKEND_MODE=supabase \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT_REF.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_PUBLIC_ANON_KEY
```

Supabase setup high-level:
1. create project
2. copy project URL
3. copy anon key
4. never use service role key in Flutter
5. push migrations
6. verify RLS
7. test local mode
8. test optional sync/auth paths

## 22. Testing Status

Observed test files:
- [test/startup_test.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/test/startup_test.dart)
- [test/life_admin_services_test.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/test/life_admin_services_test.dart)
- [test/ufficcio_supabase_readiness_test.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/test/ufficcio_supabase_readiness_test.dart)
- [test/service_intelligence_premium_test.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/test/service_intelligence_premium_test.dart)
- [test/widget_test.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/test/widget_test.dart)

Previously run during this thread:

| Command | Result | Notes |
| --- | --- | --- |
| `flutter pub get` | Passed | Dependencies resolved |
| `flutter analyze` | Passed | No issues found |
| `flutter test` | Passed | All tests passed |
| `flutter build apk --debug` | Passed | Artifact generated |
| `flutter build web --debug` | Passed | Artifact generated |
| `flutter build ios --debug --no-codesign` | Failed in env | CocoaPods not installed/valid |

## 23. Risks and Gaps

High:
- Localization coverage is incomplete outside central keys.
- Public catalog backend model is not fully implemented.
- Remote admin/security model is unfinished.
- Real payment/security is not implemented.
- Auth UX is absent while some remote flows depend on auth.

Medium:
- Very large screen files increase maintenance risk.
- `ufficcio_` vs `ufficio_` naming mismatch can cause future migration confusion.
- Many utility/telecom procedures still rely on generic standard pack text.

Low:
- Theme/system architecture is simple but coherent.
- Startup safety is better than average for a small app.

## 24. Launch Roadmap

Phase A: Make it runnable
- keep local mode healthy
- keep analyze/test green
- repair iOS CocoaPods environment
- add macOS only if needed

Phase B: Make it usable
- deepen weaker procedures
- remove more generic standard-pack fallbacks
- finish localization coverage

Phase C: Make it safe
- tighten guidance wording
- add more verified-source metadata
- improve privacy/export/delete messaging

Phase D: Supabase beta
- decide final schema prefix
- add true anon public-catalog tables/policies
- implement remote catalog repository
- add auth UX only if sync is product-ready

Phase E: Premium beta
- keep local premium behavior
- defer real payment until secure backend path exists

Phase F: Public beta
- privacy policy
- support flow
- deployment checklist
- feedback handling

## 25. Exact Next Commands

```bash
flutter pub get
flutter analyze
flutter test
flutter run -d chrome --dart-define=UFFICCIOFACILE_BACKEND_MODE=local
```

## 26. Appendix: Important Files

- [lib/main.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/main.dart)
- [lib/app/app.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/app/app.dart)
- [lib/app/app_config.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/app/app_config.dart)
- [lib/app/app_routes.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/app/app_routes.dart)
- [lib/app/app_scope.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/app/app_scope.dart)
- [lib/app/app_localizations.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/app/app_localizations.dart)
- [lib/features/italy_admin_copilot/data/pack_generator.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/data/pack_generator.dart)
- [lib/features/italy_admin_copilot/data/procedure_definitions.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/data/procedure_definitions.dart)
- [lib/features/italy_admin_copilot/data/ufficcio_supabase_readiness.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/data/ufficcio_supabase_readiness.dart)
- [lib/features/italy_admin_copilot/data/premium_service.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/data/premium_service.dart)
- [lib/features/italy_admin_copilot/presentation/screens/life_admin_screens.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/presentation/screens/life_admin_screens.dart)

## 27. Appendix: Route Table

See Section 5. The route constants are defined centrally in [lib/app/app_routes.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/app/app_routes.dart).

## 28. Appendix: Storage Keys

See Section 12. Most storage keys are defined in:
- [lib/features/italy_admin_copilot/data/life_admin_phase5_services.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/data/life_admin_phase5_services.dart)
- [lib/features/italy_admin_copilot/data/local_onboarding_repository.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/data/local_onboarding_repository.dart)
- [lib/features/italy_admin_copilot/data/local_request_repository.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/data/local_request_repository.dart)
- [lib/features/italy_admin_copilot/data/ufficcio_supabase_readiness.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/data/ufficcio_supabase_readiness.dart)
- [lib/features/italy_admin_copilot/data/premium_service.dart](/Users/mohammadkhataei/Desktop/UfficioFacile/lib/features/italy_admin_copilot/data/premium_service.dart)

## 29. Appendix: Supabase Tables

See Sections 6 and 14. Current real tables are the `ufficcio_*` tables created by [20260506090000_create_ufficciofacile_core.sql](/Users/mohammadkhataei/Desktop/UfficioFacile/supabase/migrations/20260506090000_create_ufficciofacile_core.sql).

## 30. Appendix: Procedure Catalog

Current static procedure IDs:
- `CHANGE_DOCTOR`
- `TESSERA_SANITARIA_RENEWAL`
- `ASL_REJECTED_REQUEST_REPLY`
- `ASL_APPOINTMENT_REQUEST`
- `RENTAL_CONTRACT_CHANGE`
- `LANDLORD_MAINTENANCE_OR_CONTRACT`
- `DEPOSIT_RETURN_REQUEST`
- `RENT_CONTRACT_TERMINATION_NOTICE`
- `ENERGY_BILL_ANALYZER_CHECKLIST`
- `ENERGY_SUPPLIER_COMPARISON`
- `ELECTRICITY_GAS_SWITCH_REQUEST`
- `VOLTURA_REQUEST`
- `SUBENTRO_REQUEST`
- `UTILITY_CANCELLATION_DISDETTA`
- `HIGH_BILL_COMPLAINT`
- `METER_READING_CORRECTION`
- `PAYMENT_PLAN_REQUEST`
- `WRONG_CHARGE_REFUND_REQUEST`
- `UNILATERAL_CONTRACT_CHANGE_COMPLAINT`
- `CANONE_RAI_NO_TV_DECLARATION_CHECKLIST`
- `CANONE_RAI_EXEMPTION_OVER_75_CHECKLIST`
- `CANONE_RAI_REFUND_OR_WRONG_CHARGE`
- `INTERNET_PHONE_CANCELLATION`
- `TELECOM_WRONG_BILL_COMPLAINT`
- `SERVICE_NOT_WORKING_COMPLAINT`
- `MODEM_RETURN_OR_CHARGE_DISPUTE`
- `COMUNE_RESIDENCE_REQUEST`
- `ANAGRAFE_CERTIFICATE_REQUEST`
- `NASPI_PREPARATION`
- `PATRONATO_APPOINTMENT_REQUEST`
- `UNIVERSITY_OFFICE_REQUEST`
- `PERMESSO_DOCUMENT_CHECKLIST`
- `REJECTED_REQUEST_REPLY`
- `REFUND_OR_COMPLAINT_REQUEST`
- `APPOINTMENT_REQUEST`
- `GENERIC_FORMAL_REQUEST`
