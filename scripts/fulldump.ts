// scripts/fetch-countries-full.ts
// Usage: RESTCOUNTRIES_API_KEY=rc_live_xxx bun scripts/fetch-countries-full.ts
// Out: Data/countries-full-v5-<YYYY-MM-DD>.json (full objects, no field trimming)

const API_KEY = process.env.REST_API_KEY ?? "rc_live_demo";
const BASE = "https://api.restcountries.com/countries/v5";
const LIMIT = 100; // 100 max on free, up to 500 on paid
const OUT = new URL(`../Data/countries-full.json`, import.meta.url);

async function fetchPage(limit: number, offset: number) {
  const url = `${BASE}?limit=${limit}&offset=${offset}`;
  const res = await fetch(url, { headers: { Authorization: `Bearer ${API_KEY}` } });
  if (!res.ok) throw new Error(`${res.status} ${await res.text()}`);
  const json = await res.json();
  return json.data as { objects: unknown[]; meta: { total: number; more: boolean } };
}

const all: unknown[] = [];
let offset = 0,
  total = 0;

for (;;) {
  const { objects, meta } = await fetchPage(LIMIT, offset);
  total = meta.total;
  all.push(...objects);
  console.log(`offset ${offset}: +${objects.length} (${all.length}/${total}) more=${meta.more}`);
  if (!meta.more || objects.length === 0) break;
  offset += LIMIT;
}

await Bun.write(
  OUT,
  JSON.stringify(
    { fetchedAt: new Date().toISOString(), version: "v5", total, count: all.length, objects: all },
    null,
    2,
  ),
);
console.log(`wrote ${all.length}/${total} -> ${OUT.pathname}`);
