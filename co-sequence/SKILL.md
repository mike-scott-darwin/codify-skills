---
name: co-sequence
description: "Sequencer agent. For each cold pitch, drafts a +3d bump and +9d final follow-up + deactivation rules. Use when: user types /co-sequence, asks to add follow-ups, or co-start routes here."
loops: [decide]
---

# Sequence

Add a 2-touch follow-up cadence to each pitch.

## Inputs

1. `.codify/{voice,audience,offer}.md`
2. Every pitch in `pitches/{today}-*.md` with a matching writer ticket.
3. The originating dossier from `briefs/`.

If no pitches exist for today, tell the user and route to `/co-write`.

## Method

For each pitch, draft TWO follow-ups: a +3-day bump and a +9-day final. Both must:

- Be SHORTER than the pitch (bump ≤ 60 words, final ≤ 80 words).
- Pull a DIFFERENT lever than the pitch. If the pitch led on the buying-trigger embarrassment, the bump can lead on the cost of staying stuck; the final can lead on a hard deadline or social proof.
- Avoid recapping the pitch. Assume the prospect read it.
- Have no greeting and no signoff.

Plus deactivation conditions — events that should pull this sequence out of the queue. Always include at minimum: `reply received`, `calendar booked`, `unsubscribe`. Add 1-2 more relevant to the niche (e.g. `out-of-office longer than 14 days`, `competitor announcement`).

## Output per pitch

Write to `sequences/{YYYY-MM-DD}-{slug}.md` (same slug as pitch).

Frontmatter:

```yaml
---
type: sequence
format: follow-up-cadence
date: <YYYY-MM-DD>
last-updated: <YYYY-MM-DD HH:MM>
agent: sequencer
niche: <niche>
prospect: <name>
company: <company>
pitch: pitches/<source>
brief: briefs/<source>
parent_ticket_id: <writer ticket id>
bump_offset_days: 3
final_offset_days: 9
---
```

Body:

```markdown
# Follow-up Sequence: <name> — <company>

**Pitch:** [pitches/<file>](../pitches/<file>)

## Day 0 — Pitch (already drafted by writer)

Subject: <subject>

<body>

## Day +3 — Bump

Subject: <subject or "(reply in-thread, no new subject)">

<body, ≤60 words>

## Day +9 — Final

Subject: <subject>

<body, ≤80 words>

## Deactivate the sequence on

- reply received
- calendar booked
- unsubscribe
- <niche-specific condition>

## Why each touch differs from the pitch

<1-3 sentences: which lever the bump pulls, which lever the final pulls>
```

## Output: ticket per sequence

Write to `operator-queue/{YYYY-MM-DD}-sequencer-{NNN}.md`.

Frontmatter:

```yaml
---
agent_id: sequencer
started_at: <ISO>
ended_at: <ISO>
surface: cli
input: "Sequence cadence for <name> at <company>"
output_file: sequences/<file>
status: completed
parent_ticket_id: <writer ticket id>
marks: []
---
```

Body:

```markdown
## Output

+3d bump: <subject or "(in-thread)">
+9d final: <subject>

Deactivate on: <semicolon-separated list>

Sequence: [sequences/<file>](../sequences/<file>)
```

## Do NOT

- Do NOT recap the pitch in the bump or final.
- Do NOT use voice.md's anti-jargon words.
- Do NOT exceed the word caps. Brevity is the point.
