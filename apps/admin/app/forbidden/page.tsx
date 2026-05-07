import Link from "next/link";

export default function ForbiddenPage() {
  return (
    <div className="flex min-h-screen items-center justify-center bg-slate-50 px-4">
      <div className="max-w-lg rounded-3xl border border-slate-200 bg-white p-8 shadow-soft">
        <h1 className="text-3xl font-semibold text-slate-900">Access denied</h1>
        <p className="mt-4 text-sm text-slate-600">
          Your account is signed in, but it does not have an active UfficioFacile admin role in
          <code className="mx-1 rounded bg-slate-100 px-1.5 py-0.5">public.ufficio_admin_users</code>.
        </p>
        <div className="mt-6 flex gap-3">
          <Link
            href="/login"
            className="rounded-xl bg-slate-900 px-4 py-2 text-sm font-medium text-white"
          >
            Back to login
          </Link>
        </div>
      </div>
    </div>
  );
}
