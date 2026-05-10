import { notFound, redirect } from "next/navigation";
import Link from "next/link";

import { AdminShell } from "@/components/admin-shell";
import { requireAdmin } from "@/lib/auth/require-admin";
import {
  findAdminProceduresBySlug,
  getProcedureRoutePath,
} from "@/lib/content/load-content-tree";

export default async function ContentProcedureDetailPage({
  params,
}: {
  params: Promise<{ slug: string }>;
}) {
  const admin = await requireAdmin("content.read");
  const { slug } = await params;
  const result = await findAdminProceduresBySlug(admin.supabase, slug, {
    bootstrapIfEmpty: admin.role === "owner" || admin.role === "admin",
  });
  if (result.matches.length === 0) notFound();
  if (result.matches.length === 1) {
    redirect(getProcedureRoutePath(result.matches[0]));
  }

  return (
    <AdminShell email={admin.email} role={admin.role}>
      <section className="rounded-3xl border border-amber-200 bg-white p-6 shadow-soft">
        <h2 className="text-xl font-semibold text-slate-900">
          Ambiguous legacy procedure slug
        </h2>
        <p className="mt-3 text-sm text-slate-600">
          The slug <code>{slug}</code> exists in multiple categories. Use the
          category-aware route to open the correct procedure.
        </p>
        <div className="mt-6 space-y-3">
          {result.matches.map((procedure) => {
            const href = getProcedureRoutePath(procedure);
            return (
              <Link
                key={href}
                href={href}
                className="flex items-center justify-between rounded-2xl border border-slate-200 px-4 py-3 hover:bg-slate-50"
              >
                <div>
                  <div className="font-medium text-slate-900">
                    {procedure.title?.en || procedure.slug}
                  </div>
                  <div className="text-sm text-slate-500">
                    {procedure.category_slug}
                    {procedure.subcategory_slug
                      ? ` / ${procedure.subcategory_slug}`
                      : ""}
                    {" • "}
                    {procedure.status}
                  </div>
                </div>
                <span className="text-sm font-medium text-slate-900">Open</span>
              </Link>
            );
          })}
        </div>
      </section>
    </AdminShell>
  );
}
