#!/usr/bin/env node
import { readFile } from "node:fs/promises";
import { homedir } from "node:os";
import { join } from "node:path";

// Keep credentials outside the portable skill. Never print config or parse errors.
function fail(error, exitCode = 1) {
  if (process.argv.includes("--json")) console.log(JSON.stringify({ error }));
  else console.error(error);
  process.exit(exitCode);
}
if (Number(process.versions.node.split(".")[0]) < 22)
  fail("node_22_or_newer_required");
const explicit = process.env.ART_CONFIG_FILE;
const configPath = explicit || join(homedir(), ".config", "art", "config.json");
let config = {};
try {
  config = JSON.parse(await readFile(configPath, "utf8"));
} catch (error) {
  if (explicit || error.code !== "ENOENT") fail("invalid_art_config");
}
const keys = [
  "ART_BASE_URL",
  "CF_ACCESS_CLIENT_ID",
  "CF_ACCESS_CLIENT_SECRET",
  "ART_ACCESS_JWT",
];
if (
  !config ||
  typeof config !== "object" ||
  Array.isArray(config) ||
  Object.entries(config).some(
    ([key, value]) => !keys.includes(key) || typeof value !== "string",
  )
)
  fail("invalid_art_config");
for (const key of keys) {
  // An explicitly empty env value disables the corresponding config value.
  if (process.env[key] === undefined && config[key] !== undefined)
    process.env[key] = config[key];
}
process.env.ART_BASE_URL ??= "https://art-control.h27-kubb.workers.dev";
await import("../assets/art.mjs");
