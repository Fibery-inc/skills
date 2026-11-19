# Changelog

One or two lines per version, newest first. Git keeps the full notes of every release.

## 1.11.0 — 2026-11-19

- fibery-architect has one change path, `references/change.md`, for every change to a Space that exists: read it with one small script, say in a few lines what will change, do it. New things go through the build's own scripts, edits are plain calls in one script. `extend.md`, `extend-scripts.md`, `tweaks.md` and `existing-space.md` are gone, with the extension's approval list, scripts 0, 4x and 3x and their rerun logic.
- In a Space with the team's records nothing of theirs is deleted (a replaced field stays as "(old)", its values copied by a short batching script) and a change that would lose or rewrite their data waits for a yes.
- `build-guide.md` and `scripts.md` are one file, `references/build.md`: per script its rules, template and traps. Rare shapes and the app moved to `build-reference.md`.
- The changelog is short.
- `change.md` retires a team's database, field, view or rule instead of deleting it, writes a rule's action back in its write shape, and says what a database rename reaches; `build.md` sets a formula's number format, shows a weekly schedule, an Add Item action and the number filter operators, and keeps script 5 inside the time limit.

## 1.10.0 — 2026-11-19

A new build runs on thin scripts that run once: 10K of fixed code in place of 31K. A text naming the trigger record is a `formula` value; script 5 logs a stored `{{`; script 6 checks counts with `is` and `count`.

## 1.9.8 — 2026-11-19

Follows Fibery MCP's new document reads (one line per block, short ids) and other tool changes.

## 1.9.7 — 2026-11-16

`tweaks.md`: while a Space holds only its examples, a change goes straight in with one script. Four builds tested.

## 1.9.6 — 2026-11-16

The Space is built in the language its team reads; the person is answered in theirs. Five more fixes for the person the Space is built for.

## 1.9.5 — 2026-11-16

Scripts read the TOON text that `get_spaces` and `get_databases` now return.

## 1.9.4 — 2026-11-16

Recipes and recipe-writer are removed; fibery-architect designs from the process directly.

## 1.9.3 — 2026-11-06

Script 1 uses `create_spaces`, which replaced `create_schema`.

## 1.9.2 — 2026-10-31

Recipes are found through the cookbook's search instead of its whole index.

## 1.9.1 — 2026-10-29

One report per database, its charts as tabs; metric and table tabs.

## 1.9.0 — 2026-10-29

fibery-architect extends a Space the team runs: a read, a list the person approves, guarded scripts that rename, convert and copy values.

## 1.8.28 — 2026-10-28

Whole mentions in the guide; the app's upload command keeps its variables.

## 1.8.27 — 2026-10-28

Script 1 makes the whole structure in one schema call that checks the spec first.

## 1.8.26 — 2026-10-28

Follows Fibery MCP's renamed Space and workflow tools.

## 1.8.25 — 2026-10-28

Children nest in a list when the levels show different fields.

## 1.8.24 — 2026-10-28

A number field gets a unit where the number alone is ambiguous.

## 1.8.23 — 2026-10-28

New names follow the workspace's case.

## 1.8.22 — 2026-10-26

A money formula is sent as an exact expression.

## 1.8.21 — 2026-10-25

Cards with a picture are a gallery, with placeholder covers on the sample records.

## 1.8.20 — 2026-10-24

A new plugin description and search keywords.

## 1.8.19 — 2026-10-24

The README says what the plugin sends and fetches outside Fibery MCP.

## 1.8.18 — 2026-10-24

The plugin manifest has its directory listing fields again.

## 1.8.17 — 2026-10-24

The plugin brings Fibery MCP with it.

## 1.8.16 — 2026-10-23

Scripts use more of Fibery's one-minute limit; nothing waits on the app.

## 1.8.15 — 2026-10-23

Rules start off while sample records are written; the guide comes first in the Space.

## 1.8.12 to 1.8.14 — 2026-10-23

The build's order settled: structure, formulas, everything else, then the guide; shorter templates.

## 1.8.0 to 1.8.11 — 2026-10-23

Builds right after the questions, asked through the client's question tool and fewer of them; the guide mentions its views; a short report for the person; colors, emojis, field descriptions and column order chosen as a person would; locations written in full; a leaner build guide.

## 1.3.0 to 1.7.0 — 2026-10-20 to 2026-10-21

fibery-health gathers its evidence with one script, reads real workspaces in full, and starts a big workspace with an overview; recipes drop their agent section and gain Sources.

## 1.0.0 to 1.2.1 — 2026-10-13 to 2026-10-14

First release with fibery-architect, fibery-health and recipe-writer; recipes from the Process Cookbook; scripts that stop before the time limit; a one-screen guide.
