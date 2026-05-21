# Android permissions audit

## Present permissions

`android.permission.INTERNET`

- Needed for Supabase authentication, official links, Stripe checkout handoff, web or admin-backed content, and general API communication.

`android.permission.POST_NOTIFICATIONS`

- Needed so the app can request permission for reminders, deadlines, checklists, and premium-expiry related notifications.
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

## Manual permission test

1. Install the app on Android 13 or higher.
2. Open the notifications or reminders-related screen.
3. Trigger the notification permission request.
4. Deny the permission once.
5. Confirm the app does not crash and continues working without notification access.
