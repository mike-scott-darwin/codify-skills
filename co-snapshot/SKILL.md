---
name: co-snapshot
description: "Snapshot — free outbound brief. Three agents read a prospect's business from public sources and deliver a before/after summary + 3 specific opportunities."
---

# /co-snapshot — The Free Outbound Brief

Station 1 of the graduation path. **Snapshot is free.** Three agents read the prospect's business from public sources and return a polished brief: before/after summary + 3 specific opportunities to focus on this week. Delivered as a cold email (primary on-ramp) or via the `/get-started` form fallback.

**Positioning:** "The brief we sent you — or the brief we'd send if we cold-emailed you tomorrow." Same deliverable format the client's future Codify agent will produce for *their* prospects every week. The brief is the diagnostic AND the product demo.

See `reference/core/offer.md` §"Station 1 — Snapshot" for canonical positioning.

## Usage

```
/co-snapshot <prospect-url-or-name>     → Run against an outbound prospect (primary path)
/co-snapshot --inbound <form-submission> → Run against a fallback-form submission
```

## Input Sources

**Outbound (primary):** a prospect URL, company name, or LinkedIn handle from the architect's outbound list.

**Inbound (fallback):** a form submission from `codify.build/get-started` — business name + one-paragraph summary.

Either path produces the same deliverable.

## Procedure

### 1. Research Agent — Read the business from public sources

For the given prospect, pull and read:
- Website (positioning, services, proof, copy tone)
- Reviews (Google, G2, Trustpilot, etc. — whatever exists)
- Current ads (Meta Ad Library, LinkedIn ads if visible)
- LinkedIn company + founder/CEO profile
- Recent activity — blog posts, podcast appearances, press

Capture:
- **What they sell** — the actual offer, the price point, the buyer
- **How they position** — the wedge, the proof, the differentiator claim
- **Current messaging gaps** — where their copy falls flat, what they're not saying that they should
- **Signal of bandwidth** — are they scaling, hiring, launching, stuck?

### 2. Writer Agent — Draft the brief

Produce a single document (`campaigns/<date>-snapshot-<prospect-slug>.md`) structured as:

```markdown
---
type: output
format: snapshot
date: [today]
prospect: [name]
delivery: outbound | inbound
status: draft
---

# Snapshot: [Business Name]

## Before (what we found)

[2–3 paragraphs. The business as it shows up in public sources today. Factual, specific, unflattering where appropriate — "your homepage leads with features, not the wedge." Cite specifics — page titles, exact copy, review quotes — not generalities.]

## After (what's possible in 90 days)

[2–3 paragraphs. A concrete picture of what this business looks like when its expertise is codified — outputs that sound like them from the first draft, a cold outreach engine that leads with real work instead of "interested?" emails, a context system that compounds. Reference the Flagship Play in their language.]

## Three things to focus on this week

1. **[Specific opportunity #1]** — What to do, why now, how long it takes. One sentence each for Fix, Why, Time.
2. **[Specific opportunity #2]** — Same.
3. **[Specific opportunity #3]** — Same.

---

This brief took our agents ~15 minutes. It's the same format your future Codify agent will produce for 20 of *your* prospects every week, custom per prospect, in your voice, while you sleep.

**Next step:** [`codify.build/get-started`](https://codify.build/get-started) — $297/mo to turn this into a managed loop running weekly in your voice.
```

**Voice rules:** Use `.codify/voice.md` — direct, anti-hype, practitioner tone. No "revolutionary / game-changing / unlock your potential." Lead with the point.

### 3. Delivery Agent — Send the brief

**Outbound path:**
- Email the prospect with the brief as the body (not an attachment — the brief is the email)
- Subject line: specific, non-clickbait, references the prospect's business
- From: the architect's (or client's) configured sender identity
- Log delivery in `operator-queue/`

**Inbound path:**
- Send to the email address captured in the form submission
- Same subject line convention
- Log delivery in `operator-queue/`

### 4. Log the run

Append one row to `operator-queue/<date>-snapshot-<prospect-slug>.md`:

```yaml
---
agent_id: snapshot
goal_id: station-1-diagnostic
surface: outbound | inbound
input: <prospect-identifier>
output_file: campaigns/<date>-snapshot-<prospect-slug>.md
status: delivered
cost_usd: [actual]
tokens_used: [actual]
delivered_at: [timestamp]
---
```

### 5. Report

"Snapshot delivered to [prospect]. Brief saved at `campaigns/<date>-snapshot-<prospect-slug>.md`. Cost: $X.XX. Tokens: N. Now waiting on reply or `/get-started` click-through."

## What Snapshot is NOT

- **Not a paid product.** Snapshot is free. There is no Stripe, no GHL tag, no `snapshot-purchased` workflow. That was the old (superseded) model — see `reference/archive/2026-04-09-context-snapshot-offer-SUPERSEDED.md`.
- **Not a soul/voice/audience extraction.** Those files are built during Codify onboarding via `/co-extract`, not as a snapshot output.
- **Not a one-shot extraction from a voice note.** That was the old `/co-snapshot` behaviour; it no longer exists.

## Quality Check

Before flagging delivered:
- Every claim in "Before" cites a specific public source (URL, review, ad)
- "Three things" are specific to this prospect, not generic ("more content" is banned)
- The closing line names the next step — Codify at $297/mo, `codify.build/get-started`
- Reads in under 4 minutes

## See Also

- `reference/core/offer.md` §"Station 1 — Snapshot (Free)"
- `decisions/2026-04-22-outbound-brief-as-primary-gtm.md` — the GTM flip rationale
- `decisions/2026-04-22-overnight-prospecting-as-canonical-play.md` — the parent play this brief is a scaled-down version of
