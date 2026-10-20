# Structure pass

Read it from the script's facts and `automation` lines. Each check says what to look for in them, why it matters and its default severity.

## Spaces

- **Copied spaces**: in `workspace.sameName`, another Space where most database names (60% of the smaller Space or more) match an in-scope Space's and their fields overlap (OKRs and OKRs 2; Shape Up, Shape Up F, Shape Up G), with the copy's records and newest record per database. One finding per group. Critical when two copies both hold real records still being added to; otherwise Tidy-up.
- **Empty spaces**: `workspace.noDatabases` with 0 views and documents. Tidy-up.

## Databases

- **Same concept twice**: a single match in `workspace.sameName`, regular databases with the same singular name in different spaces, not copies, and the field names they share. Overlapping fields (a Customer here and there) make it Important: two versions of the truth. Generic names (Task, Meeting, Note) serving different processes are fine, and so are two with no field in common.
- **No description**: `description` empty. Agents read it before anything else; the share with one is the agent-readiness score. Important for databases with relations, Tidy-up for lookup lists.
- **Leftovers**: v1, v2, old, copy, test, temp, tmp, backup, deprecated, legacy, a date, or a trailing number or letter after a name that also exists without it ("OKRs 2"; fibery-architect names a second build "Name 2"). Tidy-up.
- **Empty**: `n` 0 for a leftover, an undescribed database or one with no relations. Tidy-up.
- **Isolated or wide**: no `rel` field when the name says it should connect (a Vacation whose Person is text), or more than about 60 of its own non-formula fields. Tidy-up.

## Fields

- **Test fields**: the same markers in field names ("Test", "temp", an unexplained `json` field). Tidy-up.
- **Text that should be a relation**: a `text` field named like a database or a person (Customer, Owner, Person) whose values match titles or user names, or that copies a linked database's field (an order's Contact holding its customer's Email): the facts give how many distinct values it has and how many match workspace users, the titles of another database in the same Space or one of its text fields. Important: views, formulas and agents can't follow a typed name, and a copy drifts from its source.

## Workflows and selects

- **Status in a select**: a database without `states` whose `options` read like a lifecycle (New, In progress, Done, Cancelled). Ratings aren't status: On track / At risk / Off track, priority, size. Important: nobody can tell open work from finished.
- **Wrong state types**: from `states` (name, type, records, in workflow order), flag parking states (Backlog, Icebox, Later, Someday) typed Started; done-like states (Done, Closed, Shipped, Cancelled, Won't do) not Finished and final; and non-process databases (messages, logs) with nearly every record in a Started state. Important: wrong types inflate work in progress and break stuck-work checks.

## Relations and people

- **Names that contradict direction**: a plural name on a single relation (`rel`, not `rel[]`), or both ends of a self-relation swapped (Parent Message a collection, Thread Replies single). Important.
- **People lists**: a database of people (Team Member, Employee, Staff) with an email or role and no `user` field, while people fields elsewhere point at workspace users. Its email field's values say how many match workspace users. Important: work goes to users, roles live elsewhere, and they never meet.
- **People-database clutter**: every people field adds a field to each person. `workspace.userFieldsBySpace` counts them per source space; say how many come from copies and demos. Tidy-up.

## Automations

The `automation` lines list every rule and button in scope, integration mirrors and demo spaces included: enabled, last run (`COMPLETED`, `FAILED` or `NOT STARTED`, which means it never ran) with its date, created, trigger and schedule, filter and actions with field and state names, used fields that no longer exist, and a link.

- **FAILED on an enabled rule**: Critical. There's no error text: a used field that no longer exists is the likely cause; otherwise compare the actions with the facts (a field, option or database that doesn't match) and call it unconfirmed.
- **NOT STARTED on a rule**: it never ran. Fine if created in the last 30 days; older, its trigger or filter probably never matches. Important.
- **Scheduled**: silent when the last run is older than two intervals. About to fire for the first time on demo data: say when and who gets notified. Important.
- **Disabled**: list them and ask; some are parked on purpose.
- Skim script actions for fields, options or databases that don't exist, and buttons whose update of their own record has no `filter` in its args, which acts from any state.
- Rules with Slack, email or another app's actions (an `app` other than fibery) need a connected account: `get_connected_app_accounts` lists them.
