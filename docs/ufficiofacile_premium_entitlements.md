# UfficioFacile Premium Entitlements

UfficioFacile now includes a local-first premium system with Free, Pro, and Consultant-ready plans.

## Current behavior

- Free is the default plan
- Pro can be activated locally for admin/debug testing
- Consultant is marked as coming soon
- beta mode can keep premium tools visible and temporarily accessible
- paywall mode can enforce limits without requiring login

## Security note

Client-side Pro is only for local testing and UX readiness. It is not a secure payment proof.

Real payment activation must be verified server-side when App Store, Play Store, Stripe, or another payment provider is added later.

## Persistence

- `ufficiofacile_premium_config_v1`
- `ufficcio_entitlement_v1`

## Future Supabase use

If Supabase entitlements are used later, the remote table should remain read-only for normal clients and server-controlled for real plan changes.
