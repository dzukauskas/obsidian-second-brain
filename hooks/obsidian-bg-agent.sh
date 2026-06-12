#!/usr/bin/env bash
# obsidian-bg-agent.sh - PostCompact vault propagation hook
#
# Fires after Claude compacts the conversation context. Reads the session
# summary from stdin (JSON), then runs a headless Claude agent to propagate
# everything worth preserving to the vault.
#
# TRUST CAVEAT: this agent writes to the vault UNATTENDED using
# --dangerously-skip-permissions. For that reason it is OPT-IN and ships INERT.
# It requires ALL THREE of the following before it does anything:
#   - OBSIDIAN_VAULT_PATH set (where to write), AND
#   - OBSIDIAN_BG_AGENT_ENABLED=1 (a second, deliberate enable flag), AND
#   - the compacted session's cwd is the vault (or under it) - sessions from
#     other projects never propagate here (mirrors load_vault_context.py).
# setup.sh sets the first but never the second, so the agent stays inert after a
# normal install. See hooks/postcompact.hook.example.json for the opt-in steps.
#
# Defense in depth: the subprocess runs `cd "$VAULT"` first, so the vault's own
# PreToolUse guard (.claude/hooks/guard-vault-writes.py) still fires for every
# write - hooks run regardless of --dangerously-skip-permissions.
#
# Setup:
#   1. Set OBSIDIAN_VAULT_PATH in the env section of ~/.claude/settings.json
#   2. Set OBSIDIAN_BG_AGENT_ENABLED=1 in the same env section to enable
#   3. Register this script as a PostCompact hook (see postcompact.hook.example.json)
#   4. Make executable: chmod +x hooks/obsidian-bg-agent.sh
# To disable again: clear OBSIDIAN_BG_AGENT_ENABLED (the gate below makes that enough).
#
# Logs: /tmp/obsidian-bg-agent.log

VAULT="${OBSIDIAN_VAULT_PATH:-}"
[[ -z "$VAULT" ]] && exit 0

# Opt-in gate: no-op unless the user deliberately enabled the agent. This is the
# second of the two flags; without it the hook does nothing even when registered.
[[ "${OBSIDIAN_BG_AGENT_ENABLED:-0}" != "1" ]] && exit 0

# PostCompact stdin includes `cwd` and `transcript_path`; the compaction summary
# itself is written into the transcript JSONL as entries with
# `isCompactSummary: true`. We read the most recent one here.
INPUT=$(cat)

# Third gate: only sessions running IN the vault may propagate to it. Without
# this, compaction summaries from every project on the machine would land here.
# Mirrors hooks/load_vault_context.py normalize(): backslashes to slashes,
# drive letter lowercased behind a leading slash, no trailing slash.
normalize() {
  local p="${1//\\//}"
  if [[ "$p" =~ ^([A-Za-z]):(.*)$ ]]; then
    p="/$(printf '%s' "${BASH_REMATCH[1]}" | tr '[:upper:]' '[:lower:]')${BASH_REMATCH[2]}"
  fi
  printf '%s' "${p%/}"
}
CWD=$(printf '%s' "$INPUT" | jq -r '.cwd // ""' 2>/dev/null || true)
CWD_N=$(normalize "$CWD")
VAULT_N=$(normalize "$VAULT")
[[ -z "$CWD_N" ]] && exit 0   # fail closed: no cwd in the payload, no writes
[[ "$CWD_N" == "$VAULT_N" || "$CWD_N" == "$VAULT_N"/* ]] || exit 0

TRANSCRIPT=$(printf '%s' "$INPUT" | jq -r '.transcript_path // ""' 2>/dev/null || true)
[[ -z "$TRANSCRIPT" || ! -f "$TRANSCRIPT" ]] && exit 0

# Stream the JSONL (transcripts can be 100MB+). base64-encode each match so the
# multi-line content stays on one line, then decode the most recent one.
SUMMARY=$(jq -rc 'select(.isCompactSummary == true) | .message.content // "" | @base64' "$TRANSCRIPT" 2>/dev/null | tail -n 1 | base64 -d 2>/dev/null || true)
[[ -z "$SUMMARY" ]] && exit 0

TODAY=$(date +%Y-%m-%d)

# Build prompt in a temp file to handle special characters in the summary safely
PROMPT_FILE=$(mktemp /tmp/obsidian-bg-XXXXXX.txt)

cat > "$PROMPT_FILE" << HEADER
You are an autonomous Obsidian vault agent. The Claude session was just compacted.
Propagate everything worth preserving from the summary to the vault. Run silently.

VAULT: $VAULT
TODAY: $TODAY

SESSION SUMMARY:
HEADER

printf '%s\n\n' "$SUMMARY" >> "$PROMPT_FILE"

cat >> "$PROMPT_FILE" << 'INSTRUCTIONS'
INSTRUCTIONS:
1. Read _CLAUDE.md at the vault root first - it is authoritative and wins over these defaults.
2. Identify DURABLE facts in the summary and route them:
   - Health facts about FAMILY members (symptom, value, supplement started/stopped, diagnosis):
     append a timeline: entry to the person's profile in wiki/people/ (fact, from, until,
     learned, source). Never overwrite or delete existing entries. Refresh CRITICAL_FACTS.md
     if the fact is always-loaded.
   - Sourced knowledge (genes, biomarkers, supplements, protocols, concepts): update the
     matching EXISTING wiki/ knowledge page - rewriting knowledge pages smarter is allowed;
     keep source, claim date, and evidence level (stated|guideline|high|medium|speculation)
     per claim.
   - Everything else (decisions, tasks, ideas, anything needing new structure): do NOT file
     it. List it in the day's log entry as "needs owner decision: ..." - that is your only
     surfacing channel as an unattended agent.
3. Before creating any note, search for an existing one exhaustively. Never duplicate,
   never claim absence from memory.
4. Contradictions: if a new claim conflicts with an existing page, keep BOTH claims with
   sources, dates, and evidence levels, and flag the conflict in the log entry. Never pick
   a winner. Values at different times are a trend, not a contradiction.
5. Update index.md incrementally for any note you created (never regenerate it).
6. Append "**HH:MM** - bg-agent | description" to logs/YYYY-MM-DD.md (use TODAY from above).
   If the day file is missing, create it with frontmatter (type: log, date, tags, ai-first:
   true). If the logs/ folder itself does not exist, skip logging - do not create it.

CONSTRAINTS:
- Use filesystem tools only (Read, Write, Edit, Glob, Grep) - MCP is not available in this subprocess.
- Run completely silently. No output to the user. No questions.
- NEVER create folders or new note types - the owner creates structure.
- NEVER write to raw/ or research/. NEVER touch wiki/labs/ or wiki/dna/ data notes.
- There are no daily notes, boards, tasks, or ideas folders in this vault - do not create them.
- No em dashes or curly quotes in content or filenames - ASCII " - " and straight quotes.
  Lithuanian letters are always preserved.
- If the summary contains nothing durable, exit without making any changes.
- Match the vault's existing writing style, frontmatter schemas, and naming conventions exactly.
- Do not archive, delete, or merge anything - only add or update.
INSTRUCTIONS

PROMPT=$(cat "$PROMPT_FILE")
rm -f "$PROMPT_FILE"

# Run headless agent in vault directory - async, logs to /tmp for debugging
(
  cd "$VAULT" && \
  claude --dangerously-skip-permissions -p "$PROMPT" >> /tmp/obsidian-bg-agent.log 2>&1
) &

exit 0
