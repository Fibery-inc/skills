# Changes right after the build

For a Space this skill built that still holds only its examples: the one built in this conversation, or an earlier one whose guide ends "Built by fibery-architect …". Nobody works in it yet, so a change goes straight in: no read script, no list to approve, no "(old)" fields, and what the build made can be removed. The first record without the mark is the team's own work, and from then on every change is an extension (`extend.md`). The script below checks that before it changes anything.

In the conversation that built the Space you have its names, the build guide and `scripts.md`. In a later one, read those two files, the Space with `get_databases`, and `design.md` when the folder has it.

## The script

One script makes the change, and every change goes through it, a single rename included: the guard runs before anything is touched, and a direct call would skip it. Its data is `DATABASES`, the full names of every database in the Space as they are before the change, and `X`, the examples' mark. Below the guard go the change's own calls, each through `run`, in the order they depend on each other.

```js
const DATABASES = ["Hiring/Candidate", "Hiring/Job"];
const X = " (example)";

const fails = [];
const run = async (label, p) => { try { const r = await p; log("done: " + label); return r; } catch (e) { fails.push(`${label}: ${String(e.message || e).slice(0, 200)}`); return null; } };
for (const db of DATABASES) {
  const own = (await query({query: {"q/from": db, "q/select": {n: `${db.split("/")[0]}/Name`}, "q/limit": "q/no-limit"}})).result.filter(r => !String(r.n || "").endsWith(X));
  if (own.length) { log(`STOP, ${db} holds the team's own records: ${own.slice(0, 5).map(r => r.n).join(", ")}`); throw new Error("not a fresh build: extend.md"); }
}
await run("state Take-home", update_workflow_fields({fields: [{database: "Hiring/Candidate", update: {options: [{name: "Applied"}, {name: "Screening"}, {name: "Take-home", type: "Started", color: "#1FBED3"}, {name: "Interview"}, {name: "Offer"}, {name: "Hired"}, {name: "Rejected"}]}}]}));
log(`failed ${fails.length}`); fails.forEach(x => log("FAIL " + x));
```

"STOP, … holds the team's own records" means the Space isn't fresh any more: nothing was changed, so say so and go on as an extension.

## The calls

| The person wants | Call |
|---|---|
| a field added | `create_spaces({spaces: [{name: "Hiring", databases: [{name: "Hiring/Job", fields: [...]}]}]})`, the new field as the build guide §1 writes one: it adds what's missing and skips the rest. A new database goes in the same way, in full, with its `color` and `description`. An inverse name that's taken (a people field's, a link's) is refused: number it ("Recruiting 2"). A new field starts empty on the examples, whatever its default: fill it in the same script (`update_entities`) |
| a state added, moved or removed | `update_workflow_fields({fields: [{database, update: {options: [...]}}]})`, every state in the new order: one that exists as `{name}`, a new one with its `type` and `color`. A state left out is removed, so move its examples out first (`update_entities`). A new state is in no filter that lists states by name: add it to those views and rules (the rows below), or its records vanish from them |
| a state renamed, recolored or made the default | the same call with `update: {updateOptions: [{name, newName, color, isDefault}]}` |
| a select's options changed | the same `update`, through `update_single_select_fields` or `update_multi_select_fields`, the field's full `name` beside `database` |
| a database or field renamed | `rename_databases({databases: [{from, to}]})`, full names; `rename_fields({fields: [{database, from, to}]})`. Views, formulas and rules follow. A database's rename also renames the relation fields that point to it and rewrites its name inside view names, word for word ("Report a fault" became "Report a incident", measured): read the view names back, fix one that reads wrong with `update_view({viewType, id, name})`, and tell the person which fields and views changed names |
| a field removed | `delete_fields({fields: [{database, name}]})`, after what reads it: a formula (removed too, or changed) and a rule's filter or action (`update_automation`, or the rule removed) |
| a database removed | `delete_databases({databases: [name]})`, after the views and reports built on it alone (`delete_views`) and the formulas of other databases that read through it. Its records, rules and relations go with it |
| a view or report removed | `delete_views({ids})`, the id from `query_views({space, withConfig: false})` by name |
| a rule or button removed | `delete_automation({automationType, id})`, the id from `query_automations({automationType, database})` by name |
| a formula changed | `update_formula_field({database, name, description})`, written as the build guide §2 writes one; a different result type is a `delete_fields` and a `create_formula_field` |
| a view changed | `update_view({viewType, id, config})`, the id from `query_views({space, withConfig: false})` by name, and the whole config written again from the view's data in script 3, the helpers copied from its template. Never build it from a read: a read gives filters as text, and a config sent empty or in part replaces the stored one and wipes the view (measured) |
| a rule or button changed | `update_automation`, as the build guide §5 resends one |
| an example changed, or moved to a new state | `update_entities({database, entities: [{"fibery/id": id, ...}]})`, the id from the record's Name, a state or select by name |

New views, reports, rules, buttons and examples come from the build's own scripts, sent after this one with only the new things in their data, since each skips what exists: script 3, script 4, script 5, then script 6 with `RULES` as `[{database, names}]` to turn a new rule on. A new formula is script 2.

## After the script

- **The guide.** When the change touches a line of it (a step, a view it names, a promise, a Make it yours request now done), fix that line with direct calls, loaded in one search where the client loads tools on demand: `find_document_blocks({secret, text})` returns the block with its id; `replace_block_text({secret, replacements: [{blockId, exact, replacement}]})` changes plain words; `replace_document_blocks({secret, blocks: [{blockId, content}]})` writes a line again when it mentions a view, since a mention can't be matched as text; `delete_document_blocks({secret, deletions: [{blockId}]})` drops a line. The secret is in script 3's log; in a later conversation, `query_views({id, withConfig: true})` gives it as `config.documentSecret`. A mention follows its view's new name by itself, and the mention of a removed view becomes plain words, or its line goes. Plain words follow nothing: after a rename, change them.
- **The examples.** A Description or comment of an example that speaks of something removed stays as it is: fix the Description with the same document calls, and tell the person about a comment, which can't be edited.
- **A look.** Open the view the change shows in with `fetch_view_data`, as after a build, and fix what looks wrong.
- **`design.md`.** Change the spec to match, and add a line to the Build notes ("Changed after the build: …").
- **The person.** One or two lines: what changed and the view where it shows, linked. Then anything that didn't go through, with what to do instead.
