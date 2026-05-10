import { notFound } from "next/navigation";

import { AdminShell } from "@/components/admin-shell";
import { JsonEditor } from "@/components/json-editor";
import { requireAdmin } from "@/lib/auth/require-admin";
import { getAdminProcedureByCategoryAndSlug } from "@/lib/content/load-content-tree";
import { upsertCmsProcedure } from "@/lib/db/mutations";

export default async function ContentProcedureDetailPage({
  params,
}: {
  params: Promise<{ categorySlug: string; procedureSlug: string }>;
}) {
  const admin = await requireAdmin("content.read");
  const { categorySlug, procedureSlug } = await params;
  const procedure = await getAdminProcedureByCategoryAndSlug(
    admin.supabase,
    categorySlug,
    procedureSlug,
    {
      bootstrapIfEmpty: admin.role === "owner" || admin.role === "admin",
    },
  );
  if (!procedure) notFound();

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
          <form action={upsertCmsProcedure} className="mt-5 grid gap-6 xl:grid-cols-2">
            <div className="space-y-4">
              <div><label>Category slug</label><input name="categorySlug" defaultValue={procedure.category_slug} required /></div>
              <div><label>Slug</label><input name="slug" defaultValue={procedure.slug} required /></div>
              <div><label>Status</label><select name="status" defaultValue={procedure.status}><option value="draft">draft</option><option value="published">published</option><option value="archived">archived</option></select></div>
              <div><label>Sort order</label><input name="sortOrder" defaultValue={procedure.sort_order ?? 0} /></div>
              <div><label>Verification</label><select name="verificationStatus" defaultValue={procedure.verification_status}><option value="verified">verified</option><option value="needsReview">needsReview</option><option value="unverified">unverified</option></select></div>
              <label className="flex items-center gap-3"><input className="h-4 w-4" type="checkbox" name="isActive" defaultChecked={procedure.is_active} /><span>Active</span></label>
              <label className="flex items-center gap-3"><input className="h-4 w-4" type="checkbox" name="isPremium" defaultChecked={procedure.is_premium} /><span>Premium</span></label>
              <div><label>Monetization type</label><select name="monetizationType" defaultValue={procedure.monetization_type ?? (procedure.is_premium ? "premium_money_value" : "free")}><option value="free">free</option><option value="premium">premium</option><option value="premium_money_value">premium_money_value</option><option value="premium_financial_strategy">premium_financial_strategy</option><option value="premium_comparison_tool">premium_comparison_tool</option></select></div>
              <label className="flex items-center gap-3"><input className="h-4 w-4" type="checkbox" name="allowSingleUnlock" defaultChecked={procedure.allow_single_unlock ?? true} /><span>Allow single unlock</span></label>
              <div><label>Single unlock price (cents)</label><input name="singleUnlockPriceCents" defaultValue={procedure.single_unlock_price_cents ?? ""} /></div>
              <div><label>Tags</label><textarea name="tags" rows={4} defaultValue={(procedure.tags ?? []).join("\n")} /></div>
              <div><label>Synonyms</label><textarea name="synonyms" rows={5} defaultValue={(procedure.synonyms ?? []).join("\n")} /></div>
              <div><label>Search keywords</label><textarea name="searchableKeywords" rows={5} defaultValue={(procedure.searchable_keywords ?? []).join("\n")} /></div>
              <div><label>Admin notes</label><textarea name="adminNotes" rows={6} defaultValue={procedure.admin_notes ?? ""} /></div>
            </div>
            <div className="space-y-4">
              <h3 className="text-lg font-semibold text-slate-900">Basics</h3>
              <div><label>Subcategory slug</label><input value={procedure.subcategory_slug ?? ""} disabled /></div>
              <div><label>Title (EN)</label><input name="titleEn" defaultValue={procedure.title?.en ?? ""} required /></div>
              <div><label>Title (IT)</label><input name="titleIt" defaultValue={procedure.title?.it ?? ""} /></div>
              <div><label>Title (FR)</label><input name="titleFr" defaultValue={procedure.title?.fr ?? ""} /></div>
              <div><label>Title (ES)</label><input name="titleEs" defaultValue={procedure.title?.es ?? ""} /></div>
              <div><label>Title (FA)</label><input name="titleFa" defaultValue={procedure.title?.fa ?? ""} /></div>
              <div><label>Title (AR)</label><input name="titleAr" defaultValue={procedure.title?.ar ?? ""} /></div>
              <div><label>Summary (EN)</label><textarea name="summaryEn" rows={3} defaultValue={procedure.summary?.en ?? ""} /></div>
              <div><label>What is it? (EN)</label><textarea name="whatIsItEn" rows={4} defaultValue={procedure.what_is_it?.en ?? ""} /></div>
              <div><label>Premium teaser (EN)</label><textarea name="premiumTeaserEn" rows={4} defaultValue={procedure.premium_teaser?.en ?? procedure.summary?.en ?? ""} /></div>
              <div><label>Premium reason (EN)</label><textarea name="premiumReasonEn" rows={4} defaultValue={procedure.premium_reason?.en ?? ""} /></div>
            </div>
            <div className="space-y-4">
              <h3 className="text-lg font-semibold text-slate-900">Steps</h3>
              <div><label>Why you may need it</label><textarea name="whyYouMayNeedIt" rows={8} defaultValue={(procedure.why_you_may_need_it ?? []).join("\n")} /></div>
              <div><label>How to do it</label><textarea name="howToDoIt" rows={8} defaultValue={(procedure.how_to_do_it ?? []).join("\n")} /></div>
              <div><label>Required documents</label><textarea name="requiredDocuments" rows={8} defaultValue={(procedure.required_documents ?? []).join("\n")} /></div>
              <div><label>Optional documents</label><textarea name="optionalDocuments" rows={6} defaultValue={(procedure.optional_documents ?? []).join("\n")} /></div>
            </div>
            <div className="space-y-4">
              <h3 className="text-lg font-semibold text-slate-900">Warnings, proof, FAQ</h3>
              <div><label>Warnings</label><textarea name="warnings" rows={8} defaultValue={(procedure.warnings ?? []).join("\n")} /></div>
              <div><label>Common mistakes</label><textarea name="commonMistakes" rows={8} defaultValue={(procedure.common_mistakes ?? []).join("\n")} /></div>
              <div><label>Proof to keep</label><textarea name="proofToKeep" rows={6} defaultValue={(procedure.proof_to_keep ?? []).join("\n")} /></div>
              <div><label>FAQ</label><textarea name="faq" rows={6} defaultValue={(procedure.faq ?? []).join("\n")} /></div>
              <div><label>Official links</label><textarea name="officialLinks" rows={6} defaultValue={(procedure.official_links ?? []).join("\n")} /></div>
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
              <p><strong>Public title:</strong> {procedure.title?.en || procedure.slug}</p>
              <p><strong>Summary:</strong> {procedure.summary?.en || "—"}</p>
              <p><strong>What is it:</strong> {procedure.what_is_it?.en || "—"}</p>
            </div>
          </div>
          <div className="rounded-3xl border border-slate-200 bg-white p-6 shadow-soft">
            <h3 className="text-lg font-semibold text-slate-900">Advanced JSON</h3>
            <JsonEditor name="readonlySnapshot" defaultValue={procedure.public_snapshot ?? {}} rows={18} />
          </div>
        </div>
      </section>
    </AdminShell>
  );
}
