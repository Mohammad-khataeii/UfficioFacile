import { promises as fs } from "node:fs";
import path from "node:path";

type LocalizedText = Record<string, string>;

type BundledProcedure = {
  id?: string;
  title?: string;
  titleIt?: string;
  whatIsIt?: string;
  whyDoYouNeedIt?: string[];
  documents?: string[];
  extraDocuments?: string[];
  warnings?: string[];
  outputs?: string[];
  recommendedChannels?: string[];
  recommendedContacts?: string[];
  priority?: string;
  [key: string]: unknown;
};

type BundledCategory = {
  id?: string;
  title?: string;
  titleIt?: string;
  shortDescription?: string;
  subcategories?: BundledProcedure[];
  [key: string]: unknown;
};

type BundledExport = {
  categories?: Record<string, unknown>[];
  cmsCategories?: Record<string, unknown>[];
  cmsProcedures?: Record<string, unknown>[];
  cmsContentBlocks?: Record<string, unknown>[];
  richCategories?: BundledCategory[];
  healthCategory?: BundledCategory;
  housingCategory?: BundledCategory;
};

export type AdminContentSource = "supabase" | "bundled";

export type AdminCategoryRecord = {
  slug: string;
  internal_label: string | null;
  title: LocalizedText;
  subtitle?: LocalizedText;
  description?: LocalizedText;
  icon: string | null;
  color: string | null;
  sort_order: number;
  is_active: boolean;
  is_premium: boolean;
  verification_status: string;
  tags?: string[];
  synonyms?: string[];
  searchable_keywords?: string[];
  monetization_type?: string;
  allow_single_unlock?: boolean;
  single_unlock_price_cents?: number | null;
  single_unlock_currency?: string;
  premium_reason?: LocalizedText;
  premium_teaser?: LocalizedText;
  admin_notes: string | null;
  public_snapshot?: Record<string, unknown>;
  source: AdminContentSource;
};

export type AdminProcedureRecord = {
  id?: string;
  slug: string;
  category_slug: string;
  subcategory_slug?: string | null;
  title: LocalizedText;
  subtitle?: LocalizedText;
  summary: LocalizedText;
  what_is_it: LocalizedText;
  why_you_may_need_it: string[];
  how_to_do_it: string[];
  required_documents: string[];
  optional_documents: string[];
  warnings: string[];
  common_mistakes: string[];
  proof_to_keep: string[];
  faq: string[];
  official_links: string[];
  status: string;
  sort_order: number;
  is_active: boolean;
  is_premium: boolean;
  verification_status: string;
  tags?: string[];
  synonyms?: string[];
  searchable_keywords?: string[];
  monetization_type?: string;
  allow_single_unlock?: boolean;
  single_unlock_price_cents?: number | null;
  single_unlock_currency?: string;
  premium_reason?: LocalizedText;
  premium_teaser?: LocalizedText;
  admin_notes: string | null;
  public_snapshot?: Record<string, unknown>;
  source: AdminContentSource;
};

export type AdminContentTree = {
  source: AdminContentSource;
  categories: AdminCategoryRecord[];
  procedures: AdminProcedureRecord[];
};

export type LegacyProcedureSlugMatch = {
  slug: string;
  matches: AdminProcedureRecord[];
};

function getProcedureCategorySlug(procedure: AdminProcedureRecord): string {
  return String(procedure.category_slug ?? "").trim();
}

function getProcedureSubcategorySlug(
  procedure: AdminProcedureRecord,
): string | null {
  const value =
    typeof procedure.subcategory_slug === "string"
      ? procedure.subcategory_slug.trim()
      : "";
  return value.length > 0 ? value : null;
}

function getProcedureSlug(procedure: AdminProcedureRecord): string {
  return String(procedure.slug ?? "").trim();
}

function getProcedureRawId(procedure: AdminProcedureRecord): string | null {
  const rawId =
    typeof procedure.id === "string"
      ? procedure.id.trim()
      : String(procedure.id ?? "").trim();
  return rawId.length > 0 ? rawId : null;
}

function getProcedurePublicIdentity(procedure: AdminProcedureRecord): string | null {
  const slug = getProcedureSlug(procedure);
  const categorySlug = getProcedureCategorySlug(procedure);
  if (categorySlug.length > 0 && slug.length > 0) {
    return `path:${categorySlug}::${slug}`;
  }
  return null;
}

function formatProcedureDebugLabel(procedure: AdminProcedureRecord): string {
  return JSON.stringify({
    category_slug: getProcedureCategorySlug(procedure) || null,
    slug: getProcedureSlug(procedure) || null,
    source: procedure.source,
    id: getProcedureRawId(procedure),
    status: procedure.status,
    title_en: procedure.title?.en ?? null,
  });
}

function getProcedureCanonicalKey(procedure: AdminProcedureRecord): string {
  const publicIdentity = getProcedurePublicIdentity(procedure);
  if (publicIdentity) {
    return publicIdentity;
  }
  const rawId = getProcedureRawId(procedure);
  if (rawId) {
    if (process.env.NODE_ENV !== "production") {
      console.warn(
        `[content] Procedure missing category_slug or slug; falling back to database id identity ${formatProcedureDebugLabel(
          procedure,
        )}`,
      );
    }
    return `id:${rawId}`;
  }
  if (process.env.NODE_ENV !== "production") {
    console.warn(
      `[content] Procedure missing both public identity and database id ${formatProcedureDebugLabel(
        procedure,
      )}`,
    );
  }
  return `missing:${JSON.stringify({
    category_slug: getProcedureCategorySlug(procedure),
    slug: getProcedureSlug(procedure),
    sort_order: procedure.sort_order,
    source: procedure.source,
  })}`;
}

function getProcedureRoutePath(procedure: AdminProcedureRecord): string {
  return `/content/procedures/${getProcedureCategorySlug(procedure)}/${getProcedureSlug(procedure)}`;
}

function getProcedureRichnessScore(procedure: AdminProcedureRecord): number {
  return [
    Object.keys(procedure.title ?? {}).length,
    Object.keys(procedure.subtitle ?? {}).length,
    Object.keys(procedure.summary ?? {}).length,
    Object.keys(procedure.what_is_it ?? {}).length,
    procedure.why_you_may_need_it.length,
    procedure.how_to_do_it.length,
    procedure.required_documents.length,
    procedure.optional_documents.length,
    procedure.warnings.length,
    procedure.common_mistakes.length,
    procedure.proof_to_keep.length,
    procedure.faq.length,
    procedure.official_links.length,
    procedure.tags?.length ?? 0,
    procedure.synonyms?.length ?? 0,
    procedure.searchable_keywords?.length ?? 0,
  ].reduce((sum, item) => sum + item, 0);
}

function getProcedureStatusRank(procedure: AdminProcedureRecord): number {
  const normalizedStatus = String(procedure.status ?? "").trim().toLowerCase();
  if (procedure.is_active && normalizedStatus === "published") return 5;
  if (procedure.is_active && normalizedStatus === "active") return 4;
  if (procedure.is_active) return 3;
  if (normalizedStatus === "draft") return 2;
  if (normalizedStatus === "archived") return 1;
  return 0;
}

function choosePreferredProcedure(
  current: AdminProcedureRecord,
  candidate: AdminProcedureRecord,
): AdminProcedureRecord {
  const currentStatusRank = getProcedureStatusRank(current);
  const candidateStatusRank = getProcedureStatusRank(candidate);
  if (candidateStatusRank !== currentStatusRank) {
    return candidateStatusRank > currentStatusRank ? candidate : current;
  }
  const currentScore = getProcedureRichnessScore(current);
  const candidateScore = getProcedureRichnessScore(candidate);
  if (candidateScore != currentScore) {
    return candidateScore > currentScore ? candidate : current;
  }
  if (candidate.source !== current.source) {
    return candidate.source === "supabase" ? candidate : current;
  }
  return candidate.sort_order < current.sort_order ? candidate : current;
}

function dedupeProcedures(
  procedures: AdminProcedureRecord[],
): AdminProcedureRecord[] {
  const deduped = new Map<string, AdminProcedureRecord>();
  const duplicates = new Map<string, AdminProcedureRecord[]>();

  for (const procedure of procedures) {
    const key = getProcedureCanonicalKey(procedure);
    const existing = deduped.get(key);
    if (!existing) {
      deduped.set(key, procedure);
      continue;
    }
    const preferred = choosePreferredProcedure(existing, procedure);
    const dropped = preferred === existing ? procedure : existing;
    deduped.set(key, preferred);
    duplicates.set(key, [...(duplicates.get(key) ?? []), dropped]);
  }

  if (duplicates.size > 0 && process.env.NODE_ENV !== "production") {
    for (const [key, droppedRows] of duplicates.entries()) {
      const kept = deduped.get(key);
      console.warn(
        `[content] Deduped procedure ${key}; kept ${
          kept ? formatProcedureDebugLabel(kept) : "unknown"
        } and dropped ${droppedRows.length} duplicate(s): ${droppedRows
          .map((row) => formatProcedureDebugLabel(row))
          .join(", ")}`,
      );
    }
  }

  return [...deduped.values()].sort((a, b) => {
    const categoryCompare = getProcedureCategorySlug(a).localeCompare(
      getProcedureCategorySlug(b),
    );
    if (categoryCompare !== 0) return categoryCompare;
    if (a.sort_order !== b.sort_order) return a.sort_order - b.sort_order;
    return getProcedureSlug(a).localeCompare(getProcedureSlug(b));
  });
}

const bundledExportPath = path.join(
  process.cwd(),
  "..",
  "..",
  "docs",
  "generated",
  "cms_bundled_content_export.json",
);

async function getCategoriesFromSupabase(supabase: any): Promise<AdminCategoryRecord[]> {
  const { data, error } = await supabase
    .from("ufficio_cms_categories")
    .select("*")
    .order("sort_order", { ascending: true });
  if (error) throw error;
  return (data ?? []).map((row: any) => ({ ...row, source: "supabase" as const }));
}

async function getProceduresFromSupabase(supabase: any): Promise<AdminProcedureRecord[]> {
  const { data, error } = await supabase
    .from("ufficio_cms_procedures")
    .select("*")
    .order("sort_order", { ascending: true });
  if (error) throw error;
  return dedupeProcedures(
    (data ?? []).map((row: any) => ({ ...row, source: "supabase" as const })),
  );
}

async function getBundledCmsExport(): Promise<BundledExport> {
  const raw = await fs.readFile(bundledExportPath, "utf8");
  return JSON.parse(raw) as BundledExport;
}

function canonicalCategoryRowsFromTree(exported: BundledExport): Record<string, unknown>[] {
  return (exported.categories ?? []).map((row: any, index) => ({
    id: row.slug ?? `category_${index}`,
    slug: row.slug ?? `category_${index}`,
    internal_label: row.slug ?? `category_${index}`,
    title: row.title ?? {},
    subtitle: row.subtitle ?? {},
    description: row.description ?? {},
    short_description: row.description ?? {},
    long_description: row.subtitle ?? {},
    icon: row.icon ?? null,
    color: row.color ?? null,
    sort_order: row.sort_order ?? index,
    is_active: row.is_active ?? true,
    is_premium: row.is_premium ?? false,
    verification_status: row.verification_status ?? "bundledFallback",
    tags: row.tags ?? [],
    synonyms: row.synonyms ?? [],
    searchable_keywords: row.searchable_keywords ?? [],
    monetization_type: row.monetization_type ?? "free",
    allow_single_unlock: row.allow_single_unlock ?? true,
    single_unlock_price_cents: row.single_unlock_price_cents ?? null,
    single_unlock_currency: row.single_unlock_currency ?? "EUR",
    premium_reason: row.premium_reason ?? {},
    premium_teaser: row.premium_teaser ?? row.description ?? {},
    metadata: row.metadata ?? {},
    public_snapshot: row,
  }));
}

function canonicalProcedureRowsFromTree(exported: BundledExport): Record<string, unknown>[] {
  return (exported.categories ?? []).flatMap((category: any) =>
    ((category.procedures as unknown[]) ?? []).map((row: any, index) => ({
      id: row.slug ?? `procedure_${index}`,
      slug: row.slug ?? `procedure_${index}`,
      category_slug: row.category_slug ?? category.slug ?? "",
      title: row.title ?? {},
      subtitle: row.subtitle ?? {},
      summary: row.summary ?? {},
      what_is_it: row.what_is_it ?? row.summary ?? {},
      why_you_may_need_it: row.why_you_may_need_it ?? [],
      how_to_do_it: row.how_to_do_it ?? [],
      required_documents: row.required_documents ?? [],
      optional_documents: row.optional_documents ?? [],
      warnings: row.warnings ?? [],
      common_mistakes: row.common_mistakes ?? [],
      proof_to_keep: row.proof_to_keep ?? [],
      faq: row.faq ?? row.faqs ?? [],
      official_links: row.official_links ?? [],
      status: row.status ?? "published",
      sort_order: row.sort_order ?? index,
      is_active: row.is_active ?? true,
      is_premium: row.is_premium ?? false,
      verification_status: row.verification_status ?? "bundledFallback",
      tags: row.tags ?? [],
      synonyms: row.synonyms ?? [],
      searchable_keywords: row.searchable_keywords ?? [],
      monetization_type: row.monetization_type ?? "free",
      allow_single_unlock: row.allow_single_unlock ?? true,
      single_unlock_price_cents: row.single_unlock_price_cents ?? null,
      single_unlock_currency: row.single_unlock_currency ?? "EUR",
      premium_reason: row.premium_reason ?? {},
      premium_teaser: row.premium_teaser ?? row.summary ?? {},
      metadata: {
        ...(row.metadata ?? {}),
        blocks: row.blocks ?? [],
      },
      public_snapshot: row,
    })),
  );
}

function getBundledCategories(exported: BundledExport): BundledCategory[] {
  return [
    ...(exported.richCategories ?? []),
    ...(exported.healthCategory ? [exported.healthCategory] : []),
    ...(exported.housingCategory ? [exported.housingCategory] : []),
  ];
}

function normalizeBundledCmsCategories(exported: BundledExport): AdminCategoryRecord[] {
  const sourceRows =
    exported.categories && exported.categories.length > 0
      ? canonicalCategoryRowsFromTree(exported)
      : (exported.cmsCategories ?? []);
  return sourceRows.map((row: any, index) => ({
    slug: String(row.slug ?? `category_${index}`),
    internal_label: row.internal_label ? String(row.internal_label) : null,
    title: (row.title ?? {}) as LocalizedText,
    subtitle: (row.subtitle ?? {}) as LocalizedText,
    description: (row.description ?? row.short_description ?? {}) as LocalizedText,
    icon: row.icon ? String(row.icon) : null,
    color: row.color ? String(row.color) : null,
    sort_order: Number(row.sort_order ?? index),
    is_active: Boolean(row.is_active ?? true),
    is_premium: Boolean(row.is_premium ?? false),
    verification_status: String(row.verification_status ?? "bundledFallback"),
    tags: Array.isArray(row.tags) ? row.tags.map(String) : [],
    synonyms: Array.isArray(row.synonyms) ? row.synonyms.map(String) : [],
    searchable_keywords: Array.isArray(row.searchable_keywords)
      ? row.searchable_keywords.map(String)
      : [],
    monetization_type: row.monetization_type ? String(row.monetization_type) : "free",
    allow_single_unlock: row.allow_single_unlock !== false,
    single_unlock_price_cents: typeof row.single_unlock_price_cents === "number" ? row.single_unlock_price_cents : null,
    single_unlock_currency: row.single_unlock_currency ? String(row.single_unlock_currency) : "EUR",
    premium_reason: (row.premium_reason ?? {}) as LocalizedText,
    premium_teaser: (row.premium_teaser ?? row.subtitle ?? {}) as LocalizedText,
    admin_notes: row.admin_notes ? String(row.admin_notes) : null,
    public_snapshot: (row.public_snapshot ?? row) as Record<string, unknown>,
    source: "bundled",
  }));
}

function normalizeBundledCmsProcedures(exported: BundledExport): AdminProcedureRecord[] {
  const sourceRows =
    exported.categories && exported.categories.length > 0
      ? canonicalProcedureRowsFromTree(exported)
      : (exported.cmsProcedures ?? []);
  return sourceRows.map((row: any, index) => ({
    id: row.id ? String(row.id) : undefined,
    slug: String(row.slug ?? `procedure_${index}`),
    category_slug: String(row.category_slug ?? ""),
    subcategory_slug: row.subcategory_slug
      ? String(row.subcategory_slug)
      : null,
    title: (row.title ?? {}) as LocalizedText,
    subtitle: (row.subtitle ?? {}) as LocalizedText,
    summary: (row.summary ?? {}) as LocalizedText,
    what_is_it: (row.what_is_it ?? row.summary ?? {}) as LocalizedText,
    why_you_may_need_it: Array.isArray(row.why_you_may_need_it)
      ? row.why_you_may_need_it.map(String)
      : [],
    how_to_do_it: Array.isArray(row.how_to_do_it) ? row.how_to_do_it.map(String) : [],
    required_documents: Array.isArray(row.required_documents)
      ? row.required_documents.map(String)
      : [],
    optional_documents: Array.isArray(row.optional_documents)
      ? row.optional_documents.map(String)
      : [],
    warnings: Array.isArray(row.warnings) ? row.warnings.map(String) : [],
    common_mistakes: Array.isArray(row.common_mistakes)
      ? row.common_mistakes.map(String)
      : [],
    proof_to_keep: Array.isArray(row.proof_to_keep) ? row.proof_to_keep.map(String) : [],
    faq: Array.isArray(row.faq) ? row.faq.map(String) : [],
    official_links: Array.isArray(row.official_links) ? row.official_links.map(String) : [],
    status: String(row.status ?? "bundledFallback"),
    sort_order: Number(row.sort_order ?? index),
    is_active: Boolean(row.is_active ?? true),
    is_premium: Boolean(row.is_premium ?? false),
    verification_status: String(row.verification_status ?? "bundledFallback"),
    tags: Array.isArray(row.tags) ? row.tags.map(String) : [],
    synonyms: Array.isArray(row.synonyms) ? row.synonyms.map(String) : [],
    searchable_keywords: Array.isArray(row.searchable_keywords)
      ? row.searchable_keywords.map(String)
      : [],
    monetization_type: row.monetization_type ? String(row.monetization_type) : "free",
    allow_single_unlock: row.allow_single_unlock !== false,
    single_unlock_price_cents: typeof row.single_unlock_price_cents === "number" ? row.single_unlock_price_cents : null,
    single_unlock_currency: row.single_unlock_currency ? String(row.single_unlock_currency) : "EUR",
    premium_reason: (row.premium_reason ?? {}) as LocalizedText,
    premium_teaser: (row.premium_teaser ?? row.subtitle ?? row.summary ?? {}) as LocalizedText,
    admin_notes: row.admin_notes ? String(row.admin_notes) : null,
    public_snapshot: (row.public_snapshot ?? row) as Record<string, unknown>,
    source: "bundled",
  }));
}

function toLocalizedText(en?: string, it?: string): LocalizedText {
  const title = (en ?? "").trim();
  const titleIt = (it ?? en ?? "").trim();
  return {
    en: title,
    it: titleIt,
  };
}

function toBundledCategoryRecord(
  category: BundledCategory,
  index: number,
): AdminCategoryRecord {
  const slug = String(category.id ?? `category_${index}`);
  return {
    slug,
    internal_label: String(category.title ?? slug),
    title: toLocalizedText(category.title, category.titleIt),
    subtitle: {},
    description: toLocalizedText(category.shortDescription, category.shortDescription),
    icon: null,
    color: null,
    sort_order: index,
    is_active: true,
    is_premium: false,
    verification_status: "bundledFallback",
    admin_notes: null,
    public_snapshot: category as Record<string, unknown>,
    source: "bundled",
  };
}

function toBundledProcedureRecord(
  categorySlug: string,
  procedure: BundledProcedure,
  index: number,
): AdminProcedureRecord {
  const slug = String(procedure.id ?? `${categorySlug}_${index}`);
  return {
    slug,
    category_slug: categorySlug,
    title: toLocalizedText(procedure.title, procedure.titleIt),
    subtitle: {},
    summary: toLocalizedText(procedure.whatIsIt, procedure.whatIsIt),
    what_is_it: toLocalizedText(procedure.whatIsIt, procedure.whatIsIt),
    why_you_may_need_it: Array.isArray(procedure.whyDoYouNeedIt)
      ? procedure.whyDoYouNeedIt.map(String)
      : [],
    how_to_do_it: [],
    required_documents: Array.isArray(procedure.documents)
      ? procedure.documents.map(String)
      : [],
    optional_documents: Array.isArray(procedure.extraDocuments)
      ? procedure.extraDocuments.map(String)
      : [],
    warnings: Array.isArray(procedure.warnings) ? procedure.warnings.map(String) : [],
    common_mistakes: [],
    proof_to_keep: [],
    faq: [],
    official_links: [],
    status: "bundledFallback",
    sort_order: index,
    is_active: true,
    is_premium: false,
    verification_status: "bundledFallback",
    admin_notes: null,
    public_snapshot: procedure as Record<string, unknown>,
    source: "bundled",
  };
}

async function getBundledContentTree(): Promise<AdminContentTree> {
  const exported = await getBundledCmsExport();
  const normalizedCategories = normalizeBundledCmsCategories(exported);
  const normalizedProcedures = normalizeBundledCmsProcedures(exported);
  if (normalizedCategories.length > 0) {
    return {
      source: "bundled",
      categories: normalizedCategories,
      procedures: dedupeProcedures(normalizedProcedures),
    };
  }
  const bundledCategories = getBundledCategories(exported);
  const categories = bundledCategories.map(toBundledCategoryRecord);
  const procedures = bundledCategories.flatMap((category, categoryIndex) =>
    (category.subcategories ?? []).map((procedure, procedureIndex) =>
      toBundledProcedureRecord(
        String(category.id ?? `category_${categoryIndex}`),
        procedure,
        procedureIndex,
      ),
    ),
  );

  return {
    source: "bundled",
    categories,
    procedures: dedupeProcedures(procedures),
  };
}

async function bootstrapBundledContent(
  supabase: any,
  tree: AdminContentTree,
): Promise<void> {
  const { data: existingCategories } = await supabase
    .from("ufficio_cms_categories")
    .select("slug");
  const { data: existingProcedures } = await supabase
    .from("ufficio_cms_procedures")
    .select("category_slug, slug");

  const existingCategorySlugs = new Set(
    (existingCategories ?? []).map((row: any) => String(row.slug)),
  );
  const existingProcedureKeys = new Set(
    (existingProcedures ?? []).map(
      (row: any) => `${String(row.category_slug)}::${String(row.slug)}`,
    ),
  );

  const missingCategories = tree.categories
    .filter((category) => !existingCategorySlugs.has(category.slug))
    .map((category) => ({
      slug: category.slug,
      internal_label: category.internal_label,
      title: category.title,
      subtitle: category.subtitle ?? {},
      description: category.description ?? {},
      icon: category.icon,
      color: category.color,
      sort_order: category.sort_order,
      is_active: category.is_active,
      is_premium: category.is_premium,
      verification_status: category.verification_status,
      tags: category.tags ?? [],
      synonyms: category.synonyms ?? [],
      searchable_keywords: category.searchable_keywords ?? [],
      monetization_type: category.monetization_type ?? "free",
      allow_single_unlock: category.allow_single_unlock ?? true,
      single_unlock_price_cents: category.single_unlock_price_cents ?? null,
      single_unlock_currency: category.single_unlock_currency ?? "EUR",
      premium_reason: category.premium_reason ?? {},
      premium_teaser: category.premium_teaser ?? {},
      metadata: category.public_snapshot ?? {},
      public_snapshot: category.public_snapshot ?? {},
    }));

  const missingProcedures = tree.procedures
    .filter(
      (procedure) =>
        !existingProcedureKeys.has(
          `${procedure.category_slug}::${procedure.slug}`,
        ),
    )
    .map((procedure) => ({
      category_slug: procedure.category_slug,
      slug: procedure.slug,
      title: procedure.title,
      subtitle: procedure.subtitle ?? {},
      summary: procedure.summary,
      what_is_it: procedure.what_is_it,
      why_you_may_need_it: procedure.why_you_may_need_it,
      how_to_do_it: procedure.how_to_do_it,
      required_documents: procedure.required_documents,
      optional_documents: procedure.optional_documents,
      warnings: procedure.warnings,
      common_mistakes: procedure.common_mistakes,
      proof_to_keep: procedure.proof_to_keep,
      faq: procedure.faq,
      official_links: procedure.official_links,
      status: procedure.status,
      sort_order: procedure.sort_order,
      is_active: procedure.is_active,
      is_premium: procedure.is_premium,
      verification_status: procedure.verification_status,
      tags: procedure.tags ?? [],
      synonyms: procedure.synonyms ?? [],
      searchable_keywords: procedure.searchable_keywords ?? [],
      monetization_type: procedure.monetization_type ?? "free",
      allow_single_unlock: procedure.allow_single_unlock ?? true,
      single_unlock_price_cents: procedure.single_unlock_price_cents ?? null,
      single_unlock_currency: procedure.single_unlock_currency ?? "EUR",
      premium_reason: procedure.premium_reason ?? {},
      premium_teaser: procedure.premium_teaser ?? {},
      metadata: procedure.public_snapshot ?? {},
      public_snapshot: procedure.public_snapshot ?? {},
    }));

  if (missingCategories.length > 0) {
    await supabase.from("ufficio_cms_categories").insert(missingCategories);
  }

  if (missingProcedures.length > 0) {
    await supabase.from("ufficio_cms_procedures").insert(missingProcedures);
  }

  if (missingCategories.length > 0 || missingProcedures.length > 0) {
    await supabase.from("ufficio_admin_audit_logs").insert({
      action: "auto_bootstrap_missing_bundled_content",
      target_table: "ufficio_cms_categories",
      target_id: null,
      metadata: {
        categoriesInserted: missingCategories.map((item) => item.slug),
        proceduresInserted: missingProcedures.map(
          (item) => `${item.category_slug}::${item.slug}`,
        ),
      },
    });
  }
}

export async function getAdminContentTree(
  supabase: any,
  options?: { bootstrapIfEmpty?: boolean },
): Promise<AdminContentTree> {
  const bundled = await getBundledContentTree();
  try {
    if (options?.bootstrapIfEmpty) {
      try {
        await bootstrapBundledContent(supabase, bundled);
      } catch {
        // Keep existing content visible even if sync repair fails.
      }
    }
    const categories = await getCategoriesFromSupabase(supabase);
    if (categories.length > 0) {
      const procedures = await getProceduresFromSupabase(supabase);
      return {
        source: "supabase",
        categories,
        procedures,
      };
    }
  } catch {
    // Fall through to bundled content.
  }

  return bundled;
}

export async function getAdminCategories(
  supabase: any,
  options?: { bootstrapIfEmpty?: boolean },
) {
  const tree = await getAdminContentTree(supabase, options);
  return tree.categories;
}

export async function getAdminCategoryBySlug(
  supabase: any,
  slug: string,
  options?: { bootstrapIfEmpty?: boolean },
) {
  const tree = await getAdminContentTree(supabase, options);
  return tree.categories.find((category) => category.slug === slug) ?? null;
}

export async function getAdminProceduresByCategorySlug(
  supabase: any,
  categorySlug: string,
  options?: { bootstrapIfEmpty?: boolean },
) {
  const tree = await getAdminContentTree(supabase, options);
  return tree.procedures.filter((procedure) => procedure.category_slug === categorySlug);
}

export async function getAdminProcedureBySlug(
  supabase: any,
  slug: string,
  options?: { bootstrapIfEmpty?: boolean },
) {
  // Legacy helper: slug-only lookup is ambiguous if the same procedure slug exists
  // under multiple categories. Prefer getAdminProcedureByCategoryAndSlug.
  const tree = await getAdminContentTree(supabase, options);
  const matches = tree.procedures.filter((procedure) => procedure.slug === slug);
  return matches.length === 1 ? matches[0] : null;
}

export async function findAdminProceduresBySlug(
  supabase: any,
  slug: string,
  options?: { bootstrapIfEmpty?: boolean },
): Promise<LegacyProcedureSlugMatch> {
  const tree = await getAdminContentTree(supabase, options);
  return {
    slug,
    matches: tree.procedures.filter((procedure) => getProcedureSlug(procedure) === slug),
  };
}

export async function getAdminProcedureByCategoryAndSlug(
  supabase: any,
  categorySlug: string,
  slug: string,
  options?: { bootstrapIfEmpty?: boolean },
) {
  const tree = await getAdminContentTree(supabase, options);
  return (
    tree.procedures.find(
      (procedure) =>
        getProcedureCategorySlug(procedure) === categorySlug &&
        getProcedureSlug(procedure) === slug,
    ) ?? null
  );
}

export {
  getProcedureCategorySlug,
  getProcedureRoutePath,
  getProcedureSlug,
  getProcedureSubcategorySlug,
};
