import { AdminShell } from "@/components/admin-shell";
import { requireAdmin } from "@/lib/auth/require-admin";
import { upsertPromoCode } from "@/lib/db/mutations";
import { getPromoCodeOverview } from "@/lib/db/queries";

function formatDate(value: string | null | undefined) {
  if (!value) return "—";
  const parsed = new Date(value);
  if (Number.isNaN(parsed.getTime())) return value;
  return parsed.toLocaleString();
}

export default async function PromoCodesPage() {
  const admin = await requireAdmin("premium.read");
  const { codes, redemptions, warnings } = await getPromoCodeOverview(
    admin.supabase,
  );

  return (
    <AdminShell email={admin.email} role={admin.role}>
      <div className="space-y-6">
        {warnings.length > 0 ? (
          <div className="rounded-2xl border border-amber-200 bg-amber-50 p-4 text-sm text-amber-900">
            {warnings.join(" ")}
          </div>
        ) : null}

        <section className="rounded-3xl border border-slate-200 bg-white p-6 shadow-soft">
          <h2 className="text-xl font-semibold text-slate-900">Create promo code</h2>
          <form action={upsertPromoCode} className="mt-5 grid gap-4 md:grid-cols-2 xl:grid-cols-3">
            <div>
              <label className="text-sm font-medium text-slate-700">Code</label>
              <input name="code" required className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2" />
            </div>
            <div>
              <label className="text-sm font-medium text-slate-700">Title</label>
              <input name="title" required className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2" />
            </div>
            <div>
              <label className="text-sm font-medium text-slate-700">Plan</label>
              <select name="planKey" defaultValue="premium_monthly" className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2">
                <option value="premium_monthly">premium_monthly</option>
                <option value="premium_yearly">premium_yearly</option>
                <option value="trial">trial</option>
                <option value="admin_grant">admin_grant</option>
              </select>
            </div>
            <div>
              <label className="text-sm font-medium text-slate-700">Duration days</label>
              <input name="durationDays" type="number" min="1" defaultValue="30" className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2" />
            </div>
            <div>
              <label className="text-sm font-medium text-slate-700">Max redemptions</label>
              <input name="maxRedemptions" type="number" min="1" className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2" />
            </div>
            <div>
              <label className="text-sm font-medium text-slate-700">Assign to user ID</label>
              <input name="assignedUserId" className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2 font-mono text-xs" />
            </div>
            <div>
              <label className="text-sm font-medium text-slate-700">Starts at</label>
              <input name="startsAt" type="datetime-local" className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2" />
            </div>
            <div>
              <label className="text-sm font-medium text-slate-700">Ends at</label>
              <input name="endsAt" type="datetime-local" className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2" />
            </div>
            <label className="flex items-center gap-2 text-sm font-medium text-slate-700">
              <input name="isActive" type="checkbox" defaultChecked className="h-4 w-4" />
              Active
            </label>
            <div className="md:col-span-2 xl:col-span-3">
              <label className="text-sm font-medium text-slate-700">Description</label>
              <textarea name="description" rows={3} className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2" />
            </div>
            <div className="md:col-span-2 xl:col-span-3">
              <button className="rounded-xl bg-slate-900 px-4 py-2 text-sm font-medium text-white">
                Save promo code
              </button>
            </div>
          </form>
        </section>

        <section className="rounded-3xl border border-slate-200 bg-white p-6 shadow-soft">
          <h2 className="text-xl font-semibold text-slate-900">Promo codes</h2>
          <div className="mt-5 space-y-4">
            {codes.map((code: any) => (
              <form key={code.id} action={upsertPromoCode} className="rounded-2xl border border-slate-100 p-4">
                <input type="hidden" name="id" value={code.id} />
                <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-4">
                  <div>
                    <label className="text-sm font-medium text-slate-700">Code</label>
                    <input name="code" defaultValue={code.code} required className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2" />
                  </div>
                  <div>
                    <label className="text-sm font-medium text-slate-700">Title</label>
                    <input name="title" defaultValue={code.title} required className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2" />
                  </div>
                  <div>
                    <label className="text-sm font-medium text-slate-700">Plan</label>
                    <select name="planKey" defaultValue={code.plan_key ?? "premium_monthly"} className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2">
                      <option value="premium_monthly">premium_monthly</option>
                      <option value="premium_yearly">premium_yearly</option>
                      <option value="trial">trial</option>
                      <option value="admin_grant">admin_grant</option>
                    </select>
                  </div>
                  <div>
                    <label className="text-sm font-medium text-slate-700">Duration days</label>
                    <input name="durationDays" type="number" min="1" defaultValue={String(code.duration_days ?? 30)} className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2" />
                  </div>
                  <div>
                    <label className="text-sm font-medium text-slate-700">Max redemptions</label>
                    <input name="maxRedemptions" type="number" min="1" defaultValue={code.max_redemptions ?? ""} className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2" />
                  </div>
                  <div>
                    <label className="text-sm font-medium text-slate-700">Assigned user ID</label>
                    <input name="assignedUserId" defaultValue={code.assigned_user_id ?? ""} className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2 font-mono text-xs" />
                  </div>
                  <div>
                    <label className="text-sm font-medium text-slate-700">Starts at</label>
                    <input name="startsAt" type="datetime-local" defaultValue={code.starts_at ? new Date(code.starts_at).toISOString().slice(0, 16) : ""} className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2" />
                  </div>
                  <div>
                    <label className="text-sm font-medium text-slate-700">Ends at</label>
                    <input name="endsAt" type="datetime-local" defaultValue={code.ends_at ? new Date(code.ends_at).toISOString().slice(0, 16) : ""} className="mt-1 w-full rounded-xl border border-slate-200 px-3 py-2" />
                  </div>
                </div>
                <div className="mt-4 grid gap-4 md:grid-cols-[1fr_auto_auto]">
                  <textarea name="description" rows={2} defaultValue={code.description ?? ""} className="rounded-xl border border-slate-200 px-3 py-2" />
                  <label className="flex items-center gap-2 text-sm font-medium text-slate-700">
                    <input name="isActive" type="checkbox" defaultChecked={code.is_active !== false} className="h-4 w-4" />
                    Active
                  </label>
                  <button className="rounded-xl bg-slate-900 px-4 py-2 text-sm font-medium text-white">
                    Save
                  </button>
                </div>
                <div className="mt-3 flex flex-wrap gap-4 text-xs text-slate-500">
                  <span>Redeemed: {code.redeemed_count ?? 0}</span>
                  <span>Updated: {formatDate(code.updated_at)}</span>
                </div>
              </form>
            ))}
          </div>
        </section>

        <section className="rounded-3xl border border-slate-200 bg-white p-6 shadow-soft">
          <h2 className="text-xl font-semibold text-slate-900">Recent redemptions</h2>
          <div className="mt-5 space-y-3">
            {redemptions.length === 0 ? (
              <p className="text-sm text-slate-500">No redemptions yet.</p>
            ) : (
              redemptions.map((row: any) => (
                <div key={row.id} className="rounded-2xl border border-slate-100 p-4 text-sm text-slate-700">
                  <div className="flex flex-wrap items-center gap-3">
                    <strong>{row.code}</strong>
                    <span>{row.status}</span>
                    <span className="font-mono text-xs">{row.user_id}</span>
                  </div>
                  <p className="mt-2">{row.message ?? "Promo code applied."}</p>
                  <p className="mt-1 text-xs text-slate-500">{formatDate(row.created_at)}</p>
                </div>
              ))
            )}
          </div>
        </section>
      </div>
    </AdminShell>
  );
}
