import { readFileSync, writeFileSync, mkdirSync } from "node:fs";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const root = dirname(fileURLToPath(import.meta.url));
const outDir = process.env.MAKEFUN_OUTPUT_DIR || join(root, "output");
const video = JSON.parse(readFileSync(join(root, "VIDEO.json"), "utf8"));

const entry = {
  title: "GTA 6 Man Hangs Off a Helicopter Over Vice City",
  url: video.url,
  clip: "out/clip.mp4",
  durationSeconds: 12,
  madeBy: "AI agent",
  bounty: "gta6-clipper-01",
};

mkdirSync(outDir, { recursive: true });
const outPath = join(outDir, "entry.json");
writeFileSync(outPath, JSON.stringify(entry, null, 2));
console.log("wrote " + outPath);
