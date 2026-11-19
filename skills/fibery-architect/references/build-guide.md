# Build guide

A build is six `execute_code` scripts, each started from its template in `scripts.md`, and the guide's two direct calls, with the app beside them. The spec you build from is `design.md`. An extension of a Space the team already runs builds no sample records and uses guarded templates of its own: `extend.md` and `extend-scripts.md`, whose data is written as this guide says.

Before the scripts · 1 Structure · 2 Formulas · 3 Views and reports · 4 Sample records · 5 Rules and buttons · 6 The guide and the last checks · 7 The app · 8 Shapes the templates don't show. The templates are in `scripts.md`, under the same numbers; rarer shapes, what each call returns and the troubleshooting table are in `build-reference.md`, read when SKILL.md's table says.

## Before the scripts

`execute_code`'s own description says how a script runs. What it doesn't say: `get_fibery_skill` isn't there (call it directly), and the tools a script calls need no loading in the client (SKILL.md, What you need): their inputs are in the templates and in §8.

Four messages, each once the one before has answered:

1. **Script 1**, the structure and the guide's empty document: everything else hangs off them. Its log gives the Space's address, for the one line said while the build runs (SKILL.md §5).
2. **Scripts 2 and 4, in one message:** the formulas, which read script 1's fields, and the sample records, which need only the structure and are written while Fibery writes the formulas.
3. **Scripts 3 and 5, in one message,** with the app script when there's an app (§7): views and reports, rules and buttons, the empty app. Views and rules read the formulas; rules are made on, since the records are in and a rule fires only on what changes after it exists.
4. **The guide's two calls and script 6** (§6): the guide mentions what the other scripts made, and script 6 checks the sample story's promises, formulas recomputed by now.

A script with nothing in its data (no formulas, no rules) isn't sent. The app's code comes after message 3: from a helper started in a message of its own as soon as message 3 has answered, when your Agent tool can run one in the background, or from you after the guide (§7). Then the report, once a helper is back.

**Every script:**

- **Starts from its template:** replace the data block at the top with the spec's content, every name spelled as the spec spells it, and copy everything from `const err` down unchanged. Write it straight into the `execute_code` call: `execute_code` reads no files, so a script assembled in a file first is typed twice. The data uses the tools' own input shapes; anything a template doesn't show goes into the same list in the tool's shape (§8), since the fixed part sends whatever the list holds.
- **Runs once.** It makes what its data holds and logs one line per failure, `FAIL …`, beside what it made and what Fibery stored. A script is never sent again as it is, since what it made would be made twice or refused. After a failure, repair only what failed: a direct call (`update_formula_field`, `update_automation`, `create_view`, `update_entities`), or the same script with only what is missing in its data. Fixes for scripts 3 to 5 go in a message of their own before the guide's, so the guide mentions what exists.
- **Takes names where Fibery does:** a view takes state and option names; a rule takes ids, which script 5 looks up from `STATES`. Never an id pasted from an earlier result of another build, and never a name matched across the workspace: `get_reports_list` and `search` return every Space's views, deleted Spaces' reports included.
- **Stops the build on someone else's Space:** a `fixLogs` line that renames a Space or database means the call went somewhere else, and on a new build, `create_spaces` logging anything "there before" means a Space of the design's name exists: stop and tell the person the name is taken (`design.md` names a free one, "Hiring 2", once they agree).

## 1. Structure

One `create_spaces` call makes every Space, database and field, a second or two, then the script makes the guide's document, sets the defaults and reads the emojis back. `create_spaces` checks the whole spec before it changes anything, so a spec it refuses has made nothing: the error lists every problem, one a line; fix the data, and the design when a name changes, and send script 1 again. Its data is the call's input, in the spec's words, each field by its full name (`f("Email")`) and in the spec's order:

| The spec says | In the data |
|---|---|
| a Space | an item of `spaces`: its `name`, `color` (Colors, below) and `databases`. A Fibery Space has no description |
| a database | an item of its Space's `databases`: its `name` (`"<Space>/<Database>"`), `color`, `description` and `fields`, and `comments: true`, `icon: true` or `avatar: true` where the spec has them. Name and Description come with every database: leave them out of `fields` |
| text, number, checkbox, place, date | `{name, type}`: `text`, `email`, `url`, `phone`, `number` (a whole number; `numberPrecision: 1` beside it for one decimal place), `checkbox`, `location`, `date`, `date-time`, `date-range` (`date-time-range` when the hours matter) |
| a number's unit | `numberUnit: "h"`, only where the number alone is ambiguous (a time, length, weight or size measured in more than one unit), never for a score, a count, money or percent; the short form, which Fibery never pluralizes: h, min, d, wk, km, mi, kg, GB. A formula can't take one yet |
| money | `type: "number", numberFormat: "Money"`, in USD, or with `numberCurrencyCode: "EUR"`: the workspace's money fields' currency, the one the person names, or USD, an assumption `design.md` names |
| percent, as a field | `type: "number", numberFormat: "Percent"`, holding a fraction (0.25 shows as 25%); a percent formula is a whole number from 0 to 100 (§2), so a threshold for one never serves the other |
| single select; multi select | `type: "single-select"` or `"multi-select"` and its `options` in order, each `{name, color, icon}`; a single select's default has `isDefault: true` |
| states | the database's `workflow`, never a select: `{options}`, the states in order, each `{name, type, color}`; the first and any marked "(not started)" are Not started, "(finished)" ones Finished, the rest Started. The first is the default, unless another has `isDefault: true` |
| relation | `type: "relation"` with `relatedDatabase`, `relatedField` and `cardinality`, declared once, on the side the spec names: the other database, the inverse's full name in that database's Space (`f("Candidates")`), and the cardinality from this side (`many-to-one`: many of these to one of those) |
| person; people | a relation to `fibery/user`, its inverse `user/<name>`: many-to-many for a role a "My …" view filters on, even when one person holds it, since "contains me" works on a to-many people field only; many-to-one otherwise |
| link to an existing database | a relation on the new database, the target exactly as `get_spaces` shows it and the inverse in the target's Space |
| files | `type: "files"`, with `allowMultipleFiles: false` for one file; a gallery's cover is one (`build-reference.md`) |
| rich text | `rich-text`; `NO_DESCRIPTION` lists the databases whose Description the spec says "no description" to, and the script deletes it |
| a field's description | `description` beside its `type`, only as Descriptions, below, says |
| a default | an item of `DEFAULTS`, `{database, name, defaultValue}`: a number, a text, `true` for a ticked checkbox, a fixed date as "YYYY-MM-DD". A select's default is its option's `isDefault` and a workflow's its state's; a date that starts as today can't be set and goes on Your turn. `[]` when the spec gives none |
| the guide | `GUIDE`, the document How to run <process>, in the main Space, made before any other view so it comes first in the Space; §6 writes its text. `null` makes none |

**A taken inverse name.** A people field's inverse lands on every person in the workspace, and a link's on the existing database, so its name may be taken: `create_spaces` then refuses the whole spec with `Field name "user/Recruiting" is already in use in "fibery/user"`, one line per name. Rename each ("Recruiting 2", or a clearer "Recruiting hires"), send script 1 again, and say so in the Build notes.

**Colors.** Every database gets the palette color its name brings to mind (a Cat light gray, a Clinic day bright red, an Invoice green), the main database first, then the spec's order. No two share a color or a near twin (Orange, Red-orange and Brown-orange; Green and Yellow-green; Sky blue and Cyan; Deep purple and Blue-purple; the greys): take the next best fit, and a name that suggests nothing takes a free color far from the others, never a grey. A Space takes its first database's color. The palette: Dark gray #4A4A4A, Blue-gray #6A849B, Light gray #99A2AB, Bright red #D40915, Pink #E72065, Magenta purple #9C2BAF, Deep purple #673DB6, Blue-purple #3E53B4, Bright blue #2978FB, Sky blue #199EE3, Cyan #1FBED3, Teal #159789, Green #4FAF54, Yellow-green #8EC351, Orange #FBA32F, Red-orange #FC551F, Brown-orange #B04E31.

**Option emojis.** Every option gets the emoji a person would pick: priorities (High `:fire:`, Low `:snowflake:`), health (`:large_green_circle:`, `:red_circle:`), channels (`:email:`, `:speech_balloon:`), kinds and sizes; none on options that are names (places, people, products, departments) or in lists longer than about eight; states can't take one. The `icon` is a shortcode with colons, as Slack names emojis: an unknown one, a raw emoji or an empty string is stored as a random emoji (measured), so the script logs every icon stored differently. An alias is fine (`:thumbsup:` comes back `:+1:`); for any other, send `update_single_select_fields` or `update_multi_select_fields` with `update: {updateOptions: [{name, icon}]}` and another shortcode.

**Descriptions.** A field or select gets one only when its name leaves a question: a scale or a period ("1 to 5, 5 a strong hire", "per year"), what counts, or that a rule fills it ("Set by Stage changed when the state changes"); Email, Resume, Recruiter or Due date need none. The workflow can't take one: the states' guidance lives in their names and the database's description.

## 2. Formulas

`LEVELS`, in dependency order: the formulas that use no other formula, then those that use them, and so on. A level's formulas are written in parallel, about 10 seconds a level, so four levels or more go as two scripts, the second with the later levels, in the same message.

`create_formula_field` takes no code: Fibery writes the formula from the description. The description is the spec's meaning in one sentence, naming every field exactly and saying the result type ("The result is a whole number" / "a decimal with one decimal place" / "text" / "true or false" / "a date" / "a date range"); when the spec gives an expression, the formula has three or more conditions, its result is money, or it divides, averages or counts a share, it adds "Use exactly this Fibery formula: <expression>", and then the description can be just that and the type sentence (408 characters were accepted, measured): left to itself, Fibery's writer wraps a share in `Round` (which makes it decimal), types money as a whole number, and adds clauses of its own. Fibery's syntax: fields in brackets (`[Stage changed on]`), or bare when one word; `If(c, a, b)`, `IsEmpty(x)`, `and`, `or`, `=`, `!=`; `State.Name = "Done"`; `Today()` and `ToDays(date - date)`; a collection's `Filter(…)`, `Count()`, `Sum(Field)`, `Avg(Field)`, `Max(Field)`; a linked record's field `[Job].[Openings]`; `Greatest(a, b)`, `Round(x, places)`; a range's `Dates.Start()` and `Dates.End()`.

The type is fixed when the field is created, and `update_formula_field` keeps it:

- An average of whole numbers is typed whole, `If([Parts].Count() = 0, 0, [Parts].Avg([Score]))`, and needs no `Round`: `Round` or `Least(100.0, …)` over a whole number is rejected ("Expected argument of type 'Decimal' but 'Integer' found"), and multiplying by 1.0 makes it a decimal (measured).
- Division, `ToDays` and `Round` give decimals, shown with two places (6.00), a format nothing in Fibery MCP sets. An `If` takes the type of its first branch, so a whole number stays whole when its formula starts with the case that gives 0 (measured): `If(IsEmpty([Stage changed on]), 0, ToDays(Today() - [Stage changed on]))` is typed integer; swapped, or with a `Round` in the other branch, it is decimal, while `Greatest` and `Least` over whole numbers stay whole. The other way too: a decimal or money result with a 0 case writes it `0.0` (measured). So a day count reads one date field, and the rule that stamps it also fires on `created` (§5). When no 0-first form fits, accept the decimal and put its number format on the report's Your turn.
- A percent is a whole number from 0 to 100, its 0 case first ("the share of runs won, as a whole number from 0 to 100, 0 with no runs"), never a fraction; every threshold on it is on that scale. It multiplies by 100 once: Fibery's writer has multiplied a share by 100 both inside and outside the division, so check the expression.
- A date range's `Dates.End()` is its last day in a formula (measured): days left are `If(IsEmpty(Dates), 0, ToDays(Dates.End() - Today()))`. A day count from a date-time says "the date part of Creation Date", or a record created today counts -1. Formulas have no `Now()`: Fibery writes `Today()` instead, so a date-time compared in a formula turns true only when the day turns; a red card at the exact moment is a view filter in minutes (§8).
- Fibery can't write an empty branch: an `If` that should be blank in one case gets a value there (0, a far-future date) that the view filters out.

The log shows each formula's type and expression. Compare both with the spec before the next message: the type, and every condition, comparison and fallback, since Fibery's writer can drop a clause or add one and keep the type. A wrong expression: `update_formula_field({database, name, description})`, the field's full name and "Use exactly this Fibery formula: <expression>". A wrong type: `delete_fields`, then script 2 again with only that formula, while nothing uses it yet.

A report that keeps only some linked records (only key results whose objective is Active) needs a true-or-false formula on its source ("Objective active"), since a report filters on its source's own fields: the design lists it with the formulas.

## 3. Views and reports

Every view and report in one script: the views one at a time, in the order of `VIEWS`, which is the order they take in the Space after the guide, then the reports, then the url and mention of each and the secret of every empty document. Each view gets its type, name, config, its Space when it isn't the main one (`space: "Dog owners"`, as the spec names it after the view's name), and a `description`: the question it answers, in one line, the design's Answers.

- Every grid gets `rowHeight: "short"`, and every grid's and list's items start their `fields` with the Name: Fibery appends a missing Name as the last column. After the Name, the spec's Shows go in the order a person reads a row, on cards too: what the record is part of (Job on a Candidate); where it stands (the state, Days in stage, a flag); who (the people fields); what kind (the selects); when (dates in the order they happen); how much (numbers, money); then contact details, other links and text. A formula sits right after the field it reads (Openings, Hired, Open seats), a pair side by side (Salary min, Salary max). Nested items are ordered the same way.
- A view shows its database's own fields only: a linked record's field is a formula on the database (`[Customer].Phone`, §2). A path such as `{field: ["Shop/Customer", "Shop/Phone"]}` and an unknown field are dropped without an error.
- A calendar gets no card fields: each squeezes the name to its first letter, so the color carries the kind or state. A timeline bar takes one short field at most. Both use one field for start and end, unless the spec names two.
- Children nest through a to-many relation only, one item per level and each database once; a nested item through a to-one is rejected. A database nested in itself: `build-reference.md`.
- A board or timeline groups by a state, select, relation or people, never a number, text or date; a list or grid groups by nesting only. Cards that show a picture make a gallery, even where the spec says board, since a board drops a cover without an error (`build-reference.md`).
- A form's select default that differs from the field's own, and a view that filters on a specific sample record, take ids looked up in the data above `VIEWS` (`build-reference.md`).
- A report is one per database and mode, its tabs in the spec's order: the script creates it, adds the tabs one at a time, then removes the default tab, "Chart". The source's filter is the report's `filter`, sent as `filterPrompt`: one sentence naming the fields exactly ("only candidates that have a Job"), which Fibery turns into a query filter; the log shows what it stored: compare it with the spec, and resend a wrong one, sharper, with `update_report({reportId, sources: [{database, filterPrompt}]})`, which keeps the tabs. A relative date stays out of it ("created this year" was stored as 2026-01-01): dates and what one tab keeps are its `fieldConditions`. Report fields are named without their Space (`[Publish date]`), the state is `State`, a relation its title, the id `Id`; a true-or-false field and a relation are text there (`{field: "Strat retired", operator: "is in", value: ["false"]}`), and only the source's own fields are there. A historical report is `mode: "historical"`; metric and table tabs and every condition: `build-reference.md`.

The builders, one line each in the template and declared so the data can call them: `fld`, `wf`, `sel`, `and`, `or`, `flag`, `num`, `empty`, `mine`, `days`, `stateAxis`, `selAxis` (a board's rows by a select), `byState`. A view takes states and options by name, case included: a wrong one is rejected with the valid ones listed. A filter several views share is a constant at the top (`const LATE = days("Due", "is-before", 0, true)`); `days` counts in days unless its fifth argument names another unit (`"minute"`). Every matching color rule applies, so the rules after a red one carry its opposite, as Pipeline's amber rule does; `byState`'s third argument adds that condition to every state's rule.

The log gives each view's and report's url and mention, any `fixLogs` beyond Fibery's defaults, the report's stored filter, and each empty document's secret and block, for §6.

## 4. Sample records

The records are the script's data, written from the spec's sample story and database sections: what a team a month in would have.

- **How many:** the total the design's story gives, 25–40 in all, 8–15 on the main database and a few on each supporting one; more only when the story's moments and promises need them, never past 50.
- **The story's moments exactly as told:** the hero where it stands, the late one, the stuck one; around them, records in every state, and two or more in every board column that matters.
- **Names** as the team would write them, unique within a database, since links find records by name: a child's name carries its parent's ("Laptop for Ana"; "Day 30 check-in, Ana"). The script adds " (example)". Companies that don't exist, emails at example.com.
- **Dates** in days from the build day, spread over the past quarter and the next month; a story's "Tuesday" or "last week" is an offset too, never a calendar date.
- **One hero per main database**, with its Description in Markdown showing how the team writes one.
- **Every field a role fills every time**, filled, and every field a rule keeps (a date stamped on a state change), filled from the story: no rule exists yet while the records are written, and a `created` rule never fires on them.
- **The promises kept:** every record satisfies What must stay true as if the rules had run (a shipped pitch has every scope Done; a key result with a Last check in has the check in behind it). The exception is a record the story shows breaking a promise on purpose, the red card a flag exists for.
- **Only dates the build can set:** Creation Date can't be set, so a moment that needs an older record shows through a date field it has, or is noted in `design.md`'s Build notes.

Invent freely around the story, but never a real person, company or record of the workspace, and never a link to an existing database's records.

`WAVES` are steps in order; the databases in one step are written in parallel, and a database comes after those it links to. A record's keys are field names without the Space:

| Key | Value |
|---|---|
| `Name` | the name; the script adds " (example)" |
| `state`, a single select | the state's or option's name |
| a multi select | a list of option names |
| a relation | `ref(J, "Product designer")`, the linked record's Name; a to-many, a list of them; one side of a relation is enough |
| a person, people | `"me"`, `["me"]` |
| a date | `day(-3)`, days from today |
| a date-time | `at(2, "14:00")`, in UTC: the team's hour converted, as a schedule's is (§5); a date-time range `{start: at(…), end: at(…)}` |
| a date range | `range(-30, 30)`, its first and last day from today |
| a rich text field (Description) | Markdown, written with the record |
| `comments` | a list of comments in Markdown |
| a date inside a text or comment | `${day(-2)}` in a template string |
| a location | `{latitude, longitude, fullAddress, addressParts}`, `addressParts` never left out, or the create is rejected: the parts you know (`address`, `place`, `country`), or `{}`. Fibery doesn't look an address up: put sample places in one real city, near its centre, with no invented house numbers |
| a files field | left out: a sample file would have to be a real one, and the Build notes say so. A gallery's covers: `build-reference.md` |
| anything else | the value as Fibery takes it: a number, text, true or false, a percent field as a fraction |

A name, state or option Fibery doesn't have fails its database's whole step (`FAIL <database>: …`), and a link to a name the data lacks logs `FAIL no …`: send script 4 again with only the records that failed. A value to change on an example that exists is `update_entities` (each record by its `fibery/id`, a select or state by name, a to-many as `{add, remove}`).

The promises are checked by script 6 (§6): `CHECKS` hold one line per promise on stored values, or per Must hold cell, each a query's `select` and a `bad` test that finds the records breaking it (pitches in *Bet* with no appetite; *Shipped* pitches with a scope not *Done*), and one per story moment a flag shows (the stuck candidate is Stuck). Decimal values come back from `query` as strings ("25"), so a check compares `utils.number(r.x)`. A collection is a sub-query whose `q/from` is the field's full name, `skills: {"q/from": f("Skills"), "q/select": {n: "enum/name"}, "q/limit": "q/no-limit"}`, people and multi selects included; a path through a collection, or a `q/from` list, is rejected. Comments the same way, `cs: {"q/from": "comments/comments", "q/select": {id: "fibery/id"}, "q/limit": 1}`. A single-file field is a path, not a sub-query, which is rejected as "not a collection field": `photo: [f("Photo"), "fibery/id"]`, `bad: r => !r.photo`. A location is read as it is, `spot: f("Location")`, null when not set. A promise of a number of records ("two devices never checked") is `is` and `count` in place of `bad`: `is` finds the records that are such, and the check is broken when they are not exactly `count`, as the template's last check shows; never a `bad` that can't be true. A promise no query can see (a practice, an app's behaviour) is reported as not checked.

## 5. Rules and buttons

One script, in the message with script 3. Every automation is created at once and switched on; the log gives each as Fibery stored it. A schedule starts the day after the build, at the spec's time converted to UTC from the team's time zone, which the Assumptions name: 08:00 in Nicosia in winter is `tomorrowAt(6)` and `hour: 6`, with the minutes for a half-hour zone, and the day before or after in a weekly schedule when the conversion crosses midnight. Fibery keeps the UTC hour all year, so the rule's description gives both ("08:00 Cyprus time, 06:00 UTC"), the guide says the team's time, and where the zone changes its clocks the Build notes say the rule runs an hour off after a change. With no zone to go by, the time is UTC and the guide says so. A rule that stamps the date a day count reads gets `created` as a second trigger (§2).

- **Native actions only.** A rule or button never uses the `Script` action; `execute_code` builds the Space and never becomes part of it. Its condition is the filter, its texts are templates, and a rule with two conditions becomes two rules. An action no native shape can do (a comment on a linked record, a notification to the people of linked records, a check before acting, a value found by searching other records, email), or one rejected with no native shape in §8, is left out: the rule is built with the rest when the rest still does its job, and not at all when that action is its point. Either way the report lists what wasn't built and the guide names the step as done by hand. A rejected action fails its whole rule: send it again, without it, in script 5 with only that rule.
- **States and options by id.** A rule's filter and a value take ids: `wf` and `stateValue` look states up from `STATES`, an option is looked up in the data (`build-reference.md`). A state name in a rule's filter is stored as if it were an id, so the rule never fires; in an action it is rejected ("value should be a reference") (measured). So every state goes through `wf` and `stateValue`, never as a written name.
- **Buttons take no filter and can't check:** a button acts whatever the record's state, so its description and the guide say when to press it.
- **Texts and formula values are prompts**, and Fibery writes the result (10–20 s each): "a short note naming who clicked the button and the publish date", never the finished text. A prompt names the literal words a text must contain: "The words 'Interview today:' followed by the interview's Name" came back as `Interview today: {{Name}}`. A value carried from the record that triggered the rule names that record, and the target's field of the same name when there is one ("the Health of the Check in that triggered this rule, not the Key Result's own Health"). A date-time stamp says "the current date and time, using Now(), not Today()". In a Space that isn't in English, a text's prompt ends with its language ("in German").
- **`tpl` only for a comment or a notification.** Fibery fills a `{{Name}}` in when it posts a comment or sends a notification's subject and message. In a field's value, of the record a rule updates or of one it adds, `{{Name}}` stays in the field as typed (measured). So a field's text that names a record is `formula`, and its prompt names the record: "the text 'Accounts and access for ' followed by the Name of the New hire that triggered this rule" is stored as `"Accounts and access for " + [Step 1 New hire].Name`. Script 5 logs a field value holding `{{` as a `FAIL`.
- **Read back what Fibery stored:** the log gives each automation's triggers, filter and actions; read the filter and every text and formula value against the spec. A wrong one: `update_automation({automationType, id, changeActions: [{actionId, action, args}]})` with a sharper prompt, the ids from `query_automations`; `triggers` and `filter` replace the stored ones the same way. Still wrong, drop the action, or the rule when the action is its point, and list it under Not built.
- **An `updated` trigger names its fields** (`updatedField: ["workflow/state"]`); without them the rule fires on every edit.
- **Existing databases:** a filter through a link to one is fine; an action that writes to its records reaches outside the Space, so it exists only when the person asked for it, and the Build notes name it.
- `display_automations_schema` only when an action is rejected by name: its catalog runs to about 17K characters.

The builders: `wf`, `and`, `or`, `flag`, `num`, `empty` and `days` as in §3, but `wf` turns state names into ids; `stateValue` sets a state; `tpl` a comment's or notification's text and `formula` a field's value, text included, that Fibery writes from a prompt; `tomorrowAt(8)` a schedule's first run. Other triggers, actions and values: §8.

## 6. The guide and the last checks

Written last, since its text mentions what the other scripts made: two direct calls, in one message with script 6, which runs `CHECKS` (§4). Fix what it finds broken with `update_entities`, or `update_formula_field` when a formula reads wrong.

**Its text.** The guide the design guide describes under Documents, one screen and under 500 words, written from the design with the workspace's specifics. A rule that wasn't built is named in its step as done by hand. The very last line, in italics, and in English whatever the Space's language: "Built by fibery-architect from the design <name>, <date>.", so the Space can be recognized later.

**Its mentions.** Every view, form, report, document and app named in Where to look, which leaves the guide itself out, is a mention there. Elsewhere a view is a mention where it first appears in each section. A layout app has no view of its own: name it as a tab on every record of its database. Rules, buttons, databases, fields, states and records stay plain names. A view that failed is named without a mention, and the guide says so.

**The calls.** Put each mention in the text exactly as script 3's log gives it, or the app script's for a page app: "Every morning, open [[Pipeline#^a0b03b18-8310-4435-992e-da09b5f17bcd/59043a92-3e58-4dac-8081-084c171cd3c8]]." The whole string, both ids included: a shortened one, such as `[[Pipeline]]`, stays plain text. Never write one by hand or put a url in its place. Then `replace_document_blocks({secret, blocks: [{blockId, content}]})`, the document's secret and empty block from the same log and the whole text in one replacement; its result echoes every block, a mention as `[[#^type/id]]` without its label and a leading quote escaped, which is notation only: read only that it succeeded. The second call is `fetch_view_data` for the first view after the guide, its `publicId` the last part of its url, with `limit: 5`. Read those cards as the person will see them and fix what looks wrong before the report; a view with nested items comes back as one flat list per database, children unfiltered by their parents. Any other document in the spec is written the same way.

## 7. The app

Only when the design has one: the app script, `scripts.md` §7, goes in the message with scripts 3 and 5, so the guide can mention a page app, and its code is written after it as `build-reference.md`, The app, says.

## 8. Shapes the templates don't show

**Views**, `create_view {viewType, name, space, description, config}`:

- An item is `{database, fields, filter, orderBy, colorCoding}`. A field is `{field: "Space/Field"}`, the state `{field: "workflow/state"}`, a collection shown as a count adds `showCount: true`; a sort is `{field, direction}`, with `dateRangeSortBy: "start"` or `"end"` on a range.
- **list**: a grid without `rowHeight`. **board**: `x` and `y` axes, one entry per items database, each `{forDatabase, field, database, fields: []}`: `stateAxis(db)`, `selAxis(db, "Severity")`, the target database for a relation or link, `fibery/user` for people; `y` may be `[]`. A timeline's lanes are `y` axes the same way.

**Filter nodes**, `{nodeType, args: {fieldPath, operator, value}}`, without `value` for `is-empty` and `contains-me`:

| nodeType | fieldPath and operators | value |
|---|---|---|
| `workflow` | `["workflow/state"]`; `is-any-of`, `is-none-of` | a list of state names in a view, of ids in a rule |
| `single-select` | `is-any-of`, `is-none-of`, `is-empty` | a list of option names in a view, of ids in a rule, even for one |
| `multi-select` | `contains-any-of` | the same (measured) |
| `reference` (to-one) | `is`, `is-not`, `is-empty`, `is-not-empty` | record ids |
| `collection` (to-many) | `is-empty`, `is-not-empty`, `contains-any-of`; `contains-me` on a to-many people field only | record ids |
| `number` | `greater-than-or-equal`, `less-than`, `equals`, `is-empty` | a number |
| `bool` | `is` | true or false |
| `text` | `is-empty`, `contains` | a string |
| `date` | `is`, `is-before`, `is-after`, `is-on-or-before`, `is-on-or-after`, `is-empty` | `"YYYY-MM-DD"`, or `{amount, unit, isBeforeNow}` with all three keys, `unit` one of `minute`, `hour`, `day`, `week` |

Relative dates: "is today" is `is` with `{amount: 0, unit: "day", isBeforeNow: false}`; "before today" is `is-before` with `{0, "day", true}`, the start of today, on date-times too; "in the next 7 days" is `is-on-or-after` `{0, "day", false}` and `is-on-or-before` `{7, "day", false}`; "more than 14 days ago" is `is-before` `{14, "day", true}`; on a date-time, "before now" is `is-before` `{0, "minute", true}`. A to-one person field has no "me": a "My …" view needs a people field. A range's start or end is `["q/start", "Space/Dates"]` or `["q/end", …]`, the end being the stored one, a day after the last; a linked record's field chains, `["Space/Pitch", "workflow/state"]`.

**Rules and buttons**:

- **Triggers** besides `created`, `updated` and a daily schedule: `{trigger: "collection-item-added", args: {changedCollectionField: "Space/Seen in"}}` (`collection-item-removed` likewise), either one the rule's only trigger; a weekly schedule, `settings: {unit: "week", time: {hour: 9, minute: 0}, daysOfWeek: ["monday"]}`.
- **Actions**, by name: "Update" this record; "Create" a record of the same database (a weekly review on a schedule), its `fields` the new record's; "Update <Relation>" its linked records, with a `filter` on them when the relation is to-many, a filter node on the linked database's fields (`{action: "Update For repairs", args: {filter: wf(R, "is-any-of", ["Waiting for parts"]), fields: [{name: "workflow/state", value: stateValue(R, "Queued")}]}}`, with `R` in `STATES`; a to-one takes only `fields`: put the condition in the rule's own filter, chained through the relation); "Add <Relation> Item" creates a record linked through a to-many, "Add <Relation>" through a to-one, their `fields` the linked database's; "Unlink <Relation>"; "Add comment", on this record only; "Notify <People field>" with `subject` and `message`, or "Notify Users" with `to: {type: "formula", prompt: "the creator"}`, never with a formula through linked records' people, which is rejected ("Ouch, we can't calculate…") and fails the whole rule; "Append content to <field>"; "Send Web Request".
- **Values:** `{type: "value", value}` with a literal, `{"fibery/id"}` for a state, option or record, or a list of those; `{type: "formula", prompt}`, also for a value carried from a linked record and for a text that names a record; `{type: "template", prompt}` in a comment or notification only; `{type: "empty"}`; `{type: "user-provided-value"}` on a button. Prompts are plain words naming fields exactly, never code.

Rarer shapes are in `build-reference.md`, read before `design.md` is finished when the design has one of the things SKILL.md's table lists for it. The same file says what each call returns, for a repair, and holds the troubleshooting table.
