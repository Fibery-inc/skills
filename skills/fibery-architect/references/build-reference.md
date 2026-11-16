# Build reference

Never read before the questions. Read it once the design is written, when the design has one of the shapes below; when you write a fix script; or when a script fails or logs something the build guide doesn't explain. Section numbers (§1 to §8) are the build guide's.

## Rarer shapes

**Views**, each item written as the build guide §8 writes one:

- **Nesting:** a child item has `groupBy: {parentIndex, parentField}`, the parent's to-many field that targets the child. A database nests inside itself with one item pointing at its own index through its own to-many field: `{"database": "OKRs/Objective", "groupBy": {"parentIndex": 0, "parentField": "OKRs/Supported by"}}`, with Key Result's item under index 0. Listing the database twice builds two roots, not a tree. A child item's filter hides children only: filter the parent item too when only parents with such children should show.
- **form**: any field may be on it, people, multi selects and the Description included, each with `required: true` when the spec marks it. Defaults: a string, number, boolean or ISO date; `{id}` for a select, state or to-one; `[{id}]` for a to-many; `hidden: true` keeps a defaulted field off the form. Nothing makes a form public: sharing it goes on Your turn.
- **map**: each item adds `location: f("Location")`, its location field.
- **gallery**: each item adds `cover: f("Frames")`, a files field (a gallery without one is rejected), and `fillCover: true`; lanes are `y` axes as on a board, each with `hideEmptyLanes: true`, so a lane without cards (No Craft among them) takes no room; `cardSize: "medium"`, or `"compact"` for many records. Feed, gantt, embed and canvas views: `get_fibery_skill({skill: "views"})`.

**Reports:** `add_chart_tab {reportId, title, type: "stacked-bar" | "bar" | "line", x, y, color, fieldConditions, palette}`; a horizontal bar puts the count on `x` and the category on `y`. A single number is a metric tab, `{title, metrics: [{expression: "COUNT([Id])"}]}` in the report's `tabs`, which the template adds with `add_metric_tab`; a table is `add_table_tab {reportId, title, columns, groupBy, fieldConditions}`, its columns groupings and aggregates (`[Owner]`, `QUARTER([Close date])`, `SUM([Amount])`), `groupBy` folding rows under a grouping. Expressions: `COUNT([Id])`, `SUM([Amount])`, `AVG([Score])`, a date by `YEAR`, `QUARTER`, `MONTH`, `WEEK` or `DAY` (`QUARTER([Close date])`), `AUTO([Date])`. Conditions are `{field, operator, value}`, `value` always present: a state, select, relation, text or true-or-false field takes `is in` or `is not in` with a list (`["Won"]`, `["true"]`), and `exists` or `does not exist` with `null` ("has a Close date"); a number `equals`, `greater than`, `less than`, `equals or greater than`, `equals or less than`; a date `range` (`LAST 90 DAYS`, `THIS QUARTER`, `BETWEEN 8 WEEKS AGO AND TODAY`) or `exists`. Fibery's reports guide lists the rest.

## What the calls return

For fix scripts and calls beyond the templates:

| Call | Result |
|---|---|
| `get_spaces`; `get_databases` | TOON text, which the templates' `toon` reads into objects: `.spaces[]`, each with its `name` and `databases[]`, `get_spaces` beside them `systemDatabases[]` (`fibery/user` among them). `get_databases({databases, forQuerying: true})` gives each database's `fields[]`, each with its full `name` and its `type` in the write tools' words (`text`, `number`, `rich-text`, `single-select`, `relation`, `files`, `formula`); a relation has `relatedDatabase`, `relatedField` and `cardinality`, a `...-to-many` one holding a collection; a select has `options[]` with `id` and `name`, in order; a formula its `formula` and `resultType`; and the database's `workflow.options[]` are its states, with `id`, `name` and `type`. Without `forQuerying`, also every setting the schema tools take: colors, emojis, `isDefault`, number formats. A name it doesn't find is in `notFound[]` |
| `create_spaces` | `created[]` and `unchanged[]`, a line for each thing (`"space Hiring"`, `"database Hiring/Job"`, `"field Hiring/Job.Openings"`, `"workflow Hiring/Job"`, `"comments Hiring/Job"`; an existing relation is `"relation Hiring/Candidate.Job"`), `fixLogs[]`, and `.artefacts[]` for each new Space and database only; a spec it refuses throws "Nothing was changed. Fix these and call again:" with every problem, one a line |
| `create_databases`, the field calls | `.artefacts[]`, each `value` with `fibery/id` and `fibery/name`, and a field's `description` naming its database ("Field "Hiring/Job" for Database "Hiring/Candidate" was created."), since field names repeat across databases and can equal a database's; `create_workflow_fields` gives no ids |
| `create_view`; `query_views` | `.result.id`, `.result.url`; `.views[]` with `id`, `publicId`, `name`, `viewType`, `creationDate`, `url` and `config`, a document's `documentSecret` only when asked by `id`; `viewType: "report"` finds none, so filter the result; a report's `id` is its `reportId` |
| `get_custom_apps_list` | `.result[]` with `id`, `name`, `slug`, `kind` and, for a layout app, `databaseName`; no Space, and apps outlive their Spaces |
| `read_document` | `.document`, text whose `rootBlockIds[N]` counts the top-level blocks; an empty Description or a new document has one empty paragraph |
| `get_entity_mention` | `.mention`, a string such as `[[Pipeline#^<type id>/<view id>]]`, with `database: "fibery/view"` and the view's `id` |
| `create_automation`; `query_automations` | `.automation.actions[]` with the `args` Fibery stored; `.automations[]`, each with `id`, `triggers`, `actions[]` (`id`, `name`, `args`) and a `filter` whose `filterExpression` names its values as `$where1`, their ids in `filter.params` |
| `create_report`; `get_report` | `.id` and `.url`, no tab id; `.result.tabs[]` with `id` and `title` |

## Troubleshooting

| What happened | What to do |
|---|---|
| "time is up … run this script again" | Not a failure: the script stopped before Fibery's cut-off. Send it again at once, as it is. |
| "connection lost" or "The upstream server is timing out" with no logs, a timeout or a rate limit | The script ran about a minute, or Fibery was busy. It has usually finished, or stopped part-way: wait half a minute and send the same script again, alone in its message; it does only what's missing and logs the step as a first run would. Send the next scripts one at a time until one returns. |
| Every script fails whole with "invalid response from the upstream server" or "JS Executor is down" | Fibery's script service is down, while direct calls may still work. Wait a minute or two and send one script at a time until one returns; nothing is lost, and nothing is deleted to start over. |
| "STOP, names repeat" | Two sample records of one database share a name, and script 4 finds records by name. Give each its own, a child's with its parent's, and run script 4 again; nothing was created. |
| A `TypeError` or "is not defined" | A typo or an unexpected result: log the result's keys (`Object.keys(r)`), fix the script, run it again. |
| "STOP, a Space with this name holds other databases" | The name is taken by a Space this build didn't make. Choose a free one ("Hiring 2"), update the design and run script 1 again; nothing was created, and `design.md`'s Assumptions name the Space you chose. |
| A `fixLogs` line | "Add default format…" on a number field and "Added field title…" on a view are Fibery's defaults. A renamed Space or database means the name you sent doesn't exist yet or is misspelled, and Fibery matched another one: stop. A field it created on an existing database is the build's mistake: show the person exactly what landed where, and remove it with `delete_fields` once they say yes. |
| "STOP, create_spaces: Nothing was changed. Fix these and call again" | Nothing was made. Each line names a database or field and what to fix (a name with a slash, an inverse its target already has, a target that doesn't exist): fix the data, and the design when a name changes, and run script 1 again. Another message after "STOP, create_spaces" is a call that failed: run script 1 again as it is. |
| "STOP, nothing to extend named …" | A Space without `color` or a database without `description` is one to extend, and none has that name: a misspelt name, or a new one missing its `color` or `description`. Fix the data and run script 1 again; nothing was created. |
| "Last tab cannot be deleted" | Every tab of a report was rejected, so its default tab is its only one: fix the tabs' conditions (Reports, above) and run script 3 again; it adds the missing tabs, then removes the default one. |
| "<Report> not read, left as it is" | Fibery didn't return that report, so script 3 changed nothing in it: run script 3 again. A report view that stays unreadable is empty, left by a `create_report` that failed: show it to the person and delete it only once they say yes. |
| `Invalid input` on `query`'s `q/select` | A collection selected as a path, or a sub-query whose `q/from` is a list: §4. |
| A view is rejected | Every id in its filters must be real, and each node type must match its field (build guide §8). "Unable to find axis config for …": every database in `items` needs its own `x` (and `y`) entry. |
| A formula is rejected or comes back wrong | §2: a sharper description, or the exact expression. A wrong type means delete and recreate, and a recreated field is a new one: every view and report that used it is built again, the report's chart as much as the view's columns. |
| An automation is rejected | A state or select value: the id from `enumIds`, not the name. An action that "doesn't exist": the error lists the ones there are, and `display_automations_schema` for that database gives their arguments. A formula value rejected or broken: §5. |
