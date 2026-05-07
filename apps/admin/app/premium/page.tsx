import { AdminShell } from "@/components/admin-shell";
import { DataTable } from "@/components/data-table";
import { StatusBadge } from "@/components/status-badge";
import { requireAdmin } from "@/lib/auth/require-admin";
import { updateEntitlement } from "@/lib/db/mutations";
import { getEntitlements, getPremiumEvents } from "@/lib/db/queries";

export default async function PremiumPage() {
  const admin = await requireAdmin("premium.read");
  const [entitlements, events] = await Promise.all([
    getEntitlements(admin.supabase),
    getPremiumEvents(admin.supabase),
  ]);

  return (
    <AdminShell email={admin.email} role={admin.role}>
      <section className="grid gap-6 xl:grid-cols-[1.1fr_0.9fr]">
        <div className="rounded-3xl border border-slate-200 bg-white p-6 shadow-soft">
          <h2 className="text-xl font-semibold text-slate-900">User entitlements</h2>
          <div className="mt-5">
            <DataTable
              headers={["User", "Plan", "Premium", "Free pack limit", "Used", "Status"]}
              rows={entitlements.map((row: any) => [
                <code key="user" className="text-xs">{row.user_id}</code>,
                <StatusBadge key="plan" value={row.plan} />,
                row.premium_access ? "yes" : "no",
                row.free_pack_limit ?? 0,
                row.free_packs_used ?? 0,
                <StatusBadge key="status" value={row.status} />,
              ])}
            />
          </div>
        </div>

        <section className="space-y-6">
          <div className="rounded-3xl border border-slate-200 bg-white p-6 shadow-soft">
            <h2 className="text-xl font-semibold text-slate-900">Manual entitlement update</h2>
            <form action={updateEntitlement} className="mt-5 space-y-4">
              <div>
                <label htmlFor="userId">User ID</label>
                <input id="userId" name="userId" required />
              </div>
              <div>
                <label htmlFor="plan">Plan</label>
                <select id="plan" name="plan" defaultValue="free">
                  <option value="free">free</option>
                  <option value="pro">pro</option>
                  <option value="consultant">consultant</option>
                </select>
              </div>
              <div>
                <label htmlFor="status">Status</label>
                <input id="status" name="status" defaultValue="active" />
              </div>
              <div className="grid gap-4 sm:grid-cols-2">
                <div>
                  <label htmlFor="freePackLimit">Free pack limit</label>
                  <input id="freePackLimit" name="freePackLimit" defaultValue="5" />
                </div>
                <div>
                  <label htmlFor="freePacksUsed">Free packs used</label>
                  <input id="freePacksUsed" name="freePacksUsed" defaultValue="0" />
                </div>
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
            <h2 className="text-xl font-semibold text-slate-900">Premium events</h2>
            <div className="mt-4 space-y-3">
              {events.slice(0, 12).map((event: any) => (
                <div key={event.id} className="rounded-2xl border border-slate-100 p-4">
                  <div className="flex items-center justify-between">
                    <p className="font-medium text-slate-900">{event.event_type}</p>
                    <StatusBadge value={event.plan_after ?? event.plan_before} />
                  </div>
                  <p className="mt-2 text-sm text-slate-600">
                    {event.user_id} • {new Date(event.created_at).toLocaleString()}
                  </p>
                </div>
              ))}
            </div>
          </div>
        </section>
      </section>
    </AdminShell>
  );
}
