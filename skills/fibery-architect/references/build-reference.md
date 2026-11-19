# Build reference

Not for the questions. Read it before `design.md` is finished when the design has one of the things SKILL.md's table lists for this file; when you repair a failure; or when a script fails or logs something the build guide doesn't explain. Section numbers (§1 to §8) are the build guide's.

## Rarer shapes

**Views**, each item written as the build guide §8 writes one:

- **Nesting:** a child item has `groupBy: {parentIndex, parentField}`, the parent's to-many field that targets the child. A database nests inside itself with one item pointing at its own index through its own to-many field: `{"database": "OKRs/Objective", "groupBy": {"parentIndex": 0, "parentField": "OKRs/Supported by"}}`, with Key Result's item under index 0. Listing the database twice builds two roots, not a tree. A child item's filter hides children only: filter the parent item too when only parents with such children should show.
- **form**: any field may be on it, people, multi selects and the Description included, each with `required: true` when the spec marks it. Defaults: a string, number, boolean or ISO date; `{id}` for a select, state or to-one, since a name is stored as raw text (measured); `[{id}]` for a to-many; `hidden: true` keeps a defaulted field off the form. Nothing makes a form public: sharing it goes on Your turn. A new record takes the select's own default (`isDefault`, script 1); a form default that differs takes its option's id: `{field: f("Source"), defaultValue: {id: REFERRAL}}`.
- **An option or a sample record by id.** A form's default, a rule's filter or value on a select (`node("single-select", f("Source"), "is-any-of", [REFERRAL])` inside `AUTOMATIONS`), and a view's filter on one sample record (`{nodeType: "reference", args: {fieldPath: [f("Job")], operator: "is", value: [DESIGNER]}}`, since a record's name is stored wrong there) take ids, looked up in the data of script 3 or 5, above `VIEWS` or `AUTOMATIONS` (measured: the form's default, the rule's filter and the view's filter were stored with the ids):

  ```js
  async function optionId(db, field, name) { return (await query({query: {"q/from": `${f(field)}_${db}`, "q/select": {id: "fibery/id"}, "q/where": ["=", ["enum/name"], name], "q/limit": 1}})).result[0].id; }
  async function recordId(db, name) { return (await query({query: {"q/from": db, "q/select": {id: "fibery/id"}, "q/where": ["q/equals-ignoring-case?", [`${db.split("/")[0]}/Name`], name + " (example)"], "q/limit": 1}})).result[0].id; }
  const REFERRAL = await optionId(C, "Source", "Referral"), DESIGNER = await recordId(J, "Product designer");
  ```
- **map**: each item adds `location: f("Location")`, its location field.
- **gallery**: each item adds `cover: f("Frames")`, a files field (a gallery without one is rejected), and `fillCover: true`; lanes are `y` axes as on a board, each with `hideEmptyLanes: true`, so a lane without cards (No Craft among them) takes no room; `cardSize: "medium"`, or `"compact"` for many records. Feed, gantt, embed and canvas views: `get_fibery_skill({skill: "views"})`.
- **A gallery's covers**, so it opens with pictures: every record on it gets a placeholder, a block in its lane's color (its state's or option's, else its database's) with its name on it, which Fibery downloads from placehold.co; a record that has a picture gets no other. It is a script of its own, sent in message 3 beside scripts 3 and 5, once the records exist; `COVERS` names each gallery's database, its files field, and each record's color by Name:

  ```js
  const S = "Studio"; const f = n => `${S}/${n}`;
  const COVERS = [{database: f("Shot"), field: f("Frames"), colors: {"Rack focus": "#2978FB", "Dolly zoom": "#4FAF54"}}];

  const err = e => String(e?.message || e).slice(0, 300), X = " (example)";
  for (const c of COVERS) {
    const rows = (await query({query: {"q/from": c.database, "q/select": {id: "fibery/id", n: `${c.database.split("/")[0]}/Name`}, "q/limit": "q/no-limit"}})).result.filter(r => c.colors[String(r.n).replace(X, "")]);
    const done = await Promise.allSettled(rows.map(r => { const name = r.n.replace(X, ""); return add_file_from_url({database: c.database, field: c.field, entityId: r.id, url: `https://placehold.co/640x360/${c.colors[name].slice(1)}/FFFFFF/png?text=${encodeURIComponent(name)}`, fileName: name + ".png"}); }));
    log(`${c.database}: ${done.filter(o => o.status === "fulfilled").length} of ${rows.length} covers`); done.forEach(o => o.reason && log("FAIL cover: " + err(o.reason)));
  }
  ```

**Reports:** `add_chart_tab {reportId, title, type: "stacked-bar" | "bar" | "line", x, y, color, fieldConditions, palette}`; a horizontal bar puts the count on `x` and the category on `y`. A single number is a metric tab, `{title, metrics: [{expression: "COUNT([Id])"}]}` in the report's `tabs`, which the template adds with `add_metric_tab`; a table is `add_table_tab {reportId, title, columns, groupBy, fieldConditions}`, its columns groupings and aggregates (`[Owner]`, `QUARTER([Close date])`, `SUM([Amount])`), `groupBy` folding rows under a grouping. Expressions: `COUNT([Id])`, `SUM([Amount])`, `AVG([Score])`, a date by `YEAR`, `QUARTER`, `MONTH`, `WEEK` or `DAY` (`QUARTER([Close date])`), `AUTO([Date])`. Conditions are `{field, operator, value}`, `value` always present: a state, select, relation, text or true-or-false field takes `is in` or `is not in` with a list (`["Won"]`, `["true"]`), and `exists` or `does not exist` with `null` ("has a Close date"); a number `equals`, `greater than`, `less than`, `equals or greater than`, `equals or less than`; a date `range` (`LAST 90 DAYS`, `THIS QUARTER`, `BETWEEN 8 WEEKS AGO AND TODAY`) or `exists`. Fibery's reports guide lists the rest. A historical report (time in state, change over time) is `mode: "historical"` in `REPORTS`, its chart's conditions starting with `{field: "Modification Date", operator: "range", value: "LAST 90 DAYS"}`; there a field that isn't part of the history is named "<Field> (current value)" (`{field: "Objective active (current value)", operator: "is in", value: ["true"]}`), as `display_report_schema({databases, sourceMode: "historical"})` lists. `display_report_schema({databases: [...], sourceMode})` only when a chart is rejected.

## The app

The spec describes the app and never contains its code: the code is written now, from the spec's "how it works" and the built Space's real names and ids. `get_fibery_skill({skill: "custom-apps-dev"})`, a direct call, never in a script, is the source of truth for the stack, the `@/lib/fibery` API, theming, the files you may change, the token (`create_custom_app_dev_token({appId})`, from a one-line script or directly) and the download and upload requests; the three rules below are this build's own and stand. The download and upload need the web, which `execute_code` has no access to: this runs in Bash.

The app script, `scripts.md` §7, comes first, in the message with scripts 3 and 5: `APPS`, `{name, kind: "view", spaceName}` for a page in the Space (without `spaceName` it lands in the private space) or `{name, kind: "layout", databaseName}` for a tab on every record page, and `APP_TOUCHES`, the databases (`C`) and fields (`[C, f("Days in stage")]`, `[C, "workflow/state"]`) its code uses. It makes the empty app and logs its id, a page app's url and mention, and those ids.

When your Agent tool can run a helper in the background, a helper of your own model then writes the app with this brief, started in a message of its own as soon as the app script has logged, while you go on to the guide. Otherwise you write it yourself after the guide: a helper call that waits holds up everything sent after it (measured in Cowork).

```
You are writing the custom app "<name>" for the new Fibery Space "<Space>". Read <path to build-reference.md>, The app,
and load Fibery's custom-apps-dev guide with get_fibery_skill. The app is made and empty; its script
logged: <the "app" and "ids for the app" lines>. The app: <kind and purpose, and "how it works" from the
spec>. Writes: <the only fields it may change>. Names: <the full name of every database and field it
touches>. Upload description: "Built by fibery-architect from the design <name>". Change nothing else in
the workspace. Reply when the upload has built, or after three failed builds with the last error.
```

1. **Write the app**, usually only `src/App.tsx`, by three rules:
   - Build exactly what "how it works" describes: what it shows, what people can click, drag or type, what it changes and when it saves, what it shows with no data. No features beyond it.
   - Look names up when the app runs, by id, because people rename things: `getSchema()` once, then `schema.getTypeObjectById(<database id>)` and `typeObject.getFieldObjectById(<field id>)` give the current names; the title field is the type's title field, the workflow field is always `workflow/state`, and a field without an id is found by its title within its database. The names are the fallback when a lookup finds nothing, and a clear message the fallback for that.
   - Change only the fields in Writes, and add no packages.
2. **Upload** as the guide says, with the app id and the token set in the same command as the request: a shell call doesn't keep the variables of the one before, and an upload without them answers "Unauthorized". If the result is `failed`, read the build output, fix the code and upload again, up to three times; then report the last error.

Without web access to the workspace, the app stays created but empty: report it as "created, not built", and give the person the "how it works" brief to paste into the app's AI builder in Fibery.

## What the calls return

For repairs and calls beyond the templates:

| Call | Result |
|---|---|
| `get_spaces`; `get_databases` | TOON text inside `execute_code`, objects when called directly: `.spaces[]`, each with its `name` and `databases[]`, `get_spaces` beside them `systemDatabases[]` (`fibery/user` among them). `get_databases({databases, forQuerying: true})` gives each database's `fields[]`, each with its full `name` and its `type` in the write tools' words (`text`, `number`, `rich-text`, `single-select`, `relation`, `files`, `formula`); a relation has `relatedDatabase`, `relatedField` and `cardinality`, a `...-to-many` one holding a collection; a select has `options[]` with `id` and `name`, in order; a formula its `formula` and `resultType`; and the database's `workflow.options[]` are its states, with `id`, `name` and `type`. Without `forQuerying`, also every setting the schema tools take: colors, emojis, `isDefault`, number formats. A name it doesn't find is in `notFound[]` |
| `create_spaces` | `created[]` and `unchanged[]`, a line for each thing (`"space Hiring"`, `"database Hiring/Job"`, `"field Hiring/Job.Openings"`, `"workflow Hiring/Job"`, `"comments Hiring/Job"`), `fixLogs[]`, and `.artefacts[]`; a spec it refuses throws "Nothing was changed. Fix these and call again:" with every problem, one a line |
| `create_databases`, the field calls | `.artefacts[]`, each `value` with `fibery/id` and `fibery/name`, and a field's `description` naming its database; `create_workflow_fields` gives no ids |
| `create_entities` | `.entities[]`, in input order, each with `fibery/id` and the Name |
| `create_view`; `query_views` | `.result.id`, `.result.url`, `.result.fixLogs`; `.views[]` with `id`, `publicId`, `creationDate`, `name`, `viewType`, `space`, `config` and `url`, in no particular order; a document asked by `id` with `withConfig: true` also has `content`, its text as Markdown (`""` when empty), and `config.documentSecret`; `query_views({space})` lists reports too, `viewType: "report"` finds none; a report's `id` is its `reportId` |
| `get_custom_apps_list` | `.result[]` with `id`, `name`, `slug`, `kind` and, for a layout app, `databaseName`; no Space, and apps outlive their Spaces |
| `read_document` | `.document`, text: a `version: N` line, then a line per block, `<id> <type> parentId=<parent id or null> [attrs] | <text>`, children indented under their parent. A block's id is the short one at the start of its line, the `blockId` the document tools take. A new document or an empty Description is exactly `version: 0\nd709 paragraph parentId=null | `, one empty paragraph |
| `get_entity_mention` | `.mention`, a string such as `[[Pipeline#^<type id>/<view id>]]`, with `database: "fibery/view"` and the view's `id` |
| `create_automation`; `query_automations` | `.automation` with `enabled`, `triggers`, `filter` and `actions[]` with the `args` Fibery stored; `.automations[]`, each with `id`, `triggers`, `actions[]` (`id`, `name`, `args`) and a `filter` whose `filterExpression` names its values as `$where1`, their ids in `filter.params` |
| `create_report`; `get_report` | `.id` and `.url`, no tab id; `.result.tabs[]` with `id` and `title` |

## Troubleshooting

| What happened | What to do |
|---|---|
| "connection lost" or "The upstream server is timing out" with no logs, a timeout or a rate limit | The script ran about a minute, or Fibery was busy, and has usually finished. Wait half a minute, read what exists (`get_databases`, `query_views({space})`, `query_automations`, a `query` of the records), and send the script with only what is missing in its data. |
| Every script fails whole with "invalid response from the upstream server" or "JS Executor is down" | Fibery's script service is down, while direct calls may still work. Wait a minute or two and send one script at a time until one returns; nothing is lost, and nothing is deleted to start over. |
| A `TypeError` or "is not defined" | A typo in the data, or an unexpected result: read the line it names, fix it, and send only what the log doesn't show as made. |
| A `fixLogs` line | "Add default format…" on a number field and "Added field title…" on a view are Fibery's defaults. A renamed Space or database means the name you sent doesn't exist yet or is misspelled, and Fibery matched another one: stop. A field created on an existing database is the build's mistake: show the person exactly what landed where, and remove it with `delete_fields` once they say yes. |
| "Nothing was changed. Fix these and call again" from `create_spaces` | Nothing was made. Each line names a database or field and what to fix (a name with a slash, an inverse name already in use, a target that doesn't exist): fix the data, and the design when a name changes, and send script 1 again. |
| Script 1 logs things "there before" on a new build | A Space of the design's name exists. Stop and tell the person the name is taken; with their word, the design takes a free one ("Hiring 2"), and script 1 goes again with it. |
| A report keeps only its "Chart" tab | Every tab was rejected: fix the tabs' conditions (Reports, above), add them with `add_chart_tab` (or the metric or table call), then `remove_tab` the default one. |
| `FAIL <database>` in script 4 | A name, state or option Fibery doesn't have, or a value of the wrong shape, failed that database's whole step, and the links to it with it: fix the data and send script 4 again with only the records not made. |
| `Invalid input` on `query`'s `q/select` | A collection selected as a path, or a sub-query whose `q/from` is a list: §4. |
| A view is rejected | Every state and option name in its filters must be spelled as stored, case included ("Value "high" is not a valid option id or name", with the valid ones listed), every record id must be real, and each node type must match its field (build guide §8); a nested item through a to-one is rejected too. "Unable to find axis config for …": every database in `items` needs its own `x` (and `y`) entry. |
| A formula is rejected or comes back wrong | §2: a sharper description, or the exact expression. A wrong type means delete and recreate, and a recreated field is a new one: every view and report that used it is built again. |
| An automation is rejected | A state or select value: the id, from `STATES` or `optionId`, not the name. An action that "doesn't exist": the error lists the ones there are, and `display_automations_schema` for that database gives their arguments. A formula value rejected or broken: §5. |

An extension's scripts (`extend-scripts.md`, and scripts 0, 4x and 3x in `extend.md`) read what exists and do only what's missing, so they log what a new build's don't:

| What happened | What to do |
|---|---|
| "time is up … run this script again" | Not a failure: the script stopped before Fibery's cut-off. Send it again at once, as it is, alone in its message. |
| "connection lost" with no logs | Wait half a minute and send the same script again, alone in its message; it does only what's missing. |
| "STOP, a Space with this name holds other databases" | The name is taken by a Space this build didn't make. Choose a free one, update the design and run script 1 again; nothing was created. |
| "STOP, create_spaces: Nothing was changed. Fix these and call again" | Nothing was made: fix the data as each line says and run script 1 again. Another message after "STOP, create_spaces" is a call that failed: run script 1 again as it is. |
| "STOP, nothing to extend named …" | A Space without `color` or a database without `description` is one to extend, and none has that name: a misspelt name, or a new one missing its `color` or `description`. Fix the data and run script 1 again; nothing was created. |
| "Last tab cannot be deleted" | Every tab of a report was rejected: fix the tabs' conditions and run script 3 again; it adds the missing tabs, then removes the default one. |
| "<Report> not read, left as it is" | Fibery didn't return that report, so script 3 changed nothing in it: run script 3 again. |
