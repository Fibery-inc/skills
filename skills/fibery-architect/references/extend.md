# Extending a Space the team runs

When the person wants a Space they already run changed, not a new one: a process added to it ("add interviews to our Hiring space"), fields, states, options, views or rules added to its databases, or a part of it rebuilt ("turn Status into a workflow", "Company should link to our customers"). People work in that Space, so nothing in it changes before the person has seen the exact list of changes and said yes. Whatever this file doesn't say works as in a new build, by the build guide and `scripts.md`.

## What an extension does

- **Adds** databases, to the Space or to a new Space beside it for a process of its own; fields, formulas, states and options; views and reports; rules and buttons; an app; and a guide for a new process.
- **Changes**, each on the list the person approves: a database, field, option or state renamed; an option's or state's color, emoji, order or default; an existing view's fields, filters, sorts and colors; a formula; a rule's or button's triggers, filter and actions.
- **Replaces a field** the team has outgrown, losing nothing: a new field beside it, its values copied, what used it (views, formulas, rules, buttons) moved to the new one, and the old one renamed "<name> (old)" for the person to delete once they've checked. That's how a status select becomes a workflow, a typed name becomes a link to the workspace's records or a person, and a select becomes a multi select.
- **Never** deletes anything (a field, option, state, view, rule, record or database), merges two into one, changes a field's type in place, adds sample records or changes a value a record already has. It doesn't edit the team's documents, reports or apps either: the report says which of them still use an old field.

A recipe describes a whole Space, so none is mapped onto a Space that exists: a process added to a Space is designed from the process, as the design guide says, its databases new and linked to the Space's own.

## 1. Read

Before any question, read this file, the build guide, `scripts.md` and `existing-space.md` in one message (for a process added to the Space, the design guide too), then run the read script from `existing-space.md` on the Space, with `TOUCH` holding every field the request renames, replaces or changes the options or states of (`"workflow/state"` for the states). The list (§2) is written from the read's log: what exists and in what order, how each touched field is filled and what its values match, and what uses it, since everything that uses a replaced field moves with it. What to link outside the Space: SKILL.md §2.

## 2. The list

Ask only what changes what gets built (SKILL.md §3): often nothing, since "turn Status into a workflow" says it all. Then write the list at the top of `design.md`, under the Assumptions, with the spec of any new database below it as the design guide writes one. New names follow the case of the names around them (SKILL.md §2), and a new field's or view's name must be free in its database or Space.

The list is in the person's words, a line per change, in four groups, leaving out a group with nothing in it:

- **Adds**: a new database, what one record is and its fields in a few words; a new field and its type; states in order; a view and the question it answers; a rule, when and what it does.
- **Changes**: before → after.
- **Moves**: per replaced field, the new field; how many records get a value, by value; the values that match nothing, which stay empty unless the person asks for records to be created for them; what moves to the new field; the old field's new name.
- **What the team will notice**, each only when it applies: integrations, scripts and API calls that use a renamed database, field, option or state by name stop working, while Fibery's own views, formulas and rules follow; while a workflow is added and its values copied, a minute or so, every record shows the first state; every record a copy writes to shows as changed by the person today; records created in a database run its rules on creation, named; a people field adds a field to every person in the workspace; a new field starts empty on existing records, and a formula reading it shows its empty case until it fills; an edited view loses what the read doesn't return, a board's card size; a report, app or document still uses an old field.

Example, from the read of a Hiring Space a team built by hand:

> **Changes to Hiring**
>
> **Adds**
> - Interview, a new database: one per interview, linked to its candidate, with Interviewers, When, Score (1 to 4) and Verdict (Hire, No hire)
> - Candidate: a workflow, Applied → Screening → Interview → Offer → Hired or Rejected, in place of Status
> - Candidate: Referred by, the person, in place of the typed name
> - Views: Interviews this week, My interviews, Scores owed; the guide How to run interviews
> - Rule Interview booked: a candidate in Screening moves to Interview when an interview is added
>
> **Changes**
> - Position is renamed Job, and Candidate's Position field with it
> - Job: a new state, On hold, between Open and Filled
> - Seniority: Mid-level is renamed Mid; a new option, Lead; new candidates start as Junior
> - Pipeline, Active candidates and Positions: the state in place of Status, where Status was
> - Is active: true until the state is finished, was "Status isn't Hired or Rejected"
> - Stamp stage fires when the state changes; Reject sets the state
>
> **Moves**
> - Status → the state: all 12 candidates (Interview 3, Applied 3, Screening 2, Rejected 2, Offer 1, Hired 1); Status becomes "Status (old)"
> - Referred by → the person: 3 of the 6 names match a user; Dana (2 candidates) and Sam K (1) match none and stay empty; the text becomes "Referred by (old)"
>
> **What the team will notice**
> - Integrations and API calls that use Position, Status, Referred by or Mid-level stop working.
> - For a minute or so, every candidate shows Applied.
> - The 12 candidates show as changed by you today.
> - Candidates by status still counts Status (old) until it's switched to the state, by hand.
>
> Reply **go** to make these changes, or tell me what to change.

Then stop: the list is the turn's last message, never a question tool's, whose dialog can hide it. A yes builds. A reply that renames or drops a line builds with that change; one that adds or alters a change shows the lines it touched again, and waits. After "just build it", a list of Adds alone builds at once; a list with Changes or Moves still waits, since it touches what the team uses.

## 3. Build

The scripts of a new build, without the sample records, and three of an extension's own: script 0 changes what exists in place, script 4x copies values and moves the rules that read them, script 3x edits views, formulas and other rules. Each message once the one before has answered; a script with nothing to do is skipped:

1. **Script 0** (below): renames, then options and states added, changed, reordered or given a default. A replaced field is renamed "<name> (old)" here, which frees its name. Every name after this, in this script and the next ones, is the name after the renames; renaming a database also renames the relation fields named after it (measured).
2. **Script 1**: what's new in the structure. `spaces` holds only a new Space; an existing database is a key with only what's new, its new `fields` and, for one without states, its `workflow`, without `color` or `description`, and the script stops when no database has that name, so a misspelt one is never created. `GUIDE` is the new process's guide, or `null`. `create_schema` calls an existing field "unchanged" even when its type differs (measured), which is why a name is freed before it's reused.
3. **Script 2**: the new formulas.
4. **Script 4x** (below), only for Moves, alone, and again until it logs no "time is up": the copies, then the rules and buttons that used the old fields.
5. **Scripts 3, 3x and 5, and the app script**, in one message: new views and reports, every other edit to an existing view, formula, rule or button (script 3x, below), new rules and buttons (made off), the app.
6. **The guide's two calls, for a new process, and script 6**, when script 5 made rules or there's something to check. The guide is written as for a new Space, about the new process; it lands after the Space's own views. `fetch_view_data` opens the view the person starts from, an edited one when there is one: a new database has no records to show, so the report's Worth a look says its views weren't seen with data. `CHECKS` hold only checks of the build's own work (a moved formula agrees with the state it now reads): a record of the team's that breaks a promise is reported, never changed. `RULES` name the rules script 5 made, `{database, names}`, so a rule the team keeps off stays off.

Fixes, reruns and "time is up" work as in a new build. Nothing is deleted to start over, the build's own additions included, unless the person asks.

**Edits find their target by name and change it once.** Every edit in scripts 4x and 3x has `when`, text it runs only while the stored view, formula or rule holds it, or `unless`, text it skips once held, so a second run changes nothing twice. After script 0, whatever used a replaced field names it "(old)": views and rules by the full name, formulas as `[Status (old)]`, so a move's edits all take `when: f("Status (old)")`. An edit that moves nothing takes `unless` with what it adds (`unless: f("Priority")` for a view that gains Priority).

### Script 0: what exists, changed in place

The data: `RENAME_DATABASES`, `RENAME_FIELDS` (full names, the replaced fields among them) and `RENAME_OPTIONS` (an option, or a state with `field: "workflow/state"`); then `STATES` and `OPTIONS`, each `{database, add, update, order, defaultOption}`, with the select's `field` for an option. `add` appends `{name, color, icon}` (a state `{name, type, color}`) at the end; `update` changes an option's color or emoji, or a state's type or color, never a name; `order` is every name in the new order; `defaultOption` is the one new records get. `STATES` names only databases that already have states: a workflow the build adds comes from script 1. A new option takes an emoji only when the select's options have them.

```js
const S = "Hiring"; const f = n => `${S}/${n}`;
const C = f("Candidate"), J = f("Job");
const RENAME_DATABASES = [{oldName: f("Position"), newName: J}];
const RENAME_FIELDS = [
  {database: C, oldName: f("Status"), newName: f("Status (old)")},
  {database: C, oldName: f("Referred by"), newName: f("Referred by (old)")}
];
const RENAME_OPTIONS = [{database: C, field: f("Seniority"), oldName: "Mid-level", newName: "Mid"}];
const STATES = [{database: J, add: [{name: "On hold", type: "Started", color: "#FBA32F"}], order: ["Open", "On hold", "Filled", "Closed"]}];
const OPTIONS = [{database: C, field: f("Seniority"), add: [{name: "Lead", color: "#9C2BAF"}], defaultOption: "Junior"}];

const fails = [], made = [], seen = [];
const run = async (label, p) => { try { const r = await p; made.push(label); return r; } catch (e) { fails.push(`${label}: ${String(e.message || e).slice(0, 200)}`); return null; } };
const rows = async (from, select) => (await query({query: {"q/from": from, "q/select": select, "q/limit": "q/no-limit"}})).result;
const esc = s => s.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
const fieldsOf = async dbs => {
  const out = Object.fromEntries(dbs.map(db => [db, new Map()])); let cur = null;
  for (const line of dbs.length ? (await schema_detailed({databases: dbs})).schema.split("\n") : []) {
    const d = line.match(/^(\S[^:]*):/); if (d) { cur = out[d[1]] ? d[1] : null; continue; }
    const m = line.match(/^ {4}([^:]+): (.*)$/); if (cur && m) out[cur].set(m[1], m[2]);
  }
  return out;
};
const tree = (await schema({})).schema, exists = db => new RegExp(`^\\s*${esc(db)},`, "m").test(tree);
for (const x of RENAME_DATABASES) {
  if (exists(x.newName)) seen.push(`database ${x.newName}`);
  else if (exists(x.oldName)) await run(`database ${x.oldName} → ${x.newName}`, rename_databases({databases: [x]}));
  else fails.push(`database ${x.oldName}: not found`);
}
const dbs = [...new Set([...RENAME_FIELDS, ...RENAME_OPTIONS, ...STATES, ...OPTIONS].map(x => x.database))];
let has = await fieldsOf(dbs);
for (const x of RENAME_FIELDS) {
  if (has[x.database].has(x.newName)) seen.push(`field ${x.newName}`);
  else if (has[x.database].has(x.oldName)) await run(`field ${x.oldName} → ${x.newName}`, rename_fields({fields: [x]}));
  else fails.push(`field ${x.oldName}: not found`);
}
has = await fieldsOf(dbs);
const enumOf = (db, field) => field === "workflow/state" ? `workflow/state_${db}` : `${field}_${db}`;
const list = async (db, field) => (await rows(enumOf(db, field), {id: "fibery/id", n: "enum/name", c: "enum/color", r: "fibery/rank", ...(field === "workflow/state" ? {t: "workflow/Type"} : {i: "enum/icon"})})).sort((a, b) => a.r - b.r);
// Renamed through its own record, an option or state keeps its id, so the records and filters that hold it keep it.
for (const x of RENAME_OPTIONS) {
  const l = await list(x.database, x.field).catch(e => { fails.push(`option ${x.oldName}: ${String(e.message || e).slice(0, 200)}`); return null; });
  if (!l) continue;
  const o = l.find(o => o.n === x.oldName);
  if (l.some(o => o.n === x.newName)) seen.push(`option ${x.newName}`);
  else if (o) await run(`option ${x.oldName} → ${x.newName}`, update_entities({database: enumOf(x.database, x.field), entities: [{id: o.id, "enum/name": x.newName}]}));
  else fails.push(`option ${x.oldName}: not found`);
}
const same = (a, b) => String(a || "").toLowerCase() === String(b || "").toLowerCase();
const options = async (x, field) => {
  const state = field === "workflow/state", short = state ? `states of ${x.database.split("/").pop()}` : field.split("/").pop();
  const call = state ? update_workflow_fields : /collection/.test(has[x.database].get(field) || "") ? update_multi_select_fields : update_single_select_fields;
  const send = (label, more) => run(`${short} ${label}`, call({fields: [{database: x.database, ...(state ? {} : {name: field}), ...more}]}));
  let l = await list(x.database, field);
  const add = (x.add || []).filter(a => !l.some(o => o.n === a.name));
  if (add.length) await send(`added: ${add.map(a => a.name).join(", ")}`, {update: {addOptions: add}});
  const upd = (x.update || []).filter(u => { const o = l.find(o => o.n === u.name); return o && Object.keys(u).some(k => k !== "name" && !same(u[k], {color: o.c, icon: o.i, type: o.t}[k])); });
  if (upd.length) await send(`changed: ${upd.map(u => u.name).join(", ")}`, {update: {updateOptions: upd}});
  if (!add.length && !upd.length && (x.add || x.update)) seen.push(`${short} options`);
  if (x.order) {
    l = await list(x.database, field);
    // A full list replaces the options: one left out would be deleted with its values.
    if (l.length !== x.order.length || l.some(o => !x.order.includes(o.n))) fails.push(`${short} order: name every option once (${l.map(o => o.n).join(", ")})`);
    else if (l.map(o => o.n).join("|") === x.order.join("|")) seen.push(`${short} order`);
    else await send("reordered", {update: {options: x.order.map(n => { const o = l.find(o => o.n === n); return state ? {name: n, type: o.t, color: o.c} : {name: n, color: o.c, ...(o.i ? {icon: o.i} : {})}; })}});
  }
  const def = ((has[x.database].get(field) || "").match(/default: ([^;]+)$/) || [])[1];
  if (x.defaultOption && def === x.defaultOption) seen.push(`${short} default`);
  else if (x.defaultOption) await send(`default ${x.defaultOption}`, {defaultOption: x.defaultOption, update: {addOptions: []}});
};
for (const x of STATES) await options(x, "workflow/state").catch(e => fails.push(`states of ${x.database}: ${String(e.message || e).slice(0, 200)}`));
for (const x of OPTIONS) await options(x, x.field).catch(e => fails.push(`${x.field}: ${String(e.message || e).slice(0, 200)}`));
log(`made: ${made.join("; ") || "nothing"}; there before: ${seen.join(", ") || "nothing"}`);
log(`failed ${fails.length}`); fails.forEach(x => log("FAIL " + x));
```

### Script 4x: values copied, and the rules that read them moved

The data:

- `STATES` and `OPTIONS` as in script 3, for the rules' filters and values.
- `MOVES`, `{database, from, to}`: the old field by its "(old)" name and the new one. A value goes by the new field's kind: a state or option by name; a person by user name or email; a link by the linked record's Name; all three ignoring case and spaces at the ends; anything else as it is. `map` translates first, an object (`{"In review": "Review"}`) or a function, which may return a list (`v => v.split(",")` for a text holding several options). For a link, `create: true` creates a record for each name that matches none, only when the person asked for it. A copy writes only where the new field is empty, and a state only while the record is in the first state, the one every record got when the workflow came, so a value someone set since stays.
- `EDIT_RULES()`: the rules and buttons that used a replaced field, each `{automationType, database, name}`, its `when`, and the `triggers`, `filter` or `actions` that change. `actions` replace the stored ones in order, and `null` keeps the stored action in its place.

```js
const S = "Hiring"; const f = n => `${S}/${n}`;
const C = f("Candidate");
const STATES = [C];
const OPTIONS = [];
const MOVES = [
  {database: C, from: f("Status (old)"), to: "workflow/state"},
  {database: C, from: f("Referred by (old)"), to: f("Referred by")}
];
const EDIT_RULES = () => [
  {automationType: "rule", database: C, name: "Stamp stage", when: f("Status (old)"), triggers: [{trigger: "updated", args: {updatedField: ["workflow/state"]}}]},
  {automationType: "button", database: C, name: "Reject", when: f("Status (old)"), actions: [{action: "Update", args: {fields: [{name: "workflow/state", value: stateValue(C, "Rejected")}]}}]}
];

const fails = [], made = [], seen = [], t0 = Date.now();
const run = async (label, p) => { try { const r = await p; made.push(label); return r; } catch (e) { fails.push(`${label}: ${String(e.message || e).slice(0, 200)}`); return null; } };
const rows = async (from, select) => (await query({query: {"q/from": from, "q/select": select, "q/limit": "q/no-limit"}})).result;
const enumIds = async from => Object.fromEntries((await rows(from, {id: "fibery/id", n: "enum/name"})).map(r => [r.n, r.id]));
const sp = db => db.split("/")[0], short = n => n.split("/").pop();
const st = {}, opts = {};
for (const db of STATES) st[db] = await enumIds(`workflow/state_${db}`);
for (const [db, field] of OPTIONS) (opts[db] = opts[db] || {})[field] = await enumIds(`${sp(db)}/${field}_${db}`);
const node = (nodeType, field, operator, value) => ({nodeType, args: value === undefined ? {fieldPath: [field], operator} : {fieldPath: [field], operator, value}});
const wf = (db, op, names) => node("workflow", "workflow/state", op, names.map(n => st[db][n]));
const sel = (db, field, op, names) => node("single-select", f(field), op, names.map(n => opts[db][field][n]));
const and = (...filters) => ({nodeType: "logical", args: {operator: "and", filters}});
const or = (...filters) => ({nodeType: "logical", args: {operator: "or", filters}});
const flag = (field, value = true) => node("bool", f(field), "is", value);
const num = (field, op, value) => node("number", f(field), op, value);
const empty = (nodeType, field, operator = "is-empty") => node(nodeType, f(field), operator);
const days = (field, op, amount, isBeforeNow, unit = "day") => node("date", f(field), op, {amount, unit, isBeforeNow});
const stateValue = (db, name) => ({type: "value", value: {"fibery/id": st[db][name]}});
const tpl = prompt => ({type: "template", prompt});
const formula = prompt => ({type: "formula", prompt});
const types = {};
let cur = null;
for (const line of MOVES.length ? (await schema_detailed({databases: [...new Set(MOVES.map(m => m.database))]})).schema.split("\n") : []) {
  const d = line.match(/^(\S[^:]*):/); if (d) { cur = d[1]; types[cur] = {}; continue; }
  const m = line.match(/^ {4}([^:]+): (.+?)(?: # (.*))?$/); if (cur && m) types[cur][m[1]] = {type: m[2], many: /collection/.test(m[3] || ""), note: m[3] || ""};
}
const isEnum = (db, t) => t.endsWith(`_${db}`) || t.startsWith("workflow/state_");
const lower = o => Object.fromEntries(Object.entries(o).map(([k, v]) => [String(k).trim().toLowerCase(), v]));
const writes = [], copied = {};
for (const m of MOVES) {
  const from = (types[m.database] || {})[m.from], to = (types[m.database] || {})[m.to], key = `${short(m.from)} → ${short(m.to)}`;
  if (!from || !to) { fails.push(`${key}: no such field`); continue; }
  const title = from.type === "fibery/user" ? "user/name" : isEnum(m.database, from.type) ? "enum/name" : `${sp(from.type)}/Name`;
  const pick = from.type.startsWith("fibery/") && from.type !== "fibery/user" ? m.from : from.many ? {"q/from": m.from, "q/select": {n: title}, "q/limit": "q/no-limit"} : [m.from, title];
  const kind = m.to === "workflow/state" ? "state" : isEnum(m.database, to.type) ? (to.many ? "multi" : "select") : to.type === "fibery/user" ? (to.many ? "people" : "person") : to.type.startsWith("fibery/") ? "value" : (to.many ? "links" : "link");
  const many = ["multi", "people", "links"].includes(kind);
  const now = many ? {"q/from": m.to, "q/select": {id: "fibery/id"}, "q/limit": "q/no-limit"} : kind === "value" ? m.to : [m.to, "fibery/id"];
  const recs = await rows(m.database, {id: "fibery/id", v: pick, now});
  const target = kind === "value" ? null : ["state", "select", "multi"].includes(kind) ? lower(await enumIds(to.type))
    : ["person", "people"].includes(kind) ? Object.fromEntries((await rows("fibery/user", {id: "fibery/id", n: "user/name", e: "user/email"})).flatMap(u => [[String(u.n).trim().toLowerCase(), u.id], [String(u.e).trim().toLowerCase(), u.id]]))
    : lower(Object.fromEntries((await rows(to.type, {id: "fibery/id", n: `${sp(to.type)}/Name`})).map(r => [r.n, r.id])));
  // A new workflow puts every record in its first state: only a record still there gets its old value, so a state someone set since stays.
  const first = kind === "state" && target[((to.note.match(/default: ([^;]+)$/) || [])[1] || "").trim().toLowerCase()];
  const conv = v => typeof m.map === "function" ? m.map(v) : m.map && m.map[v] !== undefined ? m.map[v] : v;
  const vals = r => [].concat(r.v === null || r.v === undefined ? [] : r.v).map(v => v && v.n !== undefined ? v.n : v).flatMap(v => [].concat(conv(v))).filter(v => v !== null && v !== undefined && v !== "");
  const look = v => kind === "value" ? v : target[String(v).trim().toLowerCase()];
  const c = copied[key] = {copied: 0, there: 0, own: 0, unmatched: new Map()};
  if (m.create && ["link", "links"].includes(kind)) {
    const missing = new Map();
    recs.forEach(r => vals(r).forEach(v => { const n = String(v).trim(); if (n && !look(n) && !missing.has(n.toLowerCase())) missing.set(n.toLowerCase(), n); }));
    if (missing.size && await run(`${short(to.type)} records ${[...missing.values()].join(", ")}`, create_entities({database: to.type, entities: [...missing.values()].map(n => ({[`${sp(to.type)}/Name`]: n}))})))
      (await rows(to.type, {id: "fibery/id", n: `${sp(to.type)}/Name`})).forEach(r => target[String(r.n).trim().toLowerCase()] = r.id);
  }
  const single = [];
  for (const r of recs) {
    const vs = vals(r); if (!vs.length) continue;
    const ids = vs.map(look);
    vs.forEach((v, i) => { if (ids[i] === undefined) c.unmatched.set(String(v), (c.unmatched.get(String(v)) || 0) + 1); });
    const ok = [...new Set(ids.filter(x => x !== undefined))];
    if (!ok.length) continue;
    if (many) { const there = (r.now || []).map(x => x.id), add = ok.filter(x => !there.includes(x)); if (!add.length) c.there++; else writes.push(() => run(key, add_collection_items({database: m.database, field: m.to, entityId: r.id, items: add})).then(x => { if (x) c.copied++; })); }
    else if (kind === "state") { if (r.now === ok[0]) c.there++; else if (r.now !== first) c.own++; else single.push({id: r.id, [m.to]: ok[0]}); }
    else if (r.now !== null && r.now !== undefined && r.now !== "") c.there++;
    else single.push({id: r.id, [m.to]: ok[0]});
  }
  for (let i = 0; i < single.length; i += 25) { const part = single.slice(i, i + 25); writes.push(() => run(key, update_entities({database: m.database, entities: part})).then(x => { if (x) c.copied += part.length; })); }
}
let next = 0, slow = 5000;
while (next < writes.length && Date.now() - t0 + slow < 45000) { const batch = writes.slice(next, next + 10), s0 = Date.now(); next += batch.length; await Promise.all(batch.map(w => w())); slow = Math.max(slow, Date.now() - s0); }
const says = (text, s) => String(text).includes(s) || String(text).includes(`[${short(s)}]`);
const due = (text, x) => (!x.when || says(text, x.when)) && !(x.unless && says(text, x.unless));
// A rule moves only once every value is copied, so it never fires on a copy.
let left = next < writes.length ? EDIT_RULES().length : 0;
const ruleNames = {};
[...Object.values(st), ...Object.values(opts).flatMap(o => Object.values(o))].forEach(m => Object.entries(m).forEach(([n, id]) => ruleNames[id] = n));
const readable = o => JSON.stringify(o).split(`${S}/`).join("").replace(/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/g, id => ruleNames[id] || id);
const edited = [];
for (const e of left ? [] : EDIT_RULES()) {
  if (Date.now() - t0 + 5000 > 45000) { left++; continue; }
  const a = (await query_automations({automationType: e.automationType, database: e.database})).automations.find(x => x.name === e.name);
  if (!a) { fails.push(`${e.automationType} ${e.name}: not found`); continue; }
  if (!due(JSON.stringify([a.triggers, a.filter, a.actions]), e)) { seen.push(`${e.automationType} ${e.name}`); continue; }
  const now = a.actions || [], acts = e.actions || [];
  if (await run(`${e.automationType} ${e.name}`, update_automation({automationType: e.automationType, id: a.id, ...(e.triggers ? {triggers: e.triggers} : {}), ...(e.filter ? {filter: e.filter} : {}),
    ...(acts.length ? {changeActions: acts.slice(0, now.length).map((x, i) => x && {actionId: now[i].id, ...x}).filter(Boolean), addActions: acts.slice(now.length), deleteActionIds: now.slice(acts.length).map(x => x.id)} : {})}))) edited.push(e);
}
for (const e of edited) {
  const a = (await query_automations({automationType: e.automationType, database: e.database})).automations.find(x => x.name === e.name);
  log(`${e.name}: ${readable({when: (a.triggers || []).map(t => [t.trigger, t.args]), if: a.filter, do: (a.actions || []).map(x => [x.name, x.args])})}`.slice(0, 900));
}
Object.entries(copied).forEach(([k, c]) => log(`${k}: ${c.copied} copied, ${c.there} had it already${c.own ? `, ${c.own} left in the state someone set` : ""}${c.unmatched.size ? `, no match for ${[...c.unmatched].slice(0, 10).map(([v, n]) => `${v} (${n})`).join(", ")}` : ""}`));
log(`rules changed: ${edited.map(e => e.name).join(", ") || "none"}; there before: ${seen.join(", ") || "nothing"}`);
if (left) log(`time is up with ${writes.length - next} copies and ${left} rules left: run this script again, as it is, to finish`);
log(`failed ${fails.length}`); fails.forEach(x => log("FAIL " + x));
```

It logs each changed rule as Fibery stored it, to read as the build guide §5 says, a line per move ("N copied, M had it already", and what matched nothing), then the rules changed and those found done. A move that copied nothing while records hold values has a wrong field name or `map`.

### Script 3x: views, formulas and other rules edited

The data: `STATES` and `OPTIONS` as in script 3; `EDIT_VIEWS()`, each view to change with its whole config rebuilt from the read with the builders, since `update_view` replaces it, so what the list doesn't change stays as the team had it, in their order; `EDIT_FORMULAS`, `{database, name, description}`, the new expression as script 2 writes one; `EDIT_RULES()`, any rule edit that moves nothing, shaped as in script 4x (`actions: [null, {action: "Notify Assignee", args: {subject, message}}]` adds a notification after the stored action). Each edit with `when` or `unless`.

```js
const S = "Hiring"; const f = n => `${S}/${n}`;
const C = f("Candidate"), J = f("Job");
const STATES = [C];
const OPTIONS = [];
const EDIT_VIEWS = () => [
  {name: "Pipeline", when: f("Status (old)"), viewType: "board", config: {x: [stateAxis(C)], y: [], items: [{database: C, fields: [fld("Name"), fld("Job"), fld("Seniority")]}]}},
  {name: "Active candidates", when: f("Status (old)"), viewType: "grid", config: {rowHeight: "short", items: [
    {database: C, fields: [fld("Name"), {field: "workflow/state"}, fld("Job"), fld("Seniority"), fld("Referred by"), fld("Recruiter")], filter: wf(C, "is-none-of", ["Hired", "Rejected"]), colorCoding: [{color: "#FBA32F", filter: wf(C, "is-any-of", ["Offer"])}]}]}},
  {name: "Positions", when: f("Status (old)"), viewType: "list", config: {items: [
    {database: J, fields: [fld("Name"), {field: "workflow/state"}, fld("Openings")]},
    {database: C, fields: [fld("Name"), {field: "workflow/state"}], groupBy: {parentIndex: 0, parentField: f("Candidates")}}]}}
];
const EDIT_FORMULAS = [{database: C, name: f("Is active"), when: f("Status (old)"), description: "Use exactly this Fibery formula: State.Type != \"Finished\". The result is true or false."}];
const EDIT_RULES = () => [];

const fails = [], made = [], seen = [], t0 = Date.now();
const run = async (label, p) => { try { const r = await p; made.push(label); return r; } catch (e) { fails.push(`${label}: ${String(e.message || e).slice(0, 200)}`); return null; } };
const rows = async (from, select) => (await query({query: {"q/from": from, "q/select": select, "q/limit": "q/no-limit"}})).result;
const enumIds = async from => Object.fromEntries((await rows(from, {id: "fibery/id", n: "enum/name"})).map(r => [r.n, r.id]));
const sp = db => db.split("/")[0], short = n => n.split("/").pop();
const st = {}, opts = {};
for (const db of STATES) st[db] = await enumIds(`workflow/state_${db}`);
for (const [db, field] of OPTIONS) (opts[db] = opts[db] || {})[field] = await enumIds(`${sp(db)}/${field}_${db}`);
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
const stateValue = (db, name) => ({type: "value", value: {"fibery/id": st[db][name]}});
const tpl = prompt => ({type: "template", prompt});
const formula = prompt => ({type: "formula", prompt});
const says = (text, s) => String(text).includes(s) || String(text).includes(`[${short(s)}]`);
const due = (text, x) => (!x.when || says(text, x.when)) && !(x.unless && says(text, x.unless));
const read = async () => {
  const out = {}; let cur = null;
  for (const line of EDIT_FORMULAS.length ? (await schema_detailed({databases: [...new Set(EDIT_FORMULAS.map(x => x.database))]})).schema.split("\n") : []) {
    const d = line.match(/^(\S[^:]*):/); if (d) { cur = d[1]; out[cur] = {}; continue; }
    const m = line.match(/^ {4}([^:]+): (.*)$/); if (cur && m) out[cur][m[1]] = m[2];
  }
  return out;
};
let left = 0;
const views = (await query_views({space: S, withConfig: false})).views;
for (const v of EDIT_VIEWS()) {
  if (Date.now() - t0 + 5000 > 45000) { left++; continue; }
  const x = views.find(y => y.name === v.name);
  if (!x) { fails.push(`view ${v.name}: not found`); continue; }
  if (!due(JSON.stringify((await query_views({id: x.id, withConfig: true})).views[0].config), v)) { seen.push(`view ${v.name}`); continue; }
  await run(`view ${v.name}`, update_view({viewType: v.viewType, id: x.id, config: v.config}));
}
const types = await read();
const formulas = EDIT_FORMULAS.filter(x => { const t = (types[x.database] || {})[x.name]; if (!t) { fails.push(`formula ${short(x.name)}: not found`); return false; } if (!due(t, x)) { seen.push(`formula ${short(x.name)}`); return false; } return true; });
for (let i = 0, last = 15000; i < formulas.length; i += 4) {
  if (Date.now() - t0 + last > 45000) { left += formulas.length - i; break; }
  const s0 = Date.now();
  await Promise.all(formulas.slice(i, i + 4).map(x => run(`formula ${short(x.name)}`, update_formula_field({database: x.database, name: x.name, description: x.description}))));
  last = Math.max(last, Date.now() - s0);
}
const ruleNames = {};
[...Object.values(st), ...Object.values(opts).flatMap(o => Object.values(o))].forEach(m => Object.entries(m).forEach(([n, id]) => ruleNames[id] = n));
const readable = o => JSON.stringify(o).split(`${S}/`).join("").replace(/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/g, id => ruleNames[id] || id);
const edited = [];
for (const e of left ? [] : EDIT_RULES()) {
  if (Date.now() - t0 + 5000 > 45000) { left++; continue; }
  const a = (await query_automations({automationType: e.automationType, database: e.database})).automations.find(x => x.name === e.name);
  if (!a) { fails.push(`${e.automationType} ${e.name}: not found`); continue; }
  if (!due(JSON.stringify([a.triggers, a.filter, a.actions]), e)) { seen.push(`${e.automationType} ${e.name}`); continue; }
  const now = a.actions || [], acts = e.actions || [];
  if (await run(`${e.automationType} ${e.name}`, update_automation({automationType: e.automationType, id: a.id, ...(e.triggers ? {triggers: e.triggers} : {}), ...(e.filter ? {filter: e.filter} : {}),
    ...(acts.length ? {changeActions: acts.slice(0, now.length).map((x, i) => x && {actionId: now[i].id, ...x}).filter(Boolean), addActions: acts.slice(now.length), deleteActionIds: now.slice(acts.length).map(x => x.id)} : {})}))) edited.push(e);
}
for (const e of edited) {
  const a = (await query_automations({automationType: e.automationType, database: e.database})).automations.find(x => x.name === e.name);
  log(`${e.name}: ${readable({when: (a.triggers || []).map(t => [t.trigger, t.args]), if: a.filter, do: (a.actions || []).map(x => [x.name, x.args])})}`.slice(0, 900));
}
const after = formulas.length ? await read() : {};
formulas.forEach(x => log(`${short(x.name)}: ${String((after[x.database] || {})[x.name] || "missing").replace(" # read-only; formula: ", " = ")}`));
log(`edited: ${made.join(", ") || "nothing"}; there before: ${seen.join(", ") || "nothing"}`);
if (left) log(`time is up with ${left} edits left: run this script again, as it is, to finish`);
log(`failed ${fails.length}`); fails.forEach(x => log("FAIL " + x));
```

It logs each edited rule and formula as Fibery stored it, to read as the build guide §2 and §5 say, then the edits made and those found done.

## 4. Report

As SKILL.md §6 says, with these differences:

> **Hiring is extended.** Interviews run by the guide, [How to run interviews](…); candidates move through their states on [Pipeline](…).
>
> **Your turn:** check the copies, then delete Status (old) and Referred by (old) in Candidate's fields; before that, switch Candidates by status to the state; add the interview step to any document that describes hiring; update the integrations that use Position, Status, Referred by or Mid-level.
>
> **Not copied:** Referred by Dana (2 candidates) and Sam K (1): no user has those names, so those candidates have none.

- **Ready** says the Space is extended, and links the new guide, if any, and the view to start from.
- **Your turn** adds the "(old)" fields to delete once checked, what still uses them that the build doesn't edit, and the integrations that use a renamed name.
- **Not copied** lists the values that matched nothing, with how many records hold each.
- No line about examples: an extension writes none.

The Build notes in `design.md` list every change with what it replaced, from the read, so any of it can be undone by hand: the old names, the options and states as they were, and each edited view's config, formula's expression and rule's triggers, filter and actions.
