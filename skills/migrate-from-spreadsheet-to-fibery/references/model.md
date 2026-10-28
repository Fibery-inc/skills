# From the sheet map to the design

The architect's design guide decides how a Space is designed, written and sized; this file adds what a spreadsheet changes. The sheet is the person's own design, done in a tool that can't link, compute across tabs or take input well, so you keep what it says and undo only its workarounds: a tab per year, a name typed again on every row, a dashboard of `FILTER` formulas, a color that stands for a rule.

## Contents

1. [Databases: undo the workarounds](#1-databases-undo-the-workarounds)
2. [Fields and names](#2-fields-and-names)
3. [Formulas](#3-formulas)
4. [Views, reports and colors](#4-views-reports-and-colors)
5. [Better than the sheet](#5-better-than-the-sheet)
6. [The Migration section of design.md](#6-the-migration-section-of-designmd)

## 1. Databases: undo the workarounds

The architect's noun test (design guide §4) decides what is a database; in a sheet, the nouns hide in these places.

| In the sheet | Becomes |
|---|---|
| **Tabs of one kind** (Running and Trail Running; a tab per year, month, region, client or person) | One database. What told the tabs apart becomes a field (a select, or a date already there), or a field of a linked record when it belongs to it (a race is Trail because its track is). Each tab gets a view of its own, named after it and filtered to it. A column only one tab has is a field the other rows leave empty. Columns that match only in part are a question. |
| **A tab per stage** (To do, Doing, Done; Applicants, Hired), rows moved between tabs by hand | One database with a workflow, its states the tabs in order. |
| **A text column whose values repeat** | A database when the name has a life of its own: attributes (a lookup tab, or columns that repeat with it, such as a track's country), its own rows to look at (an opponent's matches, a track's results), or names shared by several tabs. A single select when it's a short, stable list that only labels (Style, Course, Discipline), up to about 20 values. Text when values rarely repeat. |
| **A lookup tab** (Running Tracks: Track, Country) | The database of that noun, its columns its fields. Names the logs use and the lookup lacks are created with the name only, and listed. |
| **A dashboard of combinations** (Style × Distance × Course, each row a `MIN(FILTER(…))` over the log) | A database whose records are the combinations, linked from the log's rows: the `FILTER`'s match columns become that relation, and the dashboard's columns become rollups that update themselves. Combinations the log uses and the dashboard lacks are created; ones the dashboard has with no rows are kept, since they're targets. A dashboard whose rows are only groupings (months, categories) is reports instead. |
| **Repeating columns** (Jan, Feb, Mar; Lap 1, Lap 2; Q1 score, Q2 score) | Rows of a child database, one per column, unless there are at most three fixed ones. |
| **Cells holding several values** ("Design, Sales") | A multi select, or a to-many relation when the values are records. |
| **Repeated rows that belong together** (laps of one session, items of one order) | Rows of their own database, with a parent only when the parent has fields of its own beyond the repeated columns; otherwise the repeated columns stay on each row. Unclear is a question. |
| **A reference table** no formula reads (standards, rates, a checklist) | A document holding the table, read as before; fields on the records it describes only when the person wants the values used, which is a question. |

The architect's ceiling of seven databases holds: more tabs than that usually means tabs of one kind that weren't merged.

## 2. Fields and names

Each column's type comes from its cells (`references/reading.md` §3) and the architect's type table (design guide §4); a sheet adds these cases.

- **The Name.** A table's name column is the one people tell rows apart by, usually the first text column (Track, Client, Task), and it becomes the Name. A log of events (a run, a match, a payment) has none: its Name is composed from the row's own columns the way people would say it, with what the record is first and the date in ISO form last, unique within the database: "Pool vs Max, 2026-01-04"; "PKiN lap 3, 2025-05-14". The design writes the composition once; the import writes it into every record, and a rule keeps it for new records (§5).
- **Durations.** Fibery has no duration field, and its formulas can't turn text into a number, so a time typed as "52:01" can't be computed. A duration column becomes number fields for its parts as people say them: Hours, Minutes and Seconds for anything that can pass an hour; Minutes and Seconds for shorter ones; a single decimal in seconds, with its places, for laps and sprints. Seconds is a decimal with two places, since sheets store hundredths they don't show. Two formulas sit on them: the total in seconds, which sorts, compares and charts, and the time as text, `h:mm:ss` from an hour and `m:ss` below, rounded to the second as the sheet showed it, which takes the column's place in views (§3 has both). The parts are on the record and the form. The import splits each value into its parts.
- **A header with a unit** ("Distance (m)", "Elevation Gain") is a number with that unit (architect build guide §1), named without it.
- **A header with characters a Fibery name can't hold** ("%", "Pace (50 m)", "Заезд (в день)"): the nearest words that can ("Top Percent", "Pace 50 m", "Heat"). A header in another language than the rest of the sheet is translated into the sheet's main language; values aren't.
- **Case.** Headers and tab names are names people gave, so they're kept as written: "My score" stays "My score" in a sheet that writes "Personal Best" elsewhere. New names (a database, a rollup, a field for a split duration) follow the case of the headers nearest them, the tab they extend, and otherwise the architect's SKILL.md §2.
- **Urls** are url fields, one per column. A url inside a text cell stays in the text.
- **Notes** are a text field when cells are a line or two; the Description when they run long or carry formatting.
- **A column of a few repeating values** is a single select with the values found, typos merged ("Breastroke" into Breaststroke) and listed, in their natural order or else by how often they occur; a dropdown's options keep its order and chip colors.
- **A select's default** is the value most rows have, when nearly all do (Discipline: Pool).

## 3. Formulas

**Raw data first, then formulas.** The import writes the columns people typed; a computed column is never imported as values. Its formula is created after the records exist and checked against the results the sheet stored (`references/migration.md` §3). A column of values typed by hand that look computed (a milestone copied from a reference table) is data: a field.

**One formula per computed column**, its expression translated from the sheet's, the cells of its row becoming its database's fields (`=D2/C2` becomes `[Total Seconds] / Distance`). A column whose formula changes down the rows, or with some cells typed over, takes the formula most rows have; the rows that differ are named by the check. A formula that reads another tab becomes a relation plus a formula that reads through it.

| Google Sheets | Fibery |
|---|---|
| `+ - * /`, `=D2+E2` | the same, on fields: `[My score] + [Opponent score]` |
| `IF`, `IFS`, `SWITCH` | `If(c, a, b)`, nested in the else |
| `IFERROR(x, y)`, `IFNA` | Fibery has no error values: test the cause, `If(IsEmpty([Out of]) or [Out of] = 0, 0.0, Place / [Out of])` |
| `ISBLANK(x)`, `x = ""` | `IsEmpty(x)` |
| `AND`, `OR`, `NOT` | `and`, `or`, `not` |
| `ROUND`, `ROUNDUP`, `ROUNDDOWN`, `INT`, `ABS`, `POWER`, `SQRT`, `LOG` | `Round`, `RoundUp`, `RoundDown`, `RoundDown(x, 0)`, `AbsoluteValue`, `Power`, `Power(x, 0.5)`, `Log` |
| `MIN(a, b)`, `MAX(a, b)` of values | `Least`, `Greatest` |
| `&`, `CONCATENATE`; `TEXTJOIN` over rows | `+`; `Join(Name, ", ")` over a collection |
| `LEFT`, `RIGHT`, `MID`, `LEN`, `UPPER`, `LOWER`, `TRIM`, `SUBSTITUTE`, `FIND`, `REGEXMATCH`, `REGEXREPLACE` | `Left`, `Right`, `Middle`, `Length`, `Upper`, `Lower`, `Trim`, `Replace`, `Find`, `MatchRegex`, `ReplaceRegex` |
| `TEXT(x, pattern)` | `ToText(x)` has no patterns: round first, pad with `Right("0" + …, 2)`, build dates from `Year`, `Month`, `Day`, `MonthName` |
| `VALUE`, `DATEVALUE`, `TIMEVALUE`, `SPLIT` into numbers | None: Fibery can't read a number from text, so the import stores the number |
| `TODAY()`; `NOW()` | `Today()`; `Now()` exists only in automations |
| `YEAR`, `MONTH`, `DAY`, `WEEKDAY`, `ISOWEEKNUM` | `Year`, `Month`, `Day`, `IsoWeekday`, `IsoWeekNum` |
| `DATEDIF(a, b, "D")`, `b - a` | `ToDays(b - a)` |
| `EDATE`, `EOMONTH`, `NETWORKDAYS`, `WORKDAY` | None (months can't be added to a date yet; no working days): Not carried, or a date field people set |
| `VLOOKUP`, `XLOOKUP`, `INDEX(MATCH)` into another tab by a key | A relation on the key, and the value read through it: `Track.Country` |
| `SUMIF(S)`, `COUNTIF(S)`, `AVERAGEIF(S)`, `MINIFS`, `MAXIFS`, `FILTER` then `MIN`/`MAX`/`SUM`, over another tab by this row's values | A relation from this record to those rows, and `Runs.Filter(…).Sum([…])`, `.Count()`, `.Avg(…)`, `.Min(…)`, `.Max(…)`; the record that holds the minimum, `Runs.Sort([Total Seconds]).First()` |
| `SUM(C:C)`, `AVERAGE(C:C)` over a whole column | Not a formula: a report's number, or a grid's totals row (set by hand, Your turn) |
| `RANK`, running totals (`SUM($C$2:C2)`), the row above (`C3-C2`), `ROW()`, `OFFSET`, `INDIRECT` | Records have no order in Fibery: a report's `RUNNING_SUM` or `DIFFERENCE`, or Not carried |
| `ARRAYFORMULA(…)` | The formula inside it, on every record |
| `QUERY(…)` | A view (its filter, sort and columns) or a report (its grouping) |
| `HYPERLINK`, `IMAGE`, `SPARKLINE` | A url field; a files field and a gallery; a report's line chart |
| `IMPORTRANGE`, `GOOGLEFINANCE`, `IMPORTXML`, `IMPORTHTML` | A link to the database the other sheet became, when it was migrated too; otherwise Not carried, since formulas don't fetch |
| Durations, fractions of a day | Seconds: `[Total Seconds] / Distance`, then shown as text by the pattern below |

**Durations, in formulas.** These passed the check on 289 of 289 values against a sheet (measured):

- The total in seconds puts the seconds first, with `0.0`: `If(IsEmpty(Seconds), 0.0, Seconds) + If(IsEmpty(Minutes), 0, Minutes) * 60 + If(IsEmpty(Hours), 0, Hours) * 3600`. Written with `0`, each `If` takes the type of its 0 (architect build guide §2), so the sum comes back a whole number, the hundredths are rounded away, and Fibery's writer turns every `Round` over it into `Round(x * 1, 0)`, which evaluates to nothing: every time showed empty (measured). A wrong type is fixed by deleting the total and the formulas that read it, and creating them again.
- The time as text, `h:mm:ss` from an hour and `m:ss` below, rounded to the second (about 600 characters, accepted):

  ```
  If([Total Seconds] = 0, "", If(Round([Total Seconds], 0) >= 3600, ReplaceRegex(ToText(RoundDown(Round([Total Seconds], 0) / 3600, 0)), "[.]0+$", "") + ":" + Right("0" + ReplaceRegex(ToText(RoundDown(Round([Total Seconds], 0) / 60, 0) - RoundDown(Round([Total Seconds], 0) / 3600, 0) * 60), "[.]0+$", ""), 2), ReplaceRegex(ToText(RoundDown(Round([Total Seconds], 0) / 60, 0)), "[.]0+$", "")) + ":" + Right("0" + ReplaceRegex(ToText(Round([Total Seconds], 0) - RoundDown(Round([Total Seconds], 0) / 60, 0) * 60), "[.]0+$", ""), 2))
  ```

- A pace or any other `m:ss`, for `x` the seconds (`Round([Total Seconds] / Distance, 0)` per km; `Round([Total Seconds] * 50 / [Swim Event].Distance, 0)` per 50 m), empty without a distance:

  ```
  ReplaceRegex(ToText(RoundDown(x / 60, 0)), "[.]0+$", "") + ":" + Right("0" + ReplaceRegex(ToText(x - RoundDown(x / 60, 0) * 60), "[.]0+$", ""), 2)
  ```

- The best of a parent's records and its text: `If(Runs.Filter([Total Seconds] > 0).Count() = 0, 0.0, Runs.Filter([Total Seconds] > 0).Min([Total Seconds]))` and `Runs.Filter([Total Seconds] > 0).Sort([Total Seconds]).First().Time`; a personal best flag is `[Total Seconds] > 0 and [Total Seconds] = Track.[Best Seconds]`.

`ToText` of a rounded decimal ends in ".0", which the `ReplaceRegex` drops; `x` is written out each time, since a formula has no variables. Every formula is written as the architect's build guide §2 says, with "Use exactly this Fibery formula" for each of these. A text formula can be empty, a number can't: an event with no swims shows an empty Personal Best but 0 for its Improvement Needed.

## 4. Views, reports and colors

**Every tab people used becomes a view** with its name, its columns in its order (the Name first, as Fibery puts it), its sort (none when the rows are in the order people typed them, so the view keeps it), its filter, and its hidden columns left out. A saved filter view is a view of its own. A log tab is a grid with short rows; a dashboard tab, a grid of its database. These views are parity: they don't count against the architect's ceiling of eight, and they come first in the Space after the guide, in the tabs' order. When tabs became one database, each tab's view filters by what told them apart, through the relation when it belongs to a linked record: `{nodeType: "single-select", args: {fieldPath: ["Sport/Track", "Sport/Kind"], operator: "is-any-of", value: [<Track's Kind option id>]}}` shows the runs whose track is Trail (measured). A report can't reach through a relation, so the same split in a report needs a text formula on the record (`Track.Kind.Name`).

**Pivots** become a report each, with one table: the pivot's rows are its first columns, its values aggregate columns (`SUM([My score])`, `COUNT([Id])`, `AVG`, `MIN`, `MAX`), its filter the table's `fieldConditions`. A table can't spread a dimension across columns, so a pivot's column dimension becomes one aggregate column per value, `SUM(IF([Outcome] == 'Win', 1, 0))` titled "Win", with `COUNT([Id])` as the total. When the pivot's rows are a noun with its own database (opponents, clients), its numbers also become rollups on that database, always up to date on every record.

**Charts** become a report each:

| Sheets chart | Fibery |
|---|---|
| Line; column or bar; area; scatter | `line`; `bar`, or `stacked-bar` when stacked (a horizontal bar puts the count on `x`); `area`, `stacked-area`; `scatterplot` |
| Bubble | `scatterplot` with a `size` |
| Pie, donut | A `bar` of the same counts: Fibery MCP draws no pie |
| Histogram | A `bar` over `BINS([x], n)` |
| Combo | Its main series as one chart; the other series a second report, or Not carried |
| Scorecard | A metric report |
| Table chart | A report table |
| Geo | A map view, when the rows have a location field |
| Timeline | A timeline view |
| Gauge, treemap, waterfall, candlestick, org | The nearest report, or Not carried |

**Color rules** become colors: a rule on a value ("Win" green) colors the select option, or the view's rows by a `colorCoding` rule with the nearest palette color; a threshold on a number, a `colorCoding` rule on that number; a custom formula rule, a true-or-false formula and a rule on it. A color scale is Not carried (a report table's `cellBar` is the nearest), and so is white text that hides zeros, since a formula can't be blank. Banding, fonts, widths and frozen rows aren't carried and aren't listed one by one: one line in Not carried says formatting stayed behind.

**The rest:** a protected range is Space access (Your turn); a Google Form feeding a tab becomes a Fibery form with its questions (sharing it is Your turn); Apps Script, macros and triggers become rules where native actions can do the job (architect build guide §5), and otherwise Not carried.

## 5. Better than the sheet

Within the architect's ceilings, for the person who adds rows and reads them every day; each addition has a reason in the design.

- **A form for each kind of row people add often**, so logging takes a phone and a minute: the fields a row needs, in the order people know them, pickers for relations and selects, the parts of a duration, the most common value as a select's default, required where the sheet never has a blank; computed columns stay off, and so does the Name when a rule writes it (Fibery doesn't add it to the form, measured).
- **Names that keep themselves**: a rule per log database that sets the Name from its columns, as §2 composes it, when a record is created or one of those columns changes: triggers `created` and `updated` on those fields, one Update action whose Name value is a formula prompt "Use exactly this Fibery formula: …". Fibery can name records with a formula, but Fibery MCP can't set one; the rule does the same job. `ToText` writes a date as YYYY-MM-DD and a whole number without decimals (measured), so the import composes names the same way, and the check proves the two agree before the rules exist (`references/migration.md` §3).
- **Pickers instead of retyping**: relations where the sheet repeated a name, with the lookup's values read through them.
- **Summaries that keep themselves**: rollups on the records a dashboard or pivot summarized (an opponent's wins, a track's best time), shown on every view of them.
- **Flags for what matters**, as rows colored by a rule: a personal best, a late row, an outlier the sheet's color rules or the person's notes point at.
- **New pictures of the same data**: a calendar of everything dated, all logs on one; a chart of the number people track over time (a pace, a score, a balance) where the sheet had none; a board when rows move through stages.

What the sheet did and Fibery can't, and what stands in for it, goes into the Parity table and the report's Not carried, never into a workaround that costs the person more than the gap.

## 6. The Migration section of design.md

The design follows the architect's design guide §4, with the data in place of the Sample story, and closes with this section, which the import, the check and the report all read:

```markdown
## Migration

Source: Google Sheet "Sport (copy)", 1FdbEEgc…, read 2026-10-28 14:10 (Europe/Minsk).

### Match ← Pool!A1:G35, 34 rows

| Field | From | How |
|---|---|---|
| Name | Discipline, Opponent, Date | "Pool vs Max, 2026-01-04" |
| Date | Date | serial date |
| Discipline | Discipline | option by name |
| Opponent | Opponent | Opponent by name |
| My score, Opponent score | My score, Opponent score | as is |

Formulas: Total frames = `[My score] + [Opponent score]` (sheet `=D2+E2`); Outcome = `If([My score] > [Opponent score], "Win", If([My score] < [Opponent score], "Loss", "Draw"))` (sheet `=IF(D2>E2,"Win",IF(D2<E2,"Loss","Draw"))`).

### Parity

| Sheet | Fibery |
|---|---|
| Pool tab | Pool view, same columns |
| Outcome colors | Pool view rows: Win green, Loss red, Draw orange |
| Pool Pivot, A1 | Pool Pivot report: Opponent, Loss, Win, Total; also Wins and Losses on every Opponent |
| Swimming Dashboard, zeros hidden in white | Not carried: a formula can't be blank; events with no swims show 0 |
```

Every database gets its source and field table; a database made from no tab (a lookup created from repeated names) says where its records come from ("the Track column of Running, Trail Running and Tower Running"). The Parity table lists every tab, pivot, chart, filter, color rule and formula column of the sheet map, once.
