import type {
  AdminCategoryRecord,
  AdminContentSource,
  AdminProcedureRecord,
} from "@/lib/content/load-content-tree";

export const adminSupportedLanguages = ["en", "it", "fr", "es", "fa", "ar"] as const;

export type AdminLanguageCode = (typeof adminSupportedLanguages)[number];

export type AdminLocalizedText = Partial<Record<AdminLanguageCode, string>>;

export type AdminPremiumVisibility =
  | "free"
  | "premium_preview"
  | "premium_only"
  | "hidden";

export type AdminCategory = {
  id: string;
  slug: string;
  title: AdminLocalizedText;
  description: AdminLocalizedText;
  subtitle: AdminLocalizedText;
  icon: string | null;
  color: string | null;
  sortOrder: number;
  isPublished: boolean;
  premiumVisibility: AdminPremiumVisibility;
  source: AdminContentSource;
  verificationStatus: string;
  tags: string[];
  synonyms: string[];
  searchableKeywords: string[];
  premiumReason: AdminLocalizedText;
  premiumTeaser: AdminLocalizedText;
  adminNotes: string | null;
  createdAt: string | null;
  updatedAt: string | null;
  procedureCount: number;
  subcategoryCount: number;
  translationCoverage: Partial<Record<AdminLanguageCode, boolean>>;
  raw: AdminCategoryRecord;
};

export type AdminSubcategory = {
  id: string;
  categoryId: string;
  categorySlug: string;
  slug: string;
  title: AdminLocalizedText;
  description: AdminLocalizedText;
  sortOrder: number;
  isPublished: boolean;
  premiumVisibility: AdminPremiumVisibility;
  createdAt: string | null;
  updatedAt: string | null;
  procedureCount: number;
  translationCoverage: Partial<Record<AdminLanguageCode, boolean>>;
  procedures: AdminProcedure[];
};

export type AdminProcedure = {
  id: string;
  categoryId: string;
  categorySlug: string;
  subcategoryId: string | null;
  subcategorySlug: string | null;
  slug: string;
  title: AdminLocalizedText;
  subtitle: AdminLocalizedText;
  summary: AdminLocalizedText;
  whatIsIt: AdminLocalizedText;
  steps: string[];
  whyYouMayNeedIt: string[];
  documentsRequired: string[];
  optionalDocuments: string[];
  officialLinks: string[];
  warnings: string[];
  commonMistakes: string[];
  proofToKeep: string[];
  faq: string[];
  costs: string[];
  timeline: string[];
  contacts: string[];
  channels: string[];
  premiumVisibility: AdminPremiumVisibility;
  requiredPlan: "premium" | null;
  monetizationType: string | null;
  allowSingleUnlock: boolean;
  singleUnlockPriceCents: number | null;
  singleUnlockCurrency: string | null;
  isPublished: boolean;
  status: string;
  sortOrder: number;
  source: AdminContentSource;
  verificationStatus: string;
  tags: string[];
  synonyms: string[];
  searchableKeywords: string[];
  premiumReason: AdminLocalizedText;
  premiumTeaser: AdminLocalizedText;
  adminNotes: string | null;
  publicSnapshot: Record<string, unknown>;
  metadata: Record<string, unknown>;
  createdAt: string | null;
  updatedAt: string | null;
  translationCoverage: Partial<Record<AdminLanguageCode, boolean>>;
  raw: AdminProcedureRecord;
};

export type AdminCatalogTree = {
  source: AdminContentSource;
  categories: AdminCategory[];
  procedures: AdminProcedure[];
  subcategories: AdminSubcategory[];
};

export type AdminCategoryDetail = {
  category: AdminCategory;
  subcategories: AdminSubcategory[];
  uncategorizedProcedures: AdminProcedure[];
};

export type AdminProcedureRouteRequest = {
  categorySlug: string;
  procedureSlug: string;
};
