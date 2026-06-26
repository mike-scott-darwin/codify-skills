---
name: co-update
description: "Architect-only skill. Pull the latest Codify skills and system files. Run during Brain Sync sessions, not by the client."
---

# /co-update — System Update (Architect Only)

This skill is for the **architect** to run during Brain Sync sessions. The client should never run this directly — they'll see technical output that doesn't make sense to them.

> **This is now the *only* way skills update.** As of the 2026-06-20 reversal (see `decisions/2026-06-13-engine-plugin-operator-mechanism.md`), the `/co-*` skills live **inside** each vault — there is no plugin to bump. `/co-update` re-syncs the vault's `.claude/skills/` from the upstream skills template. The `upstream` remote below must point at a repo that carries `.claude/skills/` (the canonical skills template), not the retired `codify-skills` plugin mirror.

## When to Run

- During monthly Brain Sync calls
- After releasing new skills or dashboard updates
- Before onboarding a client on a new tier

## Procedure

### 1. Resolve the upstream skills source

The canonical `/co-*` skills live in the business repo's template
(`codify-vault-template/.claude/skills/`). Defaults point there; a self-hosting
partner overrides them with env vars. Run **inside the vault**.

```bash
UPSTREAM_REPO="${CODIFY_SKILLS_UPSTREAM_REPO:-https://github.com/mike-scott-darwin/codify.git}"
UPSTREAM_PATH="${CODIFY_SKILLS_UPSTREAM_PATH:-codify-vault-template/.claude/skills}"
UPSTREAM_BRANCH="${CODIFY_SKILLS_UPSTREAM_BRANCH:-main}"
VAULT="$(git rev-parse --show-toplevel)"
```

### 2. Pull the latest skills (sparse + blobless — light, no full clone)

```bash
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
git clone --depth 1 --filter=blob:none --sparse --branch "$UPSTREAM_BRANCH" "$UPSTREAM_REPO" "$TMP" -q
git -C "$TMP" sparse-checkout set "$UPSTREAM_PATH" -q
SRC="$TMP/$UPSTREAM_PATH"
[ -d "$SRC" ] || { echo "Upstream skills not found at $UPSTREAM_PATH — check CODIFY_SKILLS_UPSTREAM_*."; exit 1; }
```

### 3. Mirror `co-*` skills into the vault

Only `co-*` skills are synced. **New skills appear, edited skills update, skills
removed upstream are pruned** — and operator-added non-`co-*` skills (e.g.
`ui-ux-pro-max`) are left untouched (rsync protects excluded files from `--delete`).

```bash
DEST="$VAULT/.claude/skills"; mkdir -p "$DEST"
rsync -a --delete --include='/co-*/' --include='/co-*/**' --exclude='*' "$SRC/" "$DEST/"
```

### 4. Commit and push the vault

```bash
git -C "$VAULT" add .claude/skills
if git -C "$VAULT" diff --cached --quiet; then
  echo "Already on the latest skills."
else
  git -C "$VAULT" commit -q -m "[update] sync /co-* skills from upstream — $(date +%F)"
  git -C "$VAULT" push -q origin HEAD || echo "Committed locally; push failed — check the vault's origin / auth."
fi
```

### 5. Report

Say: "Skills updated — newest `/co-*` commands are live in this vault." If nothing
changed: "Already on the latest skills." To update **every** vault at once instead
of one, the architect runs `scripts/push-skills-to-vaults.sh --push` (see that
script and `decisions/2026-06-20-skills-upstream-sync.md`).

## What Gets Updated vs. What's Protected

This skill touches **only `co-*` skills** — nothing else in the vault.

| Updated (synced from upstream) | Protected (never touched) |
|------------------------|------------------------|
| `.claude/skills/co-*` (added / edited / pruned) | `.codify/` core files (`soul`/`voice`/`audience`/`offer`), `agents/` |
| | `core/`, `decisions/`, `research/`, `campaigns/`, `log/`, `operator-queue/` |
| | non-`co-*` skills the operator added (e.g. `ui-ux-pro-max`) |

> System files like `CLAUDE.md` are intentionally **not** auto-synced here — they
> carry per-client personalization. Update them deliberately if a convention changes.

## Error Handling

| Situation | Action |
|-----------|--------|
| No internet / clone fails | Say "Can't reach the skills source right now — we'll try next session." Nothing in the vault changes. |
| `Upstream skills not found at …` | The `CODIFY_SKILLS_UPSTREAM_*` env vars point somewhere without `.claude/skills/`. Confirm the repo + path. |
| Auth error cloning a private upstream | The machine's `gh`/git must have read on the upstream repo (`gh auth status`). |
| Push fails after commit | The vault's `origin` or auth is the issue — the sync is committed locally; fix origin and `git push`. |
