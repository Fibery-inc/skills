# Build guide

After the yes, a build is five `execute_code` scripts, each started from its template in `scripts.md`, then the guide's two direct calls, with the app beside them. The spec you build from is `design.md`, or, for a recipe build, the recipe's Details for building with the delta in `design.md` applied on top: renames everywhere, links, additions, removals; whatever the delta doesn't mention is built as the recipe says.

Before the scripts · 1 Structure · 2 Formulas · 3 Views and reports · 4 Sample records · 5 Rules and buttons · 6 The guide · 7 The app · 8 Shapes the templates don't show · 9 Troubleshooting. The scripts' templates are in `scripts.md`, under the same numbers.

## Before the scripts

`execute_code` runs JavaScript inside Fibery. Every Fibery MCP tool is an async function there with the same name, input and result (`await create_view({...})`), and `log()` is the only output: a `return` is ignored. It is bare JavaScript, with no `fetch`, `setTimeout`, `eval` or imports, and nothing is kept from one script to the next. The tools a script calls need no loading in the client (SKILL.md, What you need): their inputs are in the templates and in §8.

| Script | Builds | Runs |
|---|---|---|
| 1 | Spaces, databases, fields, relations, people fields, links, workflows, empty apps | after the yes |
| 2 | formulas, at most two dependency levels per script | after 1 |
| 3 | views, documents and reports | after 2, in one message with 4 |
| 4 | sample records with their links, states, people, texts and comments, and the checks on stored values | with 3 |
| 5 | buttons and rules, and the checks that read formulas | after 4, so no rule fires on the sample data |
| 6 | the guide's text, then a look at the first view: two direct calls, no script | with 5 |
| App | the app's code, uploaded from Bash | after 2, beside the rest (§7) |

Scripts 1 and 2 come first because everything hangs off the fields and formulas. Scripts 3 and 4 don't depend on each other, so they go in one message. Script 5 and the guide go in the next, with any fix for script 3; a fix for script 4's records goes in a message of its own before them, since a rule created first would fire on it. The guide needs only the urls script 3 logged, and if script 5 drops a rule, the message after it corrects what the guide says about the rule. The app is the one long piece, so it alone goes to a helper when the client has an Agent tool; a script takes seconds in Fibery, and a helper would spend longer reading its brief than the script takes.

**Every script:**

- **Starts from its template** in `scripts.md`: replace the data block at the top with the spec's content, every name spelled as the spec spells it, and copy everything from `const fails = [];` down unchanged. The data uses the tools' own input shapes; anything a template doesn't show goes into the same list in the tool's shape (§8), since the fixed part sends whatever the list holds.
- **Is one step:** calls that depend on each other follow in `await` order, calls that don't run together in `Promise.all`.
- **Runs under 45 seconds.** One that runs about a minute is cut off with "connection lost" and no logs. Most calls take under a second and a `Promise.all` of 50 a second or two; what Fibery's AI writes takes 10–20 seconds (a formula, an automation's texts), so a script holds at most two formula levels or eight automations.
- **Looks ids up by name when it runs:** states and options with `enumIds`, records with `byName`, views with `query_views`, you with `get_me`; never an id pasted from an earlier result.
- **Sends every call through `run`**, which catches and records its error, so one failure never stops its neighbours; when a create that later calls need fails, the script stops with a log line and a `throw`.
- **Creates only what's missing**, reading what exists first, so a script that failed or was cut off runs again as it is (script 4 aside, §4), and a build interrupted anywhere (a client timeout, a new conversation) resumes by running the scripts again from 1, half a minute after the last one, since a script can finish after its result is lost. A schema call is atomic: one field that exists fails its whole batch.
- **Logs little:** one line per failure, counts for the rest, the checks' findings, `failed 0` when the step is done. The tool's result also lists an artefact per write; read the logs.
- **Names no variable after a tool** (`query`, `schema`, `search`): `execute_code` refuses it.
- **Is fixed by a script:** one short script in the next message fixes every failure, each call at most twice; then skip what depends on it and report it. A fix script copies the template helpers it needs: `run`; `rows`, a query's rows; `byName`, a database's records by name; `enumIds`, states (`workflow/state_<Space>/<Database>`) or options (`<Space>/<Field>_<Space>/<Database>`) by name; `day(-3)`, three days ago.
- **Stops on someone else's Space:** a `fixLogs` line that renames a Space or database means the call went somewhere else, and script 1 stops when a Space of the design's name holds databases the design doesn't have (§9).

## 1. Structure

One script, two runs when there are more than six databases (each with half of the field lists). Its data, in the spec's words:

| The spec says | In the data |
|---|---|
| text; email, url, phone | `PRIMITIVE`, `fibery/text`, with `meta: {"ui/type": "email"}` (or url, phone) |
| integer; decimal with its places | `fibery/int`; `fibery/decimal` with `meta: {"ui/number-precision": 1}` |
| money | `fibery/decimal` with `ui/number-format` Money and `ui/number-currency-code`: the currency of the workspace's money fields, or the one the person names, or USD as an assumption on the card |
| percent, as a field | `fibery/decimal` with `ui/number-format` Percent, holding a fraction (0.25 shows as 25%); a percent formula is a whole number from 0 to 100 (§2), so a threshold written for one never serves the other |
| checkbox; location | `fibery/bool`; `fibery/location` |
| date; date-time; date range | `fibery/date`; `fibery/date-time`; `fibery/date-range` (`fibery/date-time-range` when the hours matter) |
| single select; multi select | `SINGLE` with options in order and the default's name; `MULTI`, options only |
| states | `WORKFLOWS`, never a select: the states in order with the default's name; the first state and any marked "(not started)" are Not started, "(finished)" ones Finished, the rest Started |
| relation | `RELATIONS`, declared once from the side the spec names, cardinality from that side, the inverse as `relationFieldName` in its own Space |
| person; people | `PEOPLE`, many-to-one or many-to-many; the script reads `fibery/user` first, because the inverse lands on every person in the workspace, and numbers a taken name ("Recruiting 2") |
| link to an existing database | `LINKS`, in the relations' shape, the target exactly as `schema` shows it; each is sent alone, so a taken inverse fails only its call |
| files | `FILES`, with `allowMultipleFiles`; a gallery's database also goes in `AVATARS`, so its cards have a cover |
| comments; icon | `COMMENTS`; `ICONS` |
| rich text | `PRIMITIVE`, `Collaboration~Documents/Document`; every database has a Description already, and `NO_DESCRIPTION` deletes it where the spec says "no description" |
| an app | `APPS`: `{name, kind: "view", spaceName}` for a page in the Space (without `spaceName` it lands in the private space), or `{name, kind: "layout", databaseName}` for a tab on every record page; `APP_TOUCHES` names the databases and fields its code uses, so the script logs their ids for §7 |

**Colors.** Teal for the main Space, the next palette color for a second; every database its own: the main one takes its Space's color, the rest the palette in order from the color after it, skipping the three greys and wrapping to Bright red after Brown-orange. The palette: Dark gray #4A4A4A, Blue-gray #6A849B, Light gray #99A2AB, Bright red #D40915, Pink #E72065, Magenta purple #9C2BAF, Deep purple #673DB6, Blue-purple #3E53B4, Bright blue #2978FB, Sky blue #199EE3, Cyan #1FBED3, Teal #159789, Green #4FAF54, Yellow-green #8EC351, Orange #FBA32F, Red-orange #FC551F, Brown-orange #B04E31. The icon can't be set (By hand). A Space's description ends "Built by fibery-architect from <the recipe's title, or the design's name>, <date>.", so it can be recognized later.

**Descriptions.** Primitive, relation and files fields take one: what goes in the field, then why it's there, from the spec's Why ("The CV the candidate sent; the interviewers read it first"); select and workflow fields don't, so their guidance lives in the option names and the database's description.

The template is `scripts.md` §1.

## 2. Formulas

One script per two dependency levels: the formulas that use no other formula together, then the ones that use those; a third level goes in the next script. Scripts 3 and 4 wait for the last.

`create_formula_field` takes no code: Fibery writes the formula from the description, in about 11 seconds. The description is the spec's meaning in one sentence under about 280 characters (longer ones are rejected), naming every field exactly and saying the result type ("The result is a whole number" / "a decimal with one decimal place" / "text" / "true or false" / "a date" / "a date range"); when the spec gives an expression, or the formula has three or more conditions, it adds "Use exactly this Fibery formula: <expression>", and then the description can be just that and the type sentence. Fibery's syntax, as it writes it: fields in brackets (`[Stage changed on]`), or bare when one word; `If(c, a, b)`, `IsEmpty(x)`, `and`, `or`, `=`, `!=`; `State.Name = "Done"`; `Today()` and `ToDays(date - date)`; a collection's `Filter(…)`, `Count()`, `Avg(Field)`; `Greatest(a, b)`, `Round(x, places)`; a range's `Dates.Start()` and `Dates.End()`.

The type is fixed when the field is created, and `update_formula_field` keeps it:

- An average of whole numbers is typed whole unless the expression multiplies by 1.0 (`Round([Scopes].Avg([Hill position]) * 1.0, 0)` for a rounded one); `Least(100.0, …)` over an integer is rejected.
- Division, `ToDays` and `Round` (which Fibery sometimes adds itself) give decimals, and a decimal shows two places (6.00), a format nothing in Fibery MCP sets. But an `If` takes the type of its first branch, so a whole number stays whole when its formula starts with the case that gives 0, and Fibery rounds the other branch (measured): `If(IsEmpty([Stage changed on]), 0, ToDays(Today() - [Stage changed on]))` and `If(Posts.Count() = 0, 0, Posts.Filter(State.Name = "Published").Count() * 100 / Posts.Count())` are typed integer (42.857 shows as 43); the same with the branches swapped, or with a date-part fallback, are decimal. A day count therefore reads one date field, and the rule that stamps the date also fires on `created` (§5). When no 0-first form fits, accept the decimal, since thresholds work on it the same, and put its number format on the By hand list; for a recipe that said a whole number, it is also a Change row.
- A percent is a whole number from 0 to 100, its 0 case first ("the share of runs won, as a whole number from 0 to 100, 0 with no runs"), never a fraction, which people would see as 0.5714…; every threshold on it is on that scale.
- A date range is stored with an exclusive end, but in a formula `Dates.End()` is already its last day (measured): days left are `If(IsEmpty(Dates), 0, ToDays(Dates.End() - Today()))`, typed integer. `Dates.End(false)` is the stored end, a day late, and `Dates.End() - Days(1)` a day early, typed date-time; say "the last day of Dates, Dates.End()". A day count from a date-time says "the date part of Creation Date", or a record created today counts -1.
- Fibery can't write an empty branch: an `If` that should be blank in one case gets a value there (0, a far-future date) that the view filters out.

The template is `scripts.md` §2.

The log shows each formula's type and expression. Compare both with the spec before scripts 3 and 4: the type, and every condition, comparison and fallback, since Fibery's writer can drop a clause and keep the type (an At risk came back without its "Progress under 50"). A wrong type: delete and recreate in the next script, while nothing uses the field yet. A wrong expression: `update_formula_field` with "Use exactly this Fibery formula: <expression>".

## 3. Views and reports

Every view, document and report in one script: the state and option ids looked up first, the views created at once, then the reports, and every nested view read back for one root. Each view gets its type, name and config, its Space (its database's, or the one the spec names after the view's name, "Owner contacts, in Dog owners"; the guide and other documents in the main Space), and a `description`: the question it answers, in one line, the design's Answers or what the recipe's What people look at says it's for.

- Every grid gets `rowHeight: "short"`, and every grid's and list's items start their `fields` with the Name, then the spec's Shows in order: Fibery appends a missing Name as the last column.
- A calendar gets no card fields, whatever the spec's Shows says: each one squeezes the name down to its first letter, so the color carries the kind or state. A timeline bar takes one short field at most. Both use one field for start and end, a date range or a plain date or date-time, unless the spec names two.
- Children nest through a to-many relation only, one item per level and each database once; a database nests inside itself through one item pointing at its own index (§8). A view that asks to nest through a to-one is dropped and reported.
- A board or timeline groups by a state, select, relation or people, never a number, text or date: if the spec says otherwise, the spec is wrong, not the call.
- A view that filters on a specific sample record waits for the records: a short script in the message with script 5 creates it.
- A document view is created empty, with its `space`; §6 writes its text.
- A report is one tab holding one chart, never a second tab of any kind: a table, a metric or a second chart is another report. The script creates it, adds the chart and removes the empty default tab, titled "Chart", which can't be given dimensions afterwards. Rows are filtered by the tab's `fieldConditions`, never the source's `filterPrompt`, which has failed twice. Report fields are named without their Space (`[Publish date]`), the state is `State`, a relation its title, the id `Id`, and only the source's own fields are there: a condition on a linked record's state needs a formula on the source. `display_report_schema` only when a chart is rejected; Fibery's reports guide only for a historical report, which gets a 90-day condition.

The template is `scripts.md` §3.

The script ends by logging the url of every view, document and report, and each document's secret, empty or not, for §6. `VIEWS` is a function because its filters need the ids the script looks up first: `STATES` lists the databases whose states it uses, `OPTIONS` the selects. The builders: `fld` a field; `wf` a state filter; `sel` a select filter; `and` and `or`; `flag` a checkbox or true-or-false formula (`flag("Stuck")` true, `flag("Stuck", false)` false); `empty` an empty field by its node type (`empty("date", "Publish date")`; `empty("reference", "Job", "is-not-empty")` for a filled one); `mine` a "contains me" on a people field; `days` a date relative to today; `stateAxis` a board's columns; `byState` one color rule per state. Every matching color rule applies, so the rules after a red one carry its opposite, as Pipeline's amber rule does; `byState`'s third argument adds that condition to every state's rule (`byState(C, {Applied: "#99A2AB", Offer: "#FBA32F"}, flag("Stuck", false))` after the red Stuck rule).

## 4. Sample records

The records are the script's data, written from the spec's sample story and database sections: what a team a month in would have.

- **How many:** 25–40 in all, 8–15 on the main database and a few on each supporting one. A recipe's sample story names no counts: give each database what the story's moments need, past 15 on the main database when they need it (four campaigns with their posts, plus loose ideas, came to 22 posts), and keep the total inside 25–40, never past 50.
- **The story's moments exactly as told:** the hero where it stands, the late one, the stuck one; around them, records in every state, and two or more in every board column that matters.
- **Names** as the team would write them, or by the story's naming rule, and unique within a database, since the script finds records by name ("Laptop for Ana", "Laptop for Ben"); the script adds " (example)". Companies that don't exist, emails at example.com.
- **Dates** in days from the build day, spread over the past quarter and the next month; a story's "Tuesday" or "last week" is an offset too, never a calendar date.
- **Links** by the linked record's name; **people** as `"me"`.
- **One hero per main database**, with its Description in Markdown showing how the team writes one.
- **Every field a role fills every time**, filled, and every field a rule of script 5 keeps (a date stamped on a state change), filled from the story, since those rules come after the records.
- **The promises kept:** every record satisfies What must stay true as if the rules had run. A shipped pitch has every scope Done; a key result with a Last check in has the check in behind it; an official match calls only Match ready strats. A Space that contradicts its own promises on day one teaches the wrong habit.

Invent freely around the story, but never a real person, company or record of the workspace, and never a link to an existing database's records.

`CHECKS` hold one line per promise on stored values, or per Must hold cell, each a query's `select` and a `bad` test that finds the records breaking it (pitches in *Bet* with no appetite; *Shipped* pitches with a scope not *Done*). Decimal values come back from `query` as strings ("25"), so a check compares `Number(r.x)`. A promise kept in comments selects them, `cs: {"q/from": "comments/comments", "q/select": {id: "fibery/id"}, "q/limit": 1}`, with `bad: r => … && !r.cs.length`. A check that reads a formula goes in script 5, since Fibery recomputes formulas a few seconds after the writes. Fix the data in the next script until every check holds; a promise no query can see (a practice, an app's behaviour) is reported as not checked.

The template is `scripts.md` §4.

A record's keys are field names without the Space; the script reads each field's type and converts:

| Key | Value |
|---|---|
| `Name` | the name; the script adds `X` (" (example)") |
| `state` | the state's name |
| a to-one relation | the linked record's Name |
| a to-many relation | a list of Names |
| a person, people | `"me"`, `["me"]` |
| a single select | the option's name |
| a multi select | a list of option names |
| a date | days from today (`-3`), or `"YYYY-MM-DD"` |
| a date-time | `[days, "HH:MM"]`, UTC |
| a date range | `[first day, last day]` in days from today; the script stores the exclusive end |
| a rich text field (Description) | Markdown |
| `comments` | a list of comments in Markdown |
| a date inside a text or comment | `${day(-2)}` in a template string, since `day` is defined above the data |
| anything else | the value as Fibery takes it: a number, text, true or false, a percent field as a fraction |

Databases may come in any order: to-one links are set once every record exists. Only the records a run creates get their links, states, collections, texts and comments, so running it again never doubles them; an existing record is changed by a short script. So a script 4 cut off before its log is not run again as it is: delete the records it made (`delete_entities` with the ids of the records named "… (example)") and run it again. A file field stays empty, since a sample file would have to come from a real address on the web; leave its key out, and the report says so.

## 5. Rules and buttons

One script after script 4 (two past eight automations), since a rule created earlier would fire on the sample data as it is written. A schedule starts the day after the build, at the spec's time, in UTC, and the card, the guide and the report say "UTC" next to the time. A rule that stamps a date on a change gets `created` as a second trigger, so every new record has the date and the day count that reads it stays a whole number (§2); the sample records carry theirs from script 4. `CHECKS` hold the promises that read formulas, which Fibery has recomputed by now (§4).

- **Native actions only.** A rule or button never uses the `Script` action, whatever the spec says; `execute_code` builds the Space and never becomes part of it. Its condition is the filter, its texts are templates, and a rule with two conditions becomes two rules. When no native action does what a rule needs (a comment on a linked record, a check before acting, a value found by searching other records, email), or an action is rejected and §8 gives no native shape, the rule is not built: the report lists it under Not built, and the guide names the step as done by hand.
- **Buttons take no filter and can't check:** a button acts whatever the record's state, so its description and the guide say when to press it.
- **Texts and formula values are prompts**, and Fibery writes the result (10–20 s each): "a short note naming who clicked the button and the publish date", never the finished text. A prompt names the literal words a text must contain: "The words 'Interview today:' followed by the interview's Name" came back as `Interview today: {{Name}}`, where "The interview's Name is today" came back as a bare date.
- **Read back what Fibery stored:** the script logs each automation's triggers, stored filter and actions; read the filter and every text and formula value against the spec. Resend once, in the next script, with `update_automation` and a sharper prompt when one names a field the database doesn't have, multiplies a 0–100 value by 100 ("followed by a percent sign, never multiplied"), picks the wrong record ("the last item" for the one just added), or points at a field off the path; still wrong, drop the action, or the rule when the action is its point, and list it under Not built.
- **Existing databases:** a filter through a link to one is fine (read its `schema_detailed` for exact names); an action that writes to its records reaches outside the Space, so it exists only if the card listed it and the person said yes.
- `display_automations_schema` only when an action is rejected by name: its catalog is 15K tokens of integrations.

The template is `scripts.md` §5.

The builders: `wf`, `and`, `or`, `flag`, `empty` and `days` as in §3; `stateValue` sets a state; `tpl` a text and `formula` a value Fibery writes from a prompt; `tomorrowAt(8)` a schedule's first run. Other triggers, actions and values: §8.

## 6. The guide

Written once the views exist, in the message with script 5, because its text links to them. It takes two direct calls, no script.

**Its text.** For a design from scratch, the guide the design guide describes, 150–450 words. For a recipe build, the recipe's own story with no word count, in the document named after it ("How to run Shape Up"): from the promise through What must stay true, in the recipe's order and words, with the delta applied (every rename, removal and Making it yours bullet taken, so nothing the guide names is missing); its "In any work tool, this becomes…" paragraph rewritten as what this Space is, in Fibery's words (the databases, the view people live in, the rule or button that makes the method the method); the workspace's specifics written in where the recipe left a choice; a What must stay true that keeps every ★ promise with what keeps it, and names a rule that wasn't built as a practice; then For AI agents, with its "Try asking" prompts. Making it yours and Details for building are left out: the choices are made, and the Space is the details.

**Its links.** Every view, form, report, document and app named in What people look at is a link there, the guide itself aside; elsewhere a view is a link at its first mention in each section. A layout app has no url: name it as a tab on every record of its database. Rules, buttons, databases, fields, states and records stay plain names, so the guide reads as a story whose doors are the views. A view that failed is named without a link, and the guide says so.

**The calls.** Write each link with its url from script 3's log: `[Pipeline](https://…/4163)`. Then, in the message with script 5, `insert_document_blocks` (no Fibery skill to load first) with the document's secret from the same log and the whole text in one insert, `{parent: {blockId: null, position: "end"}, content: <text>}`, sent only when that log says the document is empty, so a resumed build never writes it twice; and `fetch_view_data` for the first view, its `publicId` the last part of its url, with `limit: 5`. Read those cards as the person will see them and fix what looks wrong before the report. Any other document in the spec is written the same way.

## 7. The app

The spec describes the app and never contains its code: the code is written now, from the spec's "how it works" and the built Space's real names and ids, so it matches both and today's app platform. `get_fibery_skill({skill: "custom-apps-dev"})` is the source of truth for the stack, the `@/lib/fibery` API, theming, allowed packages, the files you may change, the token (`create_custom_app_dev_token` with the app id; it lasts about an hour and is never written into a file) and the download and upload requests; where it disagrees with this page, follow it. The download and upload need the web, which `execute_code` has no access to: this runs in Bash.

With an Agent tool, a helper of your own model builds the app, started right after script 2 with this brief, while you run scripts 3 to 5 and the guide; without one, build it yourself after the guide.

```
You are building the custom app "<name>" for the new Fibery Space "<Space>". Read <path to this file> §7,
then load Fibery's custom-apps-dev guide with get_fibery_skill. The app: <kind and purpose, and "how it
works" from the spec>. Writes: <the only fields it may change>. Names: <the full name of every database
and field it touches>. Ids: <the ids scripts 1 and 2 logged for them>. App id: <id>. Upload description:
"Built by fibery-architect from the design <name>". Change nothing else in the workspace. Reply when the
upload has built, or after three failed builds with the last error.
```

1. **Write the app**, usually only `src/App.tsx`, by three rules:
   - Build exactly what "how it works" describes: what it shows, what people can click, drag or type, what it changes and when it saves, what it shows with no data. No features beyond it.
   - Look names up when the app runs, by id, because people rename things: `getSchema()` once, then `schema.getTypeObjectById(<database id>)` and `typeObject.getFieldObjectById(<field id>)` give the current names; the title field is the type's title field, the workflow field is always `workflow/state`, and a field without an id is found by its title within its database. The names are the fallback when a lookup finds nothing, and a clear message the fallback for that.
   - Change only the fields in Writes, with the guide's helpers (`queryEntities`, `updateEntity`, `openEntity`, `getSchema`; their signatures are in the guide or in `src/lib/fibery.ts`), React Query, theme tokens instead of fixed colors, visible error messages and no new packages.
2. **Upload** as the guide says (when Node and pnpm are available, `pnpm install`, `pnpm exec tsc --noEmit` and `pnpm exec vite build` first catch errors sooner, but the server's build is the one that counts). If the result is `failed`, read the build output, fix the code and upload again, up to three times; then report the last error.

Without web access to the workspace, the app stays created but empty: report it as "created, not built", and give the person the "how it works" brief to paste into the app's AI builder in Fibery.

## 8. Shapes the templates don't show

**Views**, `create_view {viewType, name, space, description, config}`:

- An item is `{database, fields, filter, orderBy, colorCoding}`. A field is `{field: "Space/Field"}`, the state `{field: "workflow/state"}`, a collection shown as a count adds `showCount: true`; a sort is `{field, direction}`, with `dateRangeSortBy: "start"` or `"end"` on a range.
- **list**: a grid without `rowHeight`. **board**: `x` and `y` axes, one entry per items database, each `{forDatabase, field, database, fields: []}` naming a lookup database, `workflow/state_<Space>/<Db>` for states, `<Space>/<Field>_<Space>/<Db>` for a select, the target database for a relation or link, `fibery/user` for people; `y` may be `[]`. A timeline's lanes are `y` axes the same way.
- **Nesting:** a child item has `groupBy: {parentIndex, parentField}`, the parent's to-many field that targets the child. A database nests inside itself with one item pointing at its own index through its own to-many field: `{"database": "OKRs/Objective", "groupBy": {"parentIndex": 0, "parentField": "OKRs/Supported by"}}`, with Key Result's item under index 0. Listing the database twice builds two roots, not a tree. A child item's filter hides children only: filter the parent item too when only parents with such children should show.
- **form**: any field may be on it, people, multi selects and the Description included, each with `required: true` when the spec marks it. Defaults: a string, number, boolean or ISO date; `{id}` for a select, state or to-one; `[{id}]` for a to-many; `hidden: true` keeps a defaulted field off the form. Nothing makes a form public: sharing it is By hand.
- Map, feed, gallery, gantt, embed and canvas views: `get_fibery_skill({skill: "views"})`.

**Filter nodes**, `{nodeType, args: {fieldPath, operator, value}}`, without `value` for `is-empty` and `contains-me`:

| nodeType | fieldPath and operators | value |
|---|---|---|
| `workflow` | `["workflow/state"]`; `is-any-of`, `is-none-of` | a list of state ids |
| `single-select` | `is-any-of`, `is-none-of`, `is-empty` | a list of option ids, even for one |
| `reference` (to-one) | `is`, `is-not`, `is-empty`, `is-not-empty` | a record id |
| `collection` (to-many) | `is-empty`, `is-not-empty`, `contains-any-of`; `contains-me` on a to-many people field only | record ids |
| `number` | `greater-than-or-equal`, `less-than`, `equals`, `is-empty` | a number |
| `bool` | `is` | true or false |
| `text` | `is-empty`, `contains` | a string |
| `date` | `is`, `is-before`, `is-after`, `is-on-or-before`, `is-on-or-after`, `is-empty` | `"YYYY-MM-DD"`, or `{amount, unit: "day", isBeforeNow}` with all three keys |

Relative dates: "is today" is `is` with `{amount: 0, unit: "day", isBeforeNow: false}`; "before today" is `is-before` with `{0, "day", true}`, the start of today, on date-times too; "in the next 7 days" is `is-on-or-after` `{0, "day", false}` and `is-on-or-before` `{7, "day", false}`; "more than 14 days ago" is `is-before` `{14, "day", true}`. A to-one person field has no "me": a "My …" view needs a people field. A range's start or end is `["q/start", "Space/Dates"]` or `["q/end", …]`, the end being the stored one, a day after the last; a linked record's field chains, `["Space/Pitch", "workflow/state"]`; `{nodeType: "logical", args: {operator: "and" | "or", filters: [...]}}` nests.

**Rules and buttons**, `create_automation {automationType, database, name, description, triggers, filter, actions}`:

- **Triggers** besides `created`, `updated` and a daily schedule: `{trigger: "collection-item-added", args: {changedCollectionField: "Space/Seen in"}}` (`collection-item-removed` likewise), either one the rule's only trigger; a weekly schedule, `settings: {unit: "week", time: {hour: 9, minute: 0}, daysOfWeek: ["monday"]}`. `created` and `updated` in one rule fire it on either.
- **Actions**, by name: "Update" this record; "Update <Relation>" its linked records, with a `filter` on them when the relation is to-many (a to-one takes only `fields`: put the condition in the rule's own filter, chained through the relation); "Add <Relation> Item" creates a record linked through a to-many, "Add <Relation>" through a to-one, their `fields` the linked database's; "Unlink <Relation>"; "Add comment", on this record only; "Notify <People field>" with `subject` and `message`, or "Notify Users" with `to: {type: "formula", prompt: "the creator"}`; "Append content to <field>"; "Send Web Request". State and select values go by id.
- **Values:** `{type: "value", value}` with a literal, `{"fibery/id"}` for a state, option or record, or a list of those; `{type: "formula", prompt}`, also for a value carried from a linked record ("the Next cycle of this pitch's Betting table"); `{type: "template", prompt}`; `{type: "empty"}`; `{type: "user-provided-value"}` on a button. Prompts are plain words naming fields exactly, never code or formula syntax.

**Reports:** `add_chart_tab {reportId, title, type: "stacked-bar" | "bar" | "line", x, y, color, fieldConditions, palette}`; a horizontal bar puts the count on `x` and the category on `y`. A single number is a metric report, the template's three calls with `add_metric_tab {reportId, metrics: [{expression: "COUNT([Id])"}]}` in place of the chart. Expressions: `COUNT([Id])`, `SUM([Amount])`, `AVG([Score])`, `MONTH([Date])`, `AUTO([Date])`. Conditions: `{field: "State", operator: "is in", value: [...]}`, `{field: "Creation Date", operator: "range", value: "LAST 90 DAYS"}`; ranges such as `THIS QUARTER` and `BETWEEN 8 WEEKS AGO AND TODAY`.

**What the calls return**, for fix scripts and calls beyond the templates:

| Call | Result |
|---|---|
| `schema`, `schema_detailed` | `{schema}`, YAML text: a `- name: <Space>` line per Space and a `<Space>/<Database>,` line per database; in `schema_detailed`, a field is a line `    <Space>/<Field>:` in its database's section, a formula's line ending with its type and expression |
| `create_space`, `create_databases`, the field calls | `.artefacts[]`, each `value` with `fibery/id` and `fibery/name`; `create_workflow_field` and `create_comments_fields` give no ids |
| `query` | `.result`, the rows, and `.hasNext` |
| `get_me` | `.result[0]["fibery/id"]` |
| `create_view`; `query_views` | `.result.id`, `.result.url`; `.views[]` with `id`, `publicId`, `name`, `url`, and `config` only when asked by `id` with `withConfig: true` |
| `create_automation`; `query_automations` | `.automation.actions[]` with the `args` Fibery stored; `.automations[]`, each with `triggers` and `filter.filterExpression` |
| `create_report`; `get_report` | `.id` and `.url`, no tab id; `.result.tabs[]` with `id` and `title` |

## 9. Troubleshooting

| What happened | What to do |
|---|---|
| "connection lost" with no logs, a timeout or a rate limit | The script ran about a minute, or Fibery was busy. What it made may exist and may still be finishing: wait half a minute, split the script if it was long, and run it again; it creates only what's missing (script 4: §4). |
| Every script fails whole with "invalid response from the upstream server" | Fibery's script service is down, while direct calls may still work. Wait a few minutes and send one script at a time until one returns; nothing is lost, and nothing is deleted to start over. |
| A `TypeError` or "is not defined" | A typo or an unexpected result: log the result's keys (`Object.keys(r)`), fix the script, run it again. |
| "STOP, a Space with this name holds other databases" | The name is taken by a Space this build didn't make. Choose a free one ("Hiring 2"), tell the person, update the design and run script 1 again; nothing was created. |
| A `fixLogs` line | "Add default format…" on a number field and "Added field title…" on a view are Fibery's defaults. A renamed Space or database means the name you sent doesn't exist yet or is misspelled, and Fibery matched another one: stop. A field it created on an existing database is the build's mistake: show the person exactly what landed where, and remove it with `delete_fields` once they say yes. |
| A link's inverse "already exists" on the existing database | Choose another name from its `schema_detailed`, tell the person and wait for their yes, since it's a field on their database; then send only that link, and update the design. |
| A view is rejected | Every id in its filters must be real, and each node type must match its field (§8). "Unable to find axis config for …": every database in `items` needs its own `x` (and `y`) entry. |
| A formula is rejected or comes back wrong | §2: a sharper description, or the exact expression. A wrong type means delete and recreate, and a recreated field is a new one: every view and report that used it is built again, the report's chart as much as the view's columns. |
| An automation is rejected | A state or select value: the id from `enumIds`, not the name. An action that "doesn't exist": the error lists the ones there are, and `display_automations_schema` for that database gives their arguments. A formula value rejected or broken: §5. |
| App upload `409 session_busy` or `401 dev_token_invalid` | 409: someone is using Fibery's AI on this app, wait a minute; 401: the token expired, create a new one. Then retry once. |
