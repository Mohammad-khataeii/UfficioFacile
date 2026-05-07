import clsx from "clsx";

export function StatusBadge({
  value,
}: {
  value: string | null | undefined;
}) {
  const normalized = (value ?? "unknown").toLowerCase();
  return (
    <span
      className={clsx(
        "inline-flex rounded-full px-2.5 py-1 text-xs font-medium",
        normalized.includes("verified") && "bg-emerald-100 text-emerald-700",
        normalized.includes("review") && "bg-amber-100 text-amber-800",
        normalized.includes("reject") && "bg-rose-100 text-rose-700",
        normalized.includes("paid") && "bg-emerald-100 text-emerald-700",
        normalized.includes("premium") && "bg-brand-100 text-brand-800",
        normalized === "draft" && "bg-slate-200 text-slate-700",
        normalized === "published" && "bg-emerald-100 text-emerald-700",
        normalized === "archived" && "bg-slate-200 text-slate-700",
        !normalized.includes("verified") &&
          !normalized.includes("review") &&
          !normalized.includes("reject") &&
          normalized !== "draft" &&
          normalized !== "published" &&
          normalized !== "archived" &&
          !normalized.includes("paid") &&
          !normalized.includes("premium") &&
          "bg-slate-100 text-slate-700",
      )}
    >
      {value ?? "unknown"}
    </span>
  );
}
