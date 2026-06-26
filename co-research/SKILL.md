---
name: co-research
description: "Research a prospect, competitor, market trend, or topic. Saves to research/ and cross-references with Context files. Compounds over time."
---

# /co-research — Research That Compounds

Gathers intelligence and saves it to your vault where it informs every future output. Research files are the fuel for `/co-ad`, `/co-email`, `/co-proposal`, and `/co-pitch` (objection responses).

## Usage

```
/co-research                    → Ask what to research
/co-research prospect [name]    → Pre-call brief on a prospect
/co-research competitor [name]  → Competitive analysis
/co-research market [topic]     → Market trend or industry signal
/co-research topic [topic]      → Deep dive on any subject relevant to your business
/co-research opportunities      → Scan all context + research files for revenue opportunities
/co-research x-intel [@handle]  → Last 7d of X activity for a prospect (Grok + xAI x_search)
/co-research current [slug]     → Sweep a queue topic via Grok depth ladder (X → Reddit → GitHub)
```

## Before Researching

Read these files first:
1. `core/audience.md` — So you can flag fit signals for prospects
2. `core/soul.md` — So you can compare competitors against your positioning
3. `core/offer.md` — So you can identify differentiation gaps
4. Recent files in `research/` — So you don't duplicate existing research

---

## Mode: Prospect Research

**Triggered by:** `/co-research prospect David Park` or `/co-research prospect Meridian HVAC`

### What to Find

Use web search to gather:
- Company overview (what they do, size, industry, revenue if public)
- The person's role, tenure, background
- Recent news, press mentions, podcast appearances
- Company reviews (Glassdoor, G2, industry forums)
- LinkedIn profile summary (via Google cache — do NOT scrape LinkedIn directly)
- Any public content they've written or been quoted in

### Cross-Reference with Context

After gathering, compare findings against `audience.md`:
- **Fit signals** — Does this person match the buyer profile? Flag specific matches.
- **Pain signals** — Any indicators of the problems described in `audience.md#Voice of Customer`?
- **Buying trigger signals** — Any recent events that match `audience.md#Buying Trigger`? (leadership change, acquisition activity, rapid growth, public complaints)
- **Disqualifier signals** — Anything that matches `audience.md#Disqualifiers`? Flag honestly.

### Output Format

```markdown
## Pre-Call Brief: [Name] — [Company]

### Fit Assessment
[Strong fit / Possible fit / Likely not a fit] — [one-line reason]

### Background
[2-3 sentences on the person and company]

### What They're Likely Dealing With
[Based on company signals cross-referenced with audience.md]

### Talking Points
- [Specific thing to reference in conversation]
- [Question to ask based on what you found]
- [Connection point to your framework from soul.md]

### Watch For
[Any disqualifier signals or red flags]

### Sources
[Links to where you found this information]
```

### When the prospect has a public X handle

Also run `/co-research x-intel @handle` (see X Intel mode below). Output goes
to a sibling `x-intel.md` artifact and is read by `deliverable-writer` and
`outreach-sequencer` automatically. If no handle is found in your prospect
research, skip — do not invent one.

---

## Mode: X Intel

**Triggered by:** `/co-research x-intel @stephenwurfel` or invoked by
`prospect-researcher` when a prospect's X handle is known.

Pulls the last 7 days of X activity for a single handle via the
`constant_quadruped/x-feed-monitor` Apify actor, which wraps xAI's native
`x_search` API. Returns raw posts; Claude does the synthesis.

### How to call it

Through the `apify` MCP (already configured globally — see
`reference/core/connectors.md` for actor list). Requires `GROK_API_KEY` in
the environment (or passed as `grokApiKey` input). Invoke with:

```json
{
  "queries": ["from:<handle>"],
  "mode": "collect",
  "analysisLevel": "none",
  "maxResults": 100,
  "sinceMinutes": 10080,
  "dedupe": true,
  "includeReplies": true,
  "includeReposts": false,
  "includeQuotes": true,
  "maxCostUsd": 0.10
}
```

### Hard rules

- `mode: "collect"` and `analysisLevel: "none"` are non-negotiable — they
  enforce Devon principle #2 (Grok collects, Claude synthesizes) at the
  actor input level.
- `maxResults: 100` is the actor's hard cap per query. Do not paginate.
- `sinceMinutes: 10080` = 7 days. For deeper history use
  `apidojo/tweet-scraper` instead.
- `maxCostUsd: 0.10` is a per-prospect safety gate. Topic-mode sweeps may
  raise to `0.30`.

### Save to vault

Per-prospect (when called from `prospect-researcher`):
`campaigns/nightly/<YYYY-MM-DD>/<prospect-slug>/x-intel.md`

Ad-hoc (when called by the operator directly):
`research/x-intel/<YYYY-MM-DD>-<handle>.md`

### Output format

Use the schema defined in
`decisions/2026-05-24-grok-x-intelligence-actor-for-prospect-research.md`.
Frontmatter is required (incl. `x_handle`, `window_days`, `post_count`,
`actor_run_id`). Body sections are deterministic — do not rename:

- `## Intent signals`
- `## Sentiment`
- `## Themes`
- `## Top posts`
- `## Raw query`

### Skip-if-no-handle

If you cannot find a verified X handle for the prospect, write a stub with
`stage_status: skipped` and `x_handle: null`. Do not guess handles.

---

## Mode: Current Info (Grok depth ladder)

**Triggered by:** `/co-research current image-gen-models-2026` or invoked by
the `current-info-researcher` agent on its nightly schedule.

The default research engine for anything that moves daily. Use this — not
Claude's web search, not GPT — for model drops, new tools, fast-moving
competitor activity, and active community conversations. Reason: Claude/GPT
can't see X in real time and lean on month-old publication scraping.

### Topic queue

The operator maintains `.codify/queues/current-info-topics.md`. Each topic
has frontmatter declaring its slug, goal, passes, currency, and cadence. The
agent reads this file and sweeps the topics that are due. Operators can also
invoke a one-off sweep on any slug that exists in the queue.

### The depth ladder (Devon principle #3)

Three passes per topic, in order:

1. **X pass** — `x_search`, last 7 days, source = X. Catches the announcement
   and viral threads.
2. **Reddit pass** — `web_search` filtered to `site:reddit.com`, last 30 days.
   Catches lived-experience reports and the comments under the announcement.
3. **GitHub pass** — `web_search` filtered to `site:github.com`, last 14 days.
   Catches the actual implementation, issues, and active forks.

A topic may set `passes: [x]` to skip rungs (e.g., when tracking a single
human prospect's X activity).

### Transport resolution (per pass, resilient — never hard-fail the sweep)

Each rung picks the best transport that is **actually available on the box** at
run time. Resolve in this order and record the chosen transport in the pass
file's `transport:` frontmatter:

**Transport = xAI Agent Tools API** (`POST https://api.x.ai/v1/responses`,
`model: grok-4.3`, `stream:false`, server-side `tools`). This **replaces the
deprecated xAI Live Search API** (`search_parameters` returns HTTP 410 — "switch
to the Agent Tools API"). One credential (`GROK_API_KEY`) covers all three
rungs; **no Apify needed** — X is native via `x_search`.

| Pass | Primary (if `GROK_API_KEY` present) | Fallback (no Grok key) |
|---|---|---|
| `x` | `tools:[{"type":"x_search"}]`, 7-day window via prompt | **none — skip.** Write `x-pass.md` with `stage_status: skipped` + `skip_reason: no GROK_API_KEY`. X is first-party-licensed only; do NOT substitute a scraper. |
| `reddit` | `tools:[{"type":"web_search","allowed_websites":["reddit.com"]}]`, 30-day via prompt | `firecrawl_search`, `site:reddit.com`, 30-day (needs Firecrawl credits) |
| `github` | `tools:[{"type":"web_search","allowed_websites":["github.com"]}]`, 14-day via prompt | `firecrawl_search`, `site:github.com`, 14-day |
| `synthesis` | Claude (this session) — always available | same |

**Parsing a `/v1/responses` reply:** the final `output[]` item with
`type:"message"` holds `content[0].text` (the collect-only listing) and
`content[0].annotations[]` of `type:"url_citation"` (the permalinks → pass-file
`## Cited sources`). `usage.cost_in_usd_ticks` ≈ per-call cost; a 3-rung sweep
runs ~$1.3. Each pass ran live first on 2026-06-21 — see
`research/current/2026-06-21-managed-agent-ops-2026/`.

**Hard rule: a missing key degrades a single rung, it never aborts the sweep.**
A topic that loses its X rung still ships reddit + github + synthesis, with the
synthesis explicitly noting "X pass skipped — no live-X surface this run." This
is exactly how the 2026-06-15 sweeps survived the absent Grok key.

> **Reddit rung — operator-ratified scope (2026-06-21).** The manual-only
> policy (`decisions/2026-06-06-reddit-manual-only-compliance.md`) is amended by
> `decisions/2026-06-21-reddit-rung-search-discovery-amendment.md`: the reddit
> rung runs as **search-index DISCOVERY only** — `firecrawl_search` returning
> thread titles + URLs + snippets, `scrapeOptions` OFF. **Hard limits, do not
> cross:** no `firecrawl_scrape`/`crawl` of reddit.com thread bodies, no Reddit
> API/PRAW, no comment extraction. Those remain banned pending Reddit's written
> approval (Reddit for Researchers). The pass file lists discovered threads
> (title + permalink + snippet); deeper reading of any thread is done
> in-browser by the operator and folded into synthesis. A snippet is a pointer,
> not a harvested dataset.

### The collect-only rule (Devon principle #2)

Grok is bad at recommendations and tends to overhype. Every pass prompt MUST
end with this paragraph verbatim:

> Collect posts, threads, repos, and quoted snippets relevant to the topic.
> Do not rank, recommend, summarize, or pick a winner. Do not say "the best"
> or "the most popular." List what you found with dates and links. A separate
> synthesis pass will make recommendations.

If a pass file contains words like "best", "recommend", "winner", "you
should" — it's contaminated. The `editor` agent flags these and they count
against the agent in the weekly tuning loop.

### Synthesis pass (Claude only)

After all three passes complete, a Claude pass reads them + the topic
frontmatter and writes `synthesis.md`. This is the only file that contains
recommendations. **Grok never writes synthesis.md** — hard rule.

Synthesis frontmatter requires `synthesizer: claude`, `passes_read: [...]`,
and `stale_by:` (an ISO date the synthesis expires).

### Save to vault

Per-topic (nightly sweep):
```
research/current/<YYYY-MM-DD>-<topic-slug>/
  topic.md
  x-pass.md
  reddit-pass.md
  github-pass.md
  synthesis.md
```

Single-topic / prospect mode (called from `prospect-researcher`):
collapsed into `campaigns/nightly/<date>/<prospect-slug>/x-intel.md`
for downstream agent compatibility.

### Full schema + agent contract

See `decisions/2026-05-24-grok-as-current-info-research-engine.md` for the
canonical artifact schema, frontmatter requirements, and per-pass H2
structure. See `.codify/agents/current-info-researcher.md` for the agent
that owns this mode.

### Running the sweep (orchestration — Devon's parallel fan-out)

This is the executable recipe. Devon's pattern: an orchestrator delegates to
foreground sub-agents, each with one perspective + tool, each writing a dated
file; the orchestrator then synthesizes and can direct a second pass.

1. **Select.** Read `.codify/queues/current-info-topics.md`. Pick the topic(s)
   whose `last_swept` is older than their `cadence` window. A one-off invocation
   (`/co-research current <slug>`) overrides the window for that one slug.
   **Run-once governance** (`decisions/2026-06-06-m1-runaway-research-crons-incident.md`):
   never register a per-topic cron; honour `last_swept`; skip within-window re-runs.
2. **Snapshot.** Write `research/current/<YYYY-MM-DD>-<topic-slug>/topic.md` —
   an immutable copy of the queue entry at sweep time.
3. **Fan out (parallel, foreground).** Spawn one sub-agent **per rung in the
   topic's `passes:`**, concurrently (single message, multiple Agent calls).
   Each sub-agent: resolves its transport (table above), runs collect-only
   (the verbatim collect-only paragraph), and writes
   `<source>-pass.md` with full pass frontmatter (`transport`, `stage_status`,
   `items_collected`). A rung whose transport is unavailable writes its file
   with `stage_status: skipped` and returns — it does not raise.
4. **Synthesise (Claude, after passes land).** One agent reads every pass file +
   `topic.md` + `.codify/soul.md`, plus the **previous** sweep's `synthesis.md`
   for the same slug (delta detection), and writes `synthesis.md` against
   `topic.goal`. Frontmatter: `synthesizer: claude`, `passes_read: [...]`,
   `stale_by: <ISO date>`. This is the only file with recommendations.
5. **Record + close.** Update `last_swept:` in the queue. Append one
   `operator-queue/<date>-current-info-researcher-<seq>.md` run log
   (`goal_id: current-info-fresh-nightly`). Commit research + queue +
   operator-queue together; push to main (architect confirms PR/merge).

**Degradation is logged, never silent.** If any rung skipped, the
`operator-queue` entry and the synthesis both name which rung and why — an
absent X surface is signal, not an error to bury.

---

## Mode: Competitor Research

**Triggered by:** `/co-research competitor [name]`

### What to Find

- Their positioning (website, about page, sales page)
- Their offer structure and pricing (if public)
- Their content strategy (what they post, where, how often)
- Their client testimonials and case studies
- Their weaknesses (complaints, negative reviews, gaps in positioning)

### Cross-Reference with Context

Compare against your `soul.md` and `offer.md`:
- **Where you overlap** — Same claims, same audience, same language
- **Where you differ** — Your contrarian beliefs vs. their conventional positioning
- **Where they're weak** — Gaps in their offer that your framework addresses
- **Where they're strong** — Be honest. What are they doing well?

### Output Format

```markdown
## Competitor Analysis: [Name]

### Their Positioning
[What they claim to do]

### Your Differentiation
[Where your approach from soul.md diverges — be specific]

### Their Gaps
[What they don't cover that you do]

### Their Strengths
[What they do well — be honest]

### Opportunity
[One actionable insight for your positioning, content, or outreach]
```

---

## Mode: Market Research

**Triggered by:** `/co-research market [topic]`

Search for trends, data, reports, and signals on the topic. Cross-reference against `soul.md` and `audience.md` to find angles unique to your positioning.

### Output Format

```markdown
## Market Signal: [Topic]

### What's Happening
[Summary of the trend or data]

### Why It Matters to Your Business
[How this connects to your audience, offer, or positioning]

### Opportunity
[What you could do with this — content angle, offer adjustment, outreach timing]

### Sources
[Links]
```

---

## Mode: Topic Research

**Triggered by:** `/co-research topic [topic]`

Deep dive on any subject. Could be an industry concept, a methodology, a new regulation, a technology shift — anything the client wants to understand better.

Cross-reference against all Context files and existing research to find connections.

---

## Mode: Opportunities

**Triggered by:** `/co-research opportunities`

This is the strategic scan. Reads your full vault — all Context files, all research, all decisions — and surfaces revenue opportunities unique to your positioning.

### Load Full Context

Read in order:
1. All `core/` files
2. Last 10 `decisions/` files
3. All `research/` files
4. Last 5 `campaigns/` files (to avoid repeating)

### Cross-Reference

- What does your `soul.md` say you believe that your market doesn't? Where's the content gap?
- What does `audience.md` say they struggle with that no competitor is addressing?
- What does `offer.md` deliver that competitors don't mention? Where's the positioning gap?
- What patterns emerge across your prospect research? Who keeps showing up?
- What recent decisions suggest a new angle?

### Output Format

For each opportunity:
- **The signal** — What data point triggered this
- **The gap** — Why nobody else is doing this
- **The play** — What you'd actually do (content, outreach, offer adjustment)
- **The source** — Which files informed this insight

---

## Save to Vault

Write ALL research to `research/[YYYY-MM-DD]-[mode]-[slug].md` with frontmatter:

```yaml
---
type: research
format: [prospect|competitor|market|topic]
date: [today]
last-updated: [today's date and time]
confidence: [high|medium|low|uncertain]
related:
  - "[[audience]]"
  - "[[soul]]"
---
```

**Always add `[[cross-references]]`** to the Context files that informed or are informed by this research.

### How to set `confidence`

| Value | Use when |
|---|---|
| `high` | Direct primary source — pulled from the company website, the prospect's own posts, an article you fetched in full, a number from an authoritative report. |
| `medium` | Multiple aligned secondary sources but no primary. Inference from observable signals (job postings, hiring patterns, public reviews). |
| `low` | Single secondary source, or inference from indirect signals (your own pattern-matching across past clients). State the inference chain in the body. |
| `uncertain` | You're guessing. Save anyway — the next research run can promote it — but flag the uncertainty so downstream agents discount it. |

Downstream skills (`/co-ad`, `/co-email`, `/co-proposal`, `/co-pitch`) should weight `high` claims heavily, treat `medium` as supporting, surface `low` as hypotheses, and ignore `uncertain` unless explicitly asked. The `/co-audit` skill will surface stale `low`/`uncertain` files for review.

## The Compound Loop

Research files are not throwaway. They accumulate:
- `/co-research opportunities` scans all research files to find patterns across prospects and competitors
- `/co-ad` and `/co-email` reference recent research for timely angles
- `/co-pitch` pulls competitor research for objection-handling and differentiation arguments
- `/co-proposal` uses prospect research for personalized framing
- The architect reviews research during Brain Sync calls to spot strategic patterns the client can't see from inside their business

**More research = smarter outputs. That's the compound loop.**

## Architect Integration

The architect uses research during Brain Sync sessions:
- Reviews accumulated prospect research to identify ideal client patterns
- Reviews competitor research to refine positioning in `soul.md`
- Reviews market research to inform strategic decisions in `decisions/`
- Spots patterns across multiple research files that the client misses day-to-day
- Updates Context files based on research insights — this is where compounding happens

Research is the raw material. The architect turns it into strategic direction. The Context files capture the direction. The outputs reflect it. That's the loop.
