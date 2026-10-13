# Designing from a recipe: the delta

The recipe may ship with the plugin or come as an attached file, a link or the prompt itself (SKILL.md §1 says how to get its text and where to save a supplied one); from here on the source makes no difference. Recipes are tool-neutral: they say what the process needs in words any tool can follow, and the build guide turns those words into Fibery. Its "Details for building" is the spec (databases, the Views table, the app, the reports, the sample story) and its story (The idea through What must stay true) is the guide document, adapted as the build guide §6 says. Its header is read too: `summary` is the card's first line, `for: solo` means one person runs it, so the sample story's people are `me` and nothing gets a "My …" view, and `for: community` means most members never open Fibery: they are records in a database, the organizers are the people fields, and members come in through a form. Don't rewrite either: every transcription is a chance to decide something the recipe already decided. The design is a one-page delta, and this file is all you need before the yes; the design guide is for designs from scratch.

## 1. Ask, then read the workspace

- **Ask every "Making it yours" question** (older recipes split it into "Before you set it up" and "Adapting") before designing, in one message, as a table with the defaults, and wait for the answers: the defaults are what a shrug gets, not a reason to skip the question. A short request ("set up Shape Up") is not "just build it"; only those words take the defaults, listed as assumptions on the card, and leave out a Making it yours bullet that has no default, which the card names as an option. A question the workspace already answers (an existing product database) is stated as answered, not asked.
- **Read the workspace**, reading only: `schema` for every Space and database, `schema_detailed` for the databases the recipe would link to, and `schema_detailed` for `fibery/user`. Four things come from the workspace, never from the recipe:
  - No new Space's name may exist yet. A recipe builds one Space, named after its title, unless its Who sees what line sets databases apart (some people must not open them, or several processes will share them): then each group gets a Space of its own, as the design guide §4 says. Older recipes name their Spaces in a Spaces line; keep those. If a name is taken, ask whether they meant that Space, or choose a free one ("Shape Up 2") and say so: the build addresses every database as `<Space>/<Database>`, and an existing name routes it into the existing Space.
  - Link targets are spelled exactly as `schema` shows them; a near miss lands the inverse field on the wrong database. Link to the workspace's system of record for a noun the recipe's questions ask about (products, customers, people as records) and create what is specific to the process; name each link's inverse the way that database's owners would, and keep the inverse free on the target. A database is the system of record only when it plainly serves the whole workspace or this team (a Customers or Products Space, a database other Spaces already link to); one inside another process's Space, or in another build of this recipe, is not. When unsure and the person said "just build it", don't link: create the database and list the link as an assumption on the card.
  - People-field names are workspace-wide: a `user/<name>` that exists already gets numbered ("Owned scopes 2"); note it in the delta.
  - The workspace's vocabulary (Customer or Account, Task or To-do) is a rename, applied everywhere.
- Space, database, field, state and option names use letters, digits and spaces only.

## 2. The delta

`design.md` is one page:

```markdown
# Delta: Shape Up for <team>

<the card, below>

**Spaces:** Shape Up
**Recipe:** recipe-writer/examples/shape-up.md

| Recipe asks | Answer | Effect |
|---|---|---|
| One product or several? | One (default) | No Product database |
| What do you call pitches, scopes and cycles? | Bets, Scopes, Cycles | Pitch → Bet everywhere, including the Bets view (renamed "Betting board") |

| Change | Why |
|---|---|
| Link Bet.Team members → People/Person (existing), inverse "Bets" | The team keeps its people in People/Person |
| Add a Priority select on Bet (High, Normal) | Asked for in the interview; shown on Betting board cards |
| Making it yours: small team | Five people: Betting table becomes a "Bets decided" date on Cycle, as the recipe's Making it yours says |

Everything not listed above is built exactly as the recipe's Details for building says.
```


- A recipe whose Who sees what line makes two or three Spaces keeps them, each listed with its databases; merging or splitting Spaces is a change in the table, with its reason.
- Apply renames everywhere the name occurs, including states, views, formulas and the story; one line in the delta per name.
- List in the Change table every translation that changes what the recipe says (below); a translation that changes nothing isn't listed. What Fibery MCP can't set goes on the card's By hand line (SKILL.md §4), never into a rule or a workaround.
- Add beyond the recipe only what the answers, the workspace or the interview require: a recipe is the 80% by design, and what it leaves out is the team's to add once it runs (its Making it yours says what). Remove only what an answer, a "Making it yours" bullet or a translation below removes.
- An answer, a rename, a removal or a "Making it yours" bullet applied changes everything that depends on it (views, formulas, rules, reports, the sample story, the guide), and never breaks a ★ promise of the recipe's What must stay true; the Change table lists what else changed and why.

### The card

Shorter than a design's (SKILL.md §4), since the person chose the recipe: its parts as counts, after the delta, then only what changes, one clause per answer or Change row. Outside the Space, By hand and the assumptions (every default taken) are as SKILL.md §4 says, and the yes is the same yes.

```
**Shape Up** — a new Space "Shape Up" in <workspace>, from the recipe Shape Up, for <team>.

From the recipe, with the changes below: 4 databases (Bet, Cycle, Scope, Task), 5 formulas, 8 views,
2 reports, 5 rules and buttons, the Hill chart app; about 35 sample records, all marked "(example)";
people are you.
Changes: Pitch → Bet everywhere; no Betting table, a "Bets decided" date on Cycle instead (small team);
Team members → People/Person (existing); a Priority select on Bet.
Outside the Space: adds "Shaped bets", "Owned scopes" and "Assigned tasks" to every person, and "Bets"
to People/Person. No automation writes to existing records.
By hand after the build: the Space icon.
Estimate: about 13 minutes after your yes, the app included.

Build it? Nothing is created until you say yes.
```

Its sample count is what the story's moments need, 25–40 in all (build guide §4), and the estimate for a recipe's Space is about 10 minutes after the yes, a few more with an app.

### Translations that change the recipe

The build guide turns each of the recipe's words into Fibery's calls, and most translations change nothing. These can, and when they do, each is a Change row or an assumption on the card:

- **A role with a "My …" view** is a people field even when one person holds it, since only people fields filter on me.
- **Money** is in the currency of the workspace's existing money fields, or the one the person names, or USD as an assumption.
- **A grouping Fibery can't do**, a board's rows by a text, a number or a date, becomes a select.
- **A whole-number formula** stays whole when it starts with its 0 case: a day count reads one date field and is 0 without it, with the rule that stamps the date also firing on creation; a share is 0 when there is nothing to count. Otherwise it comes back decimal, with its number format By hand.
- **A view that only adds a filter to another view** isn't built, since people filter; the daily view and "My …" views stay. Each dropped view is a Change row.
- **A custom view** is a custom app: a view app for a page of its own, a layout app for a tab on every record.
- **A rule or button** is native actions only (build guide §5): one that needs more (email, a comment on a linked record, a check before acting) is dropped and reported as not built, and the guide names the step as done by hand.
- **Who sees what** makes a Space per group it names, the first keeping the recipe's title; who may open each is By hand.
- **`for: community`** makes members records in a database and organizers people fields, with intake through a form shared outside the workspace By hand.

## 3. After the yes

The build reads the recipe's Details for building and the delta together; the delta wins wherever they differ. The guide document is the recipe's story, adapted as the build guide §6 says. Older recipes may still carry Building notes; read them before the build. An older recipe's sample story may be a table rather than a paragraph: read it as the story. Keep the report's For the recipe lines (SKILL.md §6) as you go: a Change row most teams would need, a part of the recipe that couldn't be built, a promise the sample data couldn't keep.
