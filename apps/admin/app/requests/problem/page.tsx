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
          Queue for the global “Can’t find your problem?” submissions.
        </p>
      </section>
      <DataTable
        headers={["Title", "Category", "User", "Language", "Status", "Priority", "Open"]}
        rows={rows.map((row: any) => [
          row.title,
          row.category_id ?? "—",
          row.user_email ?? row.user_id ?? "—",
          row.language,
          <StatusBadge key="status" value={row.status} />,
          row.is_premium_user ? "premium" : row.urgency,
          <Link key="open" href={`/requests/problem/${row.id}`}>Open</Link>,
        ])}
      />
    </AdminShell>
  );
}
