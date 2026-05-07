import { ReactNode } from "react";

import type { AdminRole } from "@/lib/auth/permissions";
import { Sidebar } from "@/components/sidebar";
import { Topbar } from "@/components/topbar";

export function AdminShell({
  email,
  role,
  children,
}: {
  email: string | null;
  role: AdminRole;
  children: ReactNode;
}) {
  return (
    <div className="min-h-screen bg-[radial-gradient(circle_at_top_left,_rgba(37,87,245,0.08),_transparent_32%),linear-gradient(180deg,#f8fafc_0%,#f8fafc_100%)]">
      <div className="mx-auto flex max-w-[1600px] flex-col gap-6 px-4 py-6 lg:flex-row lg:px-6">
        <Sidebar />
        <main className="min-w-0 flex-1 space-y-6">
          <Topbar email={email} role={role} />
          {children}
        </main>
      </div>
    </div>
  );
}
