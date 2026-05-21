# Auth password recovery and email confirmation

UfficioFacile supports:

- sign-up email confirmation
- forgot password from the login screen
- password reset from a recovery link
- password change from the account area

## Redirect URLs to allow in Supabase

Native deep links:

- `ufficiofacile://auth/confirm-email`
- `ufficiofacile://auth/reset-password`

Web callbacks:

- `https://ufficio-facile.vercel.app/auth/confirm-email-callback`
- `https://ufficio-facile.vercel.app/auth/reset-password-callback`
- `http://localhost:3000/auth/confirm-email-callback`
- `http://localhost:3000/auth/reset-password-callback`
- `http://localhost:5173/auth/confirm-email-callback`
- `http://localhost:5173/auth/reset-password-callback`

Use the local port that matches your actual development server.

## Current flow

- On mobile and web, the app currently generates web callback URLs for signup confirmation and password reset emails.
- The Android app also declares native deep links for `ufficiofacile://auth/confirm-email` and `ufficiofacile://auth/reset-password`.
- Keep both the native deep links and the web callback URLs allowed in Supabase so browser fallback and same-device flows both remain valid.

## Android deep-link expectations

The Android manifest is configured to accept:

- `ufficiofacile://auth/confirm-email`
- `ufficiofacile://auth/reset-password`

## Manual test checklist

1. Sign up from Android.
2. Open the confirmation email on the same phone.
3. Confirm the app can complete the confirmation flow.
4. Trigger password reset from Android.
5. Open the reset email on the same phone.
6. Confirm the app lands on the reset-password flow.
7. Open the web fallback callback URL in a browser and confirm the fallback flow still works.
