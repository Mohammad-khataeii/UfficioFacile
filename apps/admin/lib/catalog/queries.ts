import type { AdminCategory, AdminCategoryDetail, AdminCatalogTree, AdminProcedure } from "@/lib/catalog/types";
import {
  buildAdminSubcategories,
  normalizeCategory,
  normalizeProcedure,
} from "@/lib/catalog/mappers";
import {
  getAdminCategories,
  getAdminCategoryBySlug,
  getAdminContentTree,
  getAdminProcedureByCategoryAndSlug,
  getAdminProceduresByCategorySlug,
} from "@/lib/content/load-content-tree";

export async function getAdminCatalogTreeNormalized(
  supabase: any,
  options?: { bootstrapIfEmpty?: boolean },
): Promise<AdminCatalogTree> {
  const tree = await getAdminContentTree(supabase, options);
  const procedures = tree.procedures.map(normalizeProcedure);
  const normalizedCategories = tree.categories.map((rawCategory) =>
    normalizeCategory(rawCategory),
  );

  const categories = tree.categories
    .filter((rawCategory) => !rawCategory.parent_slug)
    .map((rawCategory) => {
      const categoryProcedures = procedures.filter(
        (procedure) => procedure.categorySlug === rawCategory.slug,
      );
      const explicitSubcategories = normalizedCategories.filter(
        (item) => item.raw.parent_slug === rawCategory.slug,
      );
      const derived = buildAdminSubcategories(
        normalizeCategory(rawCategory),
        categoryProcedures,
        explicitSubcategories,
      );
      return normalizeCategory(rawCategory, {
        procedureCount: categoryProcedures.length,
        subcategoryCount: derived.subcategories.length,
      });
    });

  const subcategories = categories.flatMap((category) =>
    buildAdminSubcategories(
      category,
      procedures.filter((procedure) => procedure.categorySlug === category.slug),
      normalizedCategories.filter((item) => item.raw.parent_slug === category.slug),
    ).subcategories,
  );

  return {
    source: tree.source,
    categories,
    procedures,
    subcategories,
  };
}

export async function getAdminCategoryDetailNormalized(
  supabase: any,
  slug: string,
  options?: { bootstrapIfEmpty?: boolean },
): Promise<AdminCategoryDetail | null> {
  const rawCategory = await getAdminCategoryBySlug(supabase, slug, options);
  if (!rawCategory) {
    return null;
  }

  const procedures = (await getAdminProceduresByCategorySlug(
    supabase,
    slug,
    options,
  )).map(normalizeProcedure);
  const allCategories = await getAdminCategories(supabase, options);
  const explicitSubcategories = allCategories
    .filter((item) => item.parent_slug === slug)
    .map((item) => normalizeCategory(item));
  const category = normalizeCategory(rawCategory, {
    procedureCount: procedures.length,
    subcategoryCount: new Set(
      procedures.map((procedure) => procedure.subcategorySlug).filter(Boolean),
    ).size,
  });
  const { subcategories, uncategorizedProcedures } = buildAdminSubcategories(
    category,
    procedures,
    explicitSubcategories,
  );

  return {
    category,
    subcategories,
    uncategorizedProcedures,
  };
}

export async function getAdminProcedureDetailNormalized(
  supabase: any,
  categorySlug: string,
  procedureSlug: string,
  options?: { bootstrapIfEmpty?: boolean },
): Promise<AdminProcedure | null> {
  const rawProcedure = await getAdminProcedureByCategoryAndSlug(
    supabase,
    categorySlug,
    procedureSlug,
    options,
  );

  return rawProcedure ? normalizeProcedure(rawProcedure) : null;
}

export async function getAdminCategoriesNormalized(
  supabase: any,
  options?: { bootstrapIfEmpty?: boolean },
): Promise<AdminCategory[]> {
  const rawCategories = await getAdminCategories(supabase, options);
  const rawTree = await getAdminContentTree(supabase, options);
  const procedures = rawTree.procedures.map(normalizeProcedure);

  return rawCategories.map((rawCategory) => {
    const categoryProcedures = procedures.filter(
      (procedure) => procedure.categorySlug === rawCategory.slug,
    );
    return normalizeCategory(rawCategory, {
      procedureCount: categoryProcedures.length,
      subcategoryCount: new Set(
        categoryProcedures.map((procedure) => procedure.subcategorySlug).filter(Boolean),
      ).size,
    });
  });
}
