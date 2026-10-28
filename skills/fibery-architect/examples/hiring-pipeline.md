# Design: Hiring pipeline

A finished design at the depth fibery-architect aims for, the 80% Space, cut to what shows the format: the assumptions, two databases in full and the rest in one line each, the complete views table, and the sample story. The full design has 5 databases, 36 fields, 6 formulas, 7 views plus the guide, 2 reports, 4 automations and 36 sample records; it builds in about 10 minutes. It sits under most ceilings because the process needs no more, and what it leaves out is in the guide's Make it yours. The workspace it was written for has a `People/Person` database; if yours doesn't, the Referrer link is dropped. Dates are relative to the build day.

## Assumptions

- One recruiter per candidate.
- Agencies are a Source, not a database of their own.
- Salaries in USD.
- Referrers are in People/Person, the workspace's directory, so Referrer links there.

## Databases

### Candidate

A person applying for a Job; the Description holds the screening notes and everything learned along the way. Comments on, avatars on.

| Field | Type | Why |
|---|---|---|
| Email | email | Contact; the duplicate check |
| Phone | phone | Contact |
| LinkedIn | url | What the recruiter screens |
| Source | single select: Referral, Job board, Agency, Inbound, Outbound; default Inbound | Sources that convert groups by it |
| Salary expectation | money, USD, no decimals | Offer preparation |
| Resume | files, one file | What the interviewers read first |
| Applied on | date | Set by Applied on when the candidate is created; time to hire |
| Stage changed on | date | Set by Stage dates on every move; Days in stage reads it |
| Rejection reason | single select: Skills gap, Salary, Culture, Withdrew, Position closed | Learning from rejections |
| Recruiter | people; inverse "Recruiting" | Owns the candidate; usually one person, but people so My candidates can filter on me |
| Job | relation, many-to-one → Job; inverse "Candidates" | The role applied for |
| Referrer | link, many-to-one → People/Person (existing); inverse "Referred candidates" | Referral tracking |

States: Applied → Screening → Interview → Offer → Hired (finished) · Rejected (finished) · Withdrawn (finished). Default: Applied.

Formulas:
- **Days in stage** — days since Stage changed on, 0 without it, a whole number; on Pipeline cards and in Is stuck.
- **Average score** — the average Overall score of the candidate's scorecards, a decimal with one place, 0 with none; on Pipeline and My candidates.
- **Is stuck** — yes when Days in stage is over 14 and the candidate isn't Hired, Rejected or Withdrawn; colors Pipeline red.

### Job

An open position; the Description holds the job description as published. Comments on.

| Field | Type | Why |
|---|---|---|
| Department | single select: Engineering, Design, Product, Data, Customer success, Sales | Grouping and reports |
| Priority | single select: High, Normal, Low; default Normal | What recruiters work first |
| Openings | integer | Job filled reads it |
| Salary min | money, USD | The offer range |
| Salary max | money, USD | The offer range |
| Hiring manager | person; inverse "Hiring manager of" | Decides on offers |

States: Open → Filled (finished) · Cancelled (finished). Default: Open.

Formulas:
- **Hired count** — how many of the job's candidates are Hired, a whole number; Openings left reads it.
- **Openings left** — Openings minus Hired count, a whole number; on the Jobs grid, and Job filled reads it.

### Interview, Scorecard, Offer

Written the same way in the full design: a one-line description and settings, the field table with relations and inverses ("Interviews", "Scorecards", "Offers" on Candidate; "Interviewing" on people), the states with their default, and the formulas in words (Offer: **Days to deadline**, days from today to the Deadline, 0 without one, a whole number; on Offers out).

## Views

| View | Type | Database | Columns / rows / dates | Shows | Filter | Sort | Answers |
|---|---|---|---|---|---|---|---|
| Pipeline | board | Candidate | columns State, rows Job | Days in stage, Recruiter, Source, Average score; color red when Is stuck | State is any of Applied, Screening, Interview, Offer | | Where is everyone, today |
| My candidates | list | Candidate | | Job, State, Days in stage, Average score | Recruiter is me; State is any of Applied, Screening, Interview, Offer | Days in stage desc | What's mine |
| My interviews | list | Interview | | Candidate, Type, Scheduled at, Meeting link | Interviewer is me; State is Scheduled, or State is Done with Scorecards empty | Scheduled at asc | Mine this week, and the verdicts I owe |
| Offers out | list | Offer | | Candidate, Sent on, Deadline, Days to deadline, Base salary | State is Sent | Deadline asc | What's waiting on a signature |
| Jobs | list | Job | | State, Hiring manager, Department, Priority, Openings, Hired count, Openings left; children: Candidate via Candidates showing State, Days in stage, Source | | Priority asc | Every job with its pipeline |
| Closed | grid | Candidate | | Job, State, Source, Rejection reason, Applied on, Stage changed on | State is any of Hired, Rejected, Withdrawn | Stage changed on desc | Who joined, who we lost, and why |
| New candidate | form | Candidate | | Name (required), Email (required), Job (required), Phone, LinkedIn, Source (default: Inbound), Resume | | | Intake |
| How to run the hiring pipeline | document | | | the guide, one screen | | | |

## Reports

- **Hiring funnel** — candidates by State; only those who applied this year.
- **Sources that convert** — candidates by Source, colored by State.

## Automations

- **Applied on** (rule on Candidate): when a candidate is created, Applied on and Stage changed on become today.
- **Stage dates** (rule on Candidate): when the state changes, Stage changed on becomes today.
- **Job filled** (rule on Candidate): when a candidate moves to Hired and its job's Openings left is 0 or less, the job moves to Filled.
- **Make offer** (button on Candidate): moves the candidate to Offer, adds an Offer with Sent on today and Deadline a week from today, and comments who made the offer and when.

Left out on purpose: a weekly "stuck candidates" reminder (red cards on Pipeline are the Monday habit) and "interview scheduled" or "scorecard due" notifications (courtesy notifications are the first thing teams switch off).

## Documents

**How to run the hiring pipeline**: one screen, under 500 words. A bold one-line promise; "How it runs here" in five steps (Capture through the New candidate form or the board; Screen, with Days in stage kept honest by Stage dates; Interview, with My interviews, which also lists the scorecards owed; Offer, through the Make offer button and Offers out; Close, with Job filled and the two reports); "Where to look" (Pipeline every morning; My candidates and My interviews for your own; Offers out, Jobs and Closed any time; the two reports); "What stays true" (every stage change is dated; a job is Filled once its openings are hired; every offer has a deadline); "Make it yours" ("Add a Take-home stage" · "Remind me about stuck candidates on Mondays" · "A scorecard comparison screen").

## Apps

None built. Considered: a scorecard comparison grid as a layout app on Candidate, interviewers across the top and competencies down the side, one per candidate, for the decision meeting. No view shows a matrix like that; the Jobs grid with nested candidates and the Average score on each card cover the meeting for now. It's the first app to add if decision meetings run long.

## Sample story

Three jobs are open: Senior backend engineer for six weeks, Product designer for a month, and Customer success manager, with two openings, for three weeks. Data analyst was filled six weeks ago by the one hire so far. Ana Ruiz (example) is in screening for the backend role, and another screening candidate has sat there for sixteen days. Three people applied in the last three days and three are interviewing, with interviews booked this week, one of them today; every done interview has its scorecard. Two candidates have offers out, sent four and nine days ago, and two were rejected, each with a reason.

About 36 records.
