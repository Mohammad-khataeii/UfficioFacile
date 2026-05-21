# Google Play Data Safety draft

This is a practical working draft for the Google Play Data Safety form. It is not a legal certification. The final Play form must match the exact production build that is uploaded.

| Play Console data category | Data example in UfficioFacile | Collected? | Shared? | Purpose | Required or optional? | Retention or deletion | Code or module evidence |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Personal info: Email address | Supabase Auth email and account email | Yes | Shared with Supabase Auth | Account creation, sign-in, password reset, account management | Required for account features | User can delete account in-app or use email fallback | `lib/features/auth`, `supabase/functions/delete-account`, `supabase/migrations/20260508170000_fix_premium_profile_runtime_schema.sql` |
| Personal info: Name | Full name entered in profile | Yes, if entered | Shared with Supabase when synced | Profile completion and autofill | Optional | Deleted with account where legally possible | profile flows and `ufficio_profiles` or `ufficcio_profiles` tables |
| Personal info: Government ID | Codice fiscale if user enters it | Yes, if entered | Shared with Supabase when synced | Administrative profile completion | Optional | Deleted with account where legally possible | profile flows and profile tables |
| Personal info: Address or city | City, address, Comune-related profile data | Yes, if entered | Shared with Supabase when synced | Localization, profile completion, city-aware guidance | Optional | Deleted with account where legally possible | profile repositories and guidance modules |
| App info and performance: User IDs | Supabase user ID, entitlement links, request ownership | Yes | Shared with Supabase and Stripe-linked backend flows | Authentication, entitlements, support workflows, deletion | Required for signed-in features | Auth user deleted in self-service flow; retained payment or audit rows may be detached from the user | auth, premium, and deletion modules |
| App activity: Saved requests and workflow history | Saved requests, request notes, reminders, generated workflow data | Yes | Shared with Supabase when synced | Request tracking and workflow history | Optional | Deleted with account where legally possible | request repositories, legacy `ufficcio_requests`, related tables |
| User-generated content | Problem descriptions and saved problem text | Yes, if user submits | Shared with Supabase | Support intake and workflow handling | Optional | Self-service flow deletes owned support rows where possible | `ufficio_problem_requests`, request flows |
| User-generated content | Consultancy request messages | Yes, if user submits | Shared with Supabase | Premium or support workflow handling | Optional | Self-service flow deletes consultancy rows; limited payment traces may remain detached | `ufficio_consultancy_requests`, `ufficio_consultancy_payments` |
| Financial info | Payment or entitlement status, Stripe customer or subscription references | Yes | Shared with Stripe and Supabase backend | Premium checkout, entitlement enforcement, billing support | Optional | Event rows may be retained in detached or anonymized form where legally required | `ufficio_user_entitlements`, `ufficio_payment_events`, `ufficio_premium_events`, Stripe functions |
| Financial info: Payment card details | Card number, CVC, expiry | No, not stored directly by app | Stripe handles directly | Payment processing | Optional | Not stored directly by app | Stripe checkout flow in `supabase/functions/create-checkout-session` |
| App activity | Checklist items, deadlines, saved procedures, cost items, scans | Yes, if user uses connected tools | Shared with Supabase when synced | Organization, reminders, productivity features | Optional | Deleted with account where legally possible | `connected_product_data.dart`, related `ufficio_*` tables |
| Photos and files / Documents | Document metadata, file names, storage paths, proof items if used | Yes, if user uses document features | Shared with Supabase when synced | Document organization and proof workflows | Optional | Metadata deleted with account; storage cleanup is attempted where paths exist | legacy `ufficcio_documents`, `ufficcio_proof_items`, connected repositories |
| App info and performance: Crash logs or diagnostics | Limited reliability or runtime diagnostics if present | Unknown | Unknown | Reliability and debugging | Unknown | Verify final SDK stack before submission | confirm before final Play form |
| Device or other IDs | Advertising or device identifiers through AdMob | Only if ads are enabled in production | Shared with Google AdMob only when enabled | Ad delivery and anti-fraud | Optional | Must match final released build | `ads_service.dart`, Android manifest placeholder config |
| App activity / preferences | Notification preferences and reminder settings | Yes, if enabled by user | Normally not shared beyond required platform delivery | Notification scheduling and reminders | Optional | Cleared locally after deletion; synced data deleted where applicable | `notification_service.dart`, deadline and checklist data |

## Recommended Play Console answers for current first release

- Ads: disabled if no production AdMob IDs are passed
- Payment card information: handled by Stripe, not stored directly by the app
- Account deletion: users can delete their account in-app through `Profile` -> `Account and privacy` -> `Delete my account`, with email fallback from the same section
- Data encrypted in transit: yes, intended for backend communication
- Data is not sold
- Data is processed to provide app functionality, account management, support, payments, deletion, and security

## Account deletion and retention

- Users can delete their account inside the app and are signed out after success.
- Users can also use the public account deletion page and email fallback.
- Some payment, invoice, fraud-prevention, security, or minimal audit records may remain detached from the deleted account where legally required.

## Before submitting, verify final build flags

- If AdMob IDs are included, update Ads and Data Safety answers.
- If analytics is active in the final build, include analytics-related data handling.
- If document upload or persistent document storage is active, include file or document data in the final answers.
- If account deletion behavior changes, update the privacy policy, account deletion page, and Play Console text together.
