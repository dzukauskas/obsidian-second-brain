---
description: Automatic synthesis - scans the vault for unnamed patterns and writes synthesis pages without being asked
category: thinking
triggers_en: ["synthesize", "auto-synthesis", "make synthesis notes", "find unnamed patterns"]
---

Use the obsidian-second-brain skill. Execute `/obsidian-synthesize`:

This command can run manually or as a scheduled agent. It thinks for you.

1. Read `_CLAUDE.md` first if it exists in the vault root
2. Read `index.md` to understand all existing pages
3. Read recent operation log: the last 2-3 `logs/YYYY-MM-DD.md` files

4. Scan for synthesis opportunities - spawn parallel subagents:

   - **Cross-source agent**: read sources added to `raw/` and findings in `research/` in the last 7 days. Find concepts that appear in 2+ unrelated sources. If the same mechanism shows up in a guideline AND an article AND a podcast - that's a synthesis candidate.

   - **Cross-domain agent**: scan `wiki/` knowledge pages (genes, biomarkers, supplements, protocols, concepts) for entities that appear together in multiple contexts but have no explicit connection page - e.g. a gene and a biomarker repeatedly co-mentioned without a page linking them.

   - **Concept evolution agent**: scan `wiki/concepts/` for ideas that have been updated 3+ times. Track how the concept evolved - write a "Concept Evolution" section showing the timeline of how the user's thinking changed.

   - **Orphan rescue agent**: find notes in `wiki/` with no incoming links that contain claims or ideas that SHOULD be linked to existing pages. Create the missing links and explain why.

5. For each synthesis found:
   - Create `wiki/concepts/Synthesis - Title.md` (ASCII hyphen) with:
     ```yaml
     ---
     date: YYYY-MM-DD
     tags:
       - concept
       - synthesis
     auto_generated: true
     ---
     ```
   - Document: what pattern was found, which sources/notes it came from (with links), what it means, and a suggested action
   - Link the synthesis page FROM all the source notes it references

6. Update `index.md` with new synthesis pages (incrementally - regeneration is `/obsidian-init`'s job)
7. Append `**HH:MM** - synthesize | X synthesis pages created, Y orphans rescued, Z connections found` to `logs/YYYY-MM-DD.md` (lowercase; `log.md` is a pointer - never write entries there)

This command IS the user's explicit ask for synthesis - creating the pages here is consented. Outside this command, synthesis is suggested, never auto-created (see SKILL.md Synthesis Hook). Personal data (`wiki/labs/`, `wiki/dna/`, profile `timeline:`) is read for patterns but never modified.

---

**AI-first rule:** Every note created or updated by this command MUST follow `references/ai-first-rules.md` - `## For future Claude` preamble, rich frontmatter (`type`, `date`, `tags`, `ai-first: true`, plus type-specific fields), recency markers per external claim, mandatory `[[wikilinks]]` for every person/project/concept referenced, sources preserved verbatim with URLs inline, and confidence levels where applicable. The vault is for future-Claude retrieval - not human reading.

**Anti-fabrication:** Search exhaustively before claiming any note, person, or file is absent - false absence is the most common failure mode - and never invent facts, entities, or dates (mark unknowns as `TBD`). See the anti-fabrication and search-completeness hard rules in `references/ai-first-rules.md`.
