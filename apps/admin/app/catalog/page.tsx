import Link from "next/link";

import { AdminShell } from "@/components/admin-shell";
import { requireAdmin } from "@/lib/auth/require-admin";
import { editableCatalogTables, getCatalogTableRows } from "@/lib/db/queries";

export default async function CatalogPage() {
  const admin = await requireAdmin("catalog.read");
  const counts = await Promise.all(
    editableCatalogTables.map(async (table) => ({
      table,
      rows: await getCatalogTableRows(admin.supabase, table),
    })),
  );

  return (
    <AdminShell email={admin.email} role={admin.role}>
      <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-3">
        {counts.map(({ table, rows }) => (
          <Link
            key={table}
            href={`/catalog/${table}`}
            className="rounded-3xl border border-slate-200 bg-white p-5 shadow-soft transition hover:border-brand-300"
          >
            <p className="text-sm text-slate-500">{table}</p>
            <p className="mt-3 text-3xl font-semibold text-slate-900">{rows.length}</p>
          </Link>
        ))}
      </div>
    </AdminShell>
  );
}
