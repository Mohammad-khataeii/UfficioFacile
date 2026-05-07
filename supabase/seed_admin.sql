-- 1. Create the Auth user manually in the Supabase Dashboard, or sign up once in the app.
-- 2. Replace YOUR_AUTH_USER_ID and YOUR_EMAIL before running this SQL.
-- 3. Run this in the Supabase SQL Editor or another trusted admin context.
-- 4. Do not seed admin roles from the anon client or from Flutter.

insert into public.ufficio_admin_users (user_id, email, role, is_active)
values ('YOUR_AUTH_USER_ID'::uuid, 'YOUR_EMAIL@example.com', 'owner', true)
on conflict (user_id) do update
set role = 'owner',
    is_active = true,
    email = excluded.email,
    updated_at = now();
