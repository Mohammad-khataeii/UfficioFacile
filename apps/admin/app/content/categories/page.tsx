import Link from "next/link";

import { AdminShell } from "@/components/admin-shell";
import { DataTable } from "@/components/data-table";
import { StatusBadge } from "@/components/status-badge";
import { requireAdmin } from "@/lib/auth/require-admin";
import { getAdminCategoriesNormalized } from "@/lib/catalog/queries";

export default async function ContentCategoriesPage() {
  const admin = await requireAdmin("content.read");
  const categories = await getAdminCategoriesNormalized(admin.supabase, {
    bootstrapIfEmpty: admin.role === "owner" || admin.role === "admin",
  });

  return (
    <AdminShell email={admin.email} role={admin.role}>
      <DataTable
        headers={[
          "Title",
          "Slug",
          "Subcategories",
          "Procedures",
          "Visibility",
          "Source",
          "Open",
        ]}
        rows={categories.map((category) => [
          category.title.en || category.slug,
          category.slug,
          category.subcategoryCount,
          category.procedureCount,
          <StatusBadge key="visibility" value={category.premiumVisibility} />,
          <StatusBadge key="source" value={category.source} />,
          <Link key="open" href={`/content/categories/${category.slug}`}>Edit</Link>,
        ])}
        empty="No CMS categories yet and no bundled content export was found."
      />
    </AdminShell>
  );
}
