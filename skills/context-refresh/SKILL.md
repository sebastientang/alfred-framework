---
name: context-refresh
description: Monthly context refresh — walk through context-updates.md, apply entries to reference docs, archive processed entries, check freshness rules.
user-invokable: true
---

# /context-refresh — Monthly Context Maintenance

Execute these steps in order. This is a monthly maintenance skill (first Monday of each month).

## Step 1: Read Pending Updates
Read `tracking/context-updates.md` in full. Group entries by target:
- BUSINESS entries → to be applied to `BUSINESS.md`
- PERSONAL entries → to be applied to `PERSONAL.md`
- Untagged entries → classify based on content

Display the grouped entries for review before applying.

## Step 2: Apply Updates
For each entry:
1. Show the entry and the target section in BUSINESS.md or PERSONAL.md
2. Show the proposed edit (what will change)
3. Wait for confirmation: "Apply all" or review one-by-one

After confirmation:
- Edit the target files with the new information
- Mark each entry as processed

## Step 3: Archive Processed Entries
Move processed entries from `tracking/context-updates.md` to `archives/context-updates-YYYY-MM.md`:
- Create the archive file if it doesn't exist
- Append processed entries with their original timestamps
- Remove them from `tracking/context-updates.md`
- Keep any unprocessed entries in place

## Step 4: Freshness Audit
Check all tracking files against freshness rules (from self-optimization.md):

| File | Stale after | Status |
|------|------------|--------|
| tracking/outreach-log.md | 3 days no entries | Check last entry date |
| tracking/leads-notes.md | 7 days no updates | Check last modification |
| tracking/fitness.md | 7 days no gym log | Check last entry |
| tracking/certifications.md | 14 days no study hours | Check last entry |
| tracking/admin-tasks.md | 14 days no status change | Check for stale items |
| tracking/context-updates.md | 30 days no entries | Just processed, reset clock |
| references/contacts.md | 30 days no updates | Check last modification |
| goals/quarterly.md | 90 days without rewrite | Check quarter alignment |

Display results as green/yellow/red dashboard.

## Step 5: Report
Output summary:
- N entries applied to BUSINESS.md
- N entries applied to PERSONAL.md
- N entries archived
- Freshness dashboard (green/yellow/red per file)
- Any recommended actions for stale files
