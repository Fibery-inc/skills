# Design guide

Everything that happens before the build: learning the process, reading the workspace, deciding what goes into the Space and where to stop, and writing it down as `design.md`. Nobody approves it, since the person had their say in the questions: it is the **spec** the build reads, what the Space is in plain words, the way a recipe's Details for building says it, under a short list of what you assumed in their place. The spec decides everything a person would notice (names, types, states, what each view shows and filters, what each rule does); turning the words into calls is the build guide's job.

## Contents

1. [Learn the process](#1-learn-the-process)
2. [Read the workspace](#2-read-the-workspace)
3. [The standard: the 80% Space](#3-the-standard-the-80-space)
4. [Designing each part, and how it's written](#4-designing-each-part-and-how-its-written)

## 1. Learn the process

The aim is a model you can play back in five lines, in the team's own words, after one or two exchanges. Every answer lands in one of nine places:

| You want to learn | It becomes |
|---|---|
| What the process is for, in one sentence | the Space description and the story's promise |
| Who runs it: one person, a team with roles, a company with hand-offs, or a community whose members mostly don't use Fibery | one person: no people fields and no "My …" views, since every view is theirs; a team: a people field per role that gets a "My …" view; a company: approvals, hand-offs and links to its departments and people; a community (a club, a league): members as records, organizers as people fields, and a form members come in through |
| The things they talk about ("a candidate applies for a job") | databases, one per noun with a life of its own; a noun that only labels something is a select |
| The stages the main thing goes through, and how it ends (done, and the other endings) | the workflow, with its finished states |
| Who does what, and who decides | person or people fields; a decision is often a button |
| What people look at every morning, and every Monday | the views, the first one being the daily one |
| The rules they keep in their heads ("when the last scope is done, the pitch ships") | automations |
| What they already track in Fibery (customers, people, products, projects) | links to existing databases |
| The numbers they want to see without calculating | formulas |

Stages, roles and existing databases change the structure; the rest you design from the standard below and adjust after the build, when they see it.

**How to ask.** Two to four questions a round, asked as SKILL.md §3 says, never a questionnaire. In their words: if they say "tickets", the database is Ticket. Concrete over abstract: "what happens to a ticket after someone replies?" gets a stage, "describe your workflow" gets a shrug. Offer a default with every question, so a shrug still gives an answer. Ask about endings (Lost, Cancelled, Rejected), because they are what boards hide when they're missing. Read the workspace (§2) before the first question, so what already exists is a question only when it's unclear which database is the one. Don't ask what you can see: read what they shared first, ask only about the gaps. Never ask about fields: people can't list them from memory, and they strike or add one more easily in the built Space than from a list, so the design picks them from the standard below.

**The playback.** Before designing, play the model back, so a wrong assumption costs a sentence rather than a build:

> So: a **Candidate** applies for a **Job**, moves Applied → Screening → Interview → Offer, and ends Hired or Rejected. Recruiters own candidates, hiring managers own jobs. Every morning you want the pipeline board; on Mondays, offers due this week. Candidates link to the People database you already have. Right?

With a question tool, the playback is written just before the last round's call, whose first question is "Is that right?". Their answer is the last before the build: if they correct it, correct the model and go on. If they add a lot, keep what a role would fill every time and park the rest in "Make it yours".

**When to stop.** When you can name the databases, their stages, the roles, the daily view and what already exists in Fibery. Signs you've gone on too long: exceptions that happen once a year, or things the person answered with "whatever you think". When the person is vague or absent ("just build it"), choose defaults from the standard and the closest recipe, and list every assumption at the top of `design.md`; an assumption they can see and reverse is fine, a question that stalls the work is not.

## 2. Read the workspace

A Space that duplicates what the team already tracks is worse than no Space: a second Customer database, a second People list, a vocabulary nobody uses. Everything here only reads, and comes before the first question, so what the workspace leaves open is asked with the rest (SKILL.md §3).

1. **`schema`** lists every Space and database. Skim it for databases this process would otherwise duplicate (people, customers, products, projects, teams, periods); a Space for the same process already (the questions say so); test or archived Spaces, never linked to; synced databases (Intercom, GitHub), fine to link to, never changed; and the workspace's vocabulary (Customer or Account, Task or To-do, Sprint or Cycle).
2. **`schema_detailed`** for the candidates, to see what they really hold: a "Contact" may be a marketing list, an "Employee" database may be the real people directory while `fibery/user` is only who has a login. Keep the exact field names of anything you'll filter or compute through. Add two or three databases from other Spaces the team works in to the same call: their fields show how the workspace writes names (SKILL.md §2).
3. **`schema_detailed` for `fibery/user`**, to read the `user/...` fields already there: every people field you add creates one more, and a taken name gets numbered ("Recruiting 2"). Note the taken ones in the design.

**Link or create.**

| Situation | Do this |
|---|---|
| The workspace has the system of record for a noun the process needs (customers, employees, products, projects, countries) | **Link** to it, asked by name in the questions with yes as the guess (SKILL.md §3). Nobody re-enters customers. |
| The noun is specific to this process (candidate, pitch, post, ticket, audit) | **Create** it in the new Space. |
| The existing database is close but not the same thing (a synced Intercom Contact when the team means paying customers) | Ask about it by name in the questions, with no as the guess (a new database). Don't guess a link. |
| The existing database is a test, an archive or one you can't understand from its fields | Don't link. Note it in the Assumptions as an option. |
| A lookup list exists elsewhere (Country, Currency, Period) | Link if it's maintained; a small select otherwise. |
| The person wants the process added to an existing database (fields on their Task database) | Outside this skill: say so, and offer a new Space alongside, linked to it. |

Link sparingly: two or three links that carry real meaning beat linking every database that shares a word with the process. Name each link's inverse the way the existing database's owners would ("Candidates", "Deals", "Audits"); it's a field they'll see.

**People: users or a database.** `person` and `people` fields point at the workspace's people (`fibery/user`), the ones with a login: use them for assignment and ownership, because notifications and the person picker work on them, and a "My …" view (filtering on `me`) works on `people` fields only, so a role that gets a "My …" view is `people` even when it's one person in practice. A process one person runs alone gets no people fields at all: there is nobody to filter on, and every view is theirs. A people database (Employee, Team member, Contact) is a normal database, often the real directory, with people who have no login and fields the user list lacks (department, office, manager): link to it when the process needs those people as records. Don't model people twice inside the new Space, and keep people fields to six at most.

**Names and collisions.** No new Space's name may exist yet (one Space by default; §4 says when a design uses two or three): if a name is taken, ask with the questions whether they meant that Space, a free one ("Hiring 2") being the default, since the build addresses every database as `<Space>/<Database>` and an existing name would route it into that Space. Link targets are spelled exactly as `schema` shows them, because Fibery matches similar names and a near miss lands the inverse field on the wrong database. Inverse names must be free on the target database; people-field names are workspace-wide. Space, database, field, state and option names use letters, digits and spaces only ("Cool down", not "Cool-down").

## 3. The standard: the 80% Space

Think of the Space as the team's operating manual, made executable: the databases are the things they talk about, the workflow is how work moves, the fields are what people record and see, the views and reports are the questions they ask, and the automations are the rules they would otherwise have to remember.

Aim for the Space a team would have built for themselves after a month of running the process in Fibery: not the first-week sketch, and not the ten-year product. That's about 80% of what a mature Space ends up with, and it's the right amount to hand over. The last 20% is what a team learns by using it, and a Space that arrives finished is one nobody feels they own. So design from how the work actually flows (and, for the fields, from what any team in the domain records), then keep to §4's ceilings, a rule of thumb for a typical process and never a target: you decide what goes in and what's left out, fewer is always fine, and what's left goes into the guide's Make it yours, so the team knows where to take it.

If the person asks for everything, lift the ceilings; for a starter, halve them.

## 4. Designing each part, and how it's written

Each part below states its rule, what to put in and how it appears in `design.md`. The document opens with **Assumptions**, one line for each choice made in the person's place (a default taken, a link made or left out, a Space name chosen, a currency), and after the build it closes with Build notes (SKILL.md §6). The spec follows, in this order: Databases, Views, Reports, Automations, Documents, Apps, Sample story. Dates in the sample story and in filters are relative to the build day: `today`, `today+7d`, `today-2w`. The rules at a glance:

| Part | Rule |
|---|---|
| Spaces | one; two or three only for a reason the report states: a part some people must not open, or a part several processes will share |
| Databases | the nouns with a life of their own; up to 7, never more than 10 |
| Fields | up to 14 on the main database and 8 on the others; each used by something or filled by a role every time |
| Formulas | up to 8, each with a consumer; none when nothing is computed |
| Views | up to 8, one per question, the daily view first; none that only adds a filter to another |
| Reports | up to 2, one per database, its charts as tabs; none when no question needs one |
| Automations | must-have only, up to 5 |
| Custom app | considered every time, up to one, named in the spec either way |
| Documents | the guide, plus up to one |
| People fields | up to six; people for a role with a "My …" view, person for one without |
| Sample data | 25–40 records, 8–15 on the main database, never trimmed and never past 50 |

These are the recipe format's ceilings (`recipe-writer/references/recipe-format.md` §11), because a recipe is written to this standard and a build adds nothing to it. The one exception is the sample records: a recipe leaves them to the build, and they fill the views rather than adding any. A change to one table is a change to both.

### Databases and fields

- Start from the nouns people use in a sentence about their work: "a candidate applies for a job and goes through interviews". Each noun with its own stages, owner, dates or fields is a database; a noun that only labels something is a select; nouns that always travel together merge. Singular names, in the team's words.
- One Space holds everything, by default; Fibery grants access per Space, so a second or third Space exists only for a reason you can state in a line: a database some people must not open (the authors behind a blind review, salaries) goes in a Space shared with fewer people; a database several processes will share (Customers, Products) goes in a Space of its own, so the next process links to it instead of to this one. Name each Space, put every database in exactly one; a view lives in its database's Space, the guide, documents and apps in the main Space, and a view that lives elsewhere says so after its name in its row ("Owner contacts, in Dog owners"); relations across the new Spaces are ordinary relations. In the spec, a database's heading carries its Space when there are several: `### Author (Space: Paper Authors)`. Colors and option emojis are the build's, and the Space's icon is left to the person.
- Supporting databases earn their place by having their own fields or workflow: Interview (scheduled at, interviewer), Offer (amount, sent on, decision). A checklist becomes a child database only when its items need owners or dates; a lookup list (tags, rooms, countries) only when it needs fields of its own or is maintained by someone, with its Description off.
- A record's write-up lives in its Description, under headings, when it's one document (a pitch, a treatment plan). Separate rich text fields only when the parts are filled by different people at different times (Screening notes, Interview feedback).
- A field earns its place when a view, report, formula or automation uses it, or when a role fills it every time: identity and contact; the one or two selects a report groups by; a single "stage changed on" kept by a rule rather than a date per stage; the amounts and dates decisions turn on; people per role; files; the links. Leave out fields the team said they don't track, classification fields added "for later reports", and the ones only a vendor's product has.
- Choose the type by what people do with the value, and write it in these words:

  | People... | Type in the spec |
  |---|---|
  | pick from a short, fixed list | single select, or multi select when several apply; options in order, with a default when one makes sense |
  | move it through stages | the workflow, not a select called "Status" |
  | assign a person, or several | person, or people (a role with a "My …" view is people) |
  | plan around a day or a period | date, date-time, date range, date-time range |
  | count or measure | integer (unit); decimal (precision, unit); money (currency, precision); percent |
  | tick | checkbox |
  | link to another record | relation (a database in this Space), or link (an existing database) |
  | attach | files |
  | write a short line | text, email, url, phone |
  | write a longer piece at its own time | rich text |
  | point at a place | location |
  | see a fact computed from other fields or linked records | formula |

- A field's name says what goes in it; a description is added only where the name leaves a question: a scale or a period, what counts, or that a rule fills it. Select and workflow fields can't carry one in Fibery, so their guidance goes into the option names and the database's description.

In the spec, one subsection per database, written the way a recipe's Details for building writes it:

```markdown
### Candidate

A person applying for a Job; the Description holds the notes from screening onwards. Comments on, avatars on.

| Field | Type | Why |
|---|---|---|
| Source | single select: Referral, Job board, Agency, Inbound; default Inbound | Sources that convert groups by it |
| Recruiter | people; inverse "Recruiting" | Owns the candidate; My candidates filters on it |
| Job | relation, many-to-one → Job; inverse "Candidates" | The role applied for |

States: Applied → Screening → Interview → Offer → Hired (finished) · Rejected (finished) · Withdrawn (finished). Default: Applied.

Formulas:
- **Days in stage** — days since Stage changed on, 0 without it, a whole number; on Pipeline cards and in Is stuck.
```

Every database has Name and a Description already; don't list them, and write "no description" for one that shouldn't have it.

### Workflows

One per database with a lifecycle; its states are the columns of its board. Four to eight states, named the way the team says them out loud ("In review", "Waiting for patient"). Every ending is a finished state (Hired, Rejected, Withdrawn; Won, Lost; Done, Cancelled): boards hide what they lack. The default state is where new records start. In the spec: states in order, `(finished)` on every ending, `(not started)` on a second state before work starts (Backlog, Icebox), and the default named.

### Relations and links

A relation is a row in one database's field table, usually the side that has many ("many interviews belong to one candidate"), with the cardinality from that side, the target and the inverse name; the other database's table doesn't repeat it. Name both sides so a sentence reads well ("Candidate → Interviews", "Interview → Candidate"). People fields add a field to every person in the workspace, so name their inverse clearly ("Recruiting", "Hiring manager of").

A **link** is a relation to an existing database: type `link`, the target exactly as `schema` shows it, and the inverse name that will appear there (`link, many-to-one → People/Person (existing); inverse "Referred candidates"`). Views, formulas and rules can read through it (`Account.Tier is Enterprise`), with the target's field names as `schema_detailed` shows them. Sample data never sets it, since that would write to a real record; people link real records after the build, and the story says so. A rule that writes to the linked records reaches outside the new Space: design one only when the person asked for it, and otherwise note it in the Assumptions as one they can ask for. An app may read it.

### Formulas

Each with a consumer, named in the spec; a formula nothing uses is cut. Worth having: rollups a card shows (counts, sums, averages, progress); ages and durations the daily view sorts by (days in stage, days to due); conditions rules filter on (all scopes done, over SLA); a linked fact a card can't do without, since views show only a database's own fields; a date a timeline needs when it's derived. Each is one line in words, as in the snippet above: what it computes, its result (a whole number, a decimal with its places, either with a unit when the number alone is ambiguous, yes or no, text, a date), its value when inputs are missing, and where it's used. A formula can't come back blank, so the missing case gets a value (0, no, or a date far enough away that the view ignores it); a share is a whole number from 0 to 100, never a fraction; a day count reads one date field, kept by a rule that also fires on creation. Write an expression only where the words could be read two ways. A decimal's number format goes on the report's Your turn.

### Views

One per question rather than per database: the daily view first (a board of the main database, columns by state, rows by the grouping people care about, filtered to what's current); "what's mine" per role that has one; a calendar or timeline wherever dates drive the work; a form when records come from outside the team; the parent database with its children nested; a grid of what finished or was lost, which the daily view hides; the guide, and the process document if there is one. A view that only adds a filter to another view isn't a view: people filter. The daily view and "My …" views are the exceptions, so stuck or late records are red cards on the daily view, not lists of their own. Three types for particular processes: a gantt when the work is a hierarchy with dependencies and dates (projects with phases, a launch plan); a gallery when records are best told apart by a picture (content with cover images, products, candidates with photos), and for any view whose cards should show one, since a Fibery board has no cover: a gallery groups its cards in lanes, as a board does in columns; a map when records have addresses (customers, sites, deliveries). A view nobody would open on a Tuesday is cut.

```markdown
| View | Type | Database | Columns / rows / dates | Shows | Filter | Sort | Answers |
|---|---|---|---|---|---|---|---|
| Pipeline | board | Candidate | columns State, rows Job | Recruiter, Source, Days in stage | State not finished | | What's where, today |
```

`Shows` lists the fields on cards or columns besides the name, which the build puts in the order a person reads a row (build guide §3); views show a database's own fields, so a linked value needs a formula. A calendar card shows the name only, so a database on a calendar needs names that say what the record is ("Mirage vs Kestrel", not "Game 12"), and its description says so; a timeline bar shows one short field at most. Filters are in words that map to Fibery's (`State is any of`, `Recruiter is me`, `Due before today+7d`, `Job.State is Open`); `me` works on `people` fields only. A view sorted by a field shows that field. A form row lists its fields in order, marked: "Name (required), Job (required), Source (default: Inbound)". Color rules, card sizes, nested children (`children: Scope via Scopes, showing Hill position`) and milestones go in the row when the view needs them. A view with nested children is a grid when its levels show mostly the same fields (Epic and Story: State, Assignee, Due date; Department and Team: Lead, Headcount, Budget), and a list when each level shows mostly its own (Customer and Deal; Candidate and Interview), since a grid puts every level's fields under one header and leaves the other levels' cells empty. Two limits to design around: a board or timeline groups by a select, a state, a relation or people, never by a number, a text or a date (a Grade integer can't be a row; make it a select); children nest through a to-many relation only, so a list can't nest through a to-one, though a database can nest inside itself through its own to-many side (objectives under the objectives they support). The story names the first view.

### Reports

What the team builds in a spreadsheet otherwise: a funnel or throughput by state, and a breakdown by the classification that matters (source, department, channel); time in stage (a historical report) only when it's the process's own KPI. A report is one per database, its charts tabs: each report loads and refreshes its records apart, and several are several places to look; a second one on that database is a historical report, a mode a report can't change. A tab is a chart, a metric for a single number, or a table of aggregated numbers, dense and never edited (Amount by Owner and quarter); records people open or change are a view. Name the report for what its tabs measure together ("Hiring numbers"). The source's filter drops the records no tab ever needs, so the report loads fewer; a tab's conditions narrow only that tab. In the spec, a line per report with its database and the records its source keeps, if any, and under it a line per tab, in words: what's counted, grouped by what, colored by what, and which records besides. Which records is said in the source's own fields, a date window on the tab: a report that keeps only some linked records (key results of active objectives) does it through a true-or-false formula on its source, listed with the formulas.

```markdown
- **Hiring numbers**, on Candidate, only candidates with a Job:
  - **Hiring funnel** — candidates by State, colored by Source; only those who applied this year.
  - **Sources that convert** — candidates by Source, colored by State.
```

### Automations

Must-have only. The test: without this rule, would the process produce wrong data or miss a handoff?

| Pattern | Example |
|---|---|
| keep dates without asking | state changes → set "Stage changed on" to today; created → "Applied on" |
| move a parent when its children are done | the last scope is Done → the pitch is Shipped; openings hired → the job is Filled |
| stop or close work when a period ends | the cycle moves to Cool down → unshipped pitches are Stopped |
| a decision as a button | "Make offer" sets the state, creates the linked Offer, comments who decided |
| one reminder on a schedule, at most | every Monday, remind owners of records stuck over 14 days |

Courtesy notifications ("an interview was scheduled") are what teams switch off first; leave them out.

A rule is native actions only, its condition the filter: never a script. Triggers: created, a field changes, a record linked or unlinked, a schedule. Actions: update this record, update linked records (which of them, by a filter), add a linked record, create a record of the same database (a weekly review on a schedule), unlink, comment on this record, notify people in a field of this record, append to a rich text, a web request (to the full URL the person gave). A rule never branches, compares two fields with each other, counts or searches across records, or refuses; a button does its actions whatever the record's state. A step that would need any of that is not an automation in the design: it becomes a formula or view that shows the exceptions, or a practice named in the guide. Texts and values are described, never written out: Fibery writes them at build time. In the spec, one line each, in words, its kind and database first:

```markdown
- **Job filled** (rule on Candidate): when a candidate moves to Hired and its job's Openings left is 0 or less, the job moves to Filled.
- **Interview reminder** (schedule on Interview, daily at 08:00): tells each interviewer about today's interviews.
```

### Documents

The guide is `How to run <process>`, named after the process the way the team says it ("How to run the hiring pipeline"): a document view, the Space's front door. A newcomer reads it in two minutes and clicks through to the views, so it fits on one screen, under 500 words, and teaches this Space, not the method. In this order:

- A one-line promise in bold, then a sentence or two on what the process is and who runs it here, with a plain gloss for the method's own words.
- **How it runs here**: the loop in up to ten numbered lines, each opening with its moment in bold ("**Leadership bets.**") and saying who acts, what they do and in which view. A step a rule or button does names it; a step nothing reminds anyone of says so.
- **Where to look**: the views by cadence (every morning, every week, at the meeting, any time), the daily view first and the reports last, a few words each.
- **What stays true**: the promises the process can't do without, one line each, with what keeps one only when a person must act on it ("bet only with Bet on it: a card dragged to *Bet* gets no cycle").
- **Make it yours**: one line of up to three requests for the parts left out on purpose ("Add a Take-home stage").

The why behind each step and the rare cases stay out; the views, the rules and the sample records show them. In the built Space every view, report and app the guide names is a mention of it, which shows its current name and opens it, and nothing else is: rules, databases, fields and records stay plain names. The process document is for the part of the process that is written, not tracked (an interview guide, a definition of done), named the way the team names it, with its content in Markdown.

### Apps

Find the process's central moment, where the team stands in front of the work and decides, and ask whether a board, timeline, calendar or grid shows it well. When it doesn't, an app does: a hill chart for scopes, a funnel you drag candidates through, a seating or floor map, a weekly capacity grid, scorecards side by side per candidate, a betting table with appetite budgets. An app is one of two kinds, chosen by what the moment looks at: a **view** app, a page of its own in the Space, when the team looks at all the work at once (the hill, the betting table, the capacity grid); a **layout** app, a tab on every record page of one database, when they look at one record at a time (the scorecard comparison on a Candidate, a progress picture on a Project). In the spec, the Apps section exists even when it's empty: name the app you considered and why a view covers it, or specify the one you're building (name, kind, one-line purpose, "how it works": what it shows, what people can click or drag, what it changes and when it saves, what it shows with no data; and the fields it reads and writes). No code; the build guide builds it.

### Sample story

The design doesn't list the records. It tells a short story, and the build invents the records from it, as the build guide §4 says. The story is one believable moment around today, as if the team were a month in:

- a current period in progress, and the next one planned
- the hero record, and where it stands
- what else is in flight
- something finished
- something stuck, late or dropped, so the flags and red cards have something to show

Everything in the story is invented: never real people, customers or records from the workspace. The Space is judged in the first minute it's opened, and an empty board loses that minute.

In the spec, write the story as one paragraph under 120 words, in the spec's names, then one line with the total.

```markdown
## Sample story

Three jobs are open: Senior backend engineer for six weeks, Product designer for a month, and Customer success manager, with two openings, for three weeks. Data analyst was filled six weeks ago by the one hire so far. Ana Ruiz (example) is in screening for the backend role, and another screening candidate has sat there for sixteen days. Three people applied in the last three days and three are interviewing, with interviews booked this week, one of them today; every done interview has its scorecard. Two candidates have offers out, sent four and nine days ago, and two were rejected, each with a reason.

About 36 records.
```
