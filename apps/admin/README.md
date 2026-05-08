# UfficioFacile Admin

Production backoffice for UfficioFacile, built with Next.js App Router, TypeScript, Tailwind CSS, and Supabase SSR auth.

## Local run

```bash
cd apps/admin
npm install
npm run dev
```

If Next.js fails with a missing `.next/routes-manifest.json` error, clear the local
build cache and restart:

```bash
cd apps/admin
rm -rf .next
npm run dev
```

Or use the package scripts:

```bash
npm run clean
npm run dev:clean
```

Required environment variables:

- `NEXT_PUBLIC_SUPABASE_URL`
- `NEXT_PUBLIC_SUPABASE_ANON_KEY`
- `SUPABASE_SERVICE_ROLE_KEY`
- `NEXT_PUBLIC_ADMIN_APP_URL`

Copy `.env.example` to `.env.local` and fill the values.

## First admin seed

```bash
cd apps/admin
SUPABASE_URL=YOUR_SUPABASE_URL \
SUPABASE_SERVICE_ROLE_KEY=YOUR_SUPABASE_SERVICE_ROLE_KEY \
ADMIN_EMAIL=admin@example.com \
ADMIN_PASSWORD='ChangeMe123!' \
node scripts/seed-admin.mjs
```

This script:

1. Finds or creates the Supabase auth user.
2. Upserts `public.ufficio_admin_users`.
3. Assigns role `owner`.
4. Marks the admin as active.

Never expose `SUPABASE_SERVICE_ROLE_KEY` in the browser.

## Bundled content bundle

Generate the canonical bundled CMS export from the Flutter category registry:

```bash
cd /Users/mohammadkhataei/Desktop/UfficioFacile
dart run tool/export_cms_seed.dart
```

This writes:

- `docs/generated/cms_bundled_content_export.json`
- `apps/admin/data/cms_bundled_content_export.json`

The admin content tree uses Supabase first and bundled content as fallback.
Owner/admin sessions also auto-bootstrap missing bundled categories and procedures
into Supabase without overwriting existing edited rows.

If you want to verify the generated bundle locally:

```bash
cd /Users/mohammadkhataei/Desktop/UfficioFacile
dart run tool/content_doctor.dart
```

## Vercel deployment

- Project root: `apps/admin`
- Framework preset: `Next.js`
- Install command: `npm install`
- Build command: `npm run build`
- Output: default Next.js

Environment variables in Vercel:

- `NEXT_PUBLIC_SUPABASE_URL`
- `NEXT_PUBLIC_SUPABASE_ANON_KEY`
- `SUPABASE_SERVICE_ROLE_KEY`
- `NEXT_PUBLIC_ADMIN_APP_URL`

Supabase auth redirect URLs:

- Local: `http://localhost:3000/dashboard`
- Production: `https://YOUR-VERCEL-URL/dashboard`

## Useful commands

```bash
npm run clean
npm run dev:clean
npm run lint
npm run build
npm run content:lint
```

## Supabase schema cache note

If admin still reports a table as missing after you apply migrations:

1. wait a moment for the PostgREST schema cache to refresh
2. restart the local admin dev server
3. confirm the table exists in the Supabase SQL editor
