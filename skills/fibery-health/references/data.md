# Data pass

Records, work and deletions for the regular databases in scope, from the script's data facts and `history` lines; automations belong to the structure pass. Under about 20 records, give counts ("5 of 7"), not percentages. Over 2,000 records, a database is read from its newest 1,000 (its `sample` says so): numbers marked `all` cover every record, so quote those, and say which ones come from the newest records.

## Records

- **Unused fields**: `fields` filled in 5% of records or fewer (checkbox: never ticked); skip formulas and fields marked `new` (added this month). Tidy-up; Important in a busy database.
- **Empty rich text**: a `rich` field empty in most records when the database description says it holds something (the brief, the pitch). Important: the substance was meant to live there.
- **Missing links**: `emptyLinks`, a key single relation empty for 2–50% of records, split by state so you can judge where it should be set (an idea without a campaign is fine). Important.
- **Untitled records**: `untitled`, with `untitledLinks`. Important at 5 or more, otherwise Tidy-up.
- **Duplicates**: `duplicates`, the same normalized title, with the relations the copies share and how many have links in a collection field, which means other records point at them. Important when other records link to both copies, otherwise Tidy-up.
- **Text that repeats a few values**: a `text` field with at most 15 distinct values, filled in a third of the records or more, should be a select. Tidy-up.
- **Dormant**: no new record (`made`, the second date) for 6 months in a space otherwise in use. Tidy-up.

## Work that isn't moving

For databases with `states`, or with a status kept in a select (its `options` counts). Skip workflows used as labels (a message or log database with nearly every record Started) and rating selects (On track / At risk / Off track).

- **Stuck**: Started and no change by a person for 30 days. `work.noChangeSince30d` comes from the modification date on a database without formulas; where formulas move that date every time they recalculate, its `history` line gives it. Important; Critical when that's over 20% of the database's unfinished records and at least 5.
- **Overdue**: unfinished, with a due, delivery or publish date in the past. `work.pastDates` lists the passed dates of unfinished records and already leaves out dates that record an event (created, started, received, done); still count only deadlines, not a projection or a date that simply happened. Without a workflow it covers a database with a Status, State, Stage or Phase select, split by it: count only the open options. Important.
- **Stale backlog**: `work.notStartedBefore`, Not started and created more than 180 days ago. Tidy-up.

## Deletions

The `history` lines: records deleted or archived in the last 30 days per database, and its `peak`, the most one author removed within one hour. 50 or more by one author within an hour is Critical: give the author, count and hour, and note the Activity Log can restore them. `ai-answer` among the sources marks changes made by AI agents.

## A number by hand

When a finding needs a number the facts don't have, one direct `query` settles it. Never count empty values with `["=", [...], true]`: inside a count it returns the database total. Count the filled records with `false` in `q/where` of `{"q/from": "Space/Database", "q/select": ["q/count", "fibery/id"]}` and subtract: text `["=", ["q/null-or-empty?", ["Space/Field"]], false]`; number or date `["=", ["q/null?", ["Space/Field"]], false]`; relation, select or collection `["=", ["q/null?", ["Space/Field", "fibery/id"]], false]`; rich text `["=", ["q/null-or-empty?", ["Space/Description", "Collaboration~Documents/Snippet"]], false]`; checkbox `["=", ["Space/Flag"], true]`, which counts ticked records.
