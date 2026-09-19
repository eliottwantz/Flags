// scripts/fetch-countries.ts
// Usage: RESTCOUNTRIES_API_KEY=rc_live_xxx bun scripts/fetch-countries.ts
// Output: Resources/countries.json (embed at bundle time)

const API_KEY = process.env.REST_API_KEY ?? "rc_live_demo";
const BASE = "https://api.restcountries.com/countries/v5";
const FIELDS = [
  "names.common",
  "names.translations",
  "codes.alpha_2",
  "codes.alpha_3",
  "flag.emoji",
  "flag.url_png",
  "flag.url_svg",
].join(",");
const OUT = new URL("../Data/countries.json", import.meta.url);

type RawObj = {
  names?: {
    common?: string;
    translations?: Record<string, { common?: string; official?: string }>;
  };
  codes?: { alpha_2?: string; alpha_3?: string };
  flag?: { emoji?: string; url_png?: string; url_svg?: string };
};

async function fetchPage(limit: number, offset: number) {
  const url = `${BASE}?limit=${limit}&offset=${offset}&response_fields=${FIELDS}`;
  const res = await fetch(url, { headers: { Authorization: `Bearer ${API_KEY}` } });
  if (!res.ok) throw new Error(`${res.status} ${await res.text()}`);
  const json = await res.json();
  return json.data as {
    objects: RawObj[];
    meta: { total: number; more: boolean };
  };
}

const seen = new Map<string, object>();

for (const offset of [0, 100, 200]) {
  const { objects, meta } = await fetchPage(100, offset);
  console.log(`offset ${offset}: got ${objects.length}/${meta.total} more=${meta.more}`);
  for (const o of objects) {
    const code = o.codes?.alpha_2?.toUpperCase();
    const name_en = o.names?.common;
    if (!code || !name_en) continue;
    const name_fr = o.names?.translations?.fra?.common ?? name_en;
    seen.set(code, {
      code,
      code3: o.codes?.alpha_3,
      name_en,
      name_fr,
      emoji: o.flag?.emoji,
      flag_png: o.flag?.url_png,
      flag_svg: o.flag?.url_svg,
    });
  }
  if (!meta.more) break;
}

const countries = [...seen.values()].sort((a: any, b: any) => a.name_en.localeCompare(b.name_en));

await Bun.write(
  OUT,
  JSON.stringify({ schemaVersion: 1, count: countries.length, countries }, null, 2),
);
console.log(`wrote ${countries.length} -> ${OUT.pathname}`);
