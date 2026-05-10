import { notFound } from "next/navigation";
import Link from "next/link";

import { AdminShell } from "@/components/admin-shell";
import { requireAdmin } from "@/lib/auth/require-admin";
import {
  getAdminCategoryBySlug,
  getAdminProceduresByCategorySlug,
  getProcedureRoutePath,
} from "@/lib/content/load-content-tree";
import { upsertCmsCategory } from "@/lib/db/mutations";

export default async function ContentCategoryDetailPage({
  params,
}: {
  params: Promise<{ slug: string }>;
}) {
  const admin = await requireAdmin("content.read");
  const { slug } = await params;
  const category = await getAdminCategoryBySlug(admin.supabase, slug, {
    bootstrapIfEmpty: admin.role === "owner" || admin.role === "admin",
  });
  const procedures = await getAdminProceduresByCategorySlug(admin.supabase, slug, {
    bootstrapIfEmpty: admin.role === "owner" || admin.role === "admin",
  });
  if (!category) notFound();

  return (
    <AdminShell email={admin.email} role={admin.role}>
      <section className="rounded-3xl border border-slate-200 bg-white p-6 shadow-soft">
        <h2 className="text-xl font-semibold text-slate-900">
          Category editor: {slug}
        </h2>
        {category.source === "bundled" ? (
          <div className="mt-4 rounded-2xl bg-amber-50 p-3 text-sm text-amber-900">
            This category is coming from the bundled app fallback because Supabase CMS is still empty.
            Saving here will create the CMS row in Supabase.
          </div>
        ) : null}
        <form action={upsertCmsCategory} className="mt-5 grid gap-6 xl:grid-cols-2">
          <div className="space-y-4">
            <div><label>Slug</label><input name="slug" defaultValue={category.slug} required /></div>
            <div><label>Internal label</label><input name="internalLabel" defaultValue={category.internal_label ?? ""} /></div>
            <div><label>Icon</label><input name="icon" defaultValue={category.icon ?? ""} /></div>
            <div><label>Color</label><input name="color" defaultValue={category.color ?? ""} /></div>
            <div><label>Sort order</label><input name="sortOrder" defaultValue={category.sort_order ?? 0} /></div>
            <div><label>Verification</label><select name="verificationStatus" defaultValue={category.verification_status}><option value="verified">verified</option><option value="needsReview">needsReview</option><option value="unverified">unverified</option></select></div>
            <label className="flex items-center gap-3"><input className="h-4 w-4" type="checkbox" name="isActive" defaultChecked={category.is_active} /><span>Active</span></label>
            <label className="flex items-center gap-3"><input className="h-4 w-4" type="checkbox" name="isPremium" defaultChecked={category.is_premium} /><span>Premium</span></label>
            <div><label>Monetization type</label><select name="monetizationType" defaultValue={(category as any).monetization_type ?? (category.is_premium ? "premium_money_value" : "free")}><option value="free">free</option><option value="premium">premium</option><option value="premium_money_value">premium_money_value</option><option value="premium_financial_strategy">premium_financial_strategy</option><option value="premium_comparison_tool">premium_comparison_tool</option></select></div>
            <label className="flex items-center gap-3"><input className="h-4 w-4" type="checkbox" name="allowSingleUnlock" defaultChecked={(category as any).allow_single_unlock ?? true} /><span>Allow single unlock</span></label>
            <div><label>Single unlock price (cents)</label><input name="singleUnlockPriceCents" defaultValue={(category as any).single_unlock_price_cents ?? ""} /></div>
            <div><label>Tags</label><textarea name="tags" rows={4} defaultValue={(category.tags ?? []).join("\n")} /></div>
            <div><label>Synonyms</label><textarea name="synonyms" rows={5} defaultValue={(category.synonyms ?? []).join("\n")} /></div>
            <div><label>Search keywords</label><textarea name="searchableKeywords" rows={5} defaultValue={(category.searchable_keywords ?? []).join("\n")} /></div>
            <div><label>Admin notes</label><textarea name="adminNotes" rows={8} defaultValue={category.admin_notes ?? ""} /></div>
          </div>
          <div className="space-y-4">
            <h3 className="text-lg font-semibold text-slate-900">Translations</h3>
            <div><label>Title (EN)</label><input name="titleEn" defaultValue={category.title?.en ?? ""} required /></div>
            <div><label>Title (IT)</label><input name="titleIt" defaultValue={category.title?.it ?? ""} /></div>
            <div><label>Title (FR)</label><input name="titleFr" defaultValue={category.title?.fr ?? ""} /></div>
            <div><label>Title (ES)</label><input name="titleEs" defaultValue={category.title?.es ?? ""} /></div>
            <div><label>Title (FA)</label><input name="titleFa" defaultValue={category.title?.fa ?? ""} /></div>
            <div><label>Title (AR)</label><input name="titleAr" defaultValue={category.title?.ar ?? ""} /></div>
            <div><label>Subtitle (EN)</label><textarea name="subtitleEn" rows={2} defaultValue={category.subtitle?.en ?? ""} /></div>
            <div><label>Description (EN)</label><textarea name="descriptionEn" rows={6} defaultValue={category.description?.en ?? ""} /></div>
            <div><label>Description (IT)</label><textarea name="descriptionIt" rows={4} defaultValue={category.description?.it ?? ""} /></div>
            <div><label>Description (FR)</label><textarea name="descriptionFr" rows={4} defaultValue={category.description?.fr ?? ""} /></div>
            <div><label>Premium teaser (EN)</label><textarea name="premiumTeaserEn" rows={4} defaultValue={(category as any).premium_teaser?.en ?? category.description?.en ?? ""} /></div>
            <div><label>Premium reason (EN)</label><textarea name="premiumReasonEn" rows={4} defaultValue={(category as any).premium_reason?.en ?? ""} /></div>
          </div>
          <div className="xl:col-span-2">
            <button className="rounded-xl bg-slate-900 px-4 py-2 text-sm font-medium text-white">
              Save category
            </button>
          </div>
        </form>
      </section>

      <section className="mt-6 rounded-3xl border border-slate-200 bg-white p-6 shadow-soft">
        <div className="flex items-center justify-between">
          <h3 className="text-lg font-semibold text-slate-900">Procedures in this category</h3>
          <span className="text-sm text-slate-500">{procedures.length} items</span>
        </div>
        <div className="mt-4 grid gap-3">
          {procedures.map((procedure) => (
            <div
              key={getProcedureRoutePath(procedure)}
              className="flex items-center justify-between rounded-2xl border border-slate-200 px-4 py-3"
            >
              <div>
                <div className="font-medium text-slate-900">
                  {procedure.title?.en || procedure.slug}
                </div>
                <div className="text-sm text-slate-500">
                  {procedure.subcategory_slug
                    ? `${procedure.subcategory_slug} • ${procedure.slug}`
                    : procedure.slug}
                </div>
              </div>
              <Link
                className="text-sm font-medium text-slate-900"
                href={getProcedureRoutePath(procedure)}
              >
                Open
              </Link>
            </div>
          ))}
        </div>
      </section>
    </AdminShell>
  );
}
