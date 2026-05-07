import { createClient } from "@supabase/supabase-js";

const {
  SUPABASE_URL,
  SUPABASE_SERVICE_ROLE_KEY,
  ADMIN_EMAIL,
  ADMIN_PASSWORD,
} = process.env;

if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY || !ADMIN_EMAIL) {
  console.error(
    "Missing SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, or ADMIN_EMAIL.",
  );
  process.exit(1);
}

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, {
  auth: { persistSession: false, autoRefreshToken: false },
});

let user =
  (await supabase.auth.admin.listUsers()).data.users.find(
    (entry) => entry.email?.toLowerCase() === ADMIN_EMAIL.toLowerCase(),
  ) ?? null;

if (!user) {
  const { data, error } = await supabase.auth.admin.createUser({
    email: ADMIN_EMAIL,
    password: ADMIN_PASSWORD || undefined,
    email_confirm: true,
  });
  if (error) {
    console.error(error);
    process.exit(1);
  }
  user = data.user;
}

if (!user) {
  console.error("Could not create or find admin user.");
  process.exit(1);
}

const payload = {
  user_id: user.id,
  email: ADMIN_EMAIL,
  role: "owner",
  is_active: true,
};

const { error } = await supabase.from("ufficio_admin_users").upsert(payload);
if (error) {
  console.error(error);
  process.exit(1);
}

console.log(`Seeded admin owner for ${ADMIN_EMAIL} (${user.id})`);
