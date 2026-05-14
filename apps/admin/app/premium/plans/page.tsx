import { AdminShell } from "@/components/admin-shell";
import { StatusBadge } from "@/components/status-badge";
import { requireAdmin } from "@/lib/auth/require-admin";
import { upsertPlanProduct } from "@/lib/db/mutations";
import { getPremiumOverviewData } from "@/lib/db/queries";

const publicPremiumPlans = new Set(["premium_monthly", "premium_yearly"]);

export default async function PremiumPlansPage() {
  const admin = await requireAdmin("premium.read");
  const { plans, warnings } = await getPremiumOverviewData(admin.supabase);
  const sortedPlans = [
    ...plans.filter((plan: any) => publicPremiumPlans.has(plan.product_key)),
    ...plans.filter((plan: any) => !publicPremiumPlans.has(plan.product_key)),
  ];

  return (
    <AdminShell email={admin.email} role={admin.role}>
      <section className="grid gap-6 xl:grid-cols-[1.1fr_0.9fr]">
        {warnings.length > 0 ? (
          <div className="xl:col-span-2 rounded-3xl border border-amber-200 bg-amber-50 p-5 text-amber-950">
            <h2 className="text-lg font-semibold">Premium setup warning</h2>
            <div className="mt-3 space-y-2 text-sm">
              {warnings.map((warning) => (
                <p key={warning}>{warning}</p>
              ))}
            </div>
          </div>
        ) : null}
        <div className="rounded-3xl border border-slate-200 bg-white p-6 shadow-soft">
          <h2 className="text-xl font-semibold text-slate-900">Plan products</h2>
          <p className="mt-1 text-sm text-slate-600">
            The public app only sells Premium Monthly and Premium Yearly. Legacy products stay here for compatibility and historic records.
          </p>
          <div className="mt-5 space-y-4">
            {sortedPlans.map((plan: any) => (
              <div key={plan.product_key} className="rounded-2xl border border-slate-100 p-4">
                <div className="flex items-center justify-between">
                  <div>
                    <p className="font-medium text-slate-900">
                      {plan.title?.en ?? plan.product_key}
                    </p>
                    <p className="text-sm text-slate-500">
                      {(plan.amount_cents ?? 0) / 100} {plan.currency ?? "EUR"} • {plan.billing_interval}
                    </p>
                  </div>
                  <StatusBadge
                    value={
                      publicPremiumPlans.has(plan.product_key)
                        ? plan.is_active
                          ? "public"
                          : "inactive"
                        : "legacy"
                    }
                  />
                </div>
              </div>
            ))}
          </div>
        </div>

        <div className="rounded-3xl border border-slate-200 bg-white p-6 shadow-soft">
          <h2 className="text-xl font-semibold text-slate-900">Edit plan</h2>
          <form action={upsertPlanProduct} className="mt-5 space-y-4">
            <input name="productKey" required placeholder="product key" />
            <select name="planType" defaultValue="subscription">
              <option value="free">free</option>
              <option value="subscription">subscription</option>
              <option value="one_time">one_time</option>
              <option value="admin_only">admin_only</option>
            </select>
            <select name="billingInterval" defaultValue="month">
              <option value="none">none</option>
              <option value="month">month</option>
              <option value="year">year</option>
              <option value="one_time">one_time</option>
            </select>
            <div className="grid gap-3 sm:grid-cols-2">
              <input name="amountCents" defaultValue="0" />
              <input name="currency" defaultValue="EUR" />
            </div>
            <input name="stripePriceId" placeholder="stripe price id" />
            <div className="grid gap-3 sm:grid-cols-2">
              <input name="sortOrder" defaultValue="0" />
              <label className="flex items-center gap-3"><input name="isActive" type="checkbox" defaultChecked className="h-4 w-4" /><span>Active</span></label>
            </div>
            <input name="titleEn" placeholder="Title EN" />
            <input name="titleIt" placeholder="Title IT" />
            <textarea name="descriptionEn" placeholder="Description EN" rows={3} />
            <textarea name="descriptionIt" placeholder="Description IT" rows={3} />
            <textarea name="featuresJson" rows={5} defaultValue={"{}"} />
            <textarea name="limitsJson" rows={5} defaultValue={"{}"} />
            <textarea name="providerMetadataJson" rows={4} defaultValue={"{}"} />
            <button className="rounded-xl bg-slate-900 px-4 py-2 text-sm font-medium text-white">
              Save plan
            </button>
          </form>
        </div>
      </section>
    </AdminShell>
  );
}
