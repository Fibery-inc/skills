# Fibery skills

Skills for building your processes in Fibery with an AI agent, and keeping your workspace in shape. This one repository installs as a plugin in Claude Code, Codex, GitHub Copilot, VS Code, Cursor, Gemini CLI and Kiro, and the skills follow the open [Agent Skills](https://agentskills.io) format, so any agent that reads skills can use them.

## Skills

- **fibery-architect** — turns how a team works (an idea, an interview, a process document, a recipe or an existing Space) into a ready-to-run Fibery Space in your workspace: databases, fields, relations and links to what you already track, workflows, formulas, views, reports, the automations the process depends on, a custom app where views fall short, documents and sample data. It starts from a recipe from the [Fibery Process Cookbook](https://github.com/Fibery-inc/process-cookbook) whenever one fits the process, which gives a better Space than a design from scratch. It asks its questions in one message, then builds right away and reports what it decided for you. Say things like "set up our hiring process in Fibery", "build a content calendar", "how should I model client onboarding in Fibery".
- **recipe-writer** — writes and revises recipes for the [Fibery Process Cookbook](https://github.com/Fibery-inc/process-cookbook), an open library under CC BY 4.0: a method or domain process (Shape Up, OKRs, a sales pipeline, a service desk, a volunteer rota) in plain words any tool can follow, with its complete model, the questions to ask a team, adaptation rules and its sources. Say "make a recipe for OKRs", "turn this Space into a recipe" or "add incident management to the cookbook". It builds nothing; fibery-architect builds from what it writes.
- **fibery-health** — checks a workspace, or the Spaces you name. By default it reviews the structure: copied, test and empty Spaces, databases and fields, missing descriptions (it drafts them), status kept in plain selects, wrongly typed workflow states, select options that split one value, formulas Fibery switched off or fixed to a date, text fields that should be relations, people lists that duplicate your users or still let people who left sign in, and failing, silent or never-run automations, including messages that contradict their rule. On a big workspace it starts with an overview, one line per Space, and checks in full the Spaces you pick. Ask for the data pass and it also reads how records fill their fields: unused and retired fields, missing links and owners who left, text that should be a select, dormant databases and demo data. Say "health-check our workspace", "which automations are broken", "is our workspace ready for AI agents", or, for the data pass, "check the data too", "find unused fields".

## Install

| Agent | Install |
| --- | --- |
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

- **Fibery MCP** (`https://mcp.fibery.io/mcp`), connected to the workspace you want to work in. The Codex, Copilot, VS Code, Cursor, Gemini CLI and Kiro installs add it for you and ask you to sign in to Fibery. In Claude, connect the Fibery connector; in Claude Code without it, run `claude mcp add --transport http fibery https://mcp.fibery.io/mcp`. fibery-architect needs a role that can create Spaces; recipe-writer uses it only to read a Space it turns into a recipe; fibery-health sees only what your role can see, so run it as a workspace admin for full coverage (applying its fixes needs Creator or Admin).
- Fibery MCP's `execute_code` tool. fibery-architect writes a handful of scripts from the design, each making a whole step's calls inside Fibery, and needs a strong reasoning model (Sonnet 5.5 or better); fibery-health gathers all its evidence with one script.

## What it changes in your workspace

fibery-architect creates new Spaces (one, or two or three when the design says why) and never edits existing databases or records. Three things reach outside the new Spaces, all noted in the design file it writes (`design.md`): the field each link adds to an existing database (when it isn't clear which database is the one, it asks first), the field each people field adds to every person, and an automation that writes to records of a linked database, built only when you ask for one.

fibery-health is read-only until you approve a specific fix, and asks again for every batch. It makes only safe, reversible changes: fixing workflow state types, deleting empty databases and unused or test fields, disabling a failing rule and "Health: ..." triage views. It never deletes records. Renames, merges, conversions and repairs come back as a written plan. With your yes, it saves its report as a document in your Private space.

## Recipes

fibery-architect looks processes up in the [Fibery Process Cookbook](https://github.com/Fibery-inc/process-cookbook) by itself: say "set up OKRs" and it builds from the cookbook's recipe. Any other recipe in the same format works the same way: attach it, or paste it or its link. Shape Up and Content calendar are copied into `skills/recipe-writer/examples/`: the models recipe-writer writes from, and what fibery-architect uses when it can't reach the cookbook.

## Support

Ask on the [Fibery community](https://community.fibery.io). Fibery's [privacy policy](https://fibery.com/privacy-policy) and [terms](https://fibery.com/terms) cover the workspace data these skills read and write through Fibery MCP.

## License

MIT, see [LICENSE](LICENSE). The recipes in `skills/recipe-writer/examples/` are copies from the [Fibery Process Cookbook](https://github.com/Fibery-inc/process-cookbook), licensed [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).
