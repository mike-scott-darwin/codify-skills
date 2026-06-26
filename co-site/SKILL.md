---
name: co-site
description: "Triage and build the site shape the client needs — quick HTML page, lander (1 page), or minisite (~4-6 pages) — and ship it. Also writes owned-surface sales videos and embedded pitch scripts. Routes to per-shape build flow, reads from .codify/ context files, deploys to Cloudflare Pages with git auto-deploy. Use when: (1) Architect needs to ship a Snapshot rebuilt-homepage prototype (2) Setting up a new lander or minisite (3) Iterating on an existing site (4) Graduating shapes (lander → minisite) (5) Writing a VSL, about-page video, or embedded pitch script for an owned conversion surface (6) Generating a quick self-contained HTML page for review."
---

# /co-site — Pick a Shape. Build It. Ship It.

The infrastructure skill that turns vault context into a live conversion surface. Used by the architect on behalf of the client — Snapshot rebuilt-homepage prototypes (Station 1), lander tests, minisite funnels.

**Default deploy rail:** Cloudflare Pages with git auto-deploy. Sovereign hosting, free tier, custom domains.

---

## Re-Invoke Often

Say `/co-site` again after compaction, context loss, or switching focus. It reloads skill context. Do it whenever the conversation feels stale.

---

## Operating Principles

Four behaviors `/co-site` uses on every run:

1. **One flow: brief to site.** Walk research → brief → review → lock → build → publish as one flow. No skill-hopping mid-flight.
2. **Foreground subagents, parallel by default.** Multiple research questions or concept variations run in parallel.
3. **Publish-first, then iterate.** Commit the rawest working version before polishing. Git history is the memory across context clears.
4. **Architect-operated.** The client never runs this. The architect runs it on their behalf and ships the artifact via WhatsApp or `codify.build/vault`.

---

## Before You Start

Read these in order:

1. `.codify/soul.md` — who they are
2. `.codify/audience.md` — who they serve
3. `.codify/offer.md` — what they sell
4. `.codify/voice.md` — how they sound
5. `.codify/design.md` — brand colours, fonts, style (if it exists)

Also scan recent `decisions/` and `research/` for context.

Then load `.codify/exemplars/landing/` and `.codify/exemplars/sales-page/` if present — voice files set the rules, exemplars show the rules in practice.

If any core file has `status: draft` or is mostly empty, stop and route to `/co-extract`. Don't ship from a thin substrate.

**The site is public; the vault is not.** `.codify/` files inform the copy — they don't appear in it. Extract principles and positioning; never ship proprietary mechanisms from `soul.md` verbatim, internal client or prospect names from `audience.md`, unreleased offers or pricing logic from `offer.md`, or decision rationale from `decisions/`. If a draft quotes vault content that wasn't written for the public, rewrite it and tell the architect what was pulled.

If `.codify/design.md` doesn't exist and the architect is on Path B/C (deployable site), ask three questions to create one:

1. Brand colours? (If unsure, share logo or URL and extract them.)
2. Font preference? (Default: clean Google Fonts pairing.)
3. Feel — corporate, friendly, bold, minimal?

Save to `.codify/design.md` with the standard frontmatter. Include: colours (primary/secondary/accent/bg/text), fonts (headings/body), style (radius/spacing/shadow), components (button/card/section).

---

## Triage

Ask the architect. Do not assume.

> **What are you shipping?**
>
> **A. Quick HTML page** — Self-contained `.html` file, no repo, no deploy. For Snapshot rebuilt-homepage drafts, review artifacts, internal previews. → "Quick HTML" below.
>
> **B. Lander** (1 page, deployable) — Single-page site, paid-traffic destination, single offer. Own repo, Cloudflare Pages. → "Lander Flow" below.
>
> **C. Minisite** (4-6 pages, deployable) — Homepage + about + services + contact, or homepage + 3 offer pages. Static HTML, Cloudflare Pages. → "Minisite Flow" below.
>
> **D. Owned-surface video script** — VSL, about-page video, lander video, embedded pitch script. Lives in the vault. → "Video Script" below.
>
> **E. Iterating on an existing site** — Editing copy, adding sections, republishing. → load the current shape flow.
>
> **F. Graduating a shape** — Lander → minisite, or minisite → custom build (hand off). → "Graduation" below.

If the architect can't articulate the shape, ask: "What's the goal? Ship a redlined Snapshot artifact to a prospect? Spin up a paid-traffic destination? Replace a Squarespace?" Their answer maps to the shape.

---

## Quick HTML (Path A)

Single self-contained `.html` file. No repo, no deploy. Output stays in the vault — the architect emails or attaches it.

This is the primary path for the **Snapshot rebuilt-homepage** deliverable: read the prospect's actual site, rebuild it from what their customers already wrote, deliver as a single file the prospect can open in any browser.

### What to Generate

Ask: "What page — homepage (default for Snapshot), about, services, contact?"

**Homepage:**
1. **Hero** — Headline from `offer.md` transformation + subheadline + primary CTA
2. **Problem** — 3 pain points from `audience.md#Voice of Customer`
3. **Solution** — Approach from `soul.md`
4. **How it works** — 3 steps from `offer.md` delivery mechanics
5. **Proof** — Testimonials from `soul.md#External Perception`
6. **CTA** — Repeat the primary action

**About:** Origin from `soul.md#Origin Story`, mission, credentials, values.

**Services:** Offer breakdown from `offer.md` tiers, who-it's-for, what's included, pricing if public.

**Contact:** Simple form, direct line, social links.

### Build Rules

- All CSS inline in one `<style>` block (no external deps except Google Fonts)
- Mobile-responsive (flexbox/grid, media queries)
- Semantic HTML (`<header>`, `<main>`, `<section>`, `<footer>`)
- No JavaScript unless the page needs it (form validation, mobile nav toggle)
- Accessible — proper heading hierarchy, alt text, contrast ratios
- All colours, fonts, spacing from `.codify/design.md`

Do NOT: cookie banners, analytics, CSS frameworks (Bootstrap, Tailwind), placeholder images (use CSS shapes/gradients or `<!-- IMAGE: description -->` markers), over-design.

### Save Output

Two files per page:

**Copy** (review + edit): `campaigns/[YYYY-MM-DD]-site-[page-slug].md`

```yaml
---
type: output
format: site-copy
page: [homepage|about|services|contact]
date: [today]
last-updated: [today's date and time]
source_files:
  - .codify/soul.md
  - .codify/audience.md
  - .codify/offer.md
  - .codify/voice.md
  - .codify/design.md
---
```

**Built page** (ready to send): `campaigns/co-site/[page-slug].html`

Then: "Page ready. Open `campaigns/co-site/[page-slug].html` to preview. Edit the `.md` and re-run `/co-site` to rebuild."

---

## Lander Flow (Path B)

One-page deployable lander shipped to Cloudflare Pages.

### Step 1 — Site Config Discovery

```bash
cat ~/.codify/sites.json 2>/dev/null
```

- **Found, matches this offer:** load `site_repo`, jump to Step 4.
- **Found, different offer:** ask which site to work on.
- **Not found:** continue to Step 2.

### Step 2 — Create Site Repo

```bash
mkdir -p ~/sites
SITE_NAME="[slug-from-offer]"
gh repo create "$SITE_NAME" --private --clone --directory ~/sites/"$SITE_NAME"
cd ~/sites/"$SITE_NAME"
```

Add a `.codify/repo.json` descriptor in the site repo:

```json
{
  "kind": "site",
  "shape": "lander",
  "business_repo": "[absolute path to vault]",
  "offer": "[active offer]",
  "deploy": "cloudflare-pages"
}
```

### Step 3 — Cloudflare Pages Setup

Walk the architect through:

1. cloudflare.com → Workers & Pages → Create → Connect to Git → select repo
2. Build settings: command = (none), output = `/`, framework = none
3. First deploy completes → note the `*.pages.dev` URL
4. (Optional) Custom domain → DNS CNAME on a Cloudflare-managed domain

Save to `~/.codify/sites.json`:

```json
[
  {
    "name": "[site-name]",
    "site_repo": "[absolute path]",
    "business_repo": "[absolute path to vault]",
    "shape": "lander",
    "offer": "[active offer]",
    "deploy": "cloudflare-pages",
    "url": "https://[name].pages.dev"
  }
]
```

### Step 4 — Brief

Draft and lock a one-page brief in `decisions/[YYYY-MM-DD]-site-[slug].md`:

```yaml
---
type: decision
slug: site-[slug]
shape: lander
offer: [active offer]
status: draft
date: [today]
last-updated: [today's date and time]
---

## Brief
- Promise: [single transformation]
- Audience: [who, from audience.md]
- Offer: [what they buy]
- CTA: [single action]
- Tone: [from voice.md]
- Sections: hero, problem, solution, how-it-works, proof, CTA
```

Show the architect. Lock the brief (status: active) before generating.

### Step 5 — Concept Variations

Spawn foreground subagents — one per hero variation, in parallel:

- **A** — direct/transformation lead
- **B** — problem-first lead
- **C** — proof-first lead

Save each to `campaigns/co-site/[slug]-concept-[A|B|C].html`. Show all three. Architect picks one.

### Step 6 — Full Build

Generate the chosen concept as a complete `index.html` in the site repo:

- Single page, CSS inline (or extracted `style.css` if >500 lines)
- Google Fonts only, no other external deps
- Mobile-first, semantic, accessible
- All copy from `.codify/` reference files
- All visual choices from `.codify/design.md`

### Step 7 — Publish (Publish First, Then Iterate)

```bash
cd [site_repo]
git add -A
git commit -m "[add] initial lander from brief [slug]"
git push origin main
```

Cloudflare auto-deploys in ~30s. Verify the live URL.

### Step 8 — Iterate

Edits: change in repo → commit → push → auto-deploy. Architect reviews live URL; client sees the link in WhatsApp.

### Step 9 — Log to Operator Queue

Write `operator-queue/[YYYY-MM-DD]-co-site-[N].md`:

```yaml
---
agent_id: co-site
started_at: [iso timestamp]
surface: architect
input: "[lander for offer X]"
output_file: "[site repo url + commit hash]"
status: shipped
goal_id: [from agent definition or null]
cost_usd: [estimate]
tokens_used: [estimate]
marks: []
---
```

---

## Minisite Flow (Path C)

Multi-page (4-6 page) site. Same flow as Lander, with these differences:

- Step 4 brief lists all pages (homepage, about, services, contact + optional offer pages)
- Step 5 concept variations focus on the homepage hero only; inner pages follow the picked direction
- Step 6 builds all pages with consistent nav + footer
- Pages share one stylesheet — copy the `<style>` block across pages, or extract to `style.css` and `<link>` it
- Each page is its own `.html` file in the site repo root

Keep footer + nav consistent across every page. Use relative links between pages.

---

## Video Script (Path D)

For owned-surface video: VSL, about-page video, lander video, embedded pitch script.

Read:
- `.codify/soul.md` (origin, mission)
- `.codify/offer.md` (transformation, mechanics)
- `.codify/voice.md` (cadence, vocabulary, banned words)
- `.codify/exemplars/vsl/` if present

Ask: "Which surface — VSL (long-form, conversion), about-page (mid-length, credibility), lander embed (short, hook)?"

Generate a camera-ready script. Save to `campaigns/[YYYY-MM-DD]-video-[surface]-[slug].md`:

```yaml
---
type: output
format: video-script
surface: [vsl|about|lander|embed]
date: [today]
last-updated: [today's date and time]
length_estimate_min: [number]
source_files:
  - .codify/soul.md
  - .codify/offer.md
  - .codify/voice.md
---
```

If the script depends on a weak offer (thin transformation, vague mechanics), stop and route to `/co-extract offer`.

---

## Graduation (Path F)

When to graduate shapes:

- **Lander → Minisite:** lander is converting; client wants about/services/proof pages for SEO and warm traffic. Move to Minisite flow, port the lander as homepage.
- **Minisite → custom build:** minisite outgrew static HTML (needs CMS, payments, login). Hand off to a custom build — this skill stops here. Document the handoff in `decisions/`.

Always commit the working version before graduating. Never lose it.

---

## Reference Mapping

| Reference File | Powers |
|---|---|
| `.codify/offer.md` | Hero headline, value prop, pricing, CTA copy |
| `.codify/audience.md` | Problem section, pain language, objection handling |
| `.codify/voice.md` | Copy tone, vocabulary, banned words |
| `.codify/soul.md` | About section, mission, origin story |
| `.codify/design.md` | Colours, fonts, spacing, button + card style |
| `.codify/exemplars/landing/` | Tone exemplars for hero + section copy |
| `decisions/` | Locked briefs, shape choices, deployment decisions |

---

## Cloudflare Pages — Why Default

- Free tier covers most Codify clients
- Custom domains free
- Git auto-deploy, no CI to maintain
- Static HTML deploys in seconds, no build step needed
- Client retains repo ownership — sovereign hosting

If the client already has Netlify or Vercel, use what they have. Don't migrate without a reason.

---

## Pipeline Position

The site is **infrastructure**, not recurring content. Conversion endpoint that other skills drive traffic to:

```
/co-extract → reference files (foundation)
     ↓
/co-site → conversion endpoint (this skill)
     ↓ drives traffic to:
/co-ad → paid traffic → site
/co-content → organic → site
/co-email → outbound → site
```

When `.codify/offer.md` changes significantly (new pricing, new positioning), prompt: "Offer changed since the site was last published. Run `/co-site` to update?"

---

## Scope

- **In scope:** quick HTML pages, landers, minisites, owned-surface video scripts
- **Out of scope:** full CMS sites, ecommerce checkouts, app login flows, email templates (use `/co-email`), wikis
- **Snapshot rebuilt-homepage:** primary use case for Quick HTML path — generate the rebuilt artifact + redline annotations for outbound delivery

---

## Recovery from Compaction

If conversation compacted or context was lost:

1. Re-invoke `/co-site` to reload skill context
2. Check active site: `cat ~/.codify/sites.json`
3. Check site repo status: `cd [site_repo] && git status && git log --oneline -5`
4. Read the most recent `decisions/[YYYY-MM-DD]-site-*.md` for the locked brief
5. Resume from the last completed step

---

## Tone

Match `voice.md`. No hype, no filler. Every word earns its place. Lead with the point.
