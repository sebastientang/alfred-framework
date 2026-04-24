---
name: reply
description: "Draft a single voice-tuned reply to an inbound message (chat, DM, email, any channel). Stripped-down version of the outreach skill with no angle selection, no CRM writes, no follow-up scheduling. Channel- and length-aware: a 3-word chat message gets a 3-word reply, a 200-word email gets a 200-word reply. Use this skill for replies to active conversations, NOT for cold outreach."
argument-hint: "[sender] [optional channel] --- [inbound message text]"
user-invokable: true
---

# /reply — Fast Reply Drafter

One job: turn an inbound message into a single voice-tuned, channel-appropriate reply draft. Target: under 30 seconds, under 800 output tokens, zero pipeline ceremony.

**The failure mode this skill exists to prevent:** drafting a thoughtful 280-word reply to a casual chat message. The substance might be perfect, but the format screams AI. People type short on chat. They type long on email. `/reply` enforces the difference mechanically.

## Step 0 — Parse arguments

Invoked via `/reply`. Parse arguments:

- Format: `[sender] [optional channel] --- [inbound text]` or just `[inbound text]`
- If sender is missing: ask once "Who is this from?" (one short question, then proceed)
- If channel is missing: infer from the contact record if one exists, otherwise default to a LinkedIn DM register (the safe middle)
- If only inbound text is pasted with no `---` separator: treat the whole input as the inbound message and ask for the sender's name

## Step 1 — Resolve sender (best-effort, non-blocking)

Query your CRM or contact store for the sender:

- If found, extract: `preferred_channel`, `preferred_language` (EN/FR/other), `relationship` (colleague / client / recruiter / lead / personal / other), `notes` (last 500 chars), `last_touch_at`
- If multiple matches, pick the most recently touched. Do not block on disambiguation.
- If not found, proceed without contact context. The inbound text is the primary signal.

## Step 2 — Load thread context (optional, parallel with Step 1)

- If the contact resolved AND `last_touch_at` is within 30 days: pull the 5 most recent touches with this contact for thread tone.
- If the channel is email or the sender contains `@`: grep your email archive for the thread. Skip otherwise — most replies happen on chat/DM channels and email queries are slow.
- Both steps are best-effort. Errors or empty results are fine — proceed.

## Step 3 — Channel and register inference (mandatory pre-draft check)

This is the critical step. Lock in two caps from the inbound message itself, not from defaults.

### 3a. Channel norm cap

| Channel | Word cap | Format rules |
|---|---|---|
| Chat (WhatsApp, SMS, iMessage, KakaoTalk, etc.) | **60 words** | 1-4 short lines. Casual register. No headers, no bullet lists, no signature. Sentence fragments allowed. One thought per line. No links unless the inbound asked. |
| LinkedIn DM | **120 words** | 2-4 short paragraphs. Professional but not formal. No subject. No "Dear X". No signature. |
| Email | **inbound length × 1.2 (clamp 80-300)** | Standard prose. May include subject line. Signature optional. |
| Slack / Teams | **100 words** | 1-3 short paragraphs. Mirror the team's tone. |
| Unknown | **120 words** (LinkedIn DM default) | Safe middle. |

### 3b. Inbound mirroring cap

Measure the inbound: word count, paragraph count, register (casual / professional / formal), depth (one-liner / substantive / essay).

The reply must NOT exceed inbound length × 1.5. If they sent 30 words, you reply with 20-50, never 200. If they sent a one-liner, you reply with a one-liner. If they wrote an essay, you have permission to be substantive but never longer than them.

### 3c. The hard cap

```
hard_cap = min(channel_cap_3a, inbound_length × 1.5)
```

This is the number you enforce in Steps 4 and 5. Whichever is shorter wins.

**Mirroring examples:**

- Inbound chat 3 words → reply 3-6 words (NOT a paragraph)
- Inbound LinkedIn DM 60 words → reply 40-90 words
- Inbound email 200 words with 3 questions → reply 150-220 words answering the questions
- Inbound email 30-word one-liner → reply 20-45 words (the channel allows more, but the inbound caps it)

## Step 4 — Draft

If a drafter agent exists (e.g., `outreach-drafter`), invoke it with this framing:

```
APPROACH: reply to active thread (NOT cold outreach, NOT a first touch)

Inbound message:
[paste full inbound text]

Sender: [name] | Relationship: [from contact store, default "unknown"] | Language: [EN unless inbound is FR or sender's preferred_language is FR]

Channel: [resolved channel from Step 3a]
Hard word cap: [hard_cap from Step 3c]
Inbound register: [casual / professional / formal]

Constraints:
- This is a reply to a live conversation. The inbound is the context. Do not invent a value-add hook unless the inbound left a question or topic dangling.
- Match the register of the inbound. If casual, be casual (sentence fragments OK). If formal, be standard prose.
- HARD CAP: [hard_cap] words. Going over is failure.
- One purpose. No padding. No "happy to chat further" filler.

Return: a single draft, no preamble, no markdown headers, no metadata wrapper. Just the message text.
```

If no drafter agent is available, draft inline following the same constraints. The drafter agent should enforce the banned-word list, channel formatting, language detection, and brevity — `/reply` just feeds it the right context.

## Step 5 — Channel-fit guard (mandatory post-draft check)

After receiving the draft:

1. Count the words in the draft body (exclude any optional subject line for emails).
2. If `word_count > hard_cap`: re-invoke the drafter ONCE with: `"Previous draft was [N] words, hard cap is [hard_cap]. Cut to under [hard_cap] by removing the least essential clause. Keep the personality and the specific reference to the inbound. Return the new draft only."`
3. If the second pass still exceeds the cap: hard-truncate to the most important sentence(s) and append `WARNING: drafter exceeded cap, manually trimmed` to the output metadata line.

This guard exists because LLMs (this one included) drift toward verbose replies under pressure. The cap must be enforced mechanically, not as a polite suggestion.

## Step 6 — Output

Output a clean, copy-paste-ready block. One line of metadata above, one line of guidance below. No emojis, no preamble.

```
Sender: [name] | Channel: [channel] | Register: [casual/professional/formal] | Length: [N] words (cap: [M])

[draft text]

Paste into [channel]. Say "redraft [direction]" for a different angle.
```

## Step 7 — No silent side effects

Do NOT:

- Write a touch record to your CRM — replies to active threads pollute the cold-outreach counter and break weekly nag math (target: N cold outreaches per week, not N back-and-forths in one thread)
- Update `last_touch_at` — that field should reflect the start of the conversation, not every message in it
- Create follow-up tasks — fixed cadences apply to cold outreach only
- Append to the outreach analytics log — that file is the cold-outreach corpus

This is enforced by Rule 21 (Reply Drafter Routing) in `behavior.md`.

**Manual override:** if the user explicitly says "log this reply as a touch" (e.g., the reply is a major commitment or stage event), log it once. Otherwise stay quiet.

## Quick redraft loop

If the user says "redraft [direction]" within the same session:

- Re-invoke the drafter with the new direction added to the constraints
- Same hard cap from the original Step 3 (don't recompute)
- Same Step 5 guard
- One pass, no chain

## Token Budget

Under 800 output tokens for the full skill execution. The draft itself is the user-facing output; everything else is one metadata line plus one guidance line.

## What this skill is NOT

- Not for cold outreach — use `/outreach`
- Not for reactivating dormant contacts — use `/outreach` with a reactivation framing
- Not for proposals — use `/proposal`
- Not for LinkedIn posts — use `/linkedin-post`
- Not a thread historian — replies don't get logged as touches
