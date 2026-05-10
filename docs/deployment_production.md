# Production Deployment

## Flutter Web

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

- Production Supabase builds now fail loud when `SUPABASE_URL` or `SUPABASE_ANON_KEY` is missing.
- Do not enable `UFFICCIOFACILE_ALLOW_LOCAL_FALLBACK` for production builds.

## Flutter Mobile

- Confirm iOS bundle identifier and Android application ID are final before release.
- Add Supabase auth redirect URLs for sign-in and password reset.
- Confirm password reset redirect URLs match the deployed app/web destinations.

## Next.js Admin On Vercel

- Root directory: `apps/admin`
- Install command: `npm install`
- Build command: `npm run build`

Required environment variables:

- `NEXT_PUBLIC_SUPABASE_URL`
- `NEXT_PUBLIC_SUPABASE_ANON_KEY`
- `SUPABASE_SERVICE_ROLE_KEY`
- `APP_BASE_URL`

Optional when Stripe is enabled:

- `STRIPE_SECRET_KEY`
- `STRIPE_WEBHOOK_SECRET`
- `NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY`

## Supabase

- Review migrations locally before remote push.
- Run `supabase migration list`.
- Run `supabase db push --dry-run` when available.
- Confirm RLS on all client-facing tables before launch.
- Create the owner/admin user and seed `ufficio_admin_users`.

If using edge functions:

```bash
supabase functions deploy create-checkout-session
supabase functions deploy stripe-webhook
```

Required function secrets:

- `STRIPE_SECRET_KEY`
- `STRIPE_WEBHOOK_SECRET`
- `APP_BASE_URL`
- `SUPABASE_URL`
- `SUPABASE_SERVICE_ROLE_KEY`

## Stripe Webhook Setup

- Point Stripe to the deployed `stripe-webhook` endpoint.
- Verify webhook signature checking is enabled.
- Confirm webhook events are idempotent before enabling live billing.

## Post-Deploy Checklist

- Admin login works.
- Owner/admin user exists.
- `/content` opens without duplicate key warnings.
- Procedure detail routes open on `/content/procedures/{categorySlug}/{procedureSlug}`.
- Flutter app signs up and logs in.
- Language switching works.
- Premium badge remains stable after refresh.
- Free limits block correctly.
- Premium users are allowed correctly.
- Problem requests reach admin.
- Consultancy requests reach admin.
