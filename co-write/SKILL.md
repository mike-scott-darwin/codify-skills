---
name: co-write
description: "Writer agent. Drafts one cold-email pitch per researcher dossier in the user's voice. Use when: user types /co-write, asks to draft pitches, or co-start routes here. Reads briefs/ + .codify/, writes pitches/."
loops: [decide]
---

# Write

Turn each researcher dossier into one cold pitch in the user's voice.

## Inputs

1. `.codify/{soul,voice,audience,offer}.md` — for voice rules and offer language.
2. Every dossier in `briefs/{today}-*.md` that has a corresponding `operator-queue/` researcher ticket. Skip orphans.
3. The matching researcher ticket id (you'll need it for `parent_ticket_id`).

If no dossiers exist for today, tell the user and route to `/co-research`.

## Method

For each dossier, draft ONE cold email. Hard rules:

- Open with the SPECIFIC embarrassment moment from the dossier's `buying_trigger`. The recipient should feel caught in line one.
- Use the user's sentence tics from `voice.md` — fragments are fine, short imperatives, name-the-pattern.
- Avoid every word in voice.md's anti-jargon table. If you write one of those words, the draft is rejected.
- 80–130 words total. No greeting, no signoff. Those are added downstream.
- End with ONE concrete, time-bounded ask. No "worth a quick chat?"

Tools:
- Read the dossier to get the `buying_trigger`, `likely_dealing_with`, and `talking_points`.
- Pull the ask from `offer.md` — typically the first deliverable (e.g. language audit) or the guarantee.
- The bridge — between hook and ask — comes from `likely_dealing_with` cross-referenced with the offer.

## Output per dossier

Write the pitch to `pitches/{YYYY-MM-DD}-{slug}.md` (same slug as the source brief).

Frontmatter:

```yaml
---
type: pitch
format: cold-email
date: <YYYY-MM-DD>
last-updated: <YYYY-MM-DD HH:MM>
agent: writer
niche: <niche from brief>
prospect: <name>
company: <company>
brief: briefs/<source filename>
parent_ticket_id: <2026-MM-DD-researcher-NNN>
subject: <subject line>
---
```

Body:

```markdown
# Cold Pitch: <name> — <company>

**Subject:** <subject line>

## Email body

<full body, 80–130 words, plain text>

## Single ask

<one concrete time-bounded ask>

## Why this opens this way

<1-3 sentences: which buying_trigger lever and which voice tic this draft pulls on>

## Source dossier

[briefs/<filename>](../briefs/<filename>)
```

## Output: operator-queue ticket per pitch

Write to `operator-queue/{YYYY-MM-DD}-writer-{NNN}.md`.

Frontmatter:

```yaml
---
agent_id: writer
started_at: <ISO>
ended_at: <ISO>
surface: cli
input: "Draft pitch for <name> at <company> (niche: <niche>)"
output_file: pitches/<filename>
status: completed
parent_ticket_id: <researcher ticket id for THIS dossier>
marks: []
---
```

Body:

```markdown
## Output

**Subject:** <subject>

**Hook:** <opening_hook>

**Ask:** <ask>

Draft: [pitches/<filename>](../pitches/<filename>)
```

## When you finish

```
5 pitches in pitches/<date>-*.md, 5 tickets in operator-queue/.

Next: /co-sequence    add +3d bump and +9d final to each
      /co-edit        skip ahead and have the editor mark them now
```

## Do NOT

- Do NOT invent quotes from the prospect.
- Do NOT use any word from voice.md's anti-jargon table — anywhere, including the subject line.
- Do NOT include "Hi {name}," or "Best,". Those go in the activator's outbox payload.
- Do NOT exceed 130 words in the body.
