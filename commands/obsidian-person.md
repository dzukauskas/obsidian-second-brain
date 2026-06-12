---
description: Create or update a person note from conversation context
category: vault
triggers_en: ["save this person", "add person", "new contact note", "create person note"]
---

Use the obsidian-second-brain skill. Execute `/obsidian-person $ARGUMENTS`:

The argument is a person's name - handle typos and partial matches.

1. Read `_CLAUDE.md` first if it exists in the vault root
2. Search `wiki/people/` for an existing profile matching the name (fuzzy - handle typos and partial names)
3. If found: confirm with user, then update - new personal facts go into the `timeline:` array (`fact`, `from`, `until`, `learned`, `source`); never overwrite existing entries. Refresh `CRITICAL_FACTS.md` if an always-loaded fact changed.
4. If not found: **`wiki/people/` is family profiles only** (`relationship: self | spouse | child` - kinship, never relationship strength). Creating a new profile means a new family member - confirm with the owner before creating. External people (clinicians, authors, podcast guests) get NO person notes; attribute them inline in the relevant knowledge pages.
5. Fill in what the conversation actually stated: `relationship`, `born`, timeline facts with dates and sources - per the vault's `_DOMAIN.md` person schema
6. Update the profile's entry in `index.md` if it changed; append `**HH:MM** - person | <name> updated` to `logs/YYYY-MM-DD.md` (lowercase; create the day file with frontmatter if missing - `log.md` is a pointer, never write entries there)

If the name has a typo or is approximate, search the vault, show what was found, and confirm before proceeding. Never silently create a note with a misspelled name.

---

**AI-first rule:** Every note created or updated by this command MUST follow `references/ai-first-rules.md` - `## For future Claude` preamble, rich frontmatter (`type`, `date`, `tags`, `ai-first: true`, plus type-specific fields), recency markers per external claim, mandatory `[[wikilinks]]` for every person/project/concept referenced, sources preserved verbatim with URLs inline, and confidence levels where applicable. The vault is for future-Claude retrieval - not human reading.

**Anti-fabrication:** Search exhaustively before claiming any note, person, or file is absent - false absence is the most common failure mode - and never invent facts, entities, or dates (mark unknowns as `TBD`). See the anti-fabrication and search-completeness hard rules in `references/ai-first-rules.md`.
