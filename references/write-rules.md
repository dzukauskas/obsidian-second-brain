# Write Rules

How Claude writes, links, formats, and updates notes in an Obsidian vault.

> **Read `references/ai-first-rules.md` first.** Every note Claude writes must follow the AI-first rule (preamble, rich frontmatter, recency markers, mandatory wikilinks, sources verbatim, confidence levels). The rules below are operational details on top of that foundation.

---

## The Propagation Rule

**Never create a note in isolation.** Every write has ripple effects - but in this
fork they propagate only within the approved structure (no daily notes, no boards).

When you create or update something, trace forward: what other notes need to know about this?

```
New lab result ingested
  → wiki/labs/ data note created (append-only; never edit an existing one)
  → Person profile timeline: gets the new value (old values stay)
  → logs/YYYY-MM-DD.md entry

Health fact stated in conversation (symptom, supplement started, diagnosis)
  → Person profile timeline: (append, never overwrite)
  → CRITICAL_FACTS.md if it changes an always-loaded fact
  → logs/YYYY-MM-DD.md entry

Knowledge page created or updated (gene, biomarker, supplement, protocol, concept)
  → [[wikilinks]] from and to related pages
  → index.md updated if a note was created
  → logs/YYYY-MM-DD.md entry

Contradiction found between sources
  → Record BOTH claims with sources and evidence levels
  → Show the owner; never auto-resolve
  → (different values at different times are a trend, not a contradiction)

Research finding saved
  → research/ staging only - wiki/ and raw/ only after the owner approves
```

---

## Internal Linking

Use `[[Note Name]]` syntax. In long-lived `wiki/` notes always link:
- People mentioned → `[[Darius]]`
- Genes referenced → `[[MTHFR]]`
- Biomarkers referenced → `[[Ferritin]]`
- Supplements / protocols / concepts → `[[Magnesium]]`, `[[Sauna protocol]]`

In manifests and temporary planning files wikilinks are optional.

**Never hardcode paths** unless necessary. Obsidian resolves `[[Name]]` by filename.

If the linked note doesn't exist yet, create it (stub is fine - frontmatter + title + one line of context).

---

## Date Formatting

| Context | Format | Example |
|---|---|---|
| Frontmatter `date` field | `YYYY-MM-DD` | `2026-03-24` |
| `timeline:` fields (`from`, `until`, `learned`) | `YYYY-MM-DD` or `present` | `2026-06-01` |
| Body text references | ISO preferred | `2026-03-24` |
| File names (dated) | `YYYY-MM-DD` | `2026-03-24.md` |

---

## Schema Tokens

Fixed vocabularies live in the vault (`_CLAUDE.md` section 0.1 and `_DOMAIN.md`) and
are summarized in `references/vault-schema.md`. Never translate, inflect, pluralize,
or invent schema tokens. Key ones:

- `relationship`: `self` | `spouse` | `child` - kinship, never relationship strength
- `evidence` / `confidence`: `stated` | `guideline` | `high` | `medium` | `speculation`
- `TBD` is the universal placeholder for any undecided value

---

## Writing Style Calibration

Before writing a new note in a folder you haven't written in before:
1. Read 1-2 existing notes in that folder
2. Match: heading structure, frontmatter fields present, tone (formal vs casual), emoji usage, list style (bullet vs numbered), section names

Don't introduce new patterns - extend what's there.

---

## Deleting and Archiving

The agent never deletes or archives vault notes - that is the owner's call. The only
exception is `research/`: it is a staging area and may be freely cleaned up.
`wiki/labs/` and `wiki/dna/` notes are append-only and are never rewritten at all.

---

## Stub Notes

When a link target doesn't exist yet, create a minimal stub that still passes the
AI-first validator (frontmatter + preamble):
```yaml
---
type: concept    # or person, gene, biomarker, ...
date: 2026-03-24
tags:
  - concept
ai-first: true
---

# Note Name

## For future Claude

Stub created because [[Referring Note]] links here. Expand when more info is
available - nothing below is established yet.
```

---

## Section Injection

When updating an existing note (vs creating new), use targeted section injection:

1. Read the full file
2. Find the target section heading
3. Append content below the last item in that section (before the next `---` or next `##`)
4. Write back the full file with `write_file`

For kanban boards: find the correct column heading, insert the new item above the last item in that column (or at top if empty).

---

## Sentinel-safe regeneration

For notes that a command generates AND a human may hand-edit (architecture docs, dashboards, any note meant to be refreshed by re-running a command), use sentinel markers so a refresh never destroys human edits:

```
<!-- @generated:start -->
...machine-generated content - safe to overwrite on the next run...
<!-- @generated:end -->

<!-- @user:start -->
...human notes - NEVER overwritten by a refresh...
<!-- @user:end -->
```

Rules on refresh:
1. Read the existing note.
2. Replace ONLY the content between `@generated:start` and `@generated:end`.
3. Never touch `@user` blocks, and never touch anything outside the markers (treat it as human-owned).
4. On the first run (no markers yet), wrap the content you generate in `@generated` markers so future refreshes are safe.

This lets a command be idempotent and re-runnable without the user fearing it will wipe their additions. Used by `/obsidian-architect`; available to any command that maintains a regenerable note.

---

## Search Before Write

Before creating any note:
```
search(query="keyword from title")
```

If a match is found:
- Same concept → update the existing note, don't create new
- Different concept, similar name → proceed with creation but choose a distinct name

Duplicate detection is especially important for: people (same person, different name formats), projects (same project, different working title), deals (same client, multiple files).

**Never claim absence from memory.** Before writing "no note exists" or creating a note because you believe none exists, search exhaustively - by every plausible name, alias, and folder, listing and grepping rather than relying on one query. False absence (under-reporting, or "nothing found" when something does exist) is the most common failure mode. When unsure, over-include and label the uncertainty. See the anti-fabrication and search-completeness hard rules in `ai-first-rules.md`.
