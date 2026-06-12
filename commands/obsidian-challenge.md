---
description: Red-team your current idea against your own vault history - finds contradictions, past failures, and flawed assumptions
category: thinking
triggers_en: ["challenge this", "grill me on this", "red team my idea", "stress test this"]
---

Use the obsidian-second-brain skill. Execute `/obsidian-challenge $ARGUMENTS`:

The optional argument is the idea, belief, or plan to challenge. If not provided, infer the user's current position from conversation context.

1. Read `_CLAUDE.md` first if it exists in the vault root
2. Identify the user's current claim, plan, or assumption - either from the argument or from recent conversation
3. Extract the key premises behind that position
4. Search the vault for counter-evidence - spawn parallel subagents:
   - **Knowledge agent**: search `wiki/` pages (concepts, protocols, supplements, genes, biomarkers) for claims and evidence levels that cut against the position
   - **History agent**: search `logs/`, `brainstorms/`, and `TODO.md` decision notes for past reasoning, reversals, or lessons related to this topic
   - **Contradictions agent**: search for `## Conflict` sections and notes where the user held the opposite position or flagged risks about this exact approach; check profile `timeline:` entries for personal data that contradicts the plan
5. Synthesize a structured "Red Team" analysis:
   - **Your position**: restate the claim clearly
   - **Counter-evidence from your vault**: cite specific notes, dates, and quotes
   - **Blind spots**: what the user might be ignoring based on their own history
   - **Verdict**: is this position consistent with past experience, or does the vault suggest caution?
6. Append `**HH:MM** - challenge | <topic> red-teamed` to `logs/YYYY-MM-DD.md` (lowercase; `log.md` is a pointer - never write entries there)

Do not be agreeable. The entire point is to pressure-test. Cite specific vault files. If you find nothing contradictory, say so honestly - but search thoroughly first.

---

**AI-first rule:** Every note created or updated by this command MUST follow `references/ai-first-rules.md` - `## For future Claude` preamble, rich frontmatter (`type`, `date`, `tags`, `ai-first: true`, plus type-specific fields), recency markers per external claim, mandatory `[[wikilinks]]` for every person/project/concept referenced, sources preserved verbatim with URLs inline, and confidence levels where applicable. The vault is for future-Claude retrieval - not human reading.

**Anti-fabrication:** Search exhaustively before claiming any note, person, or file is absent - false absence is the most common failure mode - and never invent facts, entities, or dates (mark unknowns as `TBD`). See the anti-fabrication and search-completeness hard rules in `references/ai-first-rules.md`.
