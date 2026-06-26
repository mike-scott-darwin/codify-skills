---
name: co-content
description: "Generate content for any platform — LinkedIn, blog, newsletter, X/Twitter, Instagram — from your Context files."
---

# /co-content — Generate Content

Creates content that sounds like you, for whichever platform you choose.

## Before Generating

Read these files in order:
1. `core/soul.md` — Who you are
2. `core/audience.md` — Who you serve
3. `core/offer.md` — What you sell
4. `core/voice.md` — How you sound

Also scan `decisions/` and `research/` for recent entries.

If any Context file has `status: draft` or is mostly empty, warn:
"Your [file] is thin. Output quality will improve if you run `/co-extract [file]` first. Generate anyway?"

## Ask Two Questions

1. "Which platform? LinkedIn, blog, newsletter, X/Twitter, or Instagram?"
2. "What angle? A belief, a story, a lesson, or a contrarian take?"

If they don't specify, default to LinkedIn + contrarian take.

## Platform Formats

**LinkedIn:**
- Strong opening line (hook — first line is all that shows before "see more")
- 150-250 words
- Line breaks between thoughts
- No hashtags unless the client uses them
- End with a question or clear point — not a sales pitch

**Blog:**
- 500-800 words
- Headline + 3-5 subheadings
- Lead with the point, not the backstory
- Include one story or example from Context files
- End with a takeaway, not a CTA

**Newsletter:**
- Subject line (under 50 characters)
- 300-500 words
- Personal tone — like an email to one person
- One idea per issue
- Brief CTA at the end if relevant

**X/Twitter:**
- Thread of 3-5 tweets
- First tweet is the hook — must stand alone
- Each tweet is one complete thought
- No hashtags, no emojis unless that's their voice

**Instagram:**
- Caption: 100-200 words
- Hook in first line (shows before "more")
- Conversational tone
- Suggest image concept (what to photograph or design)

## Angles

- **Belief:** Lead with a contrarian belief from `soul.md`. Back it with a specific example.
- **Story:** Tell a client story (anonymized) that proves the transformation in `offer.md`.
- **Lesson:** One tactical insight from `soul.md#Institutional Knowledge`.
- **Contrarian take:** Challenge conventional wisdom in their industry.

## Save Output

Write to `campaigns/[YYYY-MM-DD]-content-[platform]-[slug].md` with frontmatter:

```yaml
---
type: output
format: content
platform: [linkedin|blog|newsletter|twitter|instagram]
date: [today]
last-updated: [today's date and time]
source_files:
  - core/soul.md
  - core/audience.md
  - core/offer.md
  - core/voice.md
---
```
