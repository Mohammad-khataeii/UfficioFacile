import { AdminShell } from "@/components/admin-shell";
import { DataTable } from "@/components/data-table";
import { StatusBadge } from "@/components/status-badge";
import { requireAdmin } from "@/lib/auth/require-admin";
import { grantContentUnlock, updateEntitlement } from "@/lib/db/mutations";
import { getContentUnlocks, getEntitlements } from "@/lib/db/queries";

export default async function PremiumUsersPage() {
  const admin = await requireAdmin("premium.read");
  const [entitlements, unlocks] = await Promise.all([
    getEntitlements(admin.supabase),
    getContentUnlocks(admin.supabase),
  ]);

  return (
    <AdminShell email={admin.email} role={admin.role}>
      <section className="grid gap-6 xl:grid-cols-[1.2fr_0.8fr]">
        <div className="space-y-6">
          <div className="rounded-3xl border border-slate-200 bg-white p-6 shadow-soft">
            <h2 className="text-xl font-semibold text-slate-900">Entitlements</h2>
            <div className="mt-5">
              <DataTable
                headers={["User", "Plan", "Status", "Premium", "Source", "Ends"]}
                rows={entitlements.map((row: any) => [
                  <code key="user" className="text-xs">{row.user_id}</code>,
                  <StatusBadge key="plan" value={row.plan} />,
                  <StatusBadge key="status" value={row.status} />,
                  row.premium_access ? "yes" : "no",
                  row.source ?? "system",
                  row.current_period_end ? new Date(row.current_period_end).toLocaleDateString() : "—",
                ])}
              />
            </div>
          </div>

          <div className="rounded-3xl border border-slate-200 bg-white p-6 shadow-soft">
            <h2 className="text-xl font-semibold text-slate-900">Content unlocks</h2>
            <div className="mt-5">
              <DataTable
                headers={["User", "Category", "Procedure", "Status", "Type", "Amount"]}
                rows={unlocks.map((row: any) => [
                  <code key="user" className="text-xs">{row.user_id}</code>,
                  row.category_slug,
                  row.procedure_slug,
                  <StatusBadge key="status" value={row.status} />,
                  row.unlock_type,
                  row.amount_cents ? `${(row.amount_cents / 100).toFixed(2)} ${row.currency ?? "EUR"}` : "—",
                ])}
              />
            </div>
          </div>
        </div>

        <div className="space-y-6">
          <div className="rounded-3xl border border-slate-200 bg-white p-6 shadow-soft">
            <h2 className="text-xl font-semibold text-slate-900">Manual entitlement update</h2>
            <form action={updateEntitlement} className="mt-5 space-y-4">
              <input name="userId" required placeholder="User ID" />
              <select name="plan" defaultValue="free">
                <option value="free">free</option>
                <option value="premium_monthly">premium_monthly</option>
                <option value="premium_yearly">premium_yearly</option>
                <option value="admin_grant">admin_grant</option>
              </select>
              <input name="status" defaultValue="active" />
              <div className="grid gap-3 sm:grid-cols-2">
                <input name="freePackLimit" defaultValue="3" />
                <input name="freePacksUsed" defaultValue="0" />
              </div>
              <label className="flex items-center gap-3">
                <input name="premiumAccess" type="checkbox" className="h-4 w-4" />
                <span>Premium access</span>
              </label>
              <button className="rounded-xl bg-slate-900 px-4 py-2 text-sm font-medium text-white">
                Save entitlement
              </button>
            </form>
          </div>

          <div className="rounded-3xl border border-slate-200 bg-white p-6 shadow-soft">
            <h2 className="text-xl font-semibold text-slate-900">Grant single unlock</h2>
            <form action={grantContentUnlock} className="mt-5 space-y-4">
              <input name="userId" required placeholder="User ID" />
              <input name="categorySlug" required placeholder="Category slug" />
              <input name="procedureSlug" required placeholder="Procedure slug" />
              <input name="amountCents" defaultValue="399" />
              <input name="currency" defaultValue="EUR" />
              <button className="rounded-xl bg-slate-900 px-4 py-2 text-sm font-medium text-white">
                Grant unlock
              </button>
            </form>
          </div>
        </div>
      </section>
    </AdminShell>
  );
}
