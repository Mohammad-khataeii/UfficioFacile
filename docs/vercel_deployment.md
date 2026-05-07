# Vercel Deployment

1. Push the repo to GitHub.
2. In Vercel, create a new project.
3. Import the `UfficioFacile` repository.
4. Choose the `Other` framework preset.
5. Build command: `bash ./tool/vercel_build.sh`
6. Output directory: `build/web`
7. Add environment variables:
   - `UFFICCIOFACILE_BACKEND_MODE=supabase`
   - `SUPABASE_URL=https://oyqyooxtqfabzsehsbhr.supabase.co`
   - `SUPABASE_ANON_KEY=your anon/publishable key`
   - `UFFICCIOFACILE_ENABLE_SYNC=true`
   - `UFFICCIOFACILE_ENABLE_ADMIN_DEBUG=false`
   - `UFFICCIOFACILE_ENABLE_BETA_MODE=true`
   - `UFFICCIOFACILE_ENABLE_PAYWALL=true`
   - `UFFICCIOFACILE_ENABLE_ANALYTICS=true`
8. Deploy.
9. In Supabase Auth, create at least one user manually in the dashboard or sign up once in the app.
10. Seed the first owner with `supabase/seed_admin.sql` in the Supabase SQL Editor.
11. If you use password reset or email links, add your Vercel URLs to Supabase Auth redirect URLs:
   - `https://your-domain.vercel.app`
   - `https://your-domain.vercel.app/auth/callback`
12. If Stripe payments are enabled, also set:
   - `STRIPE_SECRET_KEY`
   - `STRIPE_WEBHOOK_SECRET`
   - `STRIPE_PREMIUM_PRICE_ID`
   - `SUPABASE_SERVICE_ROLE_KEY`
   - `APP_BASE_URL`
13. Redeploy and smoke test signup, login, premium state, admin visibility, language switch, and private-route gating.

Local release build:

```bash
flutter build web --release \
  --dart-define=UFFICCIOFACILE_BACKEND_MODE=supabase \
  --dart-define=SUPABASE_URL=https://oyqyooxtqfabzsehsbhr.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_PUBLIC_KEY \
  --dart-define=UFFICCIOFACILE_ENABLE_SYNC=true \
  --dart-define=UFFICCIOFACILE_ENABLE_ADMIN_DEBUG=false \
  --dart-define=UFFICCIOFACILE_ENABLE_BETA_MODE=true \
  --dart-define=UFFICCIOFACILE_ENABLE_PAYWALL=true \
  --dart-define=UFFICCIOFACILE_ENABLE_ANALYTICS=true
```
