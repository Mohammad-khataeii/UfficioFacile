import { spawn } from "node:child_process";
import path from "node:path";
import { setTimeout as delay } from "node:timers/promises";

const mode = process.argv[2] ?? "dev";
const projectRoot = path.resolve(import.meta.dirname, "..");
const syncScript = path.join(projectRoot, "scripts", "sync-next-server-chunks.mjs");

const nextProcess = spawn("next", [mode], {
  cwd: projectRoot,
  stdio: "inherit",
  shell: true,
});

let stopped = false;
nextProcess.on("exit", (code) => {
  stopped = true;
  process.exit(code ?? 0);
});

async function syncLoop() {
  while (!stopped) {
    const sync = spawn(process.execPath, [syncScript, "--quiet"], {
      cwd: projectRoot,
      stdio: "ignore",
    });
    await new Promise((resolve) => sync.on("exit", resolve));
    await delay(1000);
  }
}

void syncLoop();
