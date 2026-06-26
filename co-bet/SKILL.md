---
name: co-bet
description: "Open, update, close, list, and narrate business bets from vault truth. Use when the operator wants to frame a time-boxed hypothesis, track progress, capture a verdict, or draft public-safe narration. Modes: new, update, close, list, narrate."
---

# /co-bet — Time-Boxed Hypotheses With Verdicts

A bet is a **time-boxed operating hypothesis** with appetite, target, deadline,
evidence, and a verdict. Bets are tests that close with `## Learning` — that's
the compounding artifact.

A bet is not an offer or a decision:
- **Offer** — a durable thing you sell
- **Decision** — a commitment that shapes future work
- **Bet** — a time-boxed test of an idea

A successful bet may graduate into an offer, workflow, content pillar, or
decision. A failed bet closes with a learning. Either way the vault gets
smarter.

Every bet declares the **money object it moves** (`money_path`) and the
**condition that ends it early** (`kill_rubric`). Those two fields let
`/co-money-path` rank open bets by money-proximity and flag the ones leaking time.

See `bets/README.md` for the full convention.

---

## Five modes

- `/co-bet new` — open a bet with hypothesis, appetite, metric, target, deadline
- `/co-bet update [slug]` — append progress, link new evidence
- `/co-bet close [slug]` — record result, verdict, learning, follow-up links
- `/co-bet list` — summarize active bets, deadlines, blockers
- `/co-bet narrate [slug]` — draft public-safe copy from the bet for site/social

**Never publish automatically.** Narration drafts are files only.

---

## Repo rules

Work from inside the vault (folder containing `core/`, `decisions/`,
`research/`, `bets/`). Before writing, read source of truth:

```bash
mb status --json --peek
```

After writing or editing bet files:

```bash
mb validate --cross-refs
```

If validation warns about missing reverse `linked_bets` links on related files,
fix them when clearly safe.

---

## Bet frontmatter (canonical schema)

Every bet lives at `bets/YYYY-MM-DD-slug.md`:

```yaml
---
status: open                          # open | paused | closed | canceled
opened: YYYY-MM-DD
closed:                               # null while open; YYYY-MM-DD at close
deadline: YYYY-MM-DD                  # when verdict gets measured
appetite: "2 weeks"
hypothesis: "If we do X for Y, Z will happen because..."
metric: "qualified calls booked"
target: "10 qualified calls by deadline"
kill_rubric: "Stop early if no calls booked by day 7, or cost exceeds $500."
owner: ""                             # single accountable person for this bet
money_path: ""                        # which money object this bet moves (offer | proof | ladder | cta | channel | push | feedback) — see /co-money-path
result: ""
linked_decisions: []
linked_research: []
linked_campaigns: []
linked_outcomes: []
public: false
channels: []
tags: []
---
```

**`kill_rubric` is required.** A bet without an exit condition runs past the point
of learning — `list` flags it as `unanchored`. **`money_path`** ties the bet to the
revenue object it's testing so `/co-money-path` can rank it by money-proximity
(`unanchored` = no exit, `over_cap` = past deadline/budget).

When linking an existing file to a bet, add reverse link to that file:
```yaml
linked_bets:
  - bets/YYYY-MM-DD-slug.md
```

---

## Mode: new

**Triggers:** "try X", "launch a test", "make a bet", "prove this works",
"pilot Y for Z weeks"

**Flow:**

1. Ask only for missing essentials:
   - **Hypothesis** — "If we do X for Y, Z will happen because..."
   - **Appetite** — "2 weeks" / "$500 ad spend" / "5 sessions"
   - **Deadline** — concrete date
   - **Metric** — what success looks like
   - **Target** — concrete number / threshold
   - **Kill rubric** — the condition that ends the bet early (required; no exit = wish, not bet)
   - **Owner** — single accountable person
   - **Money path** — which money object this moves (offer / proof / ladder / cta / channel / push / feedback)
   - **Public/private** — share results publicly?
   - **Channels** — email, ads, social, site, community
   - **Linked files** — research, decisions, campaigns that informed this

2. Create `bets/YYYY-MM-DD-slug.md` (use `bets/_template.md` if present).

3. Add reverse `linked_bets` to linked decisions/research/campaigns when safe.

4. End with: **file path, deadline, target, next action**.

---

## Mode: update

**Triggers:** "progress on the bet", "evidence from X", "we ran a session"

**Flow:**

1. Read the bet and any newly relevant linked files.
2. Append a dated `Evidence Log` entry:
   ```markdown
   - 2026-05-20 - Sent first batch of emails; 3 opens so far.
   ```
3. Update `linked_*` fields if new files matter.
4. Keep `result` blank until there's a real result.
5. Repair reverse `linked_bets` on newly linked files.

---

## Mode: close

**Triggers:** "close the bet", "deadline hit", "this is over", "canceling"

**Flow:**

1. Ask for actual result if repo evidence is not enough.
2. Set `status: closed` (target met or measured) or `status: canceled` (stopped
   without verdict).
3. Set `closed: YYYY-MM-DD`.
4. Fill `result` with measured outcome + verdict:
   ```yaml
   result: "9 qualified calls booked by deadline. Short by 1, but highest
     conversion rate yet (3.2%). Hypothesis confirmed: guarantee increases trust."
   ```
5. Add or update `## Learning` section in body.
6. Link outcome files, add reverse `linked_bets`.
7. **Name the graduation path** (don't take it — name it). A closed bet either
   dies with a learning or graduates into one durable artifact:
   - **offer** — the test worked, fold it into `core/offer.md`
   - **decision** — commit to it via `/co-think decide`
   - **content pillar / angle** — `core/proof/angles/`
   - **workflow / campaign** — a repeatable play
   - **nothing** — closed with learning, no further commitment

   State which one and the exact next command. **Never auto-graduate** — graduation
   requires explicit operator confirmation, same rule as `decisions: codified`.

---

## Mode: list

Summarize active bets from `mb status --json --peek` and direct reads:

- **deadline** (highlight overdue → `over_cap`)
- **status**
- **target / metric**
- **kill rubric** — flag any bet missing one as `unanchored` and promote it; a bet with no exit can't end on time
- **money path** — which object each bet moves (groups with `/co-money-path`)
- **public/private** posture
- **blocked / overdue signals**

Promote `unanchored` and `over_cap` bets to the top — they're the ones leaking
time. Keep it short. End with: *"Next bet that needs attention: [path]."*

---

## Mode: narrate

**Triggers:** "draft public copy", "what should we share?", "write a post about X bet"

**Flow:**

1. Ask which surface (if unclear):
   1. site
   2. community
   3. social
2. **If `public: false`, ask before drafting.** Offer private retro instead.
3. Draft using this format:
   ```markdown
   # Narration Draft

   Surface: [site/community/social]
   Source bet: bets/YYYY-MM-DD-slug.md

   ## Public Angle
   [What can be shared safely.]

   ## Draft
   [Post or page copy.]

   ## Claims To Verify
   - [Any metric/result/proof needing source confirmation.]

   ## Source Links
   - [repo-relative paths read]
   ```

**Never invent results, metrics, claims, testimonials, or publishing channels.**

---

## Exit

After any mode, tell the operator:
- What changed (files touched)
- What got linked (reverse links added)
- Whether validation passed
- Exact next command (often `mb status` or `/co-end`)

---

## Anti-patterns

- ❌ Bet without a deadline → wish, not bet
- ❌ Bet without a metric → can't verdict, only vibe
- ❌ Bet without a `kill_rubric` → no exit, runs past the point of learning (`unanchored`)
- ❌ Bet with no `money_path` → can't be ranked by money-proximity; `/co-money-path` can't see it
- ❌ Closing silently → write `## Learning`
- ❌ Auto-graduating to decision → requires explicit confirmation
- ❌ Public narration from `public: false` bet → ask first
- ❌ Narration claims not in repo truth → invention
