import type { ReactNode } from "react";
import { notFound } from "next/navigation";

import { AdminShell } from "@/components/admin-shell";
import { StatusBadge } from "@/components/status-badge";
import { hasPermission } from "@/lib/auth/permissions";
import { requireAdmin } from "@/lib/auth/require-admin";
import {
  deleteUserAccount,
  updateUserDeviceLock,
} from "@/lib/db/mutations";
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
  const canManageUsers = hasPermission(admin.role, "users.manage");
  const profileMetadata =
    bundle.profile?.metadata && typeof bundle.profile.metadata === "object"
      ? bundle.profile.metadata
      : {};
  const deviceBinding =
    profileMetadata.device_binding &&
    typeof profileMetadata.device_binding === "object"
      ? profileMetadata.device_binding
      : null;
  const deviceLockEnabled = deviceBinding?.enabled !== false;
  const hasBoundDevice = Boolean(
    typeof deviceBinding?.installation_id === "string" &&
      deviceBinding.installation_id.length > 0,
  );

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
        <DetailCard title="Account controls">
          <div className="space-y-4">
            <div className="rounded-2xl border border-slate-200 bg-slate-50 p-4">
              <p className="font-medium text-slate-900">Device lock</p>
              <p className="mt-1 text-sm text-slate-600">
                Status:{" "}
                <strong>
                  {deviceLockEnabled
                    ? hasBoundDevice
                      ? "Locked to a device"
                      : "Will lock on next sign-in"
                    : "Unlocked"}
                </strong>
              </p>
              <p className="mt-1 text-xs text-slate-500">
                Bound installation:{" "}
                {hasBoundDevice ? (
                  <code>{String(deviceBinding?.installation_id)}</code>
                ) : (
                  "none"
                )}
              </p>
              <p className="mt-1 text-xs text-slate-500">
                Platform: {typeof deviceBinding?.platform === "string" ? deviceBinding.platform : "—"}
              </p>
              <div className="mt-4 flex flex-wrap gap-3">
                {canManageUsers ? (
                  <>
                    <form action={updateUserDeviceLock}>
                      <input type="hidden" name="userId" value={id} />
                      <input type="hidden" name="mode" value="unlock" />
                      <button type="submit">
                        Unlock device restriction
                      </button>
                    </form>
                    <form action={updateUserDeviceLock}>
                      <input type="hidden" name="userId" value={id} />
                      <input type="hidden" name="mode" value="lockNextSignIn" />
                      <button type="submit">
                        Lock on next sign-in
                      </button>
                    </form>
                  </>
                ) : (
                  <p className="text-xs text-slate-500">
                    Your role can view device lock status but cannot change it.
                  </p>
                )}
              </div>
            </div>
            <div className="rounded-2xl border border-rose-200 bg-rose-50 p-4">
              <p className="font-medium text-rose-900">Delete account</p>
              <p className="mt-1 text-sm text-rose-700">
                This permanently deletes the Supabase auth user and cascades user-owned rows.
              </p>
              {canManageUsers ? (
                <form action={deleteUserAccount} className="mt-4">
                  <input type="hidden" name="userId" value={id} />
                  <button
                    type="submit"
                    className="bg-rose-600 text-white hover:bg-rose-700"
                  >
                    Delete this account
                  </button>
                </form>
              ) : (
                <p className="mt-4 text-xs text-rose-700">
                  Your role cannot delete user accounts.
                </p>
              )}
            </div>
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
