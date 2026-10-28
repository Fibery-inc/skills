# Reading a spreadsheet

The aim is the sheet map: everything the person built in the sheet, on a page or two, with what each part will become. Everything here reads; nothing in the sheet is changed, sorted or filtered, whatever tools the connector offers.

## Contents

1. [Find it](#1-find-it)
2. [Fetch it](#2-fetch-it)
3. [What a cell means](#3-what-a-cell-means)
4. [Find the tables](#4-find-the-tables)
5. [What each tab is](#5-what-each-tab-is)
6. [The sheet map](#6-the-sheet-map)

## 1. Find it

| The person gives | Do this |
|---|---|
| A link, `docs.google.com/spreadsheets/d/<id>/…` | The id is what follows `/d/`, up to the next `/`. |
| A name | Drive's `search_files` with `title contains '<a word or two>' and mimeType = 'application/vnd.google-apps.spreadsheet'`. One match is it; several go into the questions, by title and last change, unless one is plainly the one they mean. |
| An `.xlsx`, `.xls`, `.ods` or `.csv` file, in Drive or attached, or a Microsoft 365 workbook | Not supported in this version. Say so, and that in Google Drive "Open with → Google Sheets" makes a Google Sheet of it, formulas included; then read that copy. |

## 2. Fetch it

Three calls for any sheet, then pages for a big tab.

1. **Structure**: `get_spreadsheet` with `fields` `["properties(title,locale,timeZone)", "sheets(properties,tables,basicFilter,filterViews,conditionalFormats,merges,charts,protectedRanges,slicers)", "namedRanges"]`. It lists every tab with its grid size, which are hidden, the tables Sheets knows (with column types and dropdown options), each tab's filter and saved filter views, the color rules with their ranges, merged cells, charts (type, series, ranges) and protected ranges. No cells.
2. **What people see**: `get_values` per tab, `'<Tab>'!A1:<last column><last row>` from the grid size: the displayed text, the quickest way to see where the tables are and what they hold.
3. **What is stored**: `get_spreadsheet` with `includeGridData: true`, `ranges` the tables found in step 2, and `fields` `["sheets(properties.title,data(startRow,startColumn,rowData.values(userEnteredValue,effectiveValue,formattedValue,userEnteredFormat.numberFormat,dataValidation,pivotTable,note,hyperlink,chipRuns),rowMetadata.hiddenByUser,rowMetadata.hiddenByFilter,columnMetadata.hiddenByUser))"]`. This is what the import reads: each cell's stored value and its type, its number format, its formula (`userEnteredValue.formulaValue`) next to the formula's result (`effectiveValue`), the pivot tables (anchored at their top-left cell, with their source range, rows, columns, values and filters), notes, links and chips. An empty cell comes back as `{}`, and a row's values stop at its last filled cell.

A tab with more than about 2,000 rows: call 3 for the header and the first 100 rows, enough to type every column, then the rest in pages of about 2,000 rows asking only for `effectiveValue`, with `userEnteredValue` for the computed columns. `references/migration.md` §4 says how a big tab is imported.

## 3. What a cell means

Read the stored value and its type, never only the displayed text: a column shows dates in three formats and holds one kind of date.

| The cell | Means |
|---|---|
| A number with a `DATE` format, whatever its pattern | A date: the number counts days from 1899-12-30. "2/26/2016", "22.06.2019" and "2026-03-29" in one column are one date column. |
| A number with a `DATE_TIME` format | A date-time in the sheet's time zone (`properties.timeZone`); the import converts it to UTC. |
| A number with a `TIME` format and an `[h]` or `[m]` pattern, or a column of results and lengths (times, laps, durations) | A duration: the number is a fraction of a day, so seconds are the number × 86,400 (0.019456 is 1,681 s, 28:01). Keep the stored precision: a pattern without decimals rounds what it shows, and a race shown as 0:52:01 was stored as 3,121.23 s (measured), which decides a personal best. |
| A number with a `TIME` format that reads as a time of day (9:30 AM) | A time of day. Fibery has none: joined with the row's date into a date-time, or text when there is no date. |
| A number with `PERCENT` | A share, stored as a fraction (0.18 shows as 18%). |
| A number with `CURRENCY`, or a pattern with a currency sign | Money in that currency. |
| Any other number | An integer when every value is whole, otherwise a decimal with the places its pattern shows. |
| `TRUE` / `FALSE`, or a checkbox | A checkbox. |
| Text that holds a number, a date or a duration ("32.50", "1.14,50" for 1:14.50, "2/26/2016" typed as text) | Parse it, by the sheet's `locale` and by what the column's other values are; each rule goes into the map. |
| A date in a column of numbers or durations ("06.09.00" shown, September 6, 2000 stored, among "6.02,00" and "6.37,50") | Text Sheets turned into a date as it was typed. Read `formattedValue`, the text the person typed, and parse it like its neighbours. |
| "-", "—", "n/a", "N/A", "?", "TBD" | Empty. |
| A merged cell over several rows (a group label down column A) | Its value belongs to every row of the merge. |
| A `hyperlink`, or `=HYPERLINK(url, label)` | A url. When the label isn't the url, the label is a name or text of its own. |
| A `note` | Text that belongs to the record of its row: added to its notes field, or a comment. Comments on cells (the discussion threads) aren't in the API and stay behind. |
| A chip: a person, a file, a place | A person's email (a people field when they're a Fibery user, text otherwise); a url; a location. |
| `dataValidation`: a list of values or a range | A single select with those options in that order, colored like the dropdown's chips; a checkbox rule is a checkbox, a date rule a date. A number range or a custom rule is a check Fibery doesn't make: the field's type, and a line in Not carried. |
| A formula | Its text is the logic and its result the value to check against. The import never writes a computed column; the formula recomputes it (`references/model.md` §3). |

A column whose values disagree (mostly numbers, a few texts) takes the type of the many, and each exception is an anomaly in the map: imported as parsed, or empty with its row named.

## 4. Find the tables

A table is a header row and the rows beneath it. Most tabs hold one, starting at A1. When they don't:

- **The header** is the first row of short labels with values under them; a title, a date or notes above it are not part of the table. Two header rows, a group label merged above its columns ("Q1" over Plan and Actual), become one name per column ("Q1 plan").
- **The table ends** at its last row with values in its key columns. Blank rows inside it are skipped, not an end: a log often has gaps.
- **Several tables on a tab**, side by side or one under the other with blank rows or columns between them, are read one by one, each with its own header.
- **Rows that aren't records**: a total or average under the table or between groups (Grand Total, Sum, a row of `=SUM(…)` over the column above), a section label alone in the first column ("January", "Team A", whose value belongs to the rows beneath it as a field), a repeated header. They become report numbers, a grid's totals and fields, never records.
- **Scattered cells** outside any table (a note in a corner, a lone number, a legend, a calculation tried once): skipped, each listed in the map with its address and what it was. Two kinds aren't lost: a value a formula reads (a target, a rate, a threshold) is a constant in that formula, or a field on the parent record when people change it; an explanation of the tab goes into the database's description or the guide.
- **Hidden rows and columns**: read them. A column people hid is left out of the tab's view but still imported when it holds data; a helper column that only feeds formulas (a key such as `=A2&B2`) is neither.

## 5. What each tab is

Hidden tabs too: a lookup is often hidden, and hidden isn't abandoned.

| Kind | How it looks | Becomes |
|---|---|---|
| **Log** | A header and rows of facts, one per thing or event, growing at the bottom | A database, alone or with the other tabs of its kind (`references/model.md` §1) |
| **Lookup** | A short list of names with attributes; other tabs repeat those names | The database of that noun, its columns its fields; a select when there are no attributes |
| **Dashboard** | Rows of categories or combinations with formulas over other tabs (`FILTER`, `SUMIF`, `COUNTIF`, `MIN`, `MAX`, `QUERY`, `VLOOKUP`) | A database of those combinations with rollups, when its rows are things people would open (an event, a product, a person); otherwise reports. Either way, a view with its columns |
| **Pivot** | A `pivotTable` at a cell | A report with a table (`references/model.md` §4) |
| **Chart** | A chart in `sheets.charts` | A report with that chart, or a view (`references/model.md` §4) |
| **Reference** | A static table no formula reads: standards, rates, a price list, a checklist | A document with the table, read as before; or fields on the records it describes, when it holds one value per record and the person wants it used (a question) |
| **Form responses** | "Form Responses 1": Timestamp first, the form's questions after | The database of the responses, with a Fibery form in place of the Google Form. An empty one is an abandoned form: skipped, and its questions listed |
| **Notes, scratch, copies, empty** | No table; a tab of notes; a copy of another tab ("Sheet1 (old)", compared before skipping) | Skipped, listed. Notes the team still needs go into a document |

## 6. The sheet map

Write `sheet-map.md` in the working folder: a header, a section per tab, then what's skipped and what's odd. It records shape, not data: a few example values where they help, never whole columns.

```markdown
# Sheet map: Sport (copy)

Google Sheet 1FdbEEgc…, en_US, Europe/Minsk; 11 tabs (1 hidden): 6 logs of 118 rows, a lookup, a dashboard, a reference table, a pivot tab and an empty form tab; read 2026-10-28.

## Pool: log, A1:G35, 34 rows → Match

| Column | Type | Notes |
|---|---|---|
| Date | date | all filled, 2025-09-18 to 2026-08-07 |
| Discipline | text, 2 values: Pool 32, Snooker 2 | select |
| Opponent | text, 2 values: Max 31, Sergey 3 | Opponent records: the pivot is by opponent |
| My score, Opponent score | integer | |
| Total frames | formula `=D2+E2` | formula |
| Outcome | formula `=IF(D2>E2,"Win",IF(D2<E2,"Loss","Draw"))` | formula; colored Win green, Loss red, Draw yellow |

## Pool Pivot: two pivots over Pool → reports
- A1: count of Date by Opponent (rows) and Outcome (columns), with totals.
- A20: sum of My score and of Opponent score by Opponent.
Both include a blank Opponent from Pool's empty rows: left out.

## Skipped
- Form Responses 1 (hidden): an empty form table, Timestamp and "Untitled Question".

## Anomalies
- Swimming Data, Style: "Breastroke" 7 times, the dashboard spells it the same way; the select says Breaststroke.
- Swimming References D5 and D13: times Sheets turned into dates as typed ("06.09.00" stored as 2000-09-06); read as 6:09.00 and 3:05.00.
```

Per column: its header, its type as section 3 reads it, how many cells are empty, for text the distinct values with counts when they repeat (a column with few distinct values among many rows is a select or a database, `references/model.md` §1), for numbers and dates the range, the formula when it's computed (one line, with the column's cells written as its header names: "Pace = Time / Distance"), and what it becomes. Per tab: its kind, range, rows kept and skipped, its filter and filter views, sort, color rules, hidden columns, pivots and charts, and what it becomes.
