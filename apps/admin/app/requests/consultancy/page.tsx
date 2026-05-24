import Link from "next/link";

import { AdminShell } from "@/components/admin-shell";
import { DataTable } from "@/components/data-table";
import { StatusBadge } from "@/components/status-badge";
import { requireAdmin } from "@/lib/auth/require-admin";
import { getConsultancyRequests } from "@/lib/db/queries";

export default async function ConsultancyRequestsPage() {
  const admin = await requireAdmin("requests.read");
  const rows = await getConsultancyRequests(admin.supabase);

  return (
    <AdminShell email={admin.email} role={admin.role}>
      <section className="rounded-3xl border border-slate-200 bg-white p-6 shadow-soft">
        <h2 className="text-xl font-semibold text-slate-900">Consultancy requests</h2>
        <p className="mt-1 text-sm text-slate-600">
          Premium members use their monthly consultancy quota here. Free-user payment status is tracked separately.
        </p>
      </section>
      <DataTable
        headers={["Name", "Topic", "Plan", "Payment", "Status", "Open"]}
        rows={rows.map((row: any) => [
          row.full_name || row.user_email || row.email || "—",
          row.problem_type || row.subject || row.category_id || row.category || "—",
          <StatusBadge
            key="plan"
            value={row.user_plan ?? (row.is_premium_snapshot ? "premium" : "free")}
          />,
          <StatusBadge key="payment" value={row.payment_status} />,
          <StatusBadge key="status" value={row.status} />,
          <Link key="open" href={`/requests/consultancy/${row.id}`}>Open</Link>,
        ])}
      />
    </AdminShell>
  );
}
