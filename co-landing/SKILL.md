---
name: co-landing
description: "Generate landing page copy from your Context files."
---

# /co-landing — Generate Landing Page Copy

Creates landing page copy that converts because it's built on real context, not templates.

## Before Generating

Read these files in order:
1. `core/soul.md` — Who you are
2. `core/audience.md` — Who you serve
3. `core/offer.md` — What you sell
4. `core/voice.md` — How you sound
5. `.codify/design.md` — brand colours, fonts, style (if it exists)

Also scan `decisions/` and `research/` for recent entries.

**Prerequisite gate (run before generating — enforce the order of operations, don't skip upstream steps):**

1. **Offer integrity.** If any core file (especially `offer.md`) is `status: draft` or thin → stop and route to `/co-extract`; don't generate from a thin substrate. For a deeper read, `/co-money-path` names the bottleneck closest to the next dollar.
2. **Design system (visual output only).** If this run produces deployable markup or visual styling and `.codify/design.md` is missing → recommend `/co-site` to author the design system first, so the page matches the site and other assets. Proceed copy-only only if the architect confirms.

## What to Generate

Ask: "What's the goal — book a call, download something, or buy directly?"

Sections:
1. **Hero** — Headline + subheadline. Lead with the transformation from `offer.md`.
2. **Problem** — 3 pain points in the audience's own words from `audience.md#Voice of Customer`.
3. **Failed alternatives** — What they've tried from `audience.md#Failed Alternatives`.
4. **Solution** — Your approach from `soul.md`, framed as the answer.
5. **How it works** — Delivery mechanics from `offer.md`, simplified to 3 steps.
6. **Proof** — Testimonials from `soul.md#External Perception`.
7. **Guarantee** — From `offer.md#Guarantee`.
8. **CTA** — One clear action matching the goal.

Tone: match `voice.md`. No hype, no filler.

If the output includes any visual direction (markup, colours, fonts, section styling), render it from `.codify/design.md` if it exists — the locked design system governs colours, type, and component style so this page matches the site and ads. If `design.md` is absent, write copy only and note that the design system is missing.

## Save Output

Write to `campaigns/[YYYY-MM-DD]-landing-[slug].md` with frontmatter:

```yaml
---
type: output
format: landing
date: [today]
last-updated: [today's date and time]
source_files:
  - core/soul.md
  - core/audience.md
  - core/offer.md
  - core/voice.md
  - .codify/design.md
---
```
