# Premium System

## Public product levels

- Free
- Plus
- Premium
- Single guide unlock
- One-shot consultancy

## Visibility rule

Premium categories and procedures must remain visible to everyone.

- Free users see previews, teasers, badges, and locked states
- Free users do not get full premium content
- Full access is allowed only through:
  - Plus or Premium where configured
  - single guide unlock for that exact procedure
  - admin grant

## Supabase tables

Premium-related tables are created and hardened by migrations under `supabase/migrations`, including:

- `ufficio_plan_products`
- `ufficio_user_entitlements`
- `ufficio_usage_counters`
- `ufficio_premium_events`
- `ufficio_payment_events`
- `ufficio_user_content_unlocks`
- `ufficio_consultancy_payments`

## Missing-table resilience

Admin `/premium` should not crash when premium tables are missing.

- Missing-table errors such as `PGRST205` are converted into warnings
- The page still renders and tells the operator to run the latest migrations

## Schema cache note

If Supabase still reports a table missing after a migration:

1. wait a moment for PostgREST schema refresh
2. restart the local admin dev server
3. verify the table in the Supabase SQL editor
