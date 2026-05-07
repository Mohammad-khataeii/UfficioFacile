# UfficcioFacile Sync Strategy

## Model

The app is local-first.
Supabase is an optional sync backend.

## Sync states

- `localOnly`
- `disabled`
- `unavailable`
- `syncing`
- `synced`
- `failed`
- `conflict`

## Conflict strategy

Current MVP strategy:
- latest `updated_at` wins
- local deletion should propagate as remote soft delete
- remote deletion should be reflected locally as soft delete
- sync attempts should write to sync log

## Triggering sync

- manual sync button
- future app-start sync when configured and authenticated

## Future realtime sync

Realtime can be added later after:
- stable auth
- better conflict UI
- careful privacy review
