---
name: co-organic
description: "CREATE short-form organic content scripts — Reels, TikToks, carousels, static posts — in the client's voice. Also REPURPOSES an existing output into versions for every channel — take one long-form piece (VSL, podcast, webinar, blog, post) and spin ad, email, post, SMS, and newsletter variants from it. Use when the architect wants to GENERATE new scripts from concepts OR repurpose one finished output across channels. NOT for research/mining competitor content (that's /co-think). NOT for paid ads (that's /co-ad). NOT for long-form text (LinkedIn posts, newsletters, blogs — that's /co-content). Modes: video, carousel, static, repurpose. If architect says mine, scrape, research competitors → route to /co-think."
---

# /co-organic — Short-Form Social Scripts

Create video scripts (Reels/TikTok), carousels, and static posts in the client's voice. Format-focused sibling to `/co-content` (which handles long-form: LinkedIn posts, newsletters, blogs).

---

## Triage

Detect intent first:

| Architect Says | Route |
|---|---|
| "mine", "scrape", "research competitors", "what are they saying" | → `/co-think` (research mode) |
| "transcribe", "extract from video" | → `/co-think` (research mode) |
| "long-form post", "newsletter", "blog", "LinkedIn", "X thread" | → `/co-content` |
| "paid ad", "Meta ad", "ad copy" | → `/co-ad` |
| "short clips from sales video", "repurpose this VSL" | continue here (repurpose mode) |
| "create", "generate", "write scripts", "Reel", "TikTok", "carousel", "static post" | continue here |

If unclear: "Mining competitor content (research) or creating new scripts (generate)?"

---

## Before You Start

Read in order:
1. `.codify/voice.md` — required (tone, banned words, cadence)
2. `.codify/audience.md` — required (their language, hooks that land)
3. `.codify/offer.md` — required (the transformation, the mechanism)
4. `.codify/soul.md` — recommended (beliefs that drive POV)
5. `.codify/design.md` — recommended for `carousel` and `static` modes (colours, fonts, style)

Then load `.codify/exemplars/content/` if present — exemplars show the voice in practice.

For `carousel` and `static` modes, any visual direction (colours, fonts, slide/frame styling) renders from `.codify/design.md` if it exists, so frames match the site and ads. If `design.md` is absent, write the script only and note that the design system is missing.

**Prerequisite gate (run before generating — enforce the order of operations, don't skip upstream steps):**

1. **Offer integrity.** If any required file (especially `offer.md`) is `status: draft` or thin → stop and route to `/co-extract`. For a deeper read, `/co-money-path` names the bottleneck closest to the next dollar.
2. **Design system (`carousel`/`static` modes only).** If producing slide/frame visuals and `.codify/design.md` is missing → recommend `/co-site` to author the design system first, so frames match the site and other assets. Proceed script-only only if the architect confirms.

---

## Context Awareness

Before generating, scan what's been done:

```bash
ls research/*-competitor-mining.md 2>/dev/null | head -3
ls campaigns/*-organic-* 2>/dev/null | head -5
```

- Recent mining? Suggest pulling concepts from it.
- Recent scripts? Avoid duplicate topics.
- Nothing? Ask the architect for a concept or topic.

**Example context-aware response:**

> "Found today's mining (research/2026-05-24-competitor-mining.md) with 10 concepts. Want to pick from those, or start fresh with a topic?"

---

## Modes

### `/co-organic video "concept"`

Reels/TikTok script.

Structure: **Hook (0-3s) → Retain (3-45s) → Reward (final 5-15s)**

Framework picker:

| Framework | Structure | When |
|---|---|---|
| Educational | Hook → Tips → Takeaway | How-to, lists |
| Story-based | Hook → Trigger → Outcome | Personal narrative |
| Transformation | Before → Turning point → After | Journey, case study |
| Problem-Solution | Hook → Problem → Solution | PAS for organic |

Output includes: hook (5 variations), script (timestamped), B-roll suggestions, on-screen text, soft CTA.

### `/co-organic carousel "concept"`

7-10 slides: **Hook → Value (one idea per slide) → Summary → CTA**

Output: slide-by-slide copy with headline + body per slide.

### `/co-organic static "concept"`

Single-post caption.

Structure: **Hook (first line) → Body → Soft CTA → Hashtags (optional)**

Output: 3 caption variations, each optimized for the first-line hook.

### `/co-organic repurpose [path-to-transcript]`

Turn a VSL, podcast, webinar, or long video into short clips.

Input: transcript file (saved to `research/` first via `/co-think` if needed).

Output: 5-10 short-clip scripts, each with timestamp from source + adapted hook + on-screen text + recommended cut points.

---

## Save Output

All script modes save to `campaigns/[YYYY-MM-DD]-organic-[batch-name]/scripts.md`:

```yaml
---
type: output
format: video | carousel | static | repurpose
platform: instagram | tiktok | both
date: [today]
last-updated: [today's date and time]
batch: [batch-name]
source_files:
  - .codify/voice.md
  - .codify/audience.md
  - .codify/offer.md
  - .codify/design.md  # carousel / static modes
---
```

**Batch name is required.** Ask if not provided. Examples: `may-hooks`, `transformation-reels`, `objection-clips`.

---

## Voice Adaptation

Read `.codify/voice.md`. Match tone, vocabulary, cadence. Avoid the "never say" list.

**Authenticity test:** Sounds like the creator (not a copywriter). Contractions, matched energy, no AI tells (`dive into`, `unlock`, `game-changer`, `revolutionary`, `at the end of the day`, `that being said`).

---

## Quality Checklist

- **Hook stops scroll.** First 3 seconds (video) or first line (static) earns the rest.
- **One idea.** Don't pack multiple concepts into one script.
- **Value before ask.** Teach/entertain before the CTA.
- **Soft CTA.** "DM me X," "comment Y," "link in bio if [specific intent]" — not "buy now."
- **Saves test.** Educational, actionable, reference-worthy content drives saves. Saves are the #1 purchase intent signal. Weight save-ability above shares and likes.
- **Voice.** Matches creator energy. Uses their vocabulary. No AI tells.

---

## Integration

- **Mining competitor content?** → `/co-think` (research mode). Save concepts to `research/`. Come back here.
- **Saving a winning angle?** → `/co-think codify` → updates `.codify/exemplars/content/` or `.codify/audience.md`.
- **Repurposing for paid?** → run scripts through `/co-ad` after they prove on organic.
- **Need a long-form post?** → `/co-content`.

---

## Overlap with /co-content

- `/co-content`: long-form (LinkedIn posts, newsletters, blogs, X threads)
- `/co-organic`: short-form video + visual (Reels, TikTok, carousels, single posts)

If unclear: pick by format. "What's the deliverable shape?"

---

## Tone

Match `.codify/voice.md`. Sounds like the creator, not a copywriter. Lead with the point.
