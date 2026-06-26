---
name: co-think
description: "Combined research, decision, and codification loop. Enriches the core — pulls insights from the world into .codify/ reference files. Use when: (1) Exploring a question before committing (2) Documenting a decision that needs rationale (3) Architect says research, decide, figure out, explore, codify, enrich, sharpen the offer, add context, mine this video, analyze this transcript (4) Updating .codify/ files based on a decision (5) Adding testimonials, angles, proof, objections, or mechanisms (6) Architect needs to build the substrate before another skill generates output (7) Cross-referencing the client's context against market signals to surface opportunities competitors can't see because they don't share the context. Supports three modes: full flow (default), research-only, decide-only, codify-only."
---

# /co-think — Research, Decide, Codify

The loop that turns the world into substrate. Every other Codify skill reads `.codify/*.md`; this skill is how those files get smarter.

**Reference files are gravity. Agents are velocity.** This skill is the only loop that compounds. Don't let agentic enthusiasm bury the substrate.

---

## Two Modes of Work

| Mode | You're doing | Skills |
|------|--------------|--------|
| **Enriching the core** | World → `.codify/` reference files | `/co-think`, `/co-extract`, `/co-import` |
| **Creating for the world** | `.codify/` → outputs | `/co-ad`, `/co-email`, `/co-content`, `/co-site`, `/co-proposal` |

`/co-think` is for enriching the core. When ready to create, route to a generation skill.

---

## Re-Invoke Often

Say `/co-think` again after compaction, context loss, or switching focus. It reloads skill context. Especially after reading a large transcript (burns tokens) or spawning research subagents.

---

## Before You Start

Read in order:

1. `.codify/soul.md`
2. `.codify/audience.md`
3. `.codify/offer.md`
4. `.codify/voice.md`

Scan recent `decisions/` and `research/` so you don't duplicate work.

---

## Route by Intent

Detect mode from the architect's natural language:

| Architect Says | Mode |
|---|---|
| "figure out", "explore", "I'm trying to…" | **Full Flow** (research → decide → codify) |
| "research", "investigate", "what do we know about", "mine this", "analyze this video/transcript" | **Research only** |
| "decide", "we chose", "document this decision" | **Decide only** |
| "codify", "apply", "update reference files", "add context", "enrich" | **Codify only** |
| "where was I", "continue", "pick up" | **Recovery** |

If unclear, ask: "Exploring a question, documenting a decision, or updating reference files?"

---

## Full Flow

```
Research → Synthesize → Decide → Codify
```

### 1. Define the Question

> "What specifically are you trying to figure out?"

One sentence. Sharp question beats vague topic.

### 2. Research

Gather from: codebase (vault grep), web search, user input, local transcripts, mined content.

**When research needs 2+ sources, spawn parallel subagents in a single message.** One per source. Each:

- Gets a focused prompt (one source, one question)
- Writes its own dated file (`research/YYYY-MM-DD-topic-[source].md`)
- **Verifies the write** (checks file exists after writing)
- Returns: file path + write status + 5-bullet summary
- If write failed, returns full content so main conversation can write it

After agents return: check files landed. Synthesize across summaries. This keeps heavy content out of main context.

**Do NOT background research subagents** — they cannot access MCP tools or prompt for permissions.

**Mining sources (suffix conventions):**

| Source | Output suffix |
|---|---|
| Codebase exploration | `-claude-code.md` |
| Web search | `-web.md` |
| YouTube transcripts | `-yt-mining.md` |
| X/Twitter sentiment | `-x-social.md` |
| Local audio/video | `-local-mining.md` |
| Competitor sites | `-competitor-mining.md` |
| Pasted documents/emails | `-internal-mining.md` |
| Deep research (Gemini/GPT) | `-gemini.md` or `-gpt.md` |

### 3. Synthesize (Required)

Every research file ends with:

- One-sentence summary (20 words max)
- Key findings (5-10 bullets, in the audience's own words where possible)
- Implications for `.codify/` files (which file, what change)
- Open questions

**AI shows what was said. You judge what it means.** Mining surfaces patterns; framework extraction is human work. Don't skip to generation. Mining → human synthesis → reference update → THEN create.

### 4. Checkpoint

> "Ready to make a decision, or need more research?"

### 5. Decide

Present 2-3 options with pros/cons. Document the choice and rationale in `decisions/YYYY-MM-DD-topic-slug.md`:

```yaml
---
type: decision
slug: [topic]
status: proposed
date: [today]
last-updated: [today's date and time]
linked_research:
  - research/YYYY-MM-DD-topic-[source].md
---

## Context
[Why this came up. What was true before.]

## Options Considered
- A: [option] — pros / cons
- B: [option] — pros / cons
- C: [option] — pros / cons

## Decision
[The chosen option.]

## Why
[Real reasoning. Not marketing language.]

## What Changes
[Which `.codify/*.md` files need updates, what specifically.]
```

Status lifecycle: `proposed` → `accepted` → `codified`.

### 6. Checkpoint

> "Ready to codify into `.codify/` now, or save for later?"

### 7. Codify

Apply the changes described in `## What Changes` to the relevant `.codify/` files. Update `last-updated` on each. Flip the decision status to `codified`.

If the change is substantial (new section, new mechanism, new audience segment), route to `/co-extract` to deepen the file through follow-up questions. Don't ship a thin update.

---

## Research-Only Mode

Skip decide + codify. Useful when the architect is mining and wants to come back later.

Output: `research/YYYY-MM-DD-topic-[source].md` with the synthesis section filled in.

---

## Decide-Only Mode

Skip the research phase — the architect already has the data and wants to lock the decision.

Output: `decisions/YYYY-MM-DD-topic-slug.md` per the template above.

---

## Codify-Only Mode

Apply a previously-accepted decision to `.codify/` files. Or process a new piece of information ("add this testimonial to proof," "this objection is missing from audience.md").

If applying a decision file, read its `## What Changes` section and execute.

If processing new information, ask:
- Which `.codify/` file does this belong in?
- New section, new bullet under existing section, or replacement?

Update `last-updated` on every modified file. If a decision file drove the change, flip its status to `codified`.

---

## Active Guidance

On every `/co-think` invocation, scan state and guide the next step:

```bash
ls -lt research/*.md 2>/dev/null | head -3
grep -l "status: proposed\|status: accepted" decisions/*.md 2>/dev/null
```

| If you find… | Then… |
|---|---|
| Recent research, no decision | "You have research on [topic]. Ready to decide?" |
| Proposed decision | "Decision [topic] is proposed. Ready to accept?" |
| Accepted decision, not codified | "Decision [topic] is accepted. Ready to codify into `.codify/`?" |
| Nothing in progress | "What are you trying to figure out?" |

**The goal is reference files.** Research and decisions are waypoints. Keep asking: "What needs to happen to get this into `.codify/`?"

---

## Recovery

If conversation compacted:

```bash
ls -lt research/*.md 2>/dev/null | head -5
grep -l "status: proposed\|status: accepted" decisions/*.md 2>/dev/null | head -5
```

Then: "I see you were working on [topic]. Continue from here?"

---

## When NOT to Use

- Quick factual questions (just answer)
- Simple file edits (just edit)
- Generating outputs (use `/co-ad`, `/co-email`, `/co-content`, `/co-site`)

Use `/co-think` when the answer needs investigation and the choice needs documentation.

---

## Why This Matters

The vault is a precision instrument. The think cycle exists to filter — not to cram everything in. Research gets synthesized; decisions get distilled; only the sharpest insights survive into `.codify/`. **Curation over collection.**

Every `.codify/` update is a curation decision that makes every downstream output better. Research and decisions go stale. Reference files compound.

---

## Tone

Match `voice.md`. Lead with the point. No throat-clearing.
