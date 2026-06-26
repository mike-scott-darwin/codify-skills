---
name: co-loop
description: "Runs one complete 'Clients While You Sleep' revenue cycle in four stages: Find (5 prospects worth a conversation) → Ship (real work per prospect + the outreach that hands it over, staged for the client's sender) → Check (editor gate — nothing off-voice gets through) → Decide (the client's decision point: one morning brief, one tap; replies write back). Use when: user types /co-loop, says 'run the whole loop', 'run a cycle', or wants the full chain in one command. Args: optional niche string."
loops: [sense, decide, ship, reflect]
---

# Loop — One Business Cycle: Find → Ship → Check → Decide

One command runs one revenue cycle of the flagship play: **real work, already done, lands in front of 5 prospects — and the client wakes to one decision, not twenty drafts.**

The cycle has four stages. The first three run without the client; the fourth — the only decision in the cycle — is theirs:

| Stage | The business question | Skills |
|---|---|---|
| 1 · **Find** | Who's worth a conversation this cycle, and what gap can we close? | `/co-research` |
| 2 · **Ship** | What can we do *for them* before we ask — and how do we ask honestly? | `/co-write` → `/co-sequence` → `/co-activate` |
| 3 · **Check** | Would we be proud to send every word? Editor gate — quality control, not the decision. | `/co-edit` |
| 4 · **Decide** | The client's decision point: one morning brief, one tap to approve — plus, when the cycle hit a fork only the client can settle, a one-tap **decision gate**. Every reply writes back to the vault. | `/co-end` |

(The `loops:` frontmatter keeps the upstream Main Branch operator-loops taxonomy — sense/decide/ship/reflect — which one lap traverses. The stage names above are the client-facing business cycle.)

## Inputs

1. `.codify/{soul,voice,audience,offer}.md` — must all exist. Bail to `/co-setup` if not. The cycle is only as good as the brain it reads.
2. Optional niche string from the slash command args. If absent, ask the user.

## Sequence

Invoke skills in order. Each skill writes its own files; this skill just orchestrates the cycle.

### Loop state — the inspectable bookend

The cycle runs unattended, so its state must be readable, not implicit. Maintain one
steered-loop contract file, `campaigns/nightly/<date>/loop-state.md`:

1. **Read it first.** On start, read the current `loop-state.md` (if a prior run left one).
   It tells you which stages already completed this cycle so a resumed run skips finished
   work instead of redoing it — the same skip-if-complete discipline the per-prospect stage
   artifacts use.
2. **Update it each stage.** After every stage, write back: stage name, status
   (`complete` / `bailed` / `skipped`), counts, and any fork raised. The file is the
   single source of "where is this cycle" — not chat scrollback.
3. **Render handoffs from it.** The Stage 4 brief and any decision gate read their inputs
   from `loop-state.md`, so what the client sees is exactly what the loop recorded — no
   drift between what ran and what's reported.

```markdown
---
type: loop-state
date: <date>
niche: <niche>
cycle_status: running | complete | bailed
---
- find:   complete — 5 dossiers
- ship:   complete — 5 pitches / 5 cadences / 5 payloads
- check:  complete — 👍 4 · ✅ 1 · 👎 0
- decide: complete — 1 brief staged · 0 gates
```

A loop without an inspectable state file is a push-only loop; this file is what makes the
cycle resumable and the morning handoff honest.

**Stage 1 · Find**
1. `/co-research <niche>` — 5 dossiers in `briefs/`, 5 tickets. Each dossier names the gap our offer can close.

**Stage 2 · Ship**
2. `/co-write` — 5 pitches in `pitches/`, 5 tickets parented to researcher. As close to new revenue for the prospect as possible.
3. `/co-sequence` — 5 cadences in `sequences/`, 5 tickets parented to writer. Day 0 hands the work over; follow-ups stop on any reply.
4. `/co-activate` — 5 outbox payloads in `outbox/`, 5 tickets parented to sequencer. Staged for the client's own sender — the cycle never sends.

**Stage 3 · Check**
5. `/co-edit` — 1 editor ticket with marks referencing upstream tickets. Quality control: nothing off-voice reaches the client. Not the decision — that's stage 4.

**Stage 4 · Decide**
6. `/co-end` — operator brief at `briefs/operator/<date>.md`. The client's decision point: one read, one tap. Their marks and every prospect reply write back to the vault.
7. **Raise a decision gate if the cycle hit a fork** (see below). If a fork only the client can settle came up during Find/Ship — write the gate file so it surfaces in tomorrow's `/co-brief`. If no fork, skip silently — most cycles are approve-only.

### Decision gates — when the cycle forks

The cycle runs without the client (stages 1–3), so when it hits a fork *only the client's judgment settles*, it can't stop and ask — the client's asleep. It does the homework, **picks the safe default to keep the cycle moving**, and writes the fork as a gate for the morning so the client can confirm or redirect.

Raise a gate **only** when:
- The fork genuinely needs the client's judgment — which niche next, which of two tested angles to lead with, widen to a new city vs. go deeper. NOT a quality call (that's the editor) and NOT something research can resolve (that's `/co-research`).
- You can reduce it to **two concrete options + a recommendation**. If you can't, it's a research gap, not a gate — don't surface a vague question.

Write the gate to `decisions/gates/<date>-<slug>.md`:

```markdown
---
type: gate
status: open
date: <date>
question: <the fork, one line>
option_a: <concrete option>
option_b: <concrete option>
recommendation: <a|b> — <one-line why, grounded in the vault>
blocks: <branch paused on this answer, or "nothing — proceeded on the default">
---
```

`/co-brief` globs these (`status: open`) and renders them as the one-tap **Decisions Waiting** block. The client's tap (or voice note) flips `status` and writes the choice back to `.codify/` so the same fork doesn't recur — that's the gate closing the [compounding] loop, same as an approval or a correction.

After each stage, print a one-line status:

```
✓ find:   5 dossiers (niche: <niche>) — each names the gap
✓ ship:   5 pitches → 5 cadences → 5 staged payloads (fixture-mode, never sends)
✓ check:  👍 <up> · ✅ <tweaks> · 👎 <down>
✓ decide: one decision staged for the client's morning brief[ · 1 gate raised]
```

Never silently skip a stage. If any step bails (e.g. researcher returns < 5 prospects), stop and tell the user what happened — a short honest cycle beats a padded one.

## Cost expectation

- 12 Sonnet 4.6 calls total: 1 researcher + 5 writer + 5 sequencer + 1 editor.
- Activator and brief generator are no-LLM.
- Typical cycle: $0.20–$0.40 in Anthropic spend at list price.

Tell the user the rough cost up front if their `~/.claude/settings.json` doesn't show recent Anthropic spend telemetry. Don't surprise them.

## When you finish

```
Cycle complete: 5 conversations staged, one decision waiting.

  briefs/<date>-*.md         5 dossiers (who + the gap)          [find]
  pitches/<date>-*.md        5 pitches (real work, attached)     [ship]
  sequences/<date>-*.md      5 cadences (open honestly, stop politely)
  outbox/<date>-*.md         5 outbox payloads (fixture)
  briefs/operator/<date>.md  morning brief — the decision point  [decide]
  decisions/gates/<date>-*.md  open decision gate (only if the cycle forked)
  operator-queue/            21 tickets (5+5+5+5+1)

Spend: ~$<estimate> · Tokens: ~<estimate>

Read briefs/operator/<date>.md before sending anything.
The 👎 marks need a rewrite before they go out.
Every reply that comes back belongs in the vault — that's what makes
the next cycle sharper than this one.
```

## Do NOT

- Do NOT skip the Check stage. Bias against shipping unreviewed drafts is the whole point.
- Do NOT make the *irreversible* decision for the client — Check gates quality; the client approves at Decide. The cycle ends at *staged*; they own the sender and the push. At a fork mid-cycle you may proceed on a **safe, reversible default** to keep moving (a sleeping client can't be asked), but you must raise the gate so they can redirect — never silently bake a directional choice in as if it were settled.
- Do NOT call out to anything that would cost real money beyond the 12 Sonnet calls (no premium models, no extra tools).
