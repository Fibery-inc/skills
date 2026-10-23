---
name: "fibery-architect"
description: 'Design and build a ready-to-run Fibery Space for any process, directly in the connected workspace: databases and fields, relations and links to databases the workspace already has, workflows, formulas, views, reports, the automations the process depends on, a custom app where views fall short, documents and rich sample data, built with Fibery MCP. Starts from a one-line idea, an interview, a process document or SOP, a recipe (any from the Fibery Process Cookbook, which it looks up by itself, or one the person attaches, links or pastes) or an existing Space. Use whenever someone wants to set up, model, structure, replicate, design or build a process, workflow, pipeline, tracker, CRM, hiring flow, editorial calendar, service desk or operating system in Fibery, asks "how should I model X in Fibery", says "set up our ... process in Fibery" or asks for a Fibery template for one, even if they never say "architect" or "Space". Not for reviewing an existing workspace (fibery-health).'
compatibility: 'Needs the Fibery MCP server with its execute_code tool, connected to a workspace where the person can create Spaces, and a strong reasoning model (Sonnet 5.5 or better): each build step is one script the model writes from a template. A place to write files helps (the design lives there); without one it lives in the conversation. Custom apps also need web access to the workspace, and an Agent tool lets the app build alongside the rest.'
---

# Fibery architect

Turn how a team works into a Fibery Space they'll run their work in: about 80% of what a mature Space would have, which is enough to run the process tomorrow and small enough to still feel like theirs, shaped to their words and their workspace. You read the process (from the person, a document, a recipe or an existing Space) and the workspace it will live in, ask what only the person can answer, then design the Space and build it with Fibery MCP straight away: their answers are the go-ahead, and a short report after the build says where to start and what's left to them.

## What you need

- **Fibery MCP, connected to the target workspace, with `execute_code`.** The target is the connected workspace unless the person names another; then that one must be connected instead. The build runs as scripts through `execute_code`; if the connected server doesn't have it, say that this build needs it and build nothing.
- **Only the tools you call directly**: `execute_code`, `schema` and `schema_detailed`, `replace_document_blocks` and `fetch_view_data` for the guide, and when needed `get_fibery_skill` (an app's guide) or `fetch_by_url` (a linked Fibery document). Every other Fibery tool is called inside a script, where it needs no loading, and the templates in `references/scripts.md` show its input; in a client that loads tools on demand, loading them all would add about 25K tokens to every turn. In a client that loads tools on demand, load the first five in one search, with one Fibery connector's prefix when two are attached, and `get_fibery_skill` with them when the design has an app: it is the one Fibery tool a script can't call. Load any other tool only when a call to it fails and its error doesn't say what it wants.
- **A working folder** for `design.md`, when you can write files.

Paths are relative to this skill's folder. What to read, and when:

| File | Read it when |
|---|---|
| `references/design-guide.md` | before the questions, for a design from scratch: learning the process, reading the workspace and what to link, the 80% standard, what goes into each part and how it's written |
| `references/recipe-delta.md` | before the questions, for a recipe build, instead of the design guide: the recipe's questions, what to take from the workspace, the one-page delta |
| `references/existing-space.md` | when the source is an existing Space: how to read it, read-only |
| `references/build-guide.md` | once the questions are answered: the build's steps in order and what goes into each, the app, the call shapes the templates don't show, troubleshooting |
| `references/scripts.md` | with the build guide: the scripts' templates, under the same numbers |
| The cookbook's index (§1 says where; each recipe's `summary` says what it is) | before designing anything from scratch, because a process with a recipe is built from it (§1) |
| `examples/hiring-pipeline.md` | once, before writing your first design from scratch (a recipe build doesn't need it): a finished design at the depth expected |

Read what a phase needs in one message: the recipe and `recipe-delta.md` (for a design from scratch, the design guide and the example) before the questions, the build guide and `scripts.md` once they're answered.

## 1. Understand the process

**Look for a recipe first.** A recipe is a process described in prose a person could run it from, with the details a designer needs and the questions worth asking, written by the recipe-writer skill. It is tool-neutral (this skill decides how Fibery delivers it, `references/recipe-delta.md`) and not a blueprint: you still read the workspace and ask its questions, so two teams get two Spaces that fit them. Unless the person brings a recipe, an existing Space or a document of their own process, look in the Fibery Process Cookbook, an open library of recipes: fetch its index, `https://raw.githubusercontent.com/Fibery-inc/process-cookbook/main/index.json`, which gives every recipe's `title`, `summary`, `keywords` and `raw` link. When the index can't be fetched, read the `summary` lines of the two recipes copied into the plugin, in the recipe-writer skill's folder next to this one (`../recipe-writer/examples/`; when that isn't there either, the skill runs outside the plugin: design from the process directly). A recipe fits when it is the same process: the same main thing going through the same kind of stages ("a candidate goes from application to offer"), whatever the words; a word in common isn't enough. When one fits, name it in one line just before asking its "Making it yours" questions, and go on as the recipe row below says: a build from a recipe starts from a model worked out once for every team, so it comes out better than a design from scratch, and its questions replace the interview. When nothing fits, or the person would rather start from scratch, take the row for what they gave you.

| The person gives you | Do this |
|---|---|
| An idea ("set up our hiring process") | Ask only the questions whose answers change the structure, at most three: usually the stages and the roles. If they said "just build it", ask nothing. |
| A request to be interviewed, or a vague idea | The design guide §1: a few questions at a time, in their words, playing the model back before you design. |
| A process document, SOP or notes | Read it fully before asking anything; the design guide §1 table says what each part of it becomes. |
| A recipe: one from the cookbook, named or implied ("set up Shape Up"), or one the person attaches as a file, links to, or pastes in full | Get its text: a cookbook recipe from its `raw` link (its copy in `../recipe-writer/examples/` when the cookbook can't be reached); the attached file, read from where the client put it; a link, fetched with your web fetch tool (a Fibery document link through Fibery MCP's `fetch_by_url`), and if it can't be fetched, ask for the file or the text rather than guessing; the pasted text itself. Fetch a recipe whole: a web fetch tool that summarizes pages can shorten it, so with a shell, download it (`curl -sSfL <link> -o recipe.md`). A recipe the person supplies wins over the cookbook's of the same name. A text without a "Details for building" section is a process document, not a recipe: the row above. Save a fetched or supplied recipe as `recipe.md` in the working folder, so the build reads one stable copy. The questions in its "Making it yours" table are the interview, picked as `references/recipe-delta.md` §1 says and asked as §3 says; wait for the answers. Only an explicit "just build it" takes the defaults; a short request ("set up Shape Up") isn't one. Then write the delta as `references/recipe-delta.md` says, not a full design. |
| An existing Fibery Space (theirs or another workspace's) | Read it as `references/existing-space.md` describes, then design a new Space from it, copied or improved as asked; the existing Space is never changed. |

The names they use become database, field and state names: a team runs a Space that speaks their language and abandons one that doesn't.

## 2. Read the workspace

Do this before asking anything: a Space that duplicates what the team already tracks is worse than no Space, and what the workspace leaves open goes into the same questions (§3). The design guide §2 (for a recipe build, `references/recipe-delta.md` §1) says how to learn, reading only, what exists, what to **link** (the workspace's system of record for a noun: customers, employees, products), what to **create** (the nouns specific to this process), and which names are taken.

## 3. Ask once

The questions are the only stop. Ask at most four, the ones whose answers change what gets built and would be hard to change later: a database, a role, who uses Fibery, a second Space. What's easy to change after the build is never a question: names and words, an extra field and a select's options take defaults, written down in `design.md`. The workspace adds a question where it holds a real choice: an existing database that could be part of the solution, asked about by name ("Are your volunteers the people in Community/Member?"), the guess yes when it plainly serves the whole workspace or this team and no when it's only close; and a new Space's name that's taken (the guess: a new one beside it, "<name> 2"). Where the workspace has nothing that fits, the question about it isn't asked. An existing Space for the same process is a line, not a question: the new one is built beside it. Notes on the sample data, on rules that might not build or on the app don't go with the questions.

Ask them all at once (an interview takes a few rounds, the last being its playback): each in their words, with your guess, and none about databases, views or rules. When your client has a tool for asking questions with choices (AskUserQuestion in Claude Code and Cowork), every round is one call to it. Each question gets a header of a word or two, 12 characters at most ("Trap bank"); your guess as the first option, with "(Recommended)" after its label; then one to three real alternatives. An option's description says in a few plain words what the person gets ("Trappers use their own traps"). The tool adds Other for a typed answer, so don't add one, and multiSelect is only for answers that add up (who uses Fibery). Closing the questions unanswered isn't a "go": don't build until they answer. Without such a tool, a round is one message, a numbered list the person can answer by number or with "go": each question, then your guess ("Do you lend out numbered traps? I'll assume yes."), with no table and no column of what each answer would change. Either way, one line says you'll build as soon as they answer, in about 10 minutes from a recipe and 15 from scratch, a few more with an app: just before the call, or at the end of the message.

When the answers are in, or straight away after "just build it", write the design and build it in the same turn. Don't show the design or a summary, and don't ask whether to build, unless the person asked to see the design first. What you decide in their place (a default taken, a link made or left out, a name chosen) is written down in `design.md`, so it can be changed when they ask.

## 4. Write the design

Design and write it as `references/design-guide.md` prescribes: the spec in plain words, under a short list of what you assumed in the person's place. The standard is the **80% Space**, the one a team would have built for themselves after a month of running the process: enough to run it tomorrow, small enough to still feel like theirs. The design guide §3–4 give the rule for each part, from the number of databases to the custom app you consider every time; its numbers are ceilings for a typical process, never targets, so you decide what goes in, fewer is always fine, and what's left out is named in the guide's Make it yours. The person can ask for a starter Space or for everything; 80% is the default.

Save it as `design.md` in the working folder when you can write files; otherwise it lives in the conversation.

**With a recipe, the design is a delta.** The recipe's "Details for building" is the spec, so don't rewrite it: `design.md` holds only what the answers, the workspace or Fibery change, as `references/recipe-delta.md` §2 says. It's a page, not a document, and it's what makes recipe builds fast. The guide is written at build time, one screen from the recipe's story that links back to the recipe (build guide §6).

## 5. Build

Follow `references/build-guide.md` in its order: six `execute_code` scripts, each started from its template, and the guide's two direct calls, so a build is about ten tool calls, not a hundred. The structure comes first and the formulas second; then the views and reports, the sample records, the rules and buttons and the app, all at once, the app by a helper when the client has an Agent tool and the rules off, so none fires on the sample data; last the guide, whose text mentions the views, with the checks that read formulas and the rules turned on. The build guide's first section has the rules every script follows: above all, a script looks every id up by name, does only what's missing and logs what it found, so one that failed, was cut off or logged "time is up" runs again as it is, and a `fixLogs` line that renames a Space or database stops the build. Don't delete anything to start over unless the person asks; then delete only the new Spaces.

There is no separate verification pass: the scripts check the formula types, the nested views, the stored rule texts and the sample data's promises, and the guide's last call opens the first view once, to see the Space the way the person will; fix what looks wrong before the report. Never change a record to test an automation.

## 6. Report

A few lines for the person who will run the Space, each only when it has something to say:

> **TNR program is ready in Edge.** Start with the guide, [How to run the TNR program](…), which is one screen, then [In care](…) for the day-to-day.
>
> **Your turn:** set who can open the Space; share [Colony report](…) and [Volunteer signup](…) publicly (each form's Share button); add Description templates to Colony and Trapping.
>
> **Worth a look:** the Colony portrait tab on any colony: I couldn't open it, so I haven't seen it run.
>
> The examples are marked "(example)".

- **Ready**, always: the Space ready in its workspace (several Spaces, each with its reason), then the guide and the first view, both linked; the only other links are the forms in Your turn.
- **Your turn**: what the person sets by hand so the Space works for the team, each with where in Fibery: who may open the Space; a form to share with people outside the workspace, linked; a number or date field's minimum, maximum and default, including every default and range a recipe gives ("Date: today by default", "0 to 100"); a formula's number format, when it came back decimal; a Description's template, the headings a new record starts with (the build names them in the database's description, and the hero record's Description uses them). Never the Space icon, and never a failure.
- **Not built**: a rule native actions couldn't do (build guide §5) or a part that failed, each with what's done by hand instead.
- **Worth a look**: what the build couldn't check itself, usually the app, with why in a few words.
- The last line says the sample records are marked "(example)".

Nothing else goes in: no counts, no list of views or of what the Space tracks, no assumptions, nothing about what reaches outside the Space, how the build was checked, its time or scripts, or the recipe, and no offers. All of it is in `design.md` for when the person asks: the Assumptions at its top, and **Build notes** at its end, written now, a line each: what was created (N databases, N fields, N formulas, N views, N reports, N automations, N documents, N apps, N sample records; the fields the build added, people fields and links in, a relation once, Name, Description, the state, comments and formulas out; the views without the documents); the scripts and minutes; each link with the field it added to its existing database, the field each people field added to every person, and any rule that writes to existing records; what was checked and what wasn't; the app considered when none was built; and after a recipe build, **For the recipe**: what the delta added or changed that most teams would need too (never this team's names or links), what the recipe asked for that couldn't be built, and any promise the sample data couldn't keep.

## Boundaries

- Never change, rename or delete anything that existed before the build. The build adds exactly three kinds of things outside the new Spaces, all written down in `design.md`'s Build notes: the inverse field of each link on the existing database, the `user/<name>` field of each people field on the workspace's people, and a rule that writes to records of a linked database when the team's own records change, which exists only when the person asked for one, before the build or after it. The build itself never reads existing records into sample data, writes to them, or links sample records to them.
- Never put real people, customers, emails or record contents into sample data; sample data is invented, people are `me`.
- No migration from other tools in this version: neither their structure (a Notion or Airtable base, a Jira project, a spreadsheet) nor their records. If that's what the person has, say so, design from their process as they describe it, and point them to Fibery's import for the records afterwards.
- If the workspace already has a Space for this process, say so with the questions (after "just build it", in `design.md`'s Assumptions) and build alongside it (a new Space, links allowed); changing the existing one is fibery-health's kind of work, done differently.
