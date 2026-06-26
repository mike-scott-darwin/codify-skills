---
name: co-obsidian
description: |
  Turn the canonical vault into a read-only Obsidian view — graph, backlinks, and a navigable home note over the markdown that already exists. Internal operator tool (and a graduation handoff for the technical ~10%); NOT a client-facing surface. Use when:
  (1) An operator wants to browse a vault visually (graph view, backlinks, quick-switcher)
  (2) Setting up Obsidian over a vault for the first time (generates .obsidian/ config + HOME.md)
  (3) Regenerating the HOME map-of-content after the vault grows
  (4) Optionally converting path-links to [[wikilinks]] so the graph lights up fully

  Triggered by: /co-obsidian, "open this in Obsidian", "give me an Obsidian view", "obsidian read-only".
---

# /co-obsidian — Read-Only Obsidian View Over the Vault

The vault is already markdown. Obsidian opens any folder as a vault natively — so this skill doesn't *convert* anything. It makes the **interface** good: a tuned `.obsidian/` config, a `HOME.md` map-of-content to land on, and an opt-in wikilink pass so the graph and backlinks are rich.

**Edits still happen through the CLI/skills.** Obsidian here is a *viewer* over the canonical GitHub vault, not an editing surface.

## Scope — read this first

- **This is an internal / operator tool.** Per `decisions/2026-04-25-managed-service-shape-automate-vs-high-touch.md` and `decisions/2026-04-26-ide-scope-collapse.md`, clients never see Obsidian, the vault, the IDE, or the CLI — they see WhatsApp + email. Do **not** position an Obsidian view as a client deliverable or a tier feature.
- **Consistent with the portability thesis.** `decisions/2026-04-17-pivot-to-ide-infrastructure.md`: *"Vault portable across any markdown editor; canonical version on GitHub."* Obsidian is one such editor. This skill exercises that portability for us.
- **Valid graduation handoff** for the technical ~10% who already drive the vault directly (VSCode extension users). For everyone else, it's internal-only.
- See `decisions/2026-06-06-obsidian-read-only-operator-view.md`.

## When to Use

- You want to *see* a vault — graph of how decisions/research/reference connect, backlinks into a file, fast switching.
- Onboarding yourself to an unfamiliar client vault.
- After a vault has grown and `HOME.md` is stale.

## Where Files Go

Everything is additive — the skill never touches canonical content (unless you explicitly run `enrich`).

```
<vault>/
├── .obsidian/        ← generated config, LOCAL ONLY (gitignored by repo convention — regenerate per machine)
└── HOME.md           ← generated map-of-content (committed; portable markdown, also renders nicely on GitHub)
```

**`.obsidian/` is not committed.** Codify vaults gitignore `.obsidian/` on purpose — *"notes stay portable .md; only the editor config is local."* The config is editor-specific and per-operator, so this skill regenerates it locally with `setup`; it never ships in git. `HOME.md` is plain markdown and *is* committed — it improves both the Obsidian view and the GitHub file browser.

## Modes

| Mode | What it does | Mutates canonical content? |
|---|---|---|
| `setup` | Generate `.obsidian/` config (local-only) + `HOME.md`, print open instructions | No |
| `refresh` | Regenerate `HOME.md` from the current vault structure | No |
| `enrich` | **Opt-in.** Convert relative-path `.md` links to `[[wikilinks]]` so the graph/backlinks are full | **Yes** — confirm first |

Default mode is `setup`.

---

## `setup`

### 1. Confirm the target vault

Confirm you're operating in the intended vault root (the folder containing `reference/`, `decisions/`, `research/`, `.codify/`). Never write `.obsidian/` outside a vault.

### 2. Generate the `.obsidian/` config

Notes open in **reading mode** by default (`defaultViewMode: preview`, `livePreview: false`) — the closest Obsidian gets to a read-only feel. Only read-useful core plugins are on; no community plugins (read-only, no third-party code).

```bash
mkdir -p .obsidian

cat > .obsidian/app.json <<'JSON'
{
  "readableLineLength": true,
  "showUnsupportedFiles": true,
  "alwaysUpdateLinks": true,
  "defaultViewMode": "preview",
  "livePreview": false,
  "newFileLocation": "current"
}
JSON

cat > .obsidian/appearance.json <<'JSON'
{
  "theme": "obsidian",
  "baseFontSize": 16
}
JSON

cat > .obsidian/core-plugins.json <<'JSON'
{
  "file-explorer": true,
  "global-search": true,
  "switcher": true,
  "graph": true,
  "backlink": true,
  "outgoing-link": true,
  "tag-pane": true,
  "properties": true,
  "page-preview": true,
  "outline": true,
  "word-count": true,
  "bookmarks": true,
  "file-recovery": true,
  "command-palette": true,
  "editor-status": false,
  "daily-notes": false,
  "templates": false,
  "note-composer": false,
  "slash-command": false,
  "audio-recorder": false,
  "workspaces": false,
  "random-note": false,
  "sync": false,
  "publish": false
}
JSON

cat > .obsidian/community-plugins.json <<'JSON'
[]
JSON

cat > .obsidian/graph.json <<'JSON'
{
  "collapse-filter": false,
  "search": "",
  "showTags": true,
  "showAttachments": false,
  "hideUnresolved": true,
  "showOrphans": true,
  "collapse-display": false,
  "showArrow": true,
  "textFadeMultiplier": 0,
  "nodeSizeMultiplier": 1.1,
  "lineSizeMultiplier": 1,
  "collapse-forces": false,
  "centerStrength": 0.5,
  "repelStrength": 12,
  "linkStrength": 1,
  "linkDistance": 250,
  "scale": 1
}
JSON

cat > .obsidian/hotkeys.json <<'JSON'
{}
JSON

echo ".obsidian/ config written."
```

### 3. Confirm `.obsidian/` is gitignored (it should already be)

Codify vaults ignore `.obsidian/` by convention — the config is local-only and regenerated per machine. Verify, don't re-add:

```bash
git check-ignore .obsidian/app.json >/dev/null 2>&1 \
  && echo ".obsidian/ is gitignored — good, config stays local." \
  || echo "WARN: .obsidian/ is NOT ignored. Add '.obsidian/' to .gitignore before committing."
```

If the warning fires, add `.obsidian/` to `.gitignore` — do **not** commit editor config.

### 4. Generate `HOME.md` (map-of-content)

This is the landing note. **Build it by reading the actual vault** — don't hardcode. Steps:

1. Read `reference/core/` (or `.codify/`) — link soul, voice, audience, offer.
2. List `decisions/` newest-first; link the 10 most recent with their one-line title.
3. List `research/` newest-first; link the 10 most recent.
4. Note counts ("47 decisions, 120 research files — see folders for the full set").
5. Use `[[wikilinks]]` in HOME so the graph treats it as the hub even if the rest of the vault uses path-links.

Skeleton:

```markdown
---
type: home
title: Vault Home
last-updated: <YYYY-MM-DD HH:mm>
---

# 🏠 Vault Home

Read-only Obsidian view over the canonical GitHub vault. Edits happen through the CLI/skills, not here. Open the graph (left ribbon) to see how everything connects.

## Core Identity
- [[soul]] — why we exist
- [[offer]] — what we sell
- [[audience]] — who buys
- [[voice]] — how we sound

## Recent Decisions
- [[YYYY-MM-DD-slug]] — one-line title
- … (10 most recent)

→ `decisions/` holds the full set (N files).

## Recent Research
- [[YYYY-MM-DD-slug]] — one-line title
- … (10 most recent)

→ `research/` holds the full set (N files).
```

### 5. Tell the operator how to open it

Print, don't guess at automation:

```
Obsidian view ready.

Open it:
  • Obsidian → "Open folder as vault" → select this vault root
  • or: open obsidian://open?path=<absolute-vault-path>   (macOS, if Obsidian installed)

First launch: Obsidian asks to "Trust author and enable plugins" — you can
stay in Restricted Mode; this view needs no community plugins. Notes open in
reading mode. Use the graph (left ribbon) and ⌘O quick-switcher to navigate.
```

Only `HOME.md` is a committable artifact (`.obsidian/` is local-only). Let the operator review; mention `/co-deploy` if they want to ship `HOME.md` to GitHub.

---

## `refresh`

Regenerate `HOME.md` only (step 4 above) against the current vault. Leave `.obsidian/` config untouched. Use after the vault has grown enough that the recent-files lists are stale.

---

## `enrich` (opt-in, mutating)

Obsidian's graph **already** renders standard markdown links between notes, so the graph works without this. `enrich` exists for richer backlink panels and `[[ ]]` autocomplete — at the cost of editing canonical files.

Before running:

1. **Confirm explicitly.** This rewrites links in canonical content. Show the operator the scope (`git diff --stat` after a dry run on one folder) and get a yes.
2. Convert `[text](relative/path/to/note.md)` → `[[note|text]]` only where the target is another markdown note inside the vault. Leave external URLs, images, and anchors alone.
3. Do one folder at a time; keep it a reviewable diff.
4. Commit as its own change: `[update] co-obsidian enrich — path-links → wikilinks in <folder>`.

If the operator just wants to look, **skip this.** The graph is fine on markdown links.

---

## What This Skill Does NOT Do

- It does **not** make Obsidian a client surface. Internal/operator + technical-graduation only.
- It does **not** sync, publish, or replace GitHub as canonical. Obsidian is a viewer.
- It does **not** install community plugins or run third-party code.
- It does **not** edit canonical content in `setup`/`refresh`. Only `enrich` mutates, and only with confirmation.
- It does **not** auto-commit. Pair with `/co-deploy` when you want the config in version history.

## Why This Matters

A vault is a graph of decisions, research, and reference files that point at each other. On a file tree that structure is invisible; in Obsidian's graph and backlink panels it's the whole point. For an operator picking up an unfamiliar vault, "show me what connects to this decision" is one click instead of a grep. It's the portability thesis made literal — the same sovereign markdown, a better lens.
