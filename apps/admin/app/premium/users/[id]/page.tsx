import Link from "next/link";

import { AdminShell } from "@/components/admin-shell";
import { DataTable } from "@/components/data-table";
import { StatusBadge } from "@/components/status-badge";
import { requireAdmin } from "@/lib/auth/require-admin";
import {
  getAuthUser,
  getUserBundle,
  safeSelectRows,
} from "@/lib/db/queries";
import {
  grantContentUnlock,
  resetUsageCounters,
  revokeContentUnlock,
  updateEntitlement,
} from "@/lib/db/mutations";

export default async function PremiumUserDetailPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const admin = await requireAdmin("premium.read");
  const { id } = await params;
  const [authUser, bundle, premiumEvents, auditRows] = await Promise.all([
    getAuthUser(id),
    getUserBundle(admin.supabase, id),
    safeSelectRows(admin.supabase, "ufficio_premium_events", (query) =>
      query.eq("user_id", id).order("created_at", { ascending: false }).limit(50),
    ),
    safeSelectRows(admin.supabase, "ufficio_admin_audit_logs", (query) =>
      query.eq("target_user_id", id).order("created_at", { ascending: false }).limit(50),
    ),
  ]);

  const warnings = [
    ...bundle.warnings,
    !authUser ? "This auth account no longer exists. The user was likely deleted." : null,
    premiumEvents.warning,
    auditRows.warning,
  ].filter((warning): warning is string => Boolean(warning));
  const entitlement = bundle.entitlement;

  return (
    <AdminShell email={admin.email} role={admin.role}>
      <section className="space-y-6">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-semibold text-slate-900">Premium user detail</h1>
            <p className="mt-1 text-sm text-slate-500">
              {authUser?.email ?? id}
            </p>
          </div>
          <Link
            href="/premium/users"
            className="rounded-xl border border-slate-300 px-4 py-2 text-sm font-medium text-slate-700"
          >
            Back to users
          </Link>
        </div>

        {warnings.length > 0 ? (
          <div className="rounded-3xl border border-amber-200 bg-amber-50 p-5 text-amber-950">
            <h2 className="text-lg font-semibold">Premium setup warning</h2>
            <div className="mt-3 space-y-2 text-sm">
              {warnings.map((warning) => (
                <p key={warning}>{warning}</p>
              ))}
            </div>
          </div>
        ) : null}

        <div className="grid gap-6 xl:grid-cols-[1.1fr_0.9fr]">
          <div className="space-y-6">
            <div className="rounded-3xl border border-slate-200 bg-white p-6 shadow-soft">
              <h2 className="text-xl font-semibold text-slate-900">User</h2>
              <dl className="mt-4 grid gap-3 text-sm sm:grid-cols-2">
                <div>
                  <dt className="text-slate-500">User ID</dt>
                  <dd className="font-mono text-xs text-slate-900">{id}</dd>
                </div>
                <div>
                  <dt className="text-slate-500">Email</dt>
                  <dd className="text-slate-900">{authUser?.email ?? bundle.profile?.email ?? "—"}</dd>
                </div>
                <div>
                  <dt className="text-slate-500">Full name</dt>
                  <dd className="text-slate-900">{bundle.profile?.full_name ?? "—"}</dd>
                </div>
                <div>
                  <dt className="text-slate-500">City</dt>
                  <dd className="text-slate-900">{bundle.profile?.city ?? "—"}</dd>
                </div>
              </dl>
            </div>

            <div className="rounded-3xl border border-slate-200 bg-white p-6 shadow-soft">
              <h2 className="text-xl font-semibold text-slate-900">Entitlement</h2>
              <dl className="mt-4 grid gap-3 text-sm sm:grid-cols-2">
                <div>
                  <dt className="text-slate-500">Plan</dt>
                  <dd><StatusBadge value={entitlement?.plan ?? "free"} /></dd>
                </div>
                <div>
                  <dt className="text-slate-500">Status</dt>
                  <dd><StatusBadge value={entitlement?.status ?? "active"} /></dd>
                </div>
                <div>
                  <dt className="text-slate-500">Premium access</dt>
                  <dd>{entitlement?.premium_access ? "yes" : "no"}</dd>
                </div>
                <div>
                  <dt className="text-slate-500">Source</dt>
                  <dd>{entitlement?.source ?? "system"}</dd>
                </div>
                <div>
                  <dt className="text-slate-500">Period start</dt>
                  <dd>{entitlement?.current_period_start ? new Date(entitlement.current_period_start).toLocaleString() : "—"}</dd>
                </div>
                <div>
                  <dt className="text-slate-500">Period end</dt>
                  <dd>{entitlement?.current_period_end ? new Date(entitlement.current_period_end).toLocaleString() : "—"}</dd>
                </div>
                <div>
                  <dt className="text-slate-500">Stripe customer</dt>
                  <dd className="font-mono text-xs text-slate-900">{entitlement?.stripe_customer_id ?? entitlement?.provider_customer_id ?? "—"}</dd>
                </div>
                <div>
                  <dt className="text-slate-500">Stripe subscription</dt>
                  <dd className="font-mono text-xs text-slate-900">{entitlement?.stripe_subscription_id ?? entitlement?.provider_subscription_id ?? "—"}</dd>
                </div>
                <div>
                  <dt className="text-slate-500">Stripe price</dt>
                  <dd className="font-mono text-xs text-slate-900">{entitlement?.stripe_price_id ?? entitlement?.provider_price_id ?? "—"}</dd>
                </div>
              </dl>
            </div>

            <div className="rounded-3xl border border-slate-200 bg-white p-6 shadow-soft">
              <h2 className="text-xl font-semibold text-slate-900">Usage counters</h2>
              <div className="mt-5">
                <DataTable
                  headers={["Period", "Packs", "Requests", "Docs", "Contacts", "Costs", "Consultancy"]}
                  rows={bundle.usageCounters.map((row: any) => [
                    row.period_key,
                    row.generated_packs_used ?? 0,
                    row.saved_requests_used ?? 0,
                    row.documents_used ?? 0,
                    row.contacts_used ?? 0,
                    row.cost_items_used ?? 0,
                    row.consultancy_requests_used ?? 0,
                  ])}
                />
              </div>
            </div>

            <div className="rounded-3xl border border-slate-200 bg-white p-6 shadow-soft">
              <h2 className="text-xl font-semibold text-slate-900">Content unlocks</h2>
              <div className="mt-5 space-y-4">
                {bundle.unlocks.map((row: any) => (
                  <div key={`${row.category_slug}-${row.procedure_slug}`} className="rounded-2xl border border-slate-100 p-4">
                    <div className="flex flex-wrap items-center justify-between gap-3">
                      <div>
                        <p className="font-medium text-slate-900">
                          {row.category_slug} / {row.procedure_slug}
                        </p>
                        <p className="text-sm text-slate-500">
                          {row.unlock_type} • {row.amount_cents ? `${(row.amount_cents / 100).toFixed(2)} ${row.currency ?? "EUR"}` : "manual"}
                        </p>
                      </div>
                      <StatusBadge value={row.status} />
                    </div>
                    <form action={revokeContentUnlock} className="mt-3">
                      <input type="hidden" name="userId" value={id} />
                      <input type="hidden" name="categorySlug" value={row.category_slug} />
                      <input type="hidden" name="procedureSlug" value={row.procedure_slug} />
                      <button className="rounded-xl border border-rose-300 px-3 py-2 text-sm font-medium text-rose-700">
                        Revoke unlock
                      </button>
                    </form>
                  </div>
                ))}
              </div>
            </div>
          </div>

          <div className="space-y-6">
            <div className="rounded-3xl border border-slate-200 bg-white p-6 shadow-soft">
              <h2 className="text-xl font-semibold text-slate-900">Change plan</h2>
              <form action={updateEntitlement} className="mt-5 space-y-4">
                <input type="hidden" name="userId" value={id} />
                <select name="plan" defaultValue={entitlement?.plan ?? "free"}>
                  <option value="free">free</option>
                  <option value="plus_monthly">plus_monthly</option>
                  <option value="plus_yearly">plus_yearly</option>
                  <option value="premium_monthly">premium_monthly</option>
                  <option value="premium_yearly">premium_yearly</option>
                  <option value="admin_grant">admin_grant</option>
                  <option value="lifetime">lifetime</option>
                  <option value="trial">trial</option>
                </select>
                <select name="status" defaultValue={entitlement?.status ?? "active"}>
                  <option value="active">active</option>
                  <option value="trialing">trialing</option>
                  <option value="cancelled">cancelled</option>
                  <option value="expired">expired</option>
                  <option value="revoked">revoked</option>
                </select>
                <div className="grid gap-3 sm:grid-cols-2">
                  <input name="periodDays" defaultValue="30" />
                  <input name="freePackLimit" defaultValue={String(entitlement?.metadata?.free_pack_limit ?? 3)} />
                </div>
                <input name="freePacksUsed" defaultValue={String(entitlement?.metadata?.free_packs_used ?? 0)} />
                <label className="flex items-center gap-3">
                  <input name="premiumAccess" type="checkbox" defaultChecked={entitlement?.premium_access ?? false} className="h-4 w-4" />
                  <span>Force premium access</span>
                </label>
                <button className="rounded-xl bg-slate-900 px-4 py-2 text-sm font-medium text-white">
                  Save entitlement
                </button>
              </form>
            </div>

            <div className="rounded-3xl border border-slate-200 bg-white p-6 shadow-soft">
              <h2 className="text-xl font-semibold text-slate-900">Reset usage</h2>
              <form action={resetUsageCounters} className="mt-5">
                <input type="hidden" name="userId" value={id} />
                <button className="rounded-xl border border-slate-300 px-4 py-2 text-sm font-medium text-slate-700">
                  Reset counters
                </button>
              </form>
            </div>

            <div className="rounded-3xl border border-slate-200 bg-white p-6 shadow-soft">
              <h2 className="text-xl font-semibold text-slate-900">Grant content unlock</h2>
              <form action={grantContentUnlock} className="mt-5 space-y-4">
                <input type="hidden" name="userId" value={id} />
                <input name="categorySlug" placeholder="Category slug" required />
                <input name="procedureSlug" placeholder="Procedure slug" required />
                <input name="amountCents" defaultValue="399" />
                <input name="currency" defaultValue="EUR" />
                <button className="rounded-xl bg-slate-900 px-4 py-2 text-sm font-medium text-white">
                  Grant unlock
                </button>
              </form>
            </div>

            <div className="rounded-3xl border border-slate-200 bg-white p-6 shadow-soft">
              <h2 className="text-xl font-semibold text-slate-900">Recent premium events</h2>
              <div className="mt-5">
                <DataTable
                  headers={["Event", "Plan", "Source", "Created"]}
                  rows={premiumEvents.data.map((row: any) => [
                    row.event_type,
                    row.plan ?? "—",
                    row.source ?? "system",
                    new Date(row.created_at).toLocaleString(),
                  ])}
                />
              </div>
            </div>

            <div className="rounded-3xl border border-slate-200 bg-white p-6 shadow-soft">
              <h2 className="text-xl font-semibold text-slate-900">Admin audit</h2>
              <div className="mt-5">
                <DataTable
                  headers={["Action", "Actor", "Created"]}
                  rows={auditRows.data.map((row: any) => [
                    row.action,
                    row.actor_email ?? row.actor_user_id ?? "—",
                    new Date(row.created_at).toLocaleString(),
                  ])}
                />
              </div>
            </div>
          </div>
        </div>
      </section>
    </AdminShell>
  );
}
