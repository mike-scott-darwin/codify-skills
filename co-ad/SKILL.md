---
name: co-ad
description: "Generate ad copy (Facebook/Instagram/Meta) from your Context files."
---

# /co-ad — Generate Ad Copy

Creates ad copy that sounds like you, speaks to your buyer, and sells your offer.

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
2. **Design system (visual output only).** If this run produces visual direction or image concepts and `.codify/design.md` is missing → recommend `/co-site` to author the design system first, so the ad matches the site and other assets. Proceed copy-only only if the architect confirms.

## What to Generate

- 3 hook variations (pattern-interrupt opening lines)
- Primary copy body (150-200 words)
- Call to action
- Suggested headline and description for Meta ad format

The copy must:
- Use the client's voice and signature phrases from `voice.md`
- Reference the specific transformation from `offer.md`
- Address the audience's pain points using their language from `audience.md`
- Reflect core beliefs from `soul.md`

Any visual direction (image concepts, `<!-- IMAGE: -->` markers, suggested colours or type for a designer or image model) must render from `.codify/design.md` if it exists — colours, fonts, and component style come from the locked design system, not invented per ad. If `design.md` is absent, proceed on voice/offer alone and note that the design system is missing.

## Save Output

Write to `campaigns/[YYYY-MM-DD]-ad-[slug].md` with frontmatter:

```yaml
---
type: output
format: ad
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
