import { AdminShell } from "@/components/admin-shell";
import { DataTable } from "@/components/data-table";
import { StatusBadge } from "@/components/status-badge";
import { requireAdmin } from "@/lib/auth/require-admin";
import { upsertAdminUser } from "@/lib/db/mutations";
import { getAdminUsers } from "@/lib/db/queries";

export default async function AdminsPage() {
  const admin = await requireAdmin("admins.read");
  const admins = await getAdminUsers(admin.supabase);

  return (
    <AdminShell email={admin.email} role={admin.role}>
      <section className="grid gap-6 xl:grid-cols-[1.1fr_0.9fr]">
        <div className="rounded-3xl border border-slate-200 bg-white p-6 shadow-soft">
          <h2 className="text-xl font-semibold text-slate-900">Admin users</h2>
          <p className="mt-1 text-sm text-slate-600">
            Owners can manage every admin. Admins cannot remove owners or other admins.
          </p>
          <div className="mt-5">
            <DataTable
              headers={["Email", "User ID", "Role", "Active", "Updated"]}
              rows={admins.map((row: any) => [
                row.email ?? "—",
                <code key="id" className="text-xs">{row.user_id}</code>,
                <StatusBadge key="role" value={row.role} />,
                row.is_active ? "yes" : "no",
                row.updated_at ? new Date(row.updated_at).toLocaleString() : "—",
              ])}
            />
          </div>
        </div>

        <section className="rounded-3xl border border-slate-200 bg-white p-6 shadow-soft">
          <h2 className="text-xl font-semibold text-slate-900">Add or update admin</h2>
          <form action={upsertAdminUser} className="mt-5 space-y-4">
            <div>
              <label htmlFor="userId">User ID</label>
              <input id="userId" name="userId" required />
            </div>
            <div>
              <label htmlFor="email">Email</label>
              <input id="email" name="email" type="email" />
            </div>
            <div>
              <label htmlFor="role">Role</label>
              <select id="role" name="role" defaultValue="viewer">
                <option value="owner">owner</option>
                <option value="admin">admin</option>
                <option value="editor">editor</option>
                <option value="support">support</option>
                <option value="viewer">viewer</option>
              </select>
            </div>
            <label className="flex items-center gap-3">
              <input name="isActive" type="checkbox" defaultChecked className="h-4 w-4" />
              <span>Active</span>
            </label>
            <button className="rounded-xl bg-slate-900 px-4 py-2 text-sm font-medium text-white">
              Save admin user
            </button>
          </form>
        </section>
      </section>
    </AdminShell>
  );
}
