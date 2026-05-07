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
const text = raw.toLowerCase();
const hits = forbidden.filter((phrase) => text.includes(phrase));

if (hits.length) {
  console.error("Forbidden user-facing phrases found:", hits.join(", "));
  process.exit(1);
}

console.log("Content lint passed.");
