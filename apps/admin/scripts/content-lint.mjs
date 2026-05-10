import { readFile } from "node:fs/promises";
import path from "node:path";

const forbidden = [
  "to help the user",
  "the user should",
  "do not show",
  "internal note",
  "for codex",
  "beta access active",
  "demo data",
  "pro feature",
  "lorem",
  "placeholder",
  "todo",
  "fixme",
];

function escapeRegExp(value) {
  return value.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

function toForbiddenPattern(phrase) {
  if (["todo", "fixme", "lorem", "placeholder"].includes(phrase)) {
    return new RegExp(`\\b${escapeRegExp(phrase)}\\b`, "i");
  }
  return new RegExp(escapeRegExp(phrase), "i");
}

const filePath = path.join(
  process.cwd(),
  "..",
  "..",
  "docs",
  "generated",
  "cms_bundled_content_export.json",
);

const raw = await readFile(filePath, "utf8");
const payload = JSON.parse(raw);
const text = raw.toLowerCase();
const hits = forbidden.filter((phrase) => toForbiddenPattern(phrase).test(text));

if (hits.length) {
  console.error("Forbidden user-facing phrases found:", hits.join(", "));
  process.exit(1);
}

const requiredLanguages = ["en", "it", "fr", "es", "fa", "ar"];
const categories = payload.cmsCategories ?? [];
const procedures = payload.cmsProcedures ?? [];

if (!raw.trim().length || categories.length === 0 || procedures.length === 0) {
  console.error("Bundled CMS export must be non-empty.");
  process.exit(1);
}

const duplicateCategorySlugs = new Set();
const seenCategorySlugs = new Set();
for (const category of categories) {
  const slug = String(category.slug ?? "").trim();
  if (!slug) {
    console.error("Category missing slug.");
    process.exit(1);
  }
  if (seenCategorySlugs.has(slug)) {
    duplicateCategorySlugs.add(slug);
  }
  seenCategorySlugs.add(slug);
}
if (duplicateCategorySlugs.size) {
  console.error(`Duplicate category slugs found: ${[...duplicateCategorySlugs].sort().join(", ")}`);
  process.exit(1);
}

const duplicateProcedureKeys = new Map();
const duplicateProcedureRoutes = new Map();
for (const procedure of procedures) {
  const categorySlug = String(procedure.category_slug ?? "").trim();
  const slug = String(procedure.slug ?? "").trim();
  if (!categorySlug || !slug) {
    console.error(`Procedure is missing category_slug or slug: ${JSON.stringify({ id: procedure.id ?? null, category_slug: procedure.category_slug ?? null, slug: procedure.slug ?? null })}`);
    process.exit(1);
  }
  const key = `${categorySlug}::${slug}`;
  const route = `/content/procedures/${categorySlug}/${slug}`;
  duplicateProcedureKeys.set(key, (duplicateProcedureKeys.get(key) ?? 0) + 1);
  duplicateProcedureRoutes.set(route, (duplicateProcedureRoutes.get(route) ?? 0) + 1);
}

const duplicateKeyHits = [...duplicateProcedureKeys.entries()]
  .filter(([, count]) => count > 1)
  .map(([key, count]) => `${key} (${count})`);
if (duplicateKeyHits.length) {
  console.error(`Duplicate procedure public identities found: ${duplicateKeyHits.join(", ")}`);
  process.exit(1);
}

const duplicateRouteHits = [...duplicateProcedureRoutes.entries()]
  .filter(([, count]) => count > 1)
  .map(([route, count]) => `${route} (${count})`);
if (duplicateRouteHits.length) {
  console.error(`Duplicate public procedure routes found: ${duplicateRouteHits.join(", ")}`);
  process.exit(1);
}

for (const category of categories) {
  for (const language of requiredLanguages) {
    if (!category.title?.[language]) {
      console.error(`Missing category title for ${category.slug} in ${language}`);
      process.exit(1);
    }
  }
}

for (const procedure of procedures) {
  for (const language of requiredLanguages) {
    if (!procedure.title?.[language]) {
      console.error(`Missing procedure title for ${procedure.slug} in ${language}`);
      process.exit(1);
    }
  }
}

for (const category of categories.filter((item) =>
  item.slug === "bonuses-benefits" || item.slug === "loans-credit"
)) {
  if (category.is_premium !== true) {
    console.error(`Money category ${category.slug} must be premium.`);
    process.exit(1);
  }
  if (!category.premium_teaser || !Object.keys(category.premium_teaser).length) {
    console.error(`Money category ${category.slug} must include premium teaser text.`);
    process.exit(1);
  }
}

for (const procedure of procedures) {
  const encoded = JSON.stringify(procedure).toLowerCase();
  if (
    encoded.includes("answer a few questions") &&
    procedure.metadata?.tool_type == null
  ) {
    console.error(`Interactive copy without tool_type on ${procedure.category_slug}::${procedure.slug}`);
    process.exit(1);
  }
  if (procedure.is_premium === true) {
    if (!procedure.premium_teaser || !Object.keys(procedure.premium_teaser).length) {
      console.error(`Premium procedure ${procedure.category_slug}::${procedure.slug} is missing premium teaser text.`);
      process.exit(1);
    }
  }
}

const bonusFinder = procedures.find(
  (item) =>
    item.category_slug === "bonuses-benefits" &&
    item.metadata?.canonical_subcategory_id === "bonus_finder",
);
if (bonusFinder?.metadata?.tool_type !== "bonus_finder") {
  console.error("Bonus finder must declare metadata.tool_type = bonus_finder.");
  process.exit(1);
}

const loanComparison = procedures.find(
  (item) =>
    item.category_slug === "loans-credit" &&
    item.metadata?.canonical_subcategory_id === "compare_loans_safely",
);
if (loanComparison?.metadata?.tool_type !== "loan_comparison") {
  console.error("Loan comparison must declare metadata.tool_type = loan_comparison.");
  process.exit(1);
}

console.log("Content lint passed.");
