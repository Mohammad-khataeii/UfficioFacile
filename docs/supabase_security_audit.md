# Supabase Security Audit

Last updated: 2026-05-12

## Scope

This audit summarizes the public tables, RLS posture, helper functions, and manual checks relevant to the current UfficioFacile Flutter app, admin app, CMS, and premium runtime.

## Key findings

- Legacy `ufficcio_*` user-data tables already have broad own-row RLS from `20260506091000_create_ufficciofacile_rls.sql`.
- Newer `ufficio_*` premium/CMS/public-catalog tables also have RLS and admin/public policies spread across the later `20260507*`, `20260508*`, `20260510*`, and `20260512*` migrations.
- Premium-critical tables are now intended to be server-backed:
  - `public.ufficio_user_entitlements`
  - `public.ufficio_premium_events`
  - `public.ufficio_plan_products`
  - `public.ufficio_user_content_unlocks`
  - `public.ufficio_usage_counters`
- Stripe webhook idempotency now relies on unique `stripe_event_id` in `public.ufficio_premium_events`.
- CMS public identity now relies on `public.ufficio_cms_procedures(category_slug, slug)`.

## Helper functions

- `public.is_ufficcio_admin()`
  - Legacy helper used by `ufficcio_*` tables.
  - Must remain compatibility-only unless the schema is fully renamed.
- `public.is_ufficio_admin()`
  - Used by newer `ufficio_*` admin, premium, CMS, and public-catalog policies.
- `public.increment_ufficio_usage_counter(text, int, uuid)`
  - `security definer`
  - fixed `search_path`
  - blocks cross-user updates unless `public.is_ufficio_admin()` is true
  - used by Flutter premium usage accounting in Supabase mode

## Table summary

### Private user data

- `public.ufficcio_profiles`
- `public.ufficcio_user_settings`
- `public.ufficcio_requests`
- `public.ufficcio_generated_packs`
- `public.ufficcio_status_events`
- `public.ufficcio_reminders`
- `public.ufficcio_documents`
- `public.ufficcio_contacts`
- `public.ufficcio_household_members`
- `public.ufficcio_household_contracts`
- `public.ufficcio_utility_comparisons`
- `public.ufficcio_bill_analyses`
- `public.ufficcio_proof_cases`
- `public.ufficcio_proof_items`
- `public.ufficcio_feedback`
- `public.ufficcio_sync_log`
- `public.ufficcio_delete_requests`

Expected posture:

- RLS enabled
- authenticated users limited to own `user_id`
- admin read policies added separately where intended

### Premium and payments

- `public.ufficio_user_entitlements`
- `public.ufficio_premium_events`
- `public.ufficio_plan_products`
- `public.ufficio_user_content_unlocks`
- `public.ufficio_usage_counters`
- `public.ufficio_payment_events`
- `public.ufficio_consultancy_payments`

Expected posture:

- `ufficio_plan_products`
  - public read for active products
  - admin-only write
- `ufficio_user_entitlements`
  - user read own row
  - no direct user write
  - admin/service writes only
- `ufficio_usage_counters`
  - user read own row
  - no direct user write expected in client path
  - writes via admin/service or `increment_ufficio_usage_counter(...)`
- `ufficio_user_content_unlocks`
  - user read own row
  - admin/service writes only
- `ufficio_premium_events`
  - user read own rows if desired
  - admin/service writes only

### CMS

- `public.ufficio_cms_categories`
- `public.ufficio_cms_procedures`
- `public.ufficio_cms_content_blocks`
- `public.ufficio_cms_revisions`
- `public.ufficio_cms_drafts`

Expected posture:

- RLS enabled
- public/authenticated read only on active/published content
- admin writes only
- category-aware content-block reads on `(category_slug, procedure_slug)`

### Requests

- `public.ufficio_problem_requests`
- `public.ufficio_consultancy_requests`

Expected posture:

- authenticated users can insert
- users can read own rows
- admins can read/manage all
- anon insert only if explicitly intended and rate-limited

### Public catalog/config

- `public.ufficio_official_links`
- `public.ufficio_official_contacts`
- `public.ufficio_service_providers`
- `public.ufficio_provider_forms`
- `public.ufficio_provider_contact_options`
- `public.ufficio_region_guidance`
- `public.ufficio_city_guidance`
- `public.ufficio_authority_guidance`
- `public.ufficio_procedure_guidance`
- `public.ufficio_source_references`
- `public.ufficio_service_terms`
- `public.ufficio_submission_channels`
- `public.ufficio_app_public_config`
- `public.ufficio_premium_public_config`

Expected posture:

- anon/authenticated read allowed intentionally
- admin writes only

## Indexes to verify

- `public.ufficio_cms_procedures(category_slug, slug)`
- `public.ufficio_cms_content_blocks(category_slug, procedure_slug, sort_order)`
- `public.ufficio_user_entitlements(user_id)`
- `public.ufficio_user_entitlements(status, current_period_end)`
- `public.ufficio_user_entitlements(stripe_customer_id)`
- `public.ufficio_user_entitlements(stripe_subscription_id)`
- `public.ufficio_premium_events(stripe_event_id)` unique where not null
- `public.ufficio_user_content_unlocks(user_id, category_slug, procedure_slug, status)`
- `public.ufficio_user_content_unlocks(stripe_checkout_session_id)`
- `public.ufficio_user_content_unlocks(stripe_payment_intent_id)`
- `public.ufficio_usage_counters(user_id, period_key)`

## Manual SQL checks

RLS enabled on the critical tables:

```sql
select schemaname, tablename, rowsecurity
from pg_tables
where schemaname = 'public'
  and tablename in (
    'ufficio_user_entitlements',
    'ufficio_premium_events',
    'ufficio_plan_products',
    'ufficio_user_content_unlocks',
    'ufficio_usage_counters',
    'ufficio_problem_requests',
    'ufficio_consultancy_requests',
    'ufficio_cms_categories',
    'ufficio_cms_procedures',
    'ufficio_cms_content_blocks',
    'ufficio_cms_drafts',
    'ufficio_cms_revisions'
  )
order by tablename;
```

Policies on critical premium/CMS tables:

```sql
select schemaname, tablename, policyname, permissive, roles, cmd
from pg_policies
where schemaname = 'public'
  and tablename in (
    'ufficio_user_entitlements',
    'ufficio_premium_events',
    'ufficio_plan_products',
    'ufficio_user_content_unlocks',
    'ufficio_usage_counters',
    'ufficio_cms_categories',
    'ufficio_cms_procedures',
    'ufficio_cms_content_blocks',
    'ufficio_problem_requests',
    'ufficio_consultancy_requests'
  )
order by tablename, policyname;
```

Security-definer helpers:

```sql
select n.nspname as schema_name,
       p.proname as function_name,
       p.prosecdef as security_definer
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'public'
  and p.proname in (
    'is_ufficcio_admin',
    'is_ufficio_admin',
    'increment_ufficio_usage_counter'
  )
order by p.proname;
```

Duplicate CMS public identity:

```sql
select category_slug, slug, count(*)
from public.ufficio_cms_procedures
group by category_slug, slug
having count(*) > 1
order by count(*) desc, category_slug, slug;
```

Duplicate Stripe events:

```sql
select stripe_event_id, count(*)
from public.ufficio_premium_events
where stripe_event_id is not null
group by stripe_event_id
having count(*) > 1;
```

Unlocks must stay category-aware:

```sql
select user_id, category_slug, procedure_slug, status, count(*)
from public.ufficio_user_content_unlocks
group by user_id, category_slug, procedure_slug, status
having count(*) > 1
order by count(*) desc;
```

## Remaining manual verification

- Run the SQL checks above against the linked production or staging project.
- Confirm `is_ufficio_admin()` and `is_ufficcio_admin()` both resolve correctly for the actual admin table data.
- Confirm Stripe webhook delivery inserts one `ufficio_premium_events` row per Stripe event id.
- Confirm the Flutter client cannot directly mutate premium/unlock state through anon/authenticated policies.
- Confirm problem/consultancy request anon behavior matches the intended product policy before public launch.
