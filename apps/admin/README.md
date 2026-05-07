# UfficioFacile Admin

Production backoffice for UfficioFacile, built with Next.js App Router, TypeScript, Tailwind CSS, and Supabase SSR auth.

## Local run

```bash
cd apps/admin
npm install
npm run dev
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

## Bundled content import

Generate the import source from the Flutter repo content:

```bash
cd /Users/mohammadkhataei/Desktop/UfficioFacile
dart run tool/export_cms_seed.dart
```

Then open `/content/import` in the admin app and run the import.

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
npm run lint
npm run build
npm run content:lint
```
