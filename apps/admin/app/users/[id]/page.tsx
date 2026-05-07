import type { ReactNode } from "react";
import { notFound } from "next/navigation";

import { AdminShell } from "@/components/admin-shell";
import { StatusBadge } from "@/components/status-badge";
import { requireAdmin } from "@/lib/auth/require-admin";
import { getAuthUser, getUserBundle } from "@/lib/db/queries";

function DetailCard({ title, children }: { title: string; children: ReactNode }) {
  return (
    <section className="rounded-3xl border border-slate-200 bg-white p-6 shadow-soft">
      <h2 className="text-lg font-semibold text-slate-900">{title}</h2>
      <div className="mt-4 text-sm text-slate-700">{children}</div>
    </section>
  );
}

export default async function UserDetailPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const admin = await requireAdmin("users.read");
  const { id } = await params;
  const authUser = await getAuthUser(id);
  if (!authUser) notFound();
  const bundle = await getUserBundle(admin.supabase, id);

  return (
    <AdminShell email={admin.email} role={admin.role}>
      <div className="grid gap-6 xl:grid-cols-2">
        <DetailCard title="Auth user">
          <div className="space-y-2">
            <p><strong>Email:</strong> {authUser.email ?? "—"}</p>
            <p><strong>User ID:</strong> <code>{authUser.id}</code></p>
            <p><strong>Created:</strong> {authUser.created_at}</p>
            <p><strong>Last sign-in:</strong> {authUser.last_sign_in_at ?? "—"}</p>
          </div>
        </DetailCard>
        <DetailCard title="Profile">
          <pre className="overflow-x-auto rounded-2xl bg-slate-50 p-4 text-xs">
            {JSON.stringify(bundle.profile ?? {}, null, 2)}
          </pre>
        </DetailCard>
        <DetailCard title="Entitlement">
          {bundle.entitlement ? (
            <div className="space-y-3">
              <StatusBadge value={bundle.entitlement.plan} />
              <pre className="overflow-x-auto rounded-2xl bg-slate-50 p-4 text-xs">
                {JSON.stringify(bundle.entitlement, null, 2)}
              </pre>
            </div>
          ) : (
            <p>No entitlement row yet.</p>
          )}
        </DetailCard>
        <DetailCard title="Related activity">
          <div className="space-y-5">
            <div>
              <p className="font-medium">Saved requests</p>
              <p>{bundle.requests.length}</p>
            </div>
            <div>
              <p className="font-medium">Problem requests</p>
              <p>{bundle.problemRequests.length}</p>
            </div>
            <div>
              <p className="font-medium">Consultancy requests</p>
              <p>{bundle.consultancy.length}</p>
            </div>
            <div>
              <p className="font-medium">Cost items</p>
              <p>{bundle.costItems.length}</p>
            </div>
            <div>
              <p className="font-medium">Contacts</p>
              <p>{bundle.contacts.length}</p>
            </div>
            <div>
              <p className="font-medium">Documents</p>
              <p>{bundle.documents.length}</p>
            </div>
          </div>
        </DetailCard>
      </div>
    </AdminShell>
  );
}
