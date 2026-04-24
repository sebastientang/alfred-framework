# Changelog

All notable changes to the Alfred Framework are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] — 2026-04-24

### Added

- **Six new behavioral rules (20-25)** in `framework/rules/behavior.md`:
  - Rule 20 — Knowledge Synthesis Routing: conditional writes to derived synthesis pages that compound knowledge across cycles (target: 60-70% of ingest events trigger zero writes).
  - Rule 21 — Reply Drafter Routing: separates cold outreach from active-thread replies so `last_touch_at` and cold-outreach counters stay accurate.
  - Rule 22 — Active-Pipeline Context Pull: mandatory pre-draft pull of deal state, interaction history, and tracking files before drafting any external message to an active-pipeline contact.
  - Rule 23 — Candidate-Perspective Gate: 3-check filter (technical alignment, declared ambition, constraint registry) for job-pursuit positioning angles.
  - Rule 24 — Timezone Math Verification: canonical timezone table and side-by-side format for call-time proposals. Flags user-submitted drafts with incorrect offsets.
  - Rule 25 — Voice Pre-Scan on User-Submitted Drafts: automated scan for exclamation marks, emoji, kaomoji, em dashes, filler words, banned marketing words, ASCII-fallback accents, grammar, and unanchored relative dates. Always presents a fixed version.

- **Wiki synthesis layer scaffold** at `framework/references/wiki/` — 5 template pages (outreach-playbook, pipeline-patterns, constraint-registry, relationship-topology, learning-synthesis) plus a README explaining the synthesis pattern. Each page ships with a size cap (150-250 lines) and empty section stubs.

- **Four new skills:**
  - `/reply` — channel- and length-aware reply drafter for active threads. Hard word cap is `min(channel norm, inbound length × 1.5)` to prevent verbose replies on casual channels.
  - `/handoff` — pre-`/clear` dev-session summary. Chat-only. Absolute paths. Background process IDs preserved for the next agent.
  - `/humanizer` — AI-writing-pattern scrubber based on Wikipedia's "Signs of AI writing" guide. Domain-agnostic. Includes voice calibration against user-provided writing samples.
  - `/prose-fr` — French prose proofreader covering voice rules (accents mandatory, no em dashes, no exclamation marks), AI patterns specific to French (nominalization, empty connectors, corporate AI vocabulary), and grammar checks.

- **Voice rules** in `framework/rules/voice.md`:
  - Pre-scan gate reference for user-submitted drafts (points to Rule 25 for the full check table).
  - Expanded 38-word banned-word list with a note on maintaining per-language equivalents (French examples included).

### Fixed

- Removed a leaked Windows filesystem path referencing a non-maintainer's desktop in `skills/nano-banana-images/SKILL.md`. Replaced with a neutral pointer to official documentation and a note for adopters to link their own reference guide.

## [0.1.0] — 2026-04-19

Initial public release of the Alfred Framework. 3 core rules files (behavior, voice, self-optimization), 35 skills, 8 agents, example configuration for a freelance-consultant setup.
