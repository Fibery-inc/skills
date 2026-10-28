# Migrating the data

The build is the architect's (its build guide and `scripts.md`), with real records in place of sample ones and two scripts of this skill's own: the import, which writes every row, and the check, which compares Fibery with the sheet. Everything the architect's build guide says about scripts holds for these two: written straight into `execute_code` from the template, one step each, stopping in time and saying so, looking ids up by name, doing only what's missing, logging little, fixed by a script.

## Contents

1. [The order](#1-the-order)
2. [The import](#2-the-import)
3. [The check](#3-the-check)
4. [A big sheet](#4-a-big-sheet)
5. [The guide and the report](#5-the-guide-and-the-report)

## 1. The order

Each message once the one before has answered:

1. **Script 1**, the structure (architect build guide §1), with the fields people type and no formulas yet.
2. **The import** (§2), lookups first and logs after, run again while it logs "time is up".
3. **Script 2**, the formulas (architect build guide §2), now that they have records to compute. Read its log for every type before going on: a total that came back a whole number is deleted with the formulas that read it and made again (`references/model.md` §3), while no view uses it yet.
4. **The check** (§3), half a minute after the formulas, so Fibery has computed them: counts, totals, every formula against the sheet, and every naming rule's expression against the imported names. A formula that differs from the sheet gets its exact expression with `update_formula_field` in the next script, and the check runs again; a difference that is the sheet's own error (a `-100%` where the sheet divided an empty cell) stays, named in the report.
5. **Scripts 3 and 5 in one message** (architect build guide §3 and §5), and the app script when there's an app: the views, the tab views first in the tabs' order; the reports; the rules, off. Script 3 changes in three places, since the sheet's order and its pivots matter here:
   - views are made one at a time, so the Space lists them in the order given (13 views made one by one kept their order; the four reports made at once came out in another, measured): `for (let i = 0; i < todo.length && Date.now() - t0 + slow < 45000; i++) { const s0 = Date.now(), v = todo[i]; made.push([v, await run("view " + v.name, create_view({space: S, ...v}))]); slow = Math.max(slow, Date.now() - s0); }`;
   - reports likewise: `const charts = []; for (const r of REPORTS) { if (Date.now() - t0 + slow > 45000) break; charts.push(await report(r, (before.find(x => x.viewType === "report" && x.name === r.title) || {}).id)); }`, with `const left = todo.length - made.length + REPORTS.length - charts.length;`;
   - a pivot's report is a table: a `REPORTS` entry whose `tab` has `columns` (`references/model.md` §4) goes to `add_table_tab`, so `report` calls `(tab.columns ? add_table_tab : add_chart_tab)({reportId: id, title, ...tab})`.
6. **The guide's two calls and script 6** (architect build guide §6), with §5 below: script 6's `CHECKS` empty and its `RULES` the databases with rules; and in the same message the check again with only its `view` lines, which count each tab view's rows against its tab.

The architect's script 4, the sample records, isn't run: a database the sheet leaves empty stays empty, and the guide says how its first record is added.

Measured on an 11-tab sheet that became 171 records (Sport, on mcp-test): structure 11 s; the import one run of 13 s; 29 formulas in three runs (49, 35 and 10 s) and one fix; the check 3 s; 13 views and 4 reports 13 s; 5 rules 15 s; about 25 minutes in all, 4 of them scripts.

## 2. The import

`TABLES` holds every table, a relation's target before the records that point at it. Each has its database, its `columns` (field names without the Space, in the order of the values in `rows`), its `rows` as arrays of the sheet's stored values (`effectiveValue`: a date's serial number, a duration's fraction of a day, a number, a text, `null` for an empty cell), and, when needed, `convert` and `name`:

| `convert` for a column | The values written |
|---|---|
| `"date"` | `YYYY-MM-DD` from a serial number; a string is taken as `YYYY-MM-DD` already |
| `"datetime"` | an ISO date-time from a serial number, in UTC, after `TZ_HOURS` (the sheet's offset from UTC) is taken off |
| `"seconds"` | a duration as seconds, to the thousandth |
| `["duration", "Hours", "Minutes", "Seconds"]` | a duration split into those fields, the column itself not written; `["duration", "Minutes", "Seconds"]` keeps the hours in the minutes |
| a function `(v, row) => value` | anything else the Migration section says: a typo merged, text parsed, a value read from another column |

`name` composes the Name from the row, its values already converted, as the design's Migration section says; without one, the `Name` column is the Name. Names repeated within a table get " (2)", " (3)" in the order they come, so a rerun finds the same records. A to-one relation or a select takes a name; a to-many relation or a multi select, a list of names; `state` a state's name; `Description` Markdown. A relation to a name its target table doesn't have creates that record with the name only, when the target is a database of this build, and the log lists it.

The import reads what exists first and creates only rows whose Name it doesn't find, so it runs again as it is after "time is up", a cut-off or a fix to its data. It writes nothing to a record that exists: a value to change goes into a short script of its own (`update_entities`).

```js
const S = "Sport"; const f = n => `${S}/${n}`;
const TZ_HOURS = 3;
const TABLES = [
  {database: f("Opponent"), columns: ["Name"], rows: [["Max"], ["Sergey"]]},
  {database: f("Match"), columns: ["Date", "Discipline", "Opponent", "My score", "Opponent score"],
    convert: {Date: "date"}, name: r => `${r.Discipline} vs ${r.Opponent}, ${r.Date}`,
    rows: [[45918, "Pool", "Sergey", 3, 4], [45926, "Pool", "Max", 6, 5]]},
  {database: f("Run"), columns: ["Track", "Date", "Distance", "Time", "Notes", "Results Link"],
    convert: {Date: "date", Time: ["duration", "Hours", "Minutes", "Seconds"]}, name: r => `${r.Track}, ${r.Date}`,
    rows: [["Moscow Marathon 10K", 43002, 10, 0.03666666666666667, null, "https://results.chronotrack.com/event/results/event/event-32804"]]}
];

const BATCH = 50, fails = [], made = [], t0 = Date.now();
const run = async (label, p) => { try { return await p; } catch (e) { fails.push(`${label}: ${String(e.message || e).slice(0, 200)}`); return null; } };
const rows = async (from, select) => (await query({query: {"q/from": from, "q/select": select, "q/limit": "q/no-limit"}})).result;
const sp = db => db.split("/")[0];
const dbs = TABLES.map(t => t.database), types = {};
let cur = null;
for (const line of (await schema_detailed({databases: dbs})).schema.split("\n")) {
  const d = line.match(/^(\S[^:]*):/); if (d) { cur = d[1]; types[cur] = {}; continue; }
  const m = line.match(/^ {4}([^:]+): (.+?)(?: # (.*))?$/); if (cur && m) types[cur][m[1]] = {type: m[2], many: /collection/.test(m[3] || "")};
}
const serial = v => new Date(Date.UTC(1899, 11, 30) + Math.round(v * 864e5));
const secs = v => Math.round(v * 864e5) / 1000;
const CONVERT = {
  date: v => typeof v === "number" ? serial(v).toISOString().slice(0, 10) : v,
  datetime: v => typeof v === "number" ? new Date(serial(v).getTime() - TZ_HOURS * 36e5).toISOString() : v,
  seconds: v => typeof v === "number" ? secs(v) : v
};
const split = (v, names) => {
  let s = secs(v); const out = {};
  if (names.length === 3) { out[names[0]] = Math.floor(s / 3600); s -= out[names[0]] * 3600; }
  out[names[names.length - 2]] = Math.floor(s / 60); out[names[names.length - 1]] = Math.round((s % 60) * 1000) / 1000;
  return out;
};
const records = t => {
  const seen = {};
  return t.rows.map(values => {
    const r = {};
    t.columns.forEach((c, i) => {
      const v = values[i], how = (t.convert || {})[c];
      if (v === null || v === undefined || v === "") return;
      if (Array.isArray(how)) Object.assign(r, split(v, how.slice(1)));
      else r[c] = typeof how === "function" ? how(v, values) : how ? CONVERT[how](v) : v;
    });
    const base = t.name ? t.name(r) : r.Name, n = (seen[base] = (seen[base] || 0) + 1);
    r.Name = n > 1 ? `${base} (${n})` : base;
    return r;
  });
};
const kind = (db, key) => {
  if (key === "state") return "state";
  const t = types[db][`${sp(db)}/${key}`];
  if (!t) return "unknown";
  if (t.type === "Collaboration~Documents/Document") return "text";
  if (t.type === "fibery/user") return t.many ? "people" : "person";
  if (t.type.endsWith(`_${db}`)) return t.many ? "multi" : "select";
  if (t.type.startsWith("fibery/")) return "value";
  return t.many ? "many" : "one";
};
const ids = {}, opt = {};
const byName = async db => ids[db] = Object.fromEntries((await rows(db, {id: "fibery/id", n: `${sp(db)}/Name`})).map(r => [r.n, r.id]));
const options = async (db, key) => opt[db + key] = opt[db + key] || Object.fromEntries((await rows(`${sp(db)}/${key}_${db}`, {id: "fibery/id", n: "enum/name"})).map(r => [r.n, r.id]));
const me = (await get_me({})).result[0]["fibery/id"];
const target = (db, key) => types[db][`${sp(db)}/${key}`].type;
const stats = {}, later = [];
let slow = 5000, left = 0;
for (const t of TABLES) {
  const db = t.database, all = records(t);
  await byName(db);
  const fresh = all.filter(r => !ids[db][r.Name]);
  stats[db] = {sheet: all.length, before: all.length - fresh.length, made: 0};
  const keys = [...new Set(all.flatMap(r => Object.keys(r)))];
  for (const k of keys) if (["select", "multi"].includes(kind(db, k))) await options(db, k);
  for (const k of keys.filter(k => ["one", "many"].includes(kind(db, k)))) {
    const to = target(db, k);
    if (!ids[to]) await byName(to);
    const wanted = [...new Set(fresh.flatMap(r => [].concat(r[k] || [])))].filter(n => !ids[to][n]);
    if (wanted.length && dbs.includes(to)) { await run("create " + to, create_entities({database: to, entities: wanted.map(n => ({[`${sp(to)}/Name`]: n}))})); made.push(`${to}: ${wanted.join(", ")}`); await byName(to); }
  }
  const entity = r => {
    const e = {};
    for (const [k, v] of Object.entries(r)) {
      const kd = kind(db, k), F = `${sp(db)}/${k}`;
      if (kd === "value") e[F] = v;
      else if (kd === "select") { if (opt[db + k][v]) e[F] = opt[db + k][v]; else fails.push(`${r.Name}: no ${k} option ${v}`); }
      else if (kd === "one") { const id = ids[target(db, k)][v]; if (id) e[F] = id; else fails.push(`${r.Name}: no ${k} named ${v}`); }
      else if (kd === "person") e[F] = v === "me" ? me : v;
      else if (kd === "unknown") fails.push(`${r.Name}: no field ${k}`);
    }
    return e;
  };
  for (let i = 0; i < fresh.length; i += BATCH) {
    if (Date.now() - t0 + slow > 45000) { left += fresh.length - i; break; }
    const s0 = Date.now(), batch = fresh.slice(i, i + BATCH);
    if (await run(`create ${db} ${i + 1}–${i + batch.length}`, create_entities({database: db, entities: batch.map(entity)}))) stats[db].made += batch.length;
    slow = Math.max(slow, Date.now() - s0);
  }
  await byName(db);
  const secrets = {};
  for (const k of keys.filter(k => kind(db, k) === "text")) secrets[k] = Object.fromEntries((await rows(db, {id: "fibery/id", s: [`${sp(db)}/${k}`, "Collaboration~Documents/secret"]})).map(x => [x.id, x.s]));
  for (const r of fresh.filter(r => ids[db][r.Name])) {
    const id = ids[db][r.Name];
    for (const [k, v] of Object.entries(r)) {
      const kd = kind(db, k), F = `${sp(db)}/${k}`;
      if (kd === "state") later.push(() => run(`${r.Name} state`, set_state({database: db, entityId: id, state: v})));
      if (kd === "many" || kd === "multi" || kd === "people") {
        const items = [].concat(v).map(n => kd === "multi" ? opt[db + k][n] : kd === "people" ? (n === "me" ? me : n) : ids[target(db, k)][n]).filter(Boolean);
        if (items.length) later.push(() => run(`${r.Name} ${k}`, add_collection_items({database: db, field: F, entityId: id, items})));
      }
      if (kd === "text") later.push(async () => {
        const secret = secrets[k][id], doc = String((await read_document({secret})).document || ""), block = (doc.match(/rootBlockIds\[1\]: (\S+)/) || [])[1];
        if (block && /,""|content: ""/.test(doc)) return run(`${r.Name} ${k}`, replace_document_blocks({secret, blocks: [{blockId: block, content: v}]}));
      });
    }
  }
}
let next = 0;
while (next < later.length && Date.now() - t0 + slow < 45000) { const s0 = Date.now(), batch = later.slice(next, next + 20); next += batch.length; await Promise.all(batch.map(w => w())); slow = Math.max(slow, Date.now() - s0); }
for (const db of dbs) stats[db].now = (await rows(db, {id: "fibery/id"})).length;
log("rows: " + dbs.map(db => `${db.split("/")[1]} ${stats[db].now} of ${stats[db].sheet} (${stats[db].made} made, ${stats[db].before} there before)`).join("; "));
if (made.length) log("made from names the rows use: " + made.join("; "));
if (left || next < later.length) log(`time is up with ${left} records and ${later.length - next} writes left: run this script again, as it is, to finish`);
log(`failed ${fails.length}`); fails.slice(0, 20).forEach(x => log("FAIL " + x));
```

States, collections and texts are written only for the records a run creates; a rerun after "time is up" with writes left picks up records created but not finished by checking them with a short script, since the import doesn't touch records that exist. Keep a big table's states, collections and texts in their own run when there are hundreds of them.

Measured on Sport: seven tables, 171 records, one run of 13 seconds with no failure; 47 records went in one `create_entities` call. The script was 22,000 characters, two thirds of them the rows.

## 3. The check

After the formulas, the check compares Fibery with the sheet, per database: the rows counted, the totals of the columns people typed (which catches a unit or a conversion gone wrong), every formula's values against the results the sheet stored for its computed column, by the records' Names, and every naming rule's expression against the names the import wrote. Durations are compared in seconds, text that shows a time (`5:36`, `1:34:20`) read back into seconds, numbers within a tolerance that matches what the sheet shows: half a second for a time rounded to the second, half the last place for a rounded number.

A `name` line tries a rule's expression as a temporary formula, `Name Check`, reads it once Fibery has computed it (a formula has values a few seconds after it exists: read at once, 47 of 47 came back empty, measured) and deletes it, so the rules can't rename the records the import wrote. A `view` line counts a view's rows: it runs once the views exist, in the guide's message.

```js
const S = "Sport"; const f = n => `${S}/${n}`;
const CHECKS = [
  {database: f("Match"), count: 34},
  {database: f("Match"), field: "My score", sum: 170},
  {database: f("Match"), field: "Outcome", expect: {"Pool vs Sergey, 2025-09-18": "Loss", "Pool vs Max, 2025-09-26": "Win"}},
  {database: f("Run"), field: "Pace", as: "time", tolerance: 0.51, expect: {"Moscow Marathon 10K, 2017-09-24": 316.8}},
  {database: f("Match"), name: 'Discipline.Name + " vs " + Opponent.Name + If(IsEmpty(Date), "", ", " + ToText(Date))'},
  {view: "Pool", rows: 34}
];

const fails = [], t0 = Date.now(), probe = f("Name Check");
const rows = async (from, select) => (await query({query: {"q/from": from, "q/select": select, "q/limit": "q/no-limit"}})).result;
const asSeconds = t => (t === null || t === undefined || t === "") ? null : String(t).split(":").map(Number).reduce((a, x) => a * 60 + x, 0);
const names = CHECKS.filter(c => c.name);
await Promise.all(names.map(c => create_formula_field({database: c.database, name: probe, description: `Use exactly this Fibery formula: ${c.name}. The result is text.`}).catch(e => fails.push(`${c.database} name: ${String(e.message || e).slice(0, 200)}`))));
const views = CHECKS.some(c => c.view) ? (await query_views({space: S, withConfig: false})).views : [];
for (const c of [...CHECKS.filter(c => !c.name), ...names]) {
  try {
    if (c.view) {
      const v = views.find(x => x.name === c.view);
      if (!v) { log(`view ${c.view}: not found`); continue; }
      let n = 0, offset = 0, more = true;
      while (more) { const r = await fetch_view_data({publicId: v.publicId, limit: 500, offset}); const page = (r.results || []).flatMap(x => x.entities || []); n += page.length; offset += 500; more = page.length > 0 && (r.results || []).some(x => x.hasNext); }
      log(`view ${c.view}: ${n} of ${c.rows}${n === c.rows ? "" : " DIFFER"}`);
      continue;
    }
    const sp = c.database.split("/")[0], select = {n: `${sp}/Name`, v: c.name ? probe : `${sp}/${c.field}`};
    if (c.count !== undefined) delete select.v;
    let got = await rows(c.database, select);
    while (c.name && got.some(r => r.v === null) && Date.now() - t0 < 40000) got = await rows(c.database, select);
    if (c.count !== undefined) { log(`${c.database} rows: ${got.length} of ${c.count}${got.length === c.count ? "" : " DIFFER"}`); continue; }
    if (c.sum !== undefined) { const s = got.reduce((a, r) => a + (Number(r.v) || 0), 0); log(`${c.field} total: ${s} of ${c.sum}${Math.abs(s - c.sum) <= (c.tolerance || 0.001) ? "" : " DIFFER"}`); continue; }
    if (c.name) { const off = got.filter(r => r.n !== r.v); log(`${c.database} names as its rule writes them: ${got.length - off.length} of ${got.length}${off.length ? "; differ: " + off.slice(0, 4).map(r => `"${r.n}" → "${r.v}"`).join("; ") : ""}`); continue; }
    const by = Object.fromEntries(got.map(r => [r.n, r.v]));
    const value = v => c.as === "time" ? asSeconds(v) : v;
    const same = (g, e) => typeof e === "number" ? g !== null && g !== undefined && g !== "" && Math.abs(Number(g) - e) <= (c.tolerance === undefined ? 0.001 : c.tolerance) : String(g === null || g === undefined ? "" : g) === String(e);
    const bad = Object.entries(c.expect).filter(([n, e]) => !(n in by) || !same(value(by[n]), e));
    log(`${c.field}: ${Object.keys(c.expect).length - bad.length} of ${Object.keys(c.expect).length} as in the sheet${bad.length ? "; differ: " + bad.slice(0, 6).map(([n, e]) => `${n} (sheet ${e}, Fibery ${n in by ? by[n] : "no record"})`).join("; ") : ""}`);
  } catch (e) { fails.push(`${c.field || c.view || c.database}: ${String(e.message || e).slice(0, 200)}`); }
}
for (const c of names) await delete_fields({fields: [{database: c.database, field: probe}]}).catch(e => fails.push(`${c.database}: Name Check not removed, ${String(e.message || e).slice(0, 150)}`));
log(`failed ${fails.length}`); fails.forEach(x => log("FAIL " + x));
```

`expect` holds every row's value for a formula column of up to a few hundred rows; past that, the first hundred, the last hundred and the totals. A sheet value that is the sheet's own error (`#DIV/0!`, `-100%` from an empty cell) is left out of `expect` and named in the report. The expected values come from the stored values the import read, converted the same way (a duration's fraction × 86,400), never from the text the sheet displays, which rounds. On Sport the check took 3 seconds for 7 counts, 6 totals and 289 formula values, all as in the sheet, and the names of all five log databases matched their rules, 151 of 151.

## 4. A big sheet

Every row passes through the conversation twice, read from the sheet and written into a script, so the import suits sheets of a few thousand rows: an import run carries up to about 500 rows of a table in its data, and a big table goes in several runs, the second with the next 500 rows in place of the first. Past about 5,000 rows in all, say so with the questions and offer the way that keeps the data out of the conversation: the build makes the Space, then the person imports each tab's CSV (File → Download → CSV in Google Sheets) into its database with Fibery's import, whose link `get_manual_import_link` gives, and the check runs on the result. A duration has to be split into its parts in the sheet first, in columns the CSV carries.

## 5. The guide and the report

The guide is the architect's (build guide §6) with one section more, after Where to look:

- **Where your sheet went**: a line per tab, each with its view or report as a mention: "Running, Trail Running and Tower Running: the [[Running]], [[Trail Running]] and [[Tower Running]] views of one Runs database." A tab left behind says why in a few words.

Its How it runs says how a row is added now (the form, or the view's new row) and what fills itself in (the Name, the formulas). Its last line, in italics, links the sheet: "Moved from the Google Sheet [Sport (copy)](https://docs.google.com/spreadsheets/d/…) on 2026-10-28; the sheet itself wasn't changed."

The report is SKILL.md §7. `design.md`'s Build notes add: rows per tab, sheet and Fibery; the import's runs and minutes; the check's results, with every difference and its reason; and what wasn't carried.
