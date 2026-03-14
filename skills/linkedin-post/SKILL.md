---
name: linkedin-post
description: Generate LinkedIn post with anti-AI voice rules, pillar alignment, and French default. Use this skill when the user says "linkedin post [topic]", "write a linkedin post", "draft linkedin content", or "linkedin carousel [topic]". Do NOT use for X/Twitter posts (use /x-post), general blog writing, outreach messages (use /outreach), or email drafts.
argument-hint: "[topic]"
user-invokable: true
---

# /linkedin-post [topic] — LinkedIn Post Generation

Execute these steps in order. Complete in <2,000 output tokens.

## Step 1: Context Pull
Call in parallel:
- `cc_content_stats` — recent publishing data, gaps, pillar distribution
- Read `Brand_Bible_Appendix.md` §3 — content pillars (educational 30%, conversion 30%, storytelling 20%, insights 10%, flex 10%)
- Read `Brand_Bible_Appendix.md` §6 — voice rules

Determine pillar alignment for the topic.

## Step 2: Generate Draft
Rules (from voice.md and CLAUDE.md):
- **Length:** 900-1,300 characters
- **Language:** French default. English only if explicitly requested.
- **Mobile-first:** First line <140 characters (this is the preview on mobile)
- **No em dashes.** No exclamation marks.
- **Max 3 hashtags** at the bottom, after content.

### 24 Banned Words (NEVER use):
leverage, synergy, unlock, dive deep, game-changer, cutting-edge, revolutionary, seamless, robust, scalable, innovative, disruptive, empower, transform, streamline, optimize, paradigm, ecosystem, holistic, agile, granular, best-in-class, next-generation, thought leader

### Post Structure:
1. **Hook** — first line, <140 chars, no question mark
2. **Body** — 3-5 short paragraphs, one idea each, white space between
3. **Takeaway or soft CTA** — no "DM me" desperation
4. **Hashtags** — max 3, at bottom

### Imperfection Markers (include at least one):
- Sentence fragment
- Colloquial phrasing
- Rhetorical question (in body, not hook)

## Step 3: Anti-AI Check
Verify:
- [ ] No banned words present
- [ ] No em dashes
- [ ] No exclamation marks
- [ ] At least one imperfection marker
- [ ] First line <140 characters
- [ ] Total length 900-1,300 characters
- [ ] Max 3 hashtags at bottom
- [ ] Reads like a human wrote it on their phone

If any check fails, revise before presenting.

## Step 4: Carousel Variant
If `[topic]` includes "carousel":
- Educational/how-to pillar only
- 5-10 slides, 1 key point per slide
- Large text, minimal design
- Generate companion post following the same rules above

## Step 5: Fill Template
Fill `templates/linkedin-post.md`:

```
# LinkedIn Post: [Topic]
Date: [YYYY-MM-DD]
Pillar: [educational/conversion/storytelling/insights]
Type: [post/carousel]
Language: [FR/EN]

## Post
[The actual post content]

## Anti-AI Checklist
- Banned words: PASS/FAIL
- Em dashes: PASS/FAIL
- Exclamation marks: PASS/FAIL
- Imperfection marker: [which one]
- Length: [N] characters
- Hashtags: [N]

## Notes
[Any context about timing, audience targeting, or A/B ideas]
```
