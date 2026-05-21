# Reviewer instructions draft

This draft is intended for the Google Play App Access section and should be updated before submission.

## Test account

- email: `play-reviewer@ufficiofacile.app`
- password: `CHANGE_ME_BEFORE_SUBMISSION`

## Reviewer flow

1. Open UfficioFacile.
2. Tap `Login` and sign in with the reviewer account above, or create a new account if the reviewer account is unavailable.
3. Browse a free category from the dashboard and open a public guidance screen.
4. Open `Account` and then `Privacy center`.
5. Return to the dashboard and open a protected or profile-related feature that requires sign-in.
6. Open the premium or paywall screen to review monetization behavior.
7. If live checkout is unavailable in the review environment, use the fallback note below.

## What is free

- Browsing public categories and public guidance
- Basic account access
- Privacy center access

## What is premium

- Premium guidance and deeper locked content
- Premium/paywall flows
- Related entitlement-based access behavior

## How to test paywall without making a real payment

- If a pre-granted reviewer premium account is provided, sign in and confirm premium content unlocks correctly.
- If checkout is intentionally disabled for review, open the paywall and confirm the app shows the premium access boundary without crashing.

## Premium fallback note

If live checkout is disabled during review, provide one of these before submission:

- a reviewer account with a pre-granted premium entitlement
- a clear note explaining that checkout is disabled in the review environment and that the reviewer should expect the paywall UI but not a completed purchase flow

If Stripe live or test checkout is not available in the review environment, the reviewer should still be able to:

- sign in
- browse free content
- open the premium screen
- see how locked premium content is presented

## Support contact

- `support@ufficiofacile.app`

## Important reviewer note

UfficioFacile is not a public authority and does not replace official administrative guidance, legal advice, or direct assistance from public offices.
