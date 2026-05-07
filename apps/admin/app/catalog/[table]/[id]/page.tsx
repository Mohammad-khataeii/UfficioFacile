import { notFound } from "next/navigation";

import { AdminShell } from "@/components/admin-shell";
import { JsonEditor } from "@/components/json-editor";
import { requireAdmin } from "@/lib/auth/require-admin";
import { upsertCatalogRow } from "@/lib/db/mutations";
import {
  editableCatalogTables,
  getCatalogTableRow,
  type EditableCatalogTable,
} from "@/lib/db/queries";

export default async function CatalogRowPage({
  params,
}: {
  params: Promise<{ table: string; id: string }>;
}) {
  const admin = await requireAdmin("catalog.read");
  const { table, id } = await params;
  if (!editableCatalogTables.includes(table as EditableCatalogTable)) notFound();
  const row = await getCatalogTableRow(admin.supabase, table as EditableCatalogTable, id);
  if (!row) notFound();

  return (
    <AdminShell email={admin.email} role={admin.role}>
      <section className="rounded-3xl border border-slate-200 bg-white p-6 shadow-soft">
        <h2 className="text-xl font-semibold text-slate-900">
          {table} / {id}
        </h2>
        <p className="mt-1 text-sm text-slate-600">
          Advanced JSON editor for public catalog rows.
        </p>
        <form action={upsertCatalogRow} className="mt-5 space-y-4">
          <input type="hidden" name="table" value={table} />
          <input type="hidden" name="id" value={id} />
          <JsonEditor name="payload" defaultValue={row} rows={24} />
          <button className="rounded-xl bg-slate-900 px-4 py-2 text-sm font-medium text-white">
            Save row
          </button>
        </form>
      </section>
    </AdminShell>
  );
}
