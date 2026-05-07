import { promises as fs } from "fs";
import path from "path";
import { redirect } from "next/navigation";

import { AdminShell } from "@/components/admin-shell";
import { requireAdmin } from "@/lib/auth/require-admin";

async function importBundledContentAction(formData: FormData) {
  "use server";

  const admin = await requireAdmin("content.manage");
  const mode = String(formData.get("mode") ?? "upsert");
  const filePath = path.join(process.cwd(), "..", "..", "docs", "generated", "cms_bundled_content_export.json");
  const raw = await fs.readFile(filePath, "utf8");
  const parsed = JSON.parse(raw) as {
    richCategories: Record<string, unknown>[];
    healthCategory?: Record<string, unknown>;
    housingCategory?: Record<string, unknown>;
  };

  const allCategories = [
    ...(parsed.richCategories ?? []),
    ...(parsed.healthCategory ? [parsed.healthCategory] : []),
    ...(parsed.housingCategory ? [parsed.housingCategory] : []),
  ];

  for (const category of allCategories) {
    const slug = String(category.id ?? "");
    if (!slug) continue;
    const subcategories = Array.isArray(category.subcategories) ? category.subcategories : [];
    const categoryPayload = {
      slug,
      internal_label: String(category.title ?? slug),
      title: { en: String(category.title ?? slug), it: String(category.titleIt ?? category.title ?? slug) },
      description: { en: String(category.shortDescription ?? ""), it: String(category.shortDescription ?? "") },
      is_active: true,
      sort_order: 0,
      verification_status: "needsReview",
      metadata: { importMode: mode },
      public_snapshot: category,
    };

    await admin.supabase.from("ufficio_cms_categories").upsert(categoryPayload);

    for (let index = 0; index < subcategories.length; index += 1) {
      const item = subcategories[index] as Record<string, unknown>;
      const procedurePayload = {
        category_slug: slug,
        slug: String(item.id ?? `${slug}_${index}`),
        title: { en: String(item.title ?? item.id ?? `Procedure ${index + 1}`), it: String(item.titleIt ?? item.title ?? item.id ?? `Procedura ${index + 1}`) },
        summary: { en: String(item.whatIsIt ?? ""), it: String(item.whatIsIt ?? "") },
        what_is_it: { en: String(item.whatIsIt ?? ""), it: String(item.whatIsIt ?? "") },
        why_you_may_need_it: item.whyDoYouNeedIt ?? [],
        required_documents: item.documents ?? [],
        optional_documents: item.extraDocuments ?? [],
        warnings: item.warnings ?? [],
        status: "published",
        is_active: true,
        sort_order: index,
        verification_status: "needsReview",
        metadata: {
          recommendedChannels: item.recommendedChannels ?? [],
          recommendedContacts: item.recommendedContacts ?? [],
          outputs: item.outputs ?? [],
        },
        public_snapshot: item,
      };

      await admin.supabase.from("ufficio_cms_procedures").upsert(procedurePayload);
    }
  }

  await admin.supabase.from("ufficio_admin_audit_logs").insert({
    actor_user_id: admin.userId,
    actor_email: admin.email,
    actor_role: admin.role,
    action: "cms.import.bundled_content",
    target_table: "ufficio_cms_categories",
    summary: `Imported ${allCategories.length} categories from bundled export`,
    after_value: { mode, categories: allCategories.length },
  });

  redirect("/content");
}

export default async function ContentImportPage() {
  const admin = await requireAdmin("content.read");
  const filePath = path.join(process.cwd(), "..", "..", "docs", "generated", "cms_bundled_content_export.json");
  let preview: any = null;
  try {
    preview = JSON.parse(await fs.readFile(filePath, "utf8"));
  } catch {
    preview = null;
  }

  return (
    <AdminShell email={admin.email} role={admin.role}>
      <section className="grid gap-6 xl:grid-cols-[0.95fr_1.05fr]">
        <div className="rounded-3xl border border-slate-200 bg-white p-6 shadow-soft">
          <h2 className="text-xl font-semibold text-slate-900">Import bundled content</h2>
          <p className="mt-2 text-sm text-slate-600">
            Reads the exported bundled Flutter category tree and upserts it into the CMS.
          </p>
          <form action={importBundledContentAction} className="mt-5 space-y-4">
            <div>
              <label htmlFor="mode">Import mode</label>
              <select id="mode" name="mode" defaultValue="upsert">
                <option value="upsert">upsert</option>
                <option value="overwrite">overwrite</option>
              </select>
            </div>
            <button className="rounded-xl bg-slate-900 px-4 py-2 text-sm font-medium text-white">
              Import now
            </button>
          </form>
        </div>
        <div className="rounded-3xl border border-slate-200 bg-white p-6 shadow-soft">
          <h2 className="text-xl font-semibold text-slate-900">Preview</h2>
          <pre className="mt-4 max-h-[560px] overflow-auto rounded-2xl bg-slate-50 p-4 text-xs">
            {JSON.stringify(preview ?? { error: "Run `dart run tool/export_cms_seed.dart` first." }, null, 2)}
          </pre>
        </div>
      </section>
    </AdminShell>
  );
}
