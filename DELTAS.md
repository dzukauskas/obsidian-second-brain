# DELTAS - zukauskenOS fork customizations

This is the **Family Health OS fork** of obsidian-second-brain: a medical /
biohacking / family-health domain fork per the upstream ecosystem contract
(`ECOSYSTEM.md`: upstream owns core primitives, forks own everything
domain-specific). This file is the one place fork deviations are catalogued, so
they survive every `git merge upstream/main` (upstream never touches `DELTAS.md`).

- **Fork:** https://github.com/dzukauskas/obsidian-second-brain
- **Upstream:** https://github.com/eugeniughelbur/obsidian-second-brain
- **Fork baseline:** upstream `cb1e250` (2026-06-12). Full file-by-file upstream
  audit done 2026-06-10..11, valid up to upstream `7762fba` + reviewed #63, #64.

## Config decisions

- **Vault path:** `~/vaults/zukauskenOS`
- **Owner / name:** Darius
- **Preset used:** none - custom Family Health OS layout (see `references/vault-schema.md`)
- **Research toolkit:** not used. Research goes through the external `deep-research`
  skill; output lands in the vault's `research/` staging folder (owner reviews, then
  promotes). No API keys configured.
- **Vault language:** content Lithuanian, folder/system filenames English.
  Lithuanian letters (ą č ę ė į š ų ū ž) are never stripped; em/en dashes and curly
  quotes are banned in content AND filenames.

## Bootstrap status

- [x] Vault exists and is owner-built (NOT bootstrapped - `bootstrap_vault.py` unused)
- [x] Fork cloned directly to `~/.claude/skills/obsidian-second-brain` (no symlink needed; `git pull` auto-deploys)
- [ ] Ran `scripts/setup.sh` (env var + hooks) - pending
- [ ] Wired `hooks/validate-ai-first.sh` as PostToolUse (manual step; setup.sh does not do it)
- [x] Background agent decision: **OFF** (`OBSIDIAN_BG_AGENT_ENABLED` never set) - see "Intentionally NOT using"
- [x] MCP server decision: **no** (file tools suffice; answer N at setup.sh prompt)

## Deviations from upstream defaults

Fork edits, by file (2026-06-12, tier 1 "core layer"):

- `references/vault-schema.md` - REWRITTEN. Canonical layout is the zukauskenOS
  structure (raw/ owner-curated subfolders, wiki/ domain folders incl. append-only
  wiki/labs + wiki/dna, research/ staging, logs/ lowercase). Authoritative schemas
  live in the VAULT (`_CLAUDE.md` 0.1, `_DOMAIN.md`); this file is the baseline.
- `references/claude-md-template.md` - REWRITTEN. Existing `_CLAUDE.md` is
  owner-maintained and never regenerated; template only for brand-new vaults; no
  "auto-save without asking" policy; family-OS folder map; ASCII naming.
- `references/write-rules.md` - Propagation Rule replaced with family-OS
  propagation (labs -> timeline -> logs; contradictions surfaced, never
  auto-resolved); kanban section removed; status enums replaced with vault schema
  tokens; stub schema fixed to pass the AI-first validator (upstream stub lacked
  `type`/`ai-first`/preamble); deleting/archiving is owner-only.
- `references/bases/` - DELETED (all four .base templates). Bases are human-facing
  Obsidian views pointing at folders this layout does not have. A custom People.base
  can be hand-made later if ever wanted. `bootstrap_vault.py` degrades gracefully
  (warns + skips).
- `commands/obsidian-init.md` - native to this layout: creates `logs/` (lowercase),
  `index.md` skips raw/ and research/ contents, NO Bases step, existing `_CLAUDE.md`
  is left untouched (no diff-and-overwrite offer), `migrate_log.py` not invoked
  (creates uppercase `Logs/`).
- `SKILL.md` - ambient behavior tamed: description rewritten (no "use proactively");
  propagation table, common operations, and write-rules summary now family-OS;
  bi-temporal example is a health fact; raw/ owner-curated; Two-Output rule scoped
  to approved structure; Synthesis Hook suggests instead of auto-creating;
  Reconciliation NEVER auto-resolves; save reminders -> single offer, no nagging;
  per-day logs lowercase; bootstrap presets marked unused.

- `commands/obsidian-reconcile.md` - REWRITTEN to find-and-surface (2026-06-12,
  tier 2): subagents retargeted to the fork's wiki/ folders; timeline values at
  different times are a trend, not a contradiction; genuine contradictions get a
  both-sided `## Conflict - <topic> (unresolved, ...)` section in the affected
  page(s) - no winner rewrites, no `wiki/decisions/`; authority ranking replaced
  with the vault evidence enum; index.md incremental; logs to lowercase `logs/`;
  no daily-note step. SKILL.md section synced.

- `commands/obsidian-ingest.md` - REWRITTEN (2026-06-12, tier 2): no autonomous
  software installs (missing yt-dlp/whisper -> tell the owner, fall back);
  originals are read in place and enter `raw/` only on explicit ask, into the
  existing subfolder set; transcripts/image descriptions are derived content
  (note or `research/`, never `raw/`); agents retargeted (family facts ->
  timeline appends, external people get no person notes, knowledge pages
  rewrite-allowed, new Data agent for append-only `wiki/labs`/`wiki/dna`,
  contradictions both-sided and surfaced); synthesis suggested not auto-created;
  action items report-only; index.md incremental; logs to lowercase `logs/`; no
  daily-note step. SKILL.md section synced.

Pending (next tiers, planned 2026-06):

- Tier 2 "behavior risks" (remaining): `hooks/obsidian-bg-agent.sh` (no cwd
  filter, hardcoded Daily/Boards prompt), research
  `scripts/research/lib/vault.py` (mechanical Research/ mkdir + monolithic
  log.md append).
- Tier 3 "deletions": commands with no target in this layout (daily, board, task,
  recap, review, calendar family, etc.) + their SKILL.md sections.

## Personal conventions

- Personal facts are canonical in `wiki/people/` profiles; `CRITICAL_FACTS.md` is a
  derived copy. Health facts are bi-temporal `timeline:` entries - never superseded.
- `relationship` field means kinship (`self`/`spouse`/`child`), NEVER relationship
  strength. Evidence levels: `stated`/`guideline`/`high`/`medium`/`speculation`.
- New folders and `type` values are created only by the owner. A PreToolUse guard in
  the vault (`.claude/hooks/guard-vault-writes.py`) enforces this mechanically.
- Git commits in the VAULT are Lithuanian; commits in THIS fork follow upstream's
  English convention.

## Intentionally NOT using

- **Daily notes / Daily/ folder** - observations go to profile `timeline:`, operations to `logs/`
- **Kanban boards, Boards/, Tasks/** - tasks live in the vault's `TODO.md`
- **Bases/** - human-facing views, rejected 2026-06-10
- **`scripts/bootstrap_vault.py` presets** - vault is owner-built
- **Research toolkit commands** (`/research`, `/research-deep`, `/x-*`, `/youtube`,
  `/podcast`, `/notebooklm`) - external `deep-research` skill + `research/` staging
  instead; the toolkit's Python layer writes mechanically (Research/ mkdir,
  monolithic log.md), bypassing vault rules
- **Background PostCompact agent** - `OBSIDIAN_BG_AGENT_ENABLED` never set: no cwd
  filter (would ingest ALL sessions' summaries) and prompt hardcodes Daily/Boards
- **Scheduled agents** (morning/nightly/weekly/health) as shipped - nightly
  auto-resolves contradictions, against vault rules
- **`install.sh`** - legacy installer; `scripts/setup.sh` is the canon
- **MCP server** - file tools suffice
- **`scripts/migrate_log.py`** - creates uppercase `Logs/`
- **`scripts/sweep_non_ascii.py --apply` on code** - it corrupted upstream's own
  Python once (see Bugs); dry-run review first, .md only

## Upgrade hygiene

```bash
cd ~/.claude/skills/obsidian-second-brain
git fetch upstream
git log --oneline HEAD..upstream/main   # review what's coming BEFORE merging
git merge upstream/main
```

Conflict policy for THIS fork (differs from the upstream template's
"prefer upstream"): in files this fork deliberately owns
(`references/vault-schema.md`, `references/claude-md-template.md`,
`references/write-rules.md`, `commands/obsidian-init.md`, `SKILL.md` core
sections), **prefer the fork side**, then port genuinely valuable upstream
improvements by hand in the same sitting. In everything else, prefer upstream.
Deleted files (bases templates, later tier-3 commands): on modify/delete conflicts,
keep deleted (`git rm` again) - the deletion is intentional.

After every merge: re-read this file's Deviations list and spot-check that fork
edits survived (`git diff upstream/main -- references/ SKILL.md | head`).

## Bugs / mismatches noticed in upstream

- `scripts/vault_health.py:229` - `_normalize_dashes` is a no-op
  (`s.replace("-", "-")`): upstream's own `sweep_non_ascii.py` stripped the em/en
  dash literals out of the function (commit f3af53b). Em-dash filename vs hyphen
  wikilink matching in broken-link check is silently dead. Not yet filed.
- `scripts/research/notebooklm.py:141` - same sweep casualty: `safe_display_name`
  now does `path.replace("-", " - ")`, mangling dates ("2026-06-11" -> "2026 - 06 - 11").
  Not yet filed.
- `relationship` field drift across upstream: `references/ai-first-rules.md` says
  `relationship: weak|medium|strong`, `Templates/Person.md` (bootstrap) uses
  `relationship_strength`, `scripts/vault_stats.py` reads `strength`, upstream
  `vault-schema.md` had none of them. Three names for one concept. Not yet filed.
- `SKILL.md` referenced `/obsidian-setup` - no such command file exists. Not yet filed.
- Research command docs say to run scripts "from the repo root
  (`~/Projects/personal/obsidian-second-brain/`)" - the author's personal path,
  wrong for any standard install. Not yet filed.
- `references/write-rules.md` stub schema (date+tags only) contradicted upstream's
  own AI-first validator (missing `type`, `ai-first`, preamble). FIXED in this fork;
  worth upstreaming.
- Filed & merged already: #63 (reviewed), #64 (CLAUDE.md stale command count, ours).
