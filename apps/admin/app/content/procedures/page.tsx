import Link from "next/link";

import { AdminShell } from "@/components/admin-shell";
import { DataTable } from "@/components/data-table";
import { StatusBadge } from "@/components/status-badge";
import { requireAdmin } from "@/lib/auth/require-admin";
import {
  getAdminContentTree,
  getProcedureRoutePath,
} from "@/lib/content/load-content-tree";

export default async function ContentProceduresPage() {
  const admin = await requireAdmin("content.read");
  const tree = await getAdminContentTree(admin.supabase, {
    bootstrapIfEmpty: admin.role === "owner" || admin.role === "admin",
  });

  return (
    <AdminShell email={admin.email} role={admin.role}>
      <DataTable
        headers={["Title", "Category", "Slug", "Status", "Source", "Open"]}
        rows={tree.procedures.map((procedure) => [
          procedure.title?.en || procedure.slug,
          procedure.subcategory_slug
            ? `${procedure.category_slug} / ${procedure.subcategory_slug}`
            : procedure.category_slug,
          procedure.slug,
          <StatusBadge key="status" value={procedure.status} />,
          <StatusBadge key="source" value={procedure.source} />,
          <Link key="open" href={getProcedureRoutePath(procedure)}>Edit</Link>,
        ])}
        empty="No CMS procedures yet and no bundled content export was found."
      />
    </AdminShell>
  );
}
