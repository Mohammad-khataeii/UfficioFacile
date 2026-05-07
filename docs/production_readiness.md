# Production Readiness

## Required environment variables

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `UFFICCIOFACILE_BACKEND_MODE=supabase`
- `UFFICCIOFACILE_ENABLE_SYNC=true`
- `UFFICCIOFACILE_ENABLE_ADMIN_DEBUG=false`
- `UFFICCIOFACILE_ENABLE_BETA_MODE=true|false`
- `UFFICCIOFACILE_ENABLE_PAYWALL=true|false`
- `UFFICCIOFACILE_ENABLE_ANALYTICS=true|false`

## Supabase migrations

```bash
supabase db push
```

## Admin seed

```bash
supabase db push
```

Then run the SQL from `supabase/seed_admin.sql` in the Supabase SQL Editor.

## Seed the first owner

1. Create the Auth user in Supabase Auth, or sign up once in the app.
2. Open `supabase/seed_admin.sql`.
3. Replace `YOUR_AUTH_USER_ID` and `YOUR_EMAIL`.
4. Run the SQL in the Supabase SQL Editor.

## RLS verification SQL

```sql
select schemaname, tablename, rowsecurity
from pg_tables
where schemaname = 'public'
  and (tablename like 'ufficio_%' or tablename like 'ufficcio_%')
order by tablename;

select schemaname, tablename, policyname, cmd, qual, with_check
from pg_policies
where schemaname = 'public'
  and (tablename like 'ufficio_%' or tablename like 'ufficcio_%')
order by tablename, policyname;
```

## Stripe / premium

- Deploy `supabase/functions/create-checkout-session`
- Deploy `supabase/functions/stripe-webhook`
- Set:
  - `STRIPE_SECRET_KEY`
  - `STRIPE_WEBHOOK_SECRET`
  - `STRIPE_PREMIUM_PRICE_ID`
  - `APP_BASE_URL`
  - `SUPABASE_URL`
  - `SUPABASE_SERVICE_ROLE_KEY`

## Smoke test

- Public catalog loads without login.
- Sign up works.
- Login works.
- Private routes show auth gate when logged out.
- Owner admin can open `/life-admin/admin`.
- Normal user is denied.
- Premium grants update from Supabase entitlement state.
- Language switch works for `en`, `it`, `fa`, `fr`.

## Rollback strategy

- Revert the last deployment in Vercel.
- Revert the last Git commit if needed.
- If a migration is bad, add a corrective migration instead of editing an applied migration.
