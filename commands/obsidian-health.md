---
description: Run a vault health check - grouped by severity, detects contradictions, concept gaps, stale claims, and structural issues
category: meta
triggers_en: ["vault health", "check vault", "audit vault", "vault diagnostics"]
---

Use the obsidian-second-brain skill. Execute `/obsidian-health`:

1. Read `_CLAUDE.md` first to find the vault path
2. Run: `python ~/.claude/skills/obsidian-second-brain/scripts/vault_health.py --path ~/path/to/vault --json`
   (replace vault path with the one from `_CLAUDE.md`)
3. Parse the JSON output and split findings into categories
4. Spawn parallel subagents to handle each category simultaneously:
   - **Links agent**: verify broken links, attempt to resolve them
   - **Duplicates agent**: confirm duplicates are truly the same concept, not just similar names
   - **Frontmatter agent**: identify notes missing required fields by type. If the script reports a `code_fence_wrapped` note (frontmatter trapped inside a leading ```` ```markdown ```` fence), the fix is to **unwrap it** - strip the opening fence line and the matching closing ```` ``` ```` so the inner `---` frontmatter and body become real markdown. **Never add a new frontmatter block to a wrapped note** - that produces duplicate frontmatter and leaves the body trapped. If the note already has both a prepended frontmatter block and an inner wrapped one, merge them (keep the richer fields) and unwrap.
   - **Staleness agent**: check unfilled template syntax and notes that promise follow-ups which never happened
   - **Orphans agent**: check orphaned notes and empty folders. Expected noise in this vault: `raw/` files (no frontmatter by design) and `wiki/labs/`/`wiki/dna/` data notes may be flagged - the script's exclusions were tuned for the author's vault; treat those findings as informational, not errors.
   - **Contradictions agent**: scan `wiki/` knowledge pages (concepts, protocols, supplements, genes, biomarkers) for claims that conflict - report both sides per the reconcile rules, never resolve
   - **Concept gaps agent**: find terms mentioned 3+ times across different notes that lack a dedicated page - these are missing concepts the vault should have
   - **Stale claims agent**: compare `wiki/` knowledge pages against their source dates - flag any note older than 6 months that references fast-moving topics (guidelines, dosing, research consensus)
5. Merge results and group by severity:
   - 🔴 Critical: broken links, unfilled template syntax, contradictions between notes, code-fence-wrapped notes (frontmatter trapped in a fence)
   - 🟡 Warning: duplicates, stale tasks, missing frontmatter, stale claims, concept gaps
   - ⚪ Info: orphaned notes, empty folders
6. For safe fixes (missing frontmatter, unwrapping code-fence-wrapped notes, obvious duplicates, creating pages for concept gaps), offer to fix automatically. For a `code_fence_wrapped` note, unwrap the fence rather than adding frontmatter (see the Frontmatter agent note above).
7. For destructive fixes (archiving, merging, resolving contradictions), list them and ask for explicit confirmation first. Never touch `raw/`, `wiki/labs/`, or `wiki/dna/` - data notes and originals are not "fixable" by this command.
8. Append `**HH:MM** - health | X critical, Y warnings, Z info` to `logs/YYYY-MM-DD.md` (lowercase; create the day file with frontmatter if missing - `log.md` is a pointer, never write entries there)

---

**AI-first rule:** Every note created or updated by this command MUST follow `references/ai-first-rules.md` - `## For future Claude` preamble, rich frontmatter (`type`, `date`, `tags`, `ai-first: true`, plus type-specific fields), recency markers per external claim, mandatory `[[wikilinks]]` for every person/project/concept referenced, sources preserved verbatim with URLs inline, and confidence levels where applicable. The vault is for future-Claude retrieval - not human reading.

**Anti-fabrication:** Search exhaustively before claiming any note, person, or file is absent - false absence is the most common failure mode - and never invent facts, entities, or dates (mark unknowns as `TBD`). See the anti-fabrication and search-completeness hard rules in `references/ai-first-rules.md`.
