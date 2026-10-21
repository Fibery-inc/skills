# Overview of a big workspace

On a whole workspace of more than about 40 databases, the full check would take many script runs, so it starts here: one run gives one line per Space, from record counts and the schema only. Then the person picks the Spaces to check in full, and those become `SCOPE` for the facts script (`references/scripts.md`). Automations, records and everything else the full check covers come only with that.

## Reading it

- **Synced Spaces**: named after an app or service (Intercom, Discourse, Chargebee, Email), or with half or more of their databases `synced` (every field read-only, as an integration's are). Their activity is the sync's, not people's: list them apart, never call one a duplicate or suggest a full check of one. A test copy that's still syncing (`newest` today) keeps importing records nobody uses: Tidy-up, Important when it holds tens of thousands. Nobody edits either side, so it isn't the Critical case of Copied spaces.
- **Active, quiet, dormant**: by `newest`. A dormant Space gets one line with its size and newest record: archive it or delete it? Never suggest a full check of one.
- **Worth a look**, per Space, from its numbers: databases without a description, `leftovers`, `empty` databases, `formulasOff`, `fixedDateFormulas`, `mixedAlphabets`. A cell of short phrases, nothing when none, and no severity: that comes with the full check.
- **Across the workspace**: `copies` and `sameConcept` are this script's `sameName`: judge them by Copied spaces and Same concept twice in `references/structure.md`. When one side is synced, suggest relating it to the canonical database; when both are, it's two apps' data side by side, no finding. People-field clutter: the `userFieldsBySpace` fields that come from dormant, archive, copied and demo Spaces (Tidy-up). `noDatabases` with 0 views and documents (Tidy-up). Agent readiness, the share of databases described.
- **Suggested full checks**: 3–5 active Spaces people work in, the biggest and most flagged first, and any Space in a copy or same-concept finding. Not a synced Space, and not a store a script fills (millions of records in a few databases, such as usage statistics). One line each with why.

## Report

```markdown
# Workspace overview: <workspace>, <date>
Run as <name> (<role>). <N> Spaces, <N> databases, <N> records. <X> of <Y> databases described.

## Summary
Two or three sentences: where the work is, what's dormant, the findings that span Spaces.

## Spaces
**Active, new records in the last 30 days (<N>)**
| Space | Databases | Records | Newest | Worth a look |
Spaces people build, biggest first, each linked.

**Quiet, last new record 1–6 months ago (<N>)**: linked names on one line.
**Dormant, nothing new for 6 months or more (<N>)**: one line each with its size and newest record.
**Synced from other apps (<N>)**, **test copies**, **no records**, **no databases**: one line each.

## Across the workspace
One line each, with severity.

## Suggested full checks
1. <Space>: why.

## Not checked
Automations, records and everything a full check covers, in the Spaces not checked in full.
```

Summary and suggestions go in chat. Then ask once which Spaces to check in full, and whether with the data pass.

## The script

Copy it whole and change only the first line: `SKIP`, `0` unless the last run's final line gave another number. It only reads. It stops starting new work after 35 seconds; its last line then gives the `SKIP` for a rerun, which prints only the Spaces left.

What it logs:

- **First line**: the workspace, the person and their role, the workspace's Space and database counts, `described` (databases with a description), `cantRead`.
- **`<Space> {…}`**, one line per Space with databases, active first, then quiet, dormant, no records and can't read, the biggest first: `state` (`active`, a new record in the last 30 days; `quiet`, in the last 6 months; `dormant`, none for longer), `url`, `dbs`, `records`, `newest` (when the newest record was made), `described`, `synced`, `empty` (databases without records), `leftovers` (database names with old, copy, test, temp, a version, a year or a trailing number), `formulasOff` (formulas Fibery switched off), `fixedDateFormulas` (formulas holding a literal year or date), `mixedAlphabets` (database or field names mixing Latin with Cyrillic or Greek letters), `cantRead` (databases the person can't read).
- **`workspace {…}`**, on the first run: `copies` `[Space, Space, how many database names they share]` for Spaces sharing most of their database names; `sameConcept` `[database, a database with the same name in another Space, the field names they share]` when they share 3 or more, `(synced)` after a synced one; `userFieldsBySpace` (the person fields on every workspace user, per Space they come from); `noDatabases` `[Space, link, views and documents]`.
- **Last line**: databases counted, their records, seconds and calls; "stopped early … run this script again with SKIP = N" when it did; `failed` with each failed call.

```js
const SKIP = 0;
const T0 = Date.now(), D = 864e5, sp = n => n.slice(0, n.indexOf("/")), nm = n => n.slice(n.indexOf("/") + 1), day = v => String(v || "").slice(0, 10);
const sing = s => s.toLowerCase().replace(/ies$/, "y").replace(/([^s])s$/, "$1"), mx = s => /[a-z]/i.test(s) && /[\u0370-\u04ff]/.test(s), T = a => a.reduce((o, x) => (o[x] = (o[x] || 0) + 1, o), {});
const J = v => JSON.stringify(v).replace(/"((?:[^"\\]|\\.)*)"(:?)/g, (m, s, c) => /^[\w .\/:@()→+&'-]+$/.test(s) && (c || !/^(true|false|null|[\d.-]+)$/.test(s)) ? s + c : m);
const C = o => Object.fromEntries(Object.entries(o).filter(([, v]) => !(v === 0 || v === "" || v == null || (Array.isArray(v) && !v.length))));
const fails = []; let calls = 0;
const safe = async (l, p) => { calls++; try { return await p; } catch (e) { fails.push(l + ": " + String(e && e.message || e).split("**IMPORTANT")[0].trim().slice(0, 150)); return null; } };
const Q = (f, s, x) => safe(f, query({query: {"q/from": f, "q/select": s, ...x}})).then(r => r && r.result);
const [me, c0] = await Promise.all([safe("get_me", get_me({})), safe("capabilities", display_schema_capabilities({}))]);
const SP = Object.keys(c0.accessInfo.spaces), A = (await safe("capabilities", display_schema_capabilities({spaces: SP}))).accessInfo;
const ALL = Object.keys(A.databases).filter(d => SP.includes(sp(d))).sort(), AS = new Set(ALL), ok = d => typeof A.databases[d] == "object", url = n => (A.databases[n] || A.spaces[n] || {}).url;
const SPS = [...new Set(ALL.map(sp))], todo = ALL.filter(d => ok(d) && SPS.indexOf(sp(d)) >= SKIP), N = {}, Z = {}, DESC = {}, FL = {}, SYN = new Set();
let i = 0;
await Promise.all([
  Promise.all([Q("fibery/type", {n: "fibery/name", d: "fibery/description"}, {"q/where": ["q/in", ["fibery/name"], ALL], "q/limit": "q/no-limit"}), Q("fibery/field", {n: "fibery/name", t: "fibery/type", m: "fibery/meta", h: ["fibery/holder-type", "fibery/name"]}, {"q/where": ["q/in", ["fibery/holder-type", "fibery/name"], [...ALL, "fibery/user"]], "q/limit": "q/no-limit"})]).then(([ty, fl]) => { (ty || []).forEach(t => { DESC[t.n] = t.d || ""; }); (fl || []).forEach(f => { if (!/_deleted$/.test(f.n)) (FL[f.h] = FL[f.h] || []).push(f); }); }),
  ...[...Array(16)].map(async () => { while (i < todo.length && Date.now() - T0 < 35000) { const d = todo[i++]; N[d] = await Q(d, ["q/count", "fibery/id"]); if (N[d]) Z[d] = day((((await Q(d, {c: "fibery/creation-date"}, {"q/order-by": [[["fibery/creation-date"], "q/desc"]], "q/limit": 1})) || [])[0] || {}).c); } })
]);
const own = d => (FL[d] || []).filter(f => !/^(fibery|Collaboration~Documents|comments|avatar|icon|workflow|documents|whiteboards)\//.test(f.n) && !(f.m || {})["formula/formula?"] && !(f.m || {})["fibery/private?"]);
const LEFT = /\b(v\d+|old|copy|test|temp|tmp|backup|deprecated|legacy)\b|\b20\d\d\b|\s\d+$/i, S = {};
for (const d of ALL) {
  const k = sp(d), s = S[k] = S[k] || {url: url(k), dbs: 0, read: 0, records: 0, newest: "", described: 0, synced: 0, empty: [], leftovers: [], formulasOff: 0, fixedDateFormulas: 0, mixedAlphabets: [], cantRead: 0}, fs = FL[d] || [], o = own(d);
  s.dbs++;
  if (!ok(d)) { s.cantRead++; continue; }
  if (d in N) s.read++;
  s.records += N[d] || 0; if ((Z[d] || "") > s.newest) s.newest = Z[d];
  if (DESC[d]) s.described++;
  if (N[d] === 0) s.empty.push(nm(d));
  if (LEFT.test(nm(d))) s.leftovers.push(nm(d));
  if (o.length && o.every(f => (f.m || {})["fibery/readonly?"])) { s.synced++; SYN.add(d); }
  if (mx(nm(d))) s.mixedAlphabets.push(nm(d));
  fs.forEach(f => { const m = f.m || {}; if (mx(nm(f.n))) s.mixedAlphabets.push(nm(d) + "." + nm(f.n)); if (m["formula/disabled?"]) s.formulasOff++; if (m["formula/formula?"] && Object.values((m["formula/formula"] || {}).params || {}).some(p => /^20[2-3]\d(\b|-)/.test(String(p)))) s.fixedDateFormulas++; });
}
const age = z => z ? (T0 - Date.parse(z)) / D : 1e9, state = s => s.cantRead == s.dbs ? "can't read" : !s.records ? "no records" : age(s.newest) <= 30 ? "active" : age(s.newest) <= 180 ? "quiet" : "dormant", ORD = ["active", "quiet", "dormant", "no records", "can't read"];
const done = SPS.slice(SKIP).filter(k => S[k].read + S[k].cantRead == S[k].dbs), next = SPS.slice(SKIP).find(k => !done.includes(k));
const m = ((me && me.result) || [])[0] || {}, tot = ALL.filter(ok), described = tot.filter(d => DESC[d]).length;
if (!SKIP) log(J({workspace: String(m.url).split("/")[2], user: m["user/name"], role: String(m["fibery/role"]).replace("role/", ""), spaces: SP.length, databases: ALL.length, described: described + " of " + tot.length, cantRead: ALL.length - tot.length}));
for (const k of done.filter(k => !next || SPS.indexOf(k) < SPS.indexOf(next)).sort((a, b) => ORD.indexOf(state(S[a])) - ORD.indexOf(state(S[b])) || S[b].records - S[a].records)) { const s = S[k]; log(k + " " + J(C({state: state(s), ...s, read: 0, described: s.dbs > s.cantRead ? s.described + " of " + (s.dbs - s.cantRead) : 0, synced: s.synced ? s.synced + " of " + s.dbs : 0}))); }
if (!SKIP) {
  const byName = {}, pair = {}, ws = {};
  ALL.forEach(d => (byName[sing(nm(d))] = byName[sing(nm(d))] || []).push(d));
  Object.values(byName).forEach(ds => { for (const a of ds) for (const b of ds) if (sp(a) < sp(b)) { const k = sp(a) + " | " + sp(b); pair[k] = (pair[k] || 0) + 1; } });
  const cp = new Set(Object.keys(pair).filter(k => { const [a, b] = k.split(" | "); return pair[k] >= 2 && pair[k] >= 0.6 * Math.min(S[a].dbs, S[b].dbs); })), fn = d => new Set(own(d).map(f => sing(nm(f.n))).filter(z => !/^(name|description)$/.test(z)));
  ws.copies = [...cp].map(k => [...k.split(" | "), pair[k] + " databases with the same names"]);
  ws.sameConcept = Object.values(byName).flatMap(ds => ds.flatMap(a => ds.filter(b => sp(a) < sp(b) && !cp.has(sp(a) + " | " + sp(b))).map(b => { const x = fn(a), sh = [...fn(b)].filter(z => x.has(z)); return sh.length >= 3 ? [...[a, b].map(z => z + (SYN.has(z) ? " (synced)" : "")), sh.length + " shared field names: " + sh.slice(0, 5).join(", ")] : 0; }))).filter(Boolean);
  ws.userFieldsBySpace = T((FL["fibery/user"] || []).filter(f => AS.has(f.t)).map(f => sp(f.t)));
  ws.noDatabases = await Promise.all(SP.filter(s => !SPS.includes(s)).map(async s => { const v = await safe("views " + s, query_views({space: s, withConfig: false})); return [s, url(s), (v ? (v.views || []).length : "?") + " views and documents"]; }));
  log("workspace " + J(C(ws)));
}
log(`${Object.keys(N).length} databases counted, ${Object.values(N).reduce((a, b) => a + (b || 0), 0)} records; ${((Date.now() - T0) / 1000).toFixed(1)} s, ${calls} calls${next ? `; stopped early with ${SPS.length - SPS.indexOf(next)} Spaces left: run this script again with SKIP = ${SPS.indexOf(next)}` : ""}; failed ${fails.length}${fails.length ? ": " + fails.join(" | ") : ""}`);
```
