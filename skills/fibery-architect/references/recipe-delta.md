# Designing from a recipe: the delta

The recipe may come from the cookbook or as an attached file, a link or the prompt itself (SKILL.md §1 says how to get its text and where to save it); from here on the source makes no difference. Recipes are tool-neutral: they say what the process needs in words any tool can follow, and the build guide turns those words into Fibery. Its "Details for building" is the spec (databases, the Views table, the app, the reports, the sample story), and its story (the promise through Making it yours) is what the one-screen guide is written from at build time, as the build guide §6 says. Its header is read too: `summary` opens the Space's description, `for: solo` means one person runs it, so the sample story's people are `me` and nothing gets a "My …" view, and `for: community` means most members never open Fibery: they are records in a database, the organizers are the people fields, and members come in through a form. Don't rewrite the spec: every transcription is a chance to decide something the recipe already decided. The design is a one-page delta, and this file is all you need before the build; the design guide is for designs from scratch.

## 1. Read the workspace, then ask

- **Read the workspace** before asking anything, reading only, alongside fetching the recipe: `schema` for every Space and database, `schema_detailed` for the databases the recipe would link to, and `schema_detailed` for `fibery/user`. Four things come from the workspace, never from the recipe:
  - No new Space's name may exist yet. A recipe builds one Space, named after its title, unless its Who sees what line sets databases apart (some people must not open them, or several processes will share them): then each group gets a Space of its own, as the design guide §4 says. Older recipes name their Spaces in a Spaces line; keep those. If a name is taken, ask with the questions whether they meant that Space; the default is the first free "<name> 2", "<name> 3". The build addresses every database as `<Space>/<Database>`, and an existing name routes it into the existing Space.
  - Link targets are spelled exactly as `schema` shows them; a near miss lands the inverse field on the wrong database. Link to the workspace's system of record for a noun the recipe's questions ask about (products, customers, people as records) and create what is specific to the process; name each link's inverse the way that database's owners would, and keep the inverse free on the target. A database is the system of record only when it plainly serves the whole workspace or this team (a Customers or Products Space, a database other Spaces already link to); one inside another process's Space, or in another build of this recipe, is not. When unsure, ask with the questions; the default is to create the database, not link.
  - People-field names are workspace-wide: a `user/<name>` that exists already gets numbered ("Owned scopes 2"); note it in the delta.
  - The workspace's vocabulary (Customer or Account, Task or To-do) is a rename, applied everywhere.
- Space, database, field, state and option names use letters, digits and spaces only.
- **Ask every "Making it yours" question** (older recipes split it into "Before you set it up" and "Adapting") in one message, as a table with the defaults, with a row for each thing the workspace left open, and wait for the answers: the defaults are what a shrug gets, not a reason to skip the question. A question the workspace already answers (an existing product database) is stated as answered, not asked. A short request ("set up Shape Up") is not "just build it"; only those words take the defaults, and leave out a Making it yours bullet that has no default, which the report names as an option. SKILL.md §3 says how the message ends, and that the delta and the build follow the answers with no other stop.

## 2. The delta

`design.md` is one page:

```markdown
# Delta: Shape Up for <team>

**Spaces:** Shape Up
**Recipe:** recipe.md (Shape Up, version 2, from the cookbook)

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
- Apply renames everywhere the name occurs, including states, views, formulas and the guide; one line in the delta per name.
- List in the Change table every translation that changes what the recipe says (below); a translation that changes nothing isn't listed. What Fibery MCP can't set goes on the report's By hand list (SKILL.md §6), never into a rule or a workaround.
- Add beyond the recipe only what the answers, the workspace or the interview require: a recipe is the 80% by design, and what it leaves out is the team's to add once it runs (its Making it yours says what). Remove only what an answer, a "Making it yours" bullet or a translation below removes.
- An answer, a rename, a removal or a "Making it yours" bullet applied changes everything that depends on it (views, formulas, rules, reports, the sample story, the guide), and never breaks a ★ promise of the recipe's What must stay true; the Change table lists what else changed and why.
- An answer left to its default says "(default)". Those answers, and the Change rows that guess for the person (a currency, a link made or not), are the report's Assumptions.

### Translations that change the recipe

The build guide turns each of the recipe's words into Fibery's calls, and most translations change nothing. These can, and when they do, each is a Change row:

- **A role with a "My …" view** is a people field even when one person holds it, since only people fields filter on me. Walk the recipe's Views table for every "My …" view before writing the delta: script 1 makes the field, and its cardinality can't change afterwards without recreating it.
- **Money** is in the currency of the workspace's existing money fields, or the one the person names, or USD as an assumption.
- **A report that keeps only some linked records** (only key results whose objective is Active, only runs of strats that aren't Retired) gets a true-or-false formula on its source, built with the other formulas, since a report filters on its source's own fields.
- **A view that shows a linked record's field** (the customer's Phone on My calls) gets a formula on its database that reads it, since a view shows its database's own fields only.
- **A grouping Fibery can't do**, a board's rows by a text, a number or a date, becomes a select.
- **A whole-number formula** stays whole when it starts with its 0 case: a day count reads one date field and is 0 without it, with the rule that stamps the date also firing on creation; a share is 0 when there is nothing to count. Otherwise it comes back decimal, with its number format By hand.
- **A view that only adds a filter to another view** isn't built, since people filter; the daily view and "My …" views stay. Each dropped view is a Change row.
- **A custom view** is a custom app: a view app for a page of its own, a layout app for a tab on every record.
- **A rule or button** is native actions only (build guide §5): an action that needs more (email, a comment on a linked record, a notification to the people of linked records, a check before acting) is left out and reported as not built, the rest of the rule is built when it still does its job, and the guide names the left-out step as done by hand; a rule whose point is that action isn't built at all.
- **Who sees what** makes a Space per group it names, the first keeping the recipe's title; who may open each is By hand.
- **`for: community`** makes members records in a database and organizers people fields, with intake through a form shared outside the workspace By hand.

## 3. The build

The build reads the recipe's Details for building and the delta together; the delta wins wherever they differ. The guide is written from the recipe's story as the build guide §6 says: one screen, ending with a link to the recipe. Older recipes may still carry Building notes; read them before the build. An older recipe's sample story may be a table rather than a paragraph: read it as the story. Keep the report's For the recipe lines (SKILL.md §6) as you go: a Change row most teams would need, a part of the recipe that couldn't be built, a promise the sample data couldn't keep.
