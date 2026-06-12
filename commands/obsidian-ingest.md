---
description: Ingest a source - knowledge pages get smarter, personal data stays append-only, contradictions get surfaced
category: research
triggers_en: ["ingest this source", "add this article", "import this", "absorb this"]
---

Use the obsidian-second-brain skill. Execute `/obsidian-ingest $ARGUMENTS`:

The argument is a URL, file path, or pasted text. If no argument, ask what to ingest.

1. Read `_CLAUDE.md` first if it exists in the vault root

2. Classify the source type before reading the full content:
   - **Article/blog post** - extract key claims, people, tools, concepts
   - **PDF/document** - extract structure, findings, recommendations
   - **Transcript (meeting/podcast)** - extract speakers, claims, quotes
   - **YouTube video** - pull metadata, description, and transcript (see step 3 for method)
   - **Audio file** (.m4a, .mp3, .wav, .ogg, .webm) - transcribe (if tooling exists), extract claims and quotes
   - **Image/screenshot** (.png, .jpg, .jpeg, .webp) - read/OCR the image, extract text and context
   - **Raw text** - classify by content (opinion, technical, narrative) and extract accordingly
   - **Lab report / genetic data** - personal DATA, not knowledge: route per step 6's Data agent and the vault's `_DOMAIN.md` schemas

3. Read or fetch the full source content. **Never install software autonomously** - if a tool is missing, tell the owner the exact install command they could run themselves, and fall through to the next method.

   **For YouTube URLs** - try methods in this order (use the first one that works):

   **Method A - `yt-dlp` (if already installed; check with `command -v yt-dlp`):**
   ```bash
   yt-dlp --skip-download --print title --print description --print duration_string --print view_count --print like_count --print upload_date --print channel "URL"
   yt-dlp --write-auto-sub --sub-lang en --skip-download -o "/tmp/%(id)s" "URL"
   ```
   If `yt-dlp` is missing: say so (install command: `brew install yt-dlp`) and try Method B.

   **Method B - YouTube MCP tools (works in Claude Desktop if configured):**
   Check if YouTube MCP tools are available. If so, use them.

   **Method C - oEmbed fallback (works everywhere, limited data):**
   Fetch `https://www.youtube.com/oembed?url=URL&format=json` - gives title and channel only. Ask user to paste description for full ingest.

   **For audio files** (.m4a, .mp3, .wav, .ogg, .webm):
   If `whisper` is already installed (`command -v whisper`):
   ```bash
   whisper "path/to/audio.m4a" --model base --output_format txt --output_dir /tmp
   ```
   If not: tell the owner (install command: `pip install openai-whisper`) and ask them to paste the transcript instead.
   After transcription: identify speakers if possible, extract claims and quotes.
   The transcript is DERIVED content - preserve it verbatim inside the derived note, or in `research/` staging if long. Never write it to `raw/`.

   **For images/screenshots** (.png, .jpg, .jpeg, .webp):
   Claude can read images directly. Analyze the image for:
   - Text content (OCR) - extract all readable text
   - UI screenshots - describe what's shown, extract data from tables/forms/dashboards
   - Whiteboard/diagram photos - describe the structure and extract concepts
   - Chat screenshots - extract messages, people, claims
   The description is DERIVED content - it goes into the derived note or `research/` staging, never into `raw/`.

   **For articles** - use WebFetch to pull the page content
   **For PDFs** - read the file directly
   **For pasted text** - use as-is

4. Extract and organize:
   - **Family facts**: anything personal about a family member (symptom, value, intervention, history)
   - **Knowledge**: claims about genes, biomarkers, supplements, protocols, concepts - each with source, claim date, and evidence level (`stated | guideline | high | medium | speculation`)
   - **Quotes**: notable quotes worth preserving verbatim
   - **Actionable items**: surface them in the final report ONLY - tasks live in the owner's `TODO.md`, never write them anywhere

5. Originals stay where they are - **do not save the source into the vault by default.** Read it in place (URL, file path, pasted text). Only when the owner EXPLICITLY asks to keep the original, distill it into the existing `raw/` subfolder set (`articles`, `books`, `genetics`, `guidelines`, `health-history`, `labs`, `podcasts`) with frontmatter (`date`, `tags: [source, <type>]`, `source_url`, `source_type`, `content_hash`) and an ASCII filename `YYYY-MM-DD - Source Title.md`. If nothing fits the existing subfolders, propose - never create a new one.

6. **Update the vault** - knowledge pages get smarter; data and timelines only grow.

   Read `index.md` first to understand what already exists in the vault. Then spawn parallel subagents:

   - **Family facts agent**: for each personal fact about a FAMILY member:
     - Append a `timeline:` entry to the person's profile in `wiki/people/` (`fact`, `from`, `until`, `learned`, `source`) - never overwrite existing entries
     - Refresh `CRITICAL_FACTS.md` if the fact is always-loaded
     - External people (authors, podcast guests, researchers) get NO person notes - `wiki/people/` is family profiles only. Attribute them inline in knowledge pages (`per Dr. X, 2026 podcast`); propose a page only if one is clearly warranted.

   - **Knowledge agent**: for each gene/biomarker/supplement/protocol/concept claim:
     - Search the matching `wiki/` knowledge folder for an existing page
     - If found: REWRITE the page smarter - merge new evidence, examples, connections; preserve history; every claim keeps its source, date, and evidence level
     - If not found: create a new knowledge page (AI-first; stub per `references/write-rules.md` if thin)
     - If a PATTERN emerges across multiple pages: SUGGEST a synthesis page in the report - create it only if the user agrees

   - **Data agent**: for personal lab values or genetic variants in the source:
     - Lab values -> `wiki/labs/YYYY-MM-DD - Name - test.md` (`type: lab-result`) per the vault's `_DOMAIN.md` schema - append-only, never edit an existing lab note
     - Genetic variants -> append to the person+platform note in `wiki/dna/` (`type: dna-result`) - existing entries are never rewritten
     - Knowledge about the markers/genes goes to `wiki/biomarkers/` / `wiki/genes/` - no personal values there

   - **Contradictions agent**: for each claim in the new source:
     - Search the vault for CONFLICTING claims in existing pages
     - Timeline values at different times are a TREND, not a contradiction - skip
     - Genuine contradiction: add a `## Conflict - <topic> (unresolved, YYYY-MM-DD)` section to the affected page with BOTH claims, sources, dates, and evidence levels, and list it in the report. Never pick a winner, never rewrite the old claim.

7. Update structural files:
   - Update `index.md` incrementally - add entries for created notes, adjust descriptions that changed. Full regeneration is `/obsidian-init`'s job.
   - Append `**HH:MM** - ingest | Source Title (type) - X created, Y updated, Z contradictions surfaced` to `logs/YYYY-MM-DD.md` (lowercase; create the day file with frontmatter `type: log`, `date`, `tags`, `ai-first: true` if missing). Never write entries to `log.md` - it is a pointer file.

8. Report back:
   - Source title and type
   - **New pages created** (list)
   - **Knowledge pages updated** (list with what changed)
   - **Timeline appends and data notes** (per person)
   - **Contradictions surfaced** (both claims - awaiting the owner's call)
   - **Synthesis suggestions** (patterns worth a page - created only on your OK)
   - **Actionable items** (for the owner to file into `TODO.md` if wanted)

The vault should be DIFFERENT after every ingest - not just bigger. Knowledge pages that existed before should be smarter, more connected, and more current. Data notes and timelines only grow - they are never rewritten.

---

**AI-first rule:** Every note created or updated by this command MUST follow `references/ai-first-rules.md` - `## For future Claude` preamble, rich frontmatter (`type`, `date`, `tags`, `ai-first: true`, plus type-specific fields), recency markers per external claim, mandatory `[[wikilinks]]` for every person/project/concept referenced, sources preserved verbatim with URLs inline, and confidence levels where applicable. The vault is for future-Claude retrieval - not human reading.

**Anti-fabrication:** Search exhaustively before claiming any note, person, or file is absent - false absence is the most common failure mode - and never invent facts, entities, or dates (mark unknowns as `TBD`). See the anti-fabrication and search-completeness hard rules in `references/ai-first-rules.md`.
