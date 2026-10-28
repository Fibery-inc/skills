# Example: Sport, from a Google Sheet

A migration at the depth this skill aims for, cut to what shows the format: the sheet map's tab table, the questions, the design's assumptions, two databases in full and the rest in a line each, the views, and the Migration section. The sheet is one person's sports results in 11 tabs; the Space came out with 7 databases, 29 formulas, 13 views plus the guide, 4 reports, 5 rules and 171 records, every formula value as in the sheet. It built in about 25 minutes.

## Sheet map, the tabs

| Tab | Kind | Rows | Becomes |
|---|---|---|---|
| Form Responses 1 (hidden) | form responses, empty | 0 | skipped; three Fibery forms take its place |
| Running | log | 16 | Run, through Track's Kind Road |
| Trail Running | log | 4 | Run, Kind Trail |
| Tower Running | log, a row per lap | 27 | Run, Kind Tower |
| Swimming Data | log | 24 | Swim |
| Swimming Dashboard | dashboard: Style × Distance × Course, `MIN(FILTER(…))` over Swimming Data; filter hides two styles and Short | 32 | Swim Event, its columns rollups; the Swimming Dashboard view |
| Swimming References | reference: rank standards, times as text ("1.14,50"), two turned into dates as typed | 19 | left in the sheet (answer) |
| Karting | log, headers in Russian | 13 | Kart Heat |
| Running Tracks | lookup: Track, Country | 9 | Track |
| Pool | log; Outcome colored Win, Loss, Draw | 34 | Match |
| Pool Pivot | two pivots over Pool | – | two report tables; rollups on Opponent |

Anomalies: "Breastroke" in both swimming tabs; a swim with no date; a kart heat with no kart and no time; times stored with hundredths the sheet doesn't show (a race shown 0:52:01 is 3,121.23 s).

## Questions

One line before them: "11 tabs: 6 logs of 118 rows, a lookup, a dashboard, a reference table, a pivot tab and an empty form tab."

1. **Running** — Running, Trail Running and Tower Running share most columns: one Runs database with a view per tab? *One Runs database (Recommended)* · Tower runs apart · Three databases. Answer: one.
2. **Tower laps** — a training day is several rows, one per lap: each lap a record, or a session holding its laps? *Each lap a record (Recommended)* · Session with laps. Answer: each lap.
3. **References** — the rank standards copied by hand into Next Milestone: a table to read, or standards on each swim event? *A table to read (Recommended)* · Standards on events. Answer, typed: "Do not move the References table at all."

## Design, cut

### Assumptions

- Space "Sport v3", as asked; the workspace treated as empty.
- One person logs and reads it: no people fields, no "My …" views, no comments.
- A run's kind is its track's: Kind lives on Track, and the tab views filter through the relation.
- Times are entered as Hours, Minutes and Seconds, Seconds with hundredths; Time and Pace show them rounded to the second, as the sheet did.
- "Breastroke" becomes Breaststroke; "Freestyle + P" the style Freestyle P. Karting's Russian headers are translated; its track names stay as written.
- Tower buildings and karting tracks have no country: the sheet gives none.

### Run

One road race, trail race or tower lap; its Track says which. Named from its track, lap and date. Color orange.

| Field | Type | Why |
|---|---|---|
| Track | relation, many-to-one → Track; inverse "Runs" | where; a tower's building |
| Date | date | |
| Distance | decimal, 2 places, km | Pace |
| Elevation Gain | integer, m | trail runs |
| Lap | integer | tower laps |
| Hours, Minutes | integer | the time |
| Seconds | decimal, 2 places | the time, with hundredths |
| Place, Out of | integer | tower races |
| Link, Tracking | url | results page; Strava |
| Notes | text | |

Formulas: **Total Seconds** (seconds first, `0.0`, a decimal); **Time** (h:mm:ss or m:ss, rounded); **Pace** (per km, m:ss; empty without a distance); **Top Percent** (Place × 100 / Out of, one place); **Kind** (the track's, as text, for the reports); **PB** (its track's best).

### Swim Event

A style, distance and pool you swim for time, like Freestyle 50 Long; Long is a 50 m pool, Short a 25 m pool. Named from its style, distance and course. No description. Color blue-purple.

| Field | Type | Why |
|---|---|---|
| Style | single select: Freestyle, Breaststroke, Butterfly, Backstroke, Freestyle P; default Freestyle | the dashboard's filter |
| Distance | integer, m | |
| Course | single select: Long, Short; default Long | |
| Next Milestone Min, Next Milestone Sec | integer; decimal, 2 places | the milestone set by hand |

Formulas: **Milestone Seconds**; **Next Milestone** (as m:ss.s); **PB Seconds**; **Personal Best** and **Pace 50 m** (the fastest swim's Time and Pace); **Milestone Pace**; **Improvement Needed** ((PB / milestone − 1) × 100, two places, 0 without either).

### Track, Swim, Kart Heat, Match, Opponent

Track: Kind (Road, Trail, Tower, Karting), Country; Best Seconds, Best Time, Best Lap. Swim: Swim Event, Date, Hours, Minutes, Seconds, Notes; Total Seconds, Time, Pace per 50 m, PB. Kart Heat: Track, Date, Kart, Heat, Lap Time (decimal, 3 places, s); PB. Match: Date, Discipline (Pool, Snooker), Opponent, My score, Opponent score; Total frames, Outcome. Opponent: Played, Wins, Losses, Win rate, Frames won, Frames lost.

### Views

| View | Type | Database | Shows | Filter | Sort |
|---|---|---|---|---|---|
| Running | grid | Run | Track, Date, Distance, Time, Pace, Notes, Link, Tracking; green when PB | Track's Kind is Road | Date |
| Trail Running | grid | Run | Track, Date, Distance, Elevation Gain, Time, Pace, Notes, Link, Tracking; green when PB | Kind is Trail | Date |
| Tower Running | grid | Run | Date, Track, Lap, Time, Place, Out of, Top Percent, Link, Notes; green when PB | Kind is Tower | Date, Lap |
| Swimming Data | grid | Swim | Date, Swim Event, Time, Pace, Notes; green when PB | | Date |
| Swimming Dashboard | grid | Swim Event | Style, Distance, Course, Personal Best, Pace 50 m, Next Milestone, Milestone Pace, Improvement Needed; green when beaten | Style is none of Backstroke, Butterfly; Course is none of Short | Style, Course, Distance |
| Karting | grid | Kart Heat | Date, Track, Kart, Heat, Lap Time; green when PB | | Date, Heat |
| Running Tracks | grid | Track | Country, Kind, Best Time | Kind is Road or Trail | |
| Pool | grid | Match | Date, Discipline, Opponent, My score, Opponent score, Total frames, Outcome; Win green, Loss red, Draw orange | | Date |
| Opponents | grid | Opponent | Played, Wins, Losses, Win rate, Frames won, Frames lost | | |
| Log a run, Log a swim, Log a match | form | Run, Swim, Match | the fields a row needs, the relation and date required, no Name | | |
| Sport calendar | calendar | Run, Swim, Kart Heat, Match | by Date | | |

Reports: **Pool Pivot** (a table: Opponent, then Loss, Win, Draw as `SUM(IF([Outcome] == 'Win', 1, 0))` columns and the total); **Pool Pivot: frames** (a table of the two sums by Opponent); **Running pace** (road runs' minutes per km over time, a line per track); **Pool form** (matches per month, stacked by Outcome).

Rules: one per database the person adds to, naming new records the way the import named the old ones ("Pool vs Max, 2026-01-04", "PKiN lap 3, 2025-05-14").

### Migration, cut

Run ← Running!A2:H17 (16), Trail Running!A2:I5 (4), Tower Running!A2:I28 (27):

| Field | From |
|---|---|
| Name | "<Track>, <date>"; towers "<Building> lap <Lap>, <date>" |
| Track | Track; Building |
| Date | Date, serial |
| Hours, Minutes, Seconds | Time, split from the day fraction |
| everything else | as is |

Formulas carried: Pace ← `=Time/Distance`; Top Percent ← `=IFERROR(Place/Out of,"")`, as 0 to 100.

| Sheet | Fibery |
|---|---|
| Three running tabs | One Run database; three views, each tab's columns in order |
| Swimming Dashboard and its filter | Swim Event and the Swimming Dashboard view; its `MIN(FILTER)` columns are rollups |
| Pool's colors | the Pool view's rows, the same colors |
| Pool Pivot | two report tables, and live on every Opponent |
| Swimming References | not moved (answer) |
| Times as `[h]:mm:ss` | three numbers and two formulas (Not carried: a duration field) |
| White text hiding zeros | Not carried: a number formula can't be blank |

## What the build showed

171 records in one 13-second import. Both Total Seconds came back whole numbers at first, since their `If`s started with `0`: the hundredths were gone and every Time empty, until they were made again seconds-first with `0.0`. The check then matched 7 counts, 6 totals and all 289 formula values with the sheet, and each rule's name expression matched every imported name. The dashboard view shows 15 rows to the sheet's 14, since Freestyle P 50 Long, an event only the data has, isn't hidden by its filter.
