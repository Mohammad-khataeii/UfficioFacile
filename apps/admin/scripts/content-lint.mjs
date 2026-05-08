import { readFile } from "node:fs/promises";
import path from "node:path";

const forbidden = [
  "to help the user",
  "the user should",
  "do not show",
  "internal note",
  "for codex",
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
