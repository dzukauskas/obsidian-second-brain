---
description: Review vault learnings, prune stale ones, surface active patterns - the vault's lessons compound or expire
category: thinking
triggers_en: ["review learnings", "what have I learned", "show lessons", "prune learnings"]
---

Use the obsidian-second-brain skill. Execute `/obsidian-learn $ARGUMENTS`:

The optional argument is a scope: `recent` (last 30 days, default), `all` (entire vault), or a topic name.

1. Read `_CLAUDE.md` first if it exists in the vault root
2. Read `index.md` and recent operation log for vault context (read the last 2-3 `logs/YYYY-MM-DD.md` files)

3. Spawn parallel subagents to gather learnings:

   - **Lessons agent**: scan `logs/` and `brainstorms/` for lessons, reversals, and decided questions
   - **Decisions agent**: read decision rationale in `TODO.md` (parked decisions with conditions) and recent git commit messages (the vault's decision log) - extract the rationale and outcome of each
   - **Reports agent**: read recent emerge/synthesize/connect/challenge reports in `wiki/concepts/` (the generated pattern reports)
   - **Mistakes agent**: scan `logs/` and `brainstorms/` for "what didn't work", "wasted time on", "next time", "lesson", phrases indicating learning from failure
   - **Wins agent**: scan for patterns that worked - "this saved time", "this approach worked", recurring success patterns

4. For each learning found, classify:
   - **Active**: still relevant, recurring, reinforced by recent activity
   - **Stale**: 6+ months old with no recent reinforcement, or contradicted by newer evidence
   - **Superseded**: explicitly replaced by a newer ADR or pattern
   - **Promoted**: appeared 3+ times - should become a permanent rule in `_CLAUDE.md`

5. Generate the Learnings Report:

   ## Active Learnings (still applies)
   - List learnings reinforced in the last 90 days
   - Cite the original source and most recent reinforcement

   ## Stale Learnings (consider archiving)
   - List learnings with no recent reinforcement
   - Suggest: keep, archive, or convert to history note

   ## Superseded Learnings (already replaced)
   - Old position -> New position, with the source of the change (commit, brainstorm, TODO entry)

   ## Promotion Candidates (appeared 3+ times)
   - Learnings strong enough to become permanent rules in `_CLAUDE.md`
   - Suggest exact wording for the operating manual

   ## Top 5 Lessons of the Period
   - Most impactful learnings ranked by frequency × recency × consequence

6. Save the report to `wiki/concepts/YYYY-MM-DD - Learnings Review.md` (ASCII hyphen, no em dashes)
7. Append `**HH:MM** - learn | X active, Y stale, Z superseded, N promotion candidates` to `logs/YYYY-MM-DD.md` (lowercase; `log.md` is a pointer - never write entries there)
8. Offer to:
   - Promote candidates to `_CLAUDE.md` (with user confirmation)
   - Flag stale learnings for the owner to archive (the agent never archives or deletes)

Lessons that aren't reviewed don't compound. This command turns scattered notes into a living rulebook.

---

**AI-first rule:** Every note created or updated by this command MUST follow `references/ai-first-rules.md` - `## For future Claude` preamble, rich frontmatter (`type`, `date`, `tags`, `ai-first: true`, plus type-specific fields), recency markers per external claim, mandatory `[[wikilinks]]` for every person/project/concept referenced, sources preserved verbatim with URLs inline, and confidence levels where applicable. The vault is for future-Claude retrieval - not human reading.

**Anti-fabrication:** Search exhaustively before claiming any note, person, or file is absent - false absence is the most common failure mode - and never invent facts, entities, or dates (mark unknowns as `TBD`). See the anti-fabrication and search-completeness hard rules in `references/ai-first-rules.md`.
