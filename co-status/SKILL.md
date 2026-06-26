---
name: co-status
description: "Quick vault readiness check — runtime entrypoints, core files, drift between Claude Code and Codex configs, and whether the vault's in-vault /co-* skills are present (and no stray old plugin is duplicating them). Lightweight sibling to /co-audit."
---

# /co-status — Vault Readiness Check

Reports whether the vault is wired correctly for the runtimes it supports. Lighter than `/co-audit` (which scores depth, freshness, connections, completeness across every file). Use `/co-status` when you want a 10-second answer to "is this vault ready to run?"

## Usage

```
/co-status              → Human-readable summary
/co-status --json       → Machine-readable status block (for tooling)
```

## What to Check

### 1. Runtime Entrypoints

| File | Required | Used by |
|------|----------|---------|
| `CLAUDE.md` | yes | Claude Code (supported runtime) |
| `AGENTS.md` | yes | Codex CLI (experimental runtime) |
| `.codify/README.md` | yes | `@codify/cli` |

For each: confirm presence + read `last-updated` (frontmatter) or filesystem mtime if no frontmatter.

### 2. Canonical Context (`.codify/`)

Confirm all four core files exist and have non-template content:

- `.codify/soul.md`
- `.codify/voice.md`
- `.codify/audience.md`
- `.codify/offer.md`

A file counts as **template-only** if its body is just `<!-- -->` placeholder comments with no real content. Flag template-only files — generation skills will produce generic outputs against them.

### 3. Codex Readiness

**Substrate conformance:** when the `mb` CLI is installed (`command -v mb`), shell out to `mb status --json` and embed its `codex` block verbatim under `runtimes.codex` in our output. MB owns runtime entrypoint facts; we layer Codify-specific facts (`.codify/` core files, operator-queue) on top. See [decisions/2026-05-03-codify-conforms-to-mb-substrate.md](../../../../decisions/2026-05-03-codify-conforms-to-mb-substrate.md).

When `mb` is **not** installed, fall back to a minimal local check that mirrors MB's shape:

```yaml
codex_ready:
  agents_md_present: bool
  agents_md_last_modified: YYYY-MM-DD HH:MM
  claude_md_last_modified: YYYY-MM-DD HH:MM
  drift_vs_claude_md: bool          # true if CLAUDE.md is newer than AGENTS.md
  core_files_reachable: bool         # all four .codify/*.md exist and parse
  runtime_supported: "experimental"  # never claim "supported" for Codex
  notes: []                          # human-readable warnings
```

**Drift rule:** if `CLAUDE.md` mtime is more than 7 days newer than `AGENTS.md` mtime, set `drift_vs_claude_md: true` and add a note: "AGENTS.md may be stale — run `/co-doctor --refresh-codex` to regenerate from CLAUDE.md."

### 4. Operator Queue Health

Quick sanity check (full audit is `/co-audit`):

- Most recent `operator-queue/` entry — date and `agent_id`.
- Any entries in the last 24h with `status: failed` or missing `output_file`.
- Total run count this month vs. sum of agent `budget_tokens` consumed (read from agent frontmatter if cached).

### 5. Skills Currency (in-vault)

The `co-*` skills ship **inside this vault** (`.claude/skills/co-*`), not as an
installed plugin (2026-06-20 reversal — see
[decisions/2026-06-13-engine-plugin-operator-mechanism.md](../../../../decisions/2026-06-13-engine-plugin-operator-mechanism.md)).
So the check is: are the vault's skills present, and is a stray old plugin
duplicating them?

- **Present:** `.claude/skills/` exists with `co-*` skill folders. If missing →
  "Skills not found in this vault — re-scaffold or `cp` `.claude/skills/` from the
  template; the vault should be self-contained."
- **Duplicate plugin:** read `~/.claude/plugins/installed_plugins.json`; if a
  `codify@*` key is present, warn: "An old engine *plugin* is installed and
  duplicates this vault's skills (you'll see both `/co-*` and `codify:co-*`). Run
  `/plugin uninstall codify` and restart Claude Code — keep only the bare `/co-*`."
- **Freshness (optional):** `/co-update` re-syncs the vault's skills from the
  upstream template. Surfacing "skills last synced N days ago" is a nice-to-have,
  not a hard check.
- Read-only and best-effort: skip silently if the plugins file is unreadable;
  never block.

## Output — Human Mode

```
## Vault Status — [date]

Runtimes:
  ✓ Claude Code      (CLAUDE.md, last updated 2026-05-09)
  ⚠ Codex (experimental)  (AGENTS.md present, but CLAUDE.md is 12 days newer — possible drift)

Canonical context (.codify/):
  ✓ soul.md       active     last updated 2026-05-04
  ✓ voice.md      active     last updated 2026-05-04
  ⚠ audience.md   draft      template-only — run /co-extract audience
  ✓ offer.md      compounding last updated 2026-05-08

Operator queue:
  Last run: 2026-05-09  prospect-researcher  ✓
  Failures (24h): 0

Skills (in-vault):
  ✓ .claude/skills/ present (co-* skills committed in the vault)
  ⚠ old `codify` plugin also installed — run /plugin uninstall codify to drop duplicates

Next step: /plugin uninstall codify
```

## Output — JSON Mode

```json
{
  "generated_at": "2026-05-10T08:14:00Z",
  "runtimes": {
    "claude_code": { "entrypoint": "CLAUDE.md", "present": true, "last_modified": "2026-05-09T11:02:00Z", "supported": true },
    "codex": { "entrypoint": "AGENTS.md", "present": true, "last_modified": "2026-04-27T14:00:00Z", "supported": "experimental" }
  },
  "codex_ready": {
    "agents_md_present": true,
    "agents_md_last_modified": "2026-04-27T14:00:00Z",
    "claude_md_last_modified": "2026-05-09T11:02:00Z",
    "drift_vs_claude_md": true,
    "core_files_reachable": true,
    "runtime_supported": "experimental",
    "notes": ["AGENTS.md may be stale — CLAUDE.md is 12 days newer."]
  },
  "core_files": [
    { "name": "soul.md", "status": "active", "template_only": false, "last_updated": "2026-05-04" },
    { "name": "voice.md", "status": "active", "template_only": false, "last_updated": "2026-05-04" },
    { "name": "audience.md", "status": "draft", "template_only": true, "last_updated": "2026-04-15" },
    { "name": "offer.md", "status": "compounding", "template_only": false, "last_updated": "2026-05-08" }
  ],
  "operator_queue": {
    "last_run": { "date": "2026-05-09", "agent_id": "prospect-researcher", "status": "ok" },
    "failures_24h": 0
  },
  "skills": {
    "in_vault": true,
    "skills_dir_present": true,
    "stray_plugin_installed": true,
    "notes": ["co-* skills ship in the vault; a stray `codify` plugin is duplicating them — run /plugin uninstall codify."]
  },
  "next_step": "/plugin uninstall codify"
}
```

## Why This Skill Exists

- Operators need a fast pre-flight check before scheduling overnight runs.
- The Codex slice is experimental — drift between `AGENTS.md` and `CLAUDE.md` is the most likely failure mode and the cheapest to detect.
- Tooling (the web `codify.build/vault` workspace, future CI) consumes the JSON form. Human form is for the architect's terminal.

## What This Skill Does Not Do

- It does not score depth, freshness, connections, or completeness — that's `/co-audit`.
- It does not refresh `AGENTS.md`. That is `/co-doctor --refresh-codex` (plan-then-apply, mirrors `mb doctor repair`).
- It does not modify any files. Read-only.
