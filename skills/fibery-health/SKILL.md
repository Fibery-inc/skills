---
name: "fibery-health"
description: 'Check the health of a Fibery workspace or space. By default it reviews the structure: copied, test and empty spaces, databases and fields; missing descriptions; status kept in plain selects; wrongly typed workflow states; text fields that should be relations; people lists that duplicate workspace users; failing, silent or never-run automations. On request it also checks the data: unused fields, empty rich text, missing links, stuck, parked or overdue work, duplicate records, demo data and bulk deletions. Returns a short ranked report with exact numbers and links, then applies only the safe fixes the person approves. Use whenever someone wants to health-check, audit, clean up or declutter a workspace or space, asks what is broken, stale, unused or badly modeled, wants to find unused fields or broken automations, or is preparing Fibery for Claude or other AI agents, even if they never say "health". Not for designing new spaces (fibery-architect).'
compatibility: 'Needs the Fibery MCP server. It sees only what the running user can see, so run it as a workspace admin for full coverage. Applying fixes needs Creator or Admin rights.'
---

# Fibery health check

Two passes, like a car inspection. The **structure pass** is the walk-around every check gets: how the workspace is built and wired, from the schema and the automations. The **data pass** puts chosen spaces on the lift, only when the person asks: records, work and deletions. Hand back a short, ranked list with evidence.

## Ground rules

- **Read-only until a yes**, a yes covers one batch, and records are never deleted.
- **Evidence**: an exact number and a link in every finding. Links come only from tool results: `display_schema_capabilities` (spaces, databases), the `url` on `query` rows and automations, `query_views` (views).
- **At most five top fixes**; one line each for the rest.
- **Say what you couldn't see.**

## 1. Workspace, passes and scope

1. `get_me`: name the workspace and the person's role in the report. With more than one Fibery connector and no workspace named, ask.
2. `schema`, then the passes and their scope:
   - **Structure** is the default: a request to health-check, audit, clean up or review a workspace or space gets the structure pass, automations included. It covers the whole workspace unless the person names spaces; copies of an in-scope space are reported wherever they are.
   - **Data** runs only when the person asks for it: the data pass by name, a full or deep check, or a question about records (unused fields, stuck or overdue work, duplicates, deletions, whether records can be trusted). A full check runs both, structure first. Scope: the spaces the person names; otherwise every regular database when there are about 30 or fewer, or else propose the 3–5 spaces with the most records and ask once.
   - A question about one area (broken automations, missing descriptions, stuck work) gets just that area's checks.
3. `display_schema_capabilities` for the scope: URLs, and what the person can't read. A non-admin gets partial coverage; say so.
4. Tell the person what you'll check and how big it is ("the structure of 14 databases in 3 spaces"), then call `schema_detailed` for every database in scope in as few calls as possible, with `includeRelatedDatabases` off: each call repeats the people database. Newer servers show descriptions only here, not in `schema`. With hundreds of databases, go space by space and keep only findings.
5. Checks that run per database (automations in the structure pass, everything in the data pass) go to helpers when they cover more than about 15 databases and an Agent tool exists: one per space, with the path to the reference file it needs. Each returns `area | severity | database | finding with exact number | link | fix | Claude can fix: yes/partly/no | undo` and record counts; merge and rank centrally.

## 2. Classify each database first

- **Integration mirror**, when two hold: every non-formula field read-only; a "Deleted in Source" field; a space named after an app (Jira, Intercom, Slack, HubSpot, Zendesk, GitHub, Email); a description that mentions syncing. Never change one or call it a duplicate; suggest relating it to the canonical database. Its automations are checked; the data pass skips it.
- **System**: `fibery/*`, `comments/*`, `highlights/*`, `Collaboration~Documents/*`, workflow and enum types. Skip.
- **Archive**: a space called Archive, Old or Legacy. Only ask whether it can go.
- **Demo or test**: most records in its main database are titled "(example)" (fibery-architect's sample data), all of them were created within the same minute, or the space name says demo, test or sandbox. One Tidy-up line per space: keep it or delete it. Its automations are still checked, since they notify real people; the data pass skips its records.
- **Regular**: everything else, checked fully.

## 3. The passes

- **Structure** (default): run the checks in `references/structure.md`: spaces, databases, fields, workflows and selects, relations and people, automations.
- **Data** (on request): read `references/data.md` before the first query, because the obvious way to count empty values returns the database total. Then run its checks: records, work, deletions.

Severity everywhere: **Critical** splits, hides or breaks data now; **Important** misleads people and agents or lets work rot; **Tidy-up** is clutter.

## 4. Report

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
| Work | | | |
| Deletions | | | |

## Top fixes
1. <Finding with number and link>: why it matters. Fix. (I can do this / Needs you)

## All findings
By area, one line each.

## Agent readiness
<X> of <Y> regular databases described. Drafts for the important rest (what one record is, its key relations, what not to confuse it with) for an admin to paste: the MCP can't write descriptions yet.

## Not checked
The pass not run; spaces the person can't read; records that contradict each other; permissions, view usage, formula errors, field descriptions, automation runs before the last one.
```

Summary, scorecard and top fixes go in chat; offer to save the full report as a document in the person's Private space (load `get_fibery_skill` with `documents` first). After a structure-only check, offer the data pass in one line, naming the spaces you'd check.

## 5. Safe fixes

The person names the findings. Per batch: restate the change, the records it touches and its undo; wait for a yes; apply; re-run the check; report before and after.

- **State types**: `update_workflow_field` with `updateOptions: [{"name": "...", "type": "Not started" | "Started" | "Finished"}]`. Undo: the old type.
- **Delete** an empty database or space, or an unused or test field (show its filled count and a few values first): only when no formula, automation or view uses it (formulas in `schema_detailed`, `get_automations` or `query_automations`, `query_views`), and never on an integration mirror. A relation field goes from both sides. Undo: the Activity Log.
- **Disable a rule**: `update_automation` with `enabled: false`. Undo: enable it.
- **Triage view** for judgment calls (stuck work, duplicates, missing links, untitled records): a grid named "Health: <finding>", filtered to exactly those records, most important first. Load `get_fibery_skill` with `views` first. Undo: delete the view.
- **Descriptions**: drafted in the report.

Plans only, never applied here: renames (integrations, scripts and API calls using the old name break), merging copies or duplicate records, turning a status select into a workflow, replacing text with a relation, retiring a people list, bulk-closing stale work, repairing automations, deleting a demo space with records.
