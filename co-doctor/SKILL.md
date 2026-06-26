---
name: co-doctor
description: "Repair vault drift — regenerate stale runtime entrypoints (AGENTS.md from CLAUDE.md), rebuild .codify/ ↔ core/ symlinks, fix operator-queue index gaps. Plan-then-apply; never silent."
---

# /co-doctor — Vault Repair

Sibling to `/co-status`. Where `/co-status` reports drift, `/co-doctor` proposes and applies repairs. Mirrors MB's `mb doctor repair --plan` / `--apply` ergonomics: always show the plan first, never rewrite tracked files silently.

## Usage

```
/co-doctor                          → List available repairs and which ones the vault needs
/co-doctor --refresh-codex          → Regenerate AGENTS.md from CLAUDE.md (asks before applying)
/co-doctor --refresh-codex --plan   → Show the diff, do not apply
/co-doctor --refresh-codex --apply  → Apply without prompting (architect-only)
/co-doctor --rebuild-symlinks       → Rebuild .codify/ ↔ core/ symlinks
/co-doctor --reindex-queue          → Rebuild operator-queue/index.md from individual run files
```

## Repair Catalogue

### `--refresh-codex` — AGENTS.md from CLAUDE.md

**When to run:** `/co-status` reports `drift_vs_claude_md: true` (CLAUDE.md is more than 7 days newer than AGENTS.md), or after a meaningful CLAUDE.md edit.

**Procedure:**

1. Read current `CLAUDE.md` and current `AGENTS.md`.
2. Generate a fresh `AGENTS.md` body using the template structure below. Pull facts from `CLAUDE.md` where they overlap (vault structure, file conventions, folder routing, writing rules). Preserve the Codex-specific framing (experimental status, "what Codex is good for / not good for", drift check).
3. Diff against current `AGENTS.md`.
4. **If `--plan`:** print the unified diff. Stop.
5. **If `--apply`:** write the new `AGENTS.md`, update its `last-updated` to now, do not commit (the human commits).
6. **Default (no flag):** print the diff and ask "Apply? (y/N)". Apply on `y`.

**Template structure for regenerated AGENTS.md (do not deviate without a decision file):**

```
# AGENTS.md — Codex Entrypoint
[experimental-status callout]

## Canonical Context (Read First)
[four .codify/ core files + pointer to CLAUDE.md]

## What Codex Is Good For Here
[3-5 bullets — execution, edits, deterministic transforms]

## What Codex Should Not Do Here
[3-5 bullets — overnight loop, .codify/ edits, operator-queue mutation, voice invention]

## File Conventions
[frontmatter spec + last-updated rule + relative links + dated files]

## Folder Routing
[bullets: decisions/, research/, campaigns/, log/, operator-queue/]

## Writing Rules
[lead with point, bullets, "Why" sections, preserve client voice]

## Drift Check
[note that CLAUDE.md is the deeper source]
```

**Refusal cases:**

- Refuse if `CLAUDE.md` is missing — that's a substrate-level break, run `/co-audit` first.
- Refuse `--apply` if the user has uncommitted changes to `AGENTS.md` — show `git status AGENTS.md`, ask them to commit or stash first.

### `--rebuild-symlinks` — `.codify/` ↔ `core/`

**When to run:** `/co-status` reports `core_files_reachable: false`, or after cloning the vault on a system where symlinks were broken (Windows, some sync tools).

**Procedure:**

1. For each of `soul.md`, `voice.md`, `audience.md`, `offer.md`:
   - Confirm one canonical copy exists (prefer `core/` if both exist with diverged content — flag and refuse to proceed; the human resolves).
   - Replace the other path with a symlink to the canonical copy.
2. Print before/after `ls -la` for both directories.

**Refusal cases:**

- Refuse if `core/foo.md` and `.codify/foo.md` both exist as real files with diverged content. Surface a diff and stop.

### `--reindex-queue` — Rebuild `operator-queue/index.md`

**When to run:** the index file is stale (older than the most recent run file), or missing.

**Procedure:**

1. Walk `operator-queue/*.md`, skip the index itself.
2. Read frontmatter from each: `agent_id`, `started_at`, `goal_id`, `status`, `cost_usd`, `tokens_used`, `marks`.
3. Write `operator-queue/index.md` as a sortable markdown table grouped by month.
4. Append a generated-at timestamp footer.

**Refusal cases:**

- Refuse if any run file has malformed frontmatter — list the offenders and stop. The human fixes; we don't paper over bad data.

## Default Mode (no flag)

When run without arguments, `/co-doctor`:

1. Calls the same checks as `/co-status` internally.
2. For each detected drift, names the repair flag that would fix it.
3. Does not apply anything. Read-only triage.

Example output:

```
## Vault Doctor — [date]

3 repairs available:

  ⚠ Codex entrypoint drift
    AGENTS.md is 12 days older than CLAUDE.md.
    Fix: /co-doctor --refresh-codex

  ⚠ Operator queue index stale
    Index last regenerated 2026-04-22; 47 run files since.
    Fix: /co-doctor --reindex-queue

  ✓ Symlinks healthy

Run a specific flag, or /co-doctor --all to apply all safe repairs interactively.
```

## Why This Skill Exists Separate From `/co-status`

- `/co-status` is read-only and cheap to run frequently (pre-flight checks, dashboards, CI).
- `/co-doctor` mutates files and asks for confirmation. Different blast radius, different ergonomics.
- Mirrors MB's `mb status` / `mb doctor` split. Substrate conformance per
  [decisions/2026-05-03-codify-conforms-to-mb-substrate.md](../../../../decisions/2026-05-03-codify-conforms-to-mb-substrate.md).

## What This Skill Does Not Do

- Does not commit. The human commits, always. We surface the diff and write the file.
- Does not modify `.codify/*.md` core files. Those are enriched via `/co-extract`, never auto-repaired.
- Does not run in CI. Repair is a human-in-the-loop ritual.
