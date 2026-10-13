# Reading an existing Fibery Space

When a recipe's source is a Space, in this workspace or another. Everything here is read-only: never create, change or delete anything, and never copy records into the recipe.

1. **`schema`**: find the Space and its databases.
2. **`schema_detailed`** for those databases: field types, which fields are collections, select and state values with their order, and formula text.
3. **`query_views`** with the Space: view types, databases, fields and filters; filters come back as readable descriptions.
4. **`get_reports_list`** and **`get_report`**: sources, mode and charts; a report with several tabs becomes one report per chart.
5. **`query_automations`** (`get_automations` on older servers) for each database, once for rules and once for buttons: triggers, filters and actions. A rule that runs a script can't be in a recipe, which takes simple rules only; its job becomes a shown promise or a practice.
6. **`get_custom_apps_list`**: which apps belong to the Space; describe what each shows and does, and ask the person if you can't tell.
7. **A small `query`** per database, only to see how the team uses it: which states hold records, which fields they actually fill. Then write the sample story from what you saw: the same kind of moment, with invented names and none of the records.

Then write it in the recipe's words, not Fibery's. A `fibery/decimal` is decimal, money or percent by its number format; `workflow/state` is the workflow; `fibery/user` is person or people by how many people the role holds, not by which views filter on it; a relation into another Space is a relation, or a Making it yours question when it points at something teams already track; a formula's text becomes its description in words; the Space becomes the recipe's title, and a second or third Space becomes a Who sees what line with its reason; an app is described by where it lives (a page of its own, or a tab on every record) rather than by Fibery's name for its kind.

Leave out fields nobody fills in, views nobody could need and automations that are switched off, unless the person wants them kept; and anything personal or confidential, including names, customers, record contents and a filter on one specific person.
