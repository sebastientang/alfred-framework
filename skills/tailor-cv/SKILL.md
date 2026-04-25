---
name: tailor-cv
description: Tailor CV for a specific job description. ATS-optimized HTML output with accent styling. Anti-fabrication enforced.
argument-hint: "[job-description]"
user-invokable: true
---

# /tailor-cv [job-description] — Tailored CV Generation

Execute these steps in order. Complete in <5,000 output tokens. Every claim must trace to master content.

## Anti-Fabrication Rules (non-negotiable)

1. Every bullet must trace to `cv-master-content.md` or its Enrichment Pool
2. **Reframing** = changing emphasis, terminology, or narrative angle of REAL experience
3. **Expanding** = adding authentic context, metrics, or narrative to existing bullets
4. **FORBIDDEN**: inventing roles, clients, projects, metrics, or outcomes
5. Missing requirements = flag as gap, never fill with fiction
6. Personal/side projects described as such, client work as client work
7. Metrics can be approximate (~47%, 30+) but must reflect reality
8. Job titles must match what was actually held
9. Location on CV should match your professional positioning. Adjust as needed for the target market.

## Step 1: Parse Job Description

Accept job description as pasted text or file path. Extract:
- Job title, company name, seniority level
- Language (auto-detect FR/EN from content)
- Key requirements (must-have vs nice-to-have)
- Required skills and technologies
- Industry/domain context
- Derive slug: lowercase company name, no spaces/accents (e.g., "capgemini", "ei-technologies")
- Check if `leads/[slug]/` exists

## Step 2: Load Context (parallel reads)

Read these files in parallel:
- `references/cv-master-content.md` — master CV + enrichment pool
- `references/ats-rules.md` — formatting and quality rules
- `references/cv-template.html` — HTML template

## Step 3: Map & Select

For each job requirement:
1. Find matching experience in master content (exact or adjacent)
2. Score relevance: HIGH (direct match), MEDIUM (transferable), LOW (stretch), NONE (gap)
3. Identify relevant enrichment pool items (AI projects for AI roles, Korean market for APAC, training for L&D)
4. Reorder experience entries by relevance to THIS role (most relevant first within chronological groups)
5. Select which competency categories to highlight vs. minimize
6. Flag hard requirements with NO match as gaps

## Step 4: Generate Tailored CV

Write ALL content in the detected language (translate if needed).

1. **Professional Summary** (3-4 sentences): Position [USER] for THIS specific role. Mirror the job posting's language. Include years of experience, key differentiators relevant to this role, and 1-2 named clients.

2. **Core Skills**: Reorder and emphasize skills matching the job description. Use both acronym AND full term for technical keywords. Group by relevance to the role.

3. **Experience bullets**: Reframe each bullet using the job description's terminology. Apply XYZ formula (accomplished X by doing Y, resulting in Z). Ensure 70%+ have quantified outcomes. Vary verb patterns — no repetitive "Spearheaded... Orchestrated..." structures.

4. **Enrichment integration**: Weave relevant enrichment items naturally into experience or skills sections. Do not create a separate "side projects" section.

5. **Keyword density**: Mirror the job posting's exact phrases where authentic. Target 75%+ coverage of stated requirements.

6. Fill the HTML template (`references/cv-template.html`) with generated content. Replace all `{{PLACEHOLDER}}` markers.

## Step 5: Quality Check

Before presenting, verify ALL of these:
- [ ] ATS: standard section headers (Professional Summary, Professional Experience, Skills, Education, Certifications, Languages)
- [ ] ATS: single-column, linear text flow in DOM order
- [ ] ATS: contact info in body, not header/footer elements
- [ ] Keywords: 75%+ of job description requirements addressed
- [ ] Metrics: 70%+ of experience bullets include quantified outcomes
- [ ] Anti-AI: no repetitive verb patterns, varied sentence structure
- [ ] Anti-AI: no words from the 24 banned list (leverage, synergy, unlock, dive deep, game-changer, cutting-edge, revolutionary, seamless, robust, scalable, innovative, disruptive, empower, transform, streamline, optimize, paradigm, ecosystem, holistic, agile, granular, best-in-class, next-generation, thought leader)
- [ ] Language: consistent throughout (no mixing FR/EN)
- [ ] Authenticity: every claim traceable to source material
- [ ] Length: fits within 2 A4 pages when printed
- [ ] Design: HTML renders with accent colors and typography

## Step 6: Save & Present

1. Create `leads/[slug]/` directory if it doesn't exist
2. Save HTML to `leads/[slug]/cv-[slug].html`
3. Present summary:
   - Key tailoring decisions made
   - Keywords matched vs. total requirements
   - Gaps identified (honest assessment)
   - Any enrichment items woven in
4. Instruct: "Open in browser, print to PDF for submission."
5. If gaps exist, suggest how to address in cover letter or interview
