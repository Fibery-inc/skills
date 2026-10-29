# Reading an existing Fibery Space

When the source is a Space, in this workspace or another, to copy or improve as a new one, or to extend (`extend.md`). One `execute_code` script reads it and changes nothing: replace its data block with the Space's name and, in `TOUCH`, the fields whose use matters, each `{database, field}` (the states are `field: "workflow/state"`) with `match` when its values name records of another database (`f("Account")`) or users (`"fibery/user"`). For an extension, that's every field the request renames or replaces; for a copy, the fields you'd leave out if nobody fills them.

```js
const S = "Hiring"; const f = n => `${S}/${n}`;
const C = f("Candidate");
const TOUCH = [{database: C, field: f("Status")}, {database: C, field: f("Referred by"), match: "fibery/user"}, {database: C, field: f("Seniority")}];

const fails = [];
const rows = async (from, select) => (await query({query: {"q/from": from, "q/select": select, "q/limit": "q/no-limit"}})).result;
const esc = s => s.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
const short = n => n.split("/").pop(), sp = db => db.split("/")[0];
const tree = (await schema({})).schema;
const dbs = [...new Set((tree.match(new RegExp(`^\\s*${esc(S)}/[^,\\n]+(?=,)`, "gm")) || []).map(x => x.trim()))];
if (!dbs.length) throw new Error(`no Space named ${S}`);
const fields = {};
let cur = null;
for (const line of (await schema_detailed({databases: dbs})).schema.split("\n")) {
  const d = line.match(/^(\S[^:]*):/); if (d) { cur = dbs.includes(d[1]) ? d[1] : null; if (cur) fields[cur] = new Map(); continue; }
  const m = line.match(/^ {4}([^:]+): (.+?)(?: # (.*))?$/);
  if (cur && m && !/^(fibery|Collaboration~Documents)\//.test(m[1])) fields[cur].set(m[1], {type: m[2], note: m[3] || "", many: /collection/.test(m[3] || "")});
}
const isEnum = (db, x) => x.type.endsWith(`_${db}`) || x.type.startsWith("workflow/state_");
const names = {}, opts = {};
await Promise.all(dbs.flatMap(db => [...fields[db].values()].filter(x => isEnum(db, x)).map(x => rows(x.type, {id: "fibery/id", n: "enum/name", r: "fibery/rank", c: "enum/color", ...(x.type.startsWith("workflow/") ? {t: "workflow/Type"} : {i: "enum/icon"})}).then(l => { opts[x.type] = l.sort((a, b) => a.r - b.r); l.forEach(o => names[o.id] = o.n); }, e => fails.push(`${x.type}: ${String(e.message || e).slice(0, 120)}`)))));
const readable = o => JSON.stringify(o).replace(new RegExp(esc(S + "/"), "g"), "").replace(/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/g, id => names[id] || id);
const kindOf = (db, name, x) => {
  const formula = (x.note.match(/formula: (.*)$/) || [])[1];
  if (formula) return `formula ${x.type.replace("fibery/", "")} = ${formula}`;
  if (isEnum(db, x)) return `${name === "workflow/state" ? "states" : x.many ? "multi select" : "select"} ${(opts[x.type] || []).map(o => o.t && o.t !== "Started" ? `${o.n} (${o.t.toLowerCase()})` : o.n).join(", ")}`;
  if (x.type === "fibery/user") return x.many ? "people" : "person";
  if (x.type === "Collaboration~Documents/Document") return "rich text";
  if (x.type.startsWith("fibery/")) return x.type.replace("fibery/", "") + (x.many ? "s" : "");
  return `${x.many ? "links" : "link"} to ${x.type}`;
};
const deflt = x => ((x.note.match(/default: ([^;]+)$/) || [])[1] || "").replace(/^\$.*/, "");
for (const db of dbs) {
  log(`${db}: ${(await query({query: {"q/from": db, "q/select": ["q/count", "fibery/id"]}})).result} records`);
  for (const [name, x] of fields[db]) log(`  ${name.startsWith(sp(db) + "/") ? short(name) : name}: ${kindOf(db, name, x)}${deflt(x) ? ` (default ${deflt(x)})` : ""}`.slice(0, 400));
}
const views = (await query_views({space: S, withConfig: false})).views, said = {};
for (const v of views) {
  if (v.viewType === "report") {
    try { const r = (await get_report({reportId: v.id})).result; said[`report ${v.name}`] = {text: JSON.stringify([r.tabs, r.data.sources.map(s => s.filter)]), from: r.data.sources.map(s => s.database)}; log(`report ${v.name} on ${r.data.sources.map(s => short(s.database) + (s.filter ? " keeping " + readable([s.filter.expression, s.filter.params]) : "")).join(", ")}: ${readable(r.tabs.map(t => ({x: t.x, y: t.y, color: t.color, where: t.fieldConditions})).map(t => Object.fromEntries(Object.entries(t).map(([k, l]) => [k, (l || []).map(e => e.expression || e)]))))}`.slice(0, 900)); }
    catch (e) { fails.push(`report ${v.name}: ${String(e.message || e).slice(0, 120)}`); }
  } else if (["document", "custom-app"].includes(v.viewType)) log(`${v.viewType === "document" ? "document" : "app"} ${v.name}`);
  else { const c = ((await query_views({id: v.id, withConfig: true})).views[0] || {}).config || {}; said[`view ${v.name}`] = {text: JSON.stringify(c)}; log(`view ${v.name} (${v.viewType}): ${readable(c)}`.slice(0, 1500)); }
}
for (const db of dbs) for (const type of ["rule", "button"]) {
  try { for (const a of (await query_automations({automationType: type, database: db})).automations) { said[`${type} ${a.name}`] = {text: JSON.stringify([a.triggers, a.filter, a.actions])}; log(`${type} ${a.name} on ${short(db)}${a.enabled === false ? " (off)" : ""}: ${readable({when: (a.triggers || []).map(t => [t.trigger, t.args]), if: a.filter, do: (a.actions || []).map(x => [x.name, x.args])})}`.slice(0, 900)); } }
  catch (e) { fails.push(`${type}s of ${db}: ${String(e.message || e).slice(0, 120)}`); }
}
const apps = (await get_custom_apps_list({})).result.filter(a => dbs.includes(a.databaseName)).map(a => `${a.name} (tab on ${short(a.databaseName)})`);
if (apps.length) log(`apps: ${apps.join(", ")}`);
for (const t of TOUCH) {
  const x = fields[t.database] && fields[t.database].get(t.field);
  if (!x) { fails.push(`${t.field}: not in ${t.database}`); continue; }
  const ref = !x.type.startsWith("fibery/") || x.type === "fibery/user", title = x.type === "fibery/user" ? "user/name" : isEnum(t.database, x) ? "enum/name" : `${sp(x.type)}/Name`;
  const recs = await rows(t.database, {v: !ref ? t.field : x.many ? {"q/from": t.field, "q/select": {n: title}, "q/limit": "q/no-limit"} : [t.field, title]});
  const count = new Map(), each = recs.map(r => [].concat(r.v === null || r.v === undefined || r.v === "" ? [] : r.v).map(v => String(v && v.n !== undefined ? v.n : v)));
  each.forEach(vals => vals.forEach(v => count.set(v, (count.get(v) || 0) + 1)));
  const top = [...count].sort((a, b) => b[1] - a[1]), filled = each.filter(v => v.length).length;
  log(`${short(t.field)} on ${short(t.database)}: ${filled} of ${recs.length} records filled, ${count.size} values: ${top.slice(0, 15).map(([v, n]) => `${v} ${n}`).join(", ")}${top.length > 15 ? ", …" : ""}`.slice(0, 600));
  if (opts[x.type]) log(`  options: ${opts[x.type].map(o => `${o.n} ${o.c}${o.t ? " " + o.t : ""}${o.i ? " " + o.i : ""}`).join(", ")}`);
  if (t.match) {
    const known = new Set((t.match === "fibery/user" ? (await rows("fibery/user", {n: "user/name", e: "user/email"})).flatMap(u => [u.n, u.e]) : (await rows(t.match, {n: `${sp(t.match)}/Name`})).map(r => r.n)).map(n => String(n).trim().toLowerCase()));
    const hit = v => known.has(v.trim().toLowerCase()), miss = top.filter(([v]) => !hit(v));
    log(`  against ${t.match}: ${each.filter(v => v.length && v.every(hit)).length} of ${filled} records match by name${miss.length ? `; no match: ${miss.slice(0, 15).map(([v, n]) => `${v} (${n})`).join(", ")}` : ""}`);
  }
  const s = t.field === "workflow/state" ? "State" : short(t.field), word = /^\w+$/.test(s) && new RegExp(`\\b${s}\\b`);
  const used = [
    ...Object.entries(said).filter(([, y]) => (!y.from || y.from.includes(t.database)) && (y.text.includes(`"${t.field}"`) || y.text.includes(`${t.field} ->`) || y.text.includes(`[${s}]`) || (y.from && y.text.includes(`"field":"${s}"`)))).map(([k]) => k),
    ...dbs.flatMap(db => [...fields[db]].filter(([, y]) => /formula:/.test(y.note) && (y.note.includes(`[${s}]`) || (word && word.test(y.note)))).map(([n]) => `formula ${db === t.database ? "" : short(db) + "."}${short(n)}`))
  ];
  log(`  used by: ${used.join(", ") || "nothing in the Space"}${apps.length ? "; apps not checked: " + apps.join(", ") : ""}`);
}
log(`failed ${fails.length}`); fails.forEach(x => log("FAIL " + x));
```

It logs each database with its record count and its fields: types, states (marked "not started" and "finished") and options in order, defaults and formula expressions; each view's config with names in place of ids; each report's source filter, axes and conditions; each rule and button with its triggers, filter and actions, "(off)" when switched off; the apps that are tabs on its databases (a page app is listed with the views). For a field in `TOUCH`: how many records fill it and with what, its options with their colors and emojis, how many of its records match by name, which values match nothing, and what in the Space uses it. A page app's code isn't read: describe what it shows and does, and ask the person if you can't tell.

Write each Fibery type in the spec's words by what it holds: a `fibery/decimal` is decimal, money or percent by its number format, `workflow/state` is the workflow, `fibery/user` is person or people, a relation to another Space's database is a link (in a design for the same workspace) or a "make it yours" note (for another), a formula's text is its expression, a report's chart and metric tabs stay tabs of one report, reports on the same database become one, the records a report's source keeps are its filter, and a table tab becomes a view. Describe texts in words; a rule that runs a script is noted as one the new design can't have, since designs are native actions only, and its job becomes a shown promise or a practice. Never copy records into the design: invent sample data in the same shape.

Leave out fields nobody fills in, views nobody could need and automations that are switched off, unless the person wants them kept; and anything personal or confidential, including a filter on one specific person.
