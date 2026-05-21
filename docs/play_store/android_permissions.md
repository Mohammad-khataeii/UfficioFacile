# Android permissions audit

## Present permissions

`android.permission.INTERNET`

- Needed for Supabase authentication, remote content/config loading, Stripe checkout handoff, and general web/API communication.

`android.permission.POST_NOTIFICATIONS`

- Needed so the app can request permission for reminders and notifications.
- This permission should only be requested when the app is about to use reminder or notification features.

## Sensitive permissions not currently declared

The Android manifest does not currently request:

- location
- camera
- microphone
- contacts
- external storage read/write

That is the intended release state unless future features explicitly require more access.

## Release expectation

Before each Play upload, confirm the manifest still contains only the permissions the shipped feature set truly needs.
