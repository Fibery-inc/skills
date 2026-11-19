# Extension scripts

The guarded templates of an extension's scripts 1, 2, 3, 5 and 6 (`extend.md` §3), for a small hiring Space (Job, Candidate): replace the data block at the top as the build guide's section of the same number says and copy everything from `const fails` down unchanged; each reads what exists before it writes and logs what it found as well as what it made, so it runs again as it is after a failure, a cut-off, a "time is up" or a fix to its data.

## 1. Structure

```js
const S = "Hiring"; const f = n => `${S}/${n}`;
const C = f("Candidate"), J = f("Job");
const SCHEMA = {spaces: [{name: S, color: "#2978FB", databases: [
  {name: C, color: "#2978FB", description: "One record per person applying for a job.", comments: true, fields: [
    {name: f("Email"), type: "email"},
    {name: f("Salary expectation"), type: "number", numberFormat: "Money", description: "What the candidate asked for, per year"},
    {name: f("Notice period"), type: "number", numberUnit: "wk"},
    {name: f("Stage changed on"), type: "date", description: "Set by Stage changed when the state changes"},
    {name: f("Next interview"), type: "date-time"},
    {name: f("Source"), type: "single-select", options: [{name: "Referral", color: "#4FAF54", icon: ":handshake:"}, {name: "Job board", color: "#2978FB", icon: ":clipboard:"}, {name: "Website", color: "#99A2AB", icon: ":globe_with_meridians:", isDefault: true}]},
    {name: f("Skills"), type: "multi-select", options: [{name: "Design", color: "#E72065"}, {name: "Engineering", color: "#2978FB"}, {name: "Sales", color: "#FBA32F"}]},
    {name: f("Resume"), type: "files", allowMultipleFiles: false},
    {name: f("Job"), type: "relation", relatedDatabase: J, relatedField: f("Candidates"), cardinality: "many-to-one"},
    {name: f("Recruiter"), type: "relation", relatedDatabase: "fibery/user", relatedField: "user/Recruiting", cardinality: "many-to-many"}
  ], workflow: {options: [
    {name: "Applied", type: "Not started", color: "#99A2AB"}, {name: "Screening", type: "Started", color: "#2978FB"}, {name: "Interview", type: "Started", color: "#673DB6"},
    {name: "Offer", type: "Started", color: "#FBA32F"}, {name: "Hired", type: "Finished", color: "#4FAF54"}, {name: "Rejected", type: "Finished", color: "#D40915"}
  ]}},
  {name: J, color: "#B04E31", description: "One record per open role.", comments: true, fields: [
    {name: f("Openings"), type: "number", description: "How many people this role hires"},
    {name: f("Hiring window"), type: "date-range"}
  ], workflow: {options: [{name: "Open", type: "Started", color: "#2978FB"}, {name: "Filled", type: "Finished", color: "#4FAF54"}, {name: "Closed", type: "Finished", color: "#99A2AB"}]}}
]}]};
const NO_DESCRIPTION = [];
const DEFAULTS = [{database: J, name: f("Openings"), defaultValue: 1}];
const GUIDE = {viewType: "document", name: "How to run hiring", description: "The process, and how this Space runs it."};

const fails = [], made = [];
const run = async (label, p) => { try { const r = await p; made.push(label); return r; } catch (e) { fails.push(`${label}: ${String(e.message || e).slice(0, 200)}`); return null; } };
const short = n => n.split("/").pop();
// get_spaces and get_databases answer in TOON text: read it back into the objects it encodes.
const toon = text => {
  if (typeof text !== "string") return text;
  const L = text.split("\n").filter(l => l.trim()).map(l => [l.search(/\S/), l.trim()]), H = /^("(?:[^"\\]|\\.)*"|[^:"[]*?)(?:\[#?(\d+)([\t|]?)\](?:\{(.*)\})?)?:(?: (.*))?$/;
  const val = s => (s = s.trim())[0] === '"' ? JSON.parse(s) : s === "true" ? true : s === "false" ? false : s === "null" ? null : s === "[]" ? [] : /^-?(0|[1-9]\d*)(\.\d+)?(e[+-]?\d+)?$/i.test(s) ? Number(s) : s;
  const cells = (s, dl) => { const a = []; let c = "", q = false; for (let k = 0; k < s.length; k++) { if (q && s[k] === "\\") { c += s[k] + s[++k]; continue; } if (s[k] === '"') q = !q; if (s[k] === dl && !q) { a.push(val(c)); c = ""; } else c += s[k]; } return [...a, val(c)]; };
  const key = k => k[0] === '"' ? JSON.parse(k) : k;
  let i = 0;
  const node = (m, d) => {
    if (m[2] === undefined) return m[5] !== undefined ? val(m[5]) : block(d + 2, {});
    const n = +m[2], dl = m[3] || ",", a = [];
    if (m[4] !== undefined) { const f = cells(m[4], dl); while (a.length < n) a.push(Object.fromEntries(cells(L[i++][1], dl).map((v, j) => [f[j], v]))); }
    else if (m[5]) return cells(m[5], dl);
    else while (a.length < n) { const s = L[i++][1].replace(/^-\s?/, ""), x = s.match(H); a.push(!x ? val(s) : x[1] ? block(d + 4, {[key(x[1])]: node(x, d + 4)}) : node(x, d + 2)); }
    return a;
  };
  const block = (d, o) => { while (i < L.length && L[i][0] === d) { const m = L[i++][1].match(H); o[key(m[1])] = node(m, d); } return o; };
  const o = block(0, {});
  if (i < L.length) throw new Error(`TOON not read from line ${i + 1}: ${L[i][1].slice(0, 80)}`);
  return o;
};
const read = async (dbs, forQuerying = true) => dbs.length ? toon(await get_databases({databases: dbs, forQuerying})).spaces.flatMap(s => s.databases) : [];
const fieldsOf = async dbs => Object.fromEntries((await read(dbs)).map(d => [d.name, new Set(d.fields.map(x => x.name))]));
const there = toon(await get_spaces({})).spaces, exists = db => there.some(s => s.databases.some(d => d.name === db));
const spec = Object.fromEntries(SCHEMA.spaces.flatMap(s => s.databases || []).map(d => [d.name, d])), dbs = Object.keys(spec);
// A new Space has a color and a new database a description; one without is one to extend, and must exist.
const foreign = there.filter(s => SCHEMA.spaces.some(x => x.color && x.name === s.name)).flatMap(s => s.databases.map(d => d.name)).filter(n => !dbs.includes(n));
if (foreign.length) { log("STOP, a Space with this name holds other databases: " + foreign.join(", ")); throw new Error("the Space isn't this build's"); }
const unknown = [...SCHEMA.spaces.filter(s => !s.color && !there.some(x => x.name === s.name)).map(s => s.name), ...dbs.filter(db => !spec[db].description && !exists(db))];
if (unknown.length) { log("STOP, nothing to extend named " + unknown.join(", ")); throw new Error("a Space or database to extend isn't there"); }
// create_spaces refuses the whole spec over one taken inverse, and a person's lands on every user: number those first.
const rels = dbs.flatMap(db => (spec[db].fields || []).filter(x => x.type === "relation").map(x => [db, x]));
const has = await fieldsOf([...new Set([...dbs, ...rels.map(([, x]) => x.relatedDatabase)])].filter(db => db === "fibery/user" || exists(db)));
const renamed = [];
for (const [db, x] of rels) {
  const on = has[x.relatedDatabase];
  if (!on || (has[db] && has[db].has(x.name))) continue;
  let back = x.relatedField, n = 2;
  while (on.has(back)) back = `${x.relatedField} ${n++}`;
  on.add(back);
  if (back !== x.relatedField) { renamed.push(`${short(x.name)} → ${short(back)}`); x.relatedField = back; }
}
let r;
try { r = await create_spaces(SCHEMA); } catch (e) { log("STOP, create_spaces: " + String(e.message || e)); throw new Error("the structure wasn't made"); }
if (DEFAULTS.length) try { await set_default_field_values({fields: DEFAULTS}); } catch (e) { fails.push("defaults: " + String(e.message || e).slice(0, 200)); }
// A Space lists its views in the order they were made, so the guide is made before any other.
const hasGuide = !GUIDE || (await query_views({space: S, withConfig: false})).views.some(v => v.name === GUIDE.name);
if (!hasGuide) await run("guide", create_view({space: S, ...GUIDE}));
const desc = db => `${db.split("/")[0]}/Description`, now = await fieldsOf(NO_DESCRIPTION);
for (const db of NO_DESCRIPTION.filter(db => now[db] && now[db].has(desc(db)))) await run("no description " + db, delete_fields({fields: [{database: db, name: desc(db)}]}));
const iconed = dbs.filter(db => (spec[db].fields || []).some(x => (x.options || []).some(o => o.icon)));
const off = (await read(iconed, false)).flatMap(d => d.fields.flatMap(got => {
  const want = (spec[d.name].fields || []).find(x => x.name === got.name);
  return want ? (got.options || []).map(o => [o, (want.options || []).find(w => w.name === o.name)]).filter(([o, w]) => w && w.icon && o.icon && o.icon !== `:${w.icon.replace(/:/g, "")}:`).map(([o, w]) => `${short(got.name)}.${o.name} ${w.icon} → ${o.icon}`) : [];
}));
const count = l => Object.entries((l || []).map(x => x.split(" ")[0].replace("relation", "field")).reduce((m, k) => ({...m, [k]: (m[k] || 0) + 1}), {})).map(([k, n]) => `${k} ${n}`).join(", ");
const fix = (r.fixLogs || []).filter(x => !/default format|Added field title/.test(x));
try { const v = (await query_views({space: S, withConfig: false})).views[0]; if (v) log("space: " + v.url.replace(/\/([^/]+)\/[^/]+$/, "/fibery/space/$1")); } catch (e) {}
log(`made: ${[count(r.created), ...made].filter(Boolean).join(", ") || "nothing"}; there before: ${[count(r.unchanged), GUIDE && hasGuide ? "guide" : ""].filter(Boolean).join(", ") || "nothing"}`);
if (renamed.length) log("inverse fields renamed: " + renamed.join("; "));
if (fix.length) log("fixLogs: " + JSON.stringify(fix));
if (off.length) log("icons stored differently, resend any that isn't the same emoji: " + off.join("; "));
log(`failed ${fails.length}`); fails.forEach(x => log("FAIL " + x));
```

## 2. Formulas

```js
const S = "Hiring"; const f = n => `${S}/${n}`;
const C = f("Candidate"), J = f("Job");
const LEVELS = [
  [
    {database: C, name: f("Days in stage"), description: "Use exactly this Fibery formula: If(IsEmpty([Stage changed on]), 0, ToDays(Today() - [Stage changed on])). The result is a whole number."},
    {database: J, name: f("Hired"), description: "How many of the job's Candidates have State Hired; 0 with none. The result is a whole number."}
  ],
  [
    {database: J, name: f("Open seats"), description: "Openings minus Hired, and 0 when that is below 0. The result is a whole number."},
    {database: C, name: f("Stuck"), description: "True when Days in stage is more than 14 and the State is neither Hired nor Rejected; false otherwise. The result is true or false."}
  ]
];

const fails = [], made = [], t0 = Date.now();
const run = async (label, p) => { try { const r = await p; made.push(label); return r; } catch (e) { fails.push(`${label}: ${String(e.message || e).slice(0, 200)}`); return null; } };
// get_spaces and get_databases answer in TOON text: read it back into the objects it encodes.
const toon = text => {
  if (typeof text !== "string") return text;
  const L = text.split("\n").filter(l => l.trim()).map(l => [l.search(/\S/), l.trim()]), H = /^("(?:[^"\\]|\\.)*"|[^:"[]*?)(?:\[#?(\d+)([\t|]?)\](?:\{(.*)\})?)?:(?: (.*))?$/;
  const val = s => (s = s.trim())[0] === '"' ? JSON.parse(s) : s === "true" ? true : s === "false" ? false : s === "null" ? null : s === "[]" ? [] : /^-?(0|[1-9]\d*)(\.\d+)?(e[+-]?\d+)?$/i.test(s) ? Number(s) : s;
  const cells = (s, dl) => { const a = []; let c = "", q = false; for (let k = 0; k < s.length; k++) { if (q && s[k] === "\\") { c += s[k] + s[++k]; continue; } if (s[k] === '"') q = !q; if (s[k] === dl && !q) { a.push(val(c)); c = ""; } else c += s[k]; } return [...a, val(c)]; };
  const key = k => k[0] === '"' ? JSON.parse(k) : k;
  let i = 0;
  const node = (m, d) => {
    if (m[2] === undefined) return m[5] !== undefined ? val(m[5]) : block(d + 2, {});
    const n = +m[2], dl = m[3] || ",", a = [];
    if (m[4] !== undefined) { const f = cells(m[4], dl); while (a.length < n) a.push(Object.fromEntries(cells(L[i++][1], dl).map((v, j) => [f[j], v]))); }
    else if (m[5]) return cells(m[5], dl);
    else while (a.length < n) { const s = L[i++][1].replace(/^-\s?/, ""), x = s.match(H); a.push(!x ? val(s) : x[1] ? block(d + 4, {[key(x[1])]: node(x, d + 4)}) : node(x, d + 2)); }
    return a;
  };
  const block = (d, o) => { while (i < L.length && L[i][0] === d) { const m = L[i++][1].match(H); o[key(m[1])] = node(m, d); } return o; };
  const o = block(0, {});
  if (i < L.length) throw new Error(`TOON not read from line ${i + 1}: ${L[i][1].slice(0, 80)}`);
  return o;
};
const formulas = LEVELS.flat(), dbs = [...new Set(formulas.map(x => x.database))];
const fieldsOf = async () => Object.fromEntries(toon(await get_databases({databases: dbs, forQuerying: true})).spaces.flatMap(s => s.databases).map(d => [d.name, new Map(d.fields.map(x => [x.name, x]))]));
const has = await fieldsOf(), before = formulas.filter(x => has[x.database].has(x.name)).length;
// Four at a time, each level after the one it reads, while the next batch fits.
let left = 0, last = 15000;
for (const level of LEVELS) {
  const todo = level.filter(x => !has[x.database].has(x.name));
  for (let i = 0; i < todo.length; i += 4) {
    if (left || Date.now() - t0 + last > 45000) { left += todo.length - i; break; }
    const s0 = Date.now();
    await Promise.all(todo.slice(i, i + 4).map(x => run(x.name, create_formula_field(x))));
    last = Math.max(last, Date.now() - s0);
  }
}
const after = await fieldsOf();
const typed = x => x.resultType === "number" ? `number, ${x.numberPrecision ? x.numberPrecision + " places" : "whole"}` : x.resultType;
formulas.forEach(x => { const t = after[x.database].get(x.name); log(t ? `${x.name}: ${typed(t)} = ${t.formula}` : `${x.name}: missing`); });
log(`made: ${made.join(", ") || "nothing"}; formulas there before: ${before}`);
if (left) log(`time is up with ${left} calls left: run this script again, as it is, to finish`);
log(`failed ${fails.length}`); fails.forEach(x => log("FAIL " + x));
```

## 3. Views and reports

```js
const S = "Hiring"; const f = n => `${S}/${n}`;
const C = f("Candidate"), J = f("Job");
const VIEWS = [
  {viewType: "board", name: "Pipeline", description: "Where is every candidate?", config: {x: [stateAxis(C)], y: [], cardSize: "comfortable", items: [
    {database: C, fields: [fld("Name"), fld("Job"), fld("Days in stage"), fld("Recruiter")], colorCoding: [{color: "#D40915", filter: flag("Stuck")}, {color: "#FBA32F", filter: and(flag("Stuck", false), empty("reference", "Job"))}]}]}},
  {viewType: "list", name: "My candidates", description: "Who am I recruiting right now?", config: {items: [
    {database: C, fields: [fld("Name"), fld("Job"), {field: "workflow/state"}, fld("Days in stage")], filter: and(mine("Recruiter"), wf(C, "is-none-of", ["Hired", "Rejected"])), orderBy: [{field: f("Days in stage"), direction: "desc"}]}]}},
  {viewType: "list", name: "Jobs", description: "How full is every role?", config: {items: [
    {database: J, fields: [fld("Name"), {field: "workflow/state"}, fld("Openings"), fld("Hired"), fld("Open seats")], filter: wf(J, "is-any-of", ["Open"])},
    {database: C, fields: [fld("Name"), {field: "workflow/state"}, fld("Source")], groupBy: {parentIndex: 0, parentField: f("Candidates")}}]}},
  {viewType: "calendar", name: "Interviews", description: "Who interviews when?", config: {items: [
    {database: C, fields: [fld("Name")], startDate: f("Next interview"), endDate: f("Next interview"), filter: wf(C, "is-any-of", ["Screening", "Interview"]), colorCoding: [{color: "#4FAF54", filter: sel(C, "Source", "is-any-of", ["Referral"])}]}]}},
  {viewType: "timeline", name: "Hiring windows", description: "When should each role be filled?", config: {y: [], oneItemPerLane: false, items: [
    {database: J, fields: [fld("Name"), fld("Open seats")], startDate: f("Hiring window"), endDate: f("Hiring window"), colorCoding: byState(J, {Open: "#2978FB", Filled: "#4FAF54", Closed: "#99A2AB"})}]}},
  {viewType: "form", name: "New candidate", description: "Add someone who applied.", config: {database: C, fields: [
    {field: f("Name"), displayName: "Name", required: true}, {field: f("Email"), required: true}, fld("Job"), fld("Source"), fld("Resume")]}}
];
const REPORTS = [
  {title: "Hiring numbers", database: C, filter: "only candidates that have a Job", tabs: [
    {title: "Hiring funnel", type: "stacked-bar", x: [{expression: "[State]"}], y: [{expression: "COUNT([Id])", title: "Candidates"}], color: {expression: "[Source]"}, fieldConditions: [{field: "Creation Date", operator: "range", value: "THIS YEAR"}], palette: "fibery2.0"},
    {title: "Sources that convert", type: "stacked-bar", x: [{expression: "[Source]"}], y: [{expression: "COUNT([Id])", title: "Candidates"}], color: {expression: "[State]"}, palette: "fibery2.0"}]}
];

const fails = [], t0 = Date.now();
const run = async (label, p) => { try { return await p; } catch (e) { fails.push(`${label}: ${String(e.message || e).slice(0, 200)}`); return null; } };
// Declarations, not arrows: the data above calls them before this line runs. A view takes state and option names.
function node(nodeType, field, operator, value) { return {nodeType, args: value === undefined ? {fieldPath: [field], operator} : {fieldPath: [field], operator, value}}; }
function fld(n) { return {field: f(n)}; }
function wf(db, op, names) { return node("workflow", "workflow/state", op, names); }
function sel(db, field, op, names) { return node("single-select", f(field), op, names); }
function and(...filters) { return {nodeType: "logical", args: {operator: "and", filters}}; }
function or(...filters) { return {nodeType: "logical", args: {operator: "or", filters}}; }
function flag(field, value = true) { return node("bool", f(field), "is", value); }
function num(field, op, value) { return node("number", f(field), op, value); }
function empty(nodeType, field, operator = "is-empty") { return node(nodeType, f(field), operator); }
function mine(field) { return node("collection", f(field), "contains-me"); }
function days(field, op, amount, isBeforeNow, unit = "day") { return node("date", f(field), op, {amount, unit, isBeforeNow}); }
function stateAxis(db) { return {forDatabase: db, field: "workflow/state", database: `workflow/state_${db}`, fields: []}; }
function byState(db, colors, also) { return Object.entries(colors).map(([n, color]) => ({color, filter: also ? and(wf(db, "is-any-of", [n]), also) : wf(db, "is-any-of", [n])})); }
const report = async ({title, database, filter, tabs, mode}, id) => {
  if (!id) { const r = await run(title, create_report({title, sources: [filter ? {database, filterPrompt: filter} : {database}], sourceMode: mode || "current", spaceName: S})); if (!r) return 0; id = r.id; }
  const got = ((await run(title + " not read, left as it is", get_report({reportId: id}))) || {}).result;
  if (!got) return 0;
  const have = got.tabs || [];
  if (filter) { const kept = ((got.data || {}).sources || [{}])[0].filter; log(`${title} keeps: ${kept ? JSON.stringify([kept.expression, kept.params]) : "everything"}`); }
  let done = 0;
  for (const t of tabs) if (have.some(h => h.title === t.title) || await run(`${title}: ${t.title}`, (t.metrics ? add_metric_tab : t.columns ? add_table_tab : add_chart_tab)({reportId: id, ...t}))) done++;
  const blank = have.find(t => t.title === "Chart");
  if (done && blank) await run(title + " default tab", remove_tab({reportId: id, tabId: blank.id}));
  return done;
};
const spaces = [...new Set([S, ...VIEWS.map(v => v.space).filter(Boolean)])];
const listed = async () => (await Promise.all(spaces.map(sp => query_views({space: sp, withConfig: false})))).flatMap(r => r.views);
const before = await listed(), todo = VIEWS.filter(v => !before.some(x => x.name === v.name)), made = [];
let slow = 5000;
for (let i = 0; i < todo.length && Date.now() - t0 + slow < 45000; i += 6) { const s0 = Date.now(); made.push(...await Promise.all(todo.slice(i, i + 6).map(v => run("view " + v.name, create_view({space: S, ...v})).then(r => [v, r])))); slow = Math.max(slow, Date.now() - s0); }
const charts = Date.now() - t0 + slow < 45000 ? await Promise.all(REPORTS.map(r => report(r, (before.find(x => x.viewType === "report" && x.name === r.title) || {}).id))) : [];
const all = await listed();
for (const v of VIEWS.filter(v => v.config && (v.config.items || []).some(i => i.groupBy))) {
  const x = all.find(y => y.name === v.name); if (!x) continue;
  const roots = (await query_views({id: x.id, withConfig: true})).views[0].config.items.filter((it, k) => !it.groupBy || it.groupBy.parentIndex === k).length;
  if (roots !== 1) fails.push(`view ${v.name}: ${roots} roots`);
}
const noisy = made.flatMap(([v, r]) => ((r && r.result && r.result.fixLogs) || []).filter(x => !/Added field title/.test(x)).map(x => `${v.name}: ${x}`));
const left = todo.length - made.length + (charts.length ? 0 : REPORTS.length);
log(`views: ${made.filter(([, r]) => r).length} made, ${VIEWS.length - todo.length} there before; reports: ${charts.filter(Boolean).length} of ${REPORTS.length}, ${charts.reduce((a, b) => a + b, 0)} of ${REPORTS.reduce((a, r) => a + r.tabs.length, 0)} tabs`);
if (left) log(`time is up with ${left} views and reports left: run this script again, as it is, to finish`);
if (noisy.length) log("fixLogs: " + JSON.stringify(noisy));
log("urls: " + JSON.stringify(Object.fromEntries(all.map(v => [v.name, v.url]))));
const mentions = await Promise.all(all.map(v => run("mention " + v.name, get_entity_mention({database: "fibery/view", entityId: v.id, label: v.name})).then(r => [v.name, r && r.mention])));
log("mentions: " + JSON.stringify(Object.fromEntries(mentions)));
for (const d of all.filter(v => v.viewType === "document")) {
  const v = (await query_views({id: d.id, withConfig: true})).views[0], secret = v.config.documentSecret;
  // An empty document is one empty paragraph: "version: 0\n<id> paragraph parentId=null | ".
  const block = !String(v.content || "").trim() && (String((await read_document({secret})).document || "").match(/^version: \d+\n(\S+) paragraph parentId=null \| ?$/) || [])[1];
  log(`document ${d.name}: secret ${secret}, ${block ? "empty, block " + block : "has text"}`);
}
log(`failed ${fails.length}`); fails.forEach(x => log("FAIL " + x));
```

## 5. Rules and buttons

```js
const S = "Hiring"; const f = n => `${S}/${n}`;
const C = f("Candidate");
const STATES = [C];
const AUTOMATIONS = () => [
  {automationType: "button", database: C, name: "Make offer", description: "Moves the candidate to Offer and notes who approved it. Press it on candidates in Interview.",
    actions: [{action: "Update", args: {fields: [{name: "workflow/state", value: stateValue(C, "Offer")}]}},
              {action: "Add comment", args: {value: tpl("A short note: an offer approved by the user who clicked the button, with today's date")}}]},
  {automationType: "rule", database: C, name: "Interview reminder", description: "Every day at 09:00 Berlin time (08:00 UTC), tells the recruiters of candidates interviewing today.",
    triggers: [{trigger: "time-based", args: {schedule: {startingFrom: tomorrowAt(8), repeatEvery: 1, settings: {unit: "day", time: {hour: 8, minute: 0}}}}}],
    filter: and(wf(C, "is-any-of", ["Screening", "Interview"]), days("Next interview", "is", 0, false)),
    actions: [{action: "Notify Recruiter", args: {subject: tpl("The words 'Interview today:' followed by the candidate's Name"), message: tpl("A short reminder that this candidate interviews today, with the Next interview time")}}]},
  {automationType: "rule", database: C, name: "Stage changed", description: "Notes the day a candidate is added and the day of every state change; Days in stage counts from it.",
    triggers: [{trigger: "created"}, {trigger: "updated", args: {updatedField: ["workflow/state"]}}],
    actions: [{action: "Update", args: {fields: [{name: f("Stage changed on"), value: formula("today")}]}}]}
];

const fails = [], t0 = Date.now();
const run = async (label, p) => { try { return await p; } catch (e) { fails.push(`${label}: ${String(e.message || e).slice(0, 200)}`); return null; } };
const rows = async (from, select) => (await query({query: {"q/from": from, "q/select": select, "q/limit": "q/no-limit"}})).result;
const enumIds = async from => Object.fromEntries((await rows(from, {id: "fibery/id", n: "enum/name"})).map(r => [r.n, r.id]));
const st = {};
for (const db of STATES) st[db] = await enumIds(`workflow/state_${db}`);
const node = (nodeType, field, operator, value) => ({nodeType, args: value === undefined ? {fieldPath: [field], operator} : {fieldPath: [field], operator, value}});
const wf = (db, op, names) => node("workflow", "workflow/state", op, names.map(n => st[db][n]));
const and = (...filters) => ({nodeType: "logical", args: {operator: "and", filters}});
const or = (...filters) => ({nodeType: "logical", args: {operator: "or", filters}});
const flag = (field, value = true) => node("bool", f(field), "is", value);
const num = (field, op, value) => node("number", f(field), op, value);
const empty = (nodeType, field, operator = "is-empty") => node(nodeType, f(field), operator);
const days = (field, op, amount, isBeforeNow, unit = "day") => node("date", f(field), op, {amount, unit, isBeforeNow});
const stateValue = (db, name) => ({type: "value", value: {"fibery/id": st[db][name]}});
const tpl = prompt => ({type: "template", prompt});
const formula = prompt => ({type: "formula", prompt});
const two = n => String(n).padStart(2, "0");
const tomorrowAt = (h, m = 0) => `${utils.day(1)}T${two(h)}:${two(m)}:00.000Z`;
const list = AUTOMATIONS(), keys = [...new Set(list.map(a => `${a.database}|${a.automationType}`))];
const key = a => `${a.database}|${a.automationType}|${a.name}`;
const read = async () => {
  const out = {};
  for (const k of keys) {
    const [database, automationType] = k.split("|");
    const r = await run("list " + k, query_automations({automationType, database}));
    if (!r) { fails.forEach(x => log("FAIL " + x)); throw new Error("can't list the automations of " + k); }
    for (const x of r.automations) out[`${k}|${x.name}`] = x;
  }
  return out;
};
const before = await read(), todo = list.filter(a => !before[key(a)]), made = [];
for (let i = 0, last = 15000; i < todo.length; i += 4) {
  if (made.length && Date.now() - t0 + last > 45000) break;
  const s0 = Date.now();
  // A rule starts off, so none fires on a sample record still being written or fixed; script 6 turns them on.
  made.push(...await Promise.all(todo.slice(i, i + 4).map(a => run(a.name, create_automation(a)).then(r => r && a.automationType === "rule" ? run(a.name + " off", update_automation({automationType: "rule", id: r.automation.id, enabled: false})).then(() => r) : r))));
  last = Math.max(last, Date.now() - s0);
}
const stored = made.length ? await read() : before;
const names = Object.fromEntries(Object.values(st).flatMap(m => Object.entries(m).map(([n, id]) => [id, n])));
const readable = o => JSON.stringify(o).replace(/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/g, id => names[id] || id);
const condition = fl => readable(fl.filterExpression).replace(/"(\$where\d+)"/g, (m, p) => readable((fl.params || {})[p] || p));
const when = t => {
  const c = (t.args && t.args.schedulerConfig) || {}, on = t.args && (t.args.updatedField || t.args.changedCollectionField);
  if (t.trigger !== "time-based") return t.trigger + (on ? ` (${[].concat(on).join(", ")})` : "");
  const wd = (c.byweekday || []).map(d => ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"][d]).join(", ");
  return `${["yearly", "monthly", "weekly", "daily", "hourly"][c.freq] || "every"}${wd ? " on " + wd : ""} at ${two(c.byhour)}:${two(c.byminute || 0)} UTC from ${String(c.dtstart).slice(0, 10)}`;
};
for (const a of list) {
  const s = stored[key(a)];
  if (s) log(`${a.name}${todo.includes(a) ? "" : " (there before)"}${s.enabled === false ? " (off)" : ""}: ${(s.triggers || []).map(when).join(" + ") || "button"}${s.filter ? "; if " + condition(s.filter) : ""}; ${readable((s.actions || []).map(x => [x.name, x.args]))}`.slice(0, 900));
}
log(`automations: ${made.filter(Boolean).length} made, ${list.length - todo.length} there before`);
if (made.length < todo.length) log(`time is up with ${todo.length - made.length} automations left: run this script again, as it is, to finish`);
log(`failed ${fails.length}`); fails.forEach(x => log("FAIL " + x));
```

## 6. The last checks and the rules on

```js
const S = "Hiring"; const f = n => `${S}/${n}`;
const C = f("Candidate");
const CHECKS = [
  {label: "Stuck while finished", from: C, select: {state: ["workflow/state", "enum/name"], stuck: f("Stuck")}, bad: r => r.stuck && ["Hired", "Rejected"].includes(r.state)},
  {label: "the story's stuck candidate shows red", from: C, select: {stuck: f("Stuck")}, bad: r => r.n === "Ben Okafor (example)" && !r.stuck}
];
const RULES = [C];

const fails = [];
for (const c of CHECKS) {
  try {
    const bad = (await query({query: {"q/from": c.from, "q/select": {n: `${c.from.split("/")[0]}/Name`, ...c.select}, "q/limit": "q/no-limit"}})).result.filter(c.bad).map(r => r.n);
    log(`check ${c.label}: ${bad.length ? "BROKEN by " + bad.join(", ") : "holds"}`);
  } catch (e) { fails.push(`${c.label}: ${String(e.message || e).slice(0, 200)}`); }
}
const on = [];
for (const r of RULES) for (const x of (await query_automations({automationType: "rule", database: r.database || r})).automations.filter(x => !x.enabled && (!r.names || r.names.includes(x.name)))) {
  try { await update_automation({automationType: "rule", id: x.id, enabled: true}); on.push(x.name); } catch (e) { fails.push(`${x.name} on: ${String(e.message || e).slice(0, 200)}`); }
}
log(`rules turned on: ${on.join(", ") || "none was off"}`);
log(`failed ${fails.length}`); fails.forEach(x => log("FAIL " + x));
```
