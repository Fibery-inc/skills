# Build

Six `execute_code` scripts and two direct calls, in four messages, each once the one before has answered:

1. **Script 1**: the structure and the guide's empty document. Its log gives the Space's address (SKILL.md §5).
2. **Scripts 2 and 4**: formulas and sample records, two calls in one message.
3. **Scripts 3 and 5**: views and reports, rules and buttons, and the app script when there is an app (`build-reference.md`, The app).
4. **The guide's two calls and script 6**, which checks the sample story's promises.

A script with nothing in its data is not sent. The templates show one example of each kind, not how many to build.

**Every script:** replace the data block with the design's content, names spelled as the design spells them, and copy everything from `const err` down unchanged into `execute_code`; a shape a template lacks goes into the same list in the tool's shape (`build-reference.md`). It runs once and logs what it made, what Fibery stored, and `FAIL …`. Repair only what failed, with a direct call or the same script holding only what is missing, before the guide's message. Never an id from another build. A `fixLogs` line renaming a Space or database, or script 1 logging anything "there before" in a new build (a change expects it: `change.md` §3), means the name is someone else's: stop, tell the person, and with their word take a free one ("Hiring 2"). Other failures: `build-reference.md`.

## 1. Structure

One `create_spaces` call makes everything; a refused spec made nothing: fix what it lists and send it again.

| The design says | In the data |
|---|---|
| a database | `comments: true`, `icon: true`, `avatar: true` where the design has them; Name and Description come with it |
| text, number, date | `text`, `email`, `url`, `phone`, `checkbox`, `location`, `rich-text`; `number` (whole; `numberPrecision: 1`; `numberUnit` only where the number alone is ambiguous: h, min, d, wk, km, kg, GB); `numberFormat: "Money"` (USD, or `numberCurrencyCode`), `"Percent"` (a fraction); `date`, `date-time`, `date-range`, `date-time-range` |
| states | the `workflow`, never a select: the first and "(not started)" ones `Not started`, "(finished)" ones `Finished`, the rest `Started` |
| a relation | declared once, on the side the design names; `relatedField` is the inverse's full name, `cardinality` from this side |
| a person; people | a relation to `fibery/user`, inverse `user/<name>`; `many-to-many` for a role a "My …" view filters on ("contains me" needs to-many) |
| a link; files | a relation to the existing database as `get_spaces` names it; `files`, `allowMultipleFiles: false` for one |
| a default | `DEFAULTS`: a number, text, `true` or "YYYY-MM-DD"; a select's is `isDefault`; "today" goes on Your turn |

**Colors.** Each database the color its name brings to mind (an Invoice green), the main one first; no two the same or near twins (the oranges, the greens, Sky blue and Cyan, the purples, the greys); otherwise a free color, never a grey. The Space takes its first database's. Dark gray #4A4A4A, Blue-gray #6A849B, Light gray #99A2AB, Bright red #D40915, Pink #E72065, Magenta purple #9C2BAF, Deep purple #673DB6, Blue-purple #3E53B4, Bright blue #2978FB, Sky blue #199EE3, Cyan #1FBED3, Teal #159789, Green #4FAF54, Yellow-green #8EC351, Orange #FBA32F, Red-orange #FC551F, Brown-orange #B04E31.

**Emojis.** Every option gets the shortcode a person would pick (High `:fire:`); none on names (places, people) or in lists over about eight. The log names each stored differently: an alias is fine, a random one is resent (`build-reference.md`).

**Descriptions** only where the name leaves a question: a scale, a period, that a rule fills it.

```js
const S = "Hiring"; const f = n => `${S}/${n}`;
const C = f("Candidate"), J = f("Job");
const SCHEMA = {spaces: [{name: S, color: "#2978FB", databases: [
  {name: C, color: "#2978FB", description: "One record per person applying for a job.", comments: true, fields: [
    {name: f("Email"), type: "email"},
    {name: f("Salary expectation"), type: "number", numberFormat: "Money", description: "What the candidate asked for, per year"},
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
const DEFAULTS = [{database: J, name: f("Openings"), defaultValue: 1}];
const GUIDE = {viewType: "document", name: "How to run hiring", description: "The process, and how this Space runs it."};

const err = e => String(e?.message || e).slice(0, 300), run = (label, p) => p.catch(e => log(`FAIL ${label}: ${err(e)}`));
const r = await create_spaces(SCHEMA), fix = (r.fixLogs || []).filter(x => !/default format|Added field title/.test(x));
log(`made ${r.created.length}; there before ${r.unchanged.length}${r.unchanged.length ? ": " + r.unchanged.slice(0, 10).join(", ") : ""}${fix.length ? "; fixLogs " + JSON.stringify(fix) : ""}`);
const iconed = SCHEMA.spaces.flatMap(s => s.databases).filter(d => (d.fields || []).some(x => (x.options || []).some(o => o.icon)));
const guide = GUIDE && run("guide", create_view({space: S, ...GUIDE})), stored = iconed.length ? get_databases({databases: iconed.map(d => d.name)}).catch(() => "") : "";
if (DEFAULTS.length) await run("defaults", set_default_field_values({fields: DEFAULTS}));
const g = await guide, lines = String(await stored).split("\n");
if (g) log("space: " + g.result.url.replace(/\/([^/]+)\/[^/]+$/, "/fibery/space/$1"));
const off = iconed.flatMap(d => d.fields.flatMap(x => (x.options || []).filter(o => o.icon && !(lines.find(l => l.includes(`,${o.name},`)) || `"${o.icon}"`).includes(`"${o.icon}"`)).map(o => `${o.name} ${o.icon}`)));
if (off.length) log("icons stored differently, resend any that isn't the same emoji: " + off.join("; "));
```

## 2. Formulas

`LEVELS` in dependency order, a level in parallel (about 10 s); four levels or more go as two scripts. Fibery writes each formula from its `description`: one sentence naming every field exactly, ending with the result type ("The result is a whole number" / "a decimal with one decimal place" / "text" / "true or false" / "a date"). With three or more conditions, money, a division, an average or a share, or an expression in the design: "Use exactly this Fibery formula: <expression>". Syntax: `[Stage changed on]`, `If(c, a, b)`, `IsEmpty(x)`, `and`, `or`, `State.Name = "Done"`, `ToDays(a - b)`, `[Parts].Filter(…).Count()`, `.Sum([X])`, `.Max([X])`, `[Job].[Openings]`, `Greatest(a, b)`, `Dates.End()`.

- An `If` takes the type of its first branch: a whole count puts the 0 case first, as Days in stage does; swapped, or with `Round`, it is decimal. A decimal or money result writes its 0 case `0.0`. An average of whole numbers is whole and takes no `Round`.
- A percent is a whole number from 0 to 100, 0 case first, multiplied by 100 once.
- `Dates.End()` is a range's last day. A day count from a date-time says "the date part of …". There is no `Now()`. An `If` can't be blank in a branch: give it a value the view filters out.
- The description sets only the type; a decimal gets one place. Places, money or a `numberUnit` go in the entry's `format` (`{numberPrecision: 2, numberFormat: "Money", numberCurrencyCode: "EUR"}`). A whole result keeps none.

Compare each logged type, format and expression with the design. A wrong expression: `update_formula_field` with the exact formula; a wrong type: `delete_fields` and script 2 again.

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
for (const level of LEVELS) (await Promise.allSettled(level.map(({format, ...x}) => create_formula_field(x)))).forEach((o, i) => o.status === "rejected" && log(`FAIL ${level[i].name}: ${err(o.reason)}`));
const fmt = LEVELS.flat().filter(x => x.format).map(x => ({database: x.database, name: x.name, ...x.format}));
if (fmt.length) await update_fields({fields: fmt}).catch(e => log(`FAIL format: ${err(e)}`));
const dbs = [...new Set(LEVELS.flat().map(x => x.database))], txt = Object.fromEntries(await Promise.all(dbs.map(async db => [db, String(await get_databases({databases: [db], forQuerying: true}))])));
for (const x of LEVELS.flat()) {
  const b = txt[x.database].split("- name: ").find(s => s.split("\n")[0].replace(/"/g, "") === x.name && /\n\s*formula: /.test(s)) || "", g = k => (b.match(new RegExp(`\\n\\s*${k}: (.*)`)) || [])[1];
  log(`${x.name}: ${g("resultType") || "MISSING"}${g("resultType") === "number" ? ", " + (+g("numberPrecision") ? g("numberPrecision") + " places" : "whole") + (/Money|Percent/.test(g("numberFormat")) ? " " + g("numberFormat") : "") : ""} = ${g("formula")}`);
}
```

## 3. Views and reports

Views are made one at a time, in their order in the Space; then reports; the log gives each one's url and mention, and each empty document's secret and block. A view has a `description`, the question it answers, and `space` when not in the main Space.

- A grid has `rowHeight: "short"`. A list's or grid's `fields` start with the Name, then as a person reads a row: what it is part of, where it stands, who, what kind, when, how much, then contacts and text; a formula after the field it reads.
- A view shows its database's own fields only; an unknown field is dropped silently. A count of a collection: `showCount: true`. A calendar (`build-reference.md`) shows the Name only, a timeline one short field.
- Children nest through a to-many relation only. A board or timeline groups by a state, select, relation or people; a list or grid only by nesting. Cards with a picture are a gallery. Galleries, maps, timelines, self-nesting, a form's other default, a filter on one record: `build-reference.md`.
- States and options by name, case included. A shared filter is a constant (`const LATE = days("Due", "is-before", 0, true)`). Every matching color rule applies, so the one after a red one carries its opposite.
- `empty(nodeType, field)`: `reference` for a to-one, `collection` for a to-many, `text`, `date`. Dates relative to today: today `days(F, "is", 0, false)`, before today `days(F, "is-before", 0, true)`, the next 7 days `is-on-or-after` 0 and `is-on-or-before` 7 with `false`, before now on a date-time unit `"minute"`. A number: `equals`, `does-not-equal`, `greater-than`, `greater-than-or-equal`, `less-than`, `less-than-or-equal`, `is-empty`, `is-not-empty`, in a rule too.
- A report is one per database and mode. Its `filter` is a sentence naming fields exactly; check the stored one in the log (a repair: `build-reference.md`). A relative date goes in a tab's `fieldConditions`. Fields go without their Space, in square brackets in an expression (`[State]`, `COUNT([Id])`; a bare `State` fails to parse), bare as a condition's `field`; true-or-false and relations are text (`["false"]`). Other tabs: `build-reference.md`.

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
  {viewType: "form", name: "New candidate", description: "Add someone who applied.", config: {database: C, fields: [
    {field: f("Name"), displayName: "Name", required: true}, {field: f("Email"), required: true}, fld("Job"), fld("Source"), fld("Resume")]}}
];
const REPORTS = [
  {title: "Hiring numbers", database: C, filter: "only candidates that have a Job", tabs: [
    {title: "Hiring funnel", type: "stacked-bar", x: [{expression: "[State]"}], y: [{expression: "COUNT([Id])", title: "Candidates"}], color: {expression: "[Source]"}, fieldConditions: [{field: "Creation Date", operator: "range", value: "THIS YEAR"}], palette: "fibery2.0"}]}
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

From the design's sample story, a team a month in: 25 to 40 records, 8 to 15 on the main database, never past 50. The story's moments exactly as told, records in every state, two or more in every board column. Names unique in their database (links find records by name); a child's carries its parent's ("Laptop for Ana"). Invented companies, example.com emails, never a real person or record, no link to an existing database's records. Dates in days from today, over the past quarter and next month; Creation Date can't be set. One hero per main database with a Markdown Description. Every field a role always fills, filled, and every field a rule keeps (no rule runs on these records); every promise in What must stay true kept, except where the story breaks one on purpose.

`WAVES` run in order, the databases of one wave in parallel, a database after those it links to. Keys are field names without the Space: `state` and selects by name, a multi select a list, `ref(J, "Product designer")` (a list for a to-many), `"me"`, `["me"]`, `day(-3)`, `at(2, "14:00")` in UTC, `range(-30, 30)`, a date-time range `{start, end}`, Markdown for rich text, `comments`, a percent as a fraction. A location: `build-reference.md`. Files stay empty.

A `FAIL <database>` or `FAIL no …`: script 4 again with only those records.

```js
const S = "Hiring"; const f = n => `${S}/${n}`;
const C = f("Candidate"), J = f("Job");
const WAVES = [
  {[J]: [
    {Name: "Product designer", state: "Open", Openings: 2, "Hiring window": range(-30, 30), comments: ["Two seats: one senior, one mid."]}
  ]},
  {[C]: [
    {Name: "Ana Ruiz", state: "Interview", Job: ref(J, "Product designer"), Source: "Referral", Skills: ["Design"], Recruiter: ["me"], Email: "ana.ruiz@example.com", "Salary expectation": 95000, "Stage changed on": day(-3), "Next interview": at(2, "14:00"),
      Description: "## Why her\nShipped two design systems.\n\n## Next\nTechnical interview in two days."},
    {Name: "Ben Okafor", state: "Screening", Job: ref(J, "Product designer"), Source: "Job board", Recruiter: ["me"], Email: "ben.okafor@example.com", "Stage changed on": day(-20)},
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

All made at once, rules on: the records are in, and a rule fires only on what changes after it exists. The log gives each as stored; read its filter and every text and value against the design.

- **Schedules are UTC**, converted from the team's zone (08:00 Nicosia in winter is `tomorrowAt(6)`, `hour: 6`); weekly is `settings: {unit: "week", time: {hour: 6, minute: 0}, daysOfWeek: ["monday"]}`; the description gives both times, the guide the team's, and the Build notes say where clocks change.
- **Native actions only**, never `Script`. An action no native shape does (a comment on a linked record, a notification to a linked record's people, email) is left out, and the rule with it when it is the point: Not built, by hand in the guide. A rejected action fails its rule.
- **States and options by id**: `wf` and `stateValue` read them from `STATES`; an option, `build-reference.md`. A state name in a filter never matches.
- **A button** has no filter: its description and the guide say when to press it.
- **Texts and values are prompts**, naming the literal words ("The words 'Interview today:' followed by …"), the trigger record a value comes from, "using Now(), not Today()" for a date-time stamp, the language when not English.
- **`tpl` only in a comment or notification**, where Fibery fills `{{Name}}` in. In a field `{{Name}}` stays as typed, so a field's text naming a record is `formula`, as in Add Tasks Item below; a stored `{{` in a field logs FAIL.
- **`updated` names its fields**, or it fires on every edit. A rule stamping the date a day count reads also fires on `created`.
- **Actions:** "Update", "Add comment", "Notify <People field>" (`subject`, `message`), "Notify Users" (`to: {type: "formula", prompt: "the creator"}`), "Add <to-many field> Item", whose `fields` are the new linked record's: `{action: "Add Tasks Item", args: {fields: [{name: f("Name"), value: formula("the text 'Laptop for ' followed by the triggering New hire's Name")}, {name: f("Due"), value: formula("the triggering New hire's Start date minus 3 days")}, {name: f("Priority"), value: {type: "value", value: {"fibery/id": HIGH}}}, {name: f("Owner"), value: formula("the triggering New hire's Manager")}]}}`, `HIGH` from `optionId`; others in `build-reference.md`. Values: `{type: "value"}`, `formula`, `template`, `{type: "empty"}`, `{type: "user-provided-value"}` on a button.
- **Time.** A generated value (`formula`, `tpl`) takes about 6 s, an action's one after another, an exact formula too; literals and ids none. Rules are made at once, so the slowest sets the time: a rule with over six goes in with its first six values, and once script 5 has answered `update_automation({automationType, id, addActions})` adds the rest, six values per `execute_code`.
- **A wrong one:** `update_automation({automationType, id, changeActions: [{actionId, action, args}]})` in the shape `change.md` gives (`triggers`, `filter` likewise), ids from `query_automations`. Still wrong: drop it, Not built.

```js
const S = "Hiring"; const f = n => `${S}/${n}`;
const C = f("Candidate");
const STATES = [C];
const AUTOMATIONS = () => [
  {automationType: "button", database: C, name: "Make offer", description: "Press it on candidates in Interview: moves them to Offer.",
    actions: [{action: "Update", args: {fields: [{name: "workflow/state", value: stateValue(C, "Offer")}]}},
              {action: "Add comment", args: {value: tpl("A short note: an offer approved by the user who clicked the button, with today's date")}}]},
  {automationType: "rule", database: C, name: "Interview reminder", description: "Daily at 09:00 Berlin time (08:00 UTC), tells recruiters who interviews today.",
    triggers: [{trigger: "time-based", args: {schedule: {startingFrom: tomorrowAt(8), repeatEvery: 1, settings: {unit: "day", time: {hour: 8, minute: 0}}}}}],
    filter: and(wf(C, "is-any-of", ["Screening", "Interview"]), days("Next interview", "is", 0, false)),
    actions: [{action: "Notify Recruiter", args: {subject: tpl("The words 'Interview today:' followed by the candidate's Name"), message: tpl("A short reminder that this candidate interviews today, with the Next interview time")}}]},
  {automationType: "rule", database: C, name: "Stage changed", description: "Stamps the day of every state change; Days in stage counts from it.",
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
  log(`${a.name}${a.enabled === false ? " (off)" : ""}: ${read({when: (a.triggers || []).map(t => t.args?.schedulerConfig || [t.trigger, t.args?.updatedField || t.args?.changedCollectionField].filter(Boolean)), if: a.filter && [a.filter.filterExpression, a.filter.params]})}`.slice(0, 600));
  (a.actions || []).forEach(x => log(`  ${x.name}: ${read(x.args?.fields?.value || x.args)}`.slice(0, 600)));
  (a.actions || []).filter(x => /"type":"value","value":"[^"]*\{\{/.test(JSON.stringify(x.args?.fields || ""))).forEach(x => log(`FAIL ${a.name}, ${x.name}: a field holds {{…}} as typed; write it with formula`));
});
```

## 6. The guide and the last checks

**The text** is the guide the design guide describes, under 500 words; a rule not built is a step done by hand. The last line, in italics and in English: "Built by fibery-architect from the design <name>, <date>."

**Mentions.** Every view, form, report, document and app in Where to look is a mention, and elsewhere a view where it first appears in a section. Rules, fields and states stay plain words. Copy each mention whole from script 3's log (or the app script's): "open [[Pipeline#^<type id>/<view id>]]". A shortened one stays plain text; never a url.

**The calls.** `replace_document_blocks({secret, blocks: [{blockId, content}]})` with the secret and block from script 3's log and the whole text: read only that it succeeded. Then `fetch_view_data({publicId, limit: 5})` on the first view after the guide (`publicId` is its url's last part): read the cards as the person will and fix what looks wrong.

**The checks.** One per promise and per story moment a flag shows: a `select` and a `bad` test for the records that break it, or `is` and `count` for a number of records. Decimals, collections and files read back in their own shapes: `build-reference.md`. Fix what breaks with `update_entities`.

```js
const S = "Hiring"; const f = n => `${S}/${n}`;
const C = f("Candidate");
const CHECKS = [
  {label: "Offer or Hired without a job", from: C, select: {state: ["workflow/state", "enum/name"], job: [f("Job"), f("Name")]}, bad: r => ["Offer", "Hired"].includes(r.state) && !r.job},
  {label: "the story's stuck candidate shows red", from: C, select: {stuck: f("Stuck")}, bad: r => r.n === "Ben Okafor (example)" && !r.stuck},
  {label: "exactly one candidate has an offer", from: C, select: {state: ["workflow/state", "enum/name"]}, is: r => r.state === "Offer", count: 1}
];

const err = e => String(e?.message || e).slice(0, 300);
for (const c of CHECKS) try {
  const hit = (await query({query: {"q/from": c.from, "q/select": {n: `${c.from.split("/")[0]}/Name`, ...c.select}, "q/limit": "q/no-limit"}})).result.filter(c.is || c.bad).map(r => r.n);
  log(`check ${c.label}: ${(c.is ? hit.length !== c.count : hit.length) ? (c.is ? `BROKEN, ${hit.length} not ${c.count}: ` : "BROKEN by ") + hit.join(", ") : "holds"}`);
} catch (e) { log(`FAIL ${c.label}: ${err(e)}`); }
```
