import { notFound, redirect } from "next/navigation";

import { requireAdmin } from "@/lib/auth/require-admin";
import {
  getAdminProcedureBySlug,
  getProcedureRoutePath,
} from "@/lib/content/load-content-tree";

export default async function ContentProcedureDetailPage({
  params,
}: {
  params: Promise<{ slug: string }>;
}) {
  const admin = await requireAdmin("content.read");
  const { slug } = await params;
  const procedure = await getAdminProcedureBySlug(admin.supabase, slug, {
    bootstrapIfEmpty: admin.role === "owner" || admin.role === "admin",
  });
  if (!procedure) notFound();
  redirect(getProcedureRoutePath(procedure));
}
