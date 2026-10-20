# The facts script

SKILL.md §2 sends it. It has two parts: part 1 runs on every check, and for the data pass part 2 goes right after it, in the same call. Copy them whole and change only the first line: `SCOPE`, the spaces the person named, spelled as in Fibery (`[]` for the whole workspace), and `SKIP`, `[0, 0, 0]` unless the last run's final line gave other numbers. The script only reads and calls every Fibery tool it needs itself. It reads the schema once, then runs three things at the same time: the facts of each database in scope, its rules and buttons, and, with part 2, its history.

It stops starting new work after 35 seconds or about 32,000 characters of output, whichever comes first, so a run never times out and its output stays readable in one piece. Its last line then says what's left and gives the `SKIP` for the next run, which prints only what's left.

## What it logs

Compact JSON: keys and plain values are not quoted, and keys whose value would be zero or empty are left out.

- **First line**: the workspace, the person and their role, the workspace's Space and database counts, the scope and its database count, `data` (whether part 2 ran), each Space's link (`spaceLinks`), databases in scope the person can't read (`cantRead`), names that match no Space (`noSuchSpace`).
- **`<Space/Database> {…}`**, one line per database:
  - `n` records, `url`, `description` (its first 150 characters), `formulas` (formula fields), `made` (first and last record, UTC, to the minute), `minutes` (distinct minutes its records were made in), `changed` (last change by anyone, formula recalculations included), `by` (records per creator; `null` means no person, as for integrations), `example` (titled "(example)"), `untitled` (records without a title, or "no title field"), `sample` (only the newest N records were read: a database over 200 records without part 2, over 2,000 with it; counts marked `all` cover every record), `error` when its records couldn't be read.
  - A database whose own fields are all read-only, as an integration's are, gets a short line: `readOnly: true`, `fields` (how many), `deletedIn` (its "Deleted in …" field) and `by` (the creators of 50 records).
  - `fields`: `[name, kind, records with a value, …]`. Kinds: `text`, `value` (number, date and other plain values), `check`, `rich`, `select`, `select[]` (multi-select), `rel` or `rel[]` → its database (the Space left out when it's the same), `user` or `user[]` → users, `file`, `file[]`, `formula`, `json` (not counted). Then `new` (added this month); for text, how many distinct values, with part 2 the values and their counts when there are 15 or fewer, how many match workspace user names or emails, and how many are titles of another database in the same Space or match one of its text fields; `all N`, an exact count over every record, for a field the sample shows nearly empty.
  - `states`: `[state, type and ", final", records]` in workflow order. `options`: per select, `[option, records]`, unused options included.
  - With part 2: `duplicateTitles` (how many titles repeat) and `duplicates` `[normalized title, copies, "same <relation>" for each single relation the copies share, how many have links in a collection field (other records point at them), two links]`; `untitledLinks`; `emptyLinks` `[single relation, records without it, their split by state, two links]` for a relation empty in at most half the records; `work`, for databases with a workflow: `unfinished`, `started`, `startedBefore` (the date 30 days ago and the Started records made before it), `notStartedBefore` (the date 180 days ago and the Not started records made before it), `noChangeSince30d` (those Started ones nobody changed since, with links, or "see history" where formulas move the modification date), and `pastDates` `[date field, unfinished records whose date has passed, their split by state, two links]`. Dates that record an event (created, started, received, done, a timestamp) are left out. Without a workflow, only a database with a Status, State, Stage or Phase select gets `pastDates`, split by it.
- **`workspace {…}`**: `sameName` `[database, a database with the same singular name in another Space, its link, how many databases that Space has, its records, its newest record, the field names they share]`; on the first run only, `userFieldsBySpace` (the fields on every workspace user, per Space they come from) and `noDatabases` `[Space, link, views and documents]`.
- **`automation <Space/Database> […] <link>`**, one per rule and button: `[rule or button, name, enabled or DISABLED, last run (COMPLETED, FAILED or NOT STARTED, which means it never ran, with its start in UTC), created, triggers ([trigger, args]), filter, actions ([name, app, what it sets and its own filter]), N used fields gone]`. Field, state and option ids appear as names, without the database's own Space; filters are written out with their values; `=` starts a formula and `empty` clears a field. A schedule's `schedulerConfig`: `freq` 0 yearly, 1 monthly, 2 weekly, 3 daily, 4 hourly; `interval`; `byweekday` 0 = Monday; `byhour` and `byminute` in UTC; `dtstart`, the first run.
- **`history …`**, with part 2: for a database with deletions, `deleted or archived in 30 days: N` (`N+` past 300), `peak` (the author and UTC hour with the most, and how many) and where they came from (`app`, or a service; `ai-answer` is an AI agent); one line lists the databases with none. For a database with a workflow, formulas and Started records made more than 30 days ago (`work.startedBefore` counts them), `stuck: N of M Started records made before <date>, no change by a person since`, with up to three links (an upper bound when the history ran past 500 changes).
- **Last line**: automations found, seconds and calls; "stopped early with … left: run this script again with SKIP = [a, b, c]" when it did; `failed` with each failed call.

## Part 1

```js
const SCOPE = [], SKIP = [0, 0, 0];
const T0 = Date.now(), TODAY = new Date(T0).toISOString().slice(0, 10), DATA = typeof dataFacts == "function", ALLN = DATA ? 2000 : 200, SAMPLE = DATA ? 1000 : 200, RANK = {"q/order-by": [[["fibery/rank"], "q/asc"]]}, UU = /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/g;
const NAME = {}, DEAD = new Set(), DESC = {}, FL = {}, F = {}, AUT = [], H = [], H0 = [], fails = [];
let calls = 0, size = 0;
const safe = async (l, p) => { calls++; try { return await p; } catch (e) { fails.push(l + ": " + String(e && e.message || e).slice(0, 150)); return null; } };
const Q = (f, s, x) => safe(f, query({query: {"q/from": f, "q/select": s, ...x}})).then(r => r && r.result);
const N = (f, w) => Q(f, ["q/count", "fibery/id"], w && {"q/where": w});
const sp = n => n.slice(0, n.indexOf("/")), nm = n => n.slice(n.indexOf("/") + 1), min = v => String(v).slice(0, 16);
const E = v => v == null || v === "" || (Array.isArray(v) && !v.length), T = a => a.reduce((o, x) => (o[x] = (o[x] || 0) + 1, o), {});
const sing = s => s.toLowerCase().replace(/ies$/, "y").replace(/([^s])s$/, "$1"), norm = s => String(s || "").toLowerCase().replace(/\(example\)/g, "").replace(/\s+/g, " ").replace(/[.,;:!?]+$/, "").trim();
const edge = (d, f, dir) => Q(d, {v: f}, {"q/order-by": [[[f], dir]], "q/limit": 1}).then(r => min(((r || [])[0] || {}).v));
const pool = async (xs, k, fn, more) => { let i = 0; await Promise.all([...Array(k)].map(async () => { while (i < xs.length && Date.now() - T0 < 35000 && (!more || more())) await fn(xs[i++]); })); return i; };
const J = v => JSON.stringify(v).replace(/"((?:[^"\\]|\\.)*)"(:?)/g, (m, s, c) => /^[\w .\/:@()→+&'-]+$/.test(s) && (c || !/^(true|false|null|[\d.-]+)$/.test(s)) ? s + c : m);
const un = (v, P) => Array.isArray(v) ? v.map(x => un(x, P)) : v && typeof v == "object" ? (v.filterExpression ? un(v.filterExpression, v.params) : "value" in v ? (v.type == "formula" ? "=" + v.value : un(v.value, P)) : v.type == "empty" ? "empty" : "fibery/id" in v ? v["fibery/id"] : Object.fromEntries(Object.entries(v).map(([k, x]) => [k, un(x, P)]))) : P && v in P ? un(P[v]) : v;
const [me, c0, us] = await Promise.all([safe("get_me", get_me({})), safe("capabilities", display_schema_capabilities({})), Q("fibery/user", {n: "user/name", e: "user/email"}, {"q/limit": "q/no-limit"})]);
const SP = Object.keys(c0.accessInfo.spaces), A = (await safe("capabilities", display_schema_capabilities({spaces: SP}))).accessInfo;
const ALL = Object.keys(A.databases).filter(d => SP.includes(sp(d))).sort(), url = n => (A.databases[n] || A.spaces[n] || {}).url, ok = d => typeof A.databases[d] == "object";
const U = new Set((us || []).flatMap(u => [String(u.n).toLowerCase(), String(u.e).toLowerCase()]));
const [ty, fl] = await Promise.all([Q("fibery/type", {n: "fibery/name", d: "fibery/description"}, {"q/where": ["q/in", ["fibery/name"], ALL], "q/limit": "q/no-limit"}),
  Q("fibery/field", {id: "fibery/id", n: "fibery/name", t: "fibery/type", m: "fibery/meta", c: "fibery/creation-date", h: ["fibery/holder-type", "fibery/name"]}, {"q/where": ["q/in", ["fibery/holder-type", "fibery/name"], [...ALL, "fibery/user"]], "q/limit": "q/no-limit"})]);
(ty || []).forEach(t => { DESC[t.n] = t.d || ""; });
(fl || []).forEach(f => { if (/_deleted$/.test(f.n)) return DEAD.add(f.id); NAME[f.id] = f.n; (FL[f.h] = FL[f.h] || []).push(f); });
const K = {"Collaboration~Documents/Document": "rich", "fibery/bool": "check", "fibery/json-value": "json", "fibery/text": "text", "fibery/email": "text", "fibery/url": "text", "fibery/phone": "text"};
const kind = (f, d) => { const m = f.m || {}, t = f.t, c = m["fibery/collection?"] ? "[]" : ""; return f.n == "workflow/state" ? "state" : /^(fibery|Collaboration~Documents|comments|avatar|icon)\//.test(f.n) ? "" : m["formula/formula?"] ? (/^fibery\/(text|int|decimal|date|date-time|bool)$/.test(t) ? "formula" : "") : K[t] || (t == "fibery/file" ? "file" + c : t == "fibery/user" ? "user" + c : t.startsWith("fibery/") ? "value" : (t == f.n + "_" + d ? "select" : "rel") + c); };
const fieldsOf = d => (FL[d] || []).map(f => ({...f, k: kind(f, d), s: nm(f.n)})).filter(f => f.k);
const pick = f => f.k == "state" ? ["workflow/state", "enum/name"] : f.k == "rich" ? [f.n, "Collaboration~Documents/Snippet"] : f.k == "select" ? [f.n, "enum/name"] : /^(rel|user|file)$/.test(f.k) ? [f.n, "fibery/id"] : /\[\]/.test(f.k) ? {"q/from": f.n, "q/select": {id: "fibery/id"}, "q/limit": 1} : f.n;
const has = (f, v) => f.k == "check" ? v === true : !E(v);
const filled = f => f.k == "check" ? ["=", [f.n], true] : ["=", [/text|rich/.test(f.k) ? "q/null-or-empty?" : "q/null?", f.k == "rich" ? [f.n, "Collaboration~Documents/Snippet"] : /^(value|formula|text)$/.test(f.k) ? [f.n] : [f.n, "fibery/id"]], false];
const ENUM = (t, s) => Q(t, {id: "fibery/id", o: "enum/name", ...s}, RANK).then(r => (r || []).map(z => (NAME[z.id] = z.o, z)));
const loaded = new Set();
async function facts(d) {
  const all = fieldsOf(d), own = all.filter(f => !/state|formula/.test(f.k)), base = {url: url(d), description: (DESC[d] || "").slice(0, 150)};
  if (own.length && own.every(f => (f.m || {})["fibery/readonly?"])) {
    const [n, r] = await Promise.all([N(d), Q(d, {by: ["fibery/created-by", "user/name"]}, {"q/limit": 50})]), del = all.find(f => /^deleted in /i.test(f.s));
    return {n, ...base, readOnly: true, fields: all.length, ...(del ? {deletedIn: del.s} : {}), by: T((r || []).map(z => z.by))};
  }
  const fs = all.filter(f => f.k != "json"), st = fs.find(f => f.k == "state"), ti = fs.find(f => (f.m || {})["ui/title?"]), sels = fs.filter(f => /^select/.test(f.k)), s = {c: "fibery/creation-date", m: "fibery/modification-date", by: ["fibery/created-by", "user/name"]}, at = f => fs.indexOf(f);
  fs.forEach((f, j) => { s[j] = pick(f); });
  const [n, states, ...opts] = await Promise.all([N(d), st && ENUM("workflow/state_" + d, {t: "workflow/Type", f: "workflow/Final", n: ["q/count", ["workflow/objects", "fibery/id"]]}), ...sels.map(f => ENUM(f.t, {n: ["q/count", [sp(f.t) + "/entities", "fibery/id"]]}))]);
  if (n == null) return null;
  loaded.add(d);
  const R = [], lim = n > ALLN ? SAMPLE : n;
  for (let o = 0; o < lim; o += 1000) { const p = await Q(d, s, {"q/order-by": [[["fibery/creation-date"], "q/desc"]], "q/limit": Math.min(1000, lim - o), "q/offset": o}); if (!p) return {n, ...base, error: "records can't be read: see failed"}; R.push(...p); }
  const big = R.length < n, cr = R.map(r => r.c).sort(), tv = ti ? R.map(r => r[at(ti)]) : [], ex = tv.filter(v => /\(example\)/.test(v)).length, ut = tv.filter(v => !norm(v)).length, fo = (FL[d] || []).filter(f => (f.m || {})["formula/formula?"]).length;
  const x = Object.assign({n, ...base}, fo ? {formulas: fo} : {}, R.length ? {made: [min(cr[0]), min(cr[cr.length - 1])], minutes: new Set(cr.map(min)).size, changed: min(R.map(r => r.m).sort().pop()), by: T(R.map(r => r.by))} : {}, ex ? {example: ex} : {}, !ti ? {untitled: "no title field"} : ut ? {untitled: ut} : {}, big ? {sample: R.length} : {});
  x.fields = all.filter(f => f.k != "state").map(f => {
    if (f.k == "json") return [f.s, "json"];
    const j = at(f), v = R.map(r => r[j]), o = [f.s, f.k + (/^(rel|user)/.test(f.k) ? " → " + (f.t == "fibery/user" ? "users" : sp(f.t) == sp(d) ? nm(f.t) : f.t) : ""), v.filter(z => has(f, z)).length];
    if (String(f.c) >= TODAY.slice(0, 8) + "01") o.push("new");
    if (f.k == "text" && f != ti) { const dv = T(v.filter(z => !E(z)).map(z => String(z).slice(0, 40))), k = Object.keys(dv), u = k.filter(z => U.has(z.toLowerCase())).length; o.push(k.length + " distinct"); if (DATA && k.length <= 15) o.push(dv); if (u) o.push(u + " match user names or emails"); }
    return o;
  });
  if (states) x.states = states.map(z => [z.o, z.t + (z.f ? ", final" : ""), z.n]);
  if (sels.length) x.options = Object.fromEntries(sels.map((f, j) => [f.s, (opts[j] || []).map(z => [z.o, z.n])]));
  const w = [];
  if (big) { w.push(edge(d, "fibery/creation-date", "q/asc").then(v => { x.made[0] = v; }), edge(d, "fibery/modification-date", "q/desc").then(v => { x.changed = v; })); if (ti) w.push(N(d, ["q/contains-ignoring-case?", [ti.n], "(example)"]).then(v => { if (v) x.example = v; }), N(d, filled(ti)).then(v => { if (v != null && n - v) x.untitled = n - v; })); }
  if (DATA) w.push(dataFacts(d, x, R, fs, st, ti, states, big));
  await Promise.all(w);
  x._t = new Set(tv.map(norm).filter(v => v.length > 2)); x._v = Object.fromEntries(fs.filter(f => f.k == "text" && f != ti).map(f => [f.s, new Set(R.map(r => norm(r[at(f)])).filter(v => v && !/^https?:/.test(v)))]));
  return x;
}
const scope = SCOPE.length ? ALL.filter(d => SCOPE.includes(sp(d))) : ALL, todo = scope.filter(ok), mine = SCOPE.length ? SCOPE.filter(s => SP.includes(s)) : SP;
const tA = todo.flatMap(d => [[d, "rule"], [d, "button"]]), tH = DATA ? histTasks(todo) : [];
const auto = async ([d, t]) => { const r = await safe(t + " " + d, query_automations({automationType: t, database: d})); ((r && r.automations) || []).forEach(a => { AUT.push([d, t, a]); size += JSON.stringify(a).length >> 1; }); }, room = () => size < 32000;
const [nF, nA, nH] = await Promise.all([pool(todo.slice(SKIP[0]), 8, async d => { F[d] = await facts(d); if (F[d]) size += J(F[d]).length; }, room), pool(tA.slice(SKIP[1]), 24, auto, room), DATA ? pool(tH.slice(SKIP[2]), 8, hist) : 0]);
const done = Object.keys(F).filter(d => F[d] && F[d]._v);
for (const d of done) for (const [f, vs] of Object.entries(F[d]._v)) {
  if (!vs.size || vs.size > 300) continue;
  const hits = [];
  for (const o of done.filter(o => o != d && sp(o) == sp(d))) { const k = [...vs].filter(v => F[o]._t.has(v)).length; if (k) hits.push(`${k} of ${vs.size} values are ${nm(o)} titles`); for (const [g, ws2] of Object.entries(F[o]._v)) { const m = [...vs].filter(v => ws2.has(v)).length; if (m >= 2 || m == vs.size) hits.push(`${m} of ${vs.size} values match ${nm(o)}.${g}`); } }
  if (hits.length) F[d].fields.find(z => z[0] == f).push(...hits.slice(0, 3));
}
done.forEach(d => { delete F[d]._t; delete F[d]._v; });
const ws = {sameName: []}, pairs = [];
for (const d of Object.keys(F).filter(d => F[d] && !F[d].readOnly)) for (const o of ALL.filter(o => sp(o) != sp(d) && sing(nm(o)) == sing(nm(d)) && ok(o) && !pairs.some(z => z[0] == o && z[1] == d))) pairs.push([d, o]);
ws.sameName = await Promise.all(pairs.map(async ([d, o]) => { const a = new Set(fieldsOf(d).map(f => sing(f.s))), b = fieldsOf(o).map(f => sing(f.s)).filter(z => a.has(z) && !/^(name|description)$/.test(z)); const [n, nw] = F[o] && F[o].made ? [F[o].n, F[o].made[1]] : await Promise.all([N(o), edge(o, "fibery/creation-date", "q/desc")]); return [d, o, url(o), ALL.filter(z => sp(z) == sp(o)).length + " databases in its Space", n + " records", "newest " + nw, b.length + " shared field names: " + b.slice(0, 6).join(", ")]; }));
if (!SKIP.some(Boolean)) { ws.userFieldsBySpace = T(fieldsOf("fibery/user").filter(f => f.n.startsWith("user/") && ALL.includes(f.t)).map(f => sp(f.t))); ws.noDatabases = await Promise.all(mine.filter(s => !ALL.some(d => sp(d) == s)).map(async s => { const v = await safe("views " + s, query_views({space: s, withConfig: false})); return [s, url(s), (v ? (v.views || []).length : "?") + " views and documents"]; })); }
const unk = [...new Set(AUT.flatMap(([, , a]) => JSON.stringify(a).match(UU) || []))].filter(id => !NAME[id] && !DEAD.has(id));
if (unk.length) await Promise.all([Q("fibery/field", {id: "fibery/id", n: "fibery/name"}, {"q/where": ["q/in", ["fibery/id"], unk], "q/limit": "q/no-limit"}).then(r => (r || []).forEach(f => { if (!/_deleted$/.test(f.n)) NAME[f.id] = f.n; })), ...[...new Set(AUT.flatMap(([d]) => [d, ...fieldsOf(d).filter(f => /^rel/.test(f.k)).map(f => f.t)]))].filter(c => FL[c] && !loaded.has(c)).flatMap(c => fieldsOf(c).filter(f => /^(state|select)/.test(f.k)).map(f => ENUM(f.k == "state" ? "workflow/state_" + c : f.t)))]);
const m = ((me && me.result) || [])[0] || {};
log(J({workspace: String(m.url).split("/")[2], user: m["user/name"], role: String(m["fibery/role"]).replace("role/", ""), spaces: SP.length, databases: ALL.length, scope: SCOPE.length ? SCOPE : "whole workspace", inScope: scope.length, data: DATA, spaceLinks: Object.fromEntries(mine.map(s => [s, url(s)])), cantRead: scope.filter(d => !ok(d)), noSuchSpace: SCOPE.filter(s => !SP.includes(s))}));
for (const d of Object.keys(F).sort()) if (F[d]) log(d + " " + J(F[d]));
log("workspace " + J(ws));
AUT.forEach(([d, t, a]) => { const g = (a.usedFields || []).filter(id => !NAME[id]).length, r = a.lastRun || {}; log("automation " + d + " " + J([t, a.name, a.enabled ? "enabled" : "DISABLED", (r.status || "?") + (r.startDate ? " " + min(r.startDate) : ""), "created " + String(a.created).slice(0, 10), (a.triggers || []).map(x => [x.trigger, un(x.args)]), un(a.filter), (a.actions || []).map(x => [x.name, x.app, un(x.args)]), ...(g ? [g + " used fields gone"] : [])]).replace(UU, id => NAME[id] || id).split(sp(d) + "/").join("") + " " + a.url); });
H.forEach(h => log("history " + J(h)));
if (H0.length) log("history no record deleted or archived in 30 days: " + H0.join(", "));
const left = [todo.length - SKIP[0] - nF, tA.length - SKIP[1] - nA, tH.length - SKIP[2] - nH];
log(`${AUT.length} automations; ${((Date.now() - T0) / 1000).toFixed(1)} s, ${calls} calls${left.some(Boolean) ? `; stopped early with ${left[0]} databases, ${left[1]} automation lists and ${left[2]} histories left: run this script again with SKIP = [${SKIP[0] + nF}, ${SKIP[1] + nA}, ${SKIP[2] + nH}]` : ""}; failed ${fails.length}${fails.length ? ": " + fails.join(" | ") : ""}`);
```

## Part 2: the data pass

```js
function ago(k) { return new Date(T0 - k * 864e5).toISOString(); }
function TY(t) { return ["q/equals-ignoring-case?", ["workflow/state", "workflow/Type"], t]; }
function histTasks(ds) { return ds.flatMap(d => [[d, "deleted"], ...((FL[d] || []).some(f => (f.m || {})["formula/formula?"]) && (FL[d] || []).some(f => f.n == "workflow/state") ? [[d, "stuck"]] : [])]); }
async function dataFacts(d, x, R, fs, st, ti, states, big) {
  const at = f => fs.indexOf(f), si = at(st), tv = ti ? R.map(r => r[at(ti)]) : [], stOf = Object.fromEntries((states || []).map(z => [z.o, z])), open = R.filter(r => !st || !(stOf[r[si]] || {}).f), g = {}, one = fs.filter(f => f.k == "rel"), many = fs.filter(f => f.k == "rel[]"), w = [], D30 = ago(30), D180 = ago(180), sum = a => a.reduce((p, q) => p + q, 0);
  R.forEach((r, j) => { const t = norm(tv[j]); if (t) (g[t] = g[t] || []).push(r); });
  const dup = Object.entries(g).filter(e => e[1].length > 1), nt = R.filter((r, j) => ti && !norm(tv[j])), el = one.map(f => { const e = R.filter(r => E(r[at(f)])); return e.length && e.length <= R.length / 2 ? [f.s, e.length, ...(st ? [T(e.map(r => r[si]))] : []), ...e.slice(0, 2).map(r => r.url)] : 0; }).filter(Boolean);
  if (dup.length) Object.assign(x, {duplicateTitles: dup.length, duplicates: dup.slice(0, 8).map(([t, rs]) => [t, rs.length, ...one.filter(f => rs.every(r => r[at(f)] && r[at(f)] == rs[0][at(f)])).map(f => "same " + f.s), rs.filter(r => many.some(f => !E(r[at(f)]))).length + " with links in a collection field", ...rs.slice(0, 2).map(r => r.url)])});
  if (nt.length) x.untitledLinks = nt.slice(0, 3).map(r => r.url);
  if (el.length) x.emptyLinks = el;
  const work = {};
  if (st) {
    work.unfinished = sum(states.filter(z => !z.f).map(z => z.n));
    const old = R.filter(r => (stOf[r[si]] || {}).t == "Started" && r.c < D30), quiet = old.filter(r => r.m < D30);
    Object.assign(work, {started: sum(states.filter(z => z.t == "Started").map(z => z.n)), startedBefore: [D30.slice(0, 10), old.length], notStartedBefore: [D180.slice(0, 10), R.filter(r => (stOf[r[si]] || {}).t == "Not started" && r.c < D180).length]});
    if (old.length) work.noChangeSince30d = x.formulas ? "see history" : [quiet.length, ...quiet.slice(0, 3).map(r => r.url)];
    if (big) { w.push(N(d, ["q/and", TY("Not started"), ["<", ["fibery/creation-date"], D180]]).then(v => { work.notStartedBefore.push("all " + v); })); if (!x.formulas) w.push(N(d, ["q/and", TY("Started"), ["<", ["fibery/modification-date"], D30]]).then(v => { work.noChangeSince30d = ["all " + v]; })); }
  }
  const by = st ? [st] : fs.filter(f => f.k == "select" && /status|state|stage|phase/i.test(f.s)).slice(0, 1), past = (r, j) => { const v = r[j] && typeof r[j] == "object" ? r[j].end : r[j]; return v && String(v).slice(0, 10) < TODAY; };
  work.pastDates = fs.filter(f => by.length && /date/.test(f.t) && /^(value|formula)$/.test(f.k) && !/creat|start|receiv|harvest|prep|made|since|inocul|fixed|check|sent|paid|done|closed|finish|complet|born|join|last|report|submit|open|stamp|edit|updat|modif|log/i.test(f.s)).map(f => { const j = at(f), p = open.filter(r => past(r, j)), o = [f.s, p.length, Object.fromEntries(by.map(b => [b.s, T(p.map(r => r[at(b)]))])), ...p.slice(0, 2).map(r => r.url)]; if (big && st) w.push(N(d, ["q/and", ["=", ["workflow/state", "workflow/Final"], false], ["<", [f.n], TODAY]]).then(v => { o.push("all " + v); })); return o; });
  if (big) fs.forEach((f, j) => { if (!/state|formula/.test(f.k) && R.filter(r => has(f, r[j])).length <= R.length * 0.05) w.push(N(d, filled(f)).then(v => { x.fields.find(o => o[0] == f.s).push("all " + v); })); });
  await Promise.all(w);
  work.pastDates = work.pastDates.filter(o => o[1] > 0 || o.some(v => /^all [1-9]/.test(v)));
  if (!work.pastDates.length) delete work.pastDates;
  if (Object.keys(work).length) x.work = work;
}
async function hist([d, kind]) {
  const pages = async (args, max) => { const it = []; let cur, more = false; for (let p = 0; p < max; p++) { const r = await safe("history " + d, search_history({...args, database: d, since: ago(30), limit: 100, ...(cur ? {sinceItem: cur} : {})})); if (!r) return []; it.push(...(r.items || [])); more = r.hasNext; cur = r.sinceItem; if (!more) break; } return [it, more]; };
  if (kind == "deleted") {
    const [it, more] = await pages({actions: ["deleted", "archived"]}, 3);
    if (!it) return;
    if (!it.length) return H0.push(d);
    H.push([d, `deleted or archived in 30 days: ${it.length}${more ? "+" : ""}`, "peak " + Object.entries(T(it.map(x => (x.author && x.author.name) + ", " + String(x.date).slice(0, 13)))).sort((a, b) => b[1] - a[1])[0].join(", "), "from " + [...new Set(it.map(x => x.fromService || "app"))].join(", ")]);
  } else {
    const st = await Q(d, {id: "fibery/id", s: ["workflow/state", "enum/name"]}, {"q/where": ["q/and", TY("Started"), ["<", ["fibery/creation-date"], ago(30)]], "q/limit": 1000});
    if (!(st || []).length) return;
    const [it, more] = await pages({actions: ["created", "updated", "collectionItemAdded", "collectionItemRemoved"]}, 5);
    if (!it) return;
    const moved = new Set(it.filter(x => !(x.changes || []).every(c => c.field == "Collaboration~Documents/References")).map(x => x.entity && x.entity.id)), stuck = st.filter(r => !moved.has(r.id));
    H.push([d, `stuck: ${stuck.length} of ${st.length} Started records made before ${ago(30).slice(0, 10)}, no change by a person since${more ? " (an upper bound)" : ""}`, ...stuck.slice(0, 3).map(r => r.url + " (" + r.s + ")")]);
  }
}
```
