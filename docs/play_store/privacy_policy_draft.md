# Privacy policy draft

This is a product draft for Google Play preparation. It is not legal advice and must be reviewed before publication.

## App

- App name: UfficioFacile
- Purpose: helping users understand and organize Italian administrative procedures

## What the app does

UfficioFacile helps users browse guidance about administrative processes, save requests and reminders, and optionally access premium features related to deeper assistance and workflow organization. The app is informational and organizational in nature. It is not a government office, legal representative, or official public authority.

## Account and authentication

The app can offer account creation and sign-in through Supabase Auth. When a user creates an account or signs in, the app may process:

- email address
- authentication state
- account identifiers needed to keep the user signed in

## User profile and request data

Depending on how the user uses the app, the app may process:

- name
- email
- codice fiscale
- city or city-related selections
- preferred language
- saved requests
- problem request details
- consultancy request details
- uploaded or described document/request information when the relevant feature is used

## Premium and payments

The app may offer premium purchases or paid flows backed by Stripe and Supabase. Payment card details are handled by Stripe. The mobile app and its backend may receive payment status, subscription status, entitlement status, and related transaction metadata, but should not store full card numbers directly.

## Notifications and reminders

The app may send notifications or reminders for deadlines, checklist items, or account-related actions when the user has enabled the relevant features and permissions.

## Ads

Production builds disable ads unless real AdMob identifiers are explicitly configured. If ads are enabled in a future production release, the app may use Google AdMob services and related device or app identifiers as part of ad delivery. If ads are disabled in the production build, the Play Console ads declaration and privacy wording must be updated to reflect that state accurately.

## Technical data and diagnostics

The app may process limited technical information such as:

- app configuration state
- device/app identifiers exposed by SDKs when required for authentication, notifications, or ads
- diagnostic or log information needed for reliability and abuse prevention

This draft does not guarantee whether crash reporting or analytics are fully enabled in production. Confirm final SDK behavior before publication.

## Service providers and processors

Depending on enabled features, data may be processed by:

- Supabase for authentication, database, and server-side functions
- Stripe for payments and billing
- Google AdMob, only if production ads are enabled
- Vercel or related hosting infrastructure for web/admin surfaces if applicable

## Data retention and deletion

Users can clear local app data from the in-app privacy center. For account deletion, the current supported route is an in-app “Request account deletion” action that opens an email request to `support@ufficiofacile.app`. The deletion workflow and published policy should be updated if self-service account deletion is introduced later.

## User rights and contact

Users should be able to contact the operator for:

- access requests
- deletion requests
- correction requests
- privacy questions

Draft contact:

- `support@ufficiofacile.app`

## Security

The app is intended to use encrypted network transport for live backend communication. Final publication should confirm TLS coverage, access controls, and backend data-handling practices.

## Disclaimer

UfficioFacile is an informational and organizational tool. It does not replace official government guidance, legal advice, or direct assistance from public offices or licensed professionals.
