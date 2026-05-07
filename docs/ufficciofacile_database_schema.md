# UfficcioFacile Database Schema

## Main user tables

- `ufficcio_profiles`: user profile and autofill data
- `ufficcio_user_settings`: language, onboarding, sync, analytics, theme
- `ufficcio_requests`: saved request metadata
- `ufficcio_generated_packs`: generated Italian email/PEC pack bodies
- `ufficcio_status_events`: request timeline
- `ufficcio_reminders`: follow-up and deadline items
- `ufficcio_documents`: document vault metadata only
- `ufficcio_contacts`: office/provider/landlord contacts
- `ufficcio_household_members`: family/roommate/client-like members
- `ufficcio_household_contracts`: recurring household contracts
- `ufficcio_utility_comparisons`: manual offer comparison results
- `ufficcio_bill_analyses`: bill analyzer outputs
- `ufficcio_proof_cases` / `ufficcio_proof_items`: complaint/dispute evidence
- `ufficcio_user_checklist_state`: per-user checklist completion state
- `ufficcio_community_templates`: local/submitted template drafts
- `ufficcio_usage_events`: privacy-safe analytics
- `ufficcio_feedback`: feedback inbox
- `ufficcio_entitlements`: free/pro/consultant/admin readiness
- `ufficcio_sync_log`: sync attempts/failures
- `ufficcio_delete_requests`: remote deletion tracking

## Global catalog tables

- `ufficcio_checklist_items`
- `ufficcio_city_packs`
- `ufficcio_official_links`
- `ufficcio_template_overrides`
- `ufficcio_admin_config`

## Sensitive data warning

Generated message bodies, profile data, and document metadata may contain sensitive personal information.
Never expose these tables publicly.

## RLS summary

- user-owned tables: `user_id = auth.uid()`
- global catalogs: authenticated read-only on active rows
- admin config/template writes: admin-only

## Local-to-remote mapping

The Flutter app stays local-first.
Remote rows use:
- `id` as remote primary key
- `local_id` for local mapping/readiness
- `updated_at`
- `deleted_at` for soft delete readiness
