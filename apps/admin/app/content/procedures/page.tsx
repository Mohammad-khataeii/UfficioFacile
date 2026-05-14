import Link from "next/link";

import { AdminShell } from "@/components/admin-shell";
import { DataTable } from "@/components/data-table";
import { StatusBadge } from "@/components/status-badge";
import { requireAdmin } from "@/lib/auth/require-admin";
import { getAdminCatalogTreeNormalized } from "@/lib/catalog/queries";

export default async function ContentProceduresPage() {
  const admin = await requireAdmin("content.read");
  const tree = await getAdminCatalogTreeNormalized(admin.supabase, {
    bootstrapIfEmpty: admin.role === "owner" || admin.role === "admin",
  });

  return (
    <AdminShell email={admin.email} role={admin.role}>
      <DataTable
        headers={["Title", "Category", "Slug", "Visibility", "Source", "Open"]}
        rows={tree.procedures.map((procedure) => [
          procedure.title.en || procedure.slug,
          procedure.subcategorySlug
            ? `${procedure.categorySlug} / ${procedure.subcategorySlug}`
            : procedure.categorySlug,
          procedure.slug,
          <StatusBadge key="status" value={procedure.premiumVisibility} />,
          <StatusBadge key="source" value={procedure.source} />,
          <Link key="open" href={`/content/procedures/${procedure.categorySlug}/${procedure.slug}`}>Edit</Link>,
        ])}
        empty="No CMS procedures yet and no bundled content export was found."
      />
    </AdminShell>
  );
}
