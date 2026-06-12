# AI-First Note Rules

The vault is designed for **future-Claude** to read and reason over, not for human review. The owner rarely opens notes directly - they call Claude to retrieve, synthesize, and connect dots across years of accumulated knowledge. **Every command that writes to the vault must produce notes that follow these rules.**

This document is the canonical specification. It lives at `references/ai-first-rules.md` in the obsidian-second-brain repo and is referenced from `_CLAUDE.md` Section 0, every slash command, and `references/write-rules.md`.

---

## The 7 Rules

### 1. Self-contained context
Each note must explain itself. Future-Claude may pull this single note via `/obsidian-find` or vault scan with no surrounding context. Don't rely on backlinks alone for meaning. State the *what*, the *why*, and the *when* inside the note itself.

### 2. "For future Claude" preamble
Every note begins with a 2-3 sentence summary in plain English under a `## For future Claude` header (immediately after the frontmatter). Future-Claude reads this to decide relevance in 10 seconds before parsing the rest. State what's in the note, why it was saved, and any temporal/staleness caveat.

```markdown
## For future Claude
This note is a [type] about [topic] saved on [date]. It [main purpose].
[Optional caveat about staleness, confidence, or scope.]
```

### 3. Rich, consistent frontmatter
Filterable metadata. Different note types have different schemas (see below) but every note has machine-readable frontmatter.

**Universal fields (every note):**
```yaml
---
date: YYYY-MM-DD              # creation or update date
type: <note-type>             # see Type Schemas below
tags: [...]                   # always include the type as a tag
ai-first: true                # explicit flag
---
```

### 4. Recency markers per claim
When stating external facts, attach the date inline:

```markdown
- Mem0 raised $24M Series A (as of 2026-04, mem0.ai/blog/series-a)
- Anthropic released native memory tool (as of 2026-02, anthropic.com/news/memory)
```

So future-Claude knows what to verify before trusting individual facts.

### 5. Sources preserved verbatim
Every external claim has its source URL inline. Don't paraphrase a citation - keep the actual URL so the claim can be re-verified or refreshed years later.

### 6. Cross-links are mandatory
In long-lived `wiki/` notes, every person, gene, biomarker, supplement, protocol, or concept referenced uses `[[wikilinks]]` so the graph is traversable by future-Claude:

```markdown
[[Darius]] started [[Magnesium]] after the [[Ferritin]] trend discussion (2026-06-01 labs).
```

If a linked note doesn't exist, create a stub (per `references/write-rules.md` § Stub Notes). In manifests and temporary planning files wikilinks are optional.

### 7. Evidence levels
Mark claims with the vault's evidence enum:
- `stated` - a personal fact or datum provided by the owner
- `guideline` - official clinical guidelines (ERC/ESC, AHA, JRCALC, ...)
- `high` - meta-analysis, systematic review, or a strong RCT
- `medium` - a single study or limited clinical data
- `speculation` - mechanistic hypothesis, podcast opinion, or experimental assumption

Use this in frontmatter (`evidence: high`) or inline (`(evidence: speculation)`). This is precision, not caution: the owner must know what is solid and what is experimental.

---

## Anti-fabrication and search-completeness (hard rules)

Rules 1-7 govern how a note is written. These govern how Claude reads and reasons over the vault before writing. They are non-negotiable because the failure modes below silently corrupt the vault's value as a memory.

### False absence (the most common failure mode)
Never assert that a note, person, project, or file does NOT exist without an exhaustive search first. Saying "no note exists" when one does is the single most common observed failure - more common than fabrication. Verify presence or absence by listing and grepping the vault, not from memory or a single lucky query. Search by every plausible name, alias, and folder before concluding something is missing. When unsure, over-include and label the uncertainty rather than under-report.

### Search completeness
When a command reads or scans the vault, enumerate exhaustively - do not sample. List every matching note, not a representative few. A partial scan that is reported as complete produces confident wrong answers, which are worse than an honest "I only checked X".

### No fabrication
Never invent facts, entities, rates, dates, or relationships that were not actually stated. Mark unknowns as `TBD`. Attach a recency marker and source URL to every external claim (Rules 4-5); mark inferences with a confidence level (Rule 7). Never fabricate a value just to make a section look complete - an empty `## Decisions` section is correct when no decision was made.

---

## Type Schemas

Frontmatter schemas by note type - the zukauskenOS set. The authoritative source
is the VAULT (`_CLAUDE.md` section 0.1 for the type list, `_DOMAIN.md` for the
detailed data schemas); this section is the working summary. **Add fields
specific to your type - never remove the universal fields. Never invent new
`type` values - the owner creates them.**

Type list: `operating-manual` | `domain` | `critical-facts` | `identity` |
`person` | `gene` | `biomarker` | `supplement` | `protocol` | `concept` |
`source` | `lab-result` | `dna-result` | `study-topic` | `planning` | `pinned` |
`log` | `synthesis`

### `type: person` (wiki/people/ - family profiles ONLY)
```yaml
date: YYYY-MM-DD
type: person
tags: [person, family]
relationship: self            # self | spouse | child - KINSHIP, never strength
born: YYYY-MM-DD
timeline:                     # bi-temporal facts - append-only, never rewritten
  - fact: ""
    from: YYYY-MM-DD          # event time
    until: present            # or end date
    learned: YYYY-MM-DD       # transaction time
    source: ""                # optional provenance
ai-first: true
```

### `type: gene` / `type: biomarker` / `type: supplement` / `type: protocol` / `type: concept`
Knowledge pages - no personal values in them (those live in data notes and timelines).
```yaml
date: YYYY-MM-DD
type: biomarker               # or gene | supplement | protocol | concept
tags: [biomarker, ...]
ai-first: true
```
Every claim in the body carries its source URL, claim date, and evidence level.

### `type: lab-result` / `type: dna-result` (wiki/labs/, wiki/dna/ - append-only DATA)
Full schemas live in the vault's `_DOMAIN.md`. Structural invariants: one
`lab-result` note per test (`YYYY-MM-DD - Name - test.md`), one `dna-result`
note per person + platform (`Name - PLATFORM.md`, `platform: wgs | chip`);
existing notes and entries are never rewritten - new data is appended.

### `type: source`
```yaml
date: YYYY-MM-DD
type: source
tags: [source]
source_url: ""
evidence: guideline           # stated | guideline | high | medium | speculation
ai-first: true
```

### `type: log` (logs/YYYY-MM-DD.md - append-only)
```yaml
date: YYYY-MM-DD
type: log
tags: [log]
ai-first: true
```
Body: `## For future Claude` preamble, then `**HH:MM** - action | description` lines.

### `type: synthesis` (wiki/concepts/)
Outputs from thinking tools (synthesize, panel, vault-deep-synthesis, saved emerge/connect reports):
```yaml
date: YYYY-MM-DD
type: synthesis
tags: [thinking, ...]
sources: [...]                # vault notes that informed this
ai-first: true
```

### `type: study-topic` / `type: planning` / `type: pinned`
Owner-defined working types (wiki/studies/, TODO.md-adjacent planning files,
PINNED.md). Universal fields apply; see the vault's `_CLAUDE.md` for their
semantics. `planning` files are exempt from mandatory wikilinks.

---

## Preamble Templates by Type

### Person profile
```markdown
## For future Claude
[Name] is the owner's [self/spouse/child], born [date]. Current state lives in the top-level fields; the full history is the bi-temporal timeline: array - values at different times are a trend, not a contradiction. This profile is THE canonical source of personal facts about [Name].
```

### Knowledge page (gene / biomarker / supplement / protocol / concept)
```markdown
## For future Claude
Knowledge page about [topic] as of [date]. Every claim carries its source, claim date, and evidence level (stated/guideline/high/medium/speculation). No personal values live here - those are in wiki/labs, wiki/dna, and profile timelines.
```

### Lab data note (lab-result)
```markdown
## For future Claude
Lab results for [Name], test [name], taken [date], source [raw/labs/...]. Append-only data note - never edited after creation. Interpretation and reference knowledge live in wiki/biomarkers/.
```

### DNA data note (dna-result)
```markdown
## For future Claude
Genetic variants for [Name], platform [wgs/chip]. Append-only: variants are added to the list, existing entries never rewritten. Gene knowledge lives in wiki/genes/.
```

### Operation log (logs/YYYY-MM-DD.md)
```markdown
## For future Claude
Operation log for [date]. Append-only; one `**HH:MM** - action | description` line per operation.
```

### Synthesis (thinking-tool output)
```markdown
## For future Claude
[Synthesis/panel/cross-reference] on "[topic]" from [date]. Sources listed in frontmatter. Contradictions are surfaced, not resolved - the owner decides. [Caveat about scope or staleness.]
```

---

## Common Anti-Patterns

Don't do these. They produce notes that are useless to future-Claude.

| Anti-pattern | Why it's bad |
|---|---|
| `date: today` | Use the actual `YYYY-MM-DD` - "today" is meaningless when read later |
| Bare claims without dates | "Mem0 is the leader" - leader as of when? |
| External URL omitted | "According to a study, X is true" - which study? |
| Plain text names instead of `[[wikilinks]]` | Breaks the link graph - future-Claude can't traverse |
| "See above" / "as mentioned" | Future-Claude may pull this note in isolation. Repeat the context. |
| Trusting the model to infer | Be explicit. State the type, the rule applied, the source. |
| Multi-paragraph human-readable narratives | Bullets and structure beat prose for retrieval. |
| Forgetting `ai-first: true` | The flag lets future-Claude know which notes meet the standard. |
| Em-dash (`—`), curly quotes (`"`), Unicode math (`≥ ≤ ≠`) | Substitution Unicode slips in silently via LLM defaults. Caught by `validate-ai-first.sh` check 5. Use ` - ` for dashes, straight `"` quotes, ASCII operators (`>=`, `!=`). Allowed: box-drawing (`─`), arrows (`→ ←`), currency (`€ £ ¥`), Nerd Font codepoints - all carry semantic meaning. |

---

## Audit Checklist

When auditing an existing note (Phase 2 work or one-off cleanup), verify:

- [ ] Has `## For future Claude` preamble below frontmatter
- [ ] `ai-first: true` in frontmatter
- [ ] `type:` field set correctly
- [ ] `date:` in YYYY-MM-DD format
- [ ] Tags include the type
- [ ] All people/projects/concepts use `[[wikilinks]]`
- [ ] External claims have recency markers AND source URLs
- [ ] If multi-source, confidence levels marked
- [ ] No "see above" or context-dependent references
- [ ] Self-contained - readable with zero context
- [ ] No fabricated facts, entities, or dates - unknowns marked `TBD`
- [ ] Any "no note / nothing found" claim was verified by an exhaustive search, not from memory

---

## Fork Note

The 7 rules and the hard rules above are upstream core (per `ECOSYSTEM.md`);
the Type Schemas and Preamble Templates sections are the fork-owned domain
layer, curated 2026-06-12 for the zukauskenOS type set. When merging from
upstream, keep the fork side of those two sections and port only genuinely
universal rule improvements (see `DELTAS.md` Upgrade hygiene). The vault's
`_CLAUDE.md` 0.1 and `_DOMAIN.md` always win over this file on schema details.
