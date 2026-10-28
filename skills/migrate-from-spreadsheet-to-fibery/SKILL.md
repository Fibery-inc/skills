---
name: "migrate-from-spreadsheet-to-fibery"
description: 'Move a process someone runs in a spreadsheet into a Fibery Space, with all its data. Reads a Google Sheet''s tabs, columns, formulas, pivots, charts, filters and color rules; works out the databases behind them (tabs of one kind become one database with a view per tab, repeated names become linked records or selects, dashboards become rollups and reports); asks at most four questions; then builds the Space with fibery-architect, imports every row and checks the formulas against the sheet''s own results. The Space keeps the familiar tables, pivots and charts and adds what a sheet can''t do: forms for logging, linked records, totals that update themselves, calendars and new charts. Use whenever someone wants to move, migrate, import, convert or replace a spreadsheet or Google Sheet with Fibery, or says "our process lives in a sheet", even if they never say "migrate". Excel and Microsoft 365 workbooks come later. Not for loading a CSV into an existing database (Fibery''s own import does that).'
compatibility: 'Hands the build to fibery-architect from this plugin and needs what it needs: Fibery MCP with execute_code and a strong reasoning model. Reads the sheet through a Google Sheets connector that returns grid data (formulas, types, pivots); Google Drive search finds a sheet by name. Uses only read tools on the sheet.'
---

# Migrate from a spreadsheet to Fibery

A team that runs a process in a spreadsheet has already designed it: the tabs are its databases, the headers its fields, the formulas its rules, the pivots and charts its reports, with a workaround wherever the sheet ran out. You read that design from the sheet, ask only what the sheet can't tell you, and hand fibery-architect a design to build, with every row moved over and every formula checked against the sheet's own results. The person opens the Space and finds their tabs as views with the same columns, their numbers matching, their pivots and charts as reports, and beside them what a sheet couldn't do: a form to log from the phone, records that link instead of names typed again, summaries that keep themselves, a calendar and charts of the same data.

## What you need

- **fibery-architect**, this plugin's other skill (`../fibery-architect/`). This skill reads the sheet, decides the model and moves the data; the architect's references build the Space, and this file says only where a migration differs from them. If it isn't installed, say this skill needs it and stop.
- **Fibery MCP with `execute_code`**, as the architect needs it, loaded as its SKILL.md says.
- **A Google Sheets connector** that returns grid data (`get_spreadsheet` with `includeGridData`, and `get_values`), and Google Drive's `search_files` to find a sheet by name. Without one, ask the person to connect it. An Excel file or a Microsoft 365 workbook isn't supported yet; until it is, the person can upload it to Google Drive and open it with Google Sheets, which converts it with its formulas.
- **A working folder** for `sheet-map.md` and `design.md`.

Paths are relative to this skill's folder. What to read, and when:

| File | Read it when |
|---|---|
| `references/reading.md` | first: reading the spreadsheet, what its cells mean, what each tab is, the sheet map |
| `references/model.md` | before the questions: from the sheet map to databases, fields, formulas, views and reports; parity and what to add |
| `references/migration.md` | before the build: its order, the import and check scripts, the guide's extra section, the report |
| `examples/sport-log.md` | once, before your first migration: a sheet map and a design at the depth expected |
| `../fibery-architect/SKILL.md` and the references it lists | as it says, with the changes below; its design guide and build guide stay the source for everything this skill doesn't change |

Read the architect's SKILL.md, design guide, build guide and `scripts.md`, and this skill's three references, in one message before the questions, so the build starts the moment the person answers.

## 1. Read the spreadsheet

Get the file and read it as `references/reading.md` says: its structure in one call, then each tab's cells with their stored values, types and formulas. Write what you find as `sheet-map.md` in the working folder: every tab with what it is (a log, a lookup, a dashboard, a pivot, a reference table, form responses, notes), every table with its header and rows, every column with its type, every formula, pivot, chart, filter and color rule, the oddities (a typo that splits a category, a number stored as text, a date Sheets made out of a time), and what each part will become. Nothing in the sheet disappears silently: cells scattered outside the tables, totals, blank and abandoned tabs are skipped, and each skip is a line in the map.

## 2. Read the workspace

As the architect's SKILL.md §2 and design guide §2 say: what to link to, which names are taken, how names are written. The sheet's own headers are the nearest names (`references/model.md` §2). When the person says to treat the workspace as empty, link to nothing and ask nothing about it; a new Space's name must still be free.

## 3. Model it

Follow `references/model.md`: the architect's noun test applied to tabs and columns, with the rules a sheet needs. Tabs that hold the same kind of row become one database, with a view per tab. A repeated name becomes a record when it has a life of its own (attributes, its own rows to look at, a lookup tab) and a select when it only labels. A lookup tab becomes the database of its noun. A dashboard of combinations becomes a database of those combinations whose summary columns are rollups. Totals, section rows and blank rows are never records. Then two lists:

- **Parity**, so it feels familiar: every tab people used gets a view with the same columns in the same order, filter and sort; every computed column a formula; every pivot and chart a report; every color rule a color. These don't count against the architect's ceilings: the person had them.
- **Better**, within the ceilings, judged by the person who logs and reads the data every day: a form for each kind of row people add often, pickers instead of retyping, names that keep themselves, rollups that update, flags and colors for what matters (a personal best, an overdue row), a calendar or a chart of the same data.

## 4. Ask once

At most four questions, in one round, asked as the architect's SKILL.md §3 says (a guess with each, AskUserQuestion where the client has it), and only what the sheet can't settle and would be hard to change after the build:

- tabs whose columns only partly match: one database or two;
- a structure the sheet flattens: sessions behind repeated dates, a parent behind a repeated group, a reference table that could drive values instead of being read;
- a repeated name that may or may not deserve records of its own;
- who else uses the sheet, when it doesn't show: a team gets people fields and "My …" views, a Google Form feeding it becomes a Fibery form, a process for one person gets neither;
- tabs that look abandoned: leave them behind or bring them.

Never ask what the data shows (types, options, what a column means), and never about fields, formats or colors. One line before the questions says what you found ("11 tabs: 6 logs of 118 rows, a lookup, a dashboard, a reference table, a pivot tab and an empty form tab"); one line after them says you'll build as soon as they answer, in about 25 minutes plus a minute per 500 rows. When the sheet settles everything, ask nothing and say so. An answer may also leave a tab behind ("don't move the references"): its Parity row says so.

## 5. Write the design

`design.md` as the architect's design guide §4 prescribes for a design from scratch, with two differences. The Sample story is replaced by the data. And a **Migration** section closes the spec (`references/model.md` §6): for every database its source (tab, range, header row, rows kept and skipped), each field's source column and how its values change, how the Name is composed, each formula next to the sheet formula it carries, and the Parity table, every element of the sheet with its place in Fibery or a Not carried line with why and what stands in for it.

When a cookbook recipe is the same process (the architect's SKILL.md §1), read it for what the sheet lacks (views, rules, the guide's story), not instead of the sheet: the sheet holds the data, so its model and names win wherever the two differ.

## 6. Build

The architect's build guide, in the order `references/migration.md` §1 gives: the structure; the records, every one, with the import script; the formulas, checked against the sheet's results; views, reports, rules and app; the guide, with a "Where your sheet went" section, and the rules on. Real records change three of the architect's habits: dates are the sheet's, not relative to today; names come from the data, never with "(example)"; and nothing is invented, so there's no sample story and no sample record.

## 7. Report

The architect's report (its SKILL.md §6), with three lines of the migration's own, each only when it has something to say:

> **Sport is in Fibery.** Start with the guide, [How to run the sport log](…), then [Running](…), your Running tab.
>
> **Moved:** 171 records from 8 tabs, every row; the formulas match the sheet on all 289 values, and the dashboard's −100% for an event never swum is now 0.
>
> **Not carried:** times are entered as hours, minutes and seconds (Fibery has no duration field); zeros show where the sheet hid them in white.

- **Moved**: rows per tab, counted in Fibery, and the formula check's result, every difference named with why.
- **Not carried**: what the sheet did that Fibery can't, one line each with what stands in for it, from the design's Parity table.
- The sheet stays as it was: say it was read, never changed, and that rows added to it before the team switches can be brought in by running the import again.

The architect's Your turn, Not built and Worth a look follow; Build notes in `design.md` add the rows per tab, the import's runs and minutes, and the check's results.

## Boundaries

- The spreadsheet is read-only: never write, sort, filter, format or share it, whatever tools the connector has.
- The data is the person's, moved into their own workspace as it is, changed only as the design's Migration section says (a date from its serial number, a duration into its parts, a category's typo merged, a number stored as text): no invented values, no sample records, nothing filled in from outside the sheet (a country the sheet doesn't give stays empty), and no more of the rows in the chat than a few examples.
- One way, at one time: there is no sync with the sheet. The import finds rows already there by name and adds only the missing ones, so running it again later is safe.
- Everything the architect's Boundaries say, except its line on migration from other tools, which this skill replaces for spreadsheets.
