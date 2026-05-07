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
  admin_notes: string | null;
  public_snapshot?: Record<string, unknown>;
  source: AdminContentSource;
};

export type AdminProcedureRecord = {
  slug: string;
  category_slug: string;
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
  admin_notes: string | null;
  public_snapshot?: Record<string, unknown>;
  source: AdminContentSource;
};

export type AdminContentTree = {
  source: AdminContentSource;
  categories: AdminCategoryRecord[];
  procedures: AdminProcedureRecord[];
};

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
  return (data ?? []).map((row: any) => ({ ...row, source: "supabase" as const }));
}

async function getBundledCmsExport(): Promise<BundledExport> {
  const raw = await fs.readFile(bundledExportPath, "utf8");
  return JSON.parse(raw) as BundledExport;
}

function getBundledCategories(exported: BundledExport): BundledCategory[] {
  return [
    ...(exported.richCategories ?? []),
    ...(exported.healthCategory ? [exported.healthCategory] : []),
    ...(exported.housingCategory ? [exported.housingCategory] : []),
  ];
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
    procedures,
  };
}

export async function getAdminContentTree(supabase: any): Promise<AdminContentTree> {
  try {
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

  return getBundledContentTree();
}

export async function getAdminCategories(supabase: any) {
  const tree = await getAdminContentTree(supabase);
  return tree.categories;
}

export async function getAdminCategoryBySlug(supabase: any, slug: string) {
  const tree = await getAdminContentTree(supabase);
  return tree.categories.find((category) => category.slug === slug) ?? null;
}

export async function getAdminProceduresByCategorySlug(
  supabase: any,
  categorySlug: string,
) {
  const tree = await getAdminContentTree(supabase);
  return tree.procedures.filter((procedure) => procedure.category_slug === categorySlug);
}

export async function getAdminProcedureBySlug(supabase: any, slug: string) {
  const tree = await getAdminContentTree(supabase);
  return tree.procedures.find((procedure) => procedure.slug === slug) ?? null;
}
