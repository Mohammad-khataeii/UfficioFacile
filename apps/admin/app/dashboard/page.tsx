import { AdminShell } from "@/components/admin-shell";
import { StatusBadge } from "@/components/status-badge";
import { requireAdmin } from "@/lib/auth/require-admin";
import { getDashboardMetrics } from "@/lib/db/queries";

function MetricCard({ label, value }: { label: string; value: string | number }) {
  return (
    <div className="rounded-3xl border border-slate-200 bg-white p-5 shadow-soft">
      <p className="text-sm text-slate-500">{label}</p>
      <p className="mt-2 text-3xl font-semibold text-slate-900">{value}</p>
    </div>
  );
}

export default async function DashboardPage() {
  const admin = await requireAdmin("dashboard.read");
  const metrics = await getDashboardMetrics(admin.supabase);
  const [
    appConfigCheck,
    premiumConfigCheck,
    adminFunctionCheck,
  ] = await Promise.all([
    admin.supabase.from("ufficio_app_public_config").select("key").limit(1),
    admin.supabase.from("ufficio_premium_public_config").select("key").limit(1),
    admin.supabase.rpc("is_ufficio_admin"),
  ]);

  const warnings = [
    !appConfigCheck.data?.length && "Missing rows in ufficio_app_public_config.",
    !premiumConfigCheck.data?.length && "Missing rows in ufficio_premium_public_config.",
    adminFunctionCheck.error && "RPC is_ufficio_admin() failed.",
  ].filter((warning): warning is string => Boolean(warning));

  return (
    <AdminShell email={admin.email} role={admin.role}>
      <section className="grid gap-4 md:grid-cols-2 xl:grid-cols-4">
        <MetricCard label="Total users" value={metrics.totalUsers} />
        <MetricCard label="Premium users" value={metrics.premiumUsers} />
        <MetricCard label="Free users" value={metrics.freeUsers} />
        <MetricCard label="Open problem requests" value={metrics.openProblemRequests} />
        <MetricCard
          label="Open consultancy requests"
          value={metrics.openConsultancyRequests}
        />
        <MetricCard label="CMS categories" value={metrics.cmsCategories} />
        <MetricCard label="CMS procedures" value={metrics.cmsProcedures} />
        <MetricCard label="CMS blocks" value={metrics.cmsBlocks} />
      </section>

      <section className="grid gap-6 lg:grid-cols-[1.25fr_0.75fr]">
        <div className="rounded-3xl border border-slate-200 bg-white p-6 shadow-soft">
          <div className="flex items-center justify-between">
            <h2 className="text-lg font-semibold text-slate-900">Latest admin activity</h2>
            <StatusBadge value={`${metrics.auditRows.length} entries`} />
          </div>
          <div className="mt-5 space-y-3">
            {metrics.auditRows.length === 0 ? (
              <p className="text-sm text-slate-500">No audit rows yet.</p>
            ) : (
              metrics.auditRows.map((row: any) => (
                <div key={row.id} className="rounded-2xl border border-slate-100 p-4">
                  <div className="flex items-center justify-between gap-3">
                    <p className="font-medium text-slate-900">{row.action}</p>
                    <StatusBadge value={row.actor_role} />
                  </div>
                  <p className="mt-2 text-sm text-slate-600">
                    {row.summary || row.target_table} • {row.actor_email || "unknown"}
                  </p>
                </div>
              ))
            )}
          </div>
        </div>

        <div className="space-y-6">
          <div className="rounded-3xl border border-slate-200 bg-white p-6 shadow-soft">
            <h2 className="text-lg font-semibold text-slate-900">Supabase status</h2>
            <div className="mt-4 space-y-3 text-sm text-slate-600">
              <p>
                Authenticated admin user: <span className="font-medium">{admin.email}</span>
              </p>
              <p>
                Role helper:{" "}
                <span className="font-medium">
                  {adminFunctionCheck.error ? "failed" : "ok"}
                </span>
              </p>
              <p>
                Public config rows:{" "}
                <span className="font-medium">{appConfigCheck.data?.length ?? 0}</span>
              </p>
              <p>
                Premium config rows:{" "}
                <span className="font-medium">{premiumConfigCheck.data?.length ?? 0}</span>
              </p>
            </div>
          </div>

          <div className="rounded-3xl border border-slate-200 bg-white p-6 shadow-soft">
            <h2 className="text-lg font-semibold text-slate-900">Warnings</h2>
            <div className="mt-4 space-y-2 text-sm text-slate-600">
              {warnings.length === 0 ? (
                <p>No immediate schema warnings detected.</p>
              ) : (
                warnings.map((warning) => (
                  <div key={warning} className="rounded-2xl bg-amber-50 p-3 text-amber-900">
                    {warning}
                  </div>
                ))
              )}
            </div>
          </div>
        </div>
      </section>
    </AdminShell>
  );
}
