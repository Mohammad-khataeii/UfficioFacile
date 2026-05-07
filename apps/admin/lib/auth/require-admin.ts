import { redirect } from "next/navigation";

import { hasPermission, type AdminRole, type Permission } from "@/lib/auth/permissions";
import { createSupabaseServerClient } from "@/lib/supabase/server";

export type AdminContext = {
  userId: string;
  email: string | null;
  role: AdminRole;
  supabase: Awaited<ReturnType<typeof createSupabaseServerClient>>;
};

export async function requireAdmin(
  permission?: Permission,
): Promise<AdminContext> {
  const supabase = await createSupabaseServerClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    redirect("/login");
  }

  const { data: adminRow } = await supabase
    .from("ufficio_admin_users")
    .select("role, is_active")
    .eq("user_id", user.id)
    .maybeSingle();

  if (!adminRow?.is_active || !adminRow.role) {
    redirect("/forbidden");
  }

  const role = adminRow.role as AdminRole;
  if (permission && !hasPermission(role, permission)) {
    redirect("/forbidden");
  }

  return {
    userId: user.id,
    email: user.email ?? null,
    role,
    supabase,
  };
}
