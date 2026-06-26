#!/usr/bin/env bash
# Codify skills — install / update (global). Clone-or-pull model.
#
# Clones this bundle into ~/.claude/skills/codify so every /co-* command is
# available in every Claude Code session and the Conductor skills dropdown.
# Re-run any time to update — it pulls if already installed.
#
# One command (install OR update):
#   gh api -H "Accept: application/vnd.github.raw" \
#     repos/mike-scott-darwin/codify-skills/contents/install.sh | bash

set -euo pipefail

REPO="${CODIFY_SKILLS_REPO:-mike-scott-darwin/codify-skills}"
BRANCH="${CODIFY_SKILLS_BRANCH:-main}"
DEST="${CODIFY_SKILLS_DEST:-$HOME/.claude/skills/codify}"

say() { printf '   %s\n' "$*"; }
die() { printf '\n❌ %s\n\n' "$*" >&2; exit 1; }

printf '\n📦 Codify skills\n\n'

command -v git >/dev/null 2>&1 || die "git not found — run: xcode-select --install"
command -v gh  >/dev/null 2>&1 && gh auth setup-git >/dev/null 2>&1 || true

URL="https://github.com/${REPO}.git"
if [ -d "$DEST/.git" ]; then
  say "Updating → $DEST"
  git -C "$DEST" fetch --depth 1 origin "$BRANCH" -q
  git -C "$DEST" reset --hard "origin/$BRANCH" -q
else
  say "Installing → $DEST"
  mkdir -p "$(dirname "$DEST")"
  rm -rf "$DEST"
  git clone --depth 1 --branch "$BRANCH" "$URL" "$DEST" -q \
    || die "Clone failed. Accept the repo invite first: https://github.com/${REPO}/invitations"
fi

[ -f "$DEST/co-start/SKILL.md" ] || die "Installed but co-start missing — wrong repo/branch?"
N="$(ls -d "$DEST"/co-* 2>/dev/null | wc -l | tr -d ' ')"

# Point vault /co-update at this reachable bundle (default upstream is private).
PROFILE="${CODIFY_SHELL_PROFILE:-$HOME/.zshrc}"
MARK="# >>> codify skills upstream (managed by install.sh) >>>"
if ! grep -qF "$MARK" "$PROFILE" 2>/dev/null; then
  {
    printf '\n%s\n' "$MARK"
    printf 'export CODIFY_SKILLS_UPSTREAM_REPO=https://github.com/%s.git\n' "$REPO"
    printf 'export CODIFY_SKILLS_UPSTREAM_PATH=.\n'
    printf 'export CODIFY_SKILLS_UPSTREAM_BRANCH=%s\n' "$BRANCH"
    printf '# <<< codify skills upstream <<<\n'
  } >> "$PROFILE" && say "Pinned /co-update upstream → $PROFILE"
fi

printf '\n✅ %s /co-* skills installed globally → %s\n\n' "$N" "$DEST"

HAS_CLAUDE=0;    command -v claude >/dev/null 2>&1 && HAS_CLAUDE=1
HAS_CONDUCTOR=0; [ -d "/Applications/Conductor.app" ] && HAS_CONDUCTOR=1
if [ "$HAS_CONDUCTOR" = 1 ]; then
  printf '🟢 Conductor detected → quit it (⌘Q) and reopen; /co-* are in the dropdown.\n'
fi
if [ "$HAS_CLAUDE" = 1 ]; then
  printf '🟢 Claude Code CLI detected → start a new `claude` session, type /co-start.\n'
fi
if [ "$HAS_CONDUCTOR" = 0 ] && [ "$HAS_CLAUDE" = 0 ]; then
  printf '⚠️  No agent found yet. Skills ARE installed — they activate once you install:\n'
  printf '     • Conductor    https://conductor.build\n'
  printf '     • Claude Code  npm install -g @anthropic-ai/claude-code\n'
fi
printf '\nUpdate any time: re-run this command, or `cd %s && git pull`.\n\n' "$DEST"
