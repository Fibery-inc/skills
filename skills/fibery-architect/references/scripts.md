# Scripts

The templates of the build guide's scripts, under its section numbers (1 to 6, and 7 for an app), for a small hiring Space (Job, Candidate). Each data block shows one example of each kind, not how many to build. Replace the data block at the top with the spec's content, as the build guide's section of the same number says, and copy everything from `const err` down unchanged. A script runs once: it makes what its data holds and logs what it made and what Fibery stored. An extension's scripts are in `extend-scripts.md` and `extend.md`. The script that removes the examples is the last one here.

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

const err = e => String(e?.message || e).slice(0, 300), run = (label, p) => p.catch(e => log(`FAIL ${label}: ${err(e)}`));
const r = await create_spaces(SCHEMA), fix = (r.fixLogs || []).filter(x => !/default format|Added field title/.test(x));
log(`made ${r.created.length}; there before ${r.unchanged.length}${r.unchanged.length ? ": " + r.unchanged.slice(0, 10).join(", ") : ""}${fix.length ? "; fixLogs " + JSON.stringify(fix) : ""}`);
const iconed = SCHEMA.spaces.flatMap(s => s.databases).filter(d => (d.fields || []).some(x => (x.options || []).some(o => o.icon)));
const guide = GUIDE && run("guide", create_view({space: S, ...GUIDE})), stored = iconed.length ? get_databases({databases: iconed.map(d => d.name)}).catch(() => "") : "";
if (DEFAULTS.length) await run("defaults", set_default_field_values({fields: DEFAULTS}));
if (NO_DESCRIPTION.length) await run("no description", delete_fields({fields: NO_DESCRIPTION.map(db => ({database: db, name: `${db.split("/")[0]}/Description`}))}));
const g = await guide, lines = String(await stored).split("\n");
if (g) log("space: " + g.result.url.replace(/\/([^/]+)\/[^/]+$/, "/fibery/space/$1"));
const off = iconed.flatMap(d => d.fields.flatMap(x => (x.options || []).filter(o => o.icon && !(lines.find(l => l.includes(`,${o.name},`)) || `"${o.icon}"`).includes(`"${o.icon}"`)).map(o => `${o.name} ${o.icon}`)));
if (off.length) log("icons stored differently, resend any that isn't the same emoji: " + off.join("; "));
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

const err = e => String(e?.message || e).slice(0, 300);
for (const level of LEVELS) (await Promise.allSettled(level.map(x => create_formula_field(x)))).forEach((o, i) => o.status === "rejected" && log(`FAIL ${level[i].name}: ${err(o.reason)}`));
const dbs = [...new Set(LEVELS.flat().map(x => x.database))], txt = Object.fromEntries(await Promise.all(dbs.map(async db => [db, String(await get_databases({databases: [db], forQuerying: true}))])));
for (const x of LEVELS.flat()) {
  const b = txt[x.database].split("- name: ").find(s => s.split("\n")[0].replace(/"/g, "") === x.name && /\n\s*formula: /.test(s)) || "", g = k => (b.match(new RegExp(`\\n\\s*${k}: (.*)`)) || [])[1];
  log(`${x.name}: ${g("resultType") || "MISSING"}${g("resultType") === "number" ? ", " + (+g("numberPrecision") ? g("numberPrecision") + " places" : "whole") : ""} = ${g("formula")}`);
}
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

const err = e => String(e?.message || e).slice(0, 300);
// Declarations, not arrows: the data above calls them before this line runs.
function node(nodeType, field, operator, value) { return {nodeType, args: {fieldPath: [field], operator, value}}; }
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
function selAxis(db, field) { return {forDatabase: db, field: f(field), database: `${f(field)}_${db}`, fields: []}; }
function byState(db, colors, also) { return Object.entries(colors).map(([n, color]) => ({color, filter: also ? and(wf(db, "is-any-of", [n]), also) : wf(db, "is-any-of", [n])})); }
const made = [];
// One at a time: a Space lists its views in the order they were made.
for (const v of VIEWS) await create_view({space: S, ...v}).then(r => made.push([v.name, r.result]), e => log(`FAIL ${v.name}: ${err(e)}`));
for (const p of REPORTS) try {
  const r = await create_report({title: p.title, sources: [p.filter ? {database: p.database, filterPrompt: p.filter} : {database: p.database}], sourceMode: p.mode || "current", spaceName: S});
  for (const t of p.tabs) await (t.metrics ? add_metric_tab : t.columns ? add_table_tab : add_chart_tab)({reportId: r.id, ...t}).catch(e => log(`FAIL ${p.title}, ${t.title}: ${err(e)}`));
  const got = (await get_report({reportId: r.id})).result, kept = got.data?.sources?.[0]?.filter;
  if (got.tabs.length > 1 && got.tabs[0].title === "Chart") await remove_tab({reportId: r.id, tabId: got.tabs[0].id});
  if (p.filter) log(`${p.title} keeps: ${kept ? JSON.stringify([kept.expression, kept.params]) : "everything"}`);
  made.push([p.title, r]);
} catch (e) { log(`FAIL ${p.title}: ${err(e)}`); }
for (const [n, r] of made) log(`${n}: ${r.url} ${await get_entity_mention({database: "fibery/view", entityId: r.id, label: n}).then(x => x.mention, err)}${(r.fixLogs || []).filter(x => !/Added field title/.test(x)).map(x => " fixLog: " + x).join("")}`);
for (const d of (await query_views({space: S, viewType: "document", withConfig: false})).views) {
  const v = (await query_views({id: d.id, withConfig: true})).views[0], secret = v.config.documentSecret;
  if (!String(v.content || "").trim()) log(`document ${d.name}: secret ${secret}, empty block ${(String((await read_document({secret})).document).match(/\n(\S+) paragraph parentId=null/) || [])[1]}`);
}
```

## 4. Sample records

```js
const S = "Hiring"; const f = n => `${S}/${n}`;
const C = f("Candidate"), J = f("Job");
const WAVES = [
  {[J]: [
    {Name: "Product designer", state: "Open", Openings: 2, "Hiring window": range(-30, 30), comments: ["Two seats: one senior, one mid. Portfolio review comes before the technical round."]}
  ]},
  {[C]: [
    {Name: "Ana Ruiz", state: "Interview", Job: ref(J, "Product designer"), Source: "Referral", Skills: ["Design"], Recruiter: ["me"], Email: "ana.ruiz@example.com", "Salary expectation": 95000, "Stage changed on": day(-3), "Next interview": at(2, "14:00"),
      Description: "## Why her\nReferred by the design lead; shipped two design systems.\n\n## Concerns\nNo B2B product yet.\n\n## Next\nTechnical interview in two days."},
    {Name: "Ben Okafor", state: "Screening", Job: ref(J, "Product designer"), Source: "Job board", Skills: ["Design"], Recruiter: ["me"], Email: "ben.okafor@example.com", "Stage changed on": day(-20)},
    {Name: "Chen Wei", state: "Offer", Job: ref(J, "Product designer"), Source: "Website", Skills: ["Design", "Engineering"], Recruiter: ["me"], Email: "chen.wei@example.com", "Stage changed on": day(-2), comments: [`Offer sent on ${day(-2)}; an answer is due by ${day(5)}.`]}
  ]}
];

const err = e => String(e?.message || e).slice(0, 300), sp = db => db.split("/")[0], X = " (example)", ids = {}, notes = [];
function day(n) { return utils.day(n); }
function at(n, hhmm) { return `${utils.day(n)}T${hhmm}:00.000Z`; }
function range(first, last) { return utils.dateRange(utils.day(first), utils.day(last)); }
function ref(db, name) { (ref.dbs = ref.dbs || new Set()).add(db); return {ref: [db, name]}; }
const me = (await get_me({})).result["fibery/id"];
// A link may name an example made before this run, so the linked databases' records are read first.
await Promise.all([...(ref.dbs || [])].map(async db => ids[db] = Object.fromEntries((await query({query: {"q/from": db, "q/select": {id: "fibery/id", n: `${sp(db)}/Name`}, "q/limit": "q/no-limit"}})).result.map(r => [r.n, r.id]))));
const val = v => v === "me" ? me : Array.isArray(v) ? v.map(val) : v && v.ref ? (ids[v.ref[0]] || {})[v.ref[1] + X] || log(`FAIL no ${v.ref[0]} named ${v.ref[1]}`) : v;
for (const wave of WAVES) await Promise.all(Object.entries(wave).map(async ([db, recs]) => {
  try {
    const r = await create_entities({database: db, entities: recs.map(({comments, ...x}) => Object.fromEntries(Object.entries(x).map(([k, v]) => [k === "state" ? "workflow/state" : `${sp(db)}/${k}`, k === "Name" ? v + X : val(v)])))});
    r.entities.forEach((e, i) => { (ids[db] = ids[db] || {})[e[`${sp(db)}/Name`]] = e["fibery/id"]; (recs[i].comments || []).forEach(content => notes.push({database: db, entityId: e["fibery/id"], content})); });
    log(`${db}: ${r.entities.length} made`);
  } catch (e) { log(`FAIL ${db}: ${err(e)}`); }
}));
const c = await Promise.allSettled(notes.map(n => add_comment(n)));
log(`comments: ${c.filter(o => o.status === "fulfilled").length} of ${c.length}`); c.forEach(o => o.reason && log("FAIL comment: " + err(o.reason)));
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

const err = e => String(e?.message || e).slice(0, 300), st = {}, two = n => String(n).padStart(2, "0");
const node = (nodeType, field, operator, value) => ({nodeType, args: {fieldPath: [field], operator, value}});
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
const tomorrowAt = (h, m = 0) => `${utils.day(1)}T${two(h)}:${two(m)}:00.000Z`;
await Promise.all(STATES.map(async db => st[db] = Object.fromEntries((await query({query: {"q/from": `workflow/state_${db}`, "q/select": {id: "fibery/id", n: "enum/name"}, "q/limit": "q/no-limit"}})).result.map(r => [r.n, r.id]))));
const names = Object.fromEntries(Object.values(st).flatMap(m => Object.entries(m).map(([n, id]) => [id, n]))), list = AUTOMATIONS();
const read = o => JSON.stringify(o).split(`${S}/`).join("").replace(/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/g, id => names[id] || id);
(await Promise.allSettled(list.map(a => create_automation(a)))).forEach((o, i) => {
  if (o.status === "rejected") return log(`FAIL ${list[i].name}: ${err(o.reason)}`);
  const a = o.value.automation;
  log(`${a.name}${a.enabled === false ? " (off)" : ""}: ${read({when: (a.triggers || []).map(t => t.args?.schedulerConfig || [t.trigger, t.args?.updatedField || t.args?.changedCollectionField].filter(Boolean)), if: a.filter && [a.filter.filterExpression, a.filter.params], do: (a.actions || []).map(x => [x.name, x.args])})}`.slice(0, 900));
  (a.actions || []).filter(x => /"type":"value","value":"[^"]*\{\{/.test(JSON.stringify(x.args?.fields || ""))).forEach(x => log(`FAIL ${a.name}, ${x.name}: a field holds {{…}} as typed; write it with formula`));
});
```

## 6. The last checks

```js
const S = "Hiring"; const f = n => `${S}/${n}`;
const C = f("Candidate");
const CHECKS = [
  {label: "Offer or Hired without a job", from: C, select: {state: ["workflow/state", "enum/name"], job: [f("Job"), f("Name")]}, bad: r => ["Offer", "Hired"].includes(r.state) && !r.job},
  {label: "Hired with no skills", from: C, select: {state: ["workflow/state", "enum/name"], skills: {"q/from": f("Skills"), "q/select": {n: "enum/name"}, "q/limit": "q/no-limit"}}, bad: r => r.state === "Hired" && !r.skills.length},
  {label: "Stuck while finished", from: C, select: {state: ["workflow/state", "enum/name"], stuck: f("Stuck")}, bad: r => r.stuck && ["Hired", "Rejected"].includes(r.state)},
  {label: "the story's stuck candidate shows red", from: C, select: {stuck: f("Stuck")}, bad: r => r.n === "Ben Okafor (example)" && !r.stuck},
  {label: "exactly one candidate has an offer", from: C, select: {state: ["workflow/state", "enum/name"]}, is: r => r.state === "Offer", count: 1}
];

const err = e => String(e?.message || e).slice(0, 300);
for (const c of CHECKS) try {
  const hit = (await query({query: {"q/from": c.from, "q/select": {n: `${c.from.split("/")[0]}/Name`, ...c.select}, "q/limit": "q/no-limit"}})).result.filter(c.is || c.bad).map(r => r.n);
  log(`check ${c.label}: ${(c.is ? hit.length !== c.count : hit.length) ? (c.is ? `BROKEN, ${hit.length} not ${c.count}: ` : "BROKEN by ") + hit.join(", ") : "holds"}`);
} catch (e) { log(`FAIL ${c.label}: ${err(e)}`); }
```

## 7. The app

Only when the design has an app, in the message with scripts 3 and 5 (build guide §7). `APPS` holds `{name, kind: "view", spaceName}` for a page in the Space or `{name, kind: "layout", databaseName}` for a tab on every record page; `APP_TOUCHES` the databases and fields the app's code uses.

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
  const mention = view && await get_entity_mention({database: "fibery/view", entityId: view.id, label: a.name}).then(r => r.mention, e => "failed: " + e.message);
  log(`app ${a.name}: ${app ? "id " + app.id : "not made yet"}${view ? `, ${view.url}, mention ${mention}` : ""}`);
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

## Removing the examples

Only when the person asks ("remove the examples"), and with no other file to read. `DATABASES` holds the full names of the Space's databases, from `design.md` or `get_spaces`; `X` is the mark script 4 put on the sample records. It deletes the records whose names end with the mark and nothing else, and logs how many went and how many stayed in each database. Then tell the person in one line, with the totals, and that Fibery's Activity tab can bring them back.

```js
const DATABASES = ["Hiring/Candidate", "Hiring/Job"];
const X = " (example)";

const fails = [];
for (const db of DATABASES) {
  try {
    const all = (await query({query: {"q/from": db, "q/select": {id: "fibery/id", n: `${db.split("/")[0]}/Name`}, "q/limit": "q/no-limit"}})).result;
    const ids = all.filter(r => String(r.n || "").endsWith(X)).map(r => r.id);
    for (let i = 0; i < ids.length; i += 100) await delete_entities({database: db, ids: ids.slice(i, i + 100)});
    log(`${db}: ${ids.length} examples removed, ${all.length - ids.length} records kept`);
  } catch (e) { fails.push(`${db}: ${String(e.message || e).slice(0, 200)}`); }
}
log(`failed ${fails.length}`); fails.forEach(x => log("FAIL " + x));
```
