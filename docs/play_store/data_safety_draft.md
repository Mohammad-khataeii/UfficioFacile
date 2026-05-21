# Google Play Data Safety draft

This is a practical working draft for the Google Play Data Safety form. It is not a legal certification. The final Play form must match the exact production build that is uploaded.

| Data type | Collected? | Shared? | Purpose | Required/optional | Retention or deletion note | Code/source evidence |
| --- | --- | --- | --- | --- | --- | --- |
| Email address | Yes | Shared with Supabase Auth | Account creation, sign-in, password reset | Required for account features | User can request account deletion from `Account` -> `Privacy center` | `lib/features/auth`, `lib/app/supabase_bootstrap.dart` |
| Name/profile info | Yes, if entered | Shared with Supabase when synced | User profile and autofill | Optional | Included in account data; deletion request is support-based | `lib/features/italy_admin_copilot/data/local_profile_repository.dart`, profile flows |
| Codice fiscale | Yes, if entered | Shared with Supabase when synced | Administrative profile completion | Optional | Sensitive personal data entered by user; deletion request applies | profile and readiness modules under `lib/features/italy_admin_copilot` |
| City and language | Yes | Shared with Supabase when synced | Localization and city-aware guidance | Optional | Can also exist locally on device | `lib/features/italy_admin_copilot`, `lib/app/app_localizations.dart` |
| Saved requests and problem descriptions | Yes | Shared with Supabase when sync/backend features are active | Request tracking and user workflow history | Optional | User can clear local data; account deletion request covers server-held app data where applicable | request repositories and sync modules |
| Consultancy request messages | Yes, if used | Shared with Supabase when submitted | Premium/support workflow | Optional | Retained as app-support data until deleted per backend policy | `consultancy` flows in `lib/features/italy_admin_copilot` |
| Payment or entitlement status | Yes | Shared with Stripe and Supabase backend | Premium access control, checkout status, entitlements | Optional, only for premium flows | Stripe handles card details; app should not store card numbers | `lib/features/italy_admin_copilot/data/premium_service.dart`, `supabase/functions` |
| Device or advertising IDs | Only if ads are enabled in production | Shared with Google AdMob if ads enabled | Ad delivery and anti-fraud | Optional | Must match final ad-enabled or ad-disabled release build | AdMob config in `lib/app/app_config.dart`, `lib/features/italy_admin_copilot/data/ads_service.dart` |
| Notifications and reminders | Yes, if user enables them | Not expected to be shared beyond required platform delivery | Reminder scheduling and deadline notifications | Optional | User can disable notifications and clear local data | `flutter_local_notifications`, notification services |
| Diagnostics or logs | Unknown, limited app/runtime logs likely | Unknown | Reliability and debugging | Unknown | Confirm before submission | review current SDK/runtime configuration before Play form |
| Document metadata or user-entered document details | Yes, if user uses document features | Shared with Supabase when synced | Organizing supporting documents and request readiness | Optional | Local deletion supported; account deletion request covers synced data where applicable | document-related repositories under `lib/features/italy_admin_copilot` |

## Important notes for Play Console

- Stripe handles payment card details. The app and backend should receive payment state and entitlement data, not full card numbers.
- Supabase stores auth, profile, sync, request, and related app data when backend-backed features are enabled.
- AdMob only applies if ads are enabled in the actual production build.
- The Data Safety form must match the final uploaded build. If the build ships with ads disabled, do not declare ad-related data collection that is not active in that build.

## Recommended Play Console answers for current first release

- Ads: disabled if no production AdMob IDs are passed
- Payment card information: handled by Stripe, not stored directly by the app
- Data encrypted in transit: yes, intended for backend communication
- Users can request deletion: yes
- Data is not sold
- Data is processed to provide app functionality, account management, support, payments, and security

## Security practices

- Network communication is intended to be encrypted in transit.
- Release signing is required for Play uploads.
- `SUPABASE_SERVICE_ROLE_KEY` must remain server-side only.

## Account deletion and retention

- Users can clear local app data inside `Account` -> `Privacy center`.
- Users can request account deletion through `Account` -> `Privacy center` -> `Request account deletion`.
- If self-service deletion is added later, update both this draft and the Play form.

## Unknowns to resolve before submission

- Whether any diagnostics or crash-reporting SDK is active in the final production build
- Whether any analytics beyond current local or privacy-safe settings is active in the final production build
- Whether ads are enabled in the final uploaded build

## Before submitting, verify final build flags

- If AdMob IDs are included, update Ads and Data Safety answers.
- If analytics is active in the final build, include analytics-related data handling.
- If document upload or persistent document storage is active, include file or document data in the final answers.
