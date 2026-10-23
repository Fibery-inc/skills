# Scripts

The templates of the build guide's scripts, under its section numbers (1 to 5, and 7 for an app), for a small hiring Space (Job, Candidate). Each data block shows one example of each kind, not how many to build. Replace the data block at the top with the spec's content, as the build guide's section of the same number says, and copy everything from `const fails` down unchanged. Every template reads what exists before it writes and logs what it found as well as what it made, so any of them runs again as it is, after a failure, a cut-off or a fix to its data.

## 1. Structure

```js
const S = "Hiring"; const f = n => `${S}/${n}`;
const C = f("Candidate"), J = f("Job");
const SPACES = [{name: S, color: "#2978FB", description: "Candidates from application to offer. Built by fibery-architect from the design Hiring pipeline, 2026-10-12."}];
const DATABASES = [
  {name: C, color: "#2978FB", description: "One record per person applying for a job."},
  {name: J, color: "#B04E31", description: "One record per open role."}
];
const PRIMITIVE = [
  {database: C, name: f("Email"), fieldType: "fibery/text", meta: {"ui/type": "email"}},
  {database: C, name: f("Salary expectation"), fieldType: "fibery/decimal", meta: {"ui/number-format": "Money", "ui/number-currency-code": "USD"}, description: "What the candidate asked for, per year"},
  {database: C, name: f("Stage changed on"), fieldType: "fibery/date", description: "Set by Stage changed when the state changes"},
  {database: C, name: f("Next interview"), fieldType: "fibery/date-time"},
  {database: J, name: f("Openings"), fieldType: "fibery/int", description: "How many people this role hires"},
  {database: J, name: f("Hiring window"), fieldType: "fibery/date-range"}
];
const SINGLE = [{database: C, name: f("Source"), defaultOption: "Website", options: [{name: "Referral", color: "#4FAF54", icon: ":handshake:"}, {name: "Job board", color: "#2978FB", icon: ":clipboard:"}, {name: "Website", color: "#99A2AB", icon: ":globe_with_meridians:"}]}];
const MULTI = [{database: C, name: f("Skills"), options: [{name: "Design", color: "#E72065"}, {name: "Engineering", color: "#2978FB"}, {name: "Sales", color: "#FBA32F"}]}];
const FILES = [{database: C, name: f("Resume"), allowMultipleFiles: false}];
const RELATIONS = [{database: C, name: f("Job"), relationDatabase: J, relationFieldName: f("Candidates"), cardinality: "many-to-one"}];
const PEOPLE = [{database: C, name: f("Recruiter"), relationFieldName: "user/Recruiting", cardinality: "many-to-many"}];
const LINKS = [];
const WORKFLOWS = [
  {database: C, defaultOption: "Applied", options: [{name: "Applied", type: "Not started", color: "#99A2AB"}, {name: "Screening", type: "Started", color: "#2978FB"}, {name: "Interview", type: "Started", color: "#673DB6"}, {name: "Offer", type: "Started", color: "#FBA32F"}, {name: "Hired", type: "Finished", color: "#4FAF54"}, {name: "Rejected", type: "Finished", color: "#D40915"}]},
  {database: J, defaultOption: "Open", options: [{name: "Open", type: "Started", color: "#2978FB"}, {name: "Filled", type: "Finished", color: "#4FAF54"}, {name: "Closed", type: "Finished", color: "#99A2AB"}]}
];
const COMMENTS = [C, J];
const ICONS = [], AVATARS = [], NO_DESCRIPTION = [];

const fails = [], made = [], t0 = Date.now();
const run = async (label, p) => { try { const r = await p; made.push(label); return r; } catch (e) { fails.push(`${label}: ${String(e.message || e).slice(0, 200)}`); return null; } };
const esc = s => s.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
const fieldsOf = async dbs => {
  const out = {}; let cur = null;
  for (const line of (await schema_detailed({databases: dbs})).schema.split("\n")) {
    const d = line.match(/^(\S[^:]*):/); if (d) { cur = d[1]; out[cur] = new Map(); continue; }
    const m = line.match(/^ {4}([^:]+): (.*)$/); if (cur && m) out[cur].set(m[1], m[2]);
  }
  return out;
};
const tree = (await schema({})).schema;
const foreign = SPACES.flatMap(sp => (tree.match(new RegExp(`^\\s*${esc(sp.name)}/[^,\\n]+(?=,)`, "gm")) || []).map(x => x.trim()).filter(n => !DATABASES.some(d => d.name === n)));
if (foreign.length) { log("STOP, a Space with this name holds other databases: " + foreign.join(", ")); throw new Error("the Space isn't this build's"); }
const newSpaces = SPACES.filter(sp => !new RegExp(`^\\s*- name: ${esc(sp.name)}$`, "m").test(tree));
const newDbs = DATABASES.filter(d => !new RegExp(`^\\s*${esc(d.name)},`, "m").test(tree));
const pre = [];
for (const sp of newSpaces) pre.push(await run("space " + sp.name, create_space(sp)));
if (newDbs.length) pre.push(await run("databases", create_databases({databases: newDbs})));
if (pre.some(r => !r)) { fails.forEach(x => log("FAIL " + x)); throw new Error("a Space or database wasn't created"); }
const moved = pre.flatMap(r => r.fixLogs || []);
if (moved.length) { log("STOP, a name went elsewhere: " + JSON.stringify(moved)); throw new Error("fixLogs on a Space or database"); }
const dbs = DATABASES.map(d => d.name), has = await fieldsOf([...dbs, "fibery/user"]);
const missing = list => list.filter(x => !has[x.database].has(x.name));
const renamed = [], people = missing(PEOPLE).map(p => {
  let inv = p.relationFieldName, n = 2;
  while (has["fibery/user"].has(inv)) inv = `${p.relationFieldName} ${n++}`;
  if (inv !== p.relationFieldName) renamed.push(`${p.relationFieldName} → ${inv}`);
  return {...p, relationDatabase: "fibery/user", relationFieldName: inv};
});
const fieldList = [PRIMITIVE, SINGLE, MULTI, FILES, RELATIONS, PEOPLE, LINKS].flat();
const before = `Spaces ${SPACES.length - newSpaces.length}, databases ${dbs.length - newDbs.length}, fields ${fieldList.length - missing(fieldList).length}, workflows ${WORKFLOWS.filter(w => has[w.database].has("workflow/state")).length}`;
const calls = [], call = (label, list, fn) => { if (list.length) calls.push([label, () => fn(list)]); };
const desc = db => `${db.split("/")[0]}/Description`;
NO_DESCRIPTION.filter(db => has[db].has(desc(db))).forEach(db => call("no description " + db, [db], () => delete_fields({fields: [{database: db, field: desc(db)}]})));
call("comments", COMMENTS.filter(db => !has[db].has("comments/comments")), l => create_comments_fields({databases: l}));
call("icons", ICONS.filter(db => !has[db].has("icon/icon")), l => create_icon_fields({databases: l}));
call("avatars", AVATARS.filter(db => !has[db].has("avatar/avatars")), l => create_avatars_fields({databases: l}));
call("primitive fields", missing(PRIMITIVE), l => create_primitive_fields({fields: l}));
call("single selects", missing(SINGLE), l => create_single_select_fields({fields: l}));
call("multi selects", missing(MULTI), l => create_multi_select_fields({fields: l}));
call("files fields", missing(FILES), l => create_files_fields({fields: l}));
call("relations", missing(RELATIONS), l => create_relation_fields({fields: l}));
call("people fields", people, l => create_relation_fields({fields: l}));
missing(LINKS).forEach(l => call("link " + l.name, [l], x => create_relation_fields({fields: x})));
WORKFLOWS.filter(w => !has[w.database].has("workflow/state")).forEach(w => call("workflow " + w.database, [w], ([x]) => create_workflow_field(x)));
const results = [];
for (const [label, go] of calls) if (Date.now() - t0 < 30000) results.push(await run(label, go()));
const left = calls.length - results.length;
const off = [];
await Promise.all([...SINGLE, ...MULTI].filter(s => s.options.some(o => o.icon)).map(s => query({query: {"q/from": `${s.name}_${s.database}`, "q/select": {n: "enum/name", i: "enum/icon"}, "q/limit": "q/no-limit"}}).then(r => r.result.forEach(x => {
  const o = s.options.find(o => o.name === x.n);
  if (o && o.icon && x.i && x.i !== `:${o.icon.replace(/:/g, "")}:`) off.push(`${s.name.split("/").pop()}.${x.n} ${o.icon} → ${x.i}`);
}), () => {})));
const fix = results.flatMap(r => (r && r.fixLogs) || []).filter(x => !/default format|Added field title/.test(x));
log(`made: ${made.join(", ") || "nothing"}; there before: ${before}`);
if (left) log(`time is up with ${left} calls left: run this script again, as it is, to finish`);
if (renamed.length) log("people fields renamed: " + renamed.join("; "));
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
const formulas = LEVELS.flat(), dbs = [...new Set(formulas.map(x => x.database))];
const fieldsOf = async () => {
  const out = {}; let cur = null;
  for (const line of (await schema_detailed({databases: dbs})).schema.split("\n")) {
    const d = line.match(/^(\S[^:]*):/); if (d) { cur = d[1]; out[cur] = new Map(); continue; }
    const m = line.match(/^ {4}([^:]+): (.*)$/); if (cur && m) out[cur].set(m[1], m[2]);
  }
  return out;
};
const has = await fieldsOf(), before = formulas.filter(x => has[x.database].has(x.name)).length;
// Four at a time, each level after the one it reads, while the next batch fits.
let left = 0, last = 15000;
for (const level of LEVELS) {
  const todo = level.filter(x => !has[x.database].has(x.name));
  for (let i = 0; i < todo.length; i += 4) {
    if (left || Date.now() - t0 + last > 35000) { left += todo.length - i; break; }
    const s0 = Date.now();
    await Promise.all(todo.slice(i, i + 4).map(x => run(x.name, create_formula_field(x))));
    last = Math.max(Date.now() - s0, 15000);
  }
}
const after = await fieldsOf();
formulas.forEach(x => { const line = after[x.database].get(x.name); log(line ? `${x.name}: ${line.replace(" # read-only; formula: ", " = ")}` : `${x.name}: missing`); });
log(`made: ${made.join(", ") || "nothing"}; formulas there before: ${before}`);
if (left) log(`time is up with ${left} calls left: run this script again, as it is, to finish`);
log(`failed ${fails.length}`); fails.forEach(x => log("FAIL " + x));
```

## 3. Views and reports

```js
const S = "Hiring"; const f = n => `${S}/${n}`;
const C = f("Candidate"), J = f("Job");
const STATES = [C, J];
const OPTIONS = [[C, "Source"]];
const VIEWS = () => [
  {viewType: "board", name: "Pipeline", description: "Where is every candidate?", config: {x: [stateAxis(C)], y: [], cardSize: "comfortable", items: [
    {database: C, fields: [fld("Name"), fld("Job"), fld("Days in stage"), fld("Recruiter")], colorCoding: [{color: "#D40915", filter: flag("Stuck")}, {color: "#FBA32F", filter: and(flag("Stuck", false), empty("reference", "Job"))}]}]}},
  {viewType: "list", name: "My candidates", description: "Who am I recruiting right now?", config: {items: [
    {database: C, fields: [fld("Name"), fld("Job"), {field: "workflow/state"}, fld("Days in stage")], filter: and(mine("Recruiter"), wf(C, "is-none-of", ["Hired", "Rejected"])), orderBy: [{field: f("Days in stage"), direction: "desc"}]}]}},
  {viewType: "grid", name: "Jobs", description: "How full is every role?", config: {rowHeight: "short", items: [
    {database: J, fields: [fld("Name"), {field: "workflow/state"}, fld("Openings"), fld("Hired"), fld("Open seats")], filter: wf(J, "is-any-of", ["Open"])},
    {database: C, fields: [fld("Name"), {field: "workflow/state"}, fld("Source")], groupBy: {parentIndex: 0, parentField: f("Candidates")}}]}},
  {viewType: "calendar", name: "Interviews", description: "Who interviews when?", config: {items: [
    {database: C, fields: [fld("Name")], startDate: f("Next interview"), endDate: f("Next interview"), filter: wf(C, "is-any-of", ["Screening", "Interview"]), colorCoding: [{color: "#4FAF54", filter: sel(C, "Source", "is-any-of", ["Referral"])}]}]}},
  {viewType: "timeline", name: "Hiring windows", description: "When should each role be filled?", config: {y: [], oneItemPerLane: false, items: [
    {database: J, fields: [fld("Name"), fld("Open seats")], startDate: f("Hiring window"), endDate: f("Hiring window"), colorCoding: byState(J, {Open: "#2978FB", Filled: "#4FAF54", Closed: "#99A2AB"})}]}},
  {viewType: "form", name: "New candidate", description: "Add someone who applied.", config: {database: C, fields: [
    {field: f("Name"), displayName: "Name", required: true}, {field: f("Email"), required: true}, fld("Job"), {field: f("Source"), defaultValue: {id: opts[C].Source.Website}}, fld("Resume")]}},
  {viewType: "document", name: "How to run hiring", description: "The process, and how this Space runs it."}
];
const REPORTS = [
  {title: "Hiring funnel", database: C, tab: {type: "stacked-bar", x: [{expression: "[State]"}], y: [{expression: "COUNT([Id])", title: "Candidates"}], color: {expression: "[Source]"}, fieldConditions: [{field: "Job", operator: "exists", value: null}], palette: "fibery2.0"}}
];

const fails = [], t0 = Date.now();
const run = async (label, p) => { try { return await p; } catch (e) { fails.push(`${label}: ${String(e.message || e).slice(0, 200)}`); return null; } };
const rows = async (from, select) => (await query({query: {"q/from": from, "q/select": select, "q/limit": "q/no-limit"}})).result;
const enumIds = async from => Object.fromEntries((await rows(from, {id: "fibery/id", n: "enum/name"})).map(r => [r.n, r.id]));
const st = {}, opts = {};
for (const db of STATES) st[db] = await enumIds(`workflow/state_${db}`);
for (const [db, field] of OPTIONS) (opts[db] = opts[db] || {})[field] = await enumIds(`${db.split("/")[0]}/${field}_${db}`);
const node = (nodeType, field, operator, value) => ({nodeType, args: value === undefined ? {fieldPath: [field], operator} : {fieldPath: [field], operator, value}});
const fld = n => ({field: f(n)});
const wf = (db, op, names) => node("workflow", "workflow/state", op, names.map(n => st[db][n]));
const sel = (db, field, op, names) => node("single-select", f(field), op, names.map(n => opts[db][field][n]));
const and = (...filters) => ({nodeType: "logical", args: {operator: "and", filters}});
const or = (...filters) => ({nodeType: "logical", args: {operator: "or", filters}});
const flag = (field, value = true) => node("bool", f(field), "is", value);
const num = (field, op, value) => node("number", f(field), op, value);
const empty = (nodeType, field, operator = "is-empty") => node(nodeType, f(field), operator);
const mine = field => node("collection", f(field), "contains-me");
const days = (field, op, amount, isBeforeNow, unit = "day") => node("date", f(field), op, {amount, unit, isBeforeNow});
const stateAxis = db => ({forDatabase: db, field: "workflow/state", database: `workflow/state_${db}`, fields: []});
const byState = (db, colors, also) => Object.entries(colors).map(([n, color]) => ({color, filter: also ? and(wf(db, "is-any-of", [n]), also) : wf(db, "is-any-of", [n])}));
const report = async ({title, database, tab, mode}, id) => {
  if (!id) { const r = await run(title, create_report({title, sources: [{database}], sourceMode: mode || "current", spaceName: S})); if (!r) return false; id = r.id; }
  const tabs = (((await run(title + " tabs", get_report({reportId: id}))) || {}).result || {}).tabs || [];
  const chart = tabs.some(t => t.title === title) || Boolean(await run(title + " chart", add_chart_tab({reportId: id, title, ...tab})));
  const blank = tabs.find(t => t.title === "Chart");
  if (chart && blank) await run(title + " default tab", remove_tab({reportId: id, tabId: blank.id}));
  return chart;
};
const views = VIEWS(), spaces = [...new Set([S, ...views.map(v => v.space).filter(Boolean)])];
const listed = async () => (await Promise.all(spaces.map(sp => query_views({space: sp, withConfig: false})))).flatMap(r => r.views);
const before = await listed(), todo = views.filter(v => !before.some(x => x.name === v.name)), made = [];
for (let i = 0; i < todo.length && Date.now() - t0 < 25000; i += 6) made.push(...await Promise.all(todo.slice(i, i + 6).map(v => run("view " + v.name, create_view({space: S, ...v})).then(r => [v, r]))));
const charts = Date.now() - t0 < 25000 ? await Promise.all(REPORTS.map(r => report(r, (before.find(x => x.viewType === "report" && x.name === r.title) || {}).id))) : [];
const all = await listed();
for (const v of views.filter(v => v.config && (v.config.items || []).some(i => i.groupBy))) {
  const x = all.find(y => y.name === v.name); if (!x) continue;
  const roots = (await query_views({id: x.id, withConfig: true})).views[0].config.items.filter((it, k) => !it.groupBy || it.groupBy.parentIndex === k).length;
  if (roots !== 1) fails.push(`view ${v.name}: ${roots} roots`);
}
const noisy = made.flatMap(([v, r]) => ((r && r.result && r.result.fixLogs) || []).filter(x => !/Added field title/.test(x)).map(x => `${v.name}: ${x}`));
const left = todo.length - made.length + (charts.length ? 0 : REPORTS.length);
log(`views: ${made.filter(([, r]) => r).length} made, ${views.length - todo.length} there before; reports: ${charts.filter(Boolean).length} of ${REPORTS.length} with their chart`);
if (left) log(`time is up with ${left} views and reports left: run this script again, as it is, to finish`);
if (noisy.length) log("fixLogs: " + JSON.stringify(noisy));
log("urls: " + JSON.stringify(Object.fromEntries(all.map(v => [v.name, v.url]))));
const mentions = await Promise.all(all.map(v => run("mention " + v.name, get_entity_mention({database: "fibery/view", entityId: v.id, label: v.name})).then(r => [v.name, r && r.mention])));
log("mentions: " + JSON.stringify(Object.fromEntries(mentions)));
for (const d of all.filter(v => v.viewType === "document")) {
  const secret = (await query_views({id: d.id, withConfig: true})).views[0].config.documentSecret, doc = String((await read_document({secret})).document || "");
  const n = Number((doc.match(/rootBlockIds\[(\d+)\]/) || [])[1] || 0), first = (doc.match(/rootBlockIds\[1\]: (\S+)/) || [])[1];
  log(`document ${d.name}: secret ${secret}, ${n === 1 && /,""|content: ""/.test(doc) ? "empty, block " + first : "has text"}`);
}
log(`failed ${fails.length}`); fails.forEach(x => log("FAIL " + x));
```

## 4. Sample records

```js
const S = "Hiring"; const f = n => `${S}/${n}`;
const C = f("Candidate"), J = f("Job");
const X = " (example)";
const day = n => new Date(Date.now() + n * 864e5).toISOString().slice(0, 10);
const RECORDS = {
  [J]: [
    {Name: "Product designer", state: "Open", Openings: 2, "Hiring window": [-30, 30], comments: ["Two seats: one senior, one mid. Portfolio review comes before the technical round."]}
  ],
  [C]: [
    {Name: "Ana Ruiz", state: "Interview", Job: "Product designer", Source: "Referral", Skills: ["Design"], Recruiter: ["me"], Email: "ana.ruiz@example.com", "Salary expectation": 95000, "Stage changed on": -3, "Next interview": [2, "14:00"],
      Description: "## Why her\nReferred by the design lead; shipped two design systems.\n\n## Concerns\nNo B2B product yet.\n\n## Next\nTechnical interview in two days."},
    {Name: "Ben Okafor", state: "Screening", Job: "Product designer", Source: "Job board", Skills: ["Design"], Recruiter: ["me"], Email: "ben.okafor@example.com", "Stage changed on": -20},
    {Name: "Chen Wei", state: "Offer", Job: "Product designer", Source: "Website", Skills: ["Design", "Engineering"], Recruiter: ["me"], Email: "chen.wei@example.com", "Stage changed on": -2, comments: [`Offer sent on ${day(-2)}; an answer is due by ${day(5)}.`]}
  ]
};
const CHECKS = [
  {label: "Offer or Hired without a job", from: C, select: {state: ["workflow/state", "enum/name"], job: [f("Job"), f("Name")]}, bad: r => ["Offer", "Hired"].includes(r.state) && !r.job},
  {label: "Hired with no skills", from: C, select: {state: ["workflow/state", "enum/name"], skills: {"q/from": f("Skills"), "q/select": {n: "enum/name"}, "q/limit": "q/no-limit"}}, bad: r => r.state === "Hired" && !r.skills.length}
];

const fails = [], filled = {}, t0 = Date.now();
const run = async (label, p) => { try { return await p; } catch (e) { fails.push(`${label}: ${String(e.message || e).slice(0, 200)}`); return null; } };
const add = (what, n = 1) => r => { if (r) filled[what] = (filled[what] || 0) + n; return r; };
const rows = async (from, select) => (await query({query: {"q/from": from, "q/select": select, "q/limit": "q/no-limit"}})).result;
const sp = db => db.split("/")[0];
const me = (await get_me({})).result[0]["fibery/id"];
const dbs = Object.keys(RECORDS), types = {};
let cur = null;
for (const line of (await schema_detailed({databases: dbs})).schema.split("\n")) {
  const d = line.match(/^(\S[^:]*):/); if (d) { cur = d[1]; types[cur] = {}; continue; }
  const m = line.match(/^ {4}([^:]+): (.+?)(?: # (.*))?$/); if (cur && m) types[cur][m[1]] = {type: m[2], many: /collection/.test(m[3] || "")};
}
const target = (db, key) => (types[db][`${sp(db)}/${key}`] || {}).type;
const kind = (db, key) => {
  if (key === "state" || key === "comments") return key;
  const t = types[db][`${sp(db)}/${key}`];
  if (!t) return "unknown";
  if (t.type === "Collaboration~Documents/Document") return "text";
  if (t.type === "fibery/file") return "file";
  if (t.type === "fibery/user") return t.many ? "people" : "person";
  if (t.type.endsWith(`_${db}`)) return t.many ? "multi" : "select";
  if (t.type.startsWith("fibery/")) return "value";
  return t.many ? "many" : "one";
};
const value = (db, key, v) => {
  const t = target(db, key), at = ([d, h]) => `${day(d)}T${h}:00.000Z`;
  if (t === "fibery/date" && typeof v === "number") return day(v);
  if (t === "fibery/date-time" && Array.isArray(v)) return at(v);
  if (t === "fibery/date-range" && Array.isArray(v)) return {start: day(v[0]), end: day(v[1] + 1)};
  if (t === "fibery/date-time-range" && Array.isArray(v)) return {start: at(v[0]), end: at(v[1])};
  return v;
};
const opt = {}, ids = {};
const options = async (db, key) => opt[db + key] = opt[db + key] || Object.fromEntries((await rows(`${sp(db)}/${key}_${db}`, {id: "fibery/id", n: "enum/name"})).map(r => [r.n, r.id]));
const byName = async db => ids[db] = Object.fromEntries((await rows(db, {id: "fibery/id", n: `${sp(db)}/Name`})).map(r => [r.n, r.id]));
for (const db of dbs) await byName(db);
const fresh = Object.fromEntries(dbs.map(db => [db, RECORDS[db].filter(r => !ids[db][r.Name + X])]));
for (const db of dbs) for (const k of new Set(RECORDS[db].flatMap(r => Object.keys(r)))) if (["select", "multi"].includes(kind(db, k))) await options(db, k);
await Promise.all(dbs.filter(db => fresh[db].length).map(db => run("create " + db, create_entities({database: db, entities: fresh[db].map(r => {
  const e = {[`${sp(db)}/Name`]: r.Name + X};
  for (const [k, v] of Object.entries(r)) {
    const kd = kind(db, k), F = `${sp(db)}/${k}`;
    if (kd === "value" && k !== "Name") e[F] = value(db, k, v);
    if (kd === "select") e[F] = opt[db + k][v];
    if (kd === "person") e[F] = v === "me" ? me : v;
  }
  return e;
})}))));
for (const db of dbs) await byName(db);
const lost = dbs.flatMap(db => fresh[db].filter(r => !ids[db][r.Name + X]).map(r => r.Name));
if (lost.length) { fails.forEach(x => log("FAIL " + x)); throw new Error("not created: " + lost.join(", ")); }
const ref = (db, key, name, who) => { const id = (ids[target(db, key)] || {})[name + X]; if (!id) fails.push(`${who}: no ${key} named ${name}`); return id; };
// A new document holds one empty paragraph: replace it, or the text opens with a blank line.
const fill = (who, secret, content) => run(who, read_document({secret})).then(d => {
  const t = String((d && d.document) || ""), n = Number((t.match(/rootBlockIds\[(\d+)\]/) || [])[1] || 0), empty = n === 1 && /,""|content: ""/.test(t) && (t.match(/rootBlockIds\[1\]: (\S+)/) || [])[1];
  if (!d || (n && !empty)) return null;
  return run(who, empty ? replace_document_blocks({secret, blocks: [{blockId: empty, content}]}) : insert_document_blocks({secret, inserts: [{parent: {blockId: null, position: "end"}, content}]})).then(add("texts"));
});
const writes = [];
for (const db of dbs) {
  const keys = [...new Set(RECORDS[db].flatMap(r => Object.keys(r)))], select = {n: `${sp(db)}/Name`};
  keys.forEach((k, i) => {
    const kd = kind(db, k), F = `${sp(db)}/${k}`;
    if (kd === "state") select.state = ["workflow/state", "enum/name"];
    if (kd === "one" || kd === "person") select[`k${i}`] = [F, "fibery/id"];
    if (kd === "many" || kd === "people" || kd === "multi") select[`k${i}`] = {"q/from": F, "q/select": {id: "fibery/id"}, "q/limit": "q/no-limit"};
    if (kd === "text") select[`k${i}`] = [F, "Collaboration~Documents/secret"];
    if (kd === "comments") select.cs = {"q/from": "comments/comments", "q/select": {id: "fibery/id"}, "q/limit": 1};
  });
  const now = Object.fromEntries((await rows(db, select)).map(r => [r.n, r])), links = [];
  for (const r of RECORDS[db]) {
    const id = ids[db][r.Name + X], has = now[r.Name + X] || {}, isNew = fresh[db].includes(r), link = {id};
    for (const [k, v] of Object.entries(r)) {
      const kd = kind(db, k), F = `${sp(db)}/${k}`, who = `${r.Name} ${k}`, got = has[`k${keys.indexOf(k)}`];
      const there = Array.isArray(got) ? got.map(x => x.id) : [];
      const items = (list, what) => { const l = list.filter(x => x && !there.includes(x)); if (l.length) writes.push(() => run(who, add_collection_items({database: db, field: F, entityId: id, items: l})).then(add(what, l.length))); };
      if (kd === "one" && !got) { const t = ref(db, k, v, who); if (t) link[F] = t; }
      if (kd === "person" && !got) link[F] = v === "me" ? me : v;
      if (kd === "state" && has.state !== v) writes.push(() => run(who, set_state({database: db, entityId: id, state: v})).then(add("states")));
      if (kd === "many") items(v.map(n => ref(db, k, n, who)), "links");
      if (kd === "people") items(v.map(n => n === "me" ? me : n), "people");
      if (kd === "multi") items(v.map(n => opt[db + k][n]), "options");
      if (kd === "text" && got) writes.push(() => fill(who, got, v));
      if (kd === "comments" && !(has.cs || []).length) v.forEach(c => writes.push(() => run(who, add_comment({database: db, entityId: id, content: c})).then(add("comments"))));
      if ((kd === "file" || kd === "unknown") && isNew) fails.push(`${who}: ${kd === "file" ? "a sample file stays empty; leave the key out" : "no such field"}`);
    }
    if (Object.keys(link).length > 1) links.push(link);
  }
  if (links.length) writes.push(() => run("links " + db, update_entities({database: db, entities: links})).then(add("links", links.length)));
}
let next = 0;
while (next < writes.length && Date.now() - t0 < 30000) { const batch = writes.slice(next, next + 20); next += batch.length; await Promise.all(batch.map(w => w())); }
for (const c of CHECKS) {
  const bad = (await rows(c.from, {n: `${sp(c.from)}/Name`, ...c.select})).filter(c.bad).map(r => r.n);
  log(`check ${c.label}: ${bad.length ? "BROKEN by " + bad.join(", ") : "holds"}`);
}
log("records: " + dbs.map(db => `${db} ${fresh[db].length} made, ${RECORDS[db].length - fresh[db].length} there before`).join("; "));
log("filled: " + (Object.entries(filled).map(([k, n]) => `${n} ${k}`).join(", ") || "nothing was missing"));
if (next < writes.length) log(`time is up with ${writes.length - next} writes left: run this script again, as it is, to finish`);
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
  {automationType: "rule", database: C, name: "Interview reminder", description: "Every day at 08:00 UTC, tells the recruiters of candidates interviewing today.",
    triggers: [{trigger: "time-based", args: {schedule: {startingFrom: tomorrowAt(8), repeatEvery: 1, settings: {unit: "day", time: {hour: 8, minute: 0}}}}}],
    filter: and(wf(C, "is-any-of", ["Screening", "Interview"]), days("Next interview", "is", 0, false)),
    actions: [{action: "Notify Recruiter", args: {subject: tpl("The words 'Interview today:' followed by the candidate's Name"), message: tpl("A short reminder that this candidate interviews today, with the Next interview time")}}]},
  {automationType: "rule", database: C, name: "Stage changed", description: "Notes the day a candidate is added and the day of every state change; Days in stage counts from it.",
    triggers: [{trigger: "created"}, {trigger: "updated", args: {updatedField: ["workflow/state"]}}],
    actions: [{action: "Update", args: {fields: [{name: f("Stage changed on"), value: formula("today")}]}}]}
];
const CHECKS = [
  {label: "Stuck while finished", from: C, select: {state: ["workflow/state", "enum/name"], stuck: f("Stuck")}, bad: r => r.stuck && ["Hired", "Rejected"].includes(r.state)},
  {label: "the story's stuck candidate shows red", from: C, select: {stuck: f("Stuck")}, bad: r => r.n === "Ben Okafor (example)" && !r.stuck}
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
const tomorrowAt = (h, m = 0) => `${new Date(Date.now() + 864e5).toISOString().slice(0, 10)}T${two(h)}:${two(m)}:00.000Z`;
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
  if (made.length && Date.now() - t0 + last > 35000) break;
  const s0 = Date.now();
  made.push(...await Promise.all(todo.slice(i, i + 4).map(a => run(a.name, create_automation(a)))));
  last = Math.max(Date.now() - s0, 15000);
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
  if (s) log(`${a.name}${todo.includes(a) ? "" : " (there before)"}: ${(s.triggers || []).map(when).join(" + ") || "button"}${s.filter ? "; if " + condition(s.filter) : ""}; ${readable((s.actions || []).map(x => [x.name, x.args]))}`.slice(0, 900));
}
for (const c of CHECKS) {
  const bad = (await rows(c.from, {n: `${c.from.split("/")[0]}/Name`, ...c.select})).filter(c.bad).map(r => r.n);
  log(`check ${c.label}: ${bad.length ? "BROKEN by " + bad.join(", ") : "holds"}`);
}
log(`automations: ${made.filter(Boolean).length} made, ${list.length - todo.length} there before`);
if (made.length < todo.length) log(`time is up with ${todo.length - made.length} automations left: run this script again, as it is, to finish`);
log(`failed ${fails.length}`); fails.forEach(x => log("FAIL " + x));
```

## 7. The app

Only when the design has an app, right after script 2. `APPS` holds `{name, kind: "view", spaceName}` for a page in the Space or `{name, kind: "layout", databaseName}` for a tab on every record page; `APP_TOUCHES` the databases and fields the app's code uses.

```js
const S = "Hiring"; const f = n => `${S}/${n}`;
const C = f("Candidate");
const APPS = [{name: "Offer desk", kind: "view", spaceName: S}];
const APP_TOUCHES = [C, [C, "workflow/state"], [C, f("Stage changed on")], [C, f("Days in stage")]];

const fails = [], made = [];
const run = async (label, p) => { try { const r = await p; made.push(label); return r; } catch (e) { fails.push(`${label}: ${String(e.message || e).slice(0, 200)}`); return null; } };
const appViews = async () => (await query_views({space: S, withConfig: false})).views.filter(v => v.viewType === "custom-app");
const viewsBefore = await appViews(), appsBefore = (await get_custom_apps_list({})).result;
for (const a of APPS.filter(a => a.kind === "view" ? !viewsBefore.some(v => v.name === a.name) : !appsBefore.some(x => x.name === a.name && x.databaseName === a.databaseName))) await run("app " + a.name, create_custom_app(a));
// A custom app id is a UUIDv7: its first 48 bits are when it was created, just before its view.
const time = id => parseInt(id.replace(/-/g, "").slice(0, 12), 16);
const appsNow = (await get_custom_apps_list({})).result, viewsNow = await appViews();
for (const a of APPS) {
  const view = viewsNow.find(v => v.name === a.name), at = view ? Date.parse(view.creationDate) + 5000 : Infinity;
  const app = (a.kind === "layout" || view) && appsNow.filter(x => x.name === a.name && x.kind === a.kind && (a.kind === "view" || x.databaseName === a.databaseName) && time(x.id) <= at).sort((p, q) => time(q.id) - time(p.id))[0];
  log(`app ${a.name}: ${app ? "id " + app.id : "not made yet"}${view ? ", " + view.url : ""}`);
}
const ids = {};
for (const db of new Set(APP_TOUCHES.map(t => [].concat(t)[0]))) {
  const t = (await query({query: {"q/from": "fibery/type", "q/select": {id: "fibery/id"}, "q/where": ["=", ["fibery/name"], db], "q/limit": 1}})).result[0];
  if (t) ids[db] = t.id;
  for (const r of (await query({query: {"q/from": "fibery/field", "q/select": {id: "fibery/id", n: "fibery/name"}, "q/where": ["=", ["fibery/holder-type", "fibery/name"], db], "q/limit": "q/no-limit"}})).result) ids[`${db}|${r.n}`] = r.id;
}
log("ids for the app: " + JSON.stringify(Object.fromEntries(APP_TOUCHES.map(t => [[].concat(t).join("|"), ids[[].concat(t).join("|")] || "not made yet"]))));
log(`made: ${made.join(", ") || "nothing"}`);
log(`failed ${fails.length}`); fails.forEach(x => log("FAIL " + x));
```
