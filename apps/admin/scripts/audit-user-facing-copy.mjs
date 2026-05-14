import { readdir, readFile, stat } from "node:fs/promises";
import path from "node:path";

const repoRoot = path.resolve(import.meta.dirname, "..", "..");

const scanRoots = [
  path.join(repoRoot, "assets", "catalog"),
  path.join(repoRoot, "apps", "admin", "data"),
  path.join(repoRoot, "docs", "generated"),
  path.join(repoRoot, "lib", "features", "italy_admin_copilot", "content"),
  path.join(repoRoot, "lib", "features", "italy_admin_copilot", "data"),
];

const forbiddenPatterns = [
  { label: "to help the user", regex: /\bto help the user\b/i },
  { label: "the user should", regex: /\bthe user should\b/i },
  { label: "do not show", regex: /\bdo not show\b/i },
  { label: "internal", regex: /\binternal\b/i },
  { label: "AI", regex: /\bAI\b/i },
  { label: "TODO", regex: /\bTODO\b/i },
  { label: "placeholder", regex: /\bplaceholder\b/i },
  { label: "lorem ipsum", regex: /\blorem ipsum\b/i },
  { label: "fake", regex: /\bfake\b/i },
  { label: "sample text", regex: /\bsample text\b/i },
  { label: "questura ....", regex: /\bquestura\s+\.\.\.\./i },
];

function isIncludedFile(filePath) {
  const basename = path.basename(filePath);
  return (
    basename.endsWith(".json") ||
    basename.endsWith(".sql") ||
    basename.endsWith("_guidance_definitions.dart") ||
    basename === "procedure_definitions.dart" ||
    basename === "general_guidance_definitions.dart"
  );
}

async function collectFiles(root) {
  const results = [];
  const entries = await readdir(root, { withFileTypes: true });
  for (const entry of entries) {
    const fullPath = path.join(root, entry.name);
    if (entry.isDirectory()) {
      results.push(...(await collectFiles(fullPath)));
      continue;
    }
    if (entry.isFile() && isIncludedFile(fullPath)) {
      results.push(fullPath);
    }
  }
  return results;
}

function shouldIgnoreMatch(filePath, matchLabel, line) {
  if (matchLabel === "internal") {
    return /internal_label|admin internal|internal notes/i.test(line);
  }
  if (matchLabel === "AI") {
    return /AIRE|PAID/i.test(line);
  }
  return false;
}

const findings = [];

for (const root of scanRoots) {
  const rootStat = await stat(root).catch(() => null);
  if (!rootStat?.isDirectory()) {
    continue;
  }

  const files = await collectFiles(root);
  for (const filePath of files) {
    const content = await readFile(filePath, "utf8");
    const lines = content.split(/\r?\n/);

    lines.forEach((line, index) => {
      for (const pattern of forbiddenPatterns) {
        if (!pattern.regex.test(line)) {
          continue;
        }
        if (shouldIgnoreMatch(filePath, pattern.label, line)) {
          continue;
        }
        findings.push({
          filePath,
          line: index + 1,
          label: pattern.label,
          snippet: line.trim().slice(0, 220),
        });
      }
    });
  }
}

if (findings.length > 0) {
  console.error("User-facing copy audit failed:\n");
  for (const finding of findings) {
    console.error(
      `${path.relative(repoRoot, finding.filePath)}:${finding.line} ` +
        `[${finding.label}] ${finding.snippet}`,
    );
  }
  process.exit(1);
}

console.log("User-facing copy audit passed.");
