# Brand Voice Rules — Gate Reference

> This file is the single source of truth for `/brand-voice-check`.
> Keep it tight: only voice gate rules. No marketing strategy, ICP, or outreach templates.
> To add French rules, expand the `## Forbidden Phrases — French` section following the English structure.

---

## Brand Voice Patterns (MUST USE)

These structural patterns define the voice. Medium and long-form content should use them.

| Pattern | Structure |
|---------|-----------|
| Root cause reframe | "The problem isn't [surface issue]. The problem is [root cause]." |
| Experience proof | "I've seen this pattern at [client]. What happened was [specific outcome]." |
| Strategic framing | "There are three ways to approach this. Only one of them survives past [constraint]." |
| Contrarian insight | "Most architects [common approach]. That works until [breaking point]." |
| Direct assertion | "[Direct assertion]. Here's why." |

## Forbidden Phrases — English (HARD FAIL)

Any exact match or semantic equivalent triggers a hard fail.

### AI Filler / Landscape Openers
- "In today's rapidly evolving Salesforce landscape..."
- "In today's rapidly evolving..." (any variant)
- "In the ever-changing world of..."
- "As we navigate the complexities of..."
- "In this day and age..."

### Engagement Bait
- "Are you struggling to unlock the full potential of...?"
- "Are you struggling to...?"
- "Ready to take your ... to the next level?"
- "Want to supercharge your...?"

### Fake Enthusiasm
- "Let's dive deep into this exciting topic!"
- "Let's dive in!"
- "Let's dive deep..."
- "I'm excited to share..."
- "This is a game-changer!"

### Empty Connectors
- "It's important to note that..."
- "It goes without saying..."
- "At the end of the day..."
- "Without further ado..."

### Non-Answers
- "There's no one-size-fits-all answer"
- "It depends on your specific needs"
- "Every organization is different"

### Hedging Language
- "I think"
- "perhaps"
- "it might be"
- "it could potentially"
- "I would argue that"
- "in my humble opinion"

### False Candor
- "genuinely"
- "honestly"
- "straightforward"

### Buzzwords
- "leverage" (as a verb)
- "utilize" (use "use")
- "synergy"
- "unlock potential"
- "unlock value"
- "drive value"
- "best-in-class"
- "cutting-edge"
- "game-changer"
- "paradigm shift"
- "low-hanging fruit"
- "move the needle"
- "circle back"
- "deep dive" (as a noun)
- "holistic approach"
- "robust solution"
- "seamless integration"
- "scalable solution"
- "empower" / "empowering"
- "elevate"
- "optimize" (when used as filler — acceptable when describing a specific technical optimization)
- "streamline"
- "revolutionize"
- "delve"
- "tapestry"
- "landscape" (when used as filler — acceptable for literal geographic context)
- "harness"
- "foster"
- "bolster"
- "multifaceted"
- "nuanced" (when used as filler — acceptable in genuine analytical context)
- "groundbreaking"
- "transformative"
- "navigate" (when used as filler — acceptable for literal UI/UX navigation)
- "pivotal"

### AI Filler Phrases
- "it's important to note"
- "in today's ever-evolving"
- "in conclusion"
- "a testament to"
- "deep dive into"
- "i'm thrilled to"
- "i'm excited to"
- "let me tell you"
- "it's worth noting"

### Punctuation
- Exclamation marks (!) — zero tolerance, anywhere in content

## Forbidden Phrases — French (HARD FAIL)

Apply when content is detected as French. Same severity as English rules.

### Ouvertures génériques
- "Dans le paysage en constante évolution..."
- "Dans un monde en perpétuelle mutation..."
- "À l'ère de la transformation digitale..."
- "Dans le contexte actuel..."

### Appâts engagement
- "N'hésitez pas à..."
- "Vous souhaitez tirer le meilleur parti de...?"
- "Prêt à passer au niveau supérieur ?"
- "Envie de booster votre...?"

### Faux enthousiasme
- "Permettez-moi de partager..."
- "J'ai le plaisir de..."
- "C'est avec enthousiasme que..."
- "Quelle belle opportunité !"

### Connecteurs creux
- "Il est important de noter que..."
- "Il convient de souligner que..."
- "Force est de constater que..."
- "Il va sans dire que..."

### Langage hésitant
- "Je pense que"
- "peut-être"
- "il se pourrait que"
- "on pourrait envisager"
- "il me semble que"
- "à mon humble avis"

### Fausse sincérité
- "sincèrement"
- "honnêtement"
- "en toute transparence"
- "pour être tout à fait franc"

### Mots à la mode
- "levier" (comme verbe — "utiliser comme levier")
- "synergie"
- "libérer le potentiel"
- "créer de la valeur"
- "best-in-class" (anglicisme)
- "game-changer" (anglicisme)
- "disruptif" / "disrupter"
- "holistique"
- "agile" (hors contexte méthodologique)
- "écosystème" (quand utilisé comme remplissage)

### Ponctuation
- Points d'exclamation (!) — tolérance zéro

## Tone Definition

**IS:** Strategic directness. Structured reasoning. Evidence over assertion. Calm authority. Practical above all. Forward-looking.

**IS NOT:** Hype. Urgency manufacturing. Filler. Marketing copy. Inspirational fluff. Hedging. Generic advice anyone could give.

**Proof point rule:** Every claim must be backed by a specific proof point — client name, metric, or outcome. Generic assertions ("major enterprise client", "significant improvement") are warnings. Insert `[CLIENT/METRIC]` placeholder when a proof point is needed.

## Content Tier Thresholds

| Tier | Word Count | Checks Applied |
|------|-----------|----------------|
| Short | < 500 | Forbidden phrases + tone only |
| Medium | 500 - 1500 | Above + at least 1 brand voice pattern + proof points on claims |
| Long | 1500+ | Above + 2+ brand voice patterns + every claim backed + no generic filler |