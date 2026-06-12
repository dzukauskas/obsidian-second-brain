# `_CLAUDE.md` Template

`_CLAUDE.md` is a file that lives at the root of your vault.
It is the first thing Claude reads when working in your vault.
It gives every Claude surface (Desktop, Code, VS Code, terminal) the same operating context - no memory required.

---

## Authoritative-vault rule (this fork)

**If the vault already has a `_CLAUDE.md`, that file is authoritative. Never
regenerate or overwrite it from this template.** The template below exists only for
bootstrapping a brand-new vault that has no operating manual yet. The reference
vault for this fork (zukauskenOS) maintains its own `_CLAUDE.md` by hand - commands
read it, they do not write it.

---

## How to Generate It (new vault only)

When a user asks Claude to create a `_CLAUDE.md` for a vault that has none:
1. Map the vault structure (list files/folders)
2. Read 2-3 existing notes per major folder to capture naming conventions and frontmatter patterns
3. Fill in the template below with discovered values
4. Show the draft to the owner and write it only after approval

---

## The Template

Copy this, fill in the bracketed values, and save as `_CLAUDE.md` in the vault root.

```markdown
# Claude Operating Manual - [Vault Name]

> Read this file before doing anything in this vault.
> This is the single source of truth for how Claude operates here.

---

## Section 0 - AI-First Vault Rule (read first, applies to every long-lived note)

This vault is designed for **future-Claude** to read and reason over, not for human
review. AI-first structure applies to long-lived `wiki/` notes and person profiles.
`raw/`, `research/`, temporary and import-intermediate files are exempt.

**Every long-lived note Claude writes must:**

1. **Be self-contained** - search pulls notes one at a time; a note must make sense alone.
2. **Start with a `## For future Claude` preamble** - 2-3 sentence summary.
3. **Carry rich frontmatter** - `type`, `date`, `tags`, `ai-first: true`, plus type-specific fields.
4. **Date every external claim** - source URL verbatim, evidence level, claim date.
5. **Use mandatory `[[wikilinks]]`** for every person, gene, concept, or protocol referenced.
6. **Never fabricate** - unknowns are `TBD`, never invented.

---

## Section 0.5 - Verify Live State Before Acting

Before declaring a bug, drafting a fix, or writing architecture: read the actual
code, schema, file, or live data. Speculation from stale context burns hours and
produces drafts that contradict reality.

---

## Vault Identity

- **Owner:** [Full Name]
- **Primary purpose:** [e.g. "Family health OS - genetics, labs, anamnesis, study"]
- **Last updated:** [YYYY-MM-DD]

---

## Folder Map

| Folder | Purpose |
|---|---|
| `raw/` | IMMUTABLE originals, owner-curated. Claude reads, never writes. |
| `wiki/people/` | One profile per family member. Canonical source of personal facts. |
| `wiki/<knowledge>/` | Knowledge pages per domain area ([genes, biomarkers, ...]). |
| `wiki/<data>/` | Append-only personal data notes ([labs, dna, ...]). |
| `research/` | Staging for raw research output. Freely written and deleted. |
| `logs/` | Per-day operation logs, `logs/YYYY-MM-DD.md`, append-only. |

- New folders and `type` values are created only by the owner. If content does not
  fit, propose - never create unprompted.
- No daily notes. Observations go to the person profile `timeline:`; operations go
  to `logs/`.

---

## Key Files

- **Catalog:** `index.md` - read first when navigating
- **Domain context:** `_DOMAIN.md` - schemas and domain rules
- **Identity:** `SOUL.md`, `CRITICAL_FACTS.md`

---

## Write Policy

Claude writes freely only inside the approved folder map above. Everything else:
propose first, write after approval. Specifically:

- Personal facts change -> append to the profile `timeline:` (never overwrite history)
- Operations -> `logs/YYYY-MM-DD.md` (append-only)
- Contradictions between sources -> record both sides, show the owner; never
  auto-resolve
- Deleting or archiving an existing note -> owner only

---

## Naming Conventions

- Dated notes: `YYYY-MM-DD - Title.md` (ASCII hyphen, never an em dash)
- People: real full name (national characters preserved)
- Logs: `logs/YYYY-MM-DD.md`
- No em dashes or curly quotes in content or filenames

---

## Schema Tokens

[List the fixed enums: type values, relationship semantics, evidence levels.
Copy the shape of zukauskenOS `_CLAUDE.md` section 0.1.]

---

*This file is maintained by the owner. Commands read it; they do not rewrite it.*
```

---

## Keeping `_CLAUDE.md` Fresh

`_CLAUDE.md` should be updated (by the owner, with Claude proposing diffs) when:
- A folder is added or restructured
- A new note type or schema token is introduced
- Operating conventions change

If the vault's reality no longer matches the manual, propose an update in the same
conversation - the manual must never lag behind the vault.
