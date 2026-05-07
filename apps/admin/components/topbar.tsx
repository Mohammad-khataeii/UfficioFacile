import Link from "next/link";

import type { AdminRole } from "@/lib/auth/permissions";

export function Topbar({
  email,
  role,
}: {
  email: string | null;
  role: AdminRole;
}) {
  return (
    <header className="flex flex-col gap-3 rounded-3xl border border-slate-200 bg-white px-5 py-4 shadow-soft sm:flex-row sm:items-center sm:justify-between">
      <div>
        <p className="text-xs font-semibold uppercase tracking-[0.18em] text-slate-500">
          Protected backoffice
        </p>
        <p className="mt-1 text-sm text-slate-700">
          Signed in as <span className="font-medium">{email ?? "unknown"}</span>{" "}
          • role: <span className="font-medium capitalize">{role}</span>
        </p>
      </div>
      <div className="flex items-center gap-3">
        <Link
          href="/content/import"
          className="rounded-xl border border-slate-200 px-3 py-2 text-sm text-slate-700 hover:bg-slate-50"
        >
          Import bundled content
        </Link>
        <Link
          href="/logout"
          className="rounded-xl bg-slate-900 px-4 py-2 text-sm font-medium text-white hover:bg-slate-800"
        >
          Log out
        </Link>
      </div>
    </header>
  );
}
