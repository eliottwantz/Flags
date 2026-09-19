// scripts/fetch-flags.ts
// Usage: bun scripts/fetch-flags.ts [--overwrite]
// In: Resources/countries.json / Out: Resources/flags/svg/<cc>.svg

const IN = new URL("../Data/countries.json", import.meta.url);
const OUT_DIR = new URL("../Data/flags/svg/", import.meta.url);
const CONCURRENCY = 8;
const OVERWRITE = process.argv.includes("--overwrite");

type Country = { code: string; flag_svg?: string };
const { countries } = (await Bun.file(IN).json()) as { countries: Country[] };
const queue = countries.filter((c) => c.code && c.flag_svg);
console.log(`countries: ${queue.length}`);

let done = 0;
const failed: string[] = [];

async function download(c: Country) {
  const cc = c.code.toLowerCase();
  const out = new URL(`${cc}.svg`, OUT_DIR);
  if (!OVERWRITE && (await Bun.file(out).exists())) return "skipped";
  const res = await fetch(c.flag_svg!);
  if (!res.ok) throw new Error(`HTTP ${res.status}`);
  const text = await res.text();
  if (!text.includes("<svg")) throw new Error("not SVG");
  await Bun.write(out, text);
  return "ok";
}

async function worker(items: Country[]) {
  for (const c of items) {
    try {
      await download(c);
    } catch (e) {
      failed.push(`${c.code.toLowerCase()}: ${e}`);
    }
    done++;
    if (done % 25 === 0) console.log(`${done}/${queue.length}`);
  }
}

const chunks: Country[][] = Array.from({ length: CONCURRENCY }, () => []);
queue.forEach((c, i) => chunks[i % CONCURRENCY].push(c));
await Promise.all(chunks.map(worker));

console.log(`done ${done}/${queue.length}, failed ${failed.length}`);
if (failed.length) console.log(failed.join("\n"));
