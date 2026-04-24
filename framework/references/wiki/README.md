# Wiki Synthesis Layer

Persistent, compounding knowledge pages that synthesize raw tracking data into actionable intelligence. Inspired by [Karpathy's LLM Wiki pattern](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f).

## Principle

Wiki pages contain zero primary data. They are derived synthesis views of tracking files, deal retros, learning ledger, and CRM data. If deleted, they can be regenerated from source files.

## Pages

| Page | Synthesizes | Updated By |
|------|-------------|------------|
| `outreach-playbook.md` | outreach log + deal retros + learning ledger | Weekly review, outreach intelligence passes, deal retros |
| `pipeline-patterns.md` | deal retros + wins + learning ledger | Weekly review, deal retros, debriefs |
| `constraint-registry.md` | knowledge graph + learning ledger | Monthly context refresh, decision triggers, closeouts |
| `relationship-topology.md` | leads notes + patterns + feedback files | Weekly review, debriefs, briefings (read-only) |
| `learning-synthesis.md` | learning ledger, indexed by domain | Weekly review, closeouts |

## Operations

- **Ingest:** Rule 20 (Knowledge Synthesis Routing) in `behavior.md` routes new facts to the relevant wiki page. Writes are conditional, not mandatory — the target is 60-70% of ingest events trigger zero wiki writes.
- **Lint:** weekly (lightweight) and monthly (deep). Catches contradictions between pages, orphan references to deleted tracking files, semantic staleness.
- **Query feedback:** when the assistant synthesizes a novel insight during outreach, decisions, or meeting prep, it files back into the relevant wiki page.

## Size Caps

Each page has a hard line cap in its header (typically 150-250 lines). When exceeded, trim the oldest section first during the monthly recompute. The cap is a forcing function — it prevents pages from becoming append-only log dumps.

## Template Structure

All pages share a consistent header format:

```markdown
# <Page Name>

Last Updated: YYYY-MM-DD
Size Cap: N lines
Sources: <comma-separated list of source tracking files>

---

## 1. <First synthesis section>
...
```

Pages below ship with empty section stubs. Populate them as your tracking data accumulates — wiki pages are meant to grow from real evidence, not be pre-filled with speculation.
