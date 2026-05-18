import Link from "next/link";

import { AdminShell } from "@/components/admin-shell";
import { requireAdmin } from "@/lib/auth/require-admin";
import { getAdminCategoryDetailNormalized } from "@/lib/catalog/queries";
import { upsertCmsCategory, upsertCmsSubcategory } from "@/lib/db/mutations";

export default async function ContentCategoryDetailPage({
  params,
  searchParams,
}: {
  params: Promise<{ slug: string }>;
  searchParams?: Promise<Record<string, string | string[] | undefined>>;
}) {
  const admin = await requireAdmin("content.read");
  const { slug } = await params;
  const query = (await searchParams) ?? {};
  const detail = await getAdminCategoryDetailNormalized(admin.supabase, slug, {
    bootstrapIfEmpty: admin.role === "owner" || admin.role === "admin",
  });
  if (!detail) {
    return (
      <AdminShell email={admin.email} role={admin.role}>
        <section className="rounded-3xl border border-dashed border-slate-300 bg-white p-10 text-center shadow-soft">
          <h2 className="text-2xl font-semibold text-slate-900">Category not found</h2>
          <p className="mt-3 text-sm text-slate-600">
            The admin panel could not find a category with slug <strong>{slug}</strong>.
          </p>
          <Link
            prefetch={false}
            href="/content/categories"
            className="mt-6 inline-flex rounded-xl bg-slate-900 px-4 py-2 text-sm font-medium text-white"
          >
            Back to categories
          </Link>
        </section>
      </AdminShell>
    );
  }

  const { category, subcategories, uncategorizedProcedures } = detail;

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
        {query.cmsMessage ? (
          <div
            className={`mt-4 rounded-2xl p-3 text-sm ${
              query.cmsStatus === "ok"
                ? "bg-emerald-50 text-emerald-900"
                : "bg-rose-50 text-rose-900"
            }`}
          >
            <div className="font-medium">
              {query.cmsStatus === "ok" ? "Saved" : "Save failed"}
            </div>
            <div>{String(query.cmsMessage)}</div>
            {query.cmsStatus === "error" && (query.cmsCode || query.cmsDetails || query.cmsHint) ? (
              <details className="mt-3 rounded-xl border border-rose-200 bg-white/80 p-3 text-xs">
                <summary className="cursor-pointer font-medium">Debug details</summary>
                <div className="mt-2 space-y-1">
                  {query.cmsCode ? <p><strong>Code:</strong> {String(query.cmsCode)}</p> : null}
                  {query.cmsDetails ? <p><strong>Details:</strong> {String(query.cmsDetails)}</p> : null}
                  {query.cmsHint ? <p><strong>Hint:</strong> {String(query.cmsHint)}</p> : null}
                </div>
              </details>
            ) : null}
          </div>
        ) : null}
        <form action={upsertCmsCategory} className="mt-5 grid gap-6 xl:grid-cols-2">
          <div className="space-y-4">
            <input type="hidden" name="redirectTo" value={`/content/categories/${slug}`} />
            <div><label>Slug</label><input name="slug" defaultValue={category.slug} required /></div>
            <div><label>Internal label</label><input name="internalLabel" defaultValue={category.raw.internal_label ?? ""} /></div>
            <div><label>Icon</label><input name="icon" defaultValue={category.icon ?? ""} /></div>
            <div><label>Color</label><input name="color" defaultValue={category.color ?? ""} /></div>
            <div><label>Sort order</label><input name="sortOrder" defaultValue={category.sortOrder} /></div>
            <div><label>Verification</label><select name="verificationStatus" defaultValue={category.verificationStatus}><option value="verified">verified</option><option value="needsReview">needsReview</option><option value="unverified">unverified</option></select></div>
            <label className="flex items-center gap-3"><input className="h-4 w-4" type="checkbox" name="isActive" defaultChecked={category.isPublished} /><span>Published</span></label>
            <div><label>Premium visibility</label><select name="premiumVisibility" defaultValue={category.premiumVisibility}><option value="free">free</option><option value="premium_preview">premium_preview</option><option value="premium_only">premium_only</option><option value="hidden">hidden</option></select></div>
            <div><label>Required plan</label><select name="requiredPlan" defaultValue={category.premiumVisibility === "free" ? "" : "premium"}><option value="">free</option><option value="premium">premium</option></select></div>
            <label className="flex items-center gap-3"><input className="h-4 w-4" type="checkbox" name="allowSingleUnlock" defaultChecked={category.raw.allow_single_unlock ?? true} /><span>Allow single unlock</span></label>
            <div><label>Single unlock price (cents)</label><input name="singleUnlockPriceCents" defaultValue={category.raw.single_unlock_price_cents ?? ""} /></div>
            <div><label>Tags</label><textarea name="tags" rows={4} defaultValue={category.tags.join("\n")} /></div>
            <div><label>Synonyms</label><textarea name="synonyms" rows={5} defaultValue={category.synonyms.join("\n")} /></div>
            <div><label>Search keywords</label><textarea name="searchableKeywords" rows={5} defaultValue={category.searchableKeywords.join("\n")} /></div>
            <div><label>Admin notes</label><textarea name="adminNotes" rows={8} defaultValue={category.adminNotes ?? ""} /></div>
          </div>
          <div className="space-y-4">
            <h3 className="text-lg font-semibold text-slate-900">Translations</h3>
            <div><label>Title (EN)</label><input name="titleEn" defaultValue={category.title.en ?? ""} required /></div>
            <div><label>Title (IT)</label><input name="titleIt" defaultValue={category.title.it ?? ""} /></div>
            <div><label>Title (FR)</label><input name="titleFr" defaultValue={category.title.fr ?? ""} /></div>
            <div><label>Title (ES)</label><input name="titleEs" defaultValue={category.title.es ?? ""} /></div>
            <div><label>Title (FA)</label><input name="titleFa" defaultValue={category.title.fa ?? ""} /></div>
            <div><label>Title (AR)</label><input name="titleAr" defaultValue={category.title.ar ?? ""} /></div>
            <div><label>Subtitle (EN)</label><textarea name="subtitleEn" rows={2} defaultValue={category.subtitle.en ?? ""} /></div>
            <div><label>Description (EN)</label><textarea name="descriptionEn" rows={6} defaultValue={category.description.en ?? ""} /></div>
            <div><label>Description (IT)</label><textarea name="descriptionIt" rows={4} defaultValue={category.description.it ?? ""} /></div>
            <div><label>Description (FR)</label><textarea name="descriptionFr" rows={4} defaultValue={category.description.fr ?? ""} /></div>
            <div><label>Premium teaser (EN)</label><textarea name="premiumTeaserEn" rows={4} defaultValue={category.premiumTeaser.en ?? category.description.en ?? ""} /></div>
            <div><label>Premium reason (EN)</label><textarea name="premiumReasonEn" rows={4} defaultValue={category.premiumReason.en ?? ""} /></div>
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
          <h3 className="text-lg font-semibold text-slate-900">Subcategories and procedures</h3>
          <span className="text-sm text-slate-500">{category.procedureCount} procedures</span>
        </div>
        <div className="mt-4 space-y-4">
          {subcategories.map((subcategory) => (
            <div key={subcategory.id} className="rounded-2xl border border-slate-200 p-4">
              <div className="flex items-center justify-between gap-4">
                <div>
                  <h4 className="font-semibold text-slate-900">
                    {subcategory.title.en ?? subcategory.slug}
                  </h4>
                  <p className="text-sm text-slate-500">
                    {subcategory.slug} • {subcategory.procedureCount} procedures
                  </p>
                </div>
                <span className="text-sm font-medium text-slate-600">
                  {subcategory.premiumVisibility}
                </span>
              </div>
              <form action={upsertCmsSubcategory} className="mt-4 grid gap-3 rounded-2xl bg-slate-50 p-4 md:grid-cols-2">
                <input type="hidden" name="redirectTo" value={`/content/categories/${slug}`} />
                <input type="hidden" name="parentSlug" value={slug} />
                <div><label>Subcategory slug</label><input name="slug" defaultValue={subcategory.slug} required /></div>
                <div><label>Sort order</label><input name="sortOrder" defaultValue={subcategory.sortOrder} /></div>
                <div><label>Title (EN)</label><input name="titleEn" defaultValue={subcategory.title.en ?? subcategory.slug} required /></div>
                <div><label>Title (IT)</label><input name="titleIt" defaultValue={subcategory.title.it ?? ""} /></div>
                <div className="md:col-span-2"><label>Description (EN)</label><textarea name="descriptionEn" rows={3} defaultValue={subcategory.description.en ?? ""} /></div>
                <div><label>Premium visibility</label><select name="premiumVisibility" defaultValue={subcategory.premiumVisibility}><option value="free">free</option><option value="premium_preview">premium_preview</option><option value="premium_only">premium_only</option><option value="hidden">hidden</option></select></div>
                <div><label>Required plan</label><select name="requiredPlan" defaultValue={subcategory.premiumVisibility === "free" ? "" : "premium"}><option value="">free</option><option value="premium">premium</option></select></div>
                <div><label>Verification</label><select name="verificationStatus" defaultValue={subcategory.isPublished ? "verified" : "needsReview"}><option value="verified">verified</option><option value="needsReview">needsReview</option><option value="unverified">unverified</option></select></div>
                <label className="flex items-center gap-3"><input className="h-4 w-4" type="checkbox" name="isActive" defaultChecked={subcategory.isPublished} /><span>Published</span></label>
                <div className="md:col-span-2"><label>Admin notes</label><textarea name="adminNotes" rows={3} defaultValue="" /></div>
                <div className="md:col-span-2">
                  <button className="rounded-xl border border-slate-300 px-4 py-2 text-sm font-medium text-slate-900">
                    Save subcategory
                  </button>
                </div>
              </form>
              <div className="mt-4 grid gap-3">
                {subcategory.procedures.map((procedure) => (
                  <div
                    key={`${procedure.categorySlug}:${procedure.slug}`}
                    className="flex items-center justify-between rounded-2xl border border-slate-100 px-4 py-3"
                  >
                    <div>
                      <div className="font-medium text-slate-900">
                        {procedure.title.en ?? procedure.slug}
                      </div>
                      <div className="text-sm text-slate-500">
                        {procedure.slug} • {procedure.status}
                      </div>
                    </div>
                    <Link
                      className="text-sm font-medium text-slate-900"
                      href={`/content/procedures/${procedure.categorySlug}/${procedure.slug}`}
                    >
                      Open
                    </Link>
                  </div>
                ))}
              </div>
            </div>
          ))}
          {uncategorizedProcedures.length > 0 ? (
            <div className="rounded-2xl border border-dashed border-slate-300 p-4">
              <h4 className="font-semibold text-slate-900">Uncategorized procedures</h4>
              <div className="mt-4 grid gap-3">
                {uncategorizedProcedures.map((procedure) => (
                  <div
                    key={`${procedure.categorySlug}:${procedure.slug}`}
                    className="flex items-center justify-between rounded-2xl border border-slate-100 px-4 py-3"
                  >
                    <div>
                      <div className="font-medium text-slate-900">
                        {procedure.title.en ?? procedure.slug}
                      </div>
                      <div className="text-sm text-slate-500">{procedure.slug}</div>
                    </div>
                    <Link
                      className="text-sm font-medium text-slate-900"
                      href={`/content/procedures/${procedure.categorySlug}/${procedure.slug}`}
                    >
                      Open
                    </Link>
                  </div>
                ))}
              </div>
            </div>
          ) : null}
        </div>
      </section>
    </AdminShell>
  );
}
