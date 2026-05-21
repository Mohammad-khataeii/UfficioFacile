# Google Play Data Safety draft

This is a working draft based on the current repository. It is not a legal certification. Unknowns are called out explicitly and must be confirmed before submission.

## Likely collected data categories

Personal info:

- Email address for authentication and account access
- Name, city, codice fiscale, and similar profile information if entered by the user

Financial info:

- Stripe handles payment card details
- The app/backend may receive subscription status, payment state, entitlement state, and transaction metadata
- TODO: confirm the exact payment-status fields retained in production storage

User-generated content:

- Saved requests
- Problem request details
- Consultancy request details
- Notes, reminders, and related form inputs

App activity:

- Interactions with premium, request, reminder, and account flows may be stored as part of normal app usage
- TODO: confirm whether any additional analytics events are retained in production

Device or other identifiers:

- Supabase/Auth identifiers for account state
- Potential advertising/device identifiers if AdMob is enabled in production

Diagnostics:

- TODO: confirm whether crash reporting or diagnostics SDKs are enabled in the final production build

## Data sharing and processing

Likely processors or recipients:

- Supabase for auth, database, and server-side logic
- Stripe for checkout, subscriptions, and payment confirmation
- Vercel or hosting providers for web/admin surfaces when applicable
- Google AdMob only if production ads are enabled

TODO:

- Confirm whether any analytics or diagnostics provider beyond the above is enabled in the production app

## Security practices

- Backend communication is intended to be encrypted in transit
- Release signing is required for Play uploads
- Sensitive server credentials such as `SUPABASE_SERVICE_ROLE_KEY` must remain server-side only

## Account deletion and retention

- Users can clear local app data in the privacy center
- Current account deletion path is a support-based request flow opened from inside the app
- TODO: update this section if self-service account deletion is later implemented

## Play Console answer guidance

Use these answers only after final verification:

- Collected: likely yes for personal info, user-generated content, and account identifiers
- Shared: yes with processors such as Supabase and Stripe; AdMob only if ads are enabled
- Encryption in transit: intended yes, confirm before submission
- Deletion request path: yes, through the in-app deletion request route plus support handling

## Unknowns to resolve before production

- Whether diagnostics/crash data is collected in production
- Whether analytics beyond local or privacy-safe settings are active in production
- Whether production ads are enabled for the actual release
