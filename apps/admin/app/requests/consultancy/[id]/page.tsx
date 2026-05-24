import { notFound } from "next/navigation";

import { AdminShell } from "@/components/admin-shell";
import { requireAdmin } from "@/lib/auth/require-admin";
import { updateConsultancyRequest } from "@/lib/db/mutations";

export default async function ConsultancyRequestDetailPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const admin = await requireAdmin("requests.read");
  const { id } = await params;
  const { data: request } = await admin.supabase
    .from("ufficio_consultancy_requests")
    .select("*")
    .eq("id", id)
    .maybeSingle();
  if (!request) notFound();
  const isRichSchema =
    "full_name" in request ||
    "user_email" in request ||
    "problem_type" in request ||
    "desired_result" in request;
  const displayName = request.full_name || request.user_email || request.email || "—";
  const displayEmail = request.user_email || request.email || "—";
  const displayProblem =
    request.problem_type || request.subject || request.category_id || request.category || "—";
  const displayDescription = request.description || request.message || "—";
  const displayDesiredResult = request.desired_result || request.admin_notes || "—";
  const displayDocuments = request.documents_available || "—";
  const displayPlan = request.user_plan ?? (request.is_premium_snapshot ? "premium" : "free");

  return (
    <AdminShell email={admin.email} role={admin.role}>
      <section className="grid gap-6 xl:grid-cols-[1fr_0.9fr]">
        <div className="rounded-3xl border border-slate-200 bg-white p-6 shadow-soft">
          <h2 className="text-xl font-semibold text-slate-900">{displayName}</h2>
          <div className="mt-5 space-y-3 text-sm text-slate-700">
            <p><strong>Email:</strong> {displayEmail}</p>
            <p><strong>Problem:</strong> {displayProblem}</p>
            <p><strong>Description:</strong> {displayDescription}</p>
            <p><strong>Desired result:</strong> {displayDesiredResult}</p>
            <p><strong>Documents:</strong> {displayDocuments}</p>
            <p><strong>Plan snapshot:</strong> {displayPlan}</p>
          </div>
        </div>
        <div className="rounded-3xl border border-slate-200 bg-white p-6 shadow-soft">
          <h2 className="text-xl font-semibold text-slate-900">Update request</h2>
          <form action={updateConsultancyRequest} className="mt-5 space-y-4">
            <input type="hidden" name="id" value={request.id} />
            <input type="hidden" name="schemaMode" value={isRichSchema ? "rich" : "legacy"} />
            <div>
              <label htmlFor="status">Status</label>
              <select id="status" name="status" defaultValue={request.status}>
                {isRichSchema ? (
                  <>
                    <option value="newRequest">newRequest</option>
                    <option value="waitingPayment">waitingPayment</option>
                    <option value="reviewing">reviewing</option>
                    <option value="replied">replied</option>
                    <option value="closed">closed</option>
                  </>
                ) : (
                  <>
                    <option value="new">new</option>
                    <option value="waiting_user">waiting_user</option>
                    <option value="reviewing">reviewing</option>
                    <option value="answered">answered</option>
                    <option value="closed">closed</option>
                  </>
                )}
              </select>
            </div>
            <div>
              <label htmlFor="paymentStatus">Payment status</label>
              <select
                id="paymentStatus"
                name="paymentStatus"
                defaultValue={request.payment_status}
              >
                {isRichSchema ? (
                  <>
                    <option value="freeForPremium">freeForPremium</option>
                    <option value="paymentRequired">paymentRequired</option>
                    <option value="waitingPayment">waitingPayment</option>
                    <option value="paid">paid</option>
                    <option value="failed">failed</option>
                    <option value="notAvailable">notAvailable</option>
                  </>
                ) : (
                  <>
                    <option value="not_required">not_required</option>
                    <option value="required">required</option>
                    <option value="pending">pending</option>
                    <option value="paid">paid</option>
                    <option value="failed">failed</option>
                    <option value="waived">waived</option>
                  </>
                )}
              </select>
            </div>
            <div>
              <label htmlFor="adminNotes">Admin notes</label>
              <textarea id="adminNotes" name="adminNotes" rows={5} defaultValue={request.admin_notes ?? ""} />
            </div>
            <div>
              <label htmlFor="responseNotes">Response notes</label>
              <textarea id="responseNotes" name="responseNotes" rows={5} defaultValue={request.response_notes ?? ""} />
            </div>
            <button className="rounded-xl bg-slate-900 px-4 py-2 text-sm font-medium text-white">
              Save changes
            </button>
          </form>
        </div>
      </section>
    </AdminShell>
  );
}
