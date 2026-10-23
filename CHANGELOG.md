# Changelog

## 1.8.0 — 2026-10-23

fibery-architect builds as soon as the questions are answered: no design card and no "Build it?". It reads the workspace before it asks, so the one questions message also carries what the workspace leaves to the person (a Space name that's taken, an existing database that may or may not be the one to link), says when a Space for the same process exists already, and ends by saying the build starts with the answers. After "just build it" it asks nothing at all. What the card used to show moves to the report: the assumptions made in the person's place, the fields added outside the new Spaces, the By hand settings and what wasn't built. A rule that writes to records of an existing database is built only when the person asks for one. The Build it line of every cookbook recipe, the format and the two bundled copies now reads "Claude asks a few questions, then sets it up in about ten minutes."

## 1.7.0 — 2026-10-21

fibery-health starts a check of a big workspace, more than about 40 databases, with an overview: one script run reads every database's record count, its newest record and the schema, and gives one line per Space (active, quiet or dormant, size, descriptions, leftovers, switched-off and date-fixed formulas, synced databases), with the copies, same concepts and people-field clutter across Spaces. It then suggests 3–5 Spaces and checks in full the ones the person picks, automations included. On Fibery's own workspace (47 Spaces, 229 databases, 2.8 million records) the overview took 3 minutes and one run of a 7 KB script, where a full check of everything would have taken about 12 runs. The script and the report are in the new `references/overview.md`.

## 1.6.0 — 2026-10-21

fibery-health, after its first runs on a real workspace, three of Fibery's own Spaces. Its script read only 5 of their 12 databases: real workspaces have fields the sample Spaces never had (document and whiteboard collections, hidden import fields, selects moved from another Space). It now reads them all, and when a field still can't be read it leaves out that field instead of the whole database. The data pass narrows to what the records say about the model: unused and retired fields (with the formulas that still read them and, for a relation, whether the other side still links), missing links and owners whose users were deactivated, text that should be a select, and dormant databases. Empty rich text, untitled and duplicate records, stuck, overdue and stale work, and deletions are gone, and with them the history reads; the script is one part again, with a `DATA` switch. New structure checks: formulas Fibery switched off or fixed to a date, select options that are unused or split one value, people marked as left whose users can still sign in, names that mix alphabets, rule messages that contradict their rule, and Script actions left as Fibery's template. A scheduled rule counts as silent only when its filter matches records now, and a parking state typed Started is a question, not a finding. A full check of each Space took 2½–5½ minutes instead of 4½–7½, with one script run, and every count in the reports held up when checked against the workspace.

## 1.5.0 — 2026-10-20

fibery-health gathers its evidence with one `execute_code` script instead of dozens of separate calls. Part 1 reads, for every database in scope, its fields and how often each is filled, workflow states and select options with their counts, and its rules and buttons with their last run, trigger, filter and actions; part 2, added for the data pass, reads duplicates, empty links, stuck and overdue work, and deletions from the history. The script stops before Fibery's one-minute cut-off, or before its output gets too long to read in one piece, and its last line says how to run it again for what's left. In tests, a full check of a 15-database Space took under 4 minutes and 12 tool calls instead of 6 minutes and 97, and a structure check of a 43-database workspace about 4 minutes and 14 calls instead of 6 minutes and 175. fibery-health now needs `execute_code`.

## 1.4.1 — 2026-10-20

The Claude plugin manifest drops five keys Claude doesn't read (`icon`, `documentationUrl`, `supportUrl`, `privacyPolicyUrl`, `termsOfServiceUrl`), which made the Claude app warn when the plugin was installed. The support, privacy and terms links move to the README.

## 1.4.0 — 2026-10-20

Every recipe ends with Sources, the one to three published sources it was written from, the main one first; a named method's source moves there from the promise line. recipe-writer reads one to three sources for every recipe, whatever it starts from, and lists them, and the two bundled recipes carry theirs.

## 1.3.0 — 2026-10-20

Recipes have no For AI agents section any more: the recipe format, its checks and the two bundled recipes drop it, and recipe-writer no longer writes agent behaviours. The guide fibery-architect writes already left it out.

## 1.2.1 — 2026-10-14

The recipe format says a rule comments on its own record and notifies the people in that record's own fields, never through a linked record, which most tools can't do and fibery-architect leaves out. To remind someone named on a linked record, a recipe gives the record the rule runs on a person field of its own.

## 1.2.0 — 2026-10-14

The guide every build writes, How to run <process>, now fits on one screen, under 500 words, for recipe builds too: the promise, the loop in up to ten lines that say who acts and in which view, where to look, what stays true, and a line of requests to make it yours. Recipe builds used to copy the recipe's whole story into it, 1,600–2,400 words that people skip; now its last line links the recipe's cookbook page for the why. The recipe format and the bundled recipes say so in What people look at and the Views table.

## 1.1.2 — 2026-10-14

The bundled Shape Up and Content calendar recipes and the recipe format follow the cookbook's fixes from the nine-recipe test: Shape Up's sample story, the format's example too, keeps the two-week cool down, and Content calendar's Stage changed rule also runs when a post is created, so Days in stage counts from one date.

## 1.1.1 — 2026-10-14

fibery-architect, from building all nine cookbook recipes at once and re-testing three: every script now stops before Fibery's one-minute cut-off and logs "time is up, run this script again", and every one, the sample records included, runs again as it is, doing only what's missing and logging what was there before. Script 1 logs every id an app needs, and finds the right app, on any run. A rerun of script 3 repairs a report whose chart was rejected, and reports take the documented conditions and historical sources. The build guide adds what the builds measured: when a formula comes back decimal or whole, no `Now()` in formulas, people fields for every "My …" view, a formula for a report or view that reads a linked record, the Create action and `update_automation`'s shape, prompts that name the triggering record, and rules built without the one action Fibery can't do.

## 1.1.0 — 2026-10-13

fibery-architect looks processes up in the [Fibery Process Cookbook](https://github.com/Fibery-inc/process-cookbook) by itself, so "set up OKRs" builds from the cookbook's recipe without attaching it. The bundled Shape Up and Content calendar recipes are copies of the cookbook's, used when it can't be reached; CI warns when they or the recipe format drift from it. The recipe footer's credit line links to the cookbook.

## 1.0.0 — 2026-10-13

First public release, with three skills: fibery-architect, fibery-health and recipe-writer. One repository installs in Claude Code, Codex, GitHub Copilot, VS Code, Cursor, Gemini CLI and Kiro.
