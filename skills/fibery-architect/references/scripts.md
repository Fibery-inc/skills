# Scripts

The templates of the build guide's five scripts, under the same numbers, for a small hiring Space (Job, Candidate). Each data block shows one example of each kind, not how many to build. Replace the data block at the top with the spec's content, as the build guide's section of the same number says, and copy everything from `const fails = [];` down unchanged.

## 1. Structure

```js
const S = "Hiring"; const f = n => `${S}/${n}`;
const C = f("Candidate"), J = f("Job");
const SPACES = [{name: S, color: "#159789", description: "Candidates from application to offer. Built by fibery-architect from the design Hiring pipeline, 2026-10-12."}];
const DATABASES = [
  {name: C, color: "#159789", description: "One record per person applying for a job."},
  {name: J, color: "#4FAF54", description: "One record per open role."}
];
const PRIMITIVE = [
  {database: C, name: f("Email"), fieldType: "fibery/text", meta: {"ui/type": "email"}, description: "Where the recruiter writes to the candidate"},
  {database: C, name: f("Salary expectation"), fieldType: "fibery/decimal", meta: {"ui/number-format": "Money", "ui/number-currency-code": "USD"}, description: "What the candidate asked for, per year"},
  {database: C, name: f("Stage changed on"), fieldType: "fibery/date", description: "Set by Stage changed; read by Days in stage"},
  {database: C, name: f("Next interview"), fieldType: "fibery/date-time", description: "When the candidate's next interview starts"},
  {database: J, name: f("Openings"), fieldType: "fibery/int", description: "How many people this role hires"},
  {database: J, name: f("Hiring window"), fieldType: "fibery/date-range", description: "When the role should be filled"}
];
const SINGLE = [{database: C, name: f("Source"), defaultOption: "Website", options: [{name: "Referral", color: "#4FAF54"}, {name: "Job board", color: "#2978FB"}, {name: "Website", color: "#99A2AB"}]}];
const MULTI = [{database: C, name: f("Skills"), options: [{name: "Design", color: "#E72065"}, {name: "Engineering", color: "#2978FB"}, {name: "Sales", color: "#FBA32F"}]}];
const FILES = [{database: C, name: f("Resume"), allowMultipleFiles: false, description: "The CV the candidate sent"}];
const RELATIONS = [{database: C, name: f("Job"), relationDatabase: J, relationFieldName: f("Candidates"), cardinality: "many-to-one", description: "The role the candidate applied for"}];
const PEOPLE = [{database: C, name: f("Recruiter"), relationFieldName: "user/Recruiting", cardinality: "many-to-many", description: "Who runs this candidate; My candidates shows them"}];
const LINKS = [];
const WORKFLOWS = [
  {database: C, defaultOption: "Applied", options: [{name: "Applied", type: "Not started", color: "#99A2AB"}, {name: "Screening", type: "Started", color: "#2978FB"}, {name: "Interview", type: "Started", color: "#673DB6"}, {name: "Offer", type: "Started", color: "#FBA32F"}, {name: "Hired", type: "Finished", color: "#4FAF54"}, {name: "Rejected", type: "Finished", color: "#D40915"}]},
  {database: J, defaultOption: "Open", options: [{name: "Open", type: "Started", color: "#2978FB"}, {name: "Filled", type: "Finished", color: "#4FAF54"}, {name: "Closed", type: "Finished", color: "#99A2AB"}]}
];
const COMMENTS = [C, J];
const ICONS = [], AVATARS = [], NO_DESCRIPTION = [];
const APPS = [];
const APP_TOUCHES = [];

const fails = [], made = [];
const run = async (label, p) => { try { const r = await p; made.push(label); return r; } catch (e) { fails.push(`${label}: ${String(e.message || e).slice(0, 200)}`); return null; } };
const esc = s => s.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
const fieldsOf = async dbs => {
  const out = {}; let cur = null;
  for (const line of (await schema_detailed({databases: dbs})).schema.split("\n")) {
    const d = line.match(/^(\S[^:]*):/); if (d) { cur = d[1]; out[cur] = new Set(); continue; }
    const m = line.match(/^ {4}([^:]+):/); if (cur && m) out[cur].add(m[1]);
  }
  return out;
};
const tree = (await schema({})).schema;
const foreign = SPACES.flatMap(sp => (tree.match(new RegExp(`^\\s*${esc(sp.name)}/[^,\\n]+(?=,)`, "gm")) || []).map(x => x.trim()).filter(n => !DATABASES.some(d => d.name === n)));
if (foreign.length) { log("STOP, a Space with this name holds other databases: " + foreign.join(", ")); throw new Error("the Space isn't this build's"); }
const pre = [];
for (const sp of SPACES) if (!new RegExp(`^\\s*- name: ${esc(sp.name)}$`, "m").test(tree)) pre.push(await run("space " + sp.name, create_space(sp)));
const newDbs = DATABASES.filter(d => !new RegExp(`^\\s*${esc(d.name)},`, "m").test(tree));
if (newDbs.length) pre.push(await run("databases", create_databases({databases: newDbs})));
if (pre.some(r => !r)) { fails.forEach(x => log("FAIL " + x)); throw new Error("a Space or database wasn't created"); }
const moved = pre.flatMap(r => (r && r.fixLogs) || []);
if (moved.length) { log("STOP, a name went elsewhere: " + JSON.stringify(moved)); throw new Error("fixLogs on a Space or database"); }
const has = await fieldsOf([...DATABASES.map(d => d.name), "fibery/user"]);
const missing = list => list.filter(x => !has[x.database].has(x.name));
const renamed = [];
const people = missing(PEOPLE).map(p => {
  let inv = p.relationFieldName, n = 2;
  while (has["fibery/user"].has(inv)) inv = `${p.relationFieldName} ${n++}`;
  if (inv !== p.relationFieldName) renamed.push(`${p.relationFieldName} → ${inv}`);
  return {...p, relationDatabase: "fibery/user", relationFieldName: inv};
});
const apps = APPS.some(a => a.kind !== "view") ? (await get_custom_apps_list({})).result : [];
const spaceViews = APPS.some(a => a.kind === "view") ? (await query_views({space: S, withConfig: false})).views.map(v => v.name) : [];
const batch = (label, list, call) => list.length ? run(label, call(list)) : null;
const results = await Promise.all([
  ...NO_DESCRIPTION.filter(db => has[db].has(`${db.split("/")[0]}/Description`)).map(db => run("no description " + db, delete_fields({fields: [{database: db, field: `${db.split("/")[0]}/Description`}]}))),
  batch("comments", COMMENTS.filter(db => !has[db].has("comments/comments")), l => create_comments_fields({databases: l})),
  batch("icons", ICONS.filter(db => !has[db].has("icon/icon")), l => create_icon_fields({databases: l})),
  batch("avatars", AVATARS.filter(db => !has[db].has("avatar/avatars")), l => create_avatars_fields({databases: l})),
  batch("primitive fields", missing(PRIMITIVE), l => create_primitive_fields({fields: l})),
  batch("single selects", missing(SINGLE), l => create_single_select_fields({fields: l})),
  batch("multi selects", missing(MULTI), l => create_multi_select_fields({fields: l})),
  batch("files fields", missing(FILES), l => create_files_fields({fields: l})),
  batch("relations", missing(RELATIONS), l => create_relation_fields({fields: l})),
  batch("people fields", people, l => create_relation_fields({fields: l})),
  ...missing(LINKS).map(l => run("link " + l.name, create_relation_fields({fields: [l]}))),
  ...WORKFLOWS.filter(w => !has[w.database].has("workflow/state")).map(w => run("workflow " + w.database, create_workflow_field(w))),
  ...APPS.filter(a => a.kind === "view" ? !spaceViews.includes(a.name) : !apps.some(x => x.name === a.name && x.databaseName === a.databaseName)).map(a => run("app " + a.name, create_custom_app(a)).then(r => { if (r) log(`app ${a.name}: ${JSON.stringify(r).slice(0, 300)}`); return r; }))
]);
const ids = {};
for (const r of [...pre, ...results]) for (const a of (r && r.artefacts) || []) if (a.value && a.value["fibery/id"]) ids[a.value["fibery/name"]] = a.value["fibery/id"];
if (APP_TOUCHES.length) log("ids for the app: " + JSON.stringify(Object.fromEntries(APP_TOUCHES.map(n => [n, ids[n] || "look up by name"]))));
const fix = results.flatMap(r => (r && r.fixLogs) || []).filter(x => !/default format|Added field title/.test(x));
log(`made: ${made.join(", ")}`);
if (renamed.length) log("people fields renamed: " + renamed.join("; "));
if (fix.length) log("fixLogs: " + JSON.stringify(fix));
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
const APP_TOUCHES = [];

const fails = [], ids = {};
const run = async (label, p) => { try { return await p; } catch (e) { fails.push(`${label}: ${String(e.message || e).slice(0, 200)}`); return null; } };
const dbs = [...new Set(LEVELS.flat().map(x => x.database))];
const fieldsOf = async () => {
  const out = {}; let cur = null;
  for (const line of (await schema_detailed({databases: dbs})).schema.split("\n")) {
    const d = line.match(/^(\S[^:]*):/); if (d) { cur = d[1]; out[cur] = []; continue; }
    const m = line.match(/^ {4}([^:]+): (.*)$/); if (cur && m) out[cur].push([m[1], m[2]]);
  }
  return out;
};
const before = await fieldsOf();
for (const level of LEVELS) {
  const todo = level.filter(x => !before[x.database].some(([n]) => n === x.name));
  const res = await Promise.all(todo.map(x => run(x.name, create_formula_field(x))));
  for (const r of res) for (const a of (r && r.artefacts) || []) if (a.value) ids[a.value["fibery/name"]] = a.value["fibery/id"];
}
const after = await fieldsOf();
for (const x of LEVELS.flat()) {
  const line = after[x.database].find(([n]) => n === x.name);
  log(line ? `${x.name}: ${line[1].replace(" # read-only; formula: ", " = ")}` : `${x.name}: missing`);
}
if (APP_TOUCHES.length) log("ids for the app: " + JSON.stringify(Object.fromEntries(APP_TOUCHES.map(n => [n, ids[n] || "look up by name"]))));
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
    {database: C, fields: [fld("Name"), fld("Job"), fld("Recruiter"), fld("Days in stage")], colorCoding: [{color: "#D40915", filter: flag("Stuck")}, {color: "#FBA32F", filter: and(flag("Stuck", false), empty("reference", "Job"))}]}]}},
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
  {title: "Hiring funnel", database: C, tab: {type: "stacked-bar", x: [{expression: "[State]"}], y: [{expression: "COUNT([Id])", title: "Candidates"}], color: {expression: "[Source]"}, palette: "fibery2.0"}},
  {title: "Sources that convert", database: C, tab: {type: "bar", x: [{expression: "[Source]"}], y: [{expression: "COUNT([Id])", title: "Hired"}], fieldConditions: [{field: "State", operator: "is in", value: ["Hired"]}], palette: "fibery2.0"}}
];

const fails = [];
const run = async (label, p) => { try { return await p; } catch (e) { fails.push(`${label}: ${String(e.message || e).slice(0, 200)}`); return null; } };
const rows = async (from, select) => (await query({query: {"q/from": from, "q/select": select, "q/limit": "q/no-limit"}})).result;
const enumIds = async from => Object.fromEntries((await rows(from, {id: "fibery/id", n: "enum/name"})).map(r => [r.n, r.id]));
const st = {}, opts = {};
for (const db of STATES) st[db] = await enumIds(`workflow/state_${db}`);
for (const [db, field] of OPTIONS) (opts[db] = opts[db] || {})[field] = await enumIds(`${db.split("/")[0]}/${field}_${db}`);
const fld = n => ({field: f(n)});
const wf = (db, op, names) => ({nodeType: "workflow", args: {fieldPath: ["workflow/state"], operator: op, value: names.map(n => st[db][n])}});
const sel = (db, field, op, names) => ({nodeType: "single-select", args: {fieldPath: [f(field)], operator: op, value: names.map(n => opts[db][field][n])}});
const and = (...filters) => ({nodeType: "logical", args: {operator: "and", filters}});
const or = (...filters) => ({nodeType: "logical", args: {operator: "or", filters}});
const flag = (field, value = true) => ({nodeType: "bool", args: {fieldPath: [f(field)], operator: "is", value}});
const empty = (nodeType, field, operator = "is-empty") => ({nodeType, args: {fieldPath: [f(field)], operator}});
const mine = field => ({nodeType: "collection", args: {fieldPath: [f(field)], operator: "contains-me"}});
const days = (field, op, amount, isBeforeNow) => ({nodeType: "date", args: {fieldPath: [f(field)], operator: op, value: {amount, unit: "day", isBeforeNow}}});
const stateAxis = db => ({forDatabase: db, field: "workflow/state", database: `workflow/state_${db}`, fields: []});
const byState = (db, colors, also) => Object.entries(colors).map(([n, color]) => ({color, filter: also ? and(wf(db, "is-any-of", [n]), also) : wf(db, "is-any-of", [n])}));
const report = async ({title, database, tab}) => {
  const r = await run(title, create_report({title, sources: [{database}], sourceMode: "current", spaceName: S}));
  if (!r) return false;
  const chart = await run(title + " chart", add_chart_tab({reportId: r.id, title, ...tab}));
  const g = await run(title + " tabs", get_report({reportId: r.id}));
  const blank = ((g && g.result && g.result.tabs) || []).find(t => t.title === "Chart");
  if (blank) await run(title + " default tab", remove_tab({reportId: r.id, tabId: blank.id}));
  return Boolean(chart);
};
const views = VIEWS(), spaces = [...new Set([S, ...views.map(v => v.space).filter(Boolean)])];
const listed = async () => (await Promise.all(spaces.map(sp => query_views({space: sp, withConfig: false})))).flatMap(r => r.views);
const exist = (await listed()).map(v => v.name);
const todo = views.filter(v => !exist.includes(v.name)), reports = REPORTS.filter(r => !exist.includes(r.title));
const made = await Promise.all(todo.map(v => run("view " + v.name, create_view({space: S, ...v})).then(r => [v, r])));
const charts = await Promise.all(reports.map(report));
for (const [v, r] of made) {
  const items = v.config && v.config.items;
  if (!r || !items || !items.some(i => i.groupBy)) continue;
  const back = (await query_views({id: r.result.id, withConfig: true})).views[0];
  const roots = back.config.items.filter((it, k) => !it.groupBy || it.groupBy.parentIndex === k).length;
  if (roots !== 1) fails.push(`view ${v.name}: ${roots} roots`);
}
const noisy = made.flatMap(([v, r]) => ((r && r.result && r.result.fixLogs) || []).filter(x => !/Added field title/.test(x)).map(x => `${v.name}: ${x}`));
log(`views: ${made.filter(([, r]) => r).length} made; reports: ${charts.filter(Boolean).length} made; ${exist.length} there before`);
if (noisy.length) log("fixLogs: " + JSON.stringify(noisy));
const all = await listed();
log("urls: " + JSON.stringify(Object.fromEntries(all.map(v => [v.name, v.url]))));
for (const d of all.filter(v => v.viewType === "document")) {
  const c = (await query_views({id: d.id, withConfig: true})).views[0];
  log(`document ${d.name}: secret ${c.config.documentSecret}, ${String(c.content || "").trim() ? "has text" : "empty"}`);
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
    {Name: "Product designer", state: "Open", Openings: 2, "Hiring window": [-30, 30], comments: ["Two seats: one senior, one mid. Portfolio review comes before the technical round."]},
    {Name: "Sales lead", state: "Filled", Openings: 1, "Hiring window": [-90, -10]}
  ],
  [C]: [
    {Name: "Ana Ruiz", state: "Interview", Job: "Product designer", Source: "Referral", Skills: ["Design"], Recruiter: ["me"], Email: "ana.ruiz@example.com", "Salary expectation": 95000, "Stage changed on": -3, "Next interview": [2, "14:00"],
      Description: "## Why her\nReferred by the design lead; shipped two design systems.\n\n## Concerns\nNo B2B product yet.\n\n## Next\nTechnical interview in two days."},
    {Name: "Ben Okafor", state: "Screening", Job: "Product designer", Source: "Job board", Skills: ["Design"], Recruiter: ["me"], Email: "ben.okafor@example.com", "Stage changed on": -20},
    {Name: "Chen Wei", state: "Offer", Job: "Product designer", Source: "Website", Skills: ["Design", "Engineering"], Recruiter: ["me"], Email: "chen.wei@example.com", "Stage changed on": -2, comments: [`Offer sent on ${day(-2)}; an answer is due by ${day(5)}.`]},
    {Name: "Fay Moreau", state: "Hired", Job: "Sales lead", Source: "Referral", Skills: ["Sales"], Recruiter: ["me"], Email: "fay.moreau@example.com", "Stage changed on": -12}
  ]
};
const CHECKS = [
  {label: "Offer or Hired without a job", from: C, select: {state: ["workflow/state", "enum/name"], job: [f("Job"), f("Name")]}, bad: r => ["Offer", "Hired"].includes(r.state) && !r.job}
];

const fails = [];
const run = async (label, p) => { try { return await p; } catch (e) { fails.push(`${label}: ${String(e.message || e).slice(0, 200)}`); return null; } };
const rows = async (from, select) => (await query({query: {"q/from": from, "q/select": select, "q/limit": "q/no-limit"}})).result;
const sp = db => db.split("/")[0];
const me = (await get_me({})).result[0]["fibery/id"];
const dbs = Object.keys(RECORDS);
const types = {}, defaults = {}; let cur = null;
for (const line of (await schema_detailed({databases: dbs})).schema.split("\n")) {
  const d = line.match(/^(\S[^:]*):/); if (d) { cur = d[1]; types[cur] = {}; continue; }
  const m = line.match(/^ {4}([^:]+): (.+?)(?: # (.*))?$/); if (!cur || !m) continue;
  types[cur][m[1]] = {type: m[2], many: /collection/.test(m[3] || "")};
  if (m[1] === "workflow/state") defaults[cur] = ((m[3] || "").match(/default: (.+)$/) || [])[1];
}
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
const target = (db, key) => types[db][`${sp(db)}/${key}`].type;
const value = (db, key, v) => {
  const t = target(db, key);
  if (t === "fibery/date" && typeof v === "number") return day(v);
  if (t === "fibery/date-time" && Array.isArray(v)) return `${day(v[0])}T${v[1]}:00.000Z`;
  if (t === "fibery/date-range" && Array.isArray(v)) return {start: day(v[0]), end: day(v[1] + 1)};
  if (t === "fibery/date-time-range" && Array.isArray(v)) return {start: `${day(v[0][0])}T${v[0][1]}:00.000Z`, end: `${day(v[1][0])}T${v[1][1]}:00.000Z`};
  return v;
};
const opt = {};
const options = async (db, key) => opt[db + key] = opt[db + key] || Object.fromEntries((await rows(`${sp(db)}/${key}_${db}`, {id: "fibery/id", n: "enum/name"})).map(r => [r.n, r.id]));
const ids = {};
const byName = async db => ids[db] = Object.fromEntries((await rows(db, {id: "fibery/id", n: `${sp(db)}/Name`})).map(r => [r.n, r.id]));
for (const db of dbs) await byName(db);
const fresh = Object.fromEntries(dbs.map(db => [db, RECORDS[db].filter(r => !ids[db][r.Name + X])]));
for (const db of dbs) for (const r of fresh[db]) for (const [k, v] of Object.entries(r)) if (kind(db, k) === "select") await options(db, k);
await Promise.all(dbs.filter(db => fresh[db].length).map(db => run("create " + db, create_entities({database: db, entities: fresh[db].map(r => {
  const e = {[`${sp(db)}/Name`]: r.Name + X};
  for (const [k, v] of Object.entries(r)) {
    const kd = kind(db, k);
    if (kd === "value" && k !== "Name") e[`${sp(db)}/${k}`] = value(db, k, v);
    if (kd === "select") e[`${sp(db)}/${k}`] = opt[db + k][v];
    if (kd === "person") e[`${sp(db)}/${k}`] = v === "me" ? me : v;
  }
  return e;
})}))));
for (const db of dbs) await byName(db);
const lost = dbs.flatMap(db => fresh[db].filter(r => !ids[db][r.Name + X]).map(r => r.Name));
if (lost.length) { fails.forEach(x => log("FAIL " + x)); throw new Error("not created: " + lost.join(", ")); }
const ref = (db, key, name, who) => { const id = (ids[target(db, key)] || {})[name + X]; if (!id) fails.push(`${who}: no ${key} named ${name}`); return id; };
const tasks = [];
for (const db of dbs) {
  const textKeys = [...new Set(fresh[db].flatMap(r => Object.keys(r).filter(k => kind(db, k) === "text")))];
  const secrets = textKeys.length ? Object.fromEntries((await rows(db, Object.fromEntries([["n", `${sp(db)}/Name`], ...textKeys.map((k, i) => [`s${i}`, [`${sp(db)}/${k}`, "Collaboration~Documents/secret"]])]))).map(r => [r.n, r])) : {};
  const links = [];
  for (const r of fresh[db]) {
    const id = ids[db][r.Name + X], link = {id};
    for (const [k, v] of Object.entries(r)) {
      const kd = kind(db, k), F = `${sp(db)}/${k}`, who = `${r.Name} ${k}`;
      if (kd === "one") link[F] = ref(db, k, v, who);
      if (kd === "state" && v !== defaults[db]) tasks.push(run(who, set_state({database: db, entityId: id, state: v})));
      if (kd === "many") tasks.push(run(who, add_collection_items({database: db, field: F, entityId: id, items: v.map(n => ref(db, k, n, who)).filter(Boolean)})));
      if (kd === "people") tasks.push(run(who, add_collection_items({database: db, field: F, entityId: id, items: v.map(n => n === "me" ? me : n)})));
      if (kd === "multi") tasks.push(options(db, k).then(o => run(who, add_collection_items({database: db, field: F, entityId: id, items: v.map(n => o[n])}))));
      if (kd === "text") tasks.push(run(who, insert_document_blocks({secret: secrets[r.Name + X][`s${textKeys.indexOf(k)}`], inserts: [{parent: {blockId: null, position: "end"}, content: v}]})));
      if (kd === "comments") v.forEach(c => tasks.push(run(who, add_comment({database: db, entityId: id, content: c}))));
      if (kd === "file") fails.push(`${who}: files can't be attached; left empty`);
      if (kd === "unknown") fails.push(`${who}: no such field`);
    }
    if (Object.keys(link).length > 1) links.push(link);
  }
  if (links.length) tasks.push(run("links " + db, update_entities({database: db, entities: links})));
}
await Promise.all(tasks);
for (const c of CHECKS) {
  const bad = (await rows(c.from, {n: `${sp(c.from)}/Name`, ...c.select})).filter(c.bad).map(r => r.n);
  log(`check ${c.label}: ${bad.length ? "BROKEN by " + bad.join(", ") : "holds"}`);
}
log("records: " + dbs.map(db => `${db} ${fresh[db].length} made, ${RECORDS[db].length - fresh[db].length} there before`).join("; "));
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

const fails = [];
const run = async (label, p) => { try { return await p; } catch (e) { fails.push(`${label}: ${String(e.message || e).slice(0, 200)}`); return null; } };
const rows = async (from, select) => (await query({query: {"q/from": from, "q/select": select, "q/limit": "q/no-limit"}})).result;
const enumIds = async from => Object.fromEntries((await rows(from, {id: "fibery/id", n: "enum/name"})).map(r => [r.n, r.id]));
const st = {};
for (const db of STATES) st[db] = await enumIds(`workflow/state_${db}`);
const wf = (db, op, names) => ({nodeType: "workflow", args: {fieldPath: ["workflow/state"], operator: op, value: names.map(n => st[db][n])}});
const and = (...filters) => ({nodeType: "logical", args: {operator: "and", filters}});
const or = (...filters) => ({nodeType: "logical", args: {operator: "or", filters}});
const flag = (field, value = true) => ({nodeType: "bool", args: {fieldPath: [f(field)], operator: "is", value}});
const empty = (nodeType, field, operator = "is-empty") => ({nodeType, args: {fieldPath: [f(field)], operator}});
const days = (field, op, amount, isBeforeNow) => ({nodeType: "date", args: {fieldPath: [f(field)], operator: op, value: {amount, unit: "day", isBeforeNow}}});
const stateValue = (db, name) => ({type: "value", value: {"fibery/id": st[db][name]}});
const tpl = prompt => ({type: "template", prompt});
const formula = prompt => ({type: "formula", prompt});
const tomorrowAt = (h, m = 0) => `${new Date(Date.now() + 864e5).toISOString().slice(0, 10)}T${String(h).padStart(2, "0")}:${String(m).padStart(2, "0")}:00.000Z`;
const list = AUTOMATIONS();
const exist = {};
for (const a of list) {
  const key = `${a.database}|${a.automationType}`;
  if (exist[key]) continue;
  const r = await run("list " + key, query_automations({automationType: a.automationType, database: a.database}));
  if (!r) { fails.forEach(x => log("FAIL " + x)); throw new Error("can't list the automations of " + key); }
  exist[key] = r.automations.map(x => x.name);
}
const made = await Promise.all(list.filter(a => !exist[`${a.database}|${a.automationType}`].includes(a.name)).map(a => run(a.name, create_automation(a)).then(r => [a, r])));
const stored = {};
for (const key of new Set(made.filter(([, r]) => r).map(([a]) => `${a.database}|${a.automationType}`))) {
  const [database, automationType] = key.split("|");
  const back = await run("read " + key, query_automations({automationType, database}));
  for (const x of (back && back.automations) || []) stored[x.name] = x;
}
for (const [a, r] of made) if (r) {
  const s = stored[a.name] || {};
  log(`${a.name}: ${(s.triggers || []).map(t => t.trigger).join(" + ") || "button"}${s.filter ? "; if " + JSON.stringify(s.filter.filterExpression) : ""}; ${JSON.stringify(r.automation.actions.map(x => [x.name, x.args]))}`.slice(0, 900));
}
for (const c of CHECKS) {
  const bad = (await rows(c.from, {n: `${c.from.split("/")[0]}/Name`, ...c.select})).filter(c.bad).map(r => r.n);
  log(`check ${c.label}: ${bad.length ? "BROKEN by " + bad.join(", ") : "holds"}`);
}
log(`automations: ${made.filter(([, r]) => r).length} made, ${list.length - made.length} there before`);
log(`failed ${fails.length}`); fails.forEach(x => log("FAIL " + x));
```
