---
description: Load your identity, values, priorities, and current state in one shot - with progressive context levels to avoid burning tokens
category: vault
triggers_en: ["load context", "what is going on", "where am I", "load my world"]
---

Use the obsidian-second-brain skill. Execute `/obsidian-world`:

1. Read `_CLAUDE.md` first if it exists in the vault root

2. Load context progressively - start light, go deeper only as needed:

   **L0 - Identity (~200 tokens)**
   Read these files if they exist:
   - `SOUL.md` - who the owner is, communication style, thinking preferences
   - `CRITICAL_FACTS.md` - ~150 tokens of always-needed context (family, key health facts, location)
   - `PINNED.md` - cross-session working memory, if present

   **L1 - Navigation (~1-2K tokens)**
   - Read `index.md` - the catalog of all vault pages. This tells Claude what exists without loading everything.
   - Read recent operation log (last 10 entries): today's and yesterday's `logs/YYYY-MM-DD.md`

   **L2 - Current State (~2-5K tokens)**
   - Read `TODO.md` - deferred infrastructure work and parked decisions with conditions
   - Skim `research/` staging for unreviewed findings awaiting the owner's triage

   **L3 - Deep Context (on demand, ~5-20K tokens)**
   - Only load if needed for a specific question or task
   - Read the relevant `wiki/people/` profile(s) - current facts up top, `timeline:` for history
   - Read the relevant `wiki/` knowledge pages and their `raw/` sources if the user asks about a specific topic
   - Read `_DOMAIN.md` when the task touches lab/genetic data schemas

3. Present a brief status after L0-L2 (do NOT load L3 unless needed):
   - **Who I am to you**: confirm the persona and communication style
   - **Open infrastructure work**: top items from `TODO.md`
   - **Open threads**: unfinished things from the operation log and `TODO.md`
   - **Awaiting your triage**: unreviewed `research/` staging notes
   - **Today so far**: what's already logged today

Keep output concise - this is a boot-up sequence, not a report. The user should glance at it and say "yes, Claude is up to speed" and start working immediately.

4. **Core memory pinning** - during the session, if the user is working on a specific task that requires persistent context (debugging a complex API, reviewing a long document, planning a project), Claude can PIN critical information to a `PINNED.md` file at the vault root:
   - Write task-specific facts, schemas, or reference data to `PINNED.md`
   - This file is loaded at L0 alongside SOUL.md and CRITICAL_FACTS.md
   - When the task is done, clear `PINNED.md`
   - This prevents critical session context from being lost during long conversations or context compaction
   - Claude should proactively suggest pinning when it detects the user is deep in a complex task

If identity files (SOUL.md, CRITICAL_FACTS.md) don't exist, offer to create them by asking 5-7 quick questions about the user's role, values, and communication preferences.

If `index.md` doesn't exist, offer to run `/obsidian-init` to generate it.

---

**AI-first rule:** Every note created or updated by this command MUST follow `references/ai-first-rules.md` - `## For future Claude` preamble, rich frontmatter (`type`, `date`, `tags`, `ai-first: true`, plus type-specific fields), recency markers per external claim, mandatory `[[wikilinks]]` for every person/project/concept referenced, sources preserved verbatim with URLs inline, and confidence levels where applicable. The vault is for future-Claude retrieval - not human reading.

**Anti-fabrication:** Search exhaustively before claiming any note, person, or file is absent - false absence is the most common failure mode - and never invent facts, entities, or dates (mark unknowns as `TBD`). See the anti-fabrication and search-completeness hard rules in `references/ai-first-rules.md`.
