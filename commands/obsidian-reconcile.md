---
description: Find and surface contradictions in the vault - both claims recorded, the owner decides
category: thinking
triggers_en: ["find contradictions", "reconcile vault", "fix conflicts", "vault contradictions"]
---

Use the obsidian-second-brain skill. Execute `/obsidian-reconcile $ARGUMENTS`:

The optional argument is a topic or entity to focus on. If not provided, scan the whole vault.

1. Read `_CLAUDE.md` first if it exists in the vault root
2. Read `index.md` to understand the full vault landscape

3. Spawn parallel subagents to find contradictions:
   - **Claims agent**: scan `wiki/concepts/`, `wiki/protocols/`, and `wiki/supplements/` for factual claims - find pairs that contradict each other
   - **Knowledge-page agent**: scan `wiki/genes/` and `wiki/biomarkers/` for claims that conflict with newer sources in `raw/` or `research/`
   - **Profiles agent**: scan `wiki/people/` profiles for timeline COHERENCE only - two facts asserted true at the SAME time that conflict, or broken `from`/`until` overlaps. Different `timeline:` values at different times are a TREND, not a contradiction - skip them (optionally note interesting trends in the report).
   - **Source freshness agent**: compare `raw/` source dates against `wiki/` page dates - flag wiki pages that reference old sources when newer ones exist on the same topic

4. For each candidate found, evaluate IN THIS ORDER:
   - **Is it a timeline trend?** Two values at different times (a biomarker moving, a supplement started then stopped) = NOT a contradiction. Skip or note as a trend.
   - **Is this a genuine contradiction or an evolution?** (someone changing their mind is not a contradiction - it's growth; document the evolution, don't erase it)
   - **What is each claim's evidence level?** Use the vault's enum: `stated | guideline | high | medium | speculation`. Evidence levels describe the claims - they never authorize picking a winner.

5. Document each genuine contradiction - NEVER resolve it:
   - Add a clearly marked section inside the affected page: `## Conflict - <topic> (unresolved, YYYY-MM-DD)` containing BOTH claims, each with its source (URL or `raw/` path verbatim), claim date, and evidence level
   - If two different pages disagree, add the section to both and cross-link them with `[[wikilinks]]`
   - Never rewrite either claim, never pick a winner, never delete anything
   - Never create new folders or note types (no `wiki/decisions/` - it does not exist in this vault)
   - Personal data is out of scope: `wiki/labs/`, `wiki/dna/`, and profile `timeline:` entries are never modified by this command

6. After documenting:
   - Update `index.md` entries incrementally where a page description changed (full regeneration is `/obsidian-init`'s job)
   - Append `**HH:MM** - reconcile | X contradictions surfaced, Y trends noted, Z stale references flagged` to `logs/YYYY-MM-DD.md` (lowercase; create the day file with frontmatter `type: log`, `date`, `tags`, `ai-first: true` if missing). Never write entries to `log.md` - it is a pointer file.

7. Report back to the owner:
   - **Contradictions surfaced** (both claims with sources and evidence levels - awaiting your call)
   - **Trends noted** (timeline values changing over time - not conflicts, just worth seeing)
   - **Stale references flagged** (wiki pages citing older sources - candidates for re-verification)

The vault should never contain two pages that disagree without knowing they disagree. This command documents and surfaces disagreements - inside the affected pages and in chat. The owner resolves them.

---

**AI-first rule:** Every note created or updated by this command MUST follow `references/ai-first-rules.md` - `## For future Claude` preamble, rich frontmatter (`type`, `date`, `tags`, `ai-first: true`, plus type-specific fields), recency markers per external claim, mandatory `[[wikilinks]]` for every person/project/concept referenced, sources preserved verbatim with URLs inline, and confidence levels where applicable. The vault is for future-Claude retrieval - not human reading.

**Anti-fabrication:** Search exhaustively before claiming any note, person, or file is absent - false absence is the most common failure mode - and never invent facts, entities, or dates (mark unknowns as `TBD`). See the anti-fabrication and search-completeness hard rules in `references/ai-first-rules.md`.
