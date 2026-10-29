---
name: "fibery-health"
description: 'Check the health of a Fibery workspace or space. By default it reviews the structure: copied, test and empty spaces, databases and fields; missing descriptions; status kept in plain selects; wrongly typed workflow states, messy select options; formulas Fibery disabled or fixed to a date; text fields that should be relations; people lists that duplicate workspace users or leave access to people who left; failing, silent or never-run automations. On request it also checks the data: unused fields, missing links, text that should be a select, dormant databases, demo data. Returns a short ranked report with exact numbers and links, then applies only the safe fixes the person approves. Use whenever someone wants to health-check, audit, clean up or declutter a workspace or space, asks what is broken, stale, unused or badly modeled, wants to find unused fields or broken automations, or is preparing Fibery for Claude or other AI agents, even if they never say "health". Not for designing new spaces (fibery-architect).'
compatibility: 'Needs the Fibery MCP server with its execute_code tool: the evidence comes from one script. It sees only what the running user can see, so run it as a workspace admin for full coverage. Applying fixes needs Creator or Admin rights.'
---

# Fibery health check

Two passes, like a car inspection. The **structure pass** is the walk-around every check gets: how the workspace is built and wired, from the schema and the automations. The **data pass** puts chosen spaces on the lift, only when the person asks: how the records actually fill their fields and links. One script gathers the evidence, in one call for most workspaces; you judge it and hand back a short, ranked list with evidence.

## What you need

- **Fibery MCP with `execute_code`.** The evidence comes from the script in `references/scripts.md`. If the connected server has no `execute_code`, say that this check needs it and stop.
- **Only `execute_code` until the report.** Every other tool runs inside the script, where it needs no loading. In a client that loads tools on demand, load `execute_code` alone; a fix loads what it needs later.

## Ground rules

- **Read-only until a yes**, a yes covers one batch, and records are never deleted.
- **Evidence**: an exact number and a link in every finding. Links come only from the script's output, which carries the `url` of every Space, database, record and automation it mentions.
- **At most five top fixes**; one line each for the rest.
- **Say what you couldn't see.**

## 1. Passes and scope

Decide from the request, before any call:

- **Structure** is the default: a request to health-check, audit, clean up or review a workspace or space gets the structure pass, automations included. It covers the whole workspace unless the person names spaces; copies of an in-scope space are reported wherever they are.
- **A big workspace starts with an overview.** For the whole workspace, first count its databases with one short `execute_code`: `const c = await display_schema_capabilities({}), s = Object.keys(c.accessInfo.spaces), a = (await display_schema_capabilities({spaces: s})).accessInfo; log(Object.keys(a.databases).filter(d => s.includes(d.slice(0, d.indexOf("/")))).length + " databases");`. Over about 40, a full check would take many runs: follow `references/overview.md` instead, one line per Space, and the Spaces the person then picks are the scope for everything else, the question they asked included.
- **Data** runs only when the person asks for it: the data pass by name, a full or deep check, or a question about records (unused fields, missing links, whether records can be trusted). A full check runs both. Scope: the spaces the person names; otherwise every database when there are about 30 or fewer. With more and no space named, the structure pass or the overview comes first, then propose 3–5 spaces and ask once.
- A question about one area (broken automations, missing descriptions, unused fields) gets just that area's checks, from the same script.
- With more than one Fibery connector and no workspace named, ask which one.

## 2. Gather the facts: one script

Tell the person in one line what you'll check ("the structure and data of Mushroom Farm"). Then send the script in `references/scripts.md`, copied whole with only its first line changed: the spaces in scope, and `DATA = true` for the data pass. It reads, for every database in scope, its records, creation and fields with how often each is filled, formulas Fibery disabled or fixed to a date, states and select options with their counts, people lists against their users' accounts, and its rules and buttons with their last run, trigger, filter and actions; with `DATA`, more records and the links they're missing; across the workspace, same-named databases and copies, the fields on every user and spaces without databases.

It stops starting new work after 35 seconds or about 32,000 characters of output. When its last line says "run this script again", send the same script with the `SKIP` it gives: the rerun prints only what's left. A `failed` count above zero is a coverage gap: name what it couldn't read.

`references/scripts.md` explains every key it logs. Don't query again what the facts already say; for one number they don't settle, send a short `execute_code` with that one `query`.

## 3. Classify each database first

From the facts:

- **Integration mirror**, when two hold: `readOnly` (every field read-only); a "Deleted in …" field (`deletedIn`); records created by no one (`by` shows `null`, which forms and the API also leave); a Space named after an app or service (Jira, Intercom, Slack, HubSpot, Zendesk, GitHub, Email, Discourse and the like); a description that mentions syncing. Never change one or call it a duplicate; suggest relating it to the canonical database. Its automations are checked; the data pass skips it.
- **Archive**: a space called Archive, Old or Legacy. Only ask whether it can go.
- **Demo or test**: most records in its space's main database are titled "(example)" (fibery-architect's sample data), all of the space's records were created within the same minute (every database's `made` shows that one minute), or the space name says demo, test or sandbox. One Tidy-up line per space: keep it or delete it. Its automations are still checked, since they notify real people; the data pass skips its records.
- **Regular**: everything else, checked fully.

## 4. The passes

- **Structure** (default): the checks in `references/structure.md`, over the facts and the `automation` lines.
- **Data** (on request): the checks in `references/data.md`, over the facts the script gathered with `DATA = true`.

Severity everywhere: **Critical** splits, hides or breaks data now; **Important** misleads people and agents or lets work rot; **Tidy-up** is clutter.

## 5. Report

```markdown
# Health check: <workspace>, <scope>, <date>
Run as <name> (<role>). <N> spaces, <N> databases (<N> regular, <N> integration, <N> demo or test), <N> records.

## Summary
Three to five sentences: overall state, the fixes that matter most, any coverage caveat.

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
By area, one line each. Questions for the person (does a parking state mean paused, is a database parked) go last, under To confirm, outside the scorecard.

## Agent readiness
<X> of <Y> regular databases described. Drafts for the important rest (what one record is, its key relations, what not to confuse it with) for an admin to paste: the MCP can't write descriptions yet.

## Not checked
The pass not run; spaces the person can't read; fields the script couldn't read; formula results; stuck, overdue or duplicate records and deletions; permissions, view usage, field descriptions, automation runs before the last one.
```

A number from a sample keeps "of the newest 1,000" wherever it appears, and the summary says what the findings say. An overview has its own report, in `references/overview.md`. Summary, scorecard and top fixes go in chat; offer to save the full report as a document in the person's Private space (load `get_fibery_skill` with `documents` first). After a structure-only check, offer the data pass in one line, naming the spaces you'd check.

## 6. Safe fixes

The person names the findings. Per batch: restate the change, the records it touches and its undo; wait for a yes; apply; re-run the script for that space; report before and after.

- **State types**: `update_workflow_fields` with `fields: [{"database": "...", "update": {"updateOptions": [{"name": "...", "type": "Not started" | "Started" | "Finished"}]}}]`, every database in one call. A parking state only after the person confirms it means paused. Undo: the old type.
- **Delete** an empty database or space, or an unused or test field (show its filled count and a few values first): only when no formula, automation or view uses it (formulas in `schema_detailed`, automations in the `automation` lines and, for a relation, in the database it points to, views in `query_views`), and never on an integration mirror. A relation field goes from both sides. Undo: the Activity Log.
- **Disable a rule**: `update_automation` with `enabled: false`. Undo: enable it.
- **Triage view** for judgment calls (records missing a link): a grid named "Health: <finding>", filtered to exactly those records, most important first. Load `get_fibery_skill` with `views` first. Undo: delete the view.
- **Descriptions**: drafted in the report.

Plans only, never applied here: renames (integrations, scripts and API calls using the old name break), merging copies, merging or removing select options, turning a status select into a workflow, replacing text with a relation, retiring a people list, deactivating users, repairing automations or formulas, deleting a demo space with records. When the person wants a plan's rename, conversion (a status select into a workflow, text into a relation, a people list into users) or repair applied, that's fibery-architect's: it extends the Space with their approval and keeps each replaced field, renamed "(old)".
