# Production Deployment

## Flutter web production build

```bash
flutter build web \
  --release \
  --dart-define=UFFICCIOFACILE_BACKEND_MODE=supabase \
  --dart-define=UFFICCIOFACILE_FLAVOR=production \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=... \
  --dart-define=UFFICCIOFACILE_ENABLE_PAYWALL=true \
  --dart-define=UFFICCIOFACILE_ENABLE_BETA_MODE=false
```

Notes:

- Production Supabase builds now fail loud if `SUPABASE_URL` or `SUPABASE_ANON_KEY` is missing.
- Do not enable local debug premium or local fallback flags in production.
- Keep `SUPABASE_SERVICE_ROLE_KEY` out of Flutter builds completely.

## Flutter mobile

- Confirm the final iOS bundle identifier before App Store/TestFlight release.
- Confirm the final Android application ID before Play/internal release.
- Add Supabase auth redirect URLs for mobile and web callback targets.
- Add password reset redirect URLs that point to the deployed web/app reset flow.
- Recheck `url_launcher` and checkout return URLs on iOS and Android after release signing.

## Next.js admin on Vercel

- Root directory: `apps/admin`
- Install command: `npm install`
- Build command: `npm run build`

Required environment variables:

- `NEXT_PUBLIC_SUPABASE_URL`
- `NEXT_PUBLIC_SUPABASE_ANON_KEY`
- `SUPABASE_SERVICE_ROLE_KEY`
- `APP_BASE_URL`
- `STRIPE_SECRET_KEY`
- `STRIPE_WEBHOOK_SECRET`

If plan products depend on explicit Stripe prices:

- populate `stripe_price_id` in `ufficio_plan_products`
- or provide equivalent admin-managed product metadata before exposing checkout buttons

## Supabase

Install or make the Supabase CLI available first. In this workspace the command was not installed.

Typical commands:

```bash
supabase link --project-ref <project-ref>
supabase migration list
supabase db push --dry-run
supabase db push
supabase functions deploy create-checkout-session
supabase functions deploy stripe-webhook
```

Required secrets:

```bash
supabase secrets set SUPABASE_URL=...
supabase secrets set SUPABASE_SERVICE_ROLE_KEY=...
supabase secrets set STRIPE_SECRET_KEY=...
supabase secrets set STRIPE_WEBHOOK_SECRET=...
supabase secrets set APP_BASE_URL=...
```

Important:

- `supabase/config.toml` now requires:

```toml
[functions.stripe-webhook]
verify_jwt = false
```

- `create-checkout-session` must remain authenticated.
- `stripe-webhook` must remain public and must verify the Stripe signature from the raw request body.

## Stripe webhook setup

- Endpoint: `https://<project-ref>.functions.supabase.co/stripe-webhook`
- Configure at minimum:
  - `checkout.session.completed`
  - `customer.subscription.created`
  - `customer.subscription.updated`
  - `customer.subscription.deleted`
  - `invoice.payment_succeeded`
  - `invoice.payment_failed`
  - `payment_intent.succeeded`
- Confirm webhook delivery succeeds before enabling live billing.
- Confirm duplicate event delivery leaves entitlement state unchanged except for a single logged event row.

## Post-deploy checklist

- Admin login works.
- Owner/admin user exists.
- `/content` opens.
- No duplicate React key warnings appear on content pages.
- Procedure detail opens on `/content/procedures/{categorySlug}/{procedureSlug}`.
- Category-aware CMS blocks render the correct procedure detail.
- Flutter signup/login works.
- Password reset works.
- Language switching works.
- Premium checkout opens Stripe Checkout.
- Stripe webhook updates `ufficio_user_entitlements`.
- Premium badge stays stable after refresh.
- Expired or revoked entitlement blocks premium content.
- Free limits block correctly.
- Single unlock works only for the exact `category_slug + procedure_slug`.
- Problem request reaches admin.
- Consultancy request reaches admin.
- Run the manual SQL checks from `docs/supabase_security_audit.md`.
