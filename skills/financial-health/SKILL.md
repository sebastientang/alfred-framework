---
name: financial-health
description: Financial health dashboard — pulls income from mobile sync, expenses from PERSONAL.md, pipeline-weighted revenue, and calculates runway.
user-invokable: true
---

# /financial-health — Financial Health Dashboard

Execute all data pulls in parallel. Output a single dashboard. <1,500 output tokens.

## Step 1: Data Collection (parallel)
- Read `PERSONAL.md` — monthly expenses (~4,400 EUR), fixed costs breakdown
- Call `cc_pipeline_list` — all active deals with stages and estimated values
- Fetch pending notes from mobile: GET `https://[YOUR_MOBILE_SYNC_URL]/api/pending-notes` (use token from `~/.alfred-mobile-token`)
  - Filter for "INCOME:" prefix notes — these are revenue events logged via mobile

## Step 2: Income Calculation
- Sum all INCOME: entries for current month
- If no income entries found, income MTD = 0

## Step 3: Pipeline Revenue Forecast
Apply stage-based probability weights to active pipeline deals:

| Stage | Probability |
|-------|------------|
| identified | 5% |
| contacted | 10% |
| meeting | 25% |
| proposal | 50% |
| negotiation | 75% |
| won | 100% |

Calculate: sum of (deal_value * probability) for all active deals.

## Step 4: Runway Calculation
- Monthly burn: from PERSONAL.md
- Income MTD: from Step 2
- Projected income: pipeline-weighted from Step 3
- Runway (weeks): available_cash / (weekly_burn - weekly_income_rate)
- Status: GREEN (>8 weeks), YELLOW (4-8 weeks), RED (<4 weeks)

## Step 5: Output
```
FINANCIAL HEALTH — [YYYY-MM-DD]

BURN RATE
- Monthly expenses: [amount] EUR
- Weekly burn: [amount] EUR

INCOME
- MTD: [amount] EUR ([source breakdown])
- Pipeline-weighted forecast: [amount] EUR

PIPELINE VALUE
[stage] | [deal count] | [total value] | [weighted value]
...
Total weighted: [amount] EUR

RUNWAY
- Status: [GREEN/YELLOW/RED]
- Estimated runway: [N] weeks
- Break-even requires: [amount] EUR/month

ACTION REQUIRED
- [If RED: specific urgent action]
- [If YELLOW: pipeline acceleration recommendation]
- [If GREEN: optimization suggestion]
```
