# Privacy policy draft

This draft is intended to become publishable after replacing any remaining legal placeholders and confirming the live deployment. It is not legal advice.

Public URL to use in Play Console:

- `https://ufficio-facile.vercel.app/privacy`

Checklist:

- [ ] Published and accessible without login
- [ ] Same URL entered in Play Console
- [ ] Contact email works
- [ ] Account deletion page linked
- [ ] Data Safety answers match this policy

Effective date placeholder:

- `2026-05-21` or replace with the final publication date

Controller or operator placeholder:

- `Seyedmohammad Khataeipour`
- `Torino, Italy`
- Contact email: `support@ufficiofacile.app`

## 1. About UfficioFacile

UfficioFacile is an informational and organizational app designed to help users understand and manage Italian administrative procedures. It may provide guidance, reminders, request tracking, account features, premium functionality, and optional ads only if ads are explicitly enabled in a future production build.

UfficioFacile is not a public authority, government portal, lawyer, accountant, CAF, patronato, immigration consultant, or substitute for official advice.

## 2. Categories of personal data

Depending on how the app is used, the operator may process:

- account data such as email address and authentication identifiers
- profile data such as full name, city, preferred language, and codice fiscale if the user enters it
- request and workflow data such as saved requests, problem descriptions, consultancy requests, reminders, and document-related details entered by the user
- premium and billing-related status data such as entitlement state, payment status, subscription metadata, and limited payment-event records
- technical data needed for app delivery, reliability, notifications, and supported integrations

## 3. Why data is processed

Personal data may be processed to:

- create and manage user accounts
- provide app features and save user workflows
- deliver reminders and notifications
- operate premium and payment-related features
- protect the service, diagnose errors, prevent abuse, and maintain reliability
- comply with legal obligations where applicable

## 4. Payments

Premium purchases may rely on Stripe and Supabase-backed services. Stripe handles payment card details and payment processing. UfficioFacile does not store full card numbers directly. The app and backend may receive payment state, subscription state, entitlement status, and related transaction metadata.

## 5. Ads

The current intended first Google Play internal-testing build keeps ads disabled unless real production AdMob identifiers are explicitly configured. If ads are enabled in a future production build, Google AdMob may process device or advertising identifiers for ad delivery and related anti-fraud purposes. The published policy and Play declarations must match the actual build that is released.

## 6. Service providers and processors

Depending on enabled features, data may be processed by:

- Supabase for authentication, database storage, backend functions, and related services
- Stripe for checkout, subscriptions, and payment processing
- Vercel or related hosting infrastructure for public web or admin surfaces where applicable
- Google AdMob only if ads are enabled in the production build

## 7. Data retention and deletion

Users can clear local app data inside the app through `Account` -> `Privacy center` -> `Delete local data`.

Users can delete their account inside the app through `Account` -> `Privacy center` -> `Delete my account`, then confirm by typing `DELETE`.

If in-app deletion is unavailable or fails, users can request deletion by email at `support@ufficiofacile.app`.

Deletion is intended to cover the account and associated app data where legally possible. Some payment, invoice, fraud-prevention, security, or legally required records may be retained or detached from the deleted account where appropriate.

Public account deletion page:

- `https://ufficio-facile.vercel.app/account-deletion`

## 8. User rights

Where applicable under Italian and EU data-protection law, users may have rights including:

- access
- rectification
- deletion
- restriction
- objection
- portability

Requests can be sent to:

- `support@ufficiofacile.app`

## 9. Security

The app is intended to use encrypted network transport for live backend communication. Account deletion is performed server-side through an authenticated Supabase Edge Function. Client applications must not contain service-role keys, and the mobile app does not use the service role to delete accounts directly.

## 10. International and legal note

This draft uses GDPR-oriented language because the app is intended for Italy and EU-related use cases. It still requires legal review before publication.

## 11. Disclaimer

UfficioFacile provides practical guidance and organizational help only. It does not replace official government guidance, legal advice, tax advice, accounting advice, or professional representation before public offices.
