import Link from "next/link";
import { notFound } from "next/navigation";

import { AdminShell } from "@/components/admin-shell";
import { DataTable } from "@/components/data-table";
import { requireAdmin } from "@/lib/auth/require-admin";
import {
  editableCatalogTables,
  getCatalogTableRows,
  type EditableCatalogTable,
} from "@/lib/db/queries";

export default async function CatalogTablePage({
  params,
}: {
  params: Promise<{ table: string }>;
}) {
  const admin = await requireAdmin("catalog.read");
  const { table } = await params;
  if (!editableCatalogTables.includes(table as EditableCatalogTable)) notFound();
  const rows = await getCatalogTableRows(admin.supabase, table as EditableCatalogTable);

  return (
    <AdminShell email={admin.email} role={admin.role}>
      <section className="rounded-3xl border border-slate-200 bg-white p-6 shadow-soft">
        <h2 className="text-xl font-semibold text-slate-900">{table}</h2>
        <p className="mt-1 text-sm text-slate-600">
          Search, inspect, and edit this public catalog table.
        </p>
      </section>
      <DataTable
        headers={["Primary", "Updated", "Open"]}
        rows={rows.map((row: any) => [
          row.title ?? row.name ?? row.id ?? row.key ?? "row",
          row.updated_at ? new Date(row.updated_at).toLocaleString() : "—",
          <Link key="open" href={`/catalog/${table}/${row.id ?? row.key}`}>Edit</Link>,
        ])}
      />
    </AdminShell>
  );
}
