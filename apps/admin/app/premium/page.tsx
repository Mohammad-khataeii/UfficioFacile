import Link from "next/link";

import { AdminShell } from "@/components/admin-shell";
import { StatusBadge } from "@/components/status-badge";
import { requireAdmin } from "@/lib/auth/require-admin";
import {
  getContentUnlocks,
  getEntitlements,
  getPaymentEvents,
  getPlanProducts,
  getPremiumEvents,
} from "@/lib/db/queries";

function countBy(rows: any[], key: string, value: unknown) {
  return rows.filter((row) => row?.[key] === value).length;
}

export default async function PremiumPage() {
  const admin = await requireAdmin("premium.read");
  const [entitlements, plans, events, paymentEvents, unlocks] =
    await Promise.all([
      getEntitlements(admin.supabase),
      getPlanProducts(admin.supabase),
      getPremiumEvents(admin.supabase),
      getPaymentEvents(admin.supabase),
      getContentUnlocks(admin.supabase),
    ]);

  return (
    <AdminShell email={admin.email} role={admin.role}>
      <section className="space-y-6">
        <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-5">
          <div className="rounded-3xl border border-slate-200 bg-white p-5 shadow-soft">
            <p className="text-sm text-slate-500">Active premium</p>
            <p className="mt-2 text-3xl font-semibold text-slate-900">
              {countBy(entitlements, "premium_access", true)}
            </p>
          </div>
          <div className="rounded-3xl border border-slate-200 bg-white p-5 shadow-soft">
            <p className="text-sm text-slate-500">Trialing</p>
            <p className="mt-2 text-3xl font-semibold text-slate-900">
              {countBy(entitlements, "status", "trialing")}
            </p>
          </div>
          <div className="rounded-3xl border border-slate-200 bg-white p-5 shadow-soft">
            <p className="text-sm text-slate-500">Admin grants</p>
            <p className="mt-2 text-3xl font-semibold text-slate-900">
              {countBy(entitlements, "source", "admin_grant")}
            </p>
          </div>
          <div className="rounded-3xl border border-slate-200 bg-white p-5 shadow-soft">
            <p className="text-sm text-slate-500">Content unlocks</p>
            <p className="mt-2 text-3xl font-semibold text-slate-900">
              {unlocks.length}
            </p>
          </div>
          <div className="rounded-3xl border border-slate-200 bg-white p-5 shadow-soft">
            <p className="text-sm text-slate-500">Payment failures</p>
            <p className="mt-2 text-3xl font-semibold text-slate-900">
              {countBy(paymentEvents, "status", "failed")}
            </p>
          </div>
        </div>

        <div className="flex flex-wrap gap-3">
          <Link className="rounded-xl bg-slate-900 px-4 py-2 text-sm font-medium text-white" href="/premium/users">
            Manage users
          </Link>
          <Link className="rounded-xl border border-slate-300 px-4 py-2 text-sm font-medium text-slate-700" href="/premium/plans">
            Manage plans
          </Link>
          <Link className="rounded-xl border border-slate-300 px-4 py-2 text-sm font-medium text-slate-700" href="/premium/events">
            View events
          </Link>
        </div>

        <section className="grid gap-6 xl:grid-cols-2">
          <div className="rounded-3xl border border-slate-200 bg-white p-6 shadow-soft">
            <div className="flex items-center justify-between">
              <h2 className="text-xl font-semibold text-slate-900">Plan products</h2>
              <Link className="text-sm font-medium text-slate-600 hover:text-slate-900" href="/premium/plans">
                Open
              </Link>
            </div>
            <div className="mt-4 space-y-3">
              {plans.map((plan: any) => (
                <div key={plan.product_key} className="rounded-2xl border border-slate-100 p-4">
                  <div className="flex items-center justify-between gap-4">
                    <div>
                      <p className="font-medium text-slate-900">{plan.product_key}</p>
                      <p className="text-sm text-slate-500">
                        {(plan.amount_cents ?? 0) / 100} {plan.currency ?? "EUR"} • {plan.billing_interval}
                      </p>
                    </div>
                    <StatusBadge value={plan.plan_type} />
                  </div>
                </div>
              ))}
            </div>
          </div>

          <div className="rounded-3xl border border-slate-200 bg-white p-6 shadow-soft">
            <div className="flex items-center justify-between">
              <h2 className="text-xl font-semibold text-slate-900">Recent premium events</h2>
              <Link className="text-sm font-medium text-slate-600 hover:text-slate-900" href="/premium/events">
                Open
              </Link>
            </div>
            <div className="mt-4 space-y-3">
              {events.slice(0, 12).map((event: any) => (
                <div key={event.id} className="rounded-2xl border border-slate-100 p-4">
                  <div className="flex items-center justify-between">
                    <p className="font-medium text-slate-900">{event.event_type}</p>
                    <StatusBadge value={event.plan ?? event.source ?? "event"} />
                  </div>
                  <p className="mt-2 text-sm text-slate-600">
                    {event.user_id ?? "system"} • {new Date(event.created_at).toLocaleString()}
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
