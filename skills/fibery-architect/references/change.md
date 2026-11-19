# Changing a Space that exists

Every change to a Space that exists goes by this file: a change right after the build, a change to a Space the team works in, a process added to it, and "remove the examples". A Space read in order to copy or improve it into a new one is read with the script in §1 and then designed and built as new; the existing Space is never changed.

Two kinds of Space, told apart by the read:

- **Only examples:** every record ends with " (example)". Nobody works in it yet. What the build made may be changed or removed.
- **The team's records:** any record without the mark. Two rules hold. Nothing of theirs is deleted: a field that is replaced stays, renamed "<name> (old)", with its values copied into the new one; a removal the person asks for is a retirement (§3), and the person deletes it in Fibery once they have checked. And a change that would lose or rewrite their data (values rounded, a state's records moved, values overwritten) waits for a yes, asked in one sentence.

The person needs `architect` access to the Space (`architect+` too); with any other, say so and change nothing. Read `build.md` too: new things go through its scripts. In the conversation that built the Space you already have its names; in a later one, read `design.md` when the folder has it.

## 1. Read

One script, which changes nothing. `S` is the Space's name; `FIND` holds the fields a change renames, replaces, converts or removes (`"State"` for the states), each by its name without the Space, `[]` for none.

```js
const S = "Hiring";
const FIND = ["Source"];

const X = " (example)", autos = [], short = n => String(n).split("/").pop();
const sp = String(await get_spaces({})).split("\n"), i = sp.findIndex(l => l.trim() === `- name: ${S}`);
if (i < 0) throw new Error(`no Space named ${S}`);
const end = sp.findIndex((l, k) => k > i && l.search(/\S/) <= sp[i].search(/\S/));
const block = sp.slice(i + 1, end < 0 ? undefined : end), dbs = block.map(l => l.trim().replace(/^"/, "").split(",")[0]).filter(n => n.startsWith(S + "/"));
log(`access ${(block.find(l => /^\s*access: /.test(l)) || "").trim().slice(8)}`);
const fields = {}; let db, cur, at;
for (const l of String(await get_databases({databases: dbs, forQuerying: true})).split("\n")) {
  const r = l.trim(), k = r.split(":")[0], v = r.slice(k.length + 2).replace(/^"|"$/g, "").replace(/\\"/g, '"');
  if (k === "- name" && dbs.includes(v) && (at ?? l.indexOf("-")) === l.indexOf("-")) { at = l.indexOf("-"); fields[db = v] = []; cur = null; }
  else if (k === "- name" && db) fields[db].push(cur = /^(fibery|Collaboration~Documents|comments)\/|\/(Name|Description)$/.test(v) ? null : {n: short(v), o: []});
  else if (r === "workflow:") fields[db].push(cur = {n: "State", t: "states", o: []});
  else if (!cur) continue;
  else if (k === "type" && !cur.t) cur.t = v;
  else if (["formula", "resultType", "relatedDatabase", "cardinality", "numberFormat", "numberPrecision"].includes(k)) cur[k] = v;
  else if (k === "name" || /^[0-9a-f-]{36},/.test(r)) cur.o.push(k === "name" ? v : r.slice(37));
  else if (k === "type" && v !== "Started") cur.o.push(cur.o.pop() + ` (${v.toLowerCase()})`);
  else if (k === "isDefault") cur.o.push(cur.o.pop() + "*");
}
for (const d of dbs) {
  const names = (await query({query: {"q/from": d, "q/select": {n: `${S}/Name`}, "q/limit": "q/no-limit"}})).result.map(r => String(r.n || ""));
  log(`${short(d)}: ${names.length} records, ${names.filter(n => !n.endsWith(X)).length} without the mark`);
  for (const x of fields[d].filter(Boolean)) log(`  ${x.n}: ${x.t}${x.formula ? ` ${x.resultType} = ${x.formula}` : ""}${x.relatedDatabase ? ` → ${x.relatedDatabase} ${x.cardinality}` : ""}${x.numberFormat && x.numberFormat !== "Number" ? " " + x.numberFormat : ""}${+x.numberPrecision ? `, ${x.numberPrecision} places` : ""}${x.o.length ? ": " + x.o.join(", ") : ""}`);
  for (const type of ["rule", "button"]) for (const a of (await query_automations({automationType: type, database: d})).automations) autos.push(a), log(`  ${type} ${a.name}${a.enabled === false ? " (off)" : ""}`);
}
const views = (await query_views({space: S, withConfig: false})).views;
views.forEach(v => log(`view ${v.name} (${v.viewType}) ${v.url}`));
for (const n of FIND) {
  const has = o => JSON.stringify(o).includes(n === "State" ? "workflow/state" : `${S}/${n}"`) || JSON.stringify(o).includes(`[${n}]`), used = [];
  for (const v of views.filter(v => v.viewType !== "document")) if (has(v.viewType === "report" ? (await get_report({reportId: v.id})).result : (await query_views({id: v.id, withConfig: true})).views[0].config)) used.push(v.name);
  autos.filter(has).forEach(a => used.push(a.name));
  Object.values(fields).flat().filter(x => x && x.formula && (x.formula.includes(`[${n}]`) || new RegExp(`\\b${n}\\b`).test(x.formula))).forEach(x => used.push(x.n));
  log(`${n} is used by: ${used.join(", ") || "nothing"}`);
}
```

It logs the access; per database its records and how many lack the mark, its fields with types, formulas, links, number formats and options in order (`*` the default, states marked "not started" and "finished"), and its rules and buttons ("(off)" when switched off); every view, document and report with its url; and for each name in `FIND` the views, reports, rules and formulas that use it. A page app's code isn't read: ask the person what it does if it matters.

For a copy or an improved new Space, write the design from this log in the design guide's words: a relation to another Space's database is a link, a formula keeps its expression, and records are never copied into the design. Leave out fields nobody fills, switched-off rules, anything personal, and a filter on one person.

## 2. Say

Before the change, a few lines in the person's words: what will be added, renamed, converted or moved, and, in a Space with the team's records, what they will notice (integrations and API calls that name a renamed field stop working; records a copy writes show as changed today; a new field starts empty). No list to approve. A change that loses or rewrites their data ends the message with one question ("Openings will round 2.5 to 3 in 4 jobs: go ahead?") and waits.

## 3. Do

**New things** go through `build.md`'s scripts with only the new things in their data, in its order:

- **Script 1** with the existing Space by `name` alone (no `color`) and an existing database by `name` and its new `fields` only; a new database in full, with `color` and `description`. It adds what is missing and logs the rest as "there before", which is expected here (the stop in `build.md` is for a new build). A name already in use with another type is called "unchanged" and not made: rename the old field first. `GUIDE` is `null`, or a new process's guide.
- **Script 2** for formulas, **script 3** for views and reports (`REPORTS = []` when none), **script 5** for rules and buttons (made on).
- **Script 4** for examples, only in a Space with only examples: its links find the examples already there by name. In a Space with the team's records, no examples are added.

**New examples go in with the rules off.** A rule that is on would fire on them: a record it makes has no mark, and a value it stamps overwrites the story's. So the edit script switches off every rule that is on in the databases script 4 writes to and the databases they link to, and logs their names:

```js
for (const db of [C, J]) for (const a of (await query_automations({automationType: "rule", database: db})).automations.filter(a => a.enabled)) await run(`off: ${a.name}`, update_automation({automationType: "rule", id: a.id, enabled: false}));
```

Script 4 goes in the next message, and the message after it switches the same rules on with `enabled: true`. Never off and on in one script, or on in script 4's message: a rule switched on right after the records were written still fires on them.

**Edits** go as plain tool calls in one script, in the order they depend on each other: renames first, then conversions, then what reads the renamed things. Inside it every tool is a function and needs no loading. `GUARD` lists the databases that must hold only examples before anything is touched; it is required before a removal in a Space with only examples, and `[]` otherwise. The builders are `build.md`'s, copied as needed.

```js
const S = "Hiring"; const f = n => `${S}/${n}`;
const C = f("Candidate"), J = f("Job");
const GUARD = [C, J];

const X = " (example)", fails = [];
const run = async (label, p) => { try { const r = await p; log("done: " + label); return r; } catch (e) { fails.push(`${label}: ${String(e?.message || e).slice(0, 300)}`); } };
for (const db of GUARD) { const own = (await query({query: {"q/from": db, "q/select": {n: `${S}/Name`}, "q/limit": "q/no-limit"}})).result.filter(r => !String(r.n || "").endsWith(X)); if (own.length) throw new Error(`STOP, ${db} holds the team's records: ${own.slice(0, 3).map(r => r.n).join(", ")}`); }
const views = (await query_views({space: S, withConfig: false})).views, view = n => (views.find(v => v.name === n) || {}).id;
const automation = async (db, n, type = "rule") => (await query_automations({automationType: type, database: db})).automations.find(a => a.name === n);
const states = async db => Object.fromEntries((await query({query: {"q/from": `workflow/state_${db}`, "q/select": {id: "fibery/id", n: "enum/name"}, "q/limit": "q/no-limit"}})).result.map(r => [r.n, r.id]));
const record = async (db, n) => (await query({query: {"q/from": db, "q/select": {id: "fibery/id"}, "q/where": ["q/equals-ignoring-case?", [`${S}/Name`], n], "q/limit": 1}})).result[0].id;
function node(nodeType, field, operator, value) { return {nodeType, args: {fieldPath: [field], operator, value}}; }
function fld(n) { return {field: f(n)}; }
function and(...filters) { return {nodeType: "logical", args: {operator: "and", filters}}; }
function wf(names, op = "is-any-of") { return node("workflow", "workflow/state", op, names); }
function days(field, op, amount, isBeforeNow, unit = "day") { return node("date", f(field), op, {amount, unit, isBeforeNow}); }

await run("state Take-home", update_workflow_fields({fields: [{database: C, update: {options: [{name: "Applied"}, {name: "Screening"}, {name: "Take-home", type: "Started", color: "#1FBED3"}, {name: "Interview"}, {name: "Offer"}, {name: "Hired"}, {name: "Rejected"}]}}]}));
await run("view Interviews", update_view({viewType: "calendar", id: view("Interviews"), config: {items: [
  {database: C, fields: [fld("Name")], startDate: f("Next interview"), endDate: f("Next interview"), filter: wf(["Screening", "Take-home", "Interview"])}]}}));
const st = await states(C), r = await automation(C, "Interview reminder");
await run("rule Interview reminder", update_automation({automationType: "rule", id: r.id, filter: and(wf([st.Screening, st["Take-home"], st.Interview]), days("Next interview", "is", 0, false))}));
log(`failed ${fails.length}`); fails.forEach(x => log("FAIL " + x));
```

"STOP, … holds the team's records" means nothing was changed: the Space has the team's records, and the two rules above apply.

| Kind of change | The call | What follows it |
|---|---|---|
| a state added, moved or removed | `update_workflow_fields({fields: [{database, update: {options: [...]}}]})`, every state in the new order, one that exists as `{name}`, a new one with `type` and `color` | A state left out is deleted: move its records first (`update_entities`), which in a team's Space waits for a yes. A new state is in no filter that lists states: add it to every view and rule that lists them, or its records vanish from them |
| a state or option renamed, recolored, made the default | the same tool with `update: {updateOptions: [{name, newName, color, icon, isDefault}]}`; for a select `update_single_select_fields` or `update_multi_select_fields`, the field's `name` beside `database` | It keeps its id, so records, views and rules keep it |
| options added or reordered | `update: {addOptions: [{name, color, icon}]}` puts a new option (or state) last; to place it, `update: {options: [...]}` with every option in the new order, one that exists as `{name}`, the new one with `color` and `icon` where it goes | Options keep their ids. A full list replaces the options: one left out is deleted with its values |
| a database renamed | `rename_databases({databases: [{from, to}]})`, full names | The link fields to it are renamed by Fibery's own rule (after "Inspection (old)" the field on Equipment is "Inspection (old)s": `rename_fields` takes that name), and the word inside view names is rewritten without grammar ("Report a fault" became "Report a incident"). The old word stays in rule names and texts, report tab titles, other field names ("Open faults"), descriptions and the guide. Read the names back (§1), fix view names (`update_view({viewType, id, name})`), rename what the person sees, and tell them |
| a field renamed | `rename_fields({fields: [{database, from, to}]})` | Views, formulas and rules follow. A report names fields as text and does not: its tab reads whatever field has that name now; rewrite it with `update_tab({reportId, tabId, tabType: "chart", x, y, color})` |
| a number's decimals, a date to a date-time | `convert_number_fields({fields: [{database, name, numberPrecision: 2}]})`, `convert_date_fields({fields: [{database, name, to: "date-time"}]})`. A formula's places, money or unit: `update_fields({fields: [{database, name, numberPrecision: 2, numberFormat: "Money", numberCurrencyCode: "EUR"}]})` (`numberUnit` likewise); `convert_number_fields` refuses a formula. A whole formula takes no places: a new formula with a decimal expression does | The field and its values stay, and what uses it follows. Back to `0` places rounds every value for good, which in a team's Space waits for a yes. A date becomes midnight UTC; a rule stamping it with today still writes midnight (its value becomes "the current date and time, using Now()"), and a day count reading it needs its date part |
| a select made multi, a person made people | `convert_select_fields({fields: [{database, name, to: "multi-select"}]})`, `convert_relation_fields({fields: [{database, name, cardinality: "many-to-many"}]})` | Values are kept, but it comes back as a new field, often renamed (Kind became Kinds, Tag became "Tags 1"), named in `fixLogs`; a select loses its default. Nothing that used it follows: write every view, formula, rule and report on it again (rows below), and give it its name back with `rename_fields` |
| a field replaced by another kind (a select by a workflow or by a link to a new database, a typed name by a person) | `rename_fields` to "<name> (old)", then script 1 with the new field, then the copy script below, then what used the old field pointed at the new one | The old field stays in a team's Space; in a Space with only examples, delete it once the copy is checked. Point rules last, after the copy, so none fires on a copied value |
| a view changed, or pointed at a new field | `update_view({viewType, id, config})` with the whole config written again with the builders: from script 3's data for a view the build made; for one the team made, from `query_views({id, withConfig: true})`, every item retyped, its filters from their text | Never built from a read sent back: a read gives filters as text, and a config sent in part replaces the stored one and wipes what it lacks |
| a formula changed | `update_formula_field({database, name, description})`, written as script 2 writes one | The type stays; a different type is `delete_fields` and script 2 |
| a rule or button changed | `update_automation({automationType, id, triggers, filter, changeActions, addActions, deleteActionIds})`, the id and action ids from `automation()`; an action in the shape below | `triggers` and `filter` replace the stored ones whole. States, options and records by id: `states(db)`, an option from `query` on `"<field>_<database>"`, `record(db, name)`; a to-one link's filter is `node("reference", f("Source"), "is", [id])` |
| a field, view, rule or database removed | `delete_fields`, `delete_views({ids})`, `delete_automation({automationType, id})`, `delete_databases({databases})` | Only in a Space with only examples, after the guard, and after what reads it: a formula, a rule's filter or action, the views built on a database alone. In a team's Space it is retired instead (below) |
| an example changed | `update_entities({database, entities: [{"fibery/id": id, ...}]})`, a state or select by name, a to-many as `{add, remove}` | — |

**A rule's action** is written again whole. A read gives `fields: {type: "value", value: {"<Space>/<Field>": {type: "formula", value: "<expression>"}}}`; `changeActions` takes `{actionId, action, args: {fields: [{name, value}]}}`, every field of the action: a literal or id as read, a generated value as `{type: "formula", prompt}`, an exact expression (the read's own, `[Step 1 Job].[Openings] + 1`) as "Use exactly this Fibery formula: <expression>". A read sent back fails with 'Value of type "formula" requires a non-empty prompt' or 'arg is not iterable'.

```js
const asWrite = x => Object.entries(x.args.fields.value).map(([name, v]) => ({name, value: v.type === "formula" ? {type: "formula", prompt: `Use exactly this Fibery formula: ${v.value}`} : v}));
const rule = await automation(C, "Onboarding tasks"), act = rule.actions.find(x => x.name === "Add Tasks Item");
const fields = asWrite(act).map(x => x.name === f("Due") ? {name: x.name, value: {type: "formula", prompt: "the date part of the triggering Candidate's Next interview, minus 1 day"}} : x);
await run("rule Onboarding tasks", update_automation({automationType: "rule", id: rule.id, changeActions: [{actionId: act.id, action: act.name, args: {fields}}]}));
```

**A field holding `{{…}}` as typed** ("Laptop for {{Name}}"): that field is written again as a `formula` naming the trigger record, as above, and the records the rule made are renamed as the formula would name them (`query` them with their trigger record, then `update_entities`), which in a team's Space waits for a yes.

**Retiring a database with the team's records**, when they ask to delete it: it is renamed "<name> (old)", and the link field on each other database too (from the name the rename gave it); a view that exists only for it is renamed "(old)", and it is taken off the views it shares; every rule that makes or changes its records is switched off (`enabled: false`); its lines leave the guide (§4). The last message says they delete it in Fibery once they have checked. A field, view or rule of theirs is retired the same way: a field renamed "(old)" and taken off what reads it, a view renamed "(old)", a rule switched off.

**Copying values** into a replacement is a short script written for the case: what to read, how a value maps, what to write. It writes only where the new field is still empty and stops before Fibery's time limit, so it is sent again, as it is, until it logs nothing left; values that match nothing are named and stay empty. For a link to a new database, `CREATE` makes a record for each value that matches none, when the old values are the new records (a select's options); otherwise `false`. For a workflow, a record still waits while it is in the first state, which every record got when the workflow came, and the value is a state name.

```js
const S = "Hiring"; const f = n => `${S}/${n}`;
const DB = f("Candidate"), FROM = [f("Source (old)"), "enum/name"], TO = f("Source"), TARGET = f("Channel");
const CREATE = true;

const t0 = Date.now(), key = s => String(s).trim().toLowerCase();
const names = async () => Object.fromEntries((await query({query: {"q/from": TARGET, "q/select": {id: "fibery/id", n: f("Name")}, "q/limit": "q/no-limit"}})).result.map(r => [key(r.n), r.id]));
const recs = (await query({query: {"q/from": DB, "q/select": {id: "fibery/id", v: FROM, now: [TO, "fibery/id"]}, "q/limit": "q/no-limit"}})).result.filter(r => r.v && !r.now);
let ids = await names();
const missing = [...new Set(recs.map(r => r.v.trim()).filter(v => !ids[key(v)]))];
if (CREATE && missing.length) { await create_entities({database: TARGET, entities: missing.map(n => ({[f("Name")]: n}))}); ids = await names(); }
const todo = recs.filter(r => ids[key(r.v)]);
let done = 0;
for (let i = 0; i < todo.length && Date.now() - t0 < 40000; i += 50) {
  await update_entities({database: DB, entities: todo.slice(i, i + 50).map(r => ({"fibery/id": r.id, [TO]: ids[key(r.v)]}))});
  done += todo.slice(i, i + 50).length;
}
log(`${done} of ${todo.length} copied${done < todo.length ? "; send this script again to go on" : ""}; no match: ${recs.length - todo.length}${CREATE ? "" : " " + missing.join(", ")}`);
```

## 4. After

- **The guide.** Fix each line the change touches, in a script, the secret from `query_views({id, withConfig: true})` as `config.documentSecret`: `read_document({secret})` lists the blocks with their ids; `replace_block_text({secret, replacements: [{blockId, exact, replacement}]})` changes plain words; `replace_document_blocks({secret, blocks: [{blockId, content}]})` writes a line again whole when it has a mention, with mentions from script 3's log or `get_entity_mention`; `delete_document_blocks({secret, deletions: [{blockId}]})` drops a line, a list line by its `list_item` block (deleting only its paragraph leaves an empty item). A mention follows a rename by itself; plain words don't. A removed view's mention is dropped with its line.
- **The examples.** A Description that speaks of something removed is fixed the same way; a comment can't be edited: tell the person.
- **One look** at the view that changed with `fetch_view_data`, as after a build.
- **`design.md`**, when it exists: the spec changed to match, and a line in the Build notes ("Changed: …", with what it replaced, so it can be undone by hand).
- **The person:** one or two lines, what changed and the view where it shows, linked; in a team's Space, the "(old)" fields to delete once checked and anything that still reads them (a document, an app, an integration). Then what didn't go through, with what to do instead.

## 5. Remove the examples

When the person asks to remove the examples, this script alone, with no other file to read. `DATABASES` holds every database of the Space, from `design.md` or `get_spaces`. It deletes the records whose names end with the mark and nothing else, and logs how many went and stayed. Then one line to the person with the totals, and that Fibery's Activity tab can bring them back.

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
