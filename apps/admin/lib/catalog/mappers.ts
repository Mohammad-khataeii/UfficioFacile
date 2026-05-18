import type {
  AdminCategoryRecord,
  AdminProcedureRecord,
} from "@/lib/content/load-content-tree";

import {
  adminSupportedLanguages,
  type AdminCategory,
  type AdminLanguageCode,
  type AdminLocalizedText,
  type AdminPremiumVisibility,
  type AdminProcedure,
  type AdminSubcategory,
} from "@/lib/catalog/types";

function cleanString(value: unknown): string | null {
  if (typeof value !== "string") {
    return null;
  }
  const trimmed = value.trim();
  return trimmed.length > 0 ? trimmed : null;
}

function humanizeSlug(slug: string): string {
  return slug
    .split(/[-_/]+/)
    .filter(Boolean)
    .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
    .join(" ");
}

function recordValue(value: unknown): Record<string, unknown> {
  return value && typeof value === "object" && !Array.isArray(value)
    ? (value as Record<string, unknown>)
    : {};
}

function stringListValue(value: unknown): string[] {
  if (Array.isArray(value)) {
    return value
      .map((item) => {
        if (typeof item === "string") {
          return item.trim();
        }
        if (item && typeof item === "object") {
          const label = cleanString((item as Record<string, unknown>).label);
          const title = cleanString((item as Record<string, unknown>).title);
          const valueText = cleanString((item as Record<string, unknown>).value);
          return label ?? title ?? valueText ?? "";
        }
        return "";
      })
      .filter(Boolean);
  }

  if (typeof value === "string") {
    return value
      .split("\n")
      .map((item) => item.trim())
      .filter(Boolean);
  }

  return [];
}

function localizedTextValue(
  value: unknown,
  fallback?: string | null,
): AdminLocalizedText {
  const result: AdminLocalizedText = {};
  const record = recordValue(value);

  for (const language of adminSupportedLanguages) {
    const text = cleanString(record[language]);
    if (text) {
      result[language] = text;
    }
  }

  const safeFallback = cleanString(fallback);
  if (!result.en && safeFallback) {
    result.en = safeFallback;
  }

  if (Object.keys(result).length === 0 && safeFallback) {
    result.en = safeFallback;
  }

  return result;
}

function translationCoverage(localized: AdminLocalizedText) {
  return Object.fromEntries(
    adminSupportedLanguages.map((language) => [
      language,
      Boolean(cleanString(localized[language])),
    ]),
  ) as Partial<Record<AdminLanguageCode, boolean>>;
}

function premiumVisibilityFromRaw(raw: {
  is_active?: boolean;
  status?: string;
  is_premium?: boolean;
  monetization_type?: string;
  metadata?: unknown;
}): AdminPremiumVisibility {
  const metadata = recordValue(raw.metadata);
  const explicit = cleanString(metadata.premium_visibility ?? metadata.premiumVisibility);
  if (
    explicit === "free" ||
    explicit === "premium_preview" ||
    explicit === "premium_only" ||
    explicit === "hidden"
  ) {
    return explicit;
  }

  if (raw.is_active === false || raw.status === "archived") {
    return "hidden";
  }

  if (raw.is_premium === true) {
    return "premium_only";
  }

  if (cleanString(raw.monetization_type)?.startsWith("premium")) {
    return "premium_preview";
  }

  return "free";
}

function procedureMetadata(raw: AdminProcedureRecord): Record<string, unknown> {
  return recordValue(raw.public_snapshot?.metadata ?? raw.public_snapshot ?? {});
}

export function normalizeCategory(
  raw: AdminCategoryRecord,
  stats?: { procedureCount?: number; subcategoryCount?: number },
): AdminCategory {
  const title = localizedTextValue(raw.title, humanizeSlug(raw.slug));
  const description = localizedTextValue(raw.description);
  const subtitle = localizedTextValue(raw.subtitle);

  return {
    id: raw.slug,
    slug: raw.slug,
    title,
    description,
    subtitle,
    icon: cleanString(raw.icon),
    color: cleanString(raw.color),
    sortOrder: Number.isFinite(raw.sort_order) ? raw.sort_order : 0,
    isPublished: raw.is_active === true,
    premiumVisibility: premiumVisibilityFromRaw(raw),
    source: raw.source,
    verificationStatus: cleanString(raw.verification_status) ?? "needsReview",
    tags: stringListValue(raw.tags),
    synonyms: stringListValue(raw.synonyms),
    searchableKeywords: stringListValue(raw.searchable_keywords),
    premiumReason: localizedTextValue(raw.premium_reason),
    premiumTeaser: localizedTextValue(raw.premium_teaser),
    adminNotes: cleanString(raw.admin_notes),
    createdAt: null,
    updatedAt: null,
    procedureCount: stats?.procedureCount ?? 0,
    subcategoryCount: stats?.subcategoryCount ?? 0,
    translationCoverage: translationCoverage(title),
    raw,
  };
}

function mergeSubcategoryVisibility(
  derived: AdminPremiumVisibility,
  explicit?: AdminPremiumVisibility | null,
): AdminPremiumVisibility {
  if (
    explicit === "free" ||
    explicit === "premium_preview" ||
    explicit === "premium_only" ||
    explicit === "hidden"
  ) {
    return explicit;
  }
  return derived;
}

export function normalizeProcedure(raw: AdminProcedureRecord): AdminProcedure {
  const title = localizedTextValue(raw.title, humanizeSlug(raw.slug));
  const summary = localizedTextValue(raw.summary);
  const metadata = procedureMetadata(raw);
  const contacts = stringListValue(
    metadata.contacts ?? metadata.recommendedContacts ?? [],
  );
  const channels = stringListValue(
    metadata.channels ?? metadata.recommendedChannels ?? [],
  );
  const costs = stringListValue(metadata.costs ?? metadata.costsAndTiming ?? []);
  const timeline = stringListValue(metadata.timeline ?? metadata.timing ?? []);
  const premiumVisibility = premiumVisibilityFromRaw({
    is_active: raw.is_active,
    status: raw.status,
    is_premium: raw.is_premium,
    monetization_type: raw.monetization_type,
    metadata,
  });
  const subcategorySlug =
    cleanString(raw.subcategory_slug) ??
    cleanString(metadata.subcategory_slug ?? metadata.subcategorySlug);

  return {
    id: cleanString(raw.id) ?? `path:${raw.category_slug}::${raw.slug}`,
    categoryId: raw.category_slug,
    categorySlug: raw.category_slug,
    subcategoryId: subcategorySlug,
    subcategorySlug,
    slug: raw.slug,
    title,
    subtitle: localizedTextValue(raw.subtitle),
    summary,
    whatIsIt: localizedTextValue(raw.what_is_it),
    steps: stringListValue(raw.how_to_do_it),
    whyYouMayNeedIt: stringListValue(raw.why_you_may_need_it),
    documentsRequired: stringListValue(raw.required_documents),
    optionalDocuments: stringListValue(raw.optional_documents),
    officialLinks: stringListValue(raw.official_links),
    warnings: stringListValue(raw.warnings),
    commonMistakes: stringListValue(raw.common_mistakes),
    proofToKeep: stringListValue(raw.proof_to_keep),
    faq: stringListValue(raw.faq),
    costs,
    timeline,
    contacts,
    channels,
    premiumVisibility,
    requiredPlan: premiumVisibility === "free" ? null : "premium",
    monetizationType: cleanString(raw.monetization_type),
    allowSingleUnlock: raw.allow_single_unlock === true,
    singleUnlockPriceCents:
      typeof raw.single_unlock_price_cents === "number"
        ? raw.single_unlock_price_cents
        : null,
    singleUnlockCurrency: cleanString(raw.single_unlock_currency),
    isPublished: raw.is_active === true && raw.status === "published",
    status: cleanString(raw.status) ?? "draft",
    sortOrder: Number.isFinite(raw.sort_order) ? raw.sort_order : 0,
    source: raw.source,
    verificationStatus: cleanString(raw.verification_status) ?? "needsReview",
    tags: stringListValue(raw.tags),
    synonyms: stringListValue(raw.synonyms),
    searchableKeywords: stringListValue(raw.searchable_keywords),
    premiumReason: localizedTextValue(raw.premium_reason),
    premiumTeaser: localizedTextValue(raw.premium_teaser),
    adminNotes: cleanString(raw.admin_notes),
    publicSnapshot: recordValue(raw.public_snapshot),
    metadata,
    createdAt: cleanString(metadata.created_at),
    updatedAt: cleanString(metadata.updated_at),
    translationCoverage: translationCoverage(title),
    raw,
  };
}

export function buildAdminSubcategories(
  category: AdminCategory,
  procedures: AdminProcedure[],
  explicitSubcategories: AdminCategory[] = [],
): {
  subcategories: AdminSubcategory[];
  uncategorizedProcedures: AdminProcedure[];
} {
  const grouped = new Map<string, AdminProcedure[]>();
  const uncategorizedProcedures: AdminProcedure[] = [];

  for (const procedure of procedures) {
    if (!procedure.subcategorySlug) {
      uncategorizedProcedures.push(procedure);
      continue;
    }
    const group = grouped.get(procedure.subcategorySlug) ?? [];
    group.push(procedure);
    grouped.set(procedure.subcategorySlug, group);
  }

  const subcategories = Array.from(grouped.entries())
    .map(([slug, group]) => {
      const first = group[0];
      const explicit = explicitSubcategories.find((item) => item.slug === slug);
      const metadataTitle = localizedTextValue(
        explicit?.title ??
          first.metadata.subcategory_title ??
          first.metadata.subcategoryTitle,
        humanizeSlug(slug),
      );
      const description = localizedTextValue(
        explicit?.description ??
          first.metadata.subcategory_description ??
          first.metadata.subcategoryDescription,
      );
      const derivedPremiumVisibility = group.some(
        (procedure) => procedure.premiumVisibility !== "free",
      )
        ? "premium_only"
        : "free";
      const premiumVisibility = mergeSubcategoryVisibility(
        derivedPremiumVisibility,
        explicit?.premiumVisibility,
      );

      return {
        id: `${category.slug}:${slug}`,
        categoryId: category.id,
        categorySlug: category.slug,
        slug,
        title: metadataTitle,
        description,
        sortOrder:
          explicit?.sortOrder ??
          Math.min(...group.map((procedure) => procedure.sortOrder)),
        isPublished: explicit?.isPublished ?? group.some((procedure) => procedure.isPublished),
        premiumVisibility,
        createdAt: explicit?.createdAt ?? null,
        updatedAt: explicit?.updatedAt ?? null,
        procedureCount: group.length,
        translationCoverage: translationCoverage(metadataTitle),
        procedures: group.sort((a, b) => a.sortOrder - b.sortOrder),
      } satisfies AdminSubcategory;
    })
    .sort((a, b) => a.sortOrder - b.sortOrder || a.slug.localeCompare(b.slug));

  return {
    subcategories,
    uncategorizedProcedures: uncategorizedProcedures.sort(
      (a, b) => a.sortOrder - b.sortOrder || a.slug.localeCompare(b.slug),
    ),
  };
}
