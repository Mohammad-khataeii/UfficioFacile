# UfficcioFacile Admin Setup

## Current admin behavior

- local debug admin remains available in-app
- backend health should report local vs Supabase mode
- remote admin writes are intentionally blocked unless a real admin role exists

## Role detection

Current SQL helper:
- `public.is_ufficcio_admin()`

It currently defaults to `false`.

## Local debug admin

Use local debug/admin flags for preview and QA without enabling remote writes.

## Remote admin limitations

Until a real RBAC source exists, these remain local/debug only:
- remote admin config writes
- remote template override writes
- privileged analytics access

## Future RBAC plan

Recommended future roles:
- `super_admin`
- `ops_manager`
- `moderator`
- `support_agent`
- `read_only_analyst`
