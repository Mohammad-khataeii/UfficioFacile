import fs from "node:fs";
import path from "node:path";

const projectRoot = path.resolve(import.meta.dirname, "..");
const serverDir = path.join(projectRoot, ".next", "server");
const chunksDir = path.join(serverDir, "chunks");

function mirrorServerChunks() {
  if (!fs.existsSync(serverDir) || !fs.existsSync(chunksDir)) {
    return 0;
  }

  const entries = fs
    .readdirSync(chunksDir, { withFileTypes: true })
    .filter((entry) => entry.isFile() && entry.name.endsWith(".js"));

  let copied = 0;
  for (const entry of entries) {
    const source = path.join(chunksDir, entry.name);
    const destination = path.join(serverDir, entry.name);
    fs.copyFileSync(source, destination);
    copied += 1;
  }
  return copied;
}

const copied = mirrorServerChunks();

if (process.argv.includes("--quiet")) {
  process.exit(0);
}

if (copied > 0) {
  console.log(
    `[admin-chunk-sync] mirrored ${copied} server chunk${copied === 1 ? "" : "s"} into .next/server`,
  );
} else {
  console.log("[admin-chunk-sync] no server chunks found to mirror");
}
