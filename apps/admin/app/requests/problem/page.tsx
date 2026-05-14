import Link from "next/link";

import { AdminShell } from "@/components/admin-shell";
import { DataTable } from "@/components/data-table";
import { StatusBadge } from "@/components/status-badge";
import { requireAdmin } from "@/lib/auth/require-admin";
import { getProblemRequests } from "@/lib/db/queries";

export default async function ProblemRequestsPage() {
  const admin = await requireAdmin("requests.read");
  const rows = await getProblemRequests(admin.supabase);

  return (
    <AdminShell email={admin.email} role={admin.role}>
      <section className="rounded-3xl border border-slate-200 bg-white p-6 shadow-soft">
        <h2 className="text-xl font-semibold text-slate-900">Problem requests</h2>
        <p className="mt-1 text-sm text-slate-600">
          Queue for the public “Can’t find your problem?” flow and city/content requests.
        </p>
      </section>
      <DataTable
        headers={["Title", "Content context", "User", "Language", "Status", "Source", "Open"]}
        rows={rows.map((row: any) => [
          row.problem_title ?? row.title ?? "Untitled request",
          row.linked_procedure_slug
            ? `${row.linked_category_slug ?? row.category_id ?? "—"} / ${row.linked_procedure_slug}`
            : row.linked_category_slug ?? row.category_id ?? row.category ?? "—",
          row.email ?? row.user_email ?? row.user_id ?? "—",
          row.language_code ?? row.language ?? "—",
          <StatusBadge key="status" value={row.status} />,
          row.source_page ?? row.category ?? "manual",
          <Link key="open" href={`/requests/problem/${row.id}`}>Open</Link>,
        ])}
      />
    </AdminShell>
  );
}
