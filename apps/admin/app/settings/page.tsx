import { AdminShell } from "@/components/admin-shell";
import { requireAdmin } from "@/lib/auth/require-admin";
import { updatePublicConfig } from "@/lib/db/mutations";
import { getSettingsData } from "@/lib/db/queries";

function ConfigForm({
  table,
  rows,
}: {
  table: "ufficio_app_public_config" | "ufficio_premium_public_config";
  rows: any[];
}) {
  return (
    <div className="rounded-3xl border border-slate-200 bg-white p-6 shadow-soft">
      <h2 className="text-xl font-semibold text-slate-900">{table}</h2>
      <div className="mt-5 space-y-4">
        {rows.map((row) => (
          <form
            key={row.key}
            action={updatePublicConfig.bind(null, table)}
            className="rounded-2xl border border-slate-100 p-4"
          >
            <input type="hidden" name="key" value={row.key} />
            <div className="mb-3 text-sm font-medium text-slate-900">{row.key}</div>
            <textarea
              name="value"
              rows={4}
              defaultValue={JSON.stringify(row.value, null, 2)}
              className="font-mono text-xs"
            />
            <button className="mt-3 rounded-xl bg-slate-900 px-4 py-2 text-sm font-medium text-white">
              Save
            </button>
          </form>
        ))}
      </div>
    </div>
  );
}

export default async function SettingsPage() {
  const admin = await requireAdmin("settings.read");
  const { appConfig, premiumConfig } = await getSettingsData(admin.supabase);

  return (
    <AdminShell email={admin.email} role={admin.role}>
      <div className="grid gap-6 xl:grid-cols-2">
        <ConfigForm table="ufficio_app_public_config" rows={appConfig} />
        <ConfigForm table="ufficio_premium_public_config" rows={premiumConfig} />
      </div>
    </AdminShell>
  );
}
