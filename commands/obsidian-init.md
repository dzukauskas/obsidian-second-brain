---
description: Scan your vault and generate an index.md catalog, logs/ structure, and log.md pointer (plus _CLAUDE.md for a brand-new vault)
category: meta
triggers_en: ["init vault", "bootstrap vault", "setup vault", "scan vault"]
---

Use the obsidian-second-brain skill. Execute `/obsidian-init`:

1. Call `list_files_in_vault()` to map the full vault structure
2. Spawn parallel subagents to discover vault context simultaneously:
   - **Manual agent**: read `_CLAUDE.md` and `_DOMAIN.md` if they exist - they are authoritative for folder structure and schemas
   - **Samples agent**: read one existing note per major folder to capture naming conventions and frontmatter patterns
3. Merge all agent results into a complete picture of the vault
4. `_CLAUDE.md` handling:
   - If `_CLAUDE.md` already exists: **leave it untouched.** It is owner-maintained and authoritative. Do not show a diff, do not propose a rewrite. If the vault's reality contradicts it, mention the mismatch in the final report so the owner can update the manual.
   - Only if `_CLAUDE.md` does not exist: draft one using the template in `~/.claude/skills/obsidian-second-brain/references/claude-md-template.md`, filled with real values from the vault, show it to the owner, and write it only after approval.
5. Generate `index.md` at the vault root - a catalog of all pages organized by category:
   - List every note in the vault grouped by folder (wiki/people, wiki/genes, wiki/biomarkers, wiki/labs, etc.)
   - Skip `raw/` and `research/` contents (owner-curated and staging; list only the folders themselves with a one-line description)
   - Include a one-line description for each note (from frontmatter or first paragraph)
   - Claude reads this file FIRST when navigating the vault - cheaper and faster than searching
   - Format: `- [[Note Name]] - brief description` (ASCII hyphen, no em dashes)
6. Initialize the vault operations log:
   - Create `logs/` directory at the vault root (lowercase)
   - Write `log.md` at the vault root as a thin pointer file: explains the per-day structure, points at `logs/`, and ships the entry template (do NOT put log entries in `log.md` itself)
   - Write today's `logs/YYYY-MM-DD.md` with the init entry: `**HH:MM** - init | Vault initialized with index.md, logs/`
   - Per-day file format: frontmatter (`type: log`, `date`, `tags`, `ai-first: true`) + `**HH:MM** - action | description` entries, append-only
7. Write `index.md`, root `log.md` (pointer), and `logs/YYYY-MM-DD.md` (today's entries)
8. Confirm what was written and tell the user to restart their Claude session so the new files take effect

If `index.md` already exists: regenerate it (it's always a fresh catalog of current vault state).
If a monolithic `log.md` already exists with `## YYYY-MM-DD` sections: ask the owner before migrating; if approved, split it into `logs/YYYY-MM-DD.md` files manually (do not run `migrate_log.py` - it creates an uppercase `Logs/` folder, which this fork does not use).

---

**AI-first rule:** Every note created or updated by this command MUST follow `references/ai-first-rules.md` - `## For future Claude` preamble, rich frontmatter (`type`, `date`, `tags`, `ai-first: true`, plus type-specific fields), recency markers per external claim, mandatory `[[wikilinks]]` for every person/project/concept referenced, sources preserved verbatim with URLs inline, and confidence levels where applicable. The vault is for future-Claude retrieval - not human reading.

**Anti-fabrication:** Search exhaustively before claiming any note, person, or file is absent - false absence is the most common failure mode - and never invent facts, entities, or dates (mark unknowns as `TBD`). See the anti-fabrication and search-completeness hard rules in `references/ai-first-rules.md`.
