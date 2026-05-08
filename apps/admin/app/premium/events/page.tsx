import { AdminShell } from "@/components/admin-shell";
import { DataTable } from "@/components/data-table";
import { StatusBadge } from "@/components/status-badge";
import { requireAdmin } from "@/lib/auth/require-admin";
import { getPaymentEvents, getPremiumEvents } from "@/lib/db/queries";

export default async function PremiumEventsPage() {
  const admin = await requireAdmin("premium.read");
  const [events, paymentEvents] = await Promise.all([
    getPremiumEvents(admin.supabase),
    getPaymentEvents(admin.supabase),
  ]);

  return (
    <AdminShell email={admin.email} role={admin.role}>
      <section className="grid gap-6 xl:grid-cols-2">
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
