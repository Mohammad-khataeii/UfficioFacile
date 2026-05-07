import Link from "next/link";

import { AdminShell } from "@/components/admin-shell";
import { DataTable } from "@/components/data-table";
import { StatusBadge } from "@/components/status-badge";
import { requireAdmin } from "@/lib/auth/require-admin";
import { getAdminCategories } from "@/lib/content/load-content-tree";

export default async function ContentCategoriesPage() {
  const admin = await requireAdmin("content.read");
  const categories = await getAdminCategories(admin.supabase);

  return (
    <AdminShell email={admin.email} role={admin.role}>
      <DataTable
        headers={["Title", "Slug", "Verification", "Active", "Source", "Open"]}
        rows={categories.map((category) => [
          category.title?.en || category.slug,
          category.slug,
          <StatusBadge key="verify" value={category.verification_status} />,
          category.is_active ? "yes" : "no",
          <StatusBadge key="source" value={category.source} />,
          <Link key="open" href={`/content/categories/${category.slug}`}>Edit</Link>,
        ])}
        empty="No CMS categories yet and no bundled content export was found."
      />
    </AdminShell>
  );
}
