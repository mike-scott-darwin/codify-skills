---
name: co-pitch
description: "Generate the things you say in a sales conversation — elevator pitch, event intro, podcast bio, speaker page, and objection responses. Multiple lengths from the same context."
---

# /co-pitch — Craft Your Pitch (and Handle Objections)

Creates versions of "what you do" for different situations — plus grounded responses to the objections that stall deals. All grounded in your Context files so every version sounds like you.

## Before Generating

Read these files in order:
1. `core/soul.md` — Who you are, your framework, your origin
2. `core/audience.md` — Who you serve
3. `core/offer.md` — Your transformation
4. `core/voice.md` — How you sound

## Ask One Question

"What's this for? Pick one or tell me the situation."

| Format | Length | Use case |
|--------|--------|----------|
| **One-liner** | 1 sentence | LinkedIn headline, Twitter bio, name tag |
| **Elevator** | 30 seconds (~75 words) | Networking events, "so what do you do?" |
| **Introduction** | 2 minutes (~300 words) | Panel intro, podcast guest bio, speaking engagement |
| **Speaker page** | Full page (~500 words) | Website about page, conference submission |
| **Objection** | 3-5 sentences | A prospect pushed back ("that's expensive", "how is this different?", "I can just do this myself") and you need a grounded reply |
| **All of the above** | All four pitch formats | Generate the full set at once |

If they don't specify, generate all four pitch formats.

## Objection Mode

If they pick **Objection** (or paste an objection directly), ask: "What did they say? Give me the objection in their words." Then craft the response:

1. **Acknowledge** — Don't dismiss it. Show you've heard it before and it's reasonable.
2. **Reframe** — Use the contrarian belief or framework from `soul.md` to shift the frame. A genuine perspective, not a trick.
3. **Prove** — One specific result or data point. Pull from case studies in `campaigns/` or `soul.md#External Perception`.
4. **Redirect** — Bring it back to their situation, referencing the buyer profile in `audience.md`.

Keep it to 3-5 sentences — this is a conversation, not a pitch. Never be defensive (confidence, not persuasion), and never pressure. If they're not ready, say so honestly. Save objection responses with `format: objection`, and offer: "Want me to save this to a running objection library? Useful for training your team or prepping for sales calls."

## Writing Rules

- Lead with the transformation, not the credentials
- Use their contrarian belief from `soul.md` as the hook — it's what makes them different
- Include the origin moment from `soul.md` in the Introduction and Speaker page versions
- Reference specific results from `offer.md#Transformation` or `soul.md#External Perception`
- Match `voice.md` tone — if they're anti-corporate, the pitch should be anti-corporate
- No buzzwords from `voice.md#Anti-Language`
- The one-liner should be memorizable. Test: could they say it without reading it?

## Save Output

Write to `campaigns/[YYYY-MM-DD]-pitch-[format-slug].md` with frontmatter:

```yaml
---
type: output
format: pitch
date: [today]
last-updated: [today's date and time]
source_files:
  - core/soul.md
  - core/audience.md
  - core/offer.md
  - core/voice.md
---
```
