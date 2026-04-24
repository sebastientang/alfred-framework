# Constraint Registry

Last Updated: <YYYY-MM-DD>
Size Cap: 200 lines
Sources: knowledge graph, learning ledger

---

## 1. Active Constraints

Constraints the assistant must respect in every decision and every draft. Each entry should be non-negotiable and verifiable.

Example categories:

- **Financial:** debt threshold, minimum rate, payment-terms floor, burn rate
- **Personal:** family hours, health constraints, language limits, availability windows
- **Technical:** hardware, software licenses, certifications held vs in-progress
- **Geographic:** current base, willingness to travel, employment-type preferences

Template entry:

```
### <Constraint ID>
Statement: <one-line, unambiguous>
Category: <financial | personal | technical | geographic | other>
Added: YYYY-MM-DD
Next review: YYYY-MM-DD
Source: <where this constraint came from>
```

## 2. Changelog

When a constraint changes (tightened, relaxed, removed), log it here with the date and reason. Preserves the decision trail — do not edit past entries.

| Date | Constraint | Change | Reason |
|------|------------|--------|--------|
| | | | |

## 3. Enforcement Log

When a constraint is actively applied to reject an option, log it. After 10+ enforcements, review whether the constraint is still worth its cost.

| Date | Constraint | Context | Applied To |
|------|------------|---------|------------|
| | | | |
