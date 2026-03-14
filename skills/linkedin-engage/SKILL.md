---
name: linkedin-engage
description: Parse LinkedIn digest from Gmail, extract posts, push to CC queue, score relevance, draft comments, review/approve/dismiss
user-invocable: true
---

# LinkedIn Engage

Trigger: `"linkedin engage"` or `"linkedin comments"`

## Phase A — Source Posts from Gmail Digest

1. Search for LinkedIn digest emails:
   ```
   gmail_search_messages q: "from:messages-noreply@linkedin.com is:unread" max_results: 5
   ```

2. For each digest email found:
   - `gmail_read_message` to get the full HTML body
   - Parse HTML to extract:
     - **Post URLs:** Look for `href` attributes containing `linkedin.com/feed/update/` or `linkedin.com/posts/`
     - **Author names:** Text near each post link (typically in bold or heading elements)
     - **Text snippets:** Post content preview text
   - Extraction patterns to try (LinkedIn digest HTML varies):
     - URLs: regex `https?://(?:www\.)?linkedin\.com/(?:feed/update/urn:li:activity:\d+|posts/[^"&\s]+)`
     - Author: text in `<strong>` or `<b>` tags preceding post content
     - Text: paragraph text between author name and next post block

3. For each extracted post:
   - Call `cc_linkedin_queue_create` with: post_url, post_text (snippet), post_author, source="digest"
   - Auto-links to tracked account if author matches `cc_linkedin_accounts_list`
   - Skip duplicates gracefully (API returns "already in queue" — ignore and continue)

4. If no digest emails found:
   - Tell user: "No unread LinkedIn digests found. You can add posts manually with `comment on [url]`."
   - Still proceed to Phase B to check for any pending queue entries.

## Phase B — Score and Draft Comments

5. Pull pending queue entries:
   ```
   cc_linkedin_queue_list status: "pending" limit: 20
   ```

6. If empty queue:
   - "No pending posts to score. Queue is clean."
   - Show stats: `cc_linkedin_queue_stats`
   - Stop.

7. For each pending post, score relevance (0-100) based on:
   - **Pillar alignment:** Does the post topic match your pillars (as defined in Brand_Bible.md)?
   - **Author value:** Is the author a tracked account? High priority? Influencer (visibility) vs contact (relationship)?
   - **Post recency:** Recent posts get higher scores (commenting on old posts looks weird)
   - **Engagement opportunity:** Does the post invite discussion, share an opinion, or raise a question?

8. For posts scoring >= 50, draft a comment following these voice rules:
   - **Length:** 50-300 characters
   - **Language:** Match post language (FR post = FR comment, EN post = EN comment)
   - **Style:** Contrarian insight, personal experience, or specific question — never generic agreement
   - **Banned:** No links, no hashtags, no self-promotion, no "Great post!" / "Love this!"
   - **24 banned words:** leverage, synergy, unlock, dive deep, game-changer, cutting-edge, revolutionary, seamless, robust, scalable, innovative, disruptive, empower, transform, streamline, optimize, paradigm, ecosystem, holistic, agile, granular, best-in-class, next-generation, thought leader
   - **Anti-AI markers:** Include at least one: imperfect phrasing, contraction, sentence fragment, or conversational tone
   - **Add value:** The comment should make the author want to reply or at minimum notice your name

9. Update each entry via `cc_linkedin_queue_update`:
   - relevance_score, comment_draft, comment_reasoning
   - status = "drafted" (if scored >= 50 and comment drafted)
   - status = "dismissed" (if scored < 50, with reasoning)

## Phase C — Review and Approve

10. Present a table of drafted comments:

```
| # | Author | Post snippet (50 chars) | Draft comment | Score |
|---|--------|------------------------|---------------|-------|
```

11. For each entry, ask: **approve / edit / dismiss**
    - **Approve:** `cc_linkedin_queue_update` status="approved"
    - **Edit:** Show current draft, accept edit, then `cc_linkedin_queue_update` with new draft + status="approved"
    - **Dismiss:** `cc_linkedin_queue_update` status="dismissed"

12. After review, offer to post approved comments:
    - "X comments approved. Post them now?"
    - If yes: for each approved entry, `cc_linkedin_queue_post`
    - Note: requires LinkedIn OAuth connected and post URN set. If URN missing, flag it.

13. If any author is a pipeline contact (check against contacts.md or cc_pipeline_list):
    - Log touch in outreach-log.md
    - Note: "Engaged with [name]'s LinkedIn post — relationship warming"

## Manual Entry Mode

If triggered with `"comment on [url]"`:
1. `cc_linkedin_queue_create` with: post_url=[url], source="manual"
2. Skip Phase A, jump to Phase B for just this entry
3. Ask for post text if not available (LinkedIn API can't read others' posts)
