# Structure pass

Read it from `schema_detailed` and the automations, plus a few confirming queries. Each check says what to look for, why it matters and its default severity.

## Spaces

- **Copied spaces**: spaces whose database names mostly match (OKRs and OKRs 2; Shape Up, Shape Up F, Shape Up G). One finding per group, with each copy's record count and newest record. Critical when two copies both hold real records still being added to; otherwise Tidy-up.
- **Empty spaces**: no databases, and no documents or whiteboards in `query_views`. Tidy-up.

## Databases

- **Same concept twice**: regular databases with the same singular name in different spaces, not copies, with overlapping fields (a Customer here and there). Generic names (Task, Meeting, Note) serving different processes are fine. Important: two versions of the truth.
- **No description**: agents read it before anything else; the share with one is the agent-readiness score. Important for databases with relations, Tidy-up for lookup lists.
- **Leftovers**: v1, v2, old, copy, test, temp, tmp, backup, deprecated, legacy, a date, or a trailing number or letter after a name that also exists without it ("OKRs 2"; fibery-architect names a second build "Name 2"). Tidy-up.
- **Empty**: count records for leftovers, undescribed databases and databases with no relations; 0 means empty. Tidy-up.
- **Isolated or wide**: no relations when the name says it should connect (a Vacation whose Person is text), or more than about 60 of its own non-formula fields. Tidy-up.

## Fields

- **Test fields**: the same markers in field names ("Test", "temp", an unexplained "JSON"). Tidy-up.
- **Text that should be a relation**: a text field named like a database or a person (Customer, Owner, Person) whose values match titles or user names; check a few. Important: views, formulas and agents can't follow a typed name.

## Workflows and selects

- **Status in a select**: options that read like a lifecycle (New, In progress, Done, Cancelled) on a database without a workflow. Ratings aren't status: On track / At risk / Off track, priority, size. Important: nobody can tell open work from finished.
- **Wrong state types**: from each workflow's states and record counts, flag parking states (Backlog, Icebox, Later, Someday) typed Started; done-like states (Done, Closed, Shipped, Cancelled, Won't do) not Finished and final; and non-process databases (messages, logs) with nearly every record in a Started state. Important: wrong types inflate work in progress and break stuck-work checks.

## Relations and people

- **Names that contradict direction**: a plural name on a single relation, or both ends of a self-relation swapped (Parent Message a collection, Thread Replies single). Important.
- **People lists**: a database of people (Team Member, Employee, Staff) with an email or role and no relation to `fibery/user`, while people fields elsewhere point at workspace users. Compare its names and emails with `fibery/user`. Important: work goes to users, roles live elsewhere, and they never meet.
- **People-database clutter**: every people field adds a field to each person. Count `user/*` fields per source space; say how many come from copies and demos. Tidy-up.

## Automations

Per database in scope, integration mirrors and demo spaces included, call `get_automations` (`query_automations` on newer servers) with `rule`, then `button`. Each has `enabled`, `created`, triggers, actions, a `url` and `lastRun`.

- **FAILED on an enabled rule**: Critical. There's no error text: compare the actions with the schema for the likely cause (a field, option or database that doesn't match) and call it unconfirmed.
- **NOT STARTED on a rule**: it never ran. Fine if created in the last 30 days; older, its trigger or filter probably never matches. Important.
- **Scheduled**: silent when the last run is older than two intervals. About to fire for the first time on demo data: say when and who gets notified. Important.
- **Disabled**: list them and ask; some are parked on purpose.
- Skim scripts for fields, options or databases that don't exist, and for buttons that act from any state.

## Queries

- **States with counts**: `{"q/from": "workflow/state_Space/Database", "q/select": {"state": "enum/name", "type": "workflow/Type", "final": "workflow/Final", "n": ["q/count", ["workflow/objects", "fibery/id"]]}}`
- **Records**: `{"q/from": "Space/Database", "q/select": ["q/count", "fibery/id"]}`. For demo titles add `"q/where": ["q/contains-ignoring-case?", ["Space/Name"], "(example)"]` on the `UI title` field. One aggregate per query.
- **Filled values**: count with `"q/where": ["=", ["q/null?", ["Space/Field"]], false]` (`q/null-or-empty?` for text). Counting with `true` returns the database total.
- **Newest or oldest record**: order by `fibery/creation-date`, `q/limit` 1. `q/min` and `q/max` don't work.
- **Automation runs**: `lastRun.status` is `COMPLETED`, `FAILED`, or `NOT STARTED` (never ran, no `startDate`).
- **Schedules**: a time-based trigger's `schedulerConfig` has `freq` (0 yearly, 1 monthly, 2 weekly, 3 daily, 4 hourly), `interval` (every N periods), `byweekday` (0 is Monday), `byhour` and `byminute` (UTC), and `dtstart` (the first run).
- **Connected accounts**: rules with Slack or email actions need one; `get_app_accounts` (`get_connected_app_accounts` on newer servers) lists them.
