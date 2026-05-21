# Account deletion support

## Current supported path

UfficioFacile currently supports account deletion requests through an in-app route:

1. Open the app.
2. Open `Account`.
3. Tap `Privacy center`.
4. Tap `Request account deletion`.
5. Send the generated email request to `support@ufficiofacile.app`.

The app also allows users to clear local app data separately with the `Delete local data` action in the privacy center.

## Important limitation

This is a support-based deletion request flow, not a client-side self-delete action. That is intentional: the mobile app must not contain elevated credentials or unsafe direct-delete logic such as a Supabase service-role account deletion path.

## Play Console note

If account creation is enabled in the submitted build, the published privacy policy and Play Console account deletion disclosures should point to this in-app request flow until a verified self-service deletion flow exists.
