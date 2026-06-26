---
name: co-redline
description: "Redline agent. Takes a target company URL, runs a fit + readability gate, scrapes their site, mines customer reviews, scores a six-check first-impression scorecard (wins and gaps), identifies 3 assumption gaps, screenshots their homepage and rebuilds the hero IN PLACE (their real site + font, only the copy changed from their reviews), shows why each line changed, adds an AI-search footnote, and packages an interactive HTML redline plus email/ad/reference handoffs. CTA is reply-to-book-a-call. Use when: user types /co-redline, asks for a website audit/redline, or co-start routes here. Args: target company URL or domain."
loops: [sense]
---

# Redline

Audit one target company's website against what their customers actually say, rebuild their above-the-fold, and package an interactive HTML redline plus copy/ad/email/reference handoffs.

This skill is the alternative cold-open to `/co-write`. Instead of mailing a pitch, you mail a redline of their own homepage. Higher reply rate, slower per-prospect, much harder to ignore.

## Inputs

1. **Target URL or domain** — from the slash arg, or ask the user.
2. `.codify/voice.md` — the voice we use in commentary (your voice, not the target's).
3. `.codify/offer.md` — to frame the bridge banner at the top of the deliverable.

If `.codify/` is incomplete, route to `/co-setup` first. The skill can technically run without `.codify/` (standalone audit mode) — if so, ask the user to confirm they want a generic redline with no Codify bridge.

## Method

### 0. Fit + readability gate

Before any work, decide whether this target is worth a redline — and be honest if it isn't. A read you don't send is cheaper than a read that embarrasses you.

- **Not our ICP.** If the target is clearly outside `.codify/audience.md` (wrong industry, wrong size, a disqualifier), don't force a redline. Note it, decline gracefully, and — if relevant — suggest who *would* be a fit. ("This isn't the kind of business we build for, so we'd be the wrong shop. If you know one who'd want this, send them our way.")
- **Couldn't read it.** If the site won't scrape cleanly (JS-rendered, blocked, down), don't guess. Flag it and offer a by-hand read: ask the operator to paste the homepage HTML or a screenshot.
- **Too new / too thin.** If the site is so sparse an outside read comes back thin (no reviews, near-empty pages), say so plainly rather than padding. Offer the by-hand read, or route to the sparse-review fallback (5 pitches) per `.codify/offer.md`.

Only proceed to a full redline when the target is in-ICP and readable. Honesty here is the point — the read's credibility comes from never inventing what isn't there.

### 1. Brand extraction

Scrape the target's homepage (use WebFetch). Extract and write to `briefs/{YYYY-MM-DD}-{slug}-brand.md`:

- **Color palette** — primary, secondary, accent (hex codes from CSS or computed style)
- **Font stack** — heading + body
- **Hero block** — H1, subhead, primary CTA label + URL, secondary CTA label + URL
- **Section inventory** — every section in order, one line each ("hero", "social proof", "services grid", etc.)
- **Hero photography URLs** — their CDN URLs (we hot-link these in the redline; do NOT download)
- **Contact patterns** — phone, chat widget, address, hours

If WebFetch fails or the site is JS-rendered and unreadable, ask the user to paste the homepage HTML or screenshot.

### 2. Review mining

Mine **at least 50 customer review snippets across at least 6 platforms**. Try in this order; skip platforms with no presence:

BBB, Trustpilot, ComplaintsBoard, Sitejabber, Birdeye, Reddit, Angi, HomeAdvisor, Google Maps, Yelp, Glassdoor (employee POV — surfaces internal-pressure tells).

For each snippet capture: `source`, `date`, `snippet` (verbatim, ≤2 sentences), `sentiment` (positive | negative | mixed), `theme_tag` (one of: speed, honesty, quality, price, commission, response_time, communication, scope_creep, technician, other).

Write to `briefs/{YYYY-MM-DD}-{slug}-reviews.md`.

If you cannot find 50 snippets across 6 platforms, **do not fabricate**. Report the count you got and ask the user whether to proceed with a thinner sample, switch to a different target, or paste reviews they have on hand.

### 3. First-impression scorecard

Before the deep gap analysis, score the site the way the target's *own buyer* sees it in the first ten seconds. This is the broad, scannable layer — a fixed-shape rubric, scored the same way every time, anchored to real buyer moments. It also captures **what the site already does well**, so the read is a fair read, not a hit piece.

Score each check **✅ strong / ⚠️ partial / ❌ gap**, with one line of plain-English evidence from the actual site (never invented). For each, name the buyer moment it belongs to.

The fixed checks (tailor the wording to `.codify/audience.md`, but keep all six):

1. **Speed on a phone** — does it load fast on mobile? *(moment: the buyer pulls you up on their phone)*
2. **Obvious next step** — is the primary action (call / book / buy / contact) visible immediately and one tap away? *(moment: ready to act — can they?)*
3. **Proof up front** — are real reviews, results, or credentials above the fold, before the ask? *(moment: deciding whether to trust you)*
4. **Five-second clarity** — can a stranger *and* a search engine / AI assistant tell what you do, for whom, and where, in five seconds? *(moment: scanning you / Google + LLMs parsing you)*
5. **After-hours answer** — is there any way to get a question answered when no human is available (chat, clear FAQ, obvious info)? *(moment: the buyer arrives at 11pm)*
6. **Trust markers** — real names/faces, a guarantee, a plain credentials line; no fake or hollow signals. *(moment: "are these people real and safe?")*

The scorecard is the same six checks for everyone, scored against this one site — the wins and the gaps together, in plain English. It is a read of their site, not a sales pitch with their name on it. State that honesty in the deliverable.

### 4. Assumption-gap analysis

Surface **exactly 3 structural gaps** where the site's promise contradicts the review corpus. Each gap requires:

- **Site claims:** verbatim quote from their hero/copy/section
- **Customers say:** 3–5 corroborating review snippets, cited (source + date)
- **The gap:** one sentence
- **The fix:** what the new copy does differently

Common gap shapes for service businesses: speed/punctuality, pricing transparency, upsell/commission pressure, response time, technician quality, follow-through. For B2B SaaS: onboarding friction, AE/CSM responsiveness, roadmap honesty, contract flexibility.

### 5. The rebuild — in their voice, only the copy changes

The deliverable is **their homepage, with their customers' words on it** — same site, same design, same font, only the hero copy changed. We are not redesigning or out-designing them. Produce two things:

**(a) The rebuilt hero** — the single strongest version (draft 2–3 stances internally, ship one):
- New headline (≤10 words) — the customer-language answer to the #1 review theme
- 3 value-prop bullets — each tied to a specific review snippet, in the words customers use
- One CTA label (e.g. "Get a written quote", "Book your consultation")

**(b) Three "why the copy changed" pairs** — for the explanation section. Each pair:
- **WAS** — the verbatim original line from their current hero (struck through)
- **NOW** — what it becomes
- **WHY** — one or two plain sentences on the gap (what the old line assumed vs. what customers actually fear/want)
- **REV** — one verbatim review quote (source cited) that drives the change

Use customer language verbatim. No jargon from `.codify/voice.md`'s anti-list. The headline must answer the fear/desire the reviews actually name — not a personality hook.

### 5b. Capture their homepage + measure the hero block (required for the rebuild-in-place)

The new template composites the rebuilt copy **over a real screenshot of their homepage**, so it reads as *their* site with the words swapped. Capture, measure, and read their type — via Playwright (headless), at a **1200px-wide viewport**:

1. **Screenshot** their live above-the-fold → save as `home.png` next to the deliverable (`~/sites/codify-site-previews/{slug}/home.png`). This is the canvas; their real van/photo/logo/nav/rating stay visible.
2. **Measure the hero text block** — `getBoundingClientRect()` of the container that holds their current headline + subhead + CTA. Convert to **percentages of the 1200×(viewport height)** and fill `{{CARD_LEFT}}`, `{{CARD_TOP}}`, `{{CARD_W}}`, `{{CARD_H}}` so the rebuilt panel lands exactly over the old copy and fully covers it. Pad generously so no old text peeks. Sensible fallback if measurement fails: `left:5.5% top:47% width:47% height:34%`.
3. **Read their type** — `getComputedStyle(h1).fontFamily` → `{{HERO_FONT}}` and the heading color → `{{HERO_COLOR}}`, so the new copy is in **their** font, not ours. If the family is a non-web-safe custom font, fall back to the nearest generic (`Arial, sans-serif` or `Georgia, serif`) — the screenshot already shows their real type in the surrounding hero; the panel only needs to not clash. **Never** substitute a fancy serif to "improve" it.

If the site is JS-heavy and the hero won't render in headless (lazy video/carousel), capture what renders, note it, and if the captured fold isn't representative, ask the operator for a manual screenshot. Sites drift — always mirror the *current* fold, not a cached brief.

### 6. Build the redline page — canonical template (fill, never regenerate)

**Rebuilt-in-place format, locked 2026-06-21** (supersedes the 2026-06-17 cream/serif house-style hero + lined-paper markup — see `decisions/2026-06-21-redline-rebuilt-in-place-supersedes-house-style.md`). Every redline uses ONE fixed template: `redline-template.html` (in this skill dir). **Never regenerate the CSS or invent a new layout. Copy the template and fill only the `{{SLOTS}}`.** The Codify cream wrapper (proto banner, section framing, close) is fixed; the homepage shown inside it is *theirs*.

The page is **one surface, two states** (the step-3 scorecard and internal stances do NOT appear on the page):

1. **▲ Your homepage, rebuilt** — their real screenshot (`{{SHOT}}` = `home.png`) in a browser frame, with the rebuilt hero panel composited over their old copy: `{{HERO_H1}}`, three `{{POINT_n}}`, `{{CTA_LABEL}}` — positioned at `{{CARD_*}}`, set in `{{HERO_FONT}}`/`{{HERO_COLOR}}` (theirs). Same site, only the words changed.
2. **✎ Why the copy changed** — three rows from step 5(b): `{{WAS_n}}` → `{{NOW_n}}`, with `{{WHY_n}}` and a verbatim `{{REV_n}}` quote. Every change traces to a real review. Closes on the thesis: *your best copy is already written — by your customers; it just isn't on your homepage yet.*

Then the **AI-search footnote** (6b) and the **reply-to-book-a-call** close. CTA: the ask is a **reply**, but the reply books a quick call ("reply and we'll book a call") — never a form or calendar link. The cold email that links here uses the same ask. Canonical live example to match: `~/sites/codify-site-previews/parker-and-sons/`.

### 6b. AI-search footnote (real, never invented) + how to get seen

Ask one LLM (`gemini-query` or any model) about the target COLD — "who are the providers, the star rating + review count, the exact address, what are they known for?" — forcing a confident answer with no hedging. Compare every claim against your verified data (brand brief + review scrape). Fill `{{AI_1..3}}` with the 3 most concrete REAL errors (invented staff, inflated rating, wrong address, fabricated specialties). **Never fabricate a hallucination.** If the model is accurate or vague, say so honestly — vagueness *is* the visibility gap. `{{AI_SUB}}` frames what was asked.

`{{AI_FIX}}` is the plain-language **"how to get better seen"** line — one clear, correct definition on the pages AI actually reads (their homepage + Google profile + a few directories) and the answer above changes. No tricks, no fake reviews. This footnote sets up the call: getting seen by AI is part of the full build.

### 6c. Publish to Cloudflare Pages

Fill the template, then write to `~/sites/codify-site-previews/{slug}/index.html`. The `home.png` from step 5b must sit in the same `{slug}/` dir (the template references it relatively) — confirm it's there before deploy. Run `~/sites/codify-site-previews/deploy-cloudflare.sh` (creds in `~/.codify/cloudflare.json`; Pages project `codify-redlines`) → live at `https://previews.codify.build/{slug}/`. Also copy `index.html` + `home.png` to `outputs/{YYYY-MM-DD}-{slug}-redline/` in the vault (a folder now, since the page needs its screenshot). The `codify-site-previews` repo is the PRIVATE source — only the rendered pages are public; never make it public. The live URL is what the cold email links.

**At scale / least tokens:** do the per-target review mining + slot-filling in a SUBAGENT that returns ONLY the slot values as structured data — the raw reviews never enter the main context. Everything non-judgment (brand curl, Apify reviews, the step-5b Playwright capture/measure, template fill via script, Cloudflare deploy) is code, not tokens. Batch N targets through a pipeline, one subagent each. The Playwright screenshot+measure is the one added cost vs. the old format — it's per-target and headless; keep it in the code path, not the judgment path.

### 7. Handoff drafts

Generate three handoff artifacts:

- **3 cold email pitches** → `outputs/{YYYY-MM-DD}-{slug}-emails.md`
  Each pitch attaches the redline link. Targets a specific intent: (a) the high-quote / sticker-shock prospect, (b) the urgent / emergency-need prospect, (c) the warranty/quality-dispute prospect.

- **3 paid-search ad headlines** → `outputs/{YYYY-MM-DD}-{slug}-ads.md`
  One per assumption gap. Each: H1 (≤30 chars), H2 (≤30 chars), description (≤90 chars).

- **4 reference-file rewrites** → `outputs/{YYYY-MM-DD}-{slug}-reference/{soul,voice,audience,offer}.md`
  Drafted from the review corpus. These are FOR THE TARGET (what their `.codify/` should look like if they hired Codify), not for the user. Used as a teaser in the cold email: "we already drafted your reference files — reply to see them."

## Output: operator-queue ticket

Write one ticket to `operator-queue/{YYYY-MM-DD}-redliner-{NNN}.md` where NNN starts at 001 for the first redliner run today.

Frontmatter:

```yaml
---
agent_id: redliner
started_at: <ISO timestamp>
ended_at: <ISO timestamp>
surface: cli
input: "Redline target: <url>"
output_file: outputs/<filename>.html
artifacts:
  - briefs/<slug>-brand.md
  - briefs/<slug>-reviews.md
  - outputs/<slug>-redline/index.html
  - outputs/<slug>-redline/home.png
  - outputs/<slug>-emails.md
  - outputs/<slug>-ads.md
  - outputs/<slug>-reference/
review_count: <N>
platform_count: <N>
status: completed
marks: []
---
```

Body:

```markdown
## Output

Redlined **<target name>** (<url>).

First-impression scorecard: <N>✅ / <N>⚠️ / <N>❌ across the six checks.

3 assumption gaps:
1. <gap-1>
2. <gap-2>
3. <gap-3>

Mined <N> review snippets across <N> platforms.

Deliverable: [outputs/<filename>.html](../outputs/<filename>.html)
```

## Append-only invariant

`operator-queue/` and `outputs/` are append-only. Never overwrite an existing file. If the same date+slug already exists, append `-v2`, `-v3`, etc.

## When the user reads back

After the deliverable + ticket are written, say:

```
Redline live: https://previews.codify.build/<slug>/
Their real homepage, rebuilt in place (only the copy changed) + "why the copy changed" from reviews + an AI-search footnote. CTA: reply to book a call. 3 emails + 3 ads + 4 reference rewrites drafted.

Open the live URL on a phone to QA before sending — check the rebuilt panel fully covers the old hero text.

Next: 1. /co-sequence       turn the 3 emails into a +3d / +9d cadence
      2. /co-activate       schedule the redline as the cold-open dispatch
      3. /ads               polish the 3 headlines into Meta/Google sets
      4. /co-redline <url>  run another target
```

## Do NOT

- Do NOT invent review snippets. Every snippet must be real and cited. If you can't find 50, report the count and ask before proceeding.
- Do NOT score a scorecard check from a guess. Every ✅/⚠️/❌ needs one line of real evidence from the actual site. If a check can't be read from outside, mark it unknown and say so — never pad.
- Do NOT make the read all-criticism. Show the wins next to the gaps; a fair read is what earns the reply.
- Do NOT force a redline on an out-of-ICP or unreadable target (see step 0). Decline gracefully or offer the by-hand read instead.
- Do NOT fabricate gap claims. Every change needs a corroborating review quote, cited with source + date.
- Do NOT restyle or out-design their homepage. The rebuilt panel sits on a screenshot of THEIR real site, in THEIR font and color — only the WORDS change. We are not the graphic designer; the point is that their best copy is their customers', not on the page yet. Never swap in a fancy serif or a "nicer" layout.
- Do NOT skip the step-5b capture. The rebuild composites over `home.png` of their *current* fold (sites drift) — a redline built from a stale brief, with the panel in the wrong place or peeking the old text, is a miss. QA that the panel fully covers the old hero.
- Do NOT regenerate the template CSS or invent a per-target layout. Copy `redline-template.html` and fill the `{{slots}}` — the brand-consistency and token-efficiency contract.
- Do NOT use a form or calendar link as the CTA. The ask is a **reply**, and the reply books a quick call ("reply and we'll book a call") — page and email both (updated 2026-06-21).
- Do NOT use words from `.codify/voice.md`'s anti-jargon list anywhere in commentary.
- Do NOT send the redline yourself. The skill writes the deliverable; the operator (or `/co-activate`) sends.
- Do NOT redline a competitor of the user without flagging it. Check `.codify/audience.md` disqualifiers before proceeding.
