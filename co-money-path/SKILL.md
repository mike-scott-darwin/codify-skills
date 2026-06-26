---
name: co-money-path
description: "Revenue-readiness scan. Reads the vault, scores eight 'money objects' (offer, proof, ladder, CTA, channel, push, feedback loop, bets), names the one bottleneck closest to the next dollar, and ranks the day's actions by money-proximity. Reports facts about readiness — never claims an offer will or won't convert."
---

# /co-money-path — What's Closest to the Next Dollar

Grounds the day in **what's actually ready to make money** before any advice gets
given. Ported from Main Branch's MoneyPath model. The discipline that makes it
trustworthy: it reports **facts about the substrate** — what's legible, connected,
and instrumented — and it never renders a verdict on whether something will sell.

Run it standalone, or let `/co-start` and `/co-brief` call it as their readiness-first
opener.

```
/co-money-path            → Full readiness scan + ranked actions
/co-money-path --snapshot → One-block summary only (for co-start / co-brief)
```

## The one rule that keeps this honest

**Report readiness, not strategy. Never judge conversion.**

- ✅ "The offer has three tiers and a stated price. There is no dedicated proof file; the only proof is one testimonial inside offer.md."
- ✅ "No live push is running. The last campaign closed 2026-05-12."
- ❌ "Your offer is weak." / "This will convert." / "This won't sell."

You are reporting whether the machinery is *present, connected, and measured* — the
same boundary as "we never sell rankings" and "the loop ends at the substrate." If a
file is thin, say what's missing as a fact. The fix for a generic recommendation is
almost always a change to the **offer files**, not a stronger adjective here.

## Procedure

### 1. Hard gates first (resolve before scoring)

Before interpreting money-readiness, check for blockers that outrank it. If any are
present, surface them and stop — a readiness scan on a broken vault is noise:

- Core files missing or `status: draft` (no `core/offer.md`, empty soul/voice/audience)
- Obvious structural drift (run a silent `/co-status` read if available)
- A pending decision that the whole pipeline is waiting on

If gates are clear, proceed.

### 2. Read the vault (markdown, not a CLI)

Read these silently. Score each object **only on what the files actually say** —
presence, completeness, and whether it connects to the next step:

- `core/offer.md`, `core/soul.md`, `core/voice.md`, `core/audience.md`
- `core/proof/` or any proof file (often absent — that's a finding)
- `core/product-ladder.md` or the tier structure inside `core/offer.md`
- `campaigns/` — recent + any live push
- `bets/` — open bets, thresholds, exit criteria
- `operator-queue/` and `log/` — is outcome measured back to source
- recent `decisions/` and `research/` only if a scored object points to one

### 3. Score the eight money objects

For each, record a one-line **fact** and a level: `present` / `partial` / `absent`.

| # | Object | Read from | The fact to report |
|---|--------|-----------|--------------------|
| 1 | **Offer** | `core/offer.md` | Is it structured and complete — tiers, price, terms — or are fields missing? |
| 2 | **Proof** (+ quality) | proof file / offer.md | Generic vs specific vs offer-linked vs outcome-fed. Where does the proof live and how typical is it? |
| 3 | **Product ladder** | ladder file / offer tiers | Are the rungs present and is there a path up? Any gap between free → paid? |
| 4 | **CTA path** | offer / campaigns / site | Is there a connected next step a reader can actually take? |
| 5 | **Channel strategy** | campaigns / content files | Which channels are declared, and are they connected to the offer? |
| 6 | **Active push** | `campaigns/` | Is a live campaign running right now, or is the last one closed? |
| 7 | **Outcome feedback loop** | `operator-queue/`, `log/` | Is the outcome instrumented back to its source, or does it disappear after send? |
| 8 | **Bets** | `bets/` | Thresholds declared? Any bet `unanchored` (no exit criteria) or `over_cap` (past its budget/date)? |

### 4. Name the bottleneck and rank actions

- Pick the **single object closest to the next dollar that is `absent` or `partial`** —
  that's the bottleneck. Order of money-proximity when several are weak: a broken/absent
  **CTA path** or **active push** beats a thin **channel strategy** beats a missing
  **feedback loop** beats deeper **proof/ladder** work. Offer/proof gaps matter most when
  nothing downstream can run yet.
- Produce 1–3 **ranked actions**, each tied to its object and the file it touches.
- If your bottleneck disagrees with what `/co-start`'s generic recommender would say,
  **name which wins and why** in one line.

### 5. Route, don't do

`co-money-path` diagnoses; it doesn't write business files or launch anything.

- Missing a **decision, proof quality, CTA, paid entry step, or feedback loop** →
  hand off to `/co-think` to decide or codify.
- Missing a **deliverable** (a live push, a page, a sequence) → name the skill that
  builds it (`/co-campaign`, `/co-site`, `/co-email`) but **ask before running it**.
- Never mutate files, providers, or live channels from this skill.

## Output format

### Full scan
```
MoneyPath — <overall: early / building / ready>

  Offer            ✅ present   — three tiers, prices stated
  Proof            ⚠️ partial   — one testimonial inside offer.md, no proof file
  Product ladder   ✅ present   — free → $297 → $1,997
  CTA path         ❌ absent    — no connected next step on the offer
  Channel strategy ⚠️ partial   — cold email declared, no others
  Active push      ❌ absent    — last campaign closed 2026-05-12
  Feedback loop    ⚠️ partial   — sends logged, outcomes not measured back
  Bets             ⚠️ partial   — 1 open bet, no exit criteria

Bottleneck: CTA path — nothing downstream can convert without a connected next step.

Today, in money order:
  1. Add a connected CTA to the offer  → /co-think, then /co-site
  2. Start a push                      → /co-campaign (ask first)
  3. Give the open bet an exit         → /co-bet

(MoneyPath disagrees with the generic "enrich your soul file" suggestion —
 the closer dollar is the missing CTA, not deeper context. CTA wins today.)
```

### `--snapshot` (for co-start / co-brief)
```
MoneyPath: building. Bottleneck — CTA path (no connected next step).
Closest move: add a CTA to the offer (/co-think → /co-site).
```

## Tone rules (client-surfaced)

- Plain business language. No git, CLI, JSON, "object," or "instrumentation" in the
  output the client sees — those are *our* words; theirs are offer, proof, next step,
  campaign, follow-the-money.
- Lead with the bottleneck. One sentence, then the ranked moves.
- Anti-hype: no "unlock," no "revolutionary," no conversion promises. Facts and the
  next move only.
- Reads `core/*.md` at runtime — never hardcode prices, tiers, or positioning here
  (CLAUDE.md Rule 7). If the scan keeps coming back generic, the substrate is thin;
  fix the offer files, not this skill.

## Provenance

Ported from Main Branch `workflows/mb-start-money-path/workflow.md` (v0.3.42).
Decision: `decisions/2026-06-02-money-path-reopen.md`. Upstream review:
`research/2026-06-02-mainbranch-upstream-review.md`. The CLI-backed `money_path` JSON
facts in MB are replaced here by direct markdown reads — when a Codify `codify status
--json` feed exists, this skill can consume it instead of re-deriving from files.
