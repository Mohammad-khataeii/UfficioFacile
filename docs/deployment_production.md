# Production Deployment

This document separates the live deployment work by surface:

- Flutter web
- Next.js admin
- Supabase
- Android Google Play release

Do not ship the Android app to production until internal testing, Play pre-launch checks, and live Supabase/Stripe payment validation have all passed.

## Flutter web deployment

```bash
/usr/local/share/flutter/bin/flutter build web \
  --release \
  --dart-define=UFFICCIOFACILE_FLAVOR=production \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=... \
  --dart-define=UFFICCIOFACILE_ENABLE_PAYWALL=true \
  --dart-define=UFFICCIOFACILE_ENABLE_BETA_MODE=false
```

Notes:

- Production Supabase builds fail loudly if `SUPABASE_URL` or `SUPABASE_ANON_KEY` is missing.
- Keep `SUPABASE_SERVICE_ROLE_KEY` out of Flutter builds completely.
- Do not enable local fallback or local debug premium flags in production.

## Next.js admin deployment

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

## Supabase deployment

Typical commands:

```bash
supabase link --project-ref <project-ref>
supabase migration list
supabase db push --dry-run
supabase db push
supabase functions deploy create-checkout-session
supabase functions deploy stripe-webhook
supabase functions deploy delete-account
```

Required secrets:

```bash
supabase secrets set SUPABASE_URL=...
supabase secrets set SUPABASE_SERVICE_ROLE_KEY=...
supabase secrets set STRIPE_SECRET_KEY=...
supabase secrets set STRIPE_WEBHOOK_SECRET=...
supabase secrets set APP_BASE_URL=...
```

Important runtime requirements:

- `create-checkout-session` must remain authenticated.
- `delete-account` must remain authenticated and must never trust a client-supplied user ID.
- `stripe-webhook` must remain public and must verify the Stripe signature from the raw request body.
- `supabase/config.toml` must keep:

```toml
[functions.stripe-webhook]
verify_jwt = false

[functions.delete-account]
verify_jwt = true
```

### Stripe webhook setup

- Endpoint: `https://<project-ref>.functions.supabase.co/stripe-webhook`
- Required events:
  - `checkout.session.completed`
  - `customer.subscription.created`
  - `customer.subscription.updated`
  - `customer.subscription.deleted`
  - `invoice.payment_succeeded`
  - `invoice.payment_failed`
  - `payment_intent.succeeded`

### Supabase and Stripe manual production checks

Run these before any production mobile rollout:

1. Login works with Supabase Auth.
2. Checkout opens from the app.
3. Stripe payment succeeds.
4. The webhook is received successfully.
5. `ufficio_user_entitlements` updates correctly.
6. Premium content unlock persists after app restart.
7. Expired or revoked entitlement blocks premium content again.

The Android release is not ready for production until the live Stripe and Supabase flow has been tested in at least internal testing.

### Manual account deletion test

1. Create a test user.
2. Add profile, request, reminder, or connected-tool data to that user.
3. Open the app and sign in as the test user.
4. Open `Profile`.
5. Confirm the `Account and privacy` section is visible and shows the signed-in email.
6. Open `Delete my account`.
7. Confirm the destructive action stays disabled until `DELETE` is typed.
8. Tap `Request deletion by email` and confirm the email fallback opens correctly.
9. Return to `Profile` -> `Account and privacy` and complete the self-service deletion flow.
10. Confirm the app signs out and starts safely afterward.
11. Confirm the Supabase Auth user is removed.
12. Confirm user-owned profile and request rows are deleted, and retained payment or audit rows are detached or anonymized as expected.
13. Confirm the email support fallback still opens correctly if the self-service flow fails.

## Android Google Play deployment

Final Android package:

- `it.ufficiofacile.app`

Release build prerequisites:

1. Generate an upload keystore locally and do not commit it:

```bash
keytool -genkeypair \
  -v \
  -keystore /absolute/path/to/upload-keystore.jks \
  -alias upload \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000
```

2. Create `android/key.properties` from `android/key.properties.example`, or export:
   - `ANDROID_KEYSTORE_PATH`
   - `ANDROID_KEYSTORE_PASSWORD`
   - `ANDROID_KEY_ALIAS`
   - `ANDROID_KEY_PASSWORD`

3. Decide whether ads are enabled for the release.

If ads are enabled, provide:

- `UFFICIOFACILE_ADMOB_APP_ID_ANDROID`
- `UFFICIOFACILE_ADMOB_BANNER_ANDROID`
- `UFFICIOFACILE_ADMOB_INTERSTITIAL_ANDROID`

If ads are not enabled yet, leave the AdMob production defines unset. Production builds now disable ads instead of using Google test IDs.

### Android internal testing bundle command

```bash
/usr/local/share/flutter/bin/flutter build appbundle \
  --release \
  --dart-define=UFFICCIOFACILE_FLAVOR=production \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=... \
  --dart-define=UFFICCIOFACILE_ENABLE_PAYWALL=true \
  --dart-define=UFFICCIOFACILE_ENABLE_BETA_MODE=false
```

If ads are enabled, append:

```bash
  --dart-define=UFFICIOFACILE_ADMOB_APP_ID_ANDROID=ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy \
  --dart-define=UFFICIOFACILE_ADMOB_BANNER_ANDROID=ca-app-pub-xxxxxxxxxxxxxxxx/zzzzzzzzzz \
  --dart-define=UFFICIOFACILE_ADMOB_INTERSTITIAL_ANDROID=ca-app-pub-xxxxxxxxxxxxxxxx/aaaaaaaaaa
```

### Android release verification

```bash
/usr/local/share/flutter/bin/dart run tool/google_play_release_doctor.dart
cd android
./gradlew printAndroidReleaseInfo
```

Check the output confirms:

- `applicationId=it.ufficiofacile.app`
- `namespace=it.ufficiofacile.app`
- `targetSdk >= 35`
- `releaseSigningConfigured=true`

### Auth redirect URLs to allow in Supabase

Native deep links:

- `ufficiofacile://auth/confirm-email`
- `ufficiofacile://auth/reset-password`

Web callback URLs:

- `https://<production-web-domain>/auth/confirm-email-callback`
- `https://<production-web-domain>/auth/reset-password-callback`

Recommended production web domain today:

- `https://ufficio-facile.vercel.app`

That means the current production callback set is:

- `ufficiofacile://auth/confirm-email`
- `ufficiofacile://auth/reset-password`
- `https://ufficio-facile.vercel.app/auth/confirm-email-callback`
- `https://ufficio-facile.vercel.app/auth/reset-password-callback`

Current flow behavior:

- the mobile app generates web callback URLs for signup confirmation and password reset emails
- the Android manifest also accepts the native deep links above
- keep both web and native URLs allowed in Supabase so same-device and fallback browser flows both work

### Android auth redirect manual checks

1. Sign up from the Android app.
2. Open the confirmation email on the same Android phone.
3. Confirm the app can complete the email confirmation flow.
4. Trigger password reset from Android.
5. Open the reset email on the same Android phone.
6. Confirm the app can land on the reset-password flow.
7. Open the fallback web callback URL from a browser and confirm the web flow still works.

### Play Console checklist

The release cannot move forward until these docs are prepared and reviewed:

- `docs/play_store/google_play_release_checklist.md`
- `docs/play_store/privacy_policy_draft.md`
- `docs/play_store/data_safety_draft.md`
- `docs/play_store/reviewer_instructions.md`
- `docs/play_store/store_listing_draft.md`
- `docs/play_store/account_deletion.md`
- `docs/play_store/android_permissions.md`
- `docs/play_store/local_signing_step_by_step.md`
- `docs/play_store/play_console_copy.md`
- `docs/play_store/final_submission_checklist.md`

Public URLs for Play Console:

- Privacy policy: [https://ufficio-facile.vercel.app/privacy](https://ufficio-facile.vercel.app/privacy)
- Account deletion: [https://ufficio-facile.vercel.app/account-deletion](https://ufficio-facile.vercel.app/account-deletion)

## iOS TestFlight / App Store deployment

Final iOS bundle identifier:

- `it.ufficiofacile.app`

Repository-side iOS prerequisites:

1. Keep the URL scheme `ufficiofacile`.
2. Keep the public privacy URL at [https://ufficio-facile.vercel.app/privacy](https://ufficio-facile.vercel.app/privacy).
3. Keep the public account deletion URL at [https://ufficio-facile.vercel.app/account-deletion](https://ufficio-facile.vercel.app/account-deletion).
4. If ads are enabled on iOS, create a local untracked `ios/Flutter/AdMob.local.xcconfig` with:

```xcconfig
ADMOB_APPLICATION_ID_IOS=ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy
```

Verification and build commands:

```bash
/usr/local/share/flutter/bin/dart run tool/apple_release_doctor.dart
/usr/local/share/flutter/bin/flutter build ipa \
  --release \
  --dart-define=UFFICCIOFACILE_FLAVOR=production \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=... \
  --dart-define=UFFICCIOFACILE_ENABLE_PAYWALL=true \
  --dart-define=UFFICCIOFACILE_ENABLE_BETA_MODE=false
```

Optional iOS ad unit Dart defines:

```bash
  --dart-define=UFFICIOFACILE_ADMOB_BANNER_IOS=ca-app-pub-xxxxxxxxxxxxxxxx/zzzzzzzzzz \
  --dart-define=UFFICIOFACILE_ADMOB_INTERSTITIAL_IOS=ca-app-pub-xxxxxxxxxxxxxxxx/aaaaaaaaaa
```

Manual iOS deletion and deep-link checks:

1. Install the TestFlight or debug build on an iPhone.
2. Open [https://ufficio-facile.vercel.app/privacy](https://ufficio-facile.vercel.app/privacy) on the same device.
3. Tap `Open the installed app` and confirm the app opens to `Profile`.
4. Open `Profile` -> `Account and privacy`.
5. Confirm `Delete my account` stays disabled until `DELETE` is typed.
6. Confirm `Request deletion by email` opens Mail.
7. Confirm sign-in, checkout, reminders, and password reset still work on iOS.

These public pages are currently provided as static Flutter web assets from:

- `web/privacy/index.html`
- `web/account-deletion/index.html`

## Before upload run this

```bash
dart format lib test tool
flutter pub get
flutter analyze
flutter test
dart run tool/content_doctor.dart
dart run tool/localization_doctor.dart
dart run tool/google_play_release_doctor.dart
dart run tool/print_google_play_commands.dart
cd android && ./gradlew printAndroidReleaseInfo && cd ..
/usr/local/share/flutter/bin/flutter build appbundle \
  --release \
  --dart-define=UFFICCIOFACILE_FLAVOR=production \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=... \
  --dart-define=UFFICCIOFACILE_ENABLE_PAYWALL=true \
  --dart-define=UFFICCIOFACILE_ENABLE_BETA_MODE=false
```
