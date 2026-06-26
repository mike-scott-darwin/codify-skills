---
name: co-setup
description: "Personalize a new client's vault and start their first extraction. Conversational — the client just answers questions."
---

# /co-setup — Personalize Your Context Architecture

**Architect-run.** The client doesn't open the vault themselves — the architect operates it on their behalf. This is the **one onboarding command** for a new managed-service client: it scaffolds the client's self-contained vault (the `/co-*` skills + their content), creates their private GitHub repo, personalizes everything for their business, and kicks off the first Context Extraction session — all in a single run. No separate script or `codify init` step is required.

**Skills + content, in one self-contained vault (read this first).** As of the 2026-06-20 reversal (see `decisions/2026-06-13-engine-plugin-operator-mechanism.md`), the `co-*` skills ship **inside each vault**, not as a separately-installed plugin. A vault holds both: the `/co-*` skills (`.claude/skills/co-*`, committed) **and** the content — `.codify/` reference files plus `core/`, `decisions/`, `research/`, `campaigns/`, `log/`, `operator-queue/`. Open the folder in Claude Code and the `/co-*` commands are right there. This skill copies the skills in, scaffolds the content, and stands the vault up on GitHub. (No `/plugin install`; if a machine shows duplicate `codify:co-*` skills from an old plugin, run `/plugin uninstall codify`.)

## Procedure

### 1. Welcome and Gather Info

Say:
"Welcome to Codify. I'm going to set up your Context Architecture — a secure vault for your expertise that compounds over time. The more you put in, the sharper everything that comes out. I just need a couple of things to get started."

Ask these one at a time:

1. **"What's your business name?"**
   → Store for personalizing files

2. **"What's your name?"**
   → Store for personalizing files

### 2. Stand Up the Vault on GitHub

**Ownership model (read first).** By default the vault lives in **the client's own
GitHub org**, not the operator's account — sovereignty has to be literally true,
not marketing. The client creates their free account + business org and invites
the operator as Owner during onboarding (the ~5-minute kickoff step in
`outputs/2026-06-15-client-github-setup.md`); the operator then runs this skill
with `CODIFY_GITHUB_ORG=<client-org>` so the repo is born in the client's house.
Concierge fallback only (a client who won't create an account): leave
`CODIFY_GITHUB_ORG` empty and set `CODIFY_CLIENT_GITHUB_USER` to invite the client
as admin on a repo in the operator's account, with a written commitment to
transfer on request. See `decisions/2026-06-15-client-owns-the-github-namespace.md`.

Do this silently — the client never *operates* git. The single exception is that
one-time account + org creation at onboarding, which the operator walks them
through live; after it, the client never touches GitHub again.

1. **Scaffold the self-contained vault (skills + content).** Create the client's vault folder under `$CODIFY_CLIENTS_DIR` (default `~/conductor/workspaces/codify-clients`), then create the canonical **content** folders inside it: `.codify/` (with `soul.md`, `voice.md`, `audience.md`, `offer.md`), `core/`, `decisions/`, `research/`, `campaigns/`, `log/`, `operator-queue/`, and the memory layer `memory/` + `memory/local/`. **Copy the `/co-*` skills into the vault** — the skills ship *inside* each vault now (no plugin; see the 2026-06-20 reversal in `decisions/2026-06-13-engine-plugin-operator-mechanism.md`), so `cp -R` `.claude/skills/` from the template into the new vault. Seed the four core files from the template (`$CODIFY_TEMPLATE_DIR/.codify/` if present, otherwise write empty drafts with `status: draft`). The `.gitignore` keeps the fast working-memory tier local (see `decisions/2026-06-14-local-working-memory-apart-from-github.md`) but **does not** exclude `.claude/` — the skills must be committed so the vault is self-contained:
   ```bash
   SLUG=$(echo "$BUSINESS_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd 'a-z0-9-')
   VAULT="${CODIFY_CLIENTS_DIR:-$HOME/conductor/workspaces/codify-clients}/$SLUG"
   TEMPLATE="${CODIFY_TEMPLATE_DIR:-$HOME/conductor/workspaces/codify/cambridge-v1/codify-vault-template}"
   mkdir -p "$VAULT"/{.codify,core,decisions,research,campaigns,log,operator-queue,memory/local}
   cp -R "$TEMPLATE/.claude" "$VAULT/.claude"          # the /co-* skills ride inside the vault
   printf '.trash/\n.DS_Store\nmemory/local/\n' > "$VAULT/.gitignore"
   ```
   The vault must be whole (all content folders + four core files + `.claude/skills/co-*` present) before it goes to GitHub. **Prefer `scripts/new-client-vault.sh` when available** — it is the canonical one-command scaffold and already copies the skills; this inline path is the fallback when the script isn't reachable.

2. **Seed the memory layer.** The two-tier memory layer gives the operating agents fast working memory apart from per-write commits. Seed three files (from `${CLAUDE_PLUGIN_ROOT}/templates/memory/` if present, otherwise write the canonical content matching this workspace's `memory/CONTEXT-RULES.md` and `memory/MEMORY.md`):
   - `memory/CONTEXT-RULES.md` — the trust order + write-routing note every surface reads before reading or writing memory (the "clean desk").
   - `memory/MEMORY.md` — the durable-fact index (starts empty under a "Durable facts" heading; one line per committed fact).
   - `memory/local/INBOX.md` — the gitignored fast-capture scratchpad (header + `<!-- new entries below -->` marker). This file is never committed; `/co-end`'s crystallize step promotes durable facts up into committed `memory/*.md`.

3. **Create the private GitHub repo and push** (skip the whole block if an `origin` remote already exists — the vault is already on GitHub). Run git **inside the client vault** (`$VAULT`), never in the engine folder:
   ```bash
   REPO="codify-vault-$SLUG"
   ORG_PREFIX="${CODIFY_GITHUB_ORG:+$CODIFY_GITHUB_ORG/}"   # empty = the authenticated gh account

   if ! git -C "$VAULT" remote get-url origin >/dev/null 2>&1; then
     git -C "$VAULT" init -q
     git -C "$VAULT" add -A
     git -C "$VAULT" commit -q -m "[add] initial vault for $BUSINESS_NAME"
     gh repo create "${ORG_PREFIX}${REPO}" --private --source="$VAULT" --push
   fi
   ```
   The repo is **private** — the client owns it. It is self-contained: the client's content **and** the `/co-*` skills (`.claude/skills/`) are committed here. If `gh` is not authenticated or repo creation fails, stop and tell the operator exactly what to fix (see Error Handling); do not pretend the vault is backed up when it isn't.

4. **Make ownership real (optional).** If `CODIFY_CLIENT_GITHUB_USER` is set, grant the client **admin** on their own repo so they can fork, export, and take the vault elsewhere — genuine ownership — while the operator keeps write access to run the managed service. Grant admin rather than transferring the repo: a full transfer strips operator access and breaks nightly runs.
   ```bash
   if [ -n "${CODIFY_CLIENT_GITHUB_USER:-}" ]; then
     REPO_FULL="$(gh repo view "${ORG_PREFIX}${REPO}" --json nameWithOwner -q .nameWithOwner)"
     gh api -X PUT "repos/$REPO_FULL/collaborators/$CODIFY_CLIENT_GITHUB_USER" -f permission=admin
   fi
   ```

### 3. Personalize the Vault

Do this silently — no need to narrate each step. Everything here operates **inside `$VAULT`** (the client vault), not the engine folder.

1. Copy the vault-conventions `CLAUDE.md` from the template (`$TEMPLATE/CLAUDE.md`) into `$VAULT/CLAUDE.md` and replace any placeholder references with the client's business name. (This is vault *config* — how any AI should behave in the folder.)
2. Write `$VAULT/README.md` — personalize with client name and business name.
3. Update the vault link in `README.md` — detect the `origin` remote URL and replace `GITHUB_USERNAME/VAULT_REPO_NAME` with the actual repo path. If no `origin` remote exists yet, leave the placeholder (architect sets it post-call).
4. Write the tier file:
   ```bash
   echo "codify" > "$VAULT/core/.tier"
   echo "0" > "$VAULT/core/.extractions"
   ```
5. **Wire GoHighLevel (if the client runs on GHL).** Capture the client's GHL sub-account so distribution targets the right Location. This is routing, not a secret — the agency `GHL_API_KEY` stays in `~/.codify/.env`.
   ```bash
   if [ -n "${CODIFY_GHL_LOCATION:-}" ]; then
     echo "$CODIFY_GHL_LOCATION" > "$VAULT/core/.ghl-location"
   fi
   ```
   If `CODIFY_GHL_LOCATION` isn't set, ask the operator: *"Does this client run on GoHighLevel? If so, paste their Location ID (or skip)."* Write it to `core/.ghl-location` when given. See `integrations/gohighlevel.md`.
6. Update frontmatter dates in Context files to today's date.

> **Skills ride inside the vault.** Step 1 copied `.claude/skills/co-*` into this folder, so the `/co-*` commands are available the moment it's opened in Claude Code — no plugin install. To refresh them later, the architect runs `/co-update`, which re-syncs the skills from the upstream template. (If a machine shows duplicate `codify:co-*` skills from an old plugin, run `/plugin uninstall codify`.)

Say: "Your vault is ready. Everything you see in the sidebar is yours — it's where your expertise will live and compound."

### 4. Quick Tour (30 seconds)

Say:
"Here's how you'll use this — there are only two things you ever touch:

- **A morning brief in WhatsApp** — daily push. Over coffee, you skim what ran overnight, tap to approve the work you want, and — some mornings — tap to pick a direction when there's a call only you can make. About a minute.
- **A voice note** — whenever something's off. *'Too long.' 'That's not how I'd say it.' 'Never lead with price.'* Each one teaches the system a rule it keeps, so the next batch comes back closer to you.

That's the whole interface: read, approve, correct. You also have a **read-only web view at codify.build/vault** to see your whole operation any time — what ran, what it produced, what it cost — but you never have to open it. And your **sovereign vault** is a private GitHub repository you own: every ad, email, decision, and research note lives there, portable to Claude, ChatGPT, Gemini — anything that reads markdown.

I operate everything else — the CLI, the skills, the agents — on your behalf. You direct; I run it."

### 5. Start First Extraction

Say: "Let's start capturing your expertise. I'm going to ask you some questions about your business — your beliefs, your audience, what you sell, and how you communicate. Just talk naturally. There are no wrong answers — I'm capturing your judgment, not testing it."

Then immediately run `/co-extract soul`.

## Tone

- **Respectful of their expertise.** This person has 30 years of domain knowledge. Don't talk down to them.
- **Confident.** "Your vault is ready" not "I'm going to try to set up..."
- **Efficient.** They're busy. Don't over-explain the architecture. They need to see their files, not understand the plumbing.
- **Legacy-minded.** Frame everything as protecting and scaling their expertise: "This captures your judgment so it compounds over time."
- **Zero jargon.** No "repo," "git," "commit," "push," "CLI," "API," "terminal," "MCP."

## Error Handling

| Situation | What to say |
|-----------|------------|
| Context files / folders missing | Recreate them silently from the template structure before the GitHub step, then continue. |
| `gh` not authenticated (to operator) | Don't fake success. Operator-facing: "GitHub isn't authenticated on this machine — run `gh auth login`, then re-run `/co-setup`. The vault is built locally; it just isn't backed up to GitHub yet." |
| Repo name already taken (to operator) | Operator-facing: "A repo named `codify-vault-<slug>` already exists. Either reuse it (add it as `origin`) or re-run with a different business slug / set `CODIFY_GITHUB_ORG`." |
| Client gets confused | "No worries. I'm handling the setup. You just answer the questions — that's where the value comes from." |
| Client asks about backups | "Everything backs up automatically to a secure vault that only you can access." |
| Client asks how it works | "Think of it as a reference library of your expertise. The AI reads it before creating anything, so everything it produces sounds like you, not a chatbot." |

## What the Client Walks Away With

After 15 minutes:
- Self-contained vault personalized with their business name (their content + the `/co-*` skills, committed)
- First Context file populated from the extraction conversation
- Sovereign private GitHub repo with automatic backup
- Every `/co-*` skill usable in the vault — they ride inside it, refreshed with `/co-update`
- First WhatsApp morning brief scheduled for the next day
