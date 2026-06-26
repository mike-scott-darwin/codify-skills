---
name: co-skill-brief-draft
description: "Composable sub-skill. Drafts a locked brief from .codify/ files + research files + architect picks (dial, archetype, headline formula). Used by /co-site as the brief-drafting step. Loadable independently by /co-ad, /co-email, /co-content, /co-pitch when they need the same brief shape. Not a standalone operator skill — invoked by other Codify skills programmatically."
---

# /co-skill-brief-draft — Composable Brief Drafting

Composable sub-skill. Other Codify skills call this when they need a locked brief in a canonical schema before generating output.

**Not a standalone operator skill.** Invoked by `/co-site`, `/co-ad`, `/co-email`, etc.

---

## Inputs

The caller passes:

- **Output kind** — `site` | `ad` | `email-sequence` | `vsl` | `pitch` | `content-push`
- **Active offer** — slug or path (defaults to `.codify/offer.md` for single-offer vaults)
- **Linked research** — paths to relevant `research/*.md` files (optional but recommended)
- **Architect picks:**
  - `dial` — `convert | story | brand`
  - `archetype` — optional, e.g., `silent-reformer`, `loud-revolutionary`, `quiet-craftsman` (caller picks from a defined list)
  - `audience_current_archetype` — optional, who the audience currently thinks they are
  - `headline_formulas_picked` — 2-3 from a defined formula list (caller surfaces choices)
- **Slug** — used in the output filename

---

## Outputs

A single markdown artifact at `decisions/[YYYY-MM-DD]-brief-[kind]-[slug].md`:

```yaml
---
type: brief
status: proposed
date: [today]
last-updated: [today's date and time]
slug: [slug]
kind: site | ad | email-sequence | vsl | pitch | content-push
offer: [path to active offer.md]
dial: convert | story | brand
archetype: [optional]
audience_current_archetype: [optional]
copy_framework_tag: [pas | aida | qvc | etc.]
headline_formulas_picked: [...]
do_not_state: [list of things the chosen archetype must never say]
four_forces:
  push: [what's pushing the audience away from status quo]
  pull: [what's pulling them toward the new]
  habit: [habit-anchor that resists change]
  anxiety: [fear about making the change]
voice_anchor_lines:
  use: [3-5 lines from .codify/voice.md that capture the tone]
  avoid: [3-5 banned phrases from .codify/voice.md]
linked_research:
  - research/...
---
```

Plus the body:

```markdown
## Promise
[Single-sentence transformation the audience gets.]

## Audience
[1-paragraph from .codify/audience.md — who they are, what they want, what they fear.]

## Mechanism
[How the offer delivers the transformation — from .codify/offer.md, simplified.]

## Headline + Subhead
[Drafted using one of the picked formulas. ≤ 2 lines.]

## Value Prop
[3 short reasons OR one extended argument. Match the dial.]

## Sections / Steps
[For site: hero, problem, solution, how-it-works, proof, CTA. For ad: hook, body, CTA. For email: subject, preview, body, CTA. For VSL: cold-open, problem, mechanism, proof, offer, close.]

## CTA
[Single specific action. No "learn more".]

## Adjacency Map (sites only)
[Per section, name 2 supporting visuals or proof anchors that reinforce — not decorate.]

## Conversion Endpoint
[Where the CTA lands. URL, form, calendar link, payment page.]
```

Status lifecycle: `proposed` → `accepted` (architect approves the brief) → `locked` (generation can begin) → `superseded` (a later brief replaced it).

---

## Flow

### 1. Read Inputs

- Load active `.codify/offer.md`, `.codify/audience.md`, `.codify/voice.md`, `.codify/soul.md`
- Load each linked `research/*.md` file
- Load `.codify/exemplars/[kind]/` if present (caller passes kind; exemplars set the structural target)

### 2. Compose Frontmatter

Fill all required schema fields from caller picks and `.codify/` content:

- `dial` — from caller
- `archetype` + `do_not_state` — if archetype passed, load its do-not-state list
- `copy_framework_tag` — caller-picked or default (`pas` for convert, `story-arc` for story, `voice-led` for brand)
- `four_forces` — extract from `.codify/audience.md` (current pain/aspiration) and `.codify/offer.md` (the change being offered)
- `voice_anchor_lines.use` + `voice_anchor_lines.avoid` — pull 3-5 each from `.codify/voice.md`

### 3. Draft Promise

One sentence. The transformation, in the audience's words. Read `.codify/offer.md` for the canonical promise; rewrite if too long or jargon-y.

### 4. Draft Audience Section

One paragraph. Pull from `.codify/audience.md` voice-of-customer language. No generic demographics.

### 5. Draft Mechanism

How the offer delivers. From `.codify/offer.md`. Simplify to 3 steps maximum. Don't list features — describe the change.

### 6. Draft Headline + Subhead

Apply one of the picked headline formulas. Generate 3 options inline so the architect can pick during review.

Keep to ≤ 2 lines total. Match the dial:

- `convert`: lead with specificity + outcome
- `story`: lead with tension + character
- `brand`: lead with belief + identity

### 7. Draft Value Prop

3 short reasons (for `convert`) OR one extended argument (for `story` / `brand`). Each backed by `.codify/offer.md` mechanism or `.codify/proof/` testimonials.

### 8. Pick Sections / Steps

From the output kind:

| Kind | Default sections |
|---|---|
| site | hero, problem, solution, how-it-works, proof, CTA |
| ad | hook, body (problem + reframe + proof), CTA |
| email-sequence | day-0 (intro + value), day-3 (objection), day-7 (close) |
| vsl | cold-open, problem, mechanism, proof, offer, close |
| pitch | hook, credibility, mechanism, ask |
| content-push | hook, body (3-5 ideas), takeaway, soft CTA |

### 9. Build Adjacency Map (Sites Only)

For each section, name 2 supporting visuals or proof anchors. The Hughes paired-imagery rule: every claim deserves two reinforcements, not one. Visuals reinforce — they don't decorate.

### 10. Define Conversion Endpoint

Where does the CTA land? URL, form, calendar, payment page. If unknown, mark `[ARCHITECT: confirm endpoint]` and surface to caller.

### 11. Write to Disk + Return

Write the brief file. Return to caller:

```json
{
  "brief_path": "decisions/[YYYY-MM-DD]-brief-[kind]-[slug].md",
  "status": "proposed",
  "blocking_unknowns": ["conversion_endpoint"]
}
```

If `blocking_unknowns` is non-empty, caller must resolve before locking the brief.

---

## When NOT to Use

- The caller already has a locked brief — don't redraft
- The output is short/one-off (a single tweet, a Slack reply) — overkill
- `.codify/` files are thin (`status: draft`) — fix substrate first via `/co-extract`

---

## Caller Examples

**`/co-site` Lander Flow Step 4:**

> Calls `/co-skill-brief-draft` with kind=`site`, dial picked by architect, linked research from the site research file. Returns the brief path. `/co-site` shows it to the architect, who flips status to `accepted` then `locked` before Step 5 (concept variations).

**`/co-ad` for a new test:**

> Calls `/co-skill-brief-draft` with kind=`ad`, dial=`convert`, archetype picked from the audience archetype library. Returns the brief. `/co-ad` uses it to generate hook + body + CTA + image prompt.

---

## Lock Flow

The brief is **proposed** when this skill returns it.

The caller (or architect) flips to **accepted** after review.

The caller flips to **locked** before invoking generation. Locking is the signal that downstream variation (via `/co-skill-concept`) and review (via `/co-skill-review`) can begin.

Briefs that go stale (offer changes significantly, audience reframes) flip to `superseded` and link forward to the new brief in frontmatter (`superseded_by: decisions/[new-brief].md`).
