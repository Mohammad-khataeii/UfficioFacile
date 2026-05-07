# UfficcioFacile Privacy And Security

## What is stored

Potentially sensitive local or synced data includes:
- profile fields
- saved requests
- generated pack text
- reminders
- document metadata
- contacts
- household members
- proof folder metadata

## What is not logged

Analytics must not include:
- full names
- codice fiscale
- email bodies
- generated letters
- bill details
- document names
- complaint narratives
- contract/account numbers

## Local vs sync

- local-only remains the default fallback
- Supabase sync is optional
- sync should require authenticated user + enabled setting

## Analytics policy

Only privacy-safe metadata should be recorded.
Large or nested payloads should be stripped.

## Export and deletion

The app supports local export and local wipe readiness.
Remote deletion should stay user-scoped and logged.

## Storage caution

Sensitive file upload should stay disabled by default until private storage buckets and signed URL handling are fully verified.
