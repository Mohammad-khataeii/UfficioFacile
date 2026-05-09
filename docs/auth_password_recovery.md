# Auth Password Recovery

UfficioFacile now supports:

- forgot password from the login screen
- reset password from a Supabase recovery link
- change password from the account/profile area

## How it works

1. From login, open `Forgot password?`
2. Enter the account email
3. The app calls Supabase `resetPasswordForEmail`
4. The reset link sends the user back to the app reset-password route
5. The user sets a new password
6. Logged-in users can also open `Change password` from the account/profile area

This flow is informational and UI-only on the client side. Supabase Auth remains the source of truth for sessions and password updates.

## Required Supabase redirect URLs

Production site URL:

- `https://ufficio-facile.vercel.app`

Redirect URLs to allow in Supabase Auth:

- `https://ufficio-facile.vercel.app/auth/reset-password`
- `https://ufficio-facile.vercel.app/auth/callback`
- `http://localhost:3000/auth/reset-password`
- `http://localhost:3000/auth/callback`
- `http://localhost:5173/auth/reset-password`
- `http://localhost:5173/auth/callback`

Use the local port that matches your dev server if it differs.

## Routes

- `/auth/forgot-password`
- `/auth/reset-password`
- `/account/change-password`

## Local testing

1. Start the app locally
2. Open the auth screen
3. Tap `Forgot password?`
4. Send a reset email for a test account
5. Open the Supabase email link
6. Confirm the app lands on the reset-password screen
7. Set a new password
8. Sign in with the new password
9. Open account/profile and test `Change password`

## Production note

The reset redirect is built from the current web origin when possible. If the app is opened from production, it should resolve to:

- `https://ufficio-facile.vercel.app/auth/reset-password`

## Known limitations

- Payments and billing are separate from password recovery
- If the local dev origin changes, the matching reset-password URL must also be added in Supabase
- Deep-link handling is currently routed through the app entry flow and the reset-password path
