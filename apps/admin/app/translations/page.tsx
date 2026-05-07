import { AdminShell } from "@/components/admin-shell";
import { DataTable } from "@/components/data-table";
import { requireAdmin } from "@/lib/auth/require-admin";
import { getTranslationsSummary } from "@/lib/db/queries";

const languages = ["en", "it", "fr", "es", "fa", "ar"] as const;

function countCompleteness(rows: any[], fields: string[]) {
  return rows.map((row) => {
    const completeness = Object.fromEntries(
      languages.map((lang) => [
        lang,
        fields.reduce((score, field) => {
          const value = row[field]?.[lang];
          return score + (value ? 1 : 0);
        }, 0),
      ]),
    );
    return {
      slug: row.slug ?? row.id,
      completeness,
    };
  });
}

export default async function TranslationsPage() {
  const admin = await requireAdmin("translations.read");
  const summary = await getTranslationsSummary(admin.supabase);
  const categoryRows = countCompleteness(summary.categories, ["title", "subtitle", "description"]);
  const procedureRows = countCompleteness(summary.procedures, [
    "title",
    "subtitle",
    "summary",
    "what_is_it",
  ]);

  return (
    <AdminShell email={admin.email} role={admin.role}>
      <section className="rounded-3xl border border-slate-200 bg-white p-6 shadow-soft">
        <h2 className="text-xl font-semibold text-slate-900">Translations</h2>
        <p className="mt-1 text-sm text-slate-600">
          Translation completeness across English, Italian, French, Spanish, Persian, and Arabic.
        </p>
      </section>
      <div className="grid gap-6 xl:grid-cols-2">
        <DataTable
          headers={["Category", ...languages]}
          rows={categoryRows.map((row) => [
            row.slug,
            ...languages.map((lang) => `${row.completeness[lang]}/3`),
          ])}
        />
        <DataTable
          headers={["Procedure", ...languages]}
          rows={procedureRows.map((row) => [
            row.slug,
            ...languages.map((lang) => `${row.completeness[lang]}/4`),
          ])}
        />
      </div>
    </AdminShell>
  );
}
