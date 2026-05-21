# Account deletion support

Public deletion support URL:

- `https://ufficio-facile.vercel.app/account-deletion`

## In-app self-service deletion

UfficioFacile now provides a self-service account deletion flow inside the app:

1. Open the app.
2. Open `Profile`.
3. Find the `Account and privacy` section.
4. Tap `Delete my account`.
5. Type `DELETE`.
6. Tap `Delete my account` again to confirm.

Users can also tap `Profile` -> `Account and privacy` -> `Privacy center` if they want to review sync or local-data controls before deleting the account.

If the deletion succeeds:

- the app calls the authenticated Supabase Edge Function
- user-owned app data is deleted where legally possible
- local app data is cleared
- the user is signed out

## Email fallback

If in-app deletion is unavailable, blocked, or fails, the user can still request deletion by email:

- Email: `support@ufficiofacile.app`
- Suggested subject: `UfficioFacile account deletion request`
- Visible app path: `Profile` -> `Account and privacy` -> `Request deletion by email`

Suggested body:

```text
Account email:
Full name:
Request:
Please delete my UfficioFacile account and associated app data where legally possible.
```

## Data covered

The deletion flow is intended to cover the user's account and associated app data where legally possible, including:

- account records
- profile data
- saved requests
- problem-request data
- consultancy-request data
- reminder and workflow data
- synced app data tied to the account

## Data that may be retained in limited form

Some records may need to be retained, detached from the deleted user where possible, for reasons such as:

- payment reconciliation
- invoice or tax obligations
- fraud prevention
- security review
- minimal audit trail for account deletion processing

Payment card numbers are handled by Stripe and are not stored directly by the app.

## Security note

The self-service deletion flow is server-side only. The Flutter client does not contain a Supabase service-role key and does not accept arbitrary user IDs for deletion. The Edge Function verifies the authenticated user and deletes the Supabase Auth user last.

## Play Console note

For Google Play disclosures:

- point the account deletion URL to `https://ufficio-facile.vercel.app/account-deletion`
- describe both the self-service in-app deletion path and the email fallback
- make sure the privacy policy and Data Safety answers match the final deployed behavior
