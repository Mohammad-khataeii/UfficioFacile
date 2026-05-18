import Link from "next/link";

import { AdminShell } from "@/components/admin-shell";
import { JsonEditor } from "@/components/json-editor";
import { requireAdmin } from "@/lib/auth/require-admin";
import { getAdminProcedureDetailNormalized } from "@/lib/catalog/queries";
import { upsertCmsProcedure } from "@/lib/db/mutations";

export default async function ContentProcedureDetailPage({
  params,
  searchParams,
}: {
  params: Promise<{ categorySlug: string; procedureSlug: string }>;
  searchParams?: Promise<Record<string, string | string[] | undefined>>;
}) {
  const admin = await requireAdmin("content.read");
  const { categorySlug, procedureSlug } = await params;
  const query = (await searchParams) ?? {};
  const procedure = await getAdminProcedureDetailNormalized(
    admin.supabase,
    categorySlug,
    procedureSlug,
    {
      bootstrapIfEmpty: admin.role === "owner" || admin.role === "admin",
    },
  );
  if (!procedure) {
    return (
      <AdminShell email={admin.email} role={admin.role}>
        <section className="rounded-3xl border border-dashed border-slate-300 bg-white p-10 text-center shadow-soft">
          <h2 className="text-2xl font-semibold text-slate-900">Procedure not found</h2>
          <p className="mt-3 text-sm text-slate-600">
            The admin panel could not find a procedure for
            {" "}
            <strong>{categorySlug}</strong>
            {" / "}
            <strong>{procedureSlug}</strong>.
          </p>
          <Link
            prefetch={false}
            href="/content/procedures"
            className="mt-6 inline-flex rounded-xl bg-slate-900 px-4 py-2 text-sm font-medium text-white"
          >
            Back to procedures
          </Link>
        </section>
      </AdminShell>
    );
  }

  return (
    <AdminShell email={admin.email} role={admin.role}>
      <section className="space-y-6">
        <div className="rounded-3xl border border-slate-200 bg-white p-6 shadow-soft">
          <h2 className="text-xl font-semibold text-slate-900">
            Procedure editor: {categorySlug} / {procedureSlug}
          </h2>
          {procedure.source === "bundled" ? (
            <div className="mt-4 rounded-2xl bg-amber-50 p-3 text-sm text-amber-900">
              This procedure is coming from the bundled app fallback because Supabase CMS is still empty.
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
          <form action={upsertCmsProcedure} className="mt-5 grid gap-6 xl:grid-cols-2">
            <div className="space-y-4">
              <input type="hidden" name="redirectTo" value={`/content/procedures/${categorySlug}/${procedureSlug}`} />
              <div><label>Category slug</label><input name="categorySlug" defaultValue={procedure.categorySlug} required /></div>
              <div><label>Subcategory slug</label><input name="subcategorySlug" defaultValue={procedure.subcategorySlug ?? ""} /></div>
              <div><label>Slug</label><input name="slug" defaultValue={procedure.slug} required /></div>
              <div><label>Status</label><select name="status" defaultValue={procedure.status}><option value="draft">draft</option><option value="published">published</option><option value="archived">archived</option></select></div>
              <div><label>Sort order</label><input name="sortOrder" defaultValue={procedure.sortOrder} /></div>
              <div><label>Verification</label><select name="verificationStatus" defaultValue={procedure.verificationStatus}><option value="verified">verified</option><option value="needsReview">needsReview</option><option value="unverified">unverified</option></select></div>
              <label className="flex items-center gap-3"><input className="h-4 w-4" type="checkbox" name="isActive" defaultChecked={procedure.raw.is_active} /><span>Published</span></label>
              <div><label>Premium visibility</label><select name="premiumVisibility" defaultValue={procedure.premiumVisibility}><option value="free">free</option><option value="premium_preview">premium_preview</option><option value="premium_only">premium_only</option><option value="hidden">hidden</option></select></div>
              <div><label>Required plan</label><select name="requiredPlan" defaultValue={procedure.requiredPlan ?? ""}><option value="">free</option><option value="premium">premium</option></select></div>
              <label className="flex items-center gap-3"><input className="h-4 w-4" type="checkbox" name="allowSingleUnlock" defaultChecked={procedure.allowSingleUnlock} /><span>Allow single unlock</span></label>
              <div><label>Single unlock price (cents)</label><input name="singleUnlockPriceCents" defaultValue={procedure.singleUnlockPriceCents ?? ""} /></div>
              <div><label>Tags</label><textarea name="tags" rows={4} defaultValue={procedure.tags.join("\n")} /></div>
              <div><label>Synonyms</label><textarea name="synonyms" rows={5} defaultValue={procedure.synonyms.join("\n")} /></div>
              <div><label>Search keywords</label><textarea name="searchableKeywords" rows={5} defaultValue={procedure.searchableKeywords.join("\n")} /></div>
              <div><label>Admin notes</label><textarea name="adminNotes" rows={6} defaultValue={procedure.adminNotes ?? ""} /></div>
            </div>
            <div className="space-y-4">
              <h3 className="text-lg font-semibold text-slate-900">Basics</h3>
              <div><label>Title (EN)</label><input name="titleEn" defaultValue={procedure.title.en ?? ""} required /></div>
              <div><label>Title (IT)</label><input name="titleIt" defaultValue={procedure.title.it ?? ""} /></div>
              <div><label>Title (FR)</label><input name="titleFr" defaultValue={procedure.title.fr ?? ""} /></div>
              <div><label>Title (ES)</label><input name="titleEs" defaultValue={procedure.title.es ?? ""} /></div>
              <div><label>Title (FA)</label><input name="titleFa" defaultValue={procedure.title.fa ?? ""} /></div>
              <div><label>Title (AR)</label><input name="titleAr" defaultValue={procedure.title.ar ?? ""} /></div>
              <div><label>Summary (EN)</label><textarea name="summaryEn" rows={3} defaultValue={procedure.summary.en ?? ""} /></div>
              <div><label>What is it? (EN)</label><textarea name="whatIsItEn" rows={4} defaultValue={procedure.whatIsIt.en ?? ""} /></div>
              <div><label>Premium teaser (EN)</label><textarea name="premiumTeaserEn" rows={4} defaultValue={procedure.premiumTeaser.en ?? procedure.summary.en ?? ""} /></div>
              <div><label>Premium reason (EN)</label><textarea name="premiumReasonEn" rows={4} defaultValue={procedure.premiumReason.en ?? ""} /></div>
            </div>
            <div className="space-y-4">
              <h3 className="text-lg font-semibold text-slate-900">Steps</h3>
              <div><label>Why you may need it</label><textarea name="whyYouMayNeedIt" rows={8} defaultValue={procedure.whyYouMayNeedIt.join("\n")} /></div>
              <div><label>How to do it</label><textarea name="howToDoIt" rows={8} defaultValue={procedure.steps.join("\n")} /></div>
              <div><label>Required documents</label><textarea name="requiredDocuments" rows={8} defaultValue={procedure.documentsRequired.join("\n")} /></div>
              <div><label>Optional documents</label><textarea name="optionalDocuments" rows={6} defaultValue={procedure.optionalDocuments.join("\n")} /></div>
            </div>
            <div className="space-y-4">
              <h3 className="text-lg font-semibold text-slate-900">Warnings, proof, FAQ</h3>
              <div><label>Warnings</label><textarea name="warnings" rows={8} defaultValue={procedure.warnings.join("\n")} /></div>
              <div><label>Common mistakes</label><textarea name="commonMistakes" rows={8} defaultValue={procedure.commonMistakes.join("\n")} /></div>
              <div><label>Proof to keep</label><textarea name="proofToKeep" rows={6} defaultValue={procedure.proofToKeep.join("\n")} /></div>
              <div><label>FAQ</label><textarea name="faq" rows={6} defaultValue={procedure.faq.join("\n")} /></div>
              <div><label>Official links</label><textarea name="officialLinks" rows={6} defaultValue={procedure.officialLinks.join("\n")} /></div>
            </div>
            <div className="xl:col-span-2">
              <button className="rounded-xl bg-slate-900 px-4 py-2 text-sm font-medium text-white">
                Save procedure
              </button>
            </div>
          </form>
        </div>

        <div className="grid gap-6 xl:grid-cols-2">
          <div className="rounded-3xl border border-slate-200 bg-white p-6 shadow-soft">
            <h3 className="text-lg font-semibold text-slate-900">Preview data</h3>
            <div className="mt-4 space-y-3 text-sm text-slate-700">
              <p><strong>Public title:</strong> {procedure.title.en || procedure.slug}</p>
              <p><strong>Summary:</strong> {procedure.summary.en || "—"}</p>
              <p><strong>What is it:</strong> {procedure.whatIsIt.en || "—"}</p>
              <p><strong>Premium visibility:</strong> {procedure.premiumVisibility}</p>
              <p><strong>Required plan:</strong> {procedure.requiredPlan ?? "free"}</p>
            </div>
          </div>
          <div className="rounded-3xl border border-slate-200 bg-white p-6 shadow-soft">
            <h3 className="text-lg font-semibold text-slate-900">Advanced JSON</h3>
            <JsonEditor name="readonlySnapshot" defaultValue={procedure.publicSnapshot} rows={18} />
          </div>
        </div>
      </section>
    </AdminShell>
  );
}
