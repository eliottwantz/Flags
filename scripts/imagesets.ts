// scripts/imagesets.ts
// Usage: bun run scripts/imagesets.ts [--overwrite] [--out=<dir>]
// In:  Data/countries.json (source of truth for country codes)
//      Data/flags/svg/<cc>.svg (fallback: Data/flags/<cc>.svg)
// Out: Flags/Assets.xcassets/<cc>.imageset/<cc>.svg + Contents.json
//
// Each .imageset preserves vector representation, e.g. bd.imageset:
// {
//   "images" : [{ "filename" : "bd.svg", "idiom" : "universal" }],
//   "info" : { "author" : "xcode", "version" : 1 },
//   "properties" : { "preserves-vector-representation" : true }
// }

import { mkdir } from "node:fs/promises";

const COUNTRIES_JSON = new URL("../Data/countries.json", import.meta.url);
const SVG_DIRS = [
  new URL("../Data/flags/svg/", import.meta.url),
  new URL("../Data/flags/", import.meta.url),
];
const DEFAULT_OUT_ROOT = new URL("../Flags/Assets.xcassets/", import.meta.url);

const OVERWRITE = process.argv.includes("--overwrite");
const outArg = process.argv.find((a) => a.startsWith("--out="));
const OUT_ROOT = outArg
  ? new URL(outArg.slice("--out=".length).replace(/\/?$/, "/"), import.meta.url)
  : DEFAULT_OUT_ROOT;

type Country = { code: string };

const { countries } = (await Bun.file(COUNTRIES_JSON).json()) as {
  countries: Country[];
};
const codes = [...new Set(countries.map((c) => c.code?.toLowerCase()).filter(Boolean))];
console.log(`countries: ${codes.length}`);

function contentsJson(filename: string): string {
  // Xcode serializes asset catalog JSON with " : " separators.
  return `{\n  "images" : [\n    {\n      "filename" : "${filename}",\n      "idiom" : "universal"\n    }\n  ],\n  "info" : {\n    "author" : "xcode",\n    "version" : 1\n  },\n  "properties" : {\n    "preserves-vector-representation" : true\n  }\n}\n`;
}

async function findSvg(cc: string): Promise<URL | null> {
  for (const dir of SVG_DIRS) {
    const candidate = new URL(`${cc}.svg`, dir);
    if (await Bun.file(candidate).exists()) return candidate;
  }
  return null;
}

let created = 0;
let skipped = 0;
const missing: string[] = [];

for (const cc of codes) {
  const svg = await findSvg(cc);
  if (!svg) {
    missing.push(cc);
    continue;
  }
  const filename = `${cc}.svg`;
  const imagesetDir = new URL(`${cc}.imageset/`, OUT_ROOT);
  const destSvg = new URL(filename, imagesetDir);
  const destJson = new URL("Contents.json", imagesetDir);

  if (!OVERWRITE && (await Bun.file(destJson).exists()) && (await Bun.file(destSvg).exists())) {
    skipped++;
    continue;
  }

  await mkdir(imagesetDir.pathname, { recursive: true });
  // Copy SVG byte-for-byte, then write Contents.json.
  await Bun.write(destSvg, Bun.file(svg));
  await Bun.write(destJson, contentsJson(filename));
  created++;
}

console.log(`imagesets: created/updated ${created}, skipped ${skipped}, missing ${missing.length}`);
if (missing.length) console.log(`missing svg:\n${missing.join("\n")}`);
console.log(`out: ${OUT_ROOT.pathname}`);
