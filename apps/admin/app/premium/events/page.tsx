import { AdminShell } from "@/components/admin-shell";
import { DataTable } from "@/components/data-table";
import { StatusBadge } from "@/components/status-badge";
import { requireAdmin } from "@/lib/auth/require-admin";
import { getPremiumOverviewData } from "@/lib/db/queries";

export default async function PremiumEventsPage() {
  const admin = await requireAdmin("premium.read");
  const { events, paymentEvents, warnings } = await getPremiumOverviewData(
    admin.supabase,
  );

  return (
    <AdminShell email={admin.email} role={admin.role}>
      <section className="grid gap-6 xl:grid-cols-2">
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
          <h2 className="text-xl font-semibold text-slate-900">Premium events</h2>
          <div className="mt-5">
            <DataTable
              headers={["Type", "User", "Plan", "Source", "Created"]}
              rows={events.map((row: any) => [
                row.event_type,
                <code key="user" className="text-xs">{row.user_id ?? "—"}</code>,
                <StatusBadge key="plan" value={row.plan ?? "event"} />,
                row.source ?? "system",
                new Date(row.created_at).toLocaleString(),
              ])}
            />
          </div>
        </div>

        <div className="rounded-3xl border border-slate-200 bg-white p-6 shadow-soft">
          <h2 className="text-xl font-semibold text-slate-900">Payment events</h2>
          <div className="mt-5">
            <DataTable
              headers={["Provider", "Type", "Product", "Status", "Created"]}
              rows={paymentEvents.map((row: any) => [
                row.provider,
                row.event_type,
                row.product_key ?? "—",
                <StatusBadge key="status" value={row.status ?? "event"} />,
                new Date(row.created_at).toLocaleString(),
              ])}
            />
          </div>
        </div>
      </section>
    </AdminShell>
  );
}
