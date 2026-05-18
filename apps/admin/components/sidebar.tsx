import Link from "next/link";

const items = [
  { href: "/dashboard", label: "Dashboard" },
  { href: "/content", label: "Content" },
  { href: "/content/categories", label: "Categories" },
  { href: "/content/procedures", label: "Procedures" },
  { href: "/premium", label: "Premium" },
  { href: "/premium/promos", label: "Promo codes" },
  { href: "/users", label: "Users" },
  { href: "/admins", label: "Admins" },
  { href: "/requests/problem", label: "Problem requests" },
  { href: "/requests/consultancy", label: "Consultancy" },
  { href: "/catalog", label: "Catalog" },
  { href: "/translations", label: "Translations" },
  { href: "/audit", label: "Audit" },
  { href: "/settings", label: "Config" },
];

export function Sidebar() {
  return (
    <aside className="w-full max-w-xs rounded-3xl border border-slate-200 bg-white p-4 shadow-soft">
      <div className="mb-5 border-b border-slate-100 pb-4">
        <p className="text-xs font-semibold uppercase tracking-[0.2em] text-brand-700">
          UfficioFacile
        </p>
        <h1 className="mt-2 text-xl font-semibold text-slate-900">
          Admin backoffice
        </h1>
      </div>
      <nav className="space-y-1">
        {items.map((item) => (
          <Link
            key={item.href}
            href={item.href}
            className="block rounded-2xl px-3 py-2 text-sm text-slate-700 transition hover:bg-brand-50 hover:text-brand-800"
          >
            {item.label}
          </Link>
        ))}
      </nav>
      <div className="mt-6 rounded-2xl bg-slate-50 p-3 text-sm text-slate-600">
        Web-only admin. Consumer Flutter routes now point here.
      </div>
    </aside>
  );
}
