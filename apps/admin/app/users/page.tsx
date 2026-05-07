import Link from "next/link";

import { AdminShell } from "@/components/admin-shell";
import { DataTable } from "@/components/data-table";
import { StatusBadge } from "@/components/status-badge";
import { requireAdmin } from "@/lib/auth/require-admin";
import { listAuthUsers } from "@/lib/db/queries";

export default async function UsersPage({
  searchParams,
}: {
  searchParams: Promise<{ q?: string }>;
}) {
  const admin = await requireAdmin("users.read");
  const params = await searchParams;
  const users = await listAuthUsers(params.q);

  return (
    <AdminShell email={admin.email} role={admin.role}>
      <section className="rounded-3xl border border-slate-200 bg-white p-6 shadow-soft">
        <div className="flex flex-col gap-4 sm:flex-row sm:items-end sm:justify-between">
          <div>
            <h2 className="text-xl font-semibold text-slate-900">Users</h2>
            <p className="mt-1 text-sm text-slate-600">
              Search Supabase auth users, then open their app profile, entitlement, and requests.
            </p>
          </div>
          <form className="w-full max-w-md">
            <label htmlFor="q">Search by email or user ID</label>
            <input id="q" name="q" defaultValue={params.q ?? ""} />
          </form>
        </div>
      </section>

      <DataTable
        headers={["Email", "User ID", "Created", "Last sign-in", "Status", "Open"]}
        rows={users.map((user) => [
          user.email ?? "no-email",
          <code key="id" className="text-xs">{user.id}</code>,
          user.created_at ? new Date(user.created_at).toLocaleString() : "—",
          user.last_sign_in_at ? new Date(user.last_sign_in_at).toLocaleString() : "—",
          <StatusBadge
            key="status"
            value={user.email_confirmed_at ? "confirmed" : "pending"}
          />,
          <Link key="open" href={`/users/${user.id}`}>Details</Link>,
        ])}
      />
    </AdminShell>
  );
}
