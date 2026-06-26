---
name: co-end
description: "Session-closing bookend. Scans today's vault activity, summarizes what happened, spawns a crystallize subagent for deep analysis, captures any final thoughts, and closes intentionally. Use when: architect says done, wrapping up, end my day, closing out, call it a day, goodnight, that's it for today, checkpoint, pause. Bookend to /co-start. Works for end-of-day, end-of-research-batch, end-of-decision-sprint, or mid-work checkpoints. Run by the architect, never auto-invoked."
---

# /co-end — Close the Session Intentionally

The bookend to `/co-start`. The end of a session is the highest-leverage reconnection point — accumulated doing becomes conscious understanding.

**Architect-only. Never auto-invoked.**

This is not just end-of-day. It closes any meaningful session:

- End of day — wrapping up
- End of a research batch — crystallize before deciding
- End of a decision sprint — see what the decisions mean together
- Mid-work checkpoint — pause deep work, crystallize, then continue

Not an audit. A thoughtful friend helping the architect close the session.

---

## The Flow

```
1. Scan today's vault activity
2. Decision lifecycle check
3. Session summary
4. Final thought capture (optional)
5. Crystallize (spawns subagent if meaningful activity)
6. Checkpoint and close
```

**Step 5 is not optional** if meaningful activity happened (decisions, research, `.codify/` changes). Do not attempt the crystallize analysis inline. Spawn the subagent.

A quick `/co-end` (architect says "just commit and close") can be 1-3 and 6.

---

## Step 1 — Scan Today's Activity

```bash
cd [vault]
git log --since="6am" --oneline 2>/dev/null
git status --short 2>/dev/null
ls -lt research/*.md 2>/dev/null | head -5
ls -lt decisions/*.md 2>/dev/null | head -5
git diff --name-only HEAD@{6am}..HEAD -- .codify/ 2>/dev/null
```

Categorize what you find:

| Category | Source |
|---|---|
| Research files created/updated | `research/` changes |
| Decisions made | `decisions/` changes (note `status:` of each) |
| `.codify/` files updated | `git diff -- .codify/` |
| Outputs generated | `campaigns/` changes |
| Operator-queue runs | `operator-queue/` changes |
| Unsaved work | `git status` dirty files |

**If nothing happened:** "Quiet day — no changes detected. Want to close out?" Skip to Step 6.

---

## Step 2 — Decision Lifecycle Check

Count decisions by status:

```bash
grep -l "status: proposed" decisions/*.md 2>/dev/null | wc -l
grep -l "status: accepted" decisions/*.md 2>/dev/null | wc -l
```

**Manual confirmation rule (non-negotiable):** Never auto-flip a decision to `codified` from evidence alone. If `status: accepted` decisions exist and the `.codify/` changes they describe were made today, offer to flip them — but require explicit per-file confirmation. If declined, leave statuses unchanged.

Surface: "You have 2 accepted decisions that look codified — want to flip their status?"

---

## Step 3 — Session Summary

Warm, brief reflection. Not a report.

> "Here's what happened today:
>
> - Researched [topic] (research file saved)
> - Decided [topic]
> - Updated `.codify/offer.md` — added [what changed]
> - Generated [N] outputs in campaigns/
>
> [1 sentence connecting the dots — what theme tied today's work together?]"

Guidelines:

- 3-6 bullets max. Summarize, don't list every file.
- Highlight `.codify/` updates — that's the most valuable work.
- If decisions were made but not codified, note it gently.
- The connecting sentence is observation, not judgment.

---

## Step 4 — Final Thought (Optional)

Ask once:

> "Any final thoughts before we close?"

**If brief:** acknowledge it; include it in the checkpoint message if relevant.

**If substantial (paragraph+):** offer to save as `research/YYYY-MM-DD-end-of-day.md`.

**If nothing:** move on. No friction.

After Step 4 — whether the architect engaged or not — **proceed to Step 5** if meaningful activity happened.

---

## Step 5 — Crystallize (SPAWN A SUBAGENT)

**You must spawn a dedicated subagent for this step.** Do not attempt the analysis inline. The main conversation has been burning tokens all session. The crystallize subagent gets a fresh context window, spends 50-100K tokens reading today's actual files, and returns one sharp question.

Without the subagent, you'll default to generic "what did you learn?" — the exact failure this architecture prevents.

### 5a. Check for Meaningful Activity

```bash
git log --since="6am" --name-only --diff-filter=AM -- decisions/ 2>/dev/null
git log --since="6am" --name-only --diff-filter=A -- research/ 2>/dev/null
git diff --name-only HEAD@{6am}..HEAD -- .codify/ 2>/dev/null
```

**Skip crystallize entirely when:**
- No decisions, research, or `.codify/` changes
- Context window critically low (under 30K remaining)
- Architect asked for a quick close ("just commit and close")

### 5b. Gather Content for the Subagent

Read and collect:

| Content | When |
|---|---|
| Today's git summary | Always |
| Today's decision files (full text) | Always |
| Today's research files (full text) | Always |
| `.codify/` diffs | If `.codify/` changed |
| `.codify/soul.md` | Always |
| `memory/local/INBOX.md` (working memory) | If it exists and has entries below the marker |
| Past crystallize outputs | If any exist (`research/*-end-of-day-crystallize.md`) |

**Heavy day adaptation:** If more than 5 research files exist for today, pass file names + commit messages for all, but full text only for the 3-5 most recent or most connected to today's decisions.

### 5c. Spawn the Crystallize Subagent

Use the Agent tool, `subagent_type: "general-purpose"`. Prompt structure:

> "You are the crystallize subagent for a Codify vault session. Read the attached content from today's work. Your job is to surface what the architect is doing but hasn't named — unnamed tensions, connections between tactical work and the why, gaps in `.codify/` that today's work exposes.
>
> Return exactly: 2-4 sentences of context, followed by 1-3 questions that make the architect stop and think. No summary, no praise, no next-steps. The question should feel like a thoughtful friend who's been watching all day.
>
> Anti-patterns to avoid: 'What did you learn?', 'What's next?', 'How do you feel?'. Those are generic. Find the actual tension.
>
> Content from today:
> [paste everything from 5b]"

**The subagent is read-only.** It returns findings. It does not write files.

### 5d. Present to the Architect

Show the crystallize output **exactly as the agent returned it.** No editing, summarizing, or commentary.

### 5e. Engagement Protocol

If the architect engages with the question, main conversation handles the dialogue (subagent's job is done).

Rules:

1. **Let them go deep.** Never redirect to "pick this up with /co-think later." If insight is happening at session's end, that's the highest-value moment. Stay with it.
2. **Listen and reflect.** Reflect in one sentence. Give space to refine.
3. **Name what they're doing.** "That sounds like a new entry for `.codify/soul.md`." "That's a decision waiting to be written."
4. **If insight updates reference, offer to do it.** Don't push — offer.
5. **Never push.** If they say one sentence and stop, let them stop. The question was planted.

### 5f. Always Save the Crystallize Output

**Not optional.** Every crystallize moment gets saved. Future crystallize subagents read these for pattern recognition.

Save to `research/YYYY-MM-DD-end-of-day-crystallize.md`:

```yaml
---
type: research
date: [today]
last-updated: [today's date and time]
source: crystallize
status: complete
---

# End-of-Day Crystallize

## Question Asked
[The crystallize question, verbatim]

## Architect Response
[What they said, or "No engagement" if skipped]

## Insight Captured
[Any insight that emerged, or empty]

## Reference Updated
[Which `.codify/` files were updated as a result, or "None"]
```

### 5g. Promote Working Memory (crystallize the INBOX)

If `memory/local/INBOX.md` exists and has entries below its `<!-- new entries below -->`
marker, this is where fast scratch becomes durable. `memory/local/` is gitignored working
memory — useful but untrusted — and crystallize is the only gate that turns it into a
committed fact. See `decisions/2026-06-14-local-working-memory-apart-from-github.md` and
`memory/CONTEXT-RULES.md`.

**Manual confirmation rule (non-negotiable):** Never auto-write or auto-clear memory.
Propose, then act per-fact on confirmation.

1. Read the INBOX entries. Identify which are **durable facts** (a stable truth about the
   user, a validated approach, an ongoing project, or a reference pointer) versus transient
   scratch (a one-off observation, a lead already acted on, noise).
2. For each durable fact, propose a committed memory file: `memory/<prefix>_<slug>.md`
   (`user_` / `feedback_` / `project_` / `reference_`), one fact per file, with frontmatter
   (`name`, `description`, `type`, `surfaces`, `created`, `last_verified`). Synthesize the
   **fact**, not the transcript — and for `feedback`/`project`, add **Why:** and
   **How to apply:** lines. Check for an existing file that already covers it; update rather
   than duplicate.
3. Show the proposed files to the architect. On confirmation: write each, add a one-line
   index entry to `memory/MEMORY.md`, and **remove the promoted entries from the INBOX**
   (leave the header, marker, and anything not promoted).
4. If nothing is durable: say so, leave the INBOX untouched. Scratch that never crystallizes
   is fine — it ages out locally and is never committed.

The committed memory files + `MEMORY.md` join the Step 6 checkpoint. The INBOX itself is
gitignored and never appears in git.

---

## Step 6 — Checkpoint and Close

If unsaved changes:

> "You have unsaved work:
> - [summarize from git status]
>
> Want me to save a checkpoint before we close?"

If yes:

```bash
cd [vault]
git add [specific files — not -A unless reviewed]
git commit -m "[update] [brief subject from today's work]"
git push origin main
```

Include the crystallize file in the checkpoint if one was created. Use beginner-safe language: "saved checkpoint," not "ran git commit."

If no: leave it. Some architects checkpoint at the start of next session.

### The Close

Warm, brief.

> "Good session. [1 sentence on the most important thing that happened today]. See you next time."

Examples:

> "Good session. Pricing is locked in and the offer is stronger for it. See you next time."

> "Solid work. `.codify/offer.md` is sharper now — everything downstream just got better."

> "Quiet day, but that research on [topic] will pay off when you decide."

**Do not:**
- List everything again (Step 3 was the summary)
- Suggest what to do tomorrow (that's `/co-start`'s job)
- Be performative
- Use emojis

---

## Edge Cases

**Nothing happened today:**
> "Nothing to close out — no changes detected. See you next time."

**Mid-task:**
> "You have work in progress — [describe]. Finish first, or close and pick up next time?"

**Context window nearly full:**
Keep ultra-brief. Skip Steps 4 and 5. Scan, checkpoint, close.

**No vault found:**
> "No vault found here. Run `/co-setup` next time to create one. See you next time."

---

## What /co-end Is NOT

- Not a daily standup. No plans for tomorrow.
- Not a task manager.
- Not a journal. Final thought capture is optional and brief.
- Not an audit. Summary is observational, not evaluative.
- Not `/co-think` — but if an insight is happening, stay with it.

---

## Tone

A thoughtful friend. Brief. Warm. Not performative. Match `.codify/voice.md`.

The close should feel like the end of a good conversation — not a report card, not a ceremony. Just: "Here's what happened. Anything else? Good. See you."
