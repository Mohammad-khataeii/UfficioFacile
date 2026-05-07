# UfficcioFacile Supabase Edge Functions Plan

Edge Functions are not required for the current MVP.

## Good future candidates

- `create-entitlement`
- `validate-subscription`
- `delete-user-data`
- `aggregate-analytics`
- `template-review`
- `send-feedback-notification`

## Why keep them server-side

- subscription verification must not trust mobile clients
- destructive deletion workflows should be audited
- analytics aggregation should avoid exposing raw user tables

## Important

Do not place service-role keys in the Flutter app.
