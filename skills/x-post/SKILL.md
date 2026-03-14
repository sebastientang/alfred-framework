---
name: x-post
description: Generate X/Twitter post (tweet or thread) with anti-AI voice rules, 280-char limit, contrarian voice, English only.
argument-hint: "[topic]"
user-invokable: true
---

# /x-post [topic] — X/Twitter Post Generation

Execute these steps in order. Complete in <2,000 output tokens.

## Step 1: Context Pull
Call in parallel:
- `cc_content_stats` — recent publishing data, gaps, pillar distribution
- Determine pillar alignment for the topic
- Determine format: **thread** if educational_howto pillar, **tweet** for everything else

## Step 2: Determine Format

### Single Tweet (all pillars except educational_howto)
- **Length:** Max 280 characters. Hard limit.
- **Language:** English only.
- **No em dashes.** No exclamation marks.
- **No hashtags required** (X algorithm doesn't reward them).

### Thread (educational_howto pillar only)
- **Length:** 7 tweets, each max 280 characters.
- **Structure:** Hook → Problem → Framework (3 steps) → Proof/Example → Soft CTA
- **Hook tweet:** Under 200 characters for maximum impact.
- **Each tweet stands alone** — readers may see any tweet in isolation.
- **No consecutive tweets with links.**

## Step 3: Generate Draft

### Voice Rules (X-specific):
- **Contrarian, debate-oriented.** "Here's why you're wrong" energy.
- **Raw and punchy.** Shorter sentences than LinkedIn.
- **No corporate speak.** Write like texting a smart friend.
- **Imperfection markers mandatory** (at least one): sentence fragment, colloquial phrasing, rhetorical question.

### 24 Banned Words (NEVER use):
leverage, synergy, unlock, dive deep, game-changer, cutting-edge, revolutionary, seamless, robust, scalable, innovative, disruptive, empower, transform, streamline, optimize, paradigm, ecosystem, holistic, agile, granular, best-in-class, next-generation, thought leader

### 33 Banned Phrases (NEVER use):
here's the thing, let me be clear, at the end of the day, it goes without saying, in today's world, the reality is, make no mistake, the truth is, let that sink in, read that again, I'll say it louder, hot take, unpopular opinion, controversial take, this is huge, game over, wake up call, no one talks about, the secret is, most people don't know, stop doing X start doing Y, the biggest mistake, here's what no one tells you, the harsh truth, if you're not doing X, X is dead, the future of X is, I've been saying this for years, call me crazy but, I don't care what anyone says, this changed everything, I was wrong about, this is the way

## Step 4: Anti-AI Check
Verify:
- [ ] No banned words present
- [ ] No banned phrases present
- [ ] No em dashes
- [ ] No exclamation marks
- [ ] At least one imperfection marker
- [ ] Each tweet ≤ 280 characters
- [ ] Thread hook < 200 characters (if thread)
- [ ] English only
- [ ] Reads like a human wrote it on their phone
- [ ] Max 40% of tweets have links (if thread)

If any check fails, revise before presenting.

## Step 5: Fill Template

### For Single Tweet:
```
# X Post: [Topic]
Date: [YYYY-MM-DD]
Pillar: [personal_storytelling/educational_howto/industry_insights/conversion_offer/achievements]
Type: tweet
Language: EN
Characters: [N]/280

## Tweet
[The actual tweet content]

## Anti-AI Checklist
- Banned words: PASS/FAIL
- Banned phrases: PASS/FAIL
- Em dashes: PASS/FAIL
- Imperfection marker: [which one]
- Length: [N] characters

## Notes
[Any context about timing or angle]
```

### For Thread:
```
# X Thread: [Topic]
Date: [YYYY-MM-DD]
Pillar: educational_howto
Type: thread
Language: EN
Tweets: [N]

## Thread
### Tweet 1 (Hook) — [N] chars
[content]

### Tweet 2 — [N] chars
[content]

[... repeat for each tweet ...]

## Anti-AI Checklist
- Banned words: PASS/FAIL
- Banned phrases: PASS/FAIL
- Em dashes: PASS/FAIL
- All tweets ≤ 280 chars: PASS/FAIL
- Hook < 200 chars: PASS/FAIL
- Imperfection marker: [which one]

## Notes
[Any context about timing or angle]
```
