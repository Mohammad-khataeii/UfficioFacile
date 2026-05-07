import { redirect } from "next/navigation";

import { createSupabaseServerClient } from "@/lib/supabase/server";

async function loginAction(formData: FormData) {
  "use server";

  const supabase = await createSupabaseServerClient();
  const email = String(formData.get("email") ?? "").trim();
  const password = String(formData.get("password") ?? "").trim();

  if (!email) return;

  if (password) {
    const { error } = await supabase.auth.signInWithPassword({ email, password });
    if (error) throw error;
    redirect("/dashboard");
  } else {
    const { error } = await supabase.auth.signInWithOtp({
      email,
      options: {
        emailRedirectTo: `${process.env.NEXT_PUBLIC_ADMIN_APP_URL ?? "http://localhost:3000"}/dashboard`,
      },
    });
    if (error) throw error;
    redirect("/login?sent=1");
  }
}

export default async function LoginPage({
  searchParams,
}: {
  searchParams?: Promise<{ sent?: string }>;
}) {
  const params = searchParams ? await searchParams : undefined;
  const sent = params?.sent === "1";

  return (
    <div className="flex min-h-screen items-center justify-center bg-slate-50 px-4 py-8">
      <div className="w-full max-w-md rounded-3xl border border-slate-200 bg-white p-8 shadow-soft">
        <p className="text-xs font-semibold uppercase tracking-[0.22em] text-brand-700">
          UfficioFacile
        </p>
        <h1 className="mt-3 text-3xl font-semibold text-slate-900">
          Admin sign in
        </h1>
        <p className="mt-3 text-sm text-slate-600">
          Use your Supabase admin account. Leave the password empty if your project uses magic links.
        </p>
        {sent ? (
          <div className="mt-4 rounded-2xl bg-emerald-50 p-3 text-sm text-emerald-900">
            Magic link sent. Open the link from your email to continue.
          </div>
        ) : null}
        <form action={loginAction} className="mt-6 space-y-4">
          <div className="space-y-1">
            <label htmlFor="email">Email</label>
            <input id="email" name="email" type="email" required />
          </div>
          <div className="space-y-1">
            <label htmlFor="password">Password</label>
            <input id="password" name="password" type="password" />
          </div>
          <button className="w-full rounded-xl bg-slate-900 px-4 py-3 text-sm font-medium text-white hover:bg-slate-800">
            Continue
          </button>
        </form>
      </div>
    </div>
  );
}
