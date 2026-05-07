import { notFound } from "next/navigation";

import { AdminShell } from "@/components/admin-shell";
import { requireAdmin } from "@/lib/auth/require-admin";
import { updateProblemRequest } from "@/lib/db/mutations";

export default async function ProblemRequestDetailPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const admin = await requireAdmin("requests.read");
  const { id } = await params;
  const { data: request } = await admin.supabase
    .from("ufficio_problem_requests")
    .select("*")
    .eq("id", id)
    .maybeSingle();
  if (!request) notFound();

  return (
    <AdminShell email={admin.email} role={admin.role}>
      <section className="grid gap-6 xl:grid-cols-[1fr_0.9fr]">
        <div className="rounded-3xl border border-slate-200 bg-white p-6 shadow-soft">
          <h2 className="text-xl font-semibold text-slate-900">{request.title}</h2>
          <div className="mt-5 space-y-3 text-sm text-slate-700">
            <p><strong>Description:</strong> {request.description}</p>
            <p><strong>Category:</strong> {request.category_id ?? "—"}</p>
            <p><strong>Subcategory:</strong> {request.subcategory_id ?? "—"}</p>
            <p><strong>User:</strong> {request.user_email ?? request.user_id ?? "—"}</p>
            <p><strong>Language:</strong> {request.language}</p>
            <p><strong>Source page:</strong> {request.source_page}</p>
          </div>
        </div>
        <div className="rounded-3xl border border-slate-200 bg-white p-6 shadow-soft">
          <h2 className="text-xl font-semibold text-slate-900">Update request</h2>
          <form action={updateProblemRequest} className="mt-5 space-y-4">
            <input type="hidden" name="id" value={request.id} />
            <div>
              <label htmlFor="status">Status</label>
              <select id="status" name="status" defaultValue={request.status}>
                <option value="new">new</option>
                <option value="reviewing">reviewing</option>
                <option value="planned">planned</option>
                <option value="added">added</option>
                <option value="rejected">rejected</option>
              </select>
            </div>
            <div>
              <label htmlFor="linkedCategorySlug">Linked CMS category</label>
              <input
                id="linkedCategorySlug"
                name="linkedCategorySlug"
                defaultValue={request.linked_category_slug ?? ""}
              />
            </div>
            <div>
              <label htmlFor="linkedProcedureSlug">Linked CMS procedure</label>
              <input
                id="linkedProcedureSlug"
                name="linkedProcedureSlug"
                defaultValue={request.linked_procedure_slug ?? ""}
              />
            </div>
            <div>
              <label htmlFor="adminNotes">Internal notes</label>
              <textarea
                id="adminNotes"
                name="adminNotes"
                rows={8}
                defaultValue={request.admin_notes ?? ""}
              />
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
