# Changelog

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
