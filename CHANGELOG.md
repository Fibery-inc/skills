# Changelog

## 1.8.21 — 2026-10-25

fibery-architect makes a gallery wherever cards should show a picture, and gives the sample cards placeholder covers. A Fibery board has no cover, and `create_view` drops one without an error, so a Film study club build made the recipe's Toolkit, a board with "Frames as the cover", a board with Frames as a card field. Now cards that show a picture make a gallery, even where the spec or the recipe says board, with the board's columns as its lanes, and the delta lists that as a change. Build guide §8 gives the gallery's shape (`cover`, a files field a gallery can't do without; `fillCover`; lanes as `y` axes with `hideEmptyLanes`; `cardSize`), so a gallery no longer needs Fibery's views guide, and a gallery's database no longer needs avatars. Sample files still stay empty, except a gallery's cover: script 4 gives every sample record on a gallery a placeholder picture, a block in its lane's color with its name on it, from placehold.co, and a rerun adds none to a record that has one; the README's What it sends and fetches names placehold.co. On edge: galleries by a select and by state with red cards and their placeholder covers shown, a board sent a cover storing none, and script 4 uploading three covers in 2.5 seconds.

## 1.8.20 — 2026-10-24

A description and keywords people search with. The description, the same in both manifests, the marketplace entry and `gemini-extension.json`, now reads "Describe how your company, team, shop or club works and get it running in Fibery, from sales and OKRs to repair orders, production queues and volunteer programs. Also audits your workspace and writes processes up as playbooks.", in place of Fibery's own terms (Spaces, recipes) and "Works with the Fibery connector", which 1.8.17 made out of date. The keywords name the kinds of processes the plugin sets up (crm, sales pipeline, okrs, hiring, product development, incident management, procurement, content calendar, compliance, small business, manufacturing, nonprofit) with fibery, work management, workflow, templates, automations and workspace audit, and drop recipe, cookbook, space, workspace, structure and health, which match unrelated searches. The README, which Anthropic's directory shows as the listing's description, opens with what you get and where it works, Claude first; the other agents move to Install, which gains a Claude and Cowork row; the Recipes section shows the cookbook's range; and fibery-architect's examples add a repair shop.

## 1.8.19 — 2026-10-24

The README says what the plugin sends and fetches outside Fibery MCP: the cookbook's index and recipes from GitHub, with nothing from the workspace; for a custom app, its code downloaded from and uploaded to the person's own workspace with a developer token from Fibery MCP, and possibly a local `pnpm` build; public pages for recipe-writer's sources and a link the person gives; and the files written in the working folder. A new SECURITY.md says how to report a security issue (support@fibery.io), and the README's Support points to it. Both are for Anthropic's directory review, whose policy asks for a way to receive vulnerability reports and a README that describes everything a plugin sends or fetches.

## 1.8.18 — 2026-10-24

The Claude manifest has the directory listing fields again: `icon` (`./assets/logo.svg`), `documentationUrl` (the README), `supportUrl` (the Fibery community), `privacyPolicyUrl` and `termsOfServiceUrl` (fibery.com). Anthropic's directory reads them for the plugin's listing and Claude Code ignores them; `claude plugin validate` accepts them from Claude Code 2.1.281. 1.4.1 had removed them when the Claude app stripped them as unknown, and the directory's validation of 1.8.17 noted the missing privacy policy URL.

## 1.8.17 — 2026-10-24

The plugin brings Fibery MCP to Claude. A new `.mcp.json` names `https://mcp.fibery.io/mcp`, so in Claude and Cowork Fibery is on the plugin's Connectors tab, and Claude Code connects it with the plugin instead of needing `claude mcp add`; it is the Fibery connector's URL, so anyone who has both gets one set of tools. Until now only the other agents got the server (from `mcp.json` and `gemini-extension.json`), and Anthropic's directory validation reported "No MCP servers", which also keeps a plugin from being paired with its connector's listing. fibery-architect no longer spells out a `curl` command for downloading a recipe whole, which the same validation flagged as a download-and-run command; it says to download the file itself. And a cookbook recipe comes only from the cookbook, downloaded whole with a shell or else through the web fetch tool: the copies of Shape Up and Content calendar in recipe-writer's `examples/` stay recipe-writer's models but are no longer fibery-architect's fallback, so when the cookbook's index can't be fetched, the design starts from the process.

## 1.8.16 — 2026-10-23

fibery-architect's scripts use more of the minute Fibery gives them, and nothing waits on the app. Every template starts a call or a batch only while the time so far plus the slowest one yet ends by 45 seconds, counting at least 5 seconds for one and 15 when Fibery's AI writes it, instead of stopping at 25 to 35 seconds: an installation's first script logged "time is up" at 30 seconds with three workflow fields left, while on edge a script that ran 55 seconds still came back (one of 70 got "The upstream server is timing out"). The app script always goes in the message with scripts 3 to 5, so the guide can mention a page app, and a helper writes the app's code only when the Agent tool can run one in the background, started in a message of its own once the app script has logged; otherwise the app is written after the guide. A helper the call waits for holds up the scripts sent beside it: in Cowork a script sent with a 30-second helper ran only when the helper was done, and the installation lost about two minutes to it. The build guide and `scripts.md` are read before the questions, with the recipe or the design guide, so the build starts the moment the person answers. On edge, in the new order: script 2 made ten formulas in 28 seconds, script 5 nine automations with every rule off, script 6 held its checks and turned six rules on, with nothing failed; with slow calls simulated, every script stopped by 45 seconds and finished on its rerun.

## 1.8.15 — 2026-10-23

fibery-architect keeps the sample story intact and puts the guide first. Script 5 turns each rule off as soon as it makes it, so no rule fires on the sample records written beside it, and script 6, in the guide's message, turns them on: in a Sales pipeline build on 1.8.14, script 4 was sent again after the rules existed, and they set every deal's days in stage to 0 and every closed deal's date to the build day. Script 1 makes the guide's empty document before any other view, since a Space lists its views in the order they were made, so How to run <process> is always the first view; script 3 no longer makes it. Step 3 says the rest goes in one message, scripts 3, 4 and 5 in that order (one build had sent them one by one), and every script is written straight into the `execute_code` call, since one assembled in a file first is typed twice (two of three builds did). On edge: rules made before the records and off stayed silent, the story's dates held and the checks passed, script 6 turned the rules on and a new record got its date within a second; the guide headed the Space's sidebar, ahead of the views, the report and the app made after it.

## 1.8.14 — 2026-10-23

fibery-architect builds in a new order: the structure, then the formulas, then everything else at once, then the guide. Views and reports, sample records, rules and buttons and the app now go out in one message, the app's helper first, running the app script itself, since none needs another; a rule may fire on the sample data as it is written, and that's fine. The guide comes last, so it can mention everything the others made, together with a new script 6, the checks that read formulas: they left script 5, which beside the records would check them before there was anything to read. The app script also logs a page app's mention for the guide. "Before the scripts" lists the four messages in order instead of a table numbered by section, and a fix goes in a message of its own before the guide's. On edge: scripts 1 and 2, then the app script and scripts 3 to 5 in one message, then script 6, with nothing failed and every check holding.

## 1.8.13 — 2026-10-23

fibery-architect's formulas are a script of their own again, script 2, as before 1.8.12, so a script that runs out of time is sent again with only its own part: in a timed TNR program build on 1.8.12, script 1 ran out of time on the structure and went again whole, formulas included, 15.2K characters. The app's part, an add-on to script 1 in 1.8.12, is a script of its own too, script 7 after the build guide's §7, run only with an app, right after script 2 (the TNR build had run it on its own anyway): it makes the empty app and logs its id and the ids the app's code needs, formula fields included, before script 3, which then finds a page app for the guide, and the app's helper starts there. Build guide §8 now gives a map view's `location`, so a map no longer needs Fibery's views guide (27K characters) for one line. Scripts 1, 2 and 7 ran on edge, first runs and reruns, with nothing failed, and a map built as §8 says was stored as sent.

## 1.8.12 — 2026-10-23

fibery-architect's script templates are shorter, so a build types less and makes one call fewer. Script 1 now builds the structure and then the formulas, script 2's job until now: schema changes have been fast enough since Fibery MCP's release of 2026-10-22 for one script to do both. It starts the formulas once every field exists and stops in time as before. A build is four scripts, still numbered after the build guide's sections, so there is no script 2. The part of script 1 that makes the empty app and logs the ids its code needs is an add-on, pasted in only when the design has an app. Scripts 3 to 5 share smaller helpers, and the example data shows one of each kind: one job, three candidates, one report. The fixed code a build copies went from 27.4K characters to 23.1K without an app and 25.0K with one, and `scripts.md` from 38.5K to 36.1K. Every template ran on edge in a throwaway Space, first runs and reruns, with nothing failed.

## 1.8.11 — 2026-10-23

fibery-architect's build guide drops what Fibery MCP already tells the model or what the guide said twice, and catches up with today's MCP: 51.7K characters down to 48.2K. Gone: what `execute_code`'s own description says (tools as functions, `log`, no variable named after a tool), the evidence behind the scripts' time budget, the bullet describing the templates' `run`, the reasoning behind the app lookup, most formula-typing examples (one per rule stays), the builders' definitions (the template has them), the second `get_reports_list` warning, restated mention and empty-paragraph behaviour, the custom-apps-dev guide's own rules in §7 (token lifetime, local build, helpers, React Query, theme tokens, errors), the `query` and `get_me` result rows, and three troubleshooting rows. Fixed: `replace_document_blocks` now works inside scripts, so script 4 fills a new Description by replacing its empty paragraph in one call instead of inserting and deleting; the reason file fields stay empty (a sample file could be uploaded now, but would have to be a real one); `display_automations_schema` costs about 17K characters, not 15K tokens; `query_views` returns `config` by default, a document's secret only when asked by id, and its `viewType: "report"` filter finds nothing. The custom-apps-dev guide no longer overrides the build's three app rules (build only what "how it works" says, look names up by id, change only the fields in Writes and add no packages).

## 1.8.10 — 2026-10-23

fibery-architect writes a sample record's location as an object with its coordinates, address and `addressParts`, which Fibery MCP rejects a create without; the parts can be `{}`. Sample places sit in one real city, since Fibery doesn't look an address up and the coordinates are the pin. A TNR program build was rejected on its colonies' Location.

## 1.8.9 — 2026-10-23

fibery-architect gives every select an emoji on every option by default. A TNR program build put none on any of its seven selects, Sex and Age among them, since under the old rule short options "read fine as words" and none was always a defensible choice. The exceptions are options that are names (clinics, places, people, products, departments, countries), where any emoji would be arbitrary, and lists longer than about eight; workflow states still can't take one.

## 1.8.8 — 2026-10-23

fibery-architect's report after a build is a few lines for the person who runs the Space: that it's ready, with the guide and the first view linked; Your turn, what they set by hand (who may open the Space, forms to share, Description templates, a field's default or range); Not built, when something was dropped; Worth a look, what the build couldn't check itself, usually the app, and why; and that the examples are marked "(example)". The block of counts, the list of views, the assumptions, what reaches outside the Space, how the build was checked, the notes for the recipe and every offer are gone from it, and the Space icon is no longer asked for. What left the report is in `design.md` for when the person asks: the Assumptions at its top, and Build notes at its end with the counts, the scripts and minutes, what reaches outside the Space, what was checked and the notes for the recipe.

## 1.8.7 — 2026-10-23

fibery-architect's guide, How to run <process>, mentions its views instead of linking to them: every view, form, report, document and app it names is a Fibery mention, which shows the view's current name, opens it on a click and keeps up with a rename. Script 3 asks Fibery MCP's `get_entity_mention` for every view and logs the mentions beside the urls; the recipe in the guide's last line stays a link. The guide also no longer opens with a blank line: a new document holds one empty paragraph, the guide was written after it, and now it replaces it. Sample records' Descriptions opened with the same blank line; script 4 now writes before that paragraph and deletes it, since a script has no `replace_document_blocks`.

## 1.8.6 — 2026-10-23

fibery-architect asks its questions through the client's question tool when there is one, AskUserQuestion in Claude Code and Cowork, so the person clicks an answer instead of typing it. Each question gets a short header ("Trap bank"), the guess as the first option marked Recommended, one to three alternatives described by what the person gets, and the tool's own Other for a typed answer. From a recipe, the Making it yours table's Default is the guess and its "If not the default" the alternative. Closing the questions isn't a "go": nothing is built until they're answered. A client without such a tool still gets the numbered list, answered by number or "go". An interview no longer lists a database's fields to cut or add, since 1.8.5 made fields a default the person changes in the built Space.

## 1.8.5 — 2026-10-23

fibery-architect asks fewer questions, in plain words. Before a TNR program build it asked ten, in a three-column table, though the recipe has four: the recipe's adaptation bullets, a Space name nobody had to choose and the clinic list had become questions, each with a column of what the build would change, under notes about sample data and rules that might not build. Now it asks at most four, as a numbered list with its guess for each ("Do you lend out numbered traps? I'll assume yes."), answered by number or "go": only questions from the recipe's table, never its bullets, and only what changes what gets built and is hard to change later. Names, words, extra fields and option lists take defaults the report lists. The workspace adds a question where it holds a real choice: an existing database that could be part of the solution, asked about by name, or a Space name that's taken; a question about something the workspace doesn't have isn't asked. Notes on sample data, rules and the app wait for the report.

## 1.8.4 — 2026-10-23

fibery-architect describes a field only when its name leaves a question: a scale or unit, what counts, or that a rule fills it ("Set by Stage changed when the state changes"). Email, Phone, Resume, Recruiter, Job or Due date get no description. Builds used to describe every text, number, date, relation and files field with what goes in it and why, down to "The day of the clinic; Clinic days runs on it" on the TNR program's Date. A formula still shows the prompt Fibery wrote it from as its description, since Fibery MCP has no other way to set one.

## 1.8.3 — 2026-10-23

fibery-architect gives a select an emoji on every option when people tell its options apart at a glance: priorities (High `:fire:`, Low `:snowflake:`), health, channels, kinds and sizes. A select that reads fine as words gets none, and workflow states can't take one. Fibery MCP takes an option's icon as a shortcode with colons, and a probe showed that an unknown shortcode, a raw emoji or an empty string is stored as a random emoji rather than rejected (`:not_a_real_emoji_xyz:` became `:notebook:`, 🔥 became `:shamrock:`), so script 1 reads the icons back and logs every one stored differently; an alias, `:thumbsup:` stored as `:+1:`, is fine. Of 58 common shortcodes, 51 came back as sent and 7 as their aliases.

## 1.8.2 — 2026-10-23

fibery-architect colors every database by what its name brings to mind, the color a person would pick for it: a Cat light gray, a Clinic day bright red, an Invoice green. The main database picks first; no two databases share a color or take near twins such as Orange and Red-orange, and a name that suggests nothing gets a free color far from the others, never a grey. Each Space takes the color of its first database. Before, every Space was Teal and its databases walked the palette from there, so the TNR program and OKRs came out in the same Teal, Green, Yellow-green, Orange, Red-orange sequence, three of them shades of orange.

## 1.8.1 — 2026-10-23

fibery-architect puts a table's columns in the order a person reads a row, whatever order the spec or recipe lists them in: what the record is part of, where it stands (the state and what measures it), who (the people fields together), what kind (the selects), when (dates in the order they happen), how much, then contact details, other links and text. A formula sits right after the field it reads, and pairs such as Salary min and Salary max sit side by side. Lists, nested items and board cards follow the same order. The TNR program's In care list used to end with the state, and its nested trappings split Coordinator and Trappers with Planned cats between them; by the rule they read Trapping, State, Age, Sex, Fixed on, Return on, and Colony, State, Coordinator, Trappers, Trap night, Planned cats.

## 1.8.0 — 2026-10-23

fibery-architect builds as soon as the questions are answered: no design card and no "Build it?". It reads the workspace before it asks, so the one questions message also carries what the workspace leaves to the person (a Space name that's taken, an existing database that may or may not be the one to link), says when a Space for the same process exists already, and ends by saying the build starts with the answers. After "just build it" it asks nothing at all. What the card used to show moves to the report: the assumptions made in the person's place, the fields added outside the new Spaces, the By hand settings and what wasn't built. A rule that writes to records of an existing database is built only when the person asks for one. The Build it line of every cookbook recipe, the format and the two bundled copies now reads "Claude asks a few questions, then sets it up in about ten minutes."

## 1.7.0 — 2026-10-21

fibery-health starts a check of a big workspace, more than about 40 databases, with an overview: one script run reads every database's record count, its newest record and the schema, and gives one line per Space (active, quiet or dormant, size, descriptions, leftovers, switched-off and date-fixed formulas, synced databases), with the copies, same concepts and people-field clutter across Spaces. It then suggests 3–5 Spaces and checks in full the ones the person picks, automations included. On Fibery's own workspace (47 Spaces, 229 databases, 2.8 million records) the overview took 3 minutes and one run of a 7 KB script, where a full check of everything would have taken about 12 runs. The script and the report are in the new `references/overview.md`.

## 1.6.0 — 2026-10-21

fibery-health, after its first runs on a real workspace, three of Fibery's own Spaces. Its script read only 5 of their 12 databases: real workspaces have fields the sample Spaces never had (document and whiteboard collections, hidden import fields, selects moved from another Space). It now reads them all, and when a field still can't be read it leaves out that field instead of the whole database. The data pass narrows to what the records say about the model: unused and retired fields (with the formulas that still read them and, for a relation, whether the other side still links), missing links and owners whose users were deactivated, text that should be a select, and dormant databases. Empty rich text, untitled and duplicate records, stuck, overdue and stale work, and deletions are gone, and with them the history reads; the script is one part again, with a `DATA` switch. New structure checks: formulas Fibery switched off or fixed to a date, select options that are unused or split one value, people marked as left whose users can still sign in, names that mix alphabets, rule messages that contradict their rule, and Script actions left as Fibery's template. A scheduled rule counts as silent only when its filter matches records now, and a parking state typed Started is a question, not a finding. A full check of each Space took 2½–5½ minutes instead of 4½–7½, with one script run, and every count in the reports held up when checked against the workspace.

## 1.5.0 — 2026-10-20

fibery-health gathers its evidence with one `execute_code` script instead of dozens of separate calls. Part 1 reads, for every database in scope, its fields and how often each is filled, workflow states and select options with their counts, and its rules and buttons with their last run, trigger, filter and actions; part 2, added for the data pass, reads duplicates, empty links, stuck and overdue work, and deletions from the history. The script stops before Fibery's one-minute cut-off, or before its output gets too long to read in one piece, and its last line says how to run it again for what's left. In tests, a full check of a 15-database Space took under 4 minutes and 12 tool calls instead of 6 minutes and 97, and a structure check of a 43-database workspace about 4 minutes and 14 calls instead of 6 minutes and 175. fibery-health now needs `execute_code`.

## 1.4.1 — 2026-10-20

The Claude plugin manifest drops five keys Claude doesn't read (`icon`, `documentationUrl`, `supportUrl`, `privacyPolicyUrl`, `termsOfServiceUrl`), which made the Claude app warn when the plugin was installed. The support, privacy and terms links move to the README.

## 1.4.0 — 2026-10-20

Every recipe ends with Sources, the one to three published sources it was written from, the main one first; a named method's source moves there from the promise line. recipe-writer reads one to three sources for every recipe, whatever it starts from, and lists them, and the two bundled recipes carry theirs.

## 1.3.0 — 2026-10-20

Recipes have no For AI agents section any more: the recipe format, its checks and the two bundled recipes drop it, and recipe-writer no longer writes agent behaviours. The guide fibery-architect writes already left it out.

## 1.2.1 — 2026-10-14

The recipe format says a rule comments on its own record and notifies the people in that record's own fields, never through a linked record, which most tools can't do and fibery-architect leaves out. To remind someone named on a linked record, a recipe gives the record the rule runs on a person field of its own.

## 1.2.0 — 2026-10-14

The guide every build writes, How to run <process>, now fits on one screen, under 500 words, for recipe builds too: the promise, the loop in up to ten lines that say who acts and in which view, where to look, what stays true, and a line of requests to make it yours. Recipe builds used to copy the recipe's whole story into it, 1,600–2,400 words that people skip; now its last line links the recipe's cookbook page for the why. The recipe format and the bundled recipes say so in What people look at and the Views table.

## 1.1.2 — 2026-10-14

The bundled Shape Up and Content calendar recipes and the recipe format follow the cookbook's fixes from the nine-recipe test: Shape Up's sample story, the format's example too, keeps the two-week cool down, and Content calendar's Stage changed rule also runs when a post is created, so Days in stage counts from one date.

## 1.1.1 — 2026-10-14

fibery-architect, from building all nine cookbook recipes at once and re-testing three: every script now stops before Fibery's one-minute cut-off and logs "time is up, run this script again", and every one, the sample records included, runs again as it is, doing only what's missing and logging what was there before. Script 1 logs every id an app needs, and finds the right app, on any run. A rerun of script 3 repairs a report whose chart was rejected, and reports take the documented conditions and historical sources. The build guide adds what the builds measured: when a formula comes back decimal or whole, no `Now()` in formulas, people fields for every "My …" view, a formula for a report or view that reads a linked record, the Create action and `update_automation`'s shape, prompts that name the triggering record, and rules built without the one action Fibery can't do.

## 1.1.0 — 2026-10-13

fibery-architect looks processes up in the [Fibery Process Cookbook](https://github.com/Fibery-inc/process-cookbook) by itself, so "set up OKRs" builds from the cookbook's recipe without attaching it. The bundled Shape Up and Content calendar recipes are copies of the cookbook's, used when it can't be reached; CI warns when they or the recipe format drift from it. The recipe footer's credit line links to the cookbook.

## 1.0.0 — 2026-10-13

First public release, with three skills: fibery-architect, fibery-health and recipe-writer. One repository installs in Claude Code, Codex, GitHub Copilot, VS Code, Cursor, Gemini CLI and Kiro.
