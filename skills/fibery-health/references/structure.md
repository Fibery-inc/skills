# Structure pass

Read it from the script's facts and `automation` lines. Each check says what to look for in them, why it matters and its default severity.

## Spaces

- **Copied spaces**: in `workspace.sameName`, another Space where most database names (60% of the smaller Space or more) match an in-scope Space's and their fields overlap (OKRs and OKRs 2; Shape Up, Shape Up F, Shape Up G), with the copy's records and newest record per database. One finding per group. Critical when two copies both hold real records still being added to; otherwise Tidy-up.
- **Empty spaces**: `workspace.noDatabases` with 0 views and documents. Tidy-up.

## Databases

- **Same concept twice**: a single match in `workspace.sameName`, regular databases with the same singular name in different spaces, not copies, and the field names they share. Overlapping fields (a Customer here and there) make it Important: two versions of the truth. Generic names (Task, Meeting, Note) serving different processes are fine, and so are two with no field in common.
- **No description**: `description` empty. Agents read it before anything else; the share with one is the agent-readiness score. Important for databases with relations, Tidy-up for lookup lists.
- **Leftovers**: v1, v2, old, copy, test, temp, tmp, backup, deprecated, legacy, a date, or a trailing number or letter after a name that also exists without it ("OKRs 2"; fibery-architect names a second build "Name 2"). Names in an integration's Space come from the app: skip them. Tidy-up.
- **Empty**: `n` 0 for a leftover, an undescribed database or one with no relations. Tidy-up.
- **Isolated or wide**: no `rel` field when the name says it should connect (a Vacation whose Person is text), or more than about 60 of its own non-formula fields. A small reference list (offices, currencies) needs no relations. Tidy-up.

## Fields

- **Test fields**: the same markers in field names ("Test", "temp", an unexplained `json` field). Tidy-up.
- **Text that should be a relation**: a `text` field named like a database or a person (Customer, Owner, Person) whose values match titles or user names, or that copies a linked database's field (an order's Contact holding its customer's Email): the facts give how many distinct values it has and how many match workspace users, the titles of another database in the same Space or one of its text fields. Important: views, formulas and agents can't follow a typed name, and a copy drifts from its source. On a people list, its own name and email fields match users by design: that's evidence for People lists, not this check.
- **Disabled formulas**: `disabledFormulas`. Fibery stopped calculating them (`loop-detected`: the formula reads itself, through other formulas or its own records' relations), so their values froze. Important when something still reads one (`read by` lists the formulas; rules show in the `automation` lines); otherwise it's a dead field to delete: Tidy-up.
- **Formulas fixed to a date**: `fixedDateFormulas`, formulas holding a literal year or date (a month an invoice check looks at, the year vacation days count from). They go quietly wrong once that date passes. Important when people act on the result, otherwise Tidy-up. Some are moved on by hand each period on purpose (a payroll month, a vacation year): then say what has to be edited and when, rather than calling it broken.
- **Mixed alphabets**: a database (`mixedAlphabets`) or field (`mixed alphabets`) whose name mixes Latin with Cyrillic or Greek letters, such as a Cyrillic е in "User Storiеs". It looks right, but search, formulas and the API can't find it by the name people type. Tidy-up.
- **Unreadable**: `unreadable` fields, or an `error` for the whole database: name them under Not checked.

## Workflows and selects

- **Status in a select**: a database of work (requests, tasks, deals) without `states` whose `options` read like a lifecycle (New, In progress, Done, Cancelled). Ratings aren't status: On track / At risk / Off track, priority, size; nor is a two-value flag on a list of things (a subscription Active or Cancelled). Important: nobody can tell open work from finished.
- **Wrong state types**: from `states` (name, type, records, in workflow order): done-like states (Done, Closed, Shipped, Cancelled, Won't do) not Finished and final; states before work starts (New, To do, Next, Planned) typed Started; non-process databases (messages, logs) with nearly every record in a Started state. Important: wrong types inflate work in progress and every report built on it; Tidy-up while no record is in the state. Parking states (Backlog, Icebox, Later, Someday, On hold) typed Started are a question, not a finding: some teams park work there, others keep working in them. Ask whether the state means paused.
- **Unused workflow**: every record of a database with more than a few in one state (47 Use Cases, all in Icebox): nobody moves records through it. Ask whether the database is parked or the states should go. Tidy-up.
- **Select options**: from `options`. Options with records under `same name` (case, spacing or a plural differs) split one value in two, so filters and reports miss half: Important. When `(their icons differ)`, they may mean different things (women's and men's sizes): suggest names that say so, not a merge. Options no record uses: Tidy-up, and only in a select with plenty of records; scales (1–5, sizes, priorities) keep every step.

## Relations and people

- **Names that contradict direction**: a plural name on a single relation (`rel`, not `rel[]`) unless it's the name of the database it points to, or both ends of a self-relation swapped (Parent Message a collection, Thread Replies single). Important.
- **Links into an archive or demo**: a regular database's relation to a database in an archive or demo Space (`rel → Archive/Campaign`): either the archive is still in use, or the field is clutter on every record. Tidy-up.
- **People lists**: a database of people (Team Member, Employee, Staff) with an email or role and no `user` field, while people fields elsewhere point at workspace users. Its email field's values say how many match workspace users. Important: work goes to users, roles live elsewhere, and they never meet. A list kept on purpose for people without logins (volunteers, contractors) is fine.
- **People and their accounts**: `accounts`, on a people list whose person field links each person to their user. `finishedWithActiveAccount`, people marked Left (or another final state) whose user is still active: Important, they can still sign in. `openWithoutAccount`, current people with no user linked: Tidy-up, unless work should reach them. On any other database (a project's owner) ignore the key.
- **People-database clutter**: every people field adds a field to each person. `workspace.userFieldsBySpace` counts them per Space they come from, across the whole workspace. A working Space's own people fields (owner, assignees) belong there; those from copies, demos and retired fields are clutter: count them for the Spaces in scope. Tidy-up.

## Automations

The `automation` lines list every rule and button in scope, integration mirrors and demo spaces included: enabled, last run (`COMPLETED`, `FAILED` or `NOT STARTED`, which means it never ran) with its date, created, trigger and schedule, filter and actions with field and state names, used fields that no longer exist, and a link.

- **FAILED on an enabled rule**: Critical. There's no error text: a used field that no longer exists is the likely cause, or for another app's action, an account not visible to you that may be disconnected; otherwise compare the actions with the facts (a field, option or database that doesn't match) and call it unconfirmed.
- **NOT STARTED on a rule**: it never ran. Fine if created in the last 30 days; older, its trigger or filter probably never matches. Important.
- **Scheduled**: a scheduled rule records a run only when its filter matches a record, so an old last run proves nothing alone. A schedule silent for two intervals gets `records matching its filter now`: above 0, it should have fired and didn't, Important; 0, it's waiting for a match (a birthday rule between birthdays), no finding; `can't count`, say it's unconfirmed. About to fire for the first time on demo data: say when and who gets notified. Important.
- **Disabled**: list them and ask; some are parked on purpose. One whose last run FAILED was probably switched off because it broke: say so.
- **What the actions say**: read each message, prompt and script against the rule's trigger and filter. A message that contradicts them (says a score of 5, fires at 15; says "solved", fires on every state change), a month, season or year typed into text meant to repeat, a Script action that's `default script template` (Fibery's sample, which saves an empty update), and a field, option or database that doesn't exist. Tidy-up; Important when people act on the wrong text.
- **App accounts**: another app's action shows the account it sends through. `an account not visible to you` was connected by someone else: only they can repair it. Not a finding on its own; on a FAILED rule, the likely cause.
