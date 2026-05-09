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
];

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
const hits = forbidden.filter((phrase) => text.includes(phrase));

if (hits.length) {
  console.error("Forbidden user-facing phrases found:", hits.join(", "));
  process.exit(1);
}

const requiredLanguages = ["en", "it", "fr", "es", "fa", "ar"];
const categories = payload.cmsCategories ?? [];
const procedures = payload.cmsProcedures ?? [];

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
  (item) => item.category_slug === "bonuses-benefits" && item.slug === "bonus-finder",
);
if (bonusFinder?.metadata?.tool_type !== "bonus_finder") {
  console.error("Bonus finder must declare metadata.tool_type = bonus_finder.");
  process.exit(1);
}

const loanComparison = procedures.find(
  (item) => item.category_slug === "loans-credit" && item.slug === "loan-comparison",
);
if (loanComparison?.metadata?.tool_type !== "loan_comparison") {
  console.error("Loan comparison must declare metadata.tool_type = loan_comparison.");
  process.exit(1);
}

for (const procedure of procedures.filter((item) => item.category_slug === "loans-credit")) {
  const warnings = JSON.stringify(procedure.public_snapshot?.blocks ?? procedure.metadata?.blocks ?? []).toLowerCase();
  if (!warnings.includes("credit") && !warnings.includes("taeg")) {
    console.error(`Loan procedure ${procedure.slug} is missing a credit warning block.`);
    process.exit(1);
  }
}

for (const procedure of procedures.filter((item) => item.category_slug === "bonuses-benefits")) {
  const warnings = JSON.stringify(procedure.public_snapshot?.blocks ?? procedure.metadata?.blocks ?? []).toLowerCase();
  const metadata = JSON.stringify(procedure.metadata ?? {}).toLowerCase();
  if (!warnings.includes("verify") && !metadata.includes("warning")) {
    console.error(`Bonus procedure ${procedure.slug} is missing a verify-before-applying warning.`);
    process.exit(1);
  }
}

console.log("Content lint passed.");
