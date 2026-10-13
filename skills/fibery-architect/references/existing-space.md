# Reading an existing Fibery Space

When the source is a Space, in this workspace or another. Everything here is read-only: never create, change or delete anything, and never copy records into the design. The steps below can run as one `execute_code` script that logs what the design needs (names, types, states and options in order, view configs, rule triggers and actions, apps, how the fields are used), never whole results.

1. **`schema`**: find the Space and its databases.
2. **`schema_detailed`** for those databases: field types, which fields are collections, select and state values with their order, and formula text.
3. **`query_views`** with the Space: view types, databases, fields and filters; filters come back as readable descriptions, write them in the spec's words.
4. **`get_reports_list`** and **`get_report`**: sources, mode, tabs and expressions; a report with several tabs becomes one report per chart in the design.
5. **`query_automations`** (`get_automations` on older servers) for each database, once for rules and once for buttons: triggers, filters and actions. Describe texts in words; a rule that runs a script is noted as one the new design can't have, since designs are native actions only, and its job becomes a shown promise or a practice.
6. **`get_custom_apps_list`**: which apps belong to the Space; describe what each shows and does, and ask the person if you can't tell.
7. **A small `query`** per database, only to see how the team uses it: which states hold records, which fields they actually fill. Then invent sample data in the same shape.

Write each Fibery type in the spec's words by what it holds: a `fibery/decimal` is decimal, money or percent by its number format, `workflow/state` is the workflow, `fibery/user` is person or people, a relation to another Space's database is a link (in a design for the same workspace) or a "make it yours" note (for another), and a formula's text is its expression.

Leave out fields nobody fills in, views nobody could need and automations that are switched off, unless the person wants them kept; and anything personal or confidential, including a filter on one specific person.
