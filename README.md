# Fibery skills

Describe how your company, team, shop or club works and get it running in Fibery, from sales pipelines and OKRs to incident response, purchase approvals, repair orders, production queues and volunteer programs. fibery-architect builds a ready-to-run Space in your own workspace, with databases, workflows, views, reports, automations and sample data. fibery-health checks a workspace's health, and recipe-writer writes a process up as a recipe, a playbook any team can follow.

It works in Claude, Cowork and Claude Code with your Fibery workspace, and in other agents that read skills (see [Install](#install)).

## Skills

- **fibery-architect** — turns how a team works (an idea, an interview, a process document, a recipe or an existing Space) into a ready-to-run Fibery Space in your workspace: databases, fields, relations and links to what you already track, workflows, formulas, views, reports, the automations the process depends on, a custom app where views fall short, documents and sample data. It starts from a recipe from the [Fibery Process Cookbook](https://github.com/Fibery-inc/process-cookbook) whenever one fits the process, which gives a better Space than a design from scratch. It asks its questions in one message, then builds right away and reports what it decided for you. It also extends a Space you already run: a process added to it, new fields, states, views or automations, or a part rebuilt (a status select into a workflow, typed names into links), after you've seen and approved the exact list of changes. Say things like "set up our hiring process in Fibery", "build a content calendar", "track our repair shop's work orders in Fibery", "how should I model client onboarding in Fibery", "add interviews to our Hiring space", "turn Status into a workflow".
- **recipe-writer** — writes and revises recipes for the [Fibery Process Cookbook](https://github.com/Fibery-inc/process-cookbook), an open library under CC BY 4.0: a method or domain process (Shape Up, OKRs, a sales pipeline, a service desk, a volunteer rota) in plain words any tool can follow, with its complete model, the questions to ask a team, adaptation rules and its sources. Say "make a recipe for OKRs", "turn this Space into a recipe" or "add incident management to the cookbook". It builds nothing; fibery-architect builds from what it writes.
- **fibery-health** — checks a workspace, or the Spaces you name. By default it reviews the structure: copied, test and empty Spaces, databases and fields, missing descriptions (it drafts them), status kept in plain selects, wrongly typed workflow states, select options that split one value, formulas Fibery switched off or fixed to a date, text fields that should be relations, people lists that duplicate your users or still let people who left sign in, and failing, silent or never-run automations, including messages that contradict their rule. On a big workspace it starts with an overview, one line per Space, and checks in full the Spaces you pick. Ask for the data pass and it also reads how records fill their fields: unused and retired fields, missing links and owners who left, text that should be a select, dormant databases and demo data. Say "health-check our workspace", "which automations are broken", "is our workspace ready for AI agents", or, for the data pass, "check the data too", "find unused fields".

## Install

The plugin installs in Claude and in the agents below, and the skills follow the open [Agent Skills](https://agentskills.io) format, so any agent that reads skills can use them.

| Agent | Install |
| --- | --- |
| Claude and Cowork | **Customize → Plugins → Discover**, add Fibery, then connect Fibery on the plugin's **Connectors** tab |
| Claude Code | `/plugin install fibery --marketplace Fibery-inc/skills` |
| Codex CLI and the ChatGPT desktop app | `codex plugin marketplace add Fibery-inc/skills`, then `codex plugin add fibery@fibery` |
| GitHub Copilot CLI | `copilot plugin marketplace add Fibery-inc/skills`, then `copilot plugin install fibery@fibery` |
| VS Code | Command Palette → **Chat: Install Plugin From Source** → `https://github.com/Fibery-inc/skills` |
| Cursor | `git clone https://github.com/Fibery-inc/skills ~/.cursor/plugins/local/fibery`, then reload Cursor |
| Gemini CLI | `gemini extensions install https://github.com/Fibery-inc/skills` |
| Kiro | Powers → **Add Custom Power** → **Import power from GitHub** → `https://github.com/Fibery-inc/skills` |
| Any other agent | `npx skills add Fibery-inc/skills` installs the skills only; connect Fibery MCP yourself |

On Claude Code older than 2.1.275, run `claude plugin marketplace add Fibery-inc/skills`, then `claude plugin install fibery@fibery`.

## What you need

- **Fibery MCP** (`https://mcp.fibery.io/mcp`), connected to the workspace you want to work in. The plugin installs add it for you and ask you to sign in to Fibery; in Claude and Cowork, connect it on the plugin's Connectors tab. It's the server behind the Fibery connector, so if you have that connected already, you get one set of tools. fibery-architect needs a role that can create Spaces; recipe-writer uses it only to read a Space it turns into a recipe; fibery-health sees only what your role can see, so run it as a workspace admin for full coverage (applying its fixes needs Creator or Admin).
- Fibery MCP's `execute_code` tool. fibery-architect writes a handful of scripts from the design, each making a whole step's calls inside Fibery, and needs a strong reasoning model (Sonnet 5.5 or better); fibery-health gathers all its evidence with one script.

## What it changes in your workspace

fibery-architect creates new Spaces (one, or two or three when the design says why) and, unless you ask it to extend a Space, never edits existing databases or records. Three things reach outside the new Spaces, all noted in the design file it writes (`design.md`): the field each link adds to an existing database (when it isn't clear which database is the one, it asks first), the field each people field adds to every person, and an automation that writes to records of a linked database, built only when you ask for one. An extension changes only what you approved on its list: it renames, adds options and states, edits views, formulas and automations, and copies a field's values into the field that replaces it. It deletes nothing: a replaced field stays, renamed "<name> (old)", for you to delete once you've checked.

fibery-health is read-only until you approve a specific fix, and asks again for every batch. It makes only safe, reversible changes: fixing workflow state types, deleting empty databases and unused or test fields, disabling a failing rule and "Health: ..." triage views. It never deletes records. Renames, merges, conversions and repairs come back as a written plan; fibery-architect can apply its renames, conversions and repairs when you ask it to extend that Space. With your yes, it saves its report as a document in your Private space.

## What it sends and fetches

- **Fibery MCP** (`https://mcp.fibery.io/mcp`): every read and change in your workspace, under your own Fibery login and role.
- **GitHub**: fibery-architect downloads the cookbook's index and the recipe it builds from, from `raw.githubusercontent.com/Fibery-inc/process-cookbook`. Nothing from your workspace is sent.
- **placehold.co, through Fibery**: when a Space has a gallery, Fibery downloads a placeholder picture for each of its sample records, so the gallery doesn't open with blank covers. The address carries the invented record's name and a color, nothing else from your workspace.
- **Your workspace's app endpoints**: for a custom app, fibery-architect gets a developer token from Fibery MCP (it lasts about an hour and works only for the app's source files), downloads the app's code from your workspace into the working folder, and uploads the code it writes back to your workspace, which builds it. Fibery's custom-apps-dev guide, which it follows, may also check the code with a local `pnpm` build, which installs packages from the npm registry.
- **Public web pages**: recipe-writer reads one to three published sources with your agent's web search and fetch tools; fibery-architect fetches a recipe or process document you link to.
- **Your working folder**: fibery-architect writes `design.md`, `recipe.md` and a custom app's code there, recipe-writer the recipe's `<process>.md`.

Nothing else: no analytics, no other services.

## Recipes

fibery-architect looks processes up in the [Fibery Process Cookbook](https://github.com/Fibery-inc/process-cookbook) by itself: say "set up OKRs" and it builds from the cookbook's recipe. Its recipes range from a sales pipeline, OKRs, incident management and purchase requests to a phone repair shop, a custom guitar shop, a custom fiber mill, an esports team's practice and a volunteer cat-rescue program; a process without a recipe is designed from scratch. Any other recipe in the same format works the same way: attach it, or paste it or its link. Shape Up and Content calendar are copied into `skills/recipe-writer/examples/` as the models recipe-writer writes from.

## Support

Ask on the [Fibery community](https://community.fibery.io); report a security issue privately, as [SECURITY.md](SECURITY.md) says. Fibery's [privacy policy](https://fibery.com/privacy-policy) and [terms](https://fibery.com/terms) cover the workspace data these skills read and write through Fibery MCP.

## License

MIT, see [LICENSE](LICENSE). The recipes in `skills/recipe-writer/examples/` are copies from the [Fibery Process Cookbook](https://github.com/Fibery-inc/process-cookbook), licensed [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).
