# Account Deletion Data Map

This document maps the user-related data currently visible in the repository and the intended self-service account-deletion behavior. It is an implementation guide, not legal advice.

## Scope

The in-app self-service deletion flow is designed to:

- delete user-owned operational data where it is safe to remove it
- anonymize or detach records that may need limited retention for payments, security, anti-fraud, or audit purposes
- delete the Supabase Auth user last, from the server side only

## Data map

| Table name | User identifier column | Delete, anonymize, or retain | Reason | RLS or security notes | Implemented by Edge Function | Legal retention notes |
| --- | --- | --- | --- | --- | --- | --- |
| `public.ufficio_profiles` | `user_id` | Delete | Main synced profile data | Authenticated user owns row; backend deletion happens before auth user removal or by FK cascade | Yes, via auth-user deletion cascade | No special retention expected |
| `public.ufficcio_profiles` | `user_id` | Delete | Legacy profile table still present in migrations | Authenticated user owns row; legacy compatibility only | Yes, via auth-user deletion cascade | No special retention expected |
| `public.ufficio_user_entitlements` | `user_id` | Delete | Current entitlement state should not survive the account | Server-owned premium truth; never client-destructive | Yes, via auth-user deletion cascade | Historical payment records are handled separately |
| `public.ufficio_usage_counters` | `user_id` | Delete | Per-user usage accounting is app-operational only | Authenticated rows; backend-only cleanup | Yes, via auth-user deletion cascade | No special retention expected |
| `public.ufficio_user_content_unlocks` | `user_id` | Delete | Purchased or granted unlock state belongs to the account | Authenticated rows; backend-only cleanup | Yes, via auth-user deletion cascade | Payment-event retention stays elsewhere |
| `public.ufficio_problem_requests` | `user_id` | Delete | Contains personal support/problem content | `user_id` is nullable, so FK alone would only detach the row | Yes, explicit delete before auth deletion | No legal retention assumed by default |
| `public.ufficio_consultancy_requests` | `user_id` | Delete | Contains personal consultancy/support content | `user_id` is nullable, so explicit delete is safer than leaving message content | Yes, explicit delete before auth deletion | Payment records may survive separately in anonymized form |
| `public.ufficio_consultancy_payments` | `user_id` | Anonymize | Payment linkage may need limited retention | `user_id` is nullable; detach identity instead of deleting every payment trace | Yes, explicit `user_id -> null` update | Payment and accounting retention may apply |
| `public.ufficio_payment_events` | `user_id` | Anonymize | Payment/audit event history may need retention | `user_id` is nullable; no client access to destructive path | Yes, explicit `user_id -> null` update | Payment, invoice, fraud, or dispute retention may apply |
| `public.ufficio_premium_events` | `user_id`, `actor_user_id` | Anonymize | Premium/audit history may need retention | `user_id` and `actor_user_id` are nullable | Yes, explicit nulling before auth delete | Payment and audit retention may apply |
| `public.ufficio_promo_redemptions` | `user_id` | Delete | User promo-redemption history is account-bound | Authenticated own-row access only | Yes, explicit delete plus possible FK cleanup | No special retention assumed |
| `public.ufficio_situation_scans` | `user_id` | Delete | Personal workflow analysis data | Authenticated rows; app-operational only | Yes, via auth-user deletion cascade | No special retention expected |
| `public.ufficio_checklist_items` | `user_id` | Delete | Personal checklist state | Authenticated rows; app-operational only | Yes, via auth-user deletion cascade | No special retention expected |
| `public.ufficio_deadlines` | `user_id` | Delete | Personal deadlines and reminders | Authenticated rows; app-operational only | Yes, via auth-user deletion cascade | No special retention expected |
| `public.ufficio_saved_procedures` | `user_id` | Delete | Personal saved procedures | Authenticated rows; app-operational only | Yes, via auth-user deletion cascade | No special retention expected |
| `public.ufficio_cost_items` | `user_id` | Delete | Personal cost-tracking items | Authenticated rows; app-operational only | Yes, via auth-user deletion cascade | No special retention expected |
| `public.ufficcio_requests` | `user_id` | Delete | Legacy synced requests can contain personal data | Authenticated rows; FK cascade is safe | Yes, via auth-user deletion cascade | No special retention expected |
| `public.ufficcio_generated_packs` | `user_id` | Delete | Legacy generated pack content can contain personal text | Authenticated rows; FK cascade is safe | Yes, via auth-user deletion cascade | No special retention expected |
| `public.ufficcio_status_events` | `user_id` | Delete | Legacy request-history entries are account-bound | Authenticated rows; FK cascade is safe | Yes, via auth-user deletion cascade | No special retention expected |
| `public.ufficcio_reminders` | `user_id` | Delete | Legacy reminder rows are account-bound | Authenticated rows; FK cascade is safe | Yes, via auth-user deletion cascade | No special retention expected |
| `public.ufficcio_documents` | `user_id` | Delete | Document metadata is personal app data | Authenticated rows; storage paths may also exist | Yes, row deletion via auth-user cascade and storage cleanup where paths exist | No special retention expected |
| `public.ufficcio_proof_items` | `user_id` | Delete | Proof/document metadata can be personal | Authenticated rows; storage paths may also exist | Yes, row deletion via auth-user cascade and storage cleanup where paths exist | No special retention expected |
| `public.ufficcio_contacts` | `user_id` | Delete | User-entered contacts are account data | Authenticated rows; FK cascade is safe | Yes, via auth-user deletion cascade | No special retention expected |
| `public.ufficcio_household_members` | `user_id` | Delete | Contains family or household personal data | Authenticated rows; FK cascade is safe | Yes, via auth-user deletion cascade | No special retention expected |
| `public.ufficcio_household_contracts` | `user_id` | Delete | Personal contract details are account data | Authenticated rows; FK cascade is safe | Yes, via auth-user deletion cascade | No special retention expected |
| `public.ufficcio_utility_comparisons` | `user_id` | Delete | Personal comparison inputs/results are account data | Authenticated rows; FK cascade is safe | Yes, via auth-user deletion cascade | No special retention expected |
| `public.ufficcio_bill_analyses` | `user_id` | Delete | Personal bill-analysis inputs/results are account data | Authenticated rows; FK cascade is safe | Yes, via auth-user deletion cascade | No special retention expected |
| `public.ufficcio_proof_cases` | `user_id` | Delete | Proof-case metadata is account-bound | Authenticated rows; FK cascade is safe | Yes, via auth-user deletion cascade | No special retention expected |
| `public.ufficcio_usage_events` | `user_id` | Delete | Legacy analytics-style events are app-operational only | `user_id` is nullable, so explicit delete is preferred | Yes, explicit delete before auth deletion | No sale or marketing retention intended |
| `public.ufficcio_feedback` | `user_id` | Delete | Feedback may contain personal free-text | `user_id` is nullable, so explicit delete is preferred | Yes, explicit delete before auth deletion | No special retention expected unless manually extracted for abuse/security review |
| `public.ufficcio_community_templates` | `user_id` | Delete | User-submitted community content may contain personal details | `user_id` is nullable, so explicit delete is preferred | Yes, explicit delete before auth deletion | Manual review may be needed if future moderation rules change |
| `public.ufficcio_delete_requests` | `user_id` | Retain limited audit row | Useful to record a deletion event without keeping the user account | `user_id` is nullable; service-role-only backend writes | Yes, function inserts and completes the audit row | Minimal deletion-audit retention may apply |
| `public.ufficio_admin_users` | `user_id` | Retain by blocking self-service | Admin accounts should not self-delete through the consumer path | Checked server-side before deletion | Yes, function blocks active admin accounts | Manual support review required |
| `auth.users` | `id` | Delete last | Final account removal | Must only be deleted server-side with service role | Yes, `auth.admin.deleteUser(userId)` | Authentication record is removed after data cleanup |

## Local device data

The Flutter client also clears locally stored personal data after successful server deletion, including:

- local profile, requests, drafts, documents, contacts, household, proof, deadlines, templates, and consultancy/problem request caches
- connected product data such as scans, checklist items, saved procedures, and cost items
- cached entitlement, premium product, unlock, and notification-preference data

Onboarding and generic app boot state are intentionally not treated as account records unless needed for stability.
