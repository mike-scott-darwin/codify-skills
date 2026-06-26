---
name: co-brief
description: "Morning brief — overnight research, vault health, open tasks, and recommended focus for the day."
---

# /co-brief — Morning Brief

Generates a daily executive summary from your vault. What changed overnight, what needs attention, and where to focus today.

## Usage

```
/co-brief              → Today's morning brief
/co-brief weekly       → Week-in-review summary
```

## The collector contract

Every data-source read below — Grok intel, vault health, money-path, tasks — follows
one shape: **date in → one structured result out, with an honest empty case.** A source
that can't answer returns `unavailable` and is reported as such; it never silently drops
to zero or fakes a value. A missing file, a stale glob, a failed sub-scan = one line that
says so, not a gap the reader mistakes for "all clear." If a source errors, the brief still
renders — the brief is never blocked by one bad collector.

The brief itself is **scorecard → anomalies → exactly one recommended action → short log.**
Surface what changed and what's off; then name the single move that matters most today.
Keep the whole brief tight (target under ~60 lines) — one decision, not a digest. If
everything is quiet, say so in a line; don't pad.

## Procedure

### 1. Scan Vault Activity

Check for changes since last brief:
- New files in `decisions/`, `research/`
- Modified Context files
- New outputs generated
- Recent git commits (via `git log --since="24 hours ago"`)

### 2. Scan Overnight Grok Intel (current-info-researcher + prospect-researcher)

Two specific paths the overnight Grok loop writes to. These are the
load-bearing artifacts — without surfacing them here, the work is invisible.

**Topic sweeps** (`current-info-researcher`):
- Glob `research/current/<today's-date>-*/synthesis.md`
- For each file, extract:
  - `topic_slug` (frontmatter)
  - `## TL;DR` body section (first 2-3 lines)
  - `recommended_action_confidence` (frontmatter)
  - `stale_by` (frontmatter — flag if within 3 days)
- Skip topics where `stage_status != complete`

**Per-prospect X intel** (`prospect-researcher` → `current-info-researcher`):
- Glob `campaigns/nightly/<today's-date>/*/x-intel.md`
- For each file where `post_count > 0`:
  - `prospect_name` (frontmatter)
  - First bullet under `## Intent signals`
  - `confidence` (frontmatter)
- Suppress entries with `stage_status: skipped` (no handle found) — these
  are not failures, just absences

**Overnight Grok spend:**
- Sum `cost_usd` from `operator-queue/<today's-date>-current-info-researcher-*.md`
  and `operator-queue/<today's-date>-prospect-researcher-*.md`
- Flag if total exceeds $10/night per client (likely a query went rogue)

**Enablement watch (self-clearing, at most one line):**
- If the Grok sweep cron is still disabled (`enabled: false` in the cron
  config / `tools.yaml` shows `grok: false`), surface ONE line: "Grok sweep
  OFF — enable once GROK_API_KEY + APIFY_TOKEN are set." Omit entirely once
  enabled. This is a nudge that disappears the moment the loop goes live —
  not a standing item.

### 3. Check Vault Health

Run a silent `/co-audit`:
- Context Power score
- Stale files count
- Orphaned notes count
- Biggest enrichment opportunity

### 4. Check Money-Readiness

Run a silent `/co-money-path --snapshot`. This grounds the brief in revenue, not
just vault hygiene — it names the one move closest to the next dollar. Capture the
bottleneck and the closest move. Report facts only; never judge whether something
will convert (see `/co-money-path`'s one rule).

### 5. Check Open Tasks

Scan for unchecked tasks across the vault:
```
- [ ] incomplete tasks in any markdown file
```

### 5b. Scan Open Decision Gates

A decision gate is a fork the overnight run hit but couldn't settle on its own —
which niche to attack next, which of two angles to lead with, widen vs. hold. The
run never pauses overnight to wait on a sleeping client; instead it pushes every
branch that doesn't need the client and writes the one that does as a **gate file**
for the morning. (Written by `/co-loop` Stage 4 — see that skill's gate convention.)

- Glob `decisions/gates/*.md` (every date, not just today) for files with
  frontmatter `type: gate` and `status: open` — an unanswered gate must carry
  forward until the client taps it, so a fork raised two nights ago still leads
  today's brief. Surface the oldest open gate first.
- For each open gate, extract: `question` (the fork, one line), `option_a`,
  `option_b`, `recommendation` (a/b + one-line why), and `blocks` (what branch is
  paused on this answer, if any).
- A gate is **pre-narrowed to a tap** — two options, a recommendation. It is never
  a free-text question to the client. If the autonomous run couldn't reduce a fork
  to two concrete options + a pick, that's a research gap, not a gate — route it to
  `/co-research`, don't surface a vague question.
- If no open gate files, omit the section entirely (don't print an empty "Decisions"
  block — unlike Grok intel, a quiet gate queue is the normal case).

### 5c. Read the Relationships (Who Needs You Today)

A brief that only optimizes the calendar and the pipeline numbers is a productivity
app. The leverage a managed exec has — that a solo operator doesn't — is people.
This read surfaces the **one relationship** most worth 90 seconds today, before it
goes cold or goes sideways.

**Default (every tier that runs the loop) — pipeline relationships.** Read from the
data the loop already has: the warm lead that's gone quiet relative to its own pattern,
the prospect owed a reply or a promised next step, the account drifting since last touch.
- Glob the active pipeline the loop writes (`campaigns/nightly/<recent-dates>/*/`,
  approved-but-unsent sequences, and CRM status synced back by `/co-ghl sync`).
- Score on the same signals Kline names, applied to revenue relationships:
  who **committed to something and owes an update**, who **went quiet relative to their
  normal pattern**, who's **carrying a stalled thread no one has checked**.
- Surface exactly **one** — name, the reason in one line, and the **specific 90-second
  move** (the message to send, the question to ask, the follow-up to pull forward).
  Draft the message; don't just name it.

**Optional team layer — Orchestrate only.** Read `core/.tier`; run this layer only if
tier is `orchestrate` **and** the operator has wired team sources (1:1 notes, team chat)
in their connection profile. When present, the same three signals apply to the client's
team: who owes a 1:1 commitment, who's gone quiet, who's carrying an unchecked load, who's out.

**Collector contract applies — never fake a person.** If the team sources aren't wired,
flag one line ("team-people layer off — no 1:1/chat source connected") and fall back to
the pipeline read. If there genuinely isn't enough signal to call one person, say what
you'd need to watch — don't invent a name or a concern. A flagged unknown beats a
confident guess.

### 6. Generate Brief

Format:

```markdown
# Morning Brief — [date]

## Overnight Activity
- [what changed since yesterday — files modified, commits]

## Overnight Grok Intel

### Topic sweeps ([N] topics)
- **[topic-slug]** ([confidence]): [TL;DR line] _(stale_by: [date])_
- ...

### Hot prospects ([M] with intent signals)
- **[Prospect Name]** ([confidence]): [first intent signal bullet]
- ...

### Spend
- Total overnight: $[X.XX] (current-info: $[X.XX] / prospect: $[X.XX])

## Decisions Waiting (one tap)
- **[the fork, one line]**
  - **A)** [option a] · **B)** [option b]
  - Recommend: **[A/B]** — [one-line why]
  - _(Holding: [branch paused on this answer], if any)_
- ...

## Closest to Revenue (MoneyPath)
- Bottleneck: [object] — [one-line fact]
- Closest move: [action] → [skill]

## Who Needs You Today
- **[Name]** — [why, one line: owes an update / gone quiet / stalled thread]
  - 90-second move: [the message to send / question to ask / follow-up to pull forward]
  - Draft: "[the actual message, ready to tap-send]"

## Vault Health
- Context Power: [score]
- Stale files: [count]
- Biggest gap: [specific suggestion]

## Open Tasks
- [ ] [task 1]
- [ ] [task 2]

## Recommended Focus
[1-2 sentence recommendation. Default to the MoneyPath bottleneck unless vault
health or overnight activity outranks it — if they disagree, name which wins.
If hot prospects surfaced overnight, prioritize those — the deliverable +
sequence are already drafted in their folders, you just need to approve.]

[Name ONE move, never a list — the single change to today with the most leverage
toward revenue (the meeting to decline so a block opens, the approval to make now,
the follow-up to pull forward). Then **draft the message that makes it happen**, so
the move is one tap, not a to-do. A move with no drafted message is a mirror; a move
with the message staged is a coach.]
```

If both Grok sections are empty (no topics swept, no prospects with intent
signals), say "No fresh Grok intel overnight" in a single line — don't omit
the section, so the reader knows the loop ran.

Omit **Decisions Waiting** entirely when no gate is open (see 5b) — most mornings
the brief is approve-only, and a phantom "no decisions" line would just add noise.
When a gate *is* open, it leads the action items: it's the one thing only the
client can unblock, so it sits above MoneyPath and Open Tasks.

Omit **Who Needs You Today** when there's no relationship worth surfacing — don't
print "no one needs you" (it reads false and trains the client to skip the section).
Surface it only when one person clears the bar: owes an update, gone quiet, or a
stalled thread. One person, never a roster — the read loses its edge the moment it
becomes a list.

### 7. Save + Deliver

Save to `log/[date]-brief.md` and display in chat.

**Delivery is operator-configured — read `~/.codify/operator.md` (`/co-connect`).**
The brief always saves to `log/[date]-brief.md` and displays in chat. Where *else* it goes depends on the operator's own connection profile:

- `delivery.channel: chat` (or no profile) → **display only.** This is the manual default — no server, no send.
- `delivery.channel: telegram | whatsapp | email` → also push to that channel's `delivery.target`, using the named secret from `~/.codify/.env`. When the overnight host (`always_on.mode: local|vps`) runs `/co-brief` on the `schedule.brief` cron, this is how it reaches the operator's phone before the day starts.

Never hardcode a channel, group, or bot here — the profile is the single source. If no profile exists, deliver to chat and move on.
