# Vault Schema Reference

This fork's canonical layout is the **Family Health OS** (zukauskenOS) structure: a
medical / biohacking / family-health domain fork of obsidian-second-brain. The vault
is AI-first (the primary reader is the LLM), the owner curates sources and approves
structure, and the agent derives and connects knowledge.

Per the upstream ecosystem contract (`ECOSYSTEM.md`), this fork owns the domain layer:
folder layout, note types, controlled vocabularies, and evidence semantics. Upstream
core primitives (vault management, AI-first rule, rewrite engine) are inherited.

---

## Canonical Layout

```
Your Vault/
├── _CLAUDE.md                  ← Claude's operating manual (authoritative; commands never overwrite it)
├── _DOMAIN.md                  ← Domain context: medical schemas, canonical names, evidence rules
├── index.md                    ← Catalog of all pages (Claude reads this FIRST)
├── log.md                      ← Thin pointer to logs/ (no entries live here)
├── SOUL.md                     ← Identity, values, communication style
├── CRITICAL_FACTS.md           ← ~150 tokens, always loaded; derived copy of key personal facts
├── TODO.md                     ← Deferred infrastructure work and parked decisions
├── PINNED.md                   ← (optional) cross-session working memory, type: pinned
│
├── raw/                        ← IMMUTABLE originals. Owner-curated; Claude reads, NEVER writes.
│   ├── articles/               ← Articles and papers
│   ├── books/                  ← Books, textbooks, book excerpts
│   ├── genetics/               ← Raw DNA exports
│   ├── guidelines/             ← Official clinical guidelines (ERC/ESC, AHA, JRCALC, ...)
│   ├── health-history/        ← Anamnesis and medical history documents
│   ├── labs/                   ← Original lab reports
│   └── podcasts/               ← Podcast sources
│
├── wiki/                       ← Claude's workspace. Long-lived, derived, AI-first notes.
│   ├── people/                 ← Family profiles (type: person). THE canonical source of personal facts.
│   ├── genes/                  ← Gene knowledge pages (no personal genotypes here)
│   ├── biomarkers/             ← Biomarker knowledge pages (no personal values here)
│   ├── supplements/            ← Supplement pages
│   ├── protocols/              ← Protocol pages
│   ├── concepts/               ← Concepts, frameworks, syntheses
│   ├── labs/                   ← Personal lab DATA (type: lab-result), one note per test. Append-only.
│   ├── dna/                    ← Personal genetic DATA (type: dna-result), one note per person+platform. Append-only.
│   └── studies/                ← Study workspaces (e.g. studies/paramedic/)
│
├── research/                   ← Staging for raw research output. Freely written AND deleted. NOT a knowledge base.
└── logs/                       ← Per-day operation logs (logs/YYYY-MM-DD.md), append-only. Lowercase.
```

### Key principles

- **raw/ is immutable and owner-curated** - original sources go here, placed by the
  owner. Claude reads them but never writes or modifies them. If a wiki page gets
  corrupted, re-derive it from raw.
- **Data vs knowledge separation** - personal measurements live in data notes
  (`wiki/labs/`, `wiki/dna/`, profile `timeline:`); general knowledge lives in
  knowledge pages (`wiki/biomarkers/`, `wiki/genes/`). Never mix personal values
  into knowledge pages.
- **Append-only data notes** - `wiki/labs/` and `wiki/dna/` notes are never rewritten
  once created. New variants/values are appended; existing entries stay.
- **research/ is a staging area** - the agent saves raw findings there; the owner
  reviews; the true source gets distilled into `raw/`; synthesis enters `wiki/` only
  after approval. AI-first schema does not apply in `research/` (same as `raw/`).
- **No Daily/, Boards/, Tasks/, People/, Ideas/, Bases/, Templates/** - these
  upstream folders do not exist in this fork's layout. Health observations go to the
  person profile `timeline:`; operations go to `logs/`; tasks live in `TODO.md`.
- **New folders and `type` values are created only by the owner.** If content does
  not fit the existing structure, propose - never create unprompted.
- **index.md is the front door** - Claude reads it first to navigate. Cheaper and
  faster than searching.

---

## Frontmatter Schemas

The authoritative schemas live in the VAULT, not in this file:

- `_CLAUDE.md` section 0.1 - schema tokens (enums, type values)
- `_DOMAIN.md` - detailed schemas for `lab-result`, `dna-result`, canonical names,
  evidence semantics

This file documents only the shared baseline. When the vault and this file disagree,
the vault wins.

### Baseline (every long-lived wiki note)

```yaml
---
type: <note-type>
date: 2026-06-12
tags: [tag1, tag2]
ai-first: true
---
```

Body starts with a `## For future Claude` preamble (2-3 sentences).

### Schema tokens (fixed vocabularies)

- `type`: `operating-manual` | `domain` | `critical-facts` | `identity` | `person` |
  `gene` | `biomarker` | `supplement` | `protocol` | `concept` | `source` |
  `lab-result` | `dna-result` | `study-topic` | `planning` | `pinned`
- `relationship` (person notes): `self` | `spouse` | `child` - **kinship**, never
  relationship strength. Do not replace with `weak`/`medium`/`strong`.
- `evidence` / `confidence`: `stated` | `guideline` | `high` | `medium` | `speculation`
- `platform` (dna-result): `wgs` | `chip`
- `TBD` is the universal placeholder for any undecided value; it is not a member of
  any enum.

### Person Note (wiki/people/)

```yaml
---
type: person
date: 2026-06-12
tags: [person, family]
ai-first: true
relationship: self        # self | spouse | child
born: 1990-01-01
timeline:                  # bi-temporal facts - never delete, only append
  - fact: "ferritin 85 ug/L"
    from: 2026-06-01            # event time: when the fact was true in reality
    until: present              # or the date it stopped being true
    learned: 2026-06-10         # transaction time: when the vault recorded it
    source: "raw/labs/2026-06-01-cbc.md"   # optional - where it was learned from
---
```

**Bi-temporal facts rule:** never overwrite a health fact, role, status, or value.
Add a new entry to `timeline:` with `from`/`until` (event time) and `learned`
(transaction time). Old value + new value together show a trend, not a contradiction.
"Supersede" rewrites are forbidden for health facts.

This enables:
- Historical queries ("what was the ferritin level in January?")
- Trend reasoning (values over time are the signal, not noise)
- Smart reconciliation (different values at different times = not a contradiction)
- Audit trail (when did the vault learn each fact, and from what source?)

### Data notes (wiki/labs/, wiki/dna/)

Detailed schemas live in the vault's `_DOMAIN.md`. Structural invariants:

- `wiki/labs/`: one `type: lab-result` note per test, named
  `YYYY-MM-DD - Name - test.md`. Append-only.
- `wiki/dna/`: one `type: dna-result` note per person + platform, named
  `Name - PLATFORM.md`. Variants are appended to the list; existing entries never
  rewritten.

### Source Note (raw/ describers, research/ findings)

```yaml
---
type: source
date: 2026-06-12
tags: [source]
ai-first: true
source_url: "https://..."
evidence: guideline        # stated | guideline | high | medium | speculation
---
```

---

## Naming Conventions

| Type | Pattern | Example |
|---|---|---|
| Lab data note | `YYYY-MM-DD - Name - test.md` | `2026-06-01 - Darius - CBC.md` |
| DNA data note | `Name - PLATFORM.md` | `Darius - WGS.md` |
| Person profile | Real name (Lithuanian letters preserved) | `Darius.md` |
| Knowledge page | Descriptive title | `Ferritin.md`, `MTHFR.md` |
| Operation log | `logs/YYYY-MM-DD.md` | `logs/2026-06-12.md` |
| Dated note | `YYYY-MM-DD - Title.md` | `2026-06-12 - Iron panel review.md` |

**No em dashes (`—`), en dashes (`–`), or curly quotes anywhere - content AND
filenames.** Use ASCII `-` and straight quotes. Where upstream patterns say
`YYYY-MM-DD — Title.md`, this fork uses `YYYY-MM-DD - Title.md`. Lithuanian letters
(ą č ę ė į š ų ū ž) are always preserved - they are never stripped to ASCII.

Folder and system file names are English (easier to grep); note content is
Lithuanian.
