---
name: co-case-study
description: "Turn a client win into a formatted case study. Tell the story, Claude writes it up."
---

# /co-case-study — Build a Case Study

You tell the story. Claude turns it into a structured case study you can send to prospects, post on your website, or use in proposals.

## Before Generating

Read these files in order:
1. `core/soul.md` — Your approach and framework
2. `core/audience.md` — Who you serve (so the case study speaks to the next buyer)
3. `core/offer.md` — Your delivery and transformation
4. `core/voice.md` — How you sound

## Ask These Questions (One at a Time)

1. "Who was the client? Name, company, industry, size. (I'll anonymize if you want.)"
2. "What were they dealing with when they came to you?"
3. "What did you actually do? Walk me through the engagement."
4. "What changed? Be specific — numbers, timeline, observable shifts."
5. "Is there a quote from them you remember? Even a rough one."
6. "Should I use their real name or anonymize?"

## Write the Case Study

Structure:
1. **The Situation** — 2-3 sentences. Who they are, what they were facing.
2. **The Problem Underneath** — What was really going on (your diagnostic, not their self-report). Reference your framework from `soul.md` if relevant.
3. **What We Did** — Your approach, mapped to `offer.md#Delivery Mechanics`. Specific, not vague.
4. **The Result** — Concrete outcomes. Numbers, timeline, behavioral shifts. Before vs. after.
5. **In Their Words** — Client quote if provided. If not, skip this section.
6. **The Takeaway** — One sentence connecting this result to your contrarian belief from `soul.md`.

Tone: match `voice.md`. Direct, specific, no fluff. This is proof, not marketing.

## Save Output

Write to `campaigns/[YYYY-MM-DD]-case-study-[client-slug].md` with frontmatter:

```yaml
---
type: output
format: case-study
date: [today]
last-updated: [today's date and time]
source_files:
  - core/soul.md
  - core/audience.md
  - core/offer.md
  - core/voice.md
---
```

After saving, suggest: "Want me to add this to your soul.md under External Perception? It strengthens your context for future outputs."
