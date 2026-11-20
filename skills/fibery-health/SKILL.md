---
name: "fibery-health"
description: 'Check the health of a Fibery workspace or Space: how it is built (copied, test and empty Spaces and databases, missing descriptions, status kept in selects, wrong state types, twin select options, formulas Fibery switched off or fixed to a date, text that should be a relation, people lists and accounts of people who left, failing or silent automations) and, on request, how its records fill their fields. Returns a short ranked report with exact numbers and links, then applies only the safe fixes the person approves. Use whenever someone wants to health-check, audit, clean up or declutter a workspace or Space, asks what is broken, stale, unused or badly modeled, or is preparing Fibery for AI agents. Not for designing new Spaces (fibery-architect).'
compatibility: 'Needs the Fibery MCP server; its execute_code tool gives the exact counts. It sees only what the running user can see, so run it as a workspace admin for full coverage.'
---

# Fibery health check

Two passes. The **structure pass** is what every check gets: how the workspace is built and wired, from the schema and the automations. The **data pass** runs only when the person asks (a full or deep check, or a question about records): how the records fill their fields and links. You gather the evidence with Fibery MCP's own tools, in a few short scripts you write; this page says what to look for and how to read what Fibery won't show you otherwise.

## Ground rules

- Read-only until a yes; a yes covers one batch; records are never deleted.
- Every finding has an exact number and a link. Links come from Fibery, never built by hand: `display_schema_capabilities` gives the `url` of every Space and database, and every query row and every rule carries its own. A link is a `url`, never the `[[…]]` mention text `get_spaces` shows, and a finding about a field links its database.
- At most five top fixes; one line each for the rest.
- Say what you couldn't see.

## The flow

1. **Scope.** The Spaces the person names, else the whole workspace; copies of a Space in scope are reported wherever they are. Over about 40 databases, start with the overview below.
2. **Evidence**, in a few `execute_code` scripts you write, each reading every database in scope and logging compact lines (inside a script every Fibery tool is a function of the same name; a script is killed at 55 s). Who runs the check, for the report's first line, from `get_me`. The schema from `get_databases`: fields, types, descriptions, formulas, states with their types, select options, relations. The records and the rest as "How to read it" says. The rules from `query_automations`, one database and one type (`rule`, `button`) a call. Where tools load on demand, load `execute_code`, `get_spaces`, `get_databases` and `query_automations` in one search; the others are functions inside a script. Don't read the same thing twice.
3. **If a script is refused** or `execute_code` is missing, go on with direct reads (`get_spaces`, `get_databases`, `query_automations`) and list under Not checked what needed the script.
4. **Classify** each database, then judge it by the checks below.
5. **Report**, then offer the safe fixes.

## A big workspace starts with an overview

- One line per Space, from counts and the schema only: databases, records, newest record, how many databases are described. Active has a new record in the last 30 days, quiet in the last 6 months, dormant none for longer.
- Synced Spaces (named after an app, or half or more of their databases read-only) are listed apart: never a duplicate, never suggested for a full check. A test copy that still syncs is Tidy-up, Important when it holds tens of thousands of records.
- A dormant Space gets one line: archive it or delete it?
- Worth a look per Space, without severity: databases without a description, leftover names, empty databases, formulas switched off or fixed to a date, mixed alphabets.
- Across the workspace: copied Spaces, same-name databases, people fields that come from dormant or copied Spaces, empty Spaces, the share of databases described.
- Suggest three to five active Spaces for a full check, the biggest and most flagged first; never a synced one or a store a script fills (millions of records in a few databases). Ask once which to check, and whether with the data pass.

## Classify first

- **Integration mirror**, when two of these hold: every field read-only; a "Deleted in …" field; records created by no one; a Space named after an app (Jira, Intercom, Slack, HubSpot, GitHub); a description that mentions syncing. Never change one or call it a duplicate; suggest relating it to the real database. Its automations are still checked; the data pass skips it.
- **Archive**: a Space called Archive, Old or Legacy. Only ask whether it can go.
- **Demo or test**: most records titled "(example)", every record of the Space created in the same minute, or a Space name that says demo, test or sandbox. One line per Space: keep it or delete it. Its automations are still checked; the data pass skips it.
- **Regular**: everything else.

## Structure checks

Severity: **Critical** splits, hides or breaks data now; **Important** misleads people and agents or lets work rot; **Tidy-up** is clutter.

- **Copied Spaces**: another Space sharing most database names and fields with one in scope. Critical when both hold real records still being added to; else Tidy-up.
- **Empty Spaces**: no databases, no views or documents. Tidy-up.
- **Same concept twice**: regular databases with the same singular name in different Spaces and overlapping fields. Important. Generic names (Task, Note) serving different processes are fine, and so are two with no field in common.
- **No description** on a database: agents read it first. Important for databases with relations, Tidy-up for lookup lists. The share described is the agent-readiness score; draft the missing ones.
- **Leftovers**: names with v1, old, copy, test, temp, backup, a date or a trailing number beside the same name without it. Names in an integration's Space come from the app: skip them. Tidy-up. **Empty** leftover or unrelated databases: Tidy-up.
- **Isolated or wide**: no relation where the name says it should connect (a Vacation whose Person is text), or more than about 60 fields of its own. A small reference list needs no relations. Tidy-up.
- **Test fields**: the same markers in field names. Tidy-up.
- **Text that should be a relation**: a text field named like a database or person whose values match that database's titles or user names, or that copies a field of a linked record (an order's Contact holding its customer's email). Important. A people list's own name and email match users by design: that is evidence for People lists, not for this check.
- **Formulas switched off**: Fibery stopped calculating them, usually for a loop, so their values froze. Important when a formula, rule or view still reads one; otherwise a dead field: Tidy-up.
- **Formulas fixed to a date**: a literal year or date inside. Read the expression and say which way it goes wrong and since when. Some are moved on by hand each period on purpose (a payroll month): then say what to edit and when. Important when people act on the result.
- **Mixed alphabets**: a name mixing Latin with Cyrillic or Greek letters looks right but can't be found by typing it. Check names by code point. Tidy-up.
- **Status in a select**: a database of work without a workflow whose select reads like a lifecycle (New, In progress, Done). Important. Ratings, priorities and two-value flags aren't status.
- **Wrong state types**: done-like states (Done, Closed, Shipped, Cancelled) not Finished; states before work starts typed Started. Important; Tidy-up while no record is in the state. A parking state (Backlog, On hold) typed Started is a question, not a finding.
- **Unused workflow**: every record of a database in one state. Ask whether it is parked.
- **Select options**: two options whose names differ only by case, spacing or a plural split one value: Important when both hold records. When their icons differ they may mean different things (women's and men's sizes): suggest names that say so, not a merge. Unused options: Tidy-up, never on a scale.
- **Names that contradict direction**: a plural name on a to-one relation, unless it is the target's own name. Important.
- **Links into an archive or demo**: a regular database's relation into an Archive or demo Space. Either the archive is still in use or the field is clutter on every record. Tidy-up.
- **People lists**: a database of people with emails or roles and no user field, while other fields point at workspace users. Important, unless kept on purpose for people without logins.
- **People and their accounts**: on a people list whose person field links each person to their user. People in a final state (Left) whose user is still active can still sign in: Important. Current people with no user linked: Tidy-up, unless work should reach them.
- **People-field clutter**: every people field adds a field to each user. Count the ones that come from copied, demo and retired Spaces. Tidy-up.
- **Automations**: an enabled rule whose last run failed, Critical. A failed run has no error text: the likely cause is a field that no longer exists or, for another app's action, an account you can't see; otherwise say it is unconfirmed. A rule that never ran and is over 30 days old, Important. A scheduled rule proves nothing by an old last run, so count the records matching its filter now. Disabled rules are listed with a question; one whose last run failed was probably switched off because it broke. Read each message against the rule's trigger and filter: a text that contradicts them, a month or year typed into a text meant to repeat, a field or option that no longer exists, a Script action that is still Fibery's sample. Tidy-up, Important when people act on the wrong text. Another app's action sent through an account you can't see was connected by someone else, and only they can repair it: not a finding alone.

## Data checks, on request

Under about 20 records give counts ("5 of 7"), not percentages. A number from a sample says so.

- **Unused fields**: filled in 5% of records or fewer. Skip formulas, fields added this month, the Description and opt-in flags. A relation is in use when its other side is. Tidy-up.
- **Retired fields**: filled in older records, empty on the newest: people stopped using it. Not when the field fills late in a record's life, was added recently, or is a collection whose other side still links new records. Name what still reads it: Important when a formula or rule people rely on does, since its results go stale.
- **Missing links**: a to-one relation or person field empty in some records. Judge by state: open records without it matter (Important), finished ones don't, and some records don't need it (an idea without a campaign). A child whose parent has the value is covered only where the formulas and views reading the field look at the parent too. A person who is deactivated is as good as empty.
- **Text that repeats a few values**: at most 15 distinct values, filled in a third of the records or more, should be a select. Tidy-up.
- **Dormant**: no new record for 6 months in a database meant to keep getting them. Reference lists and people lists pause by nature.

## How to read it

- **Every Space and database, with links**: `display_schema_capabilities({})` gives `accessInfo.spaces`, and with `{spaces: [names]}` it gives `accessInfo.databases`, each entry with its `url` and your access. Take names from there, not from parsing a text listing.
- **Records**: one paged query per database (`"q/limit": 1000` with `"q/offset"`, ordered by `fibery/creation-date`), selecting the creation date, the state as `["workflow/state", "enum/name"]`, each to-one as `["Space/Field", "fibery/id"]`, each select as `["Space/Field", "enum/name"]`, checkboxes and plain values as `["Space/Field"]`, and each to-many as `["q/count", ["Space/Field", "fibery/id"]]`; then tally in the script. 5,883 records in four databases, about 30 fields on the largest, took 3 s. Over about 20,000 records read the newest 1,000 and settle each number that matters with a count.
- **A count** is `{"q/from": "Space/Database", "q/select": ["q/count", "fibery/id"], "q/where": …}`. It stands alone as the whole select: beside other fields, only a to-many count works. Never count empty values with `["=", [...], true]` inside a count: it returns the database total. Count the filled ones and subtract: text `["=", ["q/null-or-empty?", ["Space/Field"]], false]`; number or date `["=", ["q/null?", ["Space/Field"]], false]`; relation or select `["=", ["q/null?", ["Space/Field", "fibery/id"]], false]`. Unfinished records: `["=", ["workflow/state", "workflow/Final"], false]`; two conditions go in `["q/and", a, b]`.
- **States with their counts**, without reading records: `{"q/from": "workflow/state_Space/Database", "q/select": {name: "enum/name", type: "workflow/Type", final: "workflow/Final", n: ["q/count", ["workflow/objects", "fibery/id"]]}}`.
- **Fibery's field table** shows what `get_databases` doesn't: `{"q/from": "fibery/field", "q/select": {name: "fibery/name", meta: "fibery/meta", made: "fibery/creation-date", db: ["fibery/holder-type", "fibery/name"]}, "q/where": ["q/in", ["fibery/holder-type", "fibery/name"], [database names]], "q/limit": "q/no-limit"}`. In `meta`: `formula/disabled?` with `formula/disable-reason` (`loop-detected`) marks a formula Fibery switched off; `formula/formula` holds the formula with its literal values under `params`, where a year or date shows; `fibery/readonly?` marks an integration's fields. `made` is when the field was added (old fields have none). A name ending in `_deleted` is a deleted field.
- **A deactivated user** on a person field: `["=", ["Space/Owner", "fibery/active?"], false]`.
- **Who created the records**: `["fibery/created-by", "user/name"]`; `null` means no person: an integration, a form or the API.
- **The other side of a relation** (`get_databases` names it as `relatedField`): count the records there that link back, and read the creation date of the newest one that does. That tells a collection in use from a retired one.
- **Rules**: a filter and its values name states and options by id; match them to names from `get_databases`. `get_connected_app_accounts({})` lists the app accounts you can see; an action whose `appAccountId` isn't among them goes through someone else's. Fibery's sample script contains `'Field Name': newValue` and saves an empty update.

## Report

```markdown
# Health check: <workspace>, <scope>, <date>
Run as <name> (<role>). <N> Spaces, <N> databases, <N> records.

## Summary
Three to five sentences.

## Scorecard
Rows only for the passes that ran.
| | Critical | Important | Tidy-up |
|---|---|---|---|
| Structure | | | |
| Automations | | | |
| Records | | | |

## Top fixes
1. <Finding with number and link>: why it matters. Fix. (I can do this / Needs you)

## All findings
By area, one line each, with its severity. Questions for the person go last.

## Agent readiness
<X> of <Y> databases described, with drafts for the rest.

## Not checked
```

Summary, scorecard and top fixes go in chat; offer to save the full report as a document in the person's Private space. After a structure-only check, offer the data pass in one line, naming the Spaces you'd check.

## Safe fixes

The person names the findings. Per batch: restate the change, the records it touches and its undo; wait for a yes; apply; read back and report before and after.

- **State types.** A parking state only after the person confirms it means paused. Undo: the old type.
- **Delete** an empty database or Space, or an unused or test field: show its filled count and a few values first; only when no formula, rule or view uses it; never on an integration mirror; a relation goes from both sides. Undo: the Activity Log.
- **Switch a failing rule off.** Undo: switch it on.
- **Write a drafted description.** Undo: the old text.
- **A triage view** named "Health: <finding>", filtered to exactly those records. Undo: delete the view.

Plans only, never applied here: renames (integrations and API calls using the old name break), merging copies or options, turning a select into a workflow or text into a relation, retiring a people list, deactivating users, repairing rules or formulas, deleting a demo Space with records. fibery-architect applies renames, conversions and repairs when the person asks it to change that Space.
