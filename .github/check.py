import json
import pathlib
import re
import sys

import yaml

ALLOWED = {"name", "description", "license", "compatibility", "metadata", "allowed-tools"}
NAME = re.compile(r"^[a-z0-9]+(-[a-z0-9]+)*$")
MANIFESTS = ["plugin.json", ".claude-plugin/plugin.json", "gemini-extension.json"]

errors = []

for skill in sorted(pathlib.Path("skills").glob("*/SKILL.md")):
    text = skill.read_text(encoding="utf-8")
    parts = text.split("---", 2)
    if not text.startswith("---") or len(parts) < 3:
        errors.append(f"{skill}: no frontmatter")
        continue
    meta = yaml.safe_load(parts[1]) or {}
    name = str(meta.get("name", ""))
    description = str(meta.get("description", ""))
    if not NAME.match(name) or len(name) > 64 or name != skill.parent.name:
        errors.append(f"{skill}: name must be lowercase with hyphens, at most 64 characters, and match its folder")
    if not 1 <= len(description) <= 1024:
        errors.append(f"{skill}: description has {len(description)} characters; the limit is 1024")
    if len(str(meta.get("compatibility", ""))) > 500:
        errors.append(f"{skill}: compatibility is over 500 characters")
    unknown = set(meta) - ALLOWED
    if unknown:
        errors.append(f"{skill}: fields outside the Agent Skills spec: {', '.join(sorted(unknown))}")

versions = {path: json.loads(pathlib.Path(path).read_text(encoding="utf-8")).get("version") for path in MANIFESTS}
if len(set(versions.values())) > 1:
    errors.append("manifest versions differ: " + ", ".join(f"{path} {version}" for path, version in versions.items()))

for error in errors:
    print(error)
sys.exit(1 if errors else 0)
