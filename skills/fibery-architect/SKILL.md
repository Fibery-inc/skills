---
name: "fibery-architect"
description: 'Design and build a ready-to-run Fibery Space for any process, directly in the connected workspace: databases and fields, relations and links to databases the workspace already has, workflows, formulas, views, reports, the automations the process depends on, a custom app where views fall short, documents and rich sample data, built with Fibery MCP. Starts from a one-line idea, an interview, a process document or SOP, a recipe (any from the Fibery Process Cookbook, which it looks up by itself, or one the person attaches, links or pastes) or an existing Space. Use whenever someone wants to set up, model, structure, replicate, design or build a process, workflow, pipeline, tracker, CRM, hiring flow, editorial calendar, service desk or operating system in Fibery, asks "how should I model X in Fibery", says "set up our ... process in Fibery" or asks for a Fibery template for one, even if they never say "architect" or "Space". Not for reviewing an existing workspace (fibery-health).'
compatibility: 'Needs the Fibery MCP server with its execute_code tool, connected to a workspace where the person can create Spaces, and a strong reasoning model (Sonnet 5.5 or better): each build step is one script the model writes from a template. A place to write files helps (the design lives there); without one it lives in the conversation. Custom apps also need web access to the workspace, and an Agent tool lets the app build alongside the rest.'
---

# Fibery architect

Turn how a team works into a Fibery Space they'll run their work in: about 80% of what a mature Space would have, which is enough to run the process tomorrow and small enough to still feel like theirs, shaped to their words and their workspace. You read the process (from the person, a document, a recipe or an existing Space) and the workspace it will live in, ask what only the person can answer, then design the Space and build it with Fibery MCP straight away: their answers are the go-ahead, and the report after the build says what you decided in their place.

## What you need

- **Fibery MCP, connected to the target workspace, with `execute_code`.** The target is the connected workspace unless the person names another; then that one must be connected instead. The build runs as scripts through `execute_code`; if the connected server doesn't have it, say that this build needs it and build nothing.
- **Only the tools you call directly**: `execute_code`, `schema` and `schema_detailed`, `insert_document_blocks` and `fetch_view_data` for the guide, and when needed `get_fibery_skill` (an app's guide) or `fetch_by_url` (a linked Fibery document). Every other Fibery tool is called inside a script, where it needs no loading, and the templates in `references/scripts.md` show its input; in a client that loads tools on demand, loading them all would add about 25K tokens to every turn. In a client that loads tools on demand, load the first five in one search, with one Fibery connector's prefix when two are attached, and `get_fibery_skill` with them when the design has an app: it is the one Fibery tool a script can't call. Load any other tool only when a call to it fails and its error doesn't say what it wants.
- **A working folder** for `design.md`, when you can write files.

Paths are relative to this skill's folder. What to read, and when:

| File | Read it when |
|---|---|
| `references/design-guide.md` | before the questions, for a design from scratch: learning the process, reading the workspace and what to link, the 80% standard, what goes into each part and how it's written |
| `references/recipe-delta.md` | before the questions, for a recipe build, instead of the design guide: the recipe's questions, what to take from the workspace, the one-page delta |
| `references/existing-space.md` | when the source is an existing Space: how to read it, read-only |
| `references/build-guide.md` | once the questions are answered: the build's steps in order and what goes into each, the app, the call shapes the templates don't show, troubleshooting |
| `references/scripts.md` | with the build guide: the five scripts' templates, under the same numbers |
| The cookbook's index (§1 says where; each recipe's `summary` says what it is) | before designing anything from scratch, because a process with a recipe is built from it (§1) |
| `examples/hiring-pipeline.md` | once, before writing your first design from scratch (a recipe build doesn't need it): a finished design at the depth expected |

Read what a phase needs in one message: the recipe and `recipe-delta.md` (for a design from scratch, the design guide and the example) before the questions, the build guide and `scripts.md` once they're answered.

## 1. Understand the process

**Look for a recipe first.** A recipe is a process described in prose a person could run it from, with the details a designer needs and the questions worth asking, written by the recipe-writer skill. It is tool-neutral (this skill decides how Fibery delivers it, `references/recipe-delta.md`) and not a blueprint: you still read the workspace and ask its questions, so two teams get two Spaces that fit them. Unless the person brings a recipe, an existing Space or a document of their own process, look in the Fibery Process Cookbook, an open library of recipes: fetch its index, `https://raw.githubusercontent.com/Fibery-inc/process-cookbook/main/index.json`, which gives every recipe's `title`, `summary`, `keywords` and `raw` link. When the index can't be fetched, read the `summary` lines of the two recipes copied into the plugin, in the recipe-writer skill's folder next to this one (`../recipe-writer/examples/`; when that isn't there either, the skill runs outside the plugin: design from the process directly). A recipe fits when it is the same process: the same main thing going through the same kind of stages ("a candidate goes from application to offer"), whatever the words; a word in common isn't enough. When one fits, name it in one line in the message that asks its "Making it yours" questions, and go on as the recipe row below says: a build from a recipe starts from a model worked out once for every team, so it comes out better than a design from scratch, and its questions replace the interview. When nothing fits, or the person would rather start from scratch, take the row for what they gave you.

| The person gives you | Do this |
|---|---|
| An idea ("set up our hiring process") | Ask only the questions whose answers change the structure, at most three: usually the stages and the roles. If they said "just build it", ask nothing. |
| A request to be interviewed, or a vague idea | The design guide §1: a few questions at a time, in their words, playing the model back before you design. |
| A process document, SOP or notes | Read it fully before asking anything; the design guide §1 table says what each part of it becomes. |
| A recipe: one from the cookbook, named or implied ("set up Shape Up"), or one the person attaches as a file, links to, or pastes in full | Get its text: a cookbook recipe from its `raw` link (its copy in `../recipe-writer/examples/` when the cookbook can't be reached); the attached file, read from where the client put it; a link, fetched with your web fetch tool (a Fibery document link through Fibery MCP's `fetch_by_url`), and if it can't be fetched, ask for the file or the text rather than guessing; the pasted text itself. Fetch a recipe whole: a web fetch tool that summarizes pages can shorten it, so with a shell, download it (`curl -sSfL <link> -o recipe.md`). A recipe the person supplies wins over the cookbook's of the same name. A text without a "Details for building" section is a process document, not a recipe: the row above. Save a fetched or supplied recipe as `recipe.md` in the working folder, so the build reads one stable copy. Its "Making it yours" questions are the interview: ask all of them, as a table with the defaults, and wait for the answers; a question the workspace already answers is stated as answered, not asked. Only an explicit "just build it" takes the defaults; a short request ("set up Shape Up") isn't one. Then write the delta as `references/recipe-delta.md` says, not a full design. |
| An existing Fibery Space (theirs or another workspace's) | Read it as `references/existing-space.md` describes, then design a new Space from it, copied or improved as asked; the existing Space is never changed. |

The names they use become database, field and state names: a team runs a Space that speaks their language and abandons one that doesn't.

## 2. Read the workspace

Do this before asking anything: a Space that duplicates what the team already tracks is worse than no Space, and what the workspace leaves open goes into the same questions (§3). The design guide §2 (for a recipe build, `references/recipe-delta.md` §1) says how to learn, reading only, what exists, what to **link** (the workspace's system of record for a noun: customers, employees, products), what to **create** (the nouns specific to this process), and which names are taken.

## 3. Ask once

The questions are the only stop. Send them in one message (an interview takes a few, the last being its playback), each with the default a shrug gets, plus a row for whatever the workspace leaves to the person: a new Space's name that's taken (default: a new one beside it, "<name> 2"), or an existing database that may or may not be the one to link to (default: a new database in the new Space). An existing Space for the same process is a line, not a question: the new one is built beside it. End that message, or an interview's playback, with one line: you'll build as soon as they answer, in about 10 minutes from a recipe and 15 from scratch, a few more with an app.

When the answers are in, or straight away after "just build it", write the design and build it in the same turn. Don't show the design or a summary, and don't ask whether to build, unless the person asked to see the design first. What you decide in their place (a default taken, a link made or left out, a name chosen) is written down in `design.md` and listed in the report, so they can ask for it to be changed.

## 4. Write the design

Design and write it as `references/design-guide.md` prescribes: the spec in plain words, under a short list of what you assumed in the person's place. The standard is the **80% Space**, the one a team would have built for themselves after a month of running the process: enough to run it tomorrow, small enough to still feel like theirs. The design guide §3–4 give the rule for each part, from the number of databases to the custom app you consider every time; its numbers are ceilings for a typical process, never targets, so you decide what goes in, fewer is always fine, and what's left out is named in the guide's Make it yours. The person can ask for a starter Space or for everything; 80% is the default.

Save it as `design.md` in the working folder when you can write files; otherwise it lives in the conversation.

**With a recipe, the design is a delta.** The recipe's "Details for building" is the spec, so don't rewrite it: `design.md` holds only what the answers, the workspace or Fibery change, as `references/recipe-delta.md` §2 says. It's a page, not a document, and it's what makes recipe builds fast. The guide is written at build time, one screen from the recipe's story that links back to the recipe (build guide §6).

## 5. Build

Follow `references/build-guide.md` in its order: five `execute_code` scripts, each started from its template, then the guide's two direct calls, so a build is about ten tool calls, not a hundred. The structure comes first and the formulas second; the views and reports go with the sample records in one message; then the rules and buttons, after the records so no rule fires on them, together with the guide, whose text links to the views. An app is built beside them, by a helper when the client has an Agent tool. The build guide's first section has the rules every script follows: above all, a script looks every id up by name, does only what's missing and logs what it found, so one that failed, was cut off or logged "time is up" runs again as it is, and a `fixLogs` line that renames a Space or database stops the build. Don't delete anything to start over unless the person asks; then delete only the new Spaces.

There is no separate verification pass: the scripts check the formula types, the nested views, the stored rule texts and the sample data's promises, and the guide's last call opens the first view once, to see the Space the way the person will; fix what looks wrong before the report. Never change a record to test an automation.

## 6. Report

```
Built <Space name, or names, each with its reason when there are several> in <workspace>
Created: N databases, N fields, N formulas, N views, N reports, N automations, N documents, N apps, N sample records
Links: <Database.Field → Existing/Database> ...
Build: N scripts, N minutes
```

N fields counts the fields the build added: people fields and links in, a relation once, and Name, Description, the state, comments and formulas out. N views leaves out the guide and other documents, which are N documents.

Then, briefly, one line each:

- **Assumptions**: every choice made in the person's place, from `design.md`: a default taken, a link made or left out, a Space name chosen, a currency.
- **Outside the Space**: the field each people field added to every person, the field each link added to its existing database, and any rule that writes to existing records.
- **By hand**: what Fibery MCP can't set, settings the person makes after the build and never failures, each with where in Fibery to set it: the Space icon, always; a Space's sharing, who may open it; a form shared with people outside the workspace; a number or date field's minimum, maximum and default, including every default and range a recipe gives ("Date: today by default", "0 to 100"); a formula's number format, when it came back decimal; a Description's template, the headings a new record starts with (the build names them in the database's description, and the hero record's Description uses them).
- **Not built**: every rule dropped because native actions couldn't do it (build guide §5), the app you considered when none was built, and anything else, with why.

Then the view to open first, and two offers: delete the sample records or the whole Space if this was a trial, and share it. For an identical copy elsewhere, Fibery's **Share Space as template** does it.

After a recipe build, end with **For the recipe**, at most five lines for whoever keeps it: what the delta added or changed that most teams would need too (never this team's names or links), what the recipe asked for that couldn't be built, and any promise the sample data couldn't keep. Offer to turn them into a revision with recipe-writer. After a design from scratch for a process without a recipe, offer to turn the new Space into one with recipe-writer, so the next team starts from a recipe.

## Boundaries

- Never change, rename or delete anything that existed before the build. The build adds exactly three kinds of things outside the new Spaces, all listed in the report: the inverse field of each link on the existing database, the `user/<name>` field of each people field on the workspace's people, and a rule that writes to records of a linked database when the team's own records change, which exists only when the person asked for one, before the build or after it. The build itself never reads existing records into sample data, writes to them, or links sample records to them.
- Never put real people, customers, emails or record contents into sample data; sample data is invented, people are `me`.
- No migration from other tools in this version: neither their structure (a Notion or Airtable base, a Jira project, a spreadsheet) nor their records. If that's what the person has, say so, design from their process as they describe it, and point them to Fibery's import for the records afterwards.
- If the workspace already has a Space for this process, say so with the questions (in the report after "just build it") and build alongside it (a new Space, links allowed); changing the existing one is fibery-health's kind of work, done differently.
