---
description: Save everything worth keeping from this conversation to the vault
category: vault
triggers_en: ["save this", "save the conversation", "save to vault", "obsidian save"]
---

Use the obsidian-second-brain skill. Execute `/obsidian-save`:

1. Read `_CLAUDE.md` first if it exists in the vault root
2. Scan the entire conversation and identify the durable items, by the fork's routing:
   - **Family facts**: anything personal about a family member (symptom, value, supplement started/stopped, diagnosis, history)
   - **Knowledge**: claims about genes, biomarkers, supplements, protocols, concepts - each with its source, claim date, and evidence level (`stated | guideline | high | medium | speculation`)
   - **Personal data**: lab values or genetic variants stated in the conversation
   - **Everything else** (tasks, decisions about the vault itself, loose ideas): goes to the final report only - tasks live in the owner's `TODO.md`, vault-infrastructure decisions live in git commit messages; do not write them anywhere
3. Spawn parallel subagents - one per group present in the conversation:
   - **Family facts agent**: append `timeline:` entries to the person's profile in `wiki/people/` (`fact`, `from`, `until`, `learned`, `source`) - never overwrite existing entries; refresh `CRITICAL_FACTS.md` if an always-loaded fact changed. External people (authors, clinicians mentioned, podcast guests) get NO person notes - `wiki/people/` is family profiles only; attribute them inline in knowledge pages.
   - **Knowledge agent**: search the matching `wiki/` knowledge folder first; update existing pages smarter (history preserved) or create new AI-first pages; `[[wikilinks]]` mandatory
   - **Data agent**: lab values -> `wiki/labs/YYYY-MM-DD - Name - test.md` (`type: lab-result`), genetic variants -> append to the `wiki/dna/` person+platform note - both append-only per the vault's `_DOMAIN.md`; never edit an existing data note
4. After all agents complete:
   - Update `index.md` incrementally for any created note (full regeneration is `/obsidian-init`'s job)
   - Append `**HH:MM** - save | X created, Y updated, Z timeline appends` to `logs/YYYY-MM-DD.md` (lowercase; create the day file with frontmatter `type: log`, `date`, `tags`, `ai-first: true` if missing). Never write entries to `log.md` - it is a pointer file.
5. Report back: a clean list of what was saved and where, plus the unfiled items (actionables for `TODO.md`, anything needing new structure - propose, never create unprompted)

Search before creating anything - duplicate notes are vault rot. If an item's routing is genuinely ambiguous (e.g. a fact about a person not in `wiki/people/`), ask the owner instead of guessing.

---

**AI-first rule:** Every note created or updated by this command MUST follow `references/ai-first-rules.md` - `## For future Claude` preamble, rich frontmatter (`type`, `date`, `tags`, `ai-first: true`, plus type-specific fields), recency markers per external claim, mandatory `[[wikilinks]]` for every person/project/concept referenced, sources preserved verbatim with URLs inline, and confidence levels where applicable. The vault is for future-Claude retrieval - not human reading.

**Anti-fabrication:** Search exhaustively before claiming any note, person, or file is absent - false absence is the most common failure mode - and never invent facts, entities, or dates (mark unknowns as `TBD`). See the anti-fabrication and search-completeness hard rules in `references/ai-first-rules.md`.
