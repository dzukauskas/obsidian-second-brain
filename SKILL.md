---
name: obsidian-second-brain
description: >
  Operate the family health OS Obsidian vault (zukauskenOS layout - a medical domain
  fork of obsidian-second-brain). Use this skill when the user asks Claude to read,
  write, update, search, or manage their Obsidian vault - including ingesting lab
  results or genetic data, updating family member profiles, maintaining knowledge
  pages (genes, biomarkers, supplements, protocols, concepts), logging operations to
  logs/, running a vault health check, or generating the index.md catalog. Writes
  follow the vault's _CLAUDE.md: append-only data notes, bi-temporal timeline:
  facts, contradictions surfaced to the owner (never auto-resolved), new structure
  only with owner approval. Do not save proactively - when a conversation produces
  durable facts, offer once to file them and let the user decide.
---

# Obsidian Second Brain

> Claude operates your Obsidian vault as a living knowledge base - this is a medical domain fork of the upstream skill (an evolution of [Karpathy's LLM Wiki pattern](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)).
> Knowledge pages get smarter with every source. Personal health data is append-only and bi-temporal. Contradictions are surfaced to the owner, never auto-resolved. Updates propagate only within the owner-approved structure.

---

## Quick Start

### 0. Choose vault access method (in order of preference)

Try these methods in order. Use the first one available:

**Method 0 - SessionStart hook (if configured):**
If `hooks/load_vault_context.py` is wired as a SessionStart hook in `~/.claude/settings.json`, `_CLAUDE.md` is injected into context automatically at session start. Skip step 1 below.
To wire it: `bash scripts/setup.sh "/path/to/vault"` or run `/obsidian-setup`.

**Method A - MCP server (`mcp-obsidian`):**
If the MCP tools (`get_file_contents`, `list_files_in_vault`, `search`, `append_content`, `write_file`) are available, use them.

**Method B - Direct filesystem (fallback, always works):**
Use standard file tools (Read, Write, Edit, Glob) against the vault path. The vault is plain markdown - all operations work without MCP, just more verbosely.

If MCP is not installed, silently use filesystem access. Tell the user ONCE (first time only):

> "For faster vault access on large vaults, consider installing mcp-obsidian: `claude mcp add obsidian-vault -s user -- npx -y mcp-obsidian \"/path/to/your/vault\"`. Everything works without it."

### 1. First time in a vault → read `_CLAUDE.md`

Before doing anything in a vault, check if `_CLAUDE.md` exists at the vault root:

```
get_file_contents("_CLAUDE.md")
```

If it exists: follow its rules exactly - they override the defaults in this skill. Where `_CLAUDE.md` is silent, fall back to the defaults below.
If it doesn't exist: use the defaults in this skill, then offer to create one.

If the SessionStart hook is active, `_CLAUDE.md` is already in context - skip this step.

### 2. First time with a new user → run discovery

```
list_files_in_vault()
```

Scan the structure to understand: folder names, template locations, naming conventions, frontmatter patterns. Then read 2-3 existing notes with `get_file_contents(path)` to calibrate writing style before creating anything new.

### 3. Set up on a new machine

This fork is preconfigured for the Family Health OS (zukauskenOS) layout - see
`references/vault-schema.md`. New machine setup:

```bash
git clone https://github.com/dzukauskas/obsidian-second-brain ~/.claude/skills/obsidian-second-brain
bash ~/.claude/skills/obsidian-second-brain/scripts/setup.sh "/path/to/vault"
```

The vault travels separately (its own repo / backup) and carries its authoritative
`_CLAUDE.md` and `_DOMAIN.md` with it.

For a genuinely new, empty vault: create the folder skeleton by hand following
`references/vault-schema.md`, then run `/obsidian-init` to generate `index.md` +
`logs/` and draft a `_CLAUDE.md` from `references/claude-md-template.md`.

The upstream `scripts/bootstrap_vault.py` presets (default/executive/builder/
creator/researcher) scaffold the author's generic layouts and are NOT used by this
fork (see `DELTAS.md`).

---

## Core Operating Principles

### AI-first vault rule (applies to every note)
The vault is designed for **future-Claude** to read and reason over, not for human review. Every note Claude writes - across all 18 commands - must follow `references/ai-first-rules.md`:

1. **Self-contained context** - each note explains itself; don't rely on backlinks alone
2. **"For future Claude" preamble** - 2-3 sentence summary so Claude can decide relevance in 10 seconds
3. **Rich, consistent frontmatter** - `type`, `date`, `tags`, `ai-first: true`, plus type-specific fields (see `ai-first-rules.md` for schemas per note type)
4. **Recency markers per claim** - "Mem0 raised $24M (as of 2026-04, mem0.ai)" so future-Claude knows what to verify
5. **Sources preserved verbatim** - every external claim has its source URL inline
6. **Cross-links mandatory** - every person/project/idea/decision uses `[[wikilinks]]`
7. **Confidence levels** - `stated | high | medium | speculation` where applicable

This rule lives in `_CLAUDE.md` Section 0 of every vault using this skill, and in `references/ai-first-rules.md` (the canonical specification with frontmatter schemas + preamble templates per note type).

### Never create in isolation
Every write operation must ask: *where else does this belong?*

| You create/update... | Also update... |
|---|---|
| A lab data note (`wiki/labs/`) | Person profile `timeline:` (append), `index.md`, `logs/YYYY-MM-DD.md` |
| A health fact stated in conversation | Person profile `timeline:` (append, never overwrite), `CRITICAL_FACTS.md` if it changes an always-loaded fact |
| A knowledge page (gene, biomarker, supplement, protocol, concept) | `[[wikilinks]]` to/from related pages, `index.md`, `logs/` |
| A research finding | `research/` staging only - `wiki/` and `raw/` only after owner approval |
| Any vault write | operation log `logs/YYYY-MM-DD.md`, `index.md` (update if a note was created) |

Always propagate within the approved structure. Never create a single orphaned note - and never create new folders to propagate into (propose them to the owner instead).

### Bi-temporal facts - never overwrite, always append
When a fact changes (a biomarker value, a supplement started or stopped, a symptom, a status), NEVER delete the old value. Add a new entry to the `timeline:` frontmatter array with both event time AND transaction time:

```yaml
timeline:
  - fact: "ferritin 60 ug/L"
    from: 2026-01-15            # event time: when it was true
    until: 2026-06-01
    learned: 2026-01-20         # transaction time: when the vault learned it
    source: "raw/labs/2026-01-15-cbc.md"
  - fact: "ferritin 85 ug/L"
    from: 2026-06-01
    until: present
    learned: 2026-06-10
    source: "raw/labs/2026-06-01-cbc.md"
```

This is especially non-negotiable for health facts: old value + new value together show a TREND - the most valuable signal in the vault. "Supersede" rewrites are forbidden for health facts even if a command asks for them.

This enables:
- Historical queries ("what was the ferritin level in January?")
- Trend reasoning ("ferritin rising since starting iron protocol")
- Smart reconciliation (different values at different times = not a contradiction)
- Full audit trail (when did the vault learn each fact, from what source?)

### CRITICAL_FACTS.md - always loaded
A tiny file (~150 tokens) loaded alongside `SOUL.md` at L0 in every session. Contains facts needed in every conversation (family members and key health context, location/timezone, anything true RIGHT NOW and relevant to every interaction).

It is a DERIVED copy: the canonical source of personal facts is the `wiki/people/` profile. When a fact changes, update the profile first (old value goes to `timeline:`), then refresh `CRITICAL_FACTS.md` to match. Keep it under 150 tokens.

### Raw is immutable and owner-curated
The `raw/` folder contains original sources (articles, books, guidelines, lab reports, DNA exports). Claude reads these but NEVER writes or modifies them. They are the source of truth: if a wiki page gets corrupted, re-derive it from the raw source. Originals enter `raw/` through the owner - the agent distills a source into `raw/` only when the owner explicitly asks (e.g. promoting a verified finding from `research/`). The `raw/` subfolder set is fixed by the owner; never create new subfolders.

### Maintain `index.md` and `log.md`
Two structural files that keep the vault navigable and auditable:

- **`index.md`** - A catalog of all vault pages organized by category. Claude reads this FIRST when navigating the vault instead of searching - faster and cheaper on tokens. Update it whenever a new note is created or deleted. Format: `- [[Note Name]] - brief description` (ASCII hyphen) grouped under folder headings.

- **`log.md`** - A thin pointer file at the vault root. It explains the per-day log structure and points at `logs/`. Never write entries into `log.md` itself.

### Per-day operation logs
This fork always uses the split log structure, lowercase:

- **`logs/YYYY-MM-DD.md`** - one file per day, append-only. Format: `**HH:MM** - action | description`, with frontmatter (`type: log`, `date`, `tags`, `ai-first: true`).
- Never delete or rewrite log entries - only append. Overwriting `logs/` files is blocked by the vault's write guard.

To refresh the stats block in `index.md` after bulk writes: run `python scripts/vault_stats.py --vault <path>`.

### The vault is a living system - with append-only zones
The vault is not a filing cabinet, but "living" means different things in different zones:
- **Knowledge pages** (`wiki/` genes, biomarkers, supplements, protocols, concepts) get REWRITTEN smarter with new context - more connected, more current, history preserved
- **Personal data** (`wiki/labs/`, `wiki/dna/`, profile `timeline:` entries) is APPEND-ONLY - the history IS the signal, never rewrite it
- **Contradictions** between sources get documented with both sides and surfaced to the owner - never silently resolved
- **Stale external claims** get flagged with their dates so the owner knows what to re-verify

The vault after an ingest should be DIFFERENT - not just bigger. If knowledge pages aren't smarter and more connected, the ingest wasn't deep enough.

### Two-Output Rule (within the approved structure)
An interaction that produces durable insight should consider two outputs:
1. **The answer** - what the user sees in the conversation
2. **A vault update** - the insight filed into the relevant note(s)

File directly when the update is clearly in-structure (a health fact appended to a profile `timeline:`, a knowledge page made smarter, an operation logged). When the insight would require NEW structure (a folder, a note type), propose it to the owner instead - never create structure unprompted.

### Synthesis Hook
When Claude notices a pattern during any operation (ingest, query, study session), suggest a synthesis page in `wiki/concepts/`. Patterns include:
- The same concept appearing in 3+ unrelated sources
- A claim being reinforced by multiple independent sources
- A trend emerging across time-sequenced notes
- Two entities sharing unexpected connections

Synthesis pages connect dots the user hasn't connected yet. Create one directly only when the user agreed or explicitly asked for synthesis; always log it in `logs/`.

### Reconciliation - surface, never auto-resolve
The vault should never contain two pages that disagree without knowing they disagree. When contradictions are found (during ingest, health checks, or queries):
- **Personal values at different times are NOT contradictions** - they are a `timeline:` trend
- **Genuine knowledge contradictions**: record BOTH claims with sources, dates, and evidence levels, and surface them to the owner - never pick a "winner" and rewrite the loser, even if a command suggests it

### Save offers - no nagging
When a conversation produces durable facts (a health fact, a decision, a verified source), offer ONCE to file them into the vault. Never push, never repeat the offer, never save the conversation proactively. Unprompted writes are limited to the routine propagation above (logs, index, timeline append during an operation the user requested).

### Search before creating
Before creating any new note, search for an existing one:
```
search(query="keyword from title")
```
Duplicate notes are vault rot. Merge or update instead of creating new.

### Never claim absence from memory, never fabricate
Two failure modes corrupt the vault silently:
- **False absence (most common):** never say "no note exists" or create a note on the assumption none exists without searching exhaustively first - by every plausible name, alias, and folder, listing and grepping, not from memory. When in doubt, over-include and label the uncertainty.
- **Fabrication:** never invent facts, entities, rates, dates, or relationships that were not actually stated. Mark unknowns as `TBD`; an empty section is correct when nothing was said. External claims carry a source URL + recency marker; inferences carry a confidence level.

See the anti-fabrication and search-completeness hard rules in `references/ai-first-rules.md`.

### Match the vault's voice
Read existing notes in the same folder before writing new ones.
Match: frontmatter schema, heading style, list formatting, tone, emoji usage (or lack of it).
Never introduce new conventions - extend what's already there.

### Frontmatter is mandatory
Every note gets frontmatter. At minimum:
```yaml
---
date: 2026-03-24
tags:
  - <note-type>
---
```
See `references/vault-schema.md` for full frontmatter specs by note type.

---

## Write Rules

See `references/write-rules.md` for the complete guide. Summary:

- **Links**: Use `[[Note Name]]` for internal links. In long-lived `wiki/` notes always link people, genes, biomarkers, supplements, protocols, and concepts.
- **Dates**: ISO format (`YYYY-MM-DD`) everywhere - frontmatter, `timeline:` entries, body text.
- **Naming**: `YYYY-MM-DD - Title.md` for dated notes (ASCII hyphen). `Title.md` for evergreen notes. **No em dashes or curly quotes in content or filenames.** Lithuanian letters are always preserved.
- **Schema tokens**: fixed enums live in the vault (`_CLAUDE.md` 0.1, `_DOMAIN.md`); never translate, inflect, or invent them. Unknown values are `TBD`.

---

## The `_CLAUDE.md` File

This is the most important concept in this skill.

`_CLAUDE.md` lives at the vault root and persists Claude's operating rules across every session and every surface (Claude Desktop, Claude Code, VS Code, terminal). Without it, Claude has to re-learn your vault conventions every conversation.

**Precedence rule:** `_CLAUDE.md` wins on all vault-specific rules (folder names, naming conventions, frontmatter fields, auto-save behavior, private folders). The defaults in this skill file apply only where `_CLAUDE.md` is silent. Never let skill defaults override an explicit `_CLAUDE.md` rule.

**What it contains:**
- Your vault's folder map and what each folder is for
- Frontmatter schemas for your specific note types
- Naming conventions you use
- What to auto-save vs. what to ask first
- People and projects that need special handling
- Links to key files (boards, dashboard, templates)

To generate a `_CLAUDE.md` for an existing vault, run vault discovery then use the template in `references/claude-md-template.md`.

To install it: write the file to the vault root. Every Claude session that starts in that vault should read it first.

---

## Common Operations

### Save info from conversation
When a conversation produces something vault-worthy (and the user agreed to save):
1. Identify the note type (health fact → profile `timeline:`, knowledge → the matching `wiki/` page, raw research finding → `research/`)
2. Check if a relevant note already exists (search first - duplicates are vault rot)
3. Write or update - always frontmatter-first, AI-first structure for long-lived notes
4. Propagate per the table above: wikilinks, `index.md`, `logs/`

### Record a health observation
A symptom, a supplement started or stopped, a medication, an illness:
1. Append a `timeline:` entry to the person's profile in `wiki/people/` (`fact`, `from`, `until: present`, `learned`, optional `source`)
2. Never overwrite previous entries - close the old one's `until:` if it stopped being true
3. Refresh `CRITICAL_FACTS.md` if the fact is always-loaded
4. Log the operation in `logs/YYYY-MM-DD.md`

### Log an operation
Append `**HH:MM** - action | description` to `logs/YYYY-MM-DD.md`. If it's the day's first entry, create the file with frontmatter (`type: log`, `date`, `tags`, `ai-first: true`). Root `log.md` is a pointer - never write entries there.

### Ingest a lab report
1. The original lives in `raw/labs/` (placed by the owner, or distilled there on the owner's explicit ask)
2. Create the data note `wiki/labs/YYYY-MM-DD - Name - test.md` (`type: lab-result`) - append-only, never edit an existing lab note
3. Append notable values to the person's profile `timeline:`
4. Knowledge about the markers lives in `wiki/biomarkers/` - no personal values there
5. Update `index.md`, log the ingest in `logs/`

### Run vault health check
```bash
python scripts/vault_health.py --path ~/path/to/vault
```
Reports: duplicate notes, orphaned files (no incoming links), stale tasks (overdue), empty folders, broken links, notes missing frontmatter.

Proactively suggest running this when the user says the vault feels messy, notes are hard to find, they mention duplicates, or they haven't mentioned a health check in a long time. Offer: *"Want me to run a vault health check?"*

---

## Commands

These slash commands can be used in any Claude surface. Each one is smart - it reads context, searches before writing, and propagates everywhere changes belong.

**Name matching:** If a name argument has a typo or is approximate, search the vault for the closest match, show what was found, and confirm with the user before proceeding. Never silently create a note with a misspelled name.

---

### `/obsidian-save`

**The master save command.** Reads the entire conversation and files the durable items per the fork's routing.

Parallel subagents route: family facts -> profile `timeline:` appends in `wiki/people/` (external people get NO person notes - attribute inline); knowledge claims -> the matching `wiki/` knowledge pages (updated smarter, source + date + evidence level per claim); personal lab values / variants -> append-only `wiki/labs/` / `wiki/dna/` data notes per the vault's `_DOMAIN.md`. Tasks and loose ideas are NOT filed - they surface in the report (tasks live in the owner's `TODO.md`). `index.md` updated incrementally; log entry to `logs/YYYY-MM-DD.md`. Genuinely ambiguous routing -> ask the owner, never guess.

---

### `/obsidian-person [name]`

**Updates a family profile in `wiki/people/`.**

Fuzzy-searches `wiki/people/` and confirms the match. New personal facts append to the profile's `timeline:` (never overwrite); `CRITICAL_FACTS.md` refreshed if an always-loaded fact changed. `wiki/people/` is family profiles only (`relationship: self|spouse|child` - kinship, never strength): creating a new profile means a new family member and needs the owner's confirmation; external people get no person notes (attribute inline in knowledge pages). Updates `index.md` and logs to `logs/YYYY-MM-DD.md`.

---

### `/obsidian-find [query]`

**Smart vault search.**

Steps:
1. Run `search(query="...")` with the provided query
2. Also try variations if results are sparse (synonyms, related terms)
3. Return results with context: note title, folder, a relevant excerpt, and what type of note it is
4. If results are ambiguous, group them by type (people, biomarkers, genes, supplements, protocols, concepts, data notes)
5. Offer to open, update, or link any of the found notes

Do not just return filenames - return enough context for the user to act.

---

### `/obsidian-health`

**Runs a vault health check and summarizes findings.**

Steps:
1. Run: `python scripts/vault_health.py --path ~/path/to/vault --json`
2. Parse the JSON output and split findings into categories
3. Spawn parallel subagents to handle each category simultaneously:
   - **Links agent**: verify broken links, attempt to resolve them
   - **Duplicates agent**: confirm duplicates are truly the same concept, not just similar names
   - **Frontmatter agent**: identify notes missing required fields by type
   - **Staleness agent**: check unfilled template syntax and unkept follow-up promises
   - **Orphans agent**: check orphaned notes and empty folders (expected noise: `raw/` and data notes - the script's exclusions were tuned for the author's vault)
   - **Contradictions agent**: scan `wiki/` knowledge pages for conflicting claims - report both sides, never resolve
   - **Concept gaps agent**: find terms mentioned 3+ times without a dedicated page
   - **Stale claims agent**: flag `wiki/` knowledge pages older than 6 months on fast-moving topics
4. Merge agent results and group by severity:
   - 🔴 Critical: broken links, unfilled template syntax, contradictions
   - 🟡 Warning: duplicates, missing frontmatter, stale claims, concept gaps
   - ⚪ Info: orphaned notes, empty folders
5. Present a clean summary with counts per category
6. For safe fixes (missing frontmatter, obvious duplicates, creating pages for concept gaps), offer to fix them automatically
7. For destructive fixes, list them and ask for explicit confirmation; `raw/`, `wiki/labs/`, and `wiki/dna/` are never touched
8. Append severity counts to `logs/YYYY-MM-DD.md`

---

### `/obsidian-reconcile`

**Finds and SURFACES contradictions across the vault - the owner resolves them.**

Parallel subagents scan the knowledge folders (`wiki/concepts/`, `wiki/protocols/`, `wiki/supplements/`, `wiki/genes/`, `wiki/biomarkers/`), check `wiki/people/` timelines for coherence only (values at different times are a TREND, not a contradiction), and flag wiki pages citing stale sources. Each genuine contradiction is documented inside the affected page as `## Conflict - <topic> (unresolved, YYYY-MM-DD)` with BOTH claims, sources, and evidence levels (`stated|guideline|high|medium|speculation`) - never a "winner" rewrite, never a new folder. Personal data (`wiki/labs/`, `wiki/dna/`, `timeline:`) is never modified. Updates `index.md` incrementally and logs to `logs/YYYY-MM-DD.md`; the report lists contradictions surfaced, trends noted, and stale references flagged.

---

### `/obsidian-synthesize`

**Vault-wide synthesis on explicit ask.**

Invoking this command IS the consent to create synthesis pages (outside it, synthesis is suggested, never auto-created). Parallel subagents scan `raw/` + `research/` for cross-source concepts, `wiki/` knowledge pages for co-occurring entities without a connection page, `wiki/concepts/` for evolved ideas, and orphaned notes. Each pattern becomes `wiki/concepts/Synthesis - Title.md` (ASCII hyphen) with evidence, interpretation, and suggested action, linked FROM its source notes. Personal data is read for patterns but never modified. `index.md` updated incrementally; log entry to `logs/YYYY-MM-DD.md`.

---

### `/obsidian-export`

**Export a clean snapshot any agent or tool can consume.**

Steps:
1. Scan all notes in `wiki/` and extract: path, title, type, date, status, summary, links, tags, frontmatter
2. Output as JSON (default) to `_export/vault-snapshot.json` or markdown to `_export/vault-snapshot.md`
3. The snapshot is a flat, structured representation of the vault - no folder structure knowledge needed
4. Any AI tool, automation, or agent can read this file and understand the vault
5. Append to `logs/YYYY-MM-DD.md`

---

### `/obsidian-visualize [optional: topic]`

**Generates an Obsidian canvas map of the vault's knowledge graph.**

Builds the link graph from `index.md` and the vault's `[[wikilinks]]`, then writes `atlas.canvas` (or `atlas-{topic}.canvas` if scoped) at the vault root - people left, genes/biomarkers top-right, supplements/protocols/concepts bottom-right, data notes bottom. Also prints a centrality summary: hub nodes, bridge nodes, orphans (stale ones flagged), clusters, and any single-point-of-failure node holding >25% of edges. Logs to `logs/YYYY-MM-DD.md`.

---

### `/create-command`

**Creates a new slash command via a structured interview - no markdown editing.**

Asks for the command's purpose, category (`vault`/`thinking`/`research`/`meta`), trigger phrases (checked against existing commands for collisions), and steps, then writes `commands/<name>.md` in THIS repo (never into the vault) with the standard frontmatter and AI-first/anti-fabrication footers. New commands must follow the fork's structure rules - no new vault folders or note types.

---

### `/obsidian-init`

**Generates the vault's navigation and logging infrastructure.**

Maps the vault, reads `_CLAUDE.md`/`_DOMAIN.md` (authoritative) and note samples, then generates `index.md` (catalog grouped by folder; `raw/` and `research/` contents skipped), the lowercase `logs/` structure, and the `log.md` pointer file. An existing `_CLAUDE.md` is owner-maintained and left untouched - no diff-and-overwrite offer; drafting one from `references/claude-md-template.md` happens only for a brand-new vault, with owner approval. No Bases, no uppercase `Logs/`.

---

### `/obsidian-ingest`

**Ingests a source - knowledge pages get smarter, personal data stays append-only.**

Reads the source in place (URL, file, pasted text) - originals enter `raw/` only on the owner's explicit ask, into the existing subfolder set. Never installs software (missing yt-dlp/whisper -> tell the owner, fall back). Parallel subagents then route the content: family facts -> profile `timeline:` appends in `wiki/people/` (external people get NO person notes - attribute inline); knowledge claims -> `wiki/genes|biomarkers|supplements|protocols|concepts` pages rewritten smarter, every claim with source + date + evidence level; personal lab values / variants -> append-only `wiki/labs/` / `wiki/dna/` data notes per the vault's `_DOMAIN.md`; contradictions -> both-sided `## Conflict` sections, surfaced in the report, never superseded. Synthesis pages are suggested, created only on the user's OK. `index.md` updated incrementally; log entry to `logs/YYYY-MM-DD.md`; actionable items reported only (tasks live in the owner's `TODO.md`).

---

## Thinking Tools

These commands use the vault as a thinking partner - not just storage. They surface insights, challenge assumptions, and generate connections that the user cannot see on their own.

---

### `/obsidian-challenge`

**Red-teams your current idea against your own vault history.**

Steps:
1. Identify the user's current claim, plan, or assumption - from the argument or conversation context
2. Extract the key premises behind that position
3. Spawn parallel subagents to search for counter-evidence:
   - **Knowledge agent**: search `wiki/` pages for claims and evidence levels that cut against the position
   - **History agent**: search `logs/`, `TODO.md`, and git commit messages for past reasoning, reversals, or lessons on this topic
   - **Contradictions agent**: search `## Conflict` sections, opposite positions, and profile `timeline:` data that contradicts the plan
4. Synthesize a structured "Red Team" analysis:
   - **Your position**: restate the claim
   - **Counter-evidence from your vault**: cite specific notes, dates, and quotes
   - **Blind spots**: what the user might be ignoring based on their own history
   - **Verdict**: consistent with past experience, or does the vault suggest caution?
5. Log the challenge in `logs/YYYY-MM-DD.md`

Do not be agreeable. The entire point is to pressure-test. Cite specific vault files.

---

### `/obsidian-emerge`

**Surfaces unnamed patterns from recent notes - recurring themes and conclusions you haven't explicitly stated.**

Steps:
1. Determine the date range from the argument (default: last 30 days)
2. Spawn parallel subagents to scan vault content:
   - **Operations agent**: recurring topics and open loops in `logs/`
   - **Timeline agent**: recurring symptoms, interventions, and patterns across `wiki/people/` timelines
   - **Knowledge agent**: thematic clusters in recently touched `wiki/` pages
   - **Staging agent**: topics researched in `research/` but never promoted
3. Identify:
   - **Recurring themes**: topics that appeared 3+ times without being named as a priority
   - **Emotional patterns**: what energizes vs. drains (based on language)
   - **Unnamed conclusions**: things the notes imply but never state outright
   - **Emerging directions**: where the vault suggests the user is heading
4. Present a "Pattern Report" - each pattern with evidence (cited notes), interpretation, and suggested action
5. Offer once to save the report to `wiki/concepts/`
6. Log a summary in `logs/YYYY-MM-DD.md`

The goal is insight the user cannot see themselves. Surface what they haven't named yet.

---

### `/obsidian-connect [topic A] [topic B]`

**Bridges two unrelated domains using the vault's link graph to spark new ideas.**

Steps:
1. Parse two domains from arguments (e.g., `/obsidian-connect "distributed systems" "cooking"`)
2. For each domain, search the vault: find all related notes, map backlinks and outgoing links to build a local cluster
3. Find the bridge:
   - Shared links, tags, or people between the two clusters
   - If a direct path exists in the link graph, trace it and explain each hop
   - If no direct path, find the closest semantic overlap
4. Generate creative connections:
   - **Structural analogy**: how a pattern in A maps to B
   - **Transfer opportunities**: what works in A that could apply to B
   - **Collision ideas**: new concepts that only exist at the intersection
5. Present 3-5 specific, actionable connections - not vague analogies but concrete ideas
6. Offer once to save the best connections to `wiki/concepts/` with `[[wikilinks]]` to both source domains
7. Log the connection exercise in `logs/YYYY-MM-DD.md`

The value is in unexpected links. If the connection is obvious, dig deeper.

---

### `/obsidian-panel`

**Convenes a panel of distinct perspectives on a decision - one independent verdict per lens, then a synthesis.**

A multi-persona complement to `/obsidian-challenge` (which red-teams from one stance). Uses the vault's `Advisors/` persona notes as panelists if they exist, otherwise four generic lenses (skeptic, user, operator, long-game). Each panelist argues independently before the synthesis; the disagreement is the point and is never hidden. Saves a `type: synthesis` note to `wiki/concepts/`.

---

### `/obsidian-learn [optional: scope]`

**Reviews the vault's accumulated lessons - active, stale, superseded, and promotion candidates.**

Gathers learnings from `logs/`, `TODO.md` parked decisions, git commit messages (the vault's decision log), and prior pattern reports in `wiki/concepts/`. Classifies each as active / stale / superseded / promotion candidate (appeared 3+ times - suggest exact `_CLAUDE.md` wording, promote only with user confirmation). Saves the report to `wiki/concepts/YYYY-MM-DD - Learnings Review.md`, logs to `logs/`; stale learnings are flagged for the owner, never archived by the agent.

---

### `/vault-deep-synthesis [topic]`

**Cross-references everything the vault knows about one topic: agreements, contradictions, stale claims, coverage gaps.**

Topic-driven (unlike `/obsidian-synthesize`, which scans the whole vault unprompted). Pure vault, no network. Greps and reads every note touching the topic, then consolidates into what the vault agrees on, where notes contradict (surfaced, not resolved - that is `/obsidian-reconcile`), what looks stale, and what is missing. Saves a `type: synthesis` note; never modifies the sources.

---

## Context Engine

### `/obsidian-world`

**Loads your identity, values, priorities, and current state in one shot - with progressive context levels.**

Uses token budgets to avoid loading the entire vault. Start light, go deeper only as needed.

Steps:
1. **L0 - Identity (~200 tokens)**: read `SOUL.md`, `CRITICAL_FACTS.md`, and `PINNED.md` if present
2. **L1 - Navigation (~1-2K tokens)**: read `index.md` (vault catalog) and today's + yesterday's `logs/YYYY-MM-DD.md`
3. **L2 - Current State (~2-5K tokens)**: read `TODO.md` (parked decisions) and skim `research/` staging awaiting triage
4. **L3 - Deep Context (on demand, ~5-20K tokens)**: only load if needed - relevant `wiki/people/` profiles, `wiki/` knowledge pages with their `raw/` sources, `_DOMAIN.md` for data schemas

Present a brief status after L0-L2 (do NOT load L3 unless needed):
- **Who I am to you**: persona and communication style
- **Open infrastructure work**: top items from `TODO.md`
- **Open threads**: anything unfinished (from the operation log + `TODO.md`)
- **Awaiting your triage**: unreviewed `research/` staging notes
- **Today so far**: what's already logged

Keep output concise - this is a boot-up sequence, not a report.

If identity files don't exist, offer to create them by asking 5-7 quick questions about the user's role, values, and preferences.
If `index.md` doesn't exist, offer to run `/obsidian-init` to generate it.

---

## Running commands headless (`claude -p`) - important gotcha

Custom slash commands do NOT expand in non-interactive mode. A cron job or launchd
job that runs `claude -p "/obsidian-health"` will send the literal text `/obsidian-health`
as a prompt - Claude never loads the command file, so nothing happens.

The reliable pattern for any headless run (cron, launchd, a wrapper script) is to point
Claude at the command file and tell it to carry out the instructions:

```bash
# Wrong - the slash command is not expanded in -p mode:
claude -p "/obsidian-health"

# Right - read the command file and execute its steps:
cd "$VAULT" && claude --dangerously-skip-permissions \
  -p "Read ~/.claude/commands/obsidian-health.md and carry out its instructions exactly."
```

Because `~/.claude/commands/obsidian-health.md` is symlinked from this repo (see Testing
locally in the README), a scheduled run always uses the current command logic. Export an
explicit `PATH` in launchd jobs - launchd strips the environment, so `claude` and `python3`
may not be found otherwise.

---

## Background Agent (PostCompact Hook)

A background agent that fires automatically whenever Claude compacts the conversation context. It reads the session summary and propagates everything worth preserving to the vault - no user action required.

**What it does:** After each compaction, a headless `claude -p` subprocess wakes up, reads `_CLAUDE.md`, scans the summary for durable facts, and routes them per the fork's rules: health facts about family members append to profile `timeline:` entries, sourced knowledge updates existing `wiki/` knowledge pages, and everything else surfaces as a "needs owner decision" entry in `logs/YYYY-MM-DD.md` - never filed, never new structure. It is triple-gated (env var, enable flag, AND the session's cwd must be the vault) and ships disabled.

**How it works:**
1. `PostCompact` hook fires in Claude Code after context compaction
2. Hook script reads the JSON summary from stdin
3. Spawns a headless `claude --dangerously-skip-permissions -p` subprocess in the vault directory
4. Agent runs silently, propagates updates, and exits - user sees nothing

**Setup:**

1. Make the hook script executable (one-time):
   ```bash
   chmod +x ~/.claude/skills/obsidian-second-brain/hooks/obsidian-bg-agent.sh
   ```

2. Set `OBSIDIAN_VAULT_PATH` in `~/.claude/settings.json`:
   ```json
   {
     "env": {
       "OBSIDIAN_VAULT_PATH": "/path/to/your/vault"
     }
   }
   ```

3. Add the `PostCompact` hook to `~/.claude/settings.json`:
   ```json
   {
     "hooks": {
       "PostCompact": [
         {
           "matcher": "",
           "hooks": [
             {
               "type": "command",
               "command": "/Users/you/.claude/skills/obsidian-second-brain/hooks/obsidian-bg-agent.sh",
               "timeout": 10,
               "async": true
             }
           ]
         }
       ]
     }
   }
   ```

**Debugging:** The agent logs to `/tmp/obsidian-bg-agent.log`. Check there if updates aren't appearing.

**Safety:** The agent never deletes, archives, or merges anything. It only adds or updates. If the summary has nothing vault-worthy, it exits without touching the vault.

---

## Write-Time AI-First Validator (PostToolUse Hook)

A non-blocking validator that fires after every `Write` or `Edit` on a markdown file inside the configured vault. It warns when the file fails the AI-first rule (missing required frontmatter, missing `## For future Claude` preamble, broken YAML) and surfaces the warning back to Claude on stderr so the agent can repair the note in the same turn.

**What it checks:**
1. The file has frontmatter delimiters (`--- ... ---`)
2. No tabs in frontmatter (YAML requires spaces)
3. Required AI-first fields present: `date:`, `type:`, `tags:`, `ai-first: true`
4. The body contains a `## For future Claude` preamble (rule #2 of [`references/ai-first-rules.md`](references/ai-first-rules.md))

**What it skips:**
- Files outside `OBSIDIAN_VAULT_PATH`
- Files under `raw/`, `templates/`, `_export/`, `.obsidian/`, `.git/`, `.trash/`

**Setup:**

1. Make the script executable (one-time):
   ```bash
   chmod +x ~/.claude/skills/obsidian-second-brain/hooks/validate-ai-first.sh
   ```

2. `OBSIDIAN_VAULT_PATH` must already be set in `~/.claude/settings.json` (the background agent setup above covers this).

3. Add the `PostToolUse` hook to `~/.claude/settings.json`:
   ```json
   {
     "hooks": {
       "PostToolUse": [
         {
           "matcher": "Write|Edit",
           "hooks": [
             {
               "type": "command",
               "command": "bash ~/.claude/skills/obsidian-second-brain/hooks/validate-ai-first.sh"
             }
           ]
         }
       ]
     }
   }
   ```

**Behavior:** Non-blocking. If a write fails the AI-first rule, Claude sees the warning text on stderr (with one line per missing requirement) and can re-write the file in the same conversation turn to fix it. The original write is NOT reverted.

**Other platforms (Codex CLI / Gemini CLI / OpenCode):** The hook script ships in `dist/<platform>/hooks/` for all four platform builds, but each platform's hook system differs. Wiring it up beyond Claude Code is left to the platform's own configuration. See [`hooks/validate-ai-first.hook.yaml`](hooks/validate-ai-first.hook.yaml) for the platform-neutral spec.

---

## Per-Project Vaults (multi-repo workflows)

The default install path (`scripts/setup.sh`) writes `OBSIDIAN_VAULT_PATH` into `~/.claude/settings.json` (global). That assumes one machine = one vault. If you work across multiple repos and want each to have its own dedicated vault - or want to keep work and personal vaults separate without manually swapping config - use Claude Code's per-project settings to override the global setting on a per-directory basis.

**How it works:** every hook in this skill (`hooks/load_vault_context.py`, `hooks/validate-ai-first.sh`, `hooks/obsidian-bg-agent.sh`) reads `OBSIDIAN_VAULT_PATH` from process env at fire-time. Claude Code merges `.claude/settings.json` from the current project directory on top of `~/.claude/settings.json`, so a project-scoped env block overrides the global one for any session launched from that directory.

**Setup per repo:**

1. Bootstrap each vault once: `bash scripts/setup.sh` for the first vault (writes the global default), then `python scripts/bootstrap_vault.py --path ~/vaults/repo-b --name "Your Name"` for any additional vaults (skips the global config step).

2. In each repo where you want a non-default vault, create `.claude/settings.json`:

   ```json
   {
     "env": {
       "OBSIDIAN_VAULT_PATH": "/Users/you/vaults/repo-a-vault"
     }
   }
   ```

3. Restart Claude Code (or open a new session in that directory). All slash commands, hooks, and scripts will now operate on the project-specific vault.

**What this does NOT give you:** isolation within a single vault. The skill has no `--scope` concept - `/obsidian-find`, `/obsidian-emerge`, and `/vault-deep-synthesis` scan the entire configured vault. If you want multiple areas sharing one vault, you can organize them by top-level folders for visual grouping, but commands will still see across folders.

**Slash commands and hooks are still globally installed.** Only the `OBSIDIAN_VAULT_PATH` env var is per-project. You do not need to re-symlink commands or re-register hooks per repo.

---

## Reference Files

- `references/vault-schema.md` - Complete folder structure + frontmatter specs for all note types
- `references/write-rules.md` - Detailed writing, linking, and formatting rules
- `references/claude-md-template.md` - Template for generating a vault's `_CLAUDE.md`

## Scripts

- `scripts/setup.sh` - One-command installer (wires hook + env var + MCP)
- `scripts/bootstrap_vault.py` - Bootstrap a complete vault from scratch
- `scripts/vault_health.py` - Audit a vault for structural issues
