---
name: co-campaign
description: "Full pipeline — generate high-fidelity outputs (ad + email + post + landing page, proposals on request) from Context files, then distribute everything. One command, full campaign. Use this whenever you need several grounded outputs generated together rather than one at a time."
---

# /co-campaign — Full Campaign Pipeline

One skill. Full campaign. Reads your Context files, generates every asset, and distributes them to live channels.

This is the highest-value skill in the system. It's the reason context compounds into revenue.

## Usage

```
/co-campaign                       → Full campaign (ad + email + post + landing)
/co-campaign launch [topic]        → Campaign around a specific topic/offer
/co-campaign retarget              → Retargeting campaign from existing outputs
/co-campaign promo-calendar [horizon]  → Dated promotions calendar (default: next 6 months)
/co-campaign promo [occasion]      → One deal/offer funnel (hero + terms + tiered pricing + cards + email + social)
```

**Mode router.** `promo-calendar` and `promo` are the channel-tier promotions modes — for local-business clients running seasonal offers (the "calendar of promotions" motion). Both reuse Step 1 (Load Full Context) and its prerequisite gates unchanged, then branch at generation. The single-campaign flow above is untouched. These modes earn their place only while the vertical channel is a priority — see `decisions/2026-06-18-dealsplash-channel-tool-not-core.md`.

## Procedure

### 1. Load Full Context

Read in order:
1. All `core/` files
2. `.codify/design.md` — brand colours, fonts, style (if it exists)
3. Last 5 `decisions/`
4. Last 5 `research/`
5. Last 5 `campaigns/` (to avoid repeating)

Every asset in this campaign shares one visual language: any visual direction (ad image concepts, landing markup/colours/type) renders from `.codify/design.md` if it exists, so the ad, landing page, and post all match each other and the site. If `design.md` is absent, generate copy only and note that the design system is missing.

**Prerequisite gate (run before generating — enforce the order of operations, don't skip upstream steps):**

1. **Offer integrity.** If any core file (especially `offer.md`) is `status: draft` or thin → stop and route to `/co-extract`; don't run a full campaign off a thin substrate. For a deeper read, `/co-money-path` names the bottleneck closest to the next dollar.
2. **Design system (visual assets).** This campaign produces an ad and a landing page. If `.codify/design.md` is missing → recommend `/co-site` to author the design system first, so every asset shares one visual language. Proceed copy-only only if the architect confirms.

### 2. Identify the Campaign Angle

If topic specified, use it. Otherwise, ask:
"What's this campaign about? (new offer, event, content push, seasonal, retarget)"

Cross-reference the topic against Context files to find:
- The audience pain point it addresses (from `audience.md`)
- The transformation it promises (from `offer.md`)
- The voice it should use (from `voice.md`)
- The belief it's built on (from `soul.md`)

### 3. Generate All Assets

Create these in sequence, each building on the last:

**Asset 1: Ad Copy (3 variations)**
- Hook A: Pattern interrupt
- Hook B: Problem-aware
- Hook C: Proof-forward
- Body: Problem → agitation → solution → proof → CTA
- Save to `campaigns/[date]-campaign-ad-[slug].md`

**Asset 2: Email Sequence (3 emails)**
- Email 1: Problem awareness (day 0)
- Email 2: Solution + proof (day 2)
- Email 3: CTA + urgency (day 4)
- Save to `campaigns/[date]-campaign-email-[slug].md`

**Asset 3: LinkedIn Post**
- Contrarian take or data point from Context files
- Short paragraphs, white space
- Ends with observation, not hard CTA
- Save to `campaigns/[date]-campaign-post-[slug].md`

**Asset 4: Landing Page Copy**
- Headline (from ad hook that works best)
- Subheadline (the transformation)
- 3 bullet proof points
- Objection handling (from `offer.md`)
- CTA
- Save to `campaigns/[date]-campaign-landing-[slug].md`

### 4. Review Package

Present all 4 assets together:

"Here's your full campaign:

**Ads** — 3 variations ready to test
**Emails** — 3-email sequence, spaced 2 days apart
**LinkedIn** — 1 post, ready to publish
**Landing page** — Copy ready for your page builder

Want to review each one, or distribute everything now?"

### 5. Distribute

If approved, run `/co-publish` on each asset:
- Ads → GoHighLevel social posts
- Emails → GoHighLevel email campaign or Gmail drafts
- LinkedIn post → GoHighLevel social
- Landing page → Provide copy (manual placement)

"Distribute everything now" approves the *campaign*, not each send. `/co-publish` still runs its public/private boundary check and per-channel confirmation on every asset — never skip those gates because the campaign was approved as a package. Each asset gets its own preview and yes/no before it goes live.

### 6. Log Campaign

Create a campaign log in `campaigns/[date]-campaign-log-[slug].md`:

```yaml
---
type: output
format: campaign-log
date: [today]
campaign: [topic]
assets:
  - ad-copy: 3 variations
  - email-sequence: 3 emails
  - linkedin-post: 1
  - landing-page: 1
distributed:
  - channel: [list]
    date: [today]
source_files:
  - core/soul.md
  - core/audience.md
  - core/offer.md
  - core/voice.md
  - .codify/design.md
---
```

This tracks what campaigns ran, what context they used, and where they went. Over time, this data compounds — showing which Context file elements drive the best campaigns.

---

## Mode A — `promo-calendar [horizon]`

A *dated sequence* of promotions across a horizon — the one thing the single-campaign flow can't do (it produces one campaign per run). For local-business clients running seasonal offers.

### A1. Load context + gates
Run **Step 1** above unchanged (full context load + offer-integrity and design-system gates).

### A2. Plan the calendar
- Read `core/audience.md` (niche, customer rhythms), `core/offer.md` (what can be promoted), and the last 5 `campaigns/` (avoid repeats).
- Map the horizon (default 6 months) to occasions relevant to **this client's niche** — pulled from `audience.md`, never a hardcoded holiday table (facts live in context files, not skill text). A med spa gets Mother's Day / wedding season / "New Year reset"; a pizza shop gets Super Bowl / Father's Day / back-to-school.
- Ask one gate question: *"Confirm horizon and cadence — how many promos per month?"* (default 1–2/month).

### A3. Generate the calendar artifact
One file → `campaigns/[date]-promo-calendar-[slug].md`:

```yaml
---
type: output
format: promo-calendar
date: [today]
horizon: [start]–[end]
source_files: [core/audience.md, core/offer.md]
---
```

Then a dated table — one **stub** row per promotion (the plan, not the funnel):

| Date | Occasion | Offer angle | Deal hook | Status |
|------|----------|-------------|-----------|--------|
| 2026-06-21 | Father's Day | … | … | planned |

End by offering: *"Want me to build the next promo (`/co-campaign promo [occasion]`) now?"* Each row becomes a Mode B input on demand. Default to table-only — do not auto-generate a funnel per row.

---

## Mode B — `promo [occasion]`

One full *transactional* deal/offer funnel. This is the offer-funnel copy shape — distinct from `/co-landing`'s book-a-call/download/buy model.

### B1. Load context + gates
Run **Step 1** above unchanged.

### B2. Generate four assets
Reuse the existing Email (Asset 2) and Post (Asset 3) generators; swap in the deal-funnel template below for the landing slot.

**Asset 1: Deal funnel copy** → `campaigns/[date]-promo-[occasion]-funnel.md`. Sections:
- **Deal hero** — headline + the offer in one line (e.g. "Al pastor taco feast for two — $14, was $20").
- **What to expect** — 3–4 bullets of what the buyer gets.
- **Tiered pricing / upsell options** — the structure `co-landing` doesn't model: "Buy 1, save X · Buy 2, save Y · Buy 4, save Z." From `offer.md` pricing logic.
- **Redemption terms** — how/when redeemed, expiry, fine print. **Flag for confirmation:** *"Operator + client must confirm terms before publish."*
- **Social-card captions** — short caption copy sized per card format, to pair with externally-generated card images.

**Asset 2: Email** — reuse the Email generator, framed as a list reactivation offer (day 0 + optional +3 reminder).

**Asset 3: Social post** — reuse the Post generator, deal-forward.

**Asset 4 (optional): Offer-funnel export** — see the distribution note below.

All assets read `.codify/design.md` for visual language, same as the main flow.

### B3. Review + distribute + log
- **Review:** present the four assets together (same as Step 4).
- **Distribute (Step 5) + optional offer-funnel handoff:** alongside the normal `/co-publish` channels, optionally export the deal-funnel copy + card captions shaped for an **offer-funnel endpoint** — Dealsplash, a GHL store/funnel, or a `/co-site` page. The endpoint is **optional and never a dependency**; documented in `reference/core/connectors.md`. Keep `/co-publish`'s public/private boundary + per-asset confirmation gates — never skip them.
- **Log (Step 6):** add `format: promo` and `calendar_ref:` (path to the calendar file this promo was built from, if any) so calendar and built promos stay linked.
