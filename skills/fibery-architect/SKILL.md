---
name: "fibery-architect"
description: 'Design and build a ready-to-run Fibery Space for any process, directly in the connected workspace, or change one the team already runs: databases and fields, links to existing databases, workflows, formulas, views, reports, the automations the process depends on, a custom app where views fall short, a guide and sample data, built with Fibery MCP. Starts from a one-line idea, an interview, a process document or an existing Space. Use whenever someone wants to set up, model, design or build a process, workflow, pipeline, tracker, CRM, hiring flow or service desk in Fibery, asks "how should I model X in Fibery", or wants to add to or restructure a Space they have. Not for reviewing a workspace (fibery-health).'
compatibility: 'Needs the Fibery MCP server connected to a workspace where the person can create Spaces, and a strong reasoning model (Sonnet 5.5 or better). A custom app also needs web access to the workspace.'
---

# Fibery architect

Turn how a team works into a Fibery Space they can run tomorrow: about 80% of what a mature Space would have, in the team's own words. Call shapes come from Fibery MCP's own tool descriptions and guides (`get_fibery_skill`); this page says what to build and what Fibery won't tell you.

## The flow

1. **Read the workspace first** (`get_spaces`; `get_databases` for likely matches and for `fibery/user`). Link to a database that already is the system of record for a noun (customers, people, products); never build a second one. A link adds a field to that database, so the person needs `architect` access there (`get_spaces` shows it); without it, leave the link out and say so. When a Space for the same process is already there, build beside it under a free name and say in the report that it could be extended instead. Follow the workspace's language and the case its own names use. Note which names are taken.
2. **Understand the process** (next section): one round of at most four questions, never a second, about how the work goes (stages and endings, roles, who uses Fibery, what goes wrong most), each with your guess. Never ask about fields, views, rules or which database to link. After "just build it", ask nothing.
3. **Build straight away,** as soon as the answers are in. No design to show, no summary to approve. A build is about ten calls, not a hundred: one `execute_code` script per step, each making all of that step's calls (inside a script every Fibery tool is a function of the same name). The structure in one `create_spaces` call; then all formulas in one script and all sample records in another; then all views with their mentions, the report with its tabs, and all rules, a script each; then the guide. An app is created empty with the views, so the guide can mention it, and written last. Once the structure is in, send the person one line with the Space's link, so they can open it and watch it fill; nothing more until the report. Where tools load on demand, load once, in one search, the ones whose shapes a build needs (`execute_code`, `get_spaces`, `get_databases`, `get_me`, `create_spaces`, `create_formula_field`, `update_fields`, `create_entities`, `create_view`, `get_entity_mention`, `create_report`, `add_chart_tab`, `get_report`, `remove_tab`, `create_automation`, `query`, `query_views`, `read_document`, `replace_document_blocks`, `fetch_view_data`, `get_fibery_skill`, and for an app `create_custom_app`, `create_custom_app_dev_token`), and read Fibery's guides for views, automations and reports once, before the first script.
4. **Report in a few lines:** the Space and where to start (the guide, then the daily view, both linked); what you assumed, in two or three lines, links to existing databases included, so a wrong guess costs them one sentence; what is left to the person (who may open the Space, a form to share, the real people to put in any field a rule notifies or assigns); what you couldn't check (an app you haven't seen run); and that the examples can be removed.

## Understand the process

| The person gives you | Do this |
|---|---|
| An idea ("set up our hiring") | One round, often two questions: the stages and the roles. After "just build it", ask nothing. |
| A vague idea, or a request to be interviewed | Still one round, the full four, in their words, concrete ("what happens to a ticket after someone replies?"). Then build. |
| A process document, SOP or notes | Read all of it first; ask only about the gaps. |
| An existing Space to copy or improve | Read it, then design a new Space from it. The existing one is never changed. |
| A question ("how should I model X?") | Answer in a few lines and build nothing: the databases, the stages, who does what, the daily view, what would link. Offer to build. |

What you learn becomes: the things they talk about, databases; the stages and how work ends, the workflow; who does what and who decides, people fields and buttons; what they look at every morning and every Monday, views; the rules they keep in their heads, automations; what goes wrong most, a field that records it and a red flag or a view that shows it; what they already track in Fibery, links; the numbers they want without calculating, formulas. Their words become the names.

The four questions, by what they are worth: how the work moves and every way it ends (Lost, Cancelled: boards hide what they lack); who uses Fibery and who does what; what they look at every morning; what goes wrong most today. Drop the ones the request already answers.

Everything the round leaves open, choose yourself from the standard below, and build. Don't play the model back and wait for a yes: the last message says what you assumed ("I assumed a shift needs two to four people and that only the three of you log in"), and a change after the build costs them less than another round before it.

## What a good Space has

- **Databases:** the nouns with a life of their own, singular, in the team's words; a noun that only labels something is a select. The people or companies the work is for (a client, a customer, a supplier) are a database, linked when the workspace has one. Names use letters, digits and spaces only. Each database gets its own color. A typical process needs at most 7 databases, 8 views, 8 formulas, 5 automations and one app; fewer is fine.
- **Stages:** a workflow, never a select, four to eight states named as the team says them, every way the work can end a finished state, the unhappy ones too (Declined, Lost, Cancelled), each state colored. A waiting state before work starts (Backlog) is typed Not started.
- **Fields:** only what a view, formula or rule uses or a role fills every time. Select options get a color and an emoji. A number carries a unit when the number alone is ambiguous (h, d, km, kg). A description only where the name leaves a question. A record's write-up lives in its Description under headings; a separate rich-text field only when different people fill the parts at different times.
- **People:** a people field per role; a role that gets a "My …" view is to-many. People without a login are a database, not a people field. One person working alone needs no people fields.
- **Links:** to an existing database, spelled exactly as `get_spaces` shows it, two or three at most. Examples never link to existing records.
- **Formulas:** only with a consumer, and a value when inputs are missing. Worth having: counts and progress a card shows; days open or in stage; a true-or-false "late" or "stuck" flag that colors the card and that rules can filter on; a linked fact a card needs (a view shows only its own database's fields). After creating one, replace its description: Fibery keeps your prompt there.
- **Dates that count are stamped by a rule.** A day count or a late flag reads a date a rule sets when the record is created (and on each state change, for days in stage), never one somebody types; such dates stay off forms.
- **Views:** one per question. The daily board first (columns by state, stuck or late records red); "My …" for every role that has a people field, tasks included; a calendar or timeline where dates drive the work; a map when records have addresses; a gallery when records are told apart by a picture; a form when records come from outside the team; a parent with its children nested in one list; a grid of what finished. In every view put the Name first in the fields yourself (left out, Fibery adds it last), then what the record belongs to, its state, who, when, how much. Each view's description is the question it answers. A view that only adds a filter to another is not a view. A calendar card shows only the Name, so those names must say what the record is.
- **Reports:** at most one or two, their charts as tabs, only for a question the team asks.
- **Automations:** must-have only: keep a date, move a parent when its children finish, a decision as a button, one reminder. Native actions, no scripts, no courtesy notifications. A rule can't branch, compare two fields, count across records, refuse, send email or comment on a linked record: make that a flag formula or a step in the guide. A button has no filter, so its description and the guide say when to press it. A rule notifies only people in a field of its own record, so a reminder to a parent's people about its children goes on the parent, filtered by a rollup formula. A record a rule adds gets a due date counted from the trigger's date and an owner, or the report says who must be set.
- **A custom app:** considered every time, one at most. Find the process's central moment, where the team stands in front of the work and decides. When a board, timeline, calendar or grid doesn't show it, an app does: a hill chart, a funnel candidates are dragged through, a floor map, a weekly capacity grid, scorecards side by side. It is a page in the Space when they look at all the work at once, or a tab on every record of one database when they look at one record. Decide what it shows, what people click or drag, what it changes and what it shows with no data, and build exactly that.
- **A guide document** named "How to run <process>", under 500 words: a one-line promise; how it runs here (each step says who acts and in which view); where to look; what stays true; what to add next. Views and a page app in it are mentions; a tab app is named as a tab on its database's records. Don't start a line with a quotation mark.
- **Sample data:** enough invented records to fill every view, usually 30 to 50, and never a database dropped to keep the count down. They tell one believable moment: work in flight, something finished, something stuck or late so the red cards show; records in every state; one record with a full Description. Every name ends with " (example)" and is unique in its database; a child's name carries its parent's ("Laptop for Ana"). People are you, and every people field a rule notifies is filled. Emails are at example.com. Ages live in date fields, since Creation Date can't be set. What a rule would have stamped or added is written by hand, the full set on every record the rule would have fired on: rules run only on records made after them.

## Boundaries

Never change or delete anything that existed before, unless the person asks for a change to that Space. A new build adds outside its Space only the inverse field of each link and the `user/…` field of each people field. A rule on an existing database, or one that writes to its records, only when the person asked for it. Sample data is invented: never real people, customers or records.

## Changing a Space that exists

Read it first: its databases and fields, views, rules, and whether any record's name lacks " (example)". The person needs `architect` access to the Space; without it, say so and change nothing. Say in a few lines what will change, then do it; no list to approve.

- **Only examples in it:** what the build made may be changed or removed. New examples go in with the rules of their databases switched off, and the rules go back on in a later call; otherwise the rules fire on them.
- **The team's records in it** (any record without the mark): nothing of theirs is deleted. Where Fibery converts a field in place and nothing is lost (a number's decimals, a date to a date-time, a select into a database), convert it. Otherwise a field that is replaced stays, renamed "<name> (old)", and its values are copied into the new one. Something they ask to delete is retired: renamed "(old)", taken off the views, its rules switched off, and the person told to delete it in Fibery once they have checked. A change that would lose or rewrite their data (values rounded, records moved to another state, values overwritten) waits for a yes, asked in one sentence.
- **"Remove the examples"** deletes the records whose names end with " (example)" and nothing else; say how many went and how many stayed.
- After a change: fix the guide's lines it touches, look once at the view that changed, and tell the person in a line or two what changed and where it shows.

What a change touches that you wouldn't expect:
- A new state or option lands last; to place it, send the whole list in order. An option left out of a full list is deleted with its values.
- A new state is in no filter that lists states: add it to every view and rule that lists them, or its records vanish from them.
- A view is written again whole: a partial config wipes what it leaves out, and a read gives filters as text, not as something to send back.
- Renaming a field: views, formulas and rules follow; report tabs name fields as text and don't.
- Renaming a database also renames the link fields that point to it and the word inside view names, and leaves the old word in rule texts, tab titles and the guide.
- A number's decimals and a date to a date-time convert in place. A select to a multi select, or a person to people, comes back as a new field: what used the old one must be pointed at it again.
- A rule's action is rewritten whole, each generated value as a prompt; to keep an expression, write "Use exactly this Fibery formula: <expression>".

## Fibery facts you can't guess

- A view shows only its own database's fields, and drops an unknown field without an error.
- View filters and color rules take state and option names. Ids, not names, for: a rule's filter or value on a state or option, a form's default option, a view filter on one record.
- "Is me" works on to-many people fields only.
- Every matching color rule applies, so a rule after the red one excludes what the red one matches.
- A gallery needs a files field as its cover.
- A list or grid can't group by a select or state; a board or timeline can, but not by a number, a text or a date.
- A formula is written by Fibery from a plain-words description. End it with the result type, put the empty case first to keep a count whole, and compare the stored expression with what you meant. For money, a division, a share or three or more conditions, write "Use exactly this Fibery formula: …". A money or decimal formula needs a decimal expression from the start (its empty case is `0.0`); `update_fields` then sets Money, the currency and the places. A whole-number formula takes no decimals later.
- In a rule, a text field that names the trigger record is a formula value. A `{{Name}}` template is filled in only in comments and notifications; in a field it stays as typed.
- `updated` in a rule names its fields, or it fires on every edit.
- Schedules are in UTC: convert from the team's time zone and say both times.
- A relative date in a filter is one day ("1 week after now" is that day only). A period takes two bounds: next week, seen from Friday, is on or after 3 days from now and on or before 9.
- Rules are created switched on. Create the sample records before the rules.
- `create_spaces` doesn't refuse a Space or database name that exists: it adds into it. A new build takes a free Space name ("Hiring 2") and says so; when its first call lists the Space as `unchanged`, stop and tell the person. A taken inverse name does refuse the whole spec; people-field inverse names are workspace-wide and case-insensitive.
- A new report has a default tab "Chart" to remove. Report expressions take square brackets: `[State]`, `COUNT([Id])`.
- Views made in parallel land in the sidebar in a random order: make them one at a time, in the order wanted.
- A script is killed at 55 s. Each formula or generated rule value takes Fibery 6 to 10 s, so independent ones go in parallel; a formula that reads another is made after it.
- After a timeout or a lost connection the script has usually finished: read what exists (`get_databases`, `query_views`, `query_automations`, a `query` of the records) and send only what is missing. Never delete to start over.
- A formula's type can't be changed: delete the field and make it again, before the views that use it. A percent formula is a whole number from 0 to 100, its 0 case first, multiplied by 100 once.
- `get_entity_mention` gives the mention text of a view for the guide; copy it whole. A document's secret comes from `query_views({id})`; `fibery/view` can't be queried.
- A location needs coordinates you supply and `addressParts`, even empty.
- A custom app: `get_fibery_skill({skill: "custom-apps-dev"})`, called directly since a script can't call it, is the source of truth for the stack, the token and the upload. The code looks databases and fields up by id when it runs, because people rename things; it changes only the fields it is meant to write and adds no packages. The upload needs web access to the workspace, which a script doesn't have. Without it the app stays empty: report it as created, not built, and give the person its brief to paste into the app's AI builder in Fibery.
