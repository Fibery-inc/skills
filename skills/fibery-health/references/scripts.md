# The facts script

SKILL.md §2 sends it. Copy it whole and change only the first line: `SCOPE`, the spaces the person named, spelled as in Fibery (`[]` for the whole workspace); `DATA`, `true` for the data pass; `SKIP`, `[0, 0]` unless the last run's final line gave other numbers. The script only reads and calls every Fibery tool it needs itself. It reads the schema once, then reads each database in scope and its rules and buttons at the same time.

It stops starting new work after 35 seconds or about 32,000 characters of output, whichever comes first, so a run never times out and its output stays readable in one piece. Its last line then says what's left and gives the `SKIP` for the next run, which prints only what's left.

## What it logs

Compact JSON: keys and plain values are not quoted, and keys whose value would be zero or empty are left out.

- **First line**: the workspace, the person and their role, the workspace's Space and database counts, the scope and its database count, `data` (whether `DATA` was on), each Space's link (`spaceLinks`), databases in scope the person can't read (`cantRead`), names that match no Space (`noSuchSpace`).
- **`<Space/Database> {…}`**, one line per database:
  - `n` records, `url`, `description` (its first 150 characters), `formulas` (formula fields), `disabledFormulas` (formulas Fibery switched off, with its reason: `loop-detected` means formulas that read each other), `fixedDateFormulas` (formulas holding a literal year or date, with the numbers they hold), `mixedAlphabets` (its name mixes Latin with Cyrillic or Greek letters), `made` (first and last record, UTC, to the minute), `minutes` (distinct minutes its records were made in), `by` (records per creator; `null` means no person: an integration, a form or the API), `example` (titled "(example)"), `sample` (only the newest N records were read: a database over 200 records without `DATA`, over 2,000 with it), `unreadable` (fields left out because reading them failed), `error` when its records couldn't be read at all (its states and option names are still listed).
  - A database whose own fields are all read-only, as an integration's are, gets a short line: `readOnly: true`, `fields` (how many), `deletedIn` (its "Deleted in …" field) and `by` (the creators of 50 records).
  - `fields`: `[name, kind, records with a value, …]`. Kinds: `text`, `value` (number, date, date range and other plain values), `check`, `rich`, `select`, `select[]` (multi-select), `rel` or `rel[]` → its database (the Space left out when it's the same) and the field on the other side (`rel[] → Insight.Features`), `user` or `user[]` → users, `file`, `file[]`, `formula` (a formula returning text, a number, a date, a checkbox, an email or a link), `lookup` (a formula returning records or users) and `json`, the last two not counted. Hidden fields (such as an import's ids) and system collections (documents, whiteboards) are left out. Then `mixed alphabets`; `read by …`, the formulas that read a disabled formula or, with `DATA`, a field that is nearly empty or retired (for a relation, either of its sides); `new` (created this month) or `added <month>` (most old fields have no creation date and show neither); for text, how many distinct values, with `DATA` the values and their counts when there are 15 or fewer, how many match workspace user names or emails, and how many are titles of another database in the same Space or match one of its text fields. With `DATA` also: `empty on the N newest, since <month>` (the newest record with a value was made that month, and the N records made after it have none), and for a collection relation `newest linked <database> made <month>` (the newest record on the other side that links here); `other side filled in X of Y` for a nearly empty relation (how many records of the database it points to link back); `all N`, an exact count over every record, for a field the sample shows nearly empty.
  - `states`: `[state, type and ", final", records]` in workflow order.
  - `options`: per select, `[option, records]` in the select's order, counted per option over the records read, unused options included; then `same name: …` for options whose names match but for case, spacing, punctuation or a plural, with `(their icons differ)` when they do.
  - `accounts`, on a database with a workflow whose person field holds a different user on nearly every record, as a people list does: `field`, `openWithoutAccount` (records in an unfinished state without a user, among the records read, with two links) and `finishedWithActiveAccount` (records in a final state whose user is still active, over every record, with two links).
  - With `DATA`: `emptyLinks` `[single relation or person field, records read without it, their split by state (or by a Status, State, Stage or Phase select), two links with their state (unfinished records first), all N, open N]` for a field empty in some records but filled in at least a quarter; when the database was sampled, `all` counts every record without it and `open` those in an unfinished state. Self-relations and the `accounts` field are left out. `inactiveUsers` `[person field, records whose user is deactivated (unfinished ones only, with a workflow), two links]`.
- **`workspace {…}`**: `sameName` `[database, a database with the same singular name in another Space, its link, how many databases that Space has, its records, its newest record, the field names they share besides Name and Description]`; on the first run only, `userFieldsBySpace` (the person fields on every workspace user, counted by the Space of the database they come from) and `noDatabases` `[Space, link, views and documents]`.
- **`automation <Space/Database> […] <link>`**, one per rule and button: `[rule or button, name, enabled or DISABLED, last run (COMPLETED, FAILED or NOT STARTED, which means it never ran, with its start in UTC), created, triggers ([trigger, args]), filter, actions, N used fields gone, records matching its filter now]`. Actions are `[name, what it sets and its own filter]`, or for another app's action (Slack, email) `[name, app, the account it sends through, args]`: `<app> account of <name>`, or `an account not visible to you`. Field, state, option and user ids appear as names, without the database's own Space; filters are written out with their values; `=` starts a formula and `empty` clears a field. Texts over 300 characters are cut, and a Script action that still holds Fibery's sample code reads `default script template (N characters)`. `records matching its filter now` is given for an enabled scheduled rule with a filter that hasn't run for two intervals or never ran, relative dates (today, a month from now) taken from today (`can't count` when the filter can't run as a query). A schedule's `schedulerConfig`: `freq` 0 yearly, 1 monthly, 2 weekly, 3 daily, 4 hourly; `interval`; `byweekday` 0 = Monday; `byhour` and `byminute` in UTC; `dtstart`, the first run.
- **Last line**: automations found (rules and buttons), seconds and calls; "stopped early with … left: run this script again with SKIP = [a, b]" when it did; `failed` with each failed call.

## The script

```js
const SCOPE = [], DATA = false, SKIP = [0, 0];
const T0 = Date.now(), D = 864e5, TODAY = new Date(T0).toISOString().slice(0, 10), D180 = new Date(T0 - 180 * D).toISOString(), ALLN = DATA ? 2000 : 200, SAMPLE = DATA ? 1000 : 200, RANK = {"q/order-by": [[["fibery/rank"], "q/asc"]]}, UU = /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/g;
const NAME = {}, DEAD = new Set(), DESC = {}, FL = {}, F = {}, AUT = [], ACC = {}, RB = {}, fails = [], loaded = new Set();
let calls = 0, size = 0;
const msg = e => String(e && e.message || e).split("**IMPORTANT")[0].trim().slice(0, 200);
const safe = async (l, p) => { calls++; try { return await p; } catch (e) { fails.push(l + ": " + msg(e)); return null; } };
const Q = (f, s, x) => safe(f, query({query: {"q/from": f, "q/select": s, ...x}})).then(r => r && r.result);
const N = (f, w) => Q(f, ["q/count", "fibery/id"], w && {"q/where": w});
const sp = n => n.slice(0, n.indexOf("/")), nm = n => n.slice(n.indexOf("/") + 1), min = v => String(v).slice(0, 16);
const E = v => v == null || v === "" || (Array.isArray(v) && !v.length), T = a => a.reduce((o, x) => (o[x] = (o[x] || 0) + 1, o), {});
const sing = s => s.toLowerCase().replace(/ies$/, "y").replace(/([^s])s$/, "$1"), norm = s => String(s || "").toLowerCase().replace(/\(example\)/g, "").replace(/\s+/g, " ").replace(/[.,;:!?]+$/, "").trim();
const edge = (d, f, dir) => Q(d, {v: f}, {"q/order-by": [[[f], dir]], "q/limit": 1}).then(r => min(((r || [])[0] || {}).v));
const pool = async (xs, k, fn, more) => { let i = 0; await Promise.all([...Array(k)].map(async () => { while (i < xs.length && Date.now() - T0 < 35000 && (!more || more())) await fn(xs[i++]); })); return i; };
const J = v => JSON.stringify(v).replace(/"((?:[^"\\]|\\.)*)"(:?)/g, (m, s, c) => /^[\w .\/:@()→+&'-]+$/.test(s) && (c || !/^(true|false|null|[\d.-]+)$/.test(s)) ? s + c : m);
const un = (v, P) => Array.isArray(v) ? v.map(x => un(x, P)) : v && typeof v == "object" ? (v.filterExpression ? un(v.filterExpression, v.params) : "value" in v ? (v.type == "formula" ? "=" + v.value : un(v.value, P)) : v.type == "empty" ? "empty" : "fibery/id" in v ? v["fibery/id"] : Object.fromEntries(Object.entries(v).map(([k, x]) => [k, un(x, P)]))) : P && v in P ? un(P[v]) : typeof v == "string" && v.length > 300 ? (/'Field Name': newValue/.test(v) ? "default script template (" + v.length + " characters)" : v.slice(0, 300) + "…") : v;
const where = v => Array.isArray(v) ? v.map((x, i) => i == 0 && /^(and|or)$/.test(x) ? "q/" + x : where(x)) : v;
const rd = k => { const m = /^\$(?:(today|yesterday|tomorrow)|(?:(\d+)-)?(day|week|month|year)s?-(ago|before-now|from-now|after-now))-date$/.exec(k); if (!m) return; const t = new Date(T0), n = m[1] ? {today: 0, yesterday: -1, tomorrow: 1}[m[1]] : (m[2] || 1) * (/ago|before/.test(m[4]) ? -1 : 1), u = m[3] || "day"; if (u == "month") t.setUTCMonth(t.getUTCMonth() + n); else if (u == "year") t.setUTCFullYear(t.getUTCFullYear() + n); else t.setUTCDate(t.getUTCDate() + n * (u == "week" ? 7 : 1)); return t.toISOString().slice(0, 10); };
const [me, c0, us] = await Promise.all([safe("get_me", get_me({})), safe("capabilities", display_schema_capabilities({})), Q("fibery/user", {id: "fibery/id", n: "user/name", e: "user/email"}, {"q/limit": "q/no-limit"})]);
const SP = Object.keys(c0.accessInfo.spaces), A = (await safe("capabilities", display_schema_capabilities({spaces: SP}))).accessInfo;
const ALL = Object.keys(A.databases).filter(d => SP.includes(sp(d))).sort(), AS = new Set(ALL), url = n => (A.databases[n] || A.spaces[n] || {}).url, ok = d => typeof A.databases[d] == "object";
const U = new Set((us || []).flatMap(u => (NAME[u.id] = u.n, [String(u.n).toLowerCase(), String(u.e).toLowerCase()])));
const [ty, fl] = await Promise.all([Q("fibery/type", {n: "fibery/name", d: "fibery/description"}, {"q/where": ["q/in", ["fibery/name"], ALL], "q/limit": "q/no-limit"}),
  Q("fibery/field", {id: "fibery/id", n: "fibery/name", t: "fibery/type", m: "fibery/meta", c: "fibery/creation-date", h: ["fibery/holder-type", "fibery/name"]}, {"q/where": ["q/in", ["fibery/holder-type", "fibery/name"], [...ALL, "fibery/user"]], "q/limit": "q/no-limit"})]);
(ty || []).forEach(t => { DESC[t.n] = t.d || ""; });
(fl || []).forEach(f => { if (/_deleted$/.test(f.n)) return DEAD.add(f.id); NAME[f.id] = f.n; (FL[f.h] = FL[f.h] || []).push(f); });
(fl || []).forEach(g => { if ((g.m || {})["formula/formula?"]) new Set(JSON.stringify(g.m["formula/formula"] || {}).match(UU)).forEach(id => { if (id != g.id) (RB[id] = RB[id] || []).push(nm(g.h) + "." + nm(g.n)); }); });
const K = {"Collaboration~Documents/Document": "rich", "fibery/bool": "check", "fibery/json-value": "json", "fibery/text": "text", "fibery/email": "text", "fibery/url": "text", "fibery/phone": "text"};
const kind = f => { const m = f.m || {}, t = f.t, c = m["fibery/collection?"] ? "[]" : ""; return f.n == "workflow/state" ? "state" : m["fibery/private?"] || /^(fibery|Collaboration~Documents|comments|avatar|icon)\//.test(f.n) ? "" : m["formula/formula?"] ? (/^fibery\/(text|int|decimal|date|date-time|bool|email|url|phone|emoji|date-range|date-time-range)$/.test(t) ? "formula" : "lookup") : K[t] || (t == "fibery/file" ? "file" + c : t == "fibery/user" ? "user" + c : t.startsWith("fibery/") ? (c ? "" : "value") : (m["fibery/type-component?"] ? "select" : "rel") + c); };
const fieldsOf = d => (FL[d] || []).map(f => ({...f, k: kind(f), s: nm(f.n)})).filter(f => f.k);
const pick = f => f.k == "state" ? ["workflow/state", "enum/name"] : f.k == "rich" ? [f.n, "Collaboration~Documents/Snippet"] : f.k == "select[]" ? {"q/from": f.n, "q/select": {o: "fibery/id"}, "q/limit": 20} : /^(rel|user|file|select)$/.test(f.k) ? [f.n, "fibery/id"] : /\[\]/.test(f.k) ? {"q/from": f.n, "q/select": {id: "fibery/id"}, "q/limit": 1} : f.n;
const has = (f, v) => f.k == "check" ? v === true : !E(v), rl = f => (f.m || {})["fibery/relation"], mx = s => /[a-z]/i.test(s) && /[\u0370-\u04ff]/.test(s);
const filled = f => f.k == "check" ? ["=", [f.n], true] : ["=", [/text|rich/.test(f.k) ? "q/null-or-empty?" : "q/null?", f.k == "rich" ? [f.n, "Collaboration~Documents/Snippet"] : /^(value|formula|text)$/.test(f.k) ? [f.n] : [f.n, "fibery/id"]], false];
const ENUM = (t, s) => Q(t, {id: "fibery/id", o: "enum/name", ...s}, RANK).then(r => (r || []).map(z => (NAME[z.id] = z.o, z)));
const read = async (d, s, o, l) => { calls++; try { return (await query({query: {"q/from": d, "q/select": s, "q/order-by": [[["fibery/creation-date"], "q/desc"]], "q/limit": l, "q/offset": o}})).result; } catch (e) { return msg(e); } };
async function facts(d) {
  const all = fieldsOf(d), own = all.filter(f => !/state|formula|lookup/.test(f.k)), base = {url: url(d), description: (DESC[d] || "").slice(0, 150)}, FF = (FL[d] || []).filter(f => (f.m || {})["formula/formula?"]);
  if (own.length && own.every(f => (f.m || {})["fibery/readonly?"])) {
    const [n, r] = await Promise.all([N(d), Q(d, {by: ["fibery/created-by", "user/name"]}, {"q/limit": 50})]), del = all.find(f => /^deleted in /i.test(f.s));
    return {n, ...base, readOnly: true, fields: all.length, ...(del ? {deletedIn: del.s} : {}), by: T((r || []).map(z => z.by))};
  }
  const fs = all.filter(f => !/json|lookup/.test(f.k)), st = fs.find(f => f.k == "state"), ti = fs.find(f => (f.m || {})["ui/title?"]), sels = fs.filter(f => /^select/.test(f.k)), s = {c: "fibery/creation-date", by: ["fibery/created-by", "user/name"]}, at = f => fs.indexOf(f), bad = new Set(), w = [];
  fs.forEach((f, j) => { s[j] = pick(f); });
  const [n, states, ...opts] = await Promise.all([N(d), st && ENUM("workflow/state_" + d, {t: "workflow/Type", f: "workflow/Final", n: ["q/count", ["workflow/objects", "fibery/id"]]}), ...sels.map(f => ENUM(f.t, {i: "enum/icon"}))]);
  if (n == null) return null;
  loaded.add(d);
  const x = {n, ...base}, off = FF.filter(f => f.m["formula/disabled?"]).map(f => nm(f.n) + ": " + (f.m["formula/disable-reason"] || "disabled")), fixed = FF.map(f => [nm(f.n), Object.values((f.m["formula/formula"] || {}).params || {}).map(String).filter(p => /^(20[2-3]\d(\b|-)|\d{1,2}$)/.test(p))]).filter(z => z[1].some(p => /^20[2-3]\d/.test(p))).map(([a, p]) => a + ": " + p.slice(0, 6).join(", "));
  if (FF.length) x.formulas = FF.length;
  if (off.length) x.disabledFormulas = off;
  if (fixed.length) x.fixedDateFormulas = fixed;
  if (mx(nm(d))) x.mixedAlphabets = true;
  const R = [], lim = n > ALLN ? SAMPLE : n;
  for (let o = 0; o < lim; o += 1000) {
    let p = await read(d, s, o, Math.min(1000, lim - o));
    if (typeof p == "string" && !o) { let b = fs.filter(f => p.includes('"' + f.n + '"') || p.includes(f.n + " sub-query")); if (!b.length) b = fs.filter(f => /\[\]/.test(f.k)); b.forEach(f => { bad.add(f); delete s[at(f)]; }); if (b.length) p = await read(d, s, o, Math.min(1000, lim - o)); }
    if (typeof p == "string") { fails.push(d + ": " + p); if (states) x.states = states.map(z => [z.o, z.t + (z.f ? ", final" : ""), z.n]); return Object.assign(x, {error: "records can't be read: see failed"}, sels.length ? {options: Object.fromEntries(sels.map((f, j) => [f.s, (opts[j] || []).map(z => z.o)]))} : {}); }
    R.push(...p);
  }
  const big = R.length < n, cr = R.map(r => r.c).sort(), tv = ti ? R.map(r => r[at(ti)]) : [], ex = tv.filter(v => /\(example\)/.test(v)).length, si = at(st), fin = new Set((states || []).filter(z => z.f).map(z => z.o));
  Object.assign(x, R.length ? {made: [min(cr[0]), min(cr[cr.length - 1])], minutes: new Set(cr.map(min)).size, by: T(R.map(r => r.by))} : {}, ex ? {example: ex} : {}, big ? {sample: R.length} : {});
  if (bad.size) x.unreadable = [...bad].map(f => f.s);
  x.fields = all.filter(f => f.k != "state" && !bad.has(f)).map(f => {
    if (/json|lookup/.test(f.k)) return [f.s, f.k];
    const j = at(f), v = R.map(r => r[j]), b = /^rel/.test(f.k) && rl(f) && (FL[f.t] || []).find(g => g.id != f.id && rl(g) == rl(f)), o = [f.s, f.k + (/^(rel|user)/.test(f.k) ? " → " + (f.t == "fibery/user" ? "users" : sp(f.t) == sp(d) ? nm(f.t) : f.t) + (b ? "." + nm(b.n) : "") : ""), v.filter(z => has(f, z)).length];
    const k1 = v.findIndex(z => has(f, z)), lo = R.length && o[2] <= R.length * 0.05, es = DATA && k1 >= 5 && R[k1].c < D180;
    if (mx(f.s)) o.push("mixed alphabets");
    if (es) o.push(`empty on the ${k1} newest, since ${R[k1].c.slice(0, 7)}`);
    const rb = [...(RB[f.id] || []), ...(b && RB[b.id] || [])];
    if (rb.length && (DATA && lo || es || (f.m || {})["formula/disabled?"])) o.push("read by " + rb.slice(0, 4).join(", "));
    if (es && b && /\[\]/.test(f.k)) w.push(Q(f.t, {c: "fibery/creation-date"}, {"q/where": ["=", ["q/null?", [b.n, "fibery/id"]], false], "q/order-by": [[["fibery/creation-date"], "q/desc"]], "q/limit": 1}).then(r => { const t = ((r || [])[0] || {}).c; if (t) o.push("newest linked " + nm(f.t) + " made " + t.slice(0, 7)); }));
    if (DATA && b && lo) w.push(Promise.all([N(f.t), N(f.t, ["=", ["q/null?", [b.n, "fibery/id"]], false])]).then(([a, c]) => { if (a != null && c != null) o.push("other side filled in " + c + " of " + a); }));
    if (f.c) o.push(String(f.c) >= TODAY.slice(0, 8) + "01" ? "new" : "added " + String(f.c).slice(0, 7));
    if (f.k == "text" && f != ti) { const k = [...new Set(v.filter(z => !E(z)).map(String))], u = k.filter(z => U.has(z.toLowerCase())).length; o.push(k.length + " distinct"); if (DATA && k.length <= 15) o.push(T(v.filter(z => !E(z)).map(z => String(z).slice(0, 40)))); if (u) o.push(u + " match user names or emails"); }
    return o;
  });
  if (states) x.states = states.map(z => [z.o, z.t + (z.f ? ", final" : ""), z.n]);
  if (sels.length) x.options = Object.fromEntries(sels.map((f, j) => { const c = !bad.has(f) && T(R.flatMap(r => { const v = r[at(f)]; return f.k == "select" ? (v ? [v] : []) : (v || []).map(z => z.o); })), os = opts[j] || [], key = z => norm(z.o).split(" ").map(sing).join(" "), same = os.filter((a, i) => os.findIndex(b => key(b) == key(a)) != i), diff = same.some(a => os.some(b => key(b) == key(a) && b.i != a.i)); return [f.s, [...os.map(z => c ? [z.o, c[z.id] || 0] : z.o), ...(same.length ? ["same name: " + same.map(z => z.o).join(", ") + (diff ? " (their icons differ)" : "")] : [])]]; }));
  const pu = st && fs.find(f => { if (f.k != "user" || bad.has(f)) return false; const ids = R.map(r => r[at(f)]).filter(Boolean); return ids.length >= 3 && ids.length >= R.length / 2 && new Set(ids).size >= ids.length * 0.9; });
  if (pu) { const open = R.filter(r => !fin.has(r[si]) && !r[at(pu)]), acc = x.accounts = {field: pu.s}; if (open.length) acc.openWithoutAccount = [open.length, ...open.slice(0, 2).map(r => r.url)]; w.push(Q(d, {id: "fibery/id"}, {"q/where": ["q/and", ["=", ["workflow/state", "workflow/Final"], true], ["=", [pu.n, "fibery/active?"], true]], "q/limit": 100}).then(r => { if (r && r.length) acc.finishedWithActiveAccount = [r.length, ...r.slice(0, 2).map(z => z.url)]; })); }
  if (big && R.length) w.push(edge(d, "fibery/creation-date", "q/asc").then(v => { x.made[0] = v; }));
  if (DATA) {
    const sb = st || sels.find(f => f.k == "select" && /status|state|stage|phase/i.test(f.s)), OPEN = ["=", ["workflow/state", "workflow/Final"], false], op = big && st && N(d, OPEN), el = fs.filter(f => /^(rel|user)$/.test(f.k) && f.t != d && f != pu && !bad.has(f)).map(f => { const e = R.filter(r => E(r[at(f)])); if (!e.length || e.length > R.length * 0.75) return 0; const lab = r => NAME[r[at(sb)]] || r[at(sb)], o = [f.s, e.length, ...(sb ? [T(e.map(lab))] : []), ...[...e.filter(r => !fin.has(r[si])), ...e.filter(r => fin.has(r[si]))].slice(0, 2).map(r => r.url + (sb ? " (" + lab(r) + ")" : ""))]; if (big) w.push(N(d, filled(f)).then(v => { if (v != null) o.push("all " + (n - v)); }), ...(st ? [Promise.all([op, N(d, ["q/and", OPEN, filled(f)])]).then(([a, b]) => { if (a != null && b != null) o.push("open " + (a - b)); })] : [])); return o; }).filter(Boolean);
    if (el.length) x.emptyLinks = el;
    x._iu = fs.filter(f => f.k == "user" && f != pu && !bad.has(f)).map(f => { const o = [f.s], c = ["=", [f.n, "fibery/active?"], false], q = st ? ["q/and", OPEN, c] : c; w.push(Promise.all([N(d, q), Q(d, {id: "fibery/id"}, {"q/where": q, "q/limit": 2})]).then(([k, r]) => { if (k) o.push(k, ...(r || []).map(z => z.url)); })); return o; });
    if (big) fs.forEach((f, j) => { if (!/state|formula/.test(f.k) && !bad.has(f) && R.filter(r => has(f, r[j])).length <= R.length * 0.05) w.push(N(d, filled(f)).then(v => { if (v != null) x.fields.find(o => o[0] == f.s).push("all " + v); })); });
  }
  await Promise.all(w);
  if (DATA) { const iu2 = (x._iu || []).filter(o => o.length > 1); delete x._iu; if (iu2.length) x.inactiveUsers = iu2; }
  x._t = new Set(tv.map(norm).filter(v => v.length > 2)); x._v = Object.fromEntries(fs.filter(f => f.k == "text" && f != ti && !bad.has(f)).map(f => [f.s, new Set(R.map(r => norm(r[at(f)])).filter(v => v && !/^https?:/.test(v)))]));
  return x;
}
const scope = SCOPE.length ? ALL.filter(d => SCOPE.includes(sp(d))) : ALL, todo = scope.filter(ok), mine = SCOPE.length ? SCOPE.filter(s => SP.includes(s)) : SP, tA = todo.flatMap(d => [[d, "rule"], [d, "button"]]);
const auto = async ([d, t]) => { const r = await safe(t + " " + d, query_automations({automationType: t, database: d})); ((r && r.automations) || []).forEach(a => { AUT.push([d, t, a]); size += JSON.stringify(a).length >> 1; }); }, room = () => size < 32000;
const [nF, nA] = await Promise.all([pool(todo.slice(SKIP[0]), 8, async d => { F[d] = await facts(d); if (F[d]) size += J(F[d]).length; }, room), pool(tA.slice(SKIP[1]), 24, auto, room)]);
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
ws.sameName = await Promise.all(pairs.map(async ([d, o]) => { const a = new Set(fieldsOf(d).map(f => sing(f.s))), b = fieldsOf(o).map(f => sing(f.s)).filter(z => a.has(z) && !/^(name|description)$/.test(z)); const [n, nw] = F[o] && F[o].made ? [F[o].n, F[o].made[1]] : await Promise.all([N(o), edge(o, "fibery/creation-date", "q/desc")]); return [d, o, url(o), ALL.filter(z => sp(z) == sp(o)).length + " databases in its Space", n + " records", "newest " + nw, b.length + " shared field names besides Name and Description: " + b.slice(0, 6).join(", ")]; }));
if (!SKIP.some(Boolean)) { ws.userFieldsBySpace = T(fieldsOf("fibery/user").filter(f => AS.has(f.t)).map(f => sp(f.t))); ws.noDatabases = await Promise.all(mine.filter(s => !ALL.some(d => sp(d) == s)).map(async s => { const v = await safe("views " + s, query_views({space: s, withConfig: false})); return [s, url(s), (v ? (v.views || []).length : "?") + " views and documents"]; })); }
const unk = [...new Set(AUT.flatMap(([, , a]) => JSON.stringify(a).match(UU) || []))].filter(id => !NAME[id] && !DEAD.has(id)), IV = [365, 31, 7, 1, 1 / 24];
await Promise.all([unk.length && Q("fibery/field", {id: "fibery/id", n: "fibery/name"}, {"q/where": ["q/in", ["fibery/id"], unk], "q/limit": "q/no-limit"}).then(r => (r || []).forEach(f => { if (!/_deleted$/.test(f.n)) NAME[f.id] = f.n; })), ...[...new Set(AUT.flatMap(([d]) => [d, ...fieldsOf(d).filter(f => /^rel/.test(f.k)).map(f => f.t)]))].filter(c => FL[c] && !loaded.has(c)).flatMap(c => fieldsOf(c).filter(f => /^(state|select)/.test(f.k)).map(f => ENUM(f.k == "state" ? "workflow/state_" + c : f.t))),
  AUT.some(([, , a]) => (a.actions || []).some(x => x.app && x.app != "fibery")) && safe("accounts", get_connected_app_accounts({})).then(r => ((r && r.accounts) || []).forEach(z => { ACC[z.id] = z.app + " account of " + z.name; })),
  ...AUT.map(([d, , a]) => { const c = ((a.triggers || []).find(x => x.trigger == "time-based") || {args: {}}).args.schedulerConfig, l = (a.lastRun || {}).startDate, P = {...(a.filter || {}).params}; if (!c || !a.enabled || !a.filter || (l && T0 - Date.parse(l) <= 2 * IV[c.freq] * (c.interval || 1) * D)) return; for (const k in P) if (P[k] === k) P[k] = rd(k); calls++; return query({query: {"q/from": d, "q/select": ["q/count", "fibery/id"], "q/where": where(a.filter.filterExpression)}, params: P}).then(r => { a._m = r.result; }, () => { a._m = "can't count"; }); })]);
const m = ((me && me.result) || [])[0] || {};
log(J({workspace: String(m.url).split("/")[2], user: m["user/name"], role: String(m["fibery/role"]).replace("role/", ""), spaces: SP.length, databases: ALL.length, scope: SCOPE.length ? SCOPE : "whole workspace", inScope: scope.length, data: DATA, spaceLinks: Object.fromEntries(mine.map(s => [s, url(s)])), cantRead: scope.filter(d => !ok(d)), noSuchSpace: SCOPE.filter(s => !SP.includes(s))}));
for (const d of Object.keys(F).sort()) if (F[d]) log(d + " " + J(F[d]));
log("workspace " + J(ws));
AUT.forEach(([d, t, a]) => { const g = (a.usedFields || []).filter(id => !NAME[id]).length, r = a.lastRun || {}; log("automation " + d + " " + J([t, a.name, a.enabled ? "enabled" : "DISABLED", (r.status || "?") + (r.startDate ? " " + min(r.startDate) : ""), "created " + String(a.created).slice(0, 10), (a.triggers || []).map(x => [x.trigger, un(x.args)]), un(a.filter), (a.actions || []).map(x => !x.app || x.app == "fibery" ? [x.name, un(x.args)] : [x.name, x.app, ...(x.appAccountId ? [ACC[x.appAccountId] || "an account not visible to you"] : []), un(x.args)]), ...(g ? [g + " used fields gone"] : []), ...(a._m != null ? ["records matching its filter now: " + a._m] : [])]).replace(UU, id => NAME[id] || id).split(sp(d) + "/").join("") + " " + a.url); });
const left = [todo.length - SKIP[0] - nF, tA.length - SKIP[1] - nA];
log(`${AUT.length} automations (${AUT.filter(z => z[1] == "rule").length} rules, ${AUT.filter(z => z[1] == "button").length} buttons); ${((Date.now() - T0) / 1000).toFixed(1)} s, ${calls} calls${left.some(Boolean) ? `; stopped early with ${left[0]} databases and ${left[1]} automation lists left: run this script again with SKIP = [${SKIP[0] + nF}, ${SKIP[1] + nA}]` : ""}; failed ${fails.length}${fails.length ? ": " + fails.join(" | ") : ""}`);
```
