# Data pass

Records, work and deletions for the regular databases in scope; automations belong to the structure pass. The query patterns are at the end; read "Counting empty values" before the first query.

## Records

Up to 100 records: read them all in one query and compute everything exactly from it. More: read the 100 newest and confirm suspects with exact counts. Under about 20 records, give counts ("5 of 7"), not percentages.

- **Unused fields**: filled in 5% of records or fewer (checkbox: never ticked); skip formulas and fields added this month. Tidy-up; Important in a busy database.
- **Empty rich text**: a Description or document empty in most records when the database description says it holds something (the brief, the pitch). Important: the substance was meant to live there.
- **Missing links**: a key single relation empty for 2–50% of records, within the states where it should be set (an idea without a campaign is fine), and orphans whose parent was deleted. Important.
- **Untitled records**: Important at 5 or more, otherwise Tidy-up.
- **Duplicates**: the same normalized title under the same parent, from a title-sorted query over all records; ignore empty and formula titles. Important when other records link to both copies, otherwise Tidy-up.
- **Text that repeats a few values**: at most 15 distinct values and a third of the records means it should be a select. Tidy-up.
- **Dormant**: no new record for 6 months in a space otherwise in use. Tidy-up.

## Work that isn't moving

For databases with a workflow, or with a status kept in a select (count records per option). Skip workflows used as labels (a message or log database with nearly every record Started) and rating selects (On track / At risk / Off track).

- **Stuck**: Started (or an in-progress-like option) and no change by a person for 30 days. Important; Critical when that's over 20% of the database's unfinished records and at least 5.
- **Overdue**: unfinished, with a due, delivery or publish date in the past. Important.
- **Stale backlog**: Not started and created more than 180 days ago. Tidy-up.

`fibery/modification-date` is a person's last change only on databases without formulas: formulas rewrite it, and those using Today() do so every night. Elsewhere, take the changes people made from `search_history` (below).

## Deletions

`search_history` per database for records deleted or archived in the last 30 days. 50 or more by one author within an hour is Critical: give the author, count and window, and note the Activity Log can restore them. `fromService: "ai-answer"` marks changes made by AI agents.

## Queries

### Counting empty values

Never count empty values with `["=", [...], true]`: inside a count it returns the database total. Count the filled records with `false` and subtract them from the total.

| Field | Counts filled records |
|---|---|
| text | `["=", ["q/null-or-empty?", ["Space/Field"]], false]` |
| number, date, other primitives | `["=", ["q/null?", ["Space/Field"]], false]` |
| single relation, select, or collection (records with at least one link) | `["=", ["q/null?", ["Space/Relation", "fibery/id"]], false]` |
| rich text | `["=", ["q/null-or-empty?", ["Space/Description", "Collaboration~Documents/Snippet"]], false]` |
| checkbox (never empty) | `["=", ["Space/Flag"], true]`, which counts ticked records |

Put the filter in `q/where` of `{"q/from": "Space/Database", "q/select": ["q/count", "fibery/id"]}`. One aggregate per query. Skip formula fields: their emptiness follows their inputs.

### Reading records

- **All records, or the 100 newest**: select the title, primitive fields and single relations as `["Space/Relation", "fibery/id"]`, order by `fibery/creation-date` descending, `q/limit` 100. Leave out files, collections and rich text, which can overflow the tool's output.
- **Newest or oldest record**: order by `fibery/creation-date` and take `q/limit` 1. `q/min` and `q/max` aren't supported.
- **Duplicates**: `{"q/from": "Space/Database", "q/select": {"id": "fibery/id", "name": "Space/Name", "parent": ["Space/Parent", "fibery/id"]}, "q/order-by": [[["Space/Name"], "q/asc"]], "q/limit": 1000}`, paging with `q/offset`. Repeats sit next to each other; compare them after normalizing case, spaces and trailing punctuation.
- Relations, selects and states need a subfield in `q/where`: `["workflow/state", "enum/name"]`, `["Space/Relation", "fibery/id"]`.

### Work

- **Records per state**: `{"q/from": "workflow/state_Space/Database", "q/select": {"state": "enum/name", "type": "workflow/Type", "final": "workflow/Final", "n": ["q/count", ["workflow/objects", "fibery/id"]]}}`
- **Records per select option** (status kept in a select): `{"q/from": "<enum database>", "q/select": {"option": "enum/name", "n": ["q/count", ["Space/entities", "fibery/id"]]}}`. The enum database is the field's type in `schema_detailed`, for example `Sales/State_Sales/Order`.
- **Stuck**: list rather than count, so each record comes with its name and `url`:
  `{"q/from": "Space/Database", "q/select": {"name": "Space/Name", "state": ["workflow/state", "enum/name"], "modified": "fibery/modification-date"}, "q/where": ["q/and", ["q/equals-ignoring-case?", ["workflow/state", "workflow/Type"], "Started"], ["<", ["fibery/modification-date"], "<cutoff>"]], "q/limit": 100}`
- **Unfinished**: `["=", ["workflow/state", "workflow/Final"], false]`. Overdue adds `["<", ["Space/Due date"], "<today>"]`.

### Changes made by people

On a database with formulas, `fibery/modification-date` moves whenever they recalculate, and every night when they use Today(). Ask `search_history` what people changed instead; automatic changes from automations, formulas and integrations are excluded by default.

- **Up to about 30 Started records**: one call each, `{"database": "Space/Database", "entityId": "<id>", "actions": ["created", "updated", "collectionItemAdded", "collectionItemRemoved"], "since": "<30 days ago>", "limit": 1}`. No result means stuck.
- **More**: the same call without `entityId` and with `limit` 100, up to 5 pages with `sinceItem`. Started records missing from the result are stuck; if pages remain, say the count is an upper bound.

### History

- **Deletions**: `{"database": "Space/Database", "actions": ["deleted", "archived"], "since": "<30 days ago>", "limit": 100}`.
- **Schema changes**: field and database changes are logged under `fibery/field` and `fibery/type`, not under the database. Filter with `entityName: "Space/"` instead of `database`.
- `fromService` says where a change came from, for example `ai-answer` for AI agents and `formula_recalculation`.
- Ignore collection changes on `Collaboration~Documents/References`: they are mention backlinks.
