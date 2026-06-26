---
name: co-proposal
description: "Generate a client proposal from your Context files."
---

# /co-proposal — Generate Client Proposal

Creates a proposal that frames your offer around the specific prospect's situation.

## Before Generating

Read these files in order:
1. `core/soul.md` — Who you are
2. `core/audience.md` — Who you serve
3. `core/offer.md` — What you sell
4. `core/voice.md` — How you sound

Also scan `decisions/` and `research/` for recent entries.

If any Context file has `status: draft` or is mostly empty, warn:
"Your [file] is thin. Output quality will improve if you run `/co-extract [file]` first. Generate anyway?"

## What to Generate

Ask: "Who is this proposal for? Tell me their name, company, and what they're struggling with."

Structure:
1. **The Situation** — Mirror back what the prospect told you (2-3 sentences)
2. **The Problem Underneath** — What they're really dealing with, informed by `audience.md`
3. **What We'll Do** — Delivery mechanics from `offer.md`, personalized to their situation
4. **What Changes** — Transformation from `offer.md`, made specific to them
5. **The Guarantee** — From `offer.md`
6. **Investment** — Ask the client for the price, or pull from `offer.md` if available
7. **Next Step** — One clear action

Tone: direct, confident, no fluff. Match `voice.md`.

## Save Output

Write to `campaigns/[YYYY-MM-DD]-proposal-[slug].md` with frontmatter:

```yaml
---
type: output
format: proposal
date: [today]
last-updated: [today's date and time]
source_files:
  - core/soul.md
  - core/audience.md
  - core/offer.md
  - core/voice.md
---
```
