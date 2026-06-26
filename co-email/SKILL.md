---
name: co-email
description: "Generate email sequences (cold outreach, warm nurture, follow-up) from your Context files."
---

# /co-email — Generate Email Sequence

Creates emails that sound like you wrote them, not a marketer.

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

Ask the client: "What kind of email? Cold outreach, warm follow-up, or nurture sequence?"

**Cold outreach (default):** 3-email sequence
- Email 1: Pattern-interrupt opener. Lead with insight, not pitch.
- Email 2: Proof/story. One specific client result.
- Email 3: Direct ask. Short, no pressure, clear next step.

**Warm follow-up:** Single email after a call, meeting, or event — sounds like the client wrote it, not a template. First ask two questions:
1. "Who did you just meet with? Name and context — prospect, existing client, referral, event connection?"
2. "What stood out from the conversation? Anything specific they said, a problem they mentioned, or something you promised to send?"

Then write it: open with the point (not "Great meeting you"), reference one specific thing from the conversation, keep it under 150 words, drop in one unasked-for insight that shows you were listening (pull from `soul.md#Institutional Knowledge` if relevant), and end with a concrete next step ("I'll send the overview Thursday"), not "let me know if you'd like to chat." Never use "I hope this finds you well," "It was great connecting," "Just circling back," or "Let's find some time." No PS unless it's genuinely useful.

**Nurture sequence:** 5-email sequence that builds authority over 2 weeks.

The copy must:
- Use the client's voice — short sentences if that's their style, direct if that's their tone
- Never open with "I hope this finds you well" or any filler
- Reference specific transformations, not vague promises
- Include their signature phrases naturally

## Save Output

Write to `campaigns/[YYYY-MM-DD]-email-[slug].md` with frontmatter:

```yaml
---
type: output
format: email
date: [today]
last-updated: [today's date and time]
source_files:
  - core/soul.md
  - core/audience.md
  - core/offer.md
  - core/voice.md
---
```
