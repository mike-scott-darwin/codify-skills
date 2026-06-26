---
name: co-skill-shortener
description: "Architect-only. Weekly tuning loop on the vault's own skills — A/B test each skill with and without its current guidance, propose edits to keep skills lean and effective. Wraps Anthropic's skill-creator pattern."
---

# /co-skill-shortener — Skills That Stay Lean

Skills bloat. Every time you add a rule, an exception, or a "while you're at it" instruction, the skill gets longer. Long skills cost tokens, slow generation, and dilute the guidance that actually matters. This skill runs the inverse loop: it removes the guidance the skill no longer needs.

**Architect-only.** Run weekly during the Brain Sync cadence, or on-demand when a skill feels heavy. Not surfaced to the client. Outputs land in `decisions/` for human review before any skill file is changed.

## What it does

For each skill in `.claude/skills/`:

1. Picks 1–2 representative tasks the skill is normally invoked for (read from recent `operator-queue/` entries that called the skill).
2. Generates the output **with** the skill's current guidance loaded.
3. Generates the same output **without** the skill (model relies on the four core files only).
4. Has the model compare the two outputs and identify:
   - Lines in the skill that demonstrably changed the output for the better (**keep**).
   - Lines that produced no observable difference (**candidate to drop**).
   - Lines that made the output worse or constrained it unnecessarily (**drop**).
5. Writes a proposal to `decisions/[YYYY-MM-DD]-skill-shortener-[skill-name].md` with the diff and reasoning.

**The skill never edits another skill directly.** It writes a decision file. The human approves; the architect applies.

## Wraps Anthropic's `skill-creator`

The mechanic is the same loop Anthropic ships in their `skill-creator` skill. We don't reimplement it; we adapt the prompts and route the output to a decision file instead of overwriting in place.

Reference: https://github.com/anthropics/skills/tree/main/skills/skill-creator

If `skill-creator` is installed in the harness, this skill calls it with `--mode shorten --target <skill-path>` and post-processes the recommendations. If not, this skill runs the comparison inline using the model directly.

## Usage

```
/co-skill-shortener                      → Run on every skill in .claude/skills/, write one decision file per skill
/co-skill-shortener [skill-name]         → Run on a single skill
/co-skill-shortener --since [N]d         → Only re-evaluate skills used in the last N days (cheaper for large skill packs)
/co-skill-shortener --dry-run            → Run the comparison but skip writing decision files (useful for verification)
```

## Before running

Read these files first:

1. The target skill's `SKILL.md` — current state.
2. The four core files in `.codify/` — these define the model's baseline competence.
3. Recent `operator-queue/` entries for that skill — what tasks does it actually do?
4. `research/` files cross-referenced from the skill (if any) — what real-world data should the skill be informed by?

## Selecting representative tasks

For each skill, pull the **3 most recent operator-queue entries** where that skill was invoked. If fewer than 3 exist (skill is new or rarely used), fall back to the example invocations in the skill's own `## Usage` block.

Skip the comparison entirely if there are zero invocations in the last 30 days — log a note in the decision file recommending the skill be archived if the pattern continues.

## Output: decision file format

```markdown
---
type: decision
status: proposed
date: YYYY-MM-DD
skill_target: [skill-name]
proposed_by: skill-shortener
---

# Skill Shortener — [skill-name]

## Tasks evaluated
- [task 1, with operator-queue link]
- [task 2, with operator-queue link]
- [task 3, with operator-queue link]

## Lines to keep (load-bearing)
- Line N: "[exact line]" — output observably worse without it ([one-sentence why]).

## Lines to drop (no observable effect)
- Lines M–P: "[range]" — output identical with and without. Recommend remove.

## Lines to drop (made output worse)
- Line Q: "[exact line]" — over-constrained the output ([one-sentence why]).

## Net token change
- Before: [N tokens]
- After (proposed): [M tokens]
- Reduction: [%]

## Recommendation
[approve | approve with edits | reject]

## Architect approval
- [ ] Reviewed
- [ ] Applied diff to `.claude/skills/[skill-name]/SKILL.md`
- [ ] Marked decision `status: active`
```

## What this skill does NOT do

- **Does not edit any skill file directly.** All changes go through the decision file + human approval.
- **Does not delete skills.** It can recommend archival in the decision file body. Deletion is a separate architect call.
- **Does not modify the four core files** (soul, voice, audience, offer). Those have their own tuning loop via `/co-extract`.
- **Does not run on `skill-shortener` itself.** Reflexive recursion is out of scope. Manual review only.

## Cadence

Default: weekly, run during the Brain Sync prep window (Sunday evening or Monday morning). Skill is configured in the architect's agent definition (`.codify/agents/architect.md`) under the `schedule` field — not invoked by the client.

## Why this exists

Borrowed from Ryan Law (Director of Content, Ahrefs) — *"It's easy for skill files to become long and bloated… This process allows me to continually shorten skills to their most effective essence."* See `research/2026-05-02-knowledge-layer-deep-dive-positioning-validation.md` for the source pattern and the architectural rationale.

The four core files are the substrate; the skills are the leverage on top. If skills bloat, generation slows and gets noisier. The shortener keeps the leverage clean.
