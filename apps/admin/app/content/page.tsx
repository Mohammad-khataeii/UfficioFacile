import Link from "next/link";

import { AdminShell } from "@/components/admin-shell";
import { StatusBadge } from "@/components/status-badge";
import { requireAdmin } from "@/lib/auth/require-admin";
import { getAdminContentTree } from "@/lib/content/load-content-tree";

export default async function ContentPage() {
  const admin = await requireAdmin("content.read");
  const tree = await getAdminContentTree(admin.supabase);

  return (
    <AdminShell email={admin.email} role={admin.role}>
      <section className="grid gap-6 xl:grid-cols-[0.95fr_1.05fr]">
        <div className="rounded-3xl border border-slate-200 bg-white p-6 shadow-soft">
          <div className="flex items-center justify-between">
            <h2 className="text-xl font-semibold text-slate-900">Categories</h2>
            <div className="flex items-center gap-3">
              <StatusBadge value={tree.source} />
              <Link href="/content/categories" className="text-sm">Open manager</Link>
            </div>
          </div>
          <div className="mt-5 space-y-3">
            {tree.categories.map((category: any) => (
              <Link
                key={category.slug}
                href={`/content/categories/${category.slug}`}
                className="flex items-center justify-between rounded-2xl border border-slate-100 p-4 hover:bg-slate-50"
              >
                <div>
                  <p className="font-medium text-slate-900">
                    {category.title?.en || category.slug}
                  </p>
                  <p className="text-sm text-slate-500">{category.slug}</p>
                </div>
                <StatusBadge value={category.verification_status} />
              </Link>
            ))}
          </div>
        </div>

        <div className="rounded-3xl border border-slate-200 bg-white p-6 shadow-soft">
          <div className="flex items-center justify-between">
            <h2 className="text-xl font-semibold text-slate-900">Procedures</h2>
            <Link href="/content/procedures" className="text-sm">Open manager</Link>
          </div>
          <div className="mt-5 space-y-3">
            {tree.procedures.map((procedure: any) => (
              <Link
                key={`${procedure.category_slug ?? procedure.categorySlug ?? "unknown"}-${procedure.slug}-${procedure.id ?? ""}`}
                href={`/content/procedures/${procedure.slug}`}
                className="flex items-center justify-between rounded-2xl border border-slate-100 p-4 hover:bg-slate-50"
              >
                <div>
                  <p className="font-medium text-slate-900">
                    {procedure.title?.en || procedure.slug}
                  </p>
                  <p className="text-sm text-slate-500">
                    {procedure.category_slug} • {procedure.slug}
                  </p>
                </div>
                <StatusBadge value={procedure.status} />
              </Link>
            ))}
          </div>
        </div>
      </section>
    </AdminShell>
  );
}
