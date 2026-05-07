import { AdminShell } from "@/components/admin-shell";
import { DataTable } from "@/components/data-table";
import { StatusBadge } from "@/components/status-badge";
import { requireAdmin } from "@/lib/auth/require-admin";
import { getAuditRows } from "@/lib/db/queries";

export default async function AuditPage() {
  const admin = await requireAdmin("audit.read");
  const rows = await getAuditRows(admin.supabase);

  return (
    <AdminShell email={admin.email} role={admin.role}>
      <DataTable
        headers={["When", "Action", "Actor", "Role", "Table", "Target"]}
        rows={rows.map((row: any) => [
          new Date(row.created_at).toLocaleString(),
          row.action,
          row.actor_email ?? "—",
          <StatusBadge key="role" value={row.actor_role} />,
          row.target_table,
          row.target_id ?? row.target_user_id ?? "—",
        ])}
      />
    </AdminShell>
  );
}
