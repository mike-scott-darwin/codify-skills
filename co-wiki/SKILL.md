---
name: co-wiki
description: |
  Create and maintain a personal wiki on Cloudflare Pages. Atomic notes, WikiLinks, auto-deploy. Use when:
  (1) Setting up a new wiki from the commune-wiki template
  (2) Personalizing wiki (name, avatar, social links, custom domain)
  (3) Adding atomic notes with proper frontmatter and WikiLinks
  (4) Publishing changes (git commit + push for auto-deploy)
  (5) Converting Gemini/GPT deep research into wiki format
  (6) Pulling upstream template updates
  (7) Generating "Recent Updates" notes from Git history

  Triggered by: /co-wiki, "add a note", "publish wiki", "create wiki", "personalize wiki"
---

# /co-wiki — Personal Wiki on Cloudflare Pages

Public-facing knowledge garden. Atomic notes with WikiLinks, auto-deployed to Cloudflare Pages. Separate from the vault — wiki content is public; vault content is private.

---

## Where Files Go

Wiki files live in a **separate repo** from the Codify vault.

```
your-wiki-repo/
├── src/content/notes/        ← Atomic notes (/co-wiki add)
├── src/content/research/     ← Full research docs (/co-wiki research)
└── src/content/updates/      ← Auto-generated updates (/co-wiki recent)

~/.codify/co-wiki.json        ← Config pointing to wiki repo
```

---

## Prerequisites

- GitHub CLI (`gh`) installed and authenticated
- `pnpm` installed (`npm install -g pnpm`)
- Cloudflare account (free tier works — created during setup)

Check existing config:

```bash
cat ~/.codify/co-wiki.json 2>/dev/null || echo "No wiki configured yet"
```

---

## Modes

| Mode | What it does | When |
|---|---|---|
| `setup` | Clone template, deploy to Cloudflare Pages | First time |
| `configure` | Personalize wiki (name, social, domain, avatar) | After setup |
| `add` | Create atomic note with frontmatter | Daily note-taking |
| `publish` | Commit + push (auto-deploys) | After any change |
| `research` | Convert deep research to wiki format | After Gemini/GPT research |
| `update` | Pull upstream template changes | When fixes released |
| `recent` | Generate "Recent Updates" from git history | Weekly |

---

## Mode: setup

First-time wiki setup. Clones the commune-wiki template, deploys via Cloudflare Pages.

Quick steps:

1. Ask repo name (e.g., `[architect-name]-wiki`)
2. Check `gh auth status`
3. Create + clone the wiki repo: `gh repo create [name] --public --clone`
4. Merge upstream template: `git remote add upstream https://github.com/devonmeadows/commune-wiki.git && git fetch upstream && git merge upstream/main --allow-unrelated-histories`
5. `pnpm install && pnpm build`
6. `git push -u origin main`
7. Cloudflare dashboard → Workers & Pages → Create → Connect to Git → select repo
8. Capture deployed `*.pages.dev` URL
9. Update `astro.config.mjs` site URL → commit → push (triggers deploy)
10. Save config to `~/.codify/co-wiki.json`:

```json
{
  "wiki_repo": "/absolute/path/to/wiki",
  "hosting": "cloudflare",
  "domain": "your-wiki.pages.dev",
  "cf_project": "your-wiki"
}
```

**Exit:** "Wiki deployed. Run `/co-wiki configure` to personalize, or `/co-wiki add` to create your first note."

---

## Mode: configure

Personalize after setup. Prompts:

| Setting | Required | Default |
|---|---|---|
| Display name | Yes | — |
| Short name (mobile) | No | First word of display name |
| Avatar image | No | drag & drop to replace |
| Twitter/X handle | No | skip |
| GitHub username | No | skip |
| Website URLs | No | skip (comma-separated) |
| Custom domain | No | keep `*.pages.dev` |
| Delete sample notes | No | keep samples |

Files to update:
- `src/components/Header.astro` — display name, short name, avatar alt
- `src/components/Footer.astro` — attribution
- `src/pages/index.astro` — meta author, structured data
- `src/pages/notes/[...slug].astro` — author meta
- `src/content/notes/my-working-notes.md` — social links
- `astro.config.mjs` — site URL if domain changed

**If avatar provided:** copy to `public/avatar.jpg`, generate `public/favicon-32x32.png` via sharp.

**If custom domain:** walk through Cloudflare custom domain setup (Workers & Pages → project → Custom domains → add → CNAME on Cloudflare-managed DNS).

**If delete samples:** `rm -f src/content/notes/*.md src/content/updates/*.md`, then create fresh `my-working-notes.md` with welcome content.

Rebuild + push: `pnpm build && git add -A && git commit -m "[configure] personalize wiki" && git push`.

---

## Mode: add

Create a new atomic note.

**Usage:** `/co-wiki add "Note Title"`

Steps:
1. Read config to find wiki repo
2. Generate slug from title
3. Check note doesn't already exist
4. Create with frontmatter:

```yaml
---
title: "Note Title"
status: draft
visibility: public
date: [today]
last-updated: [today's date and time]
tags: []
---
```

5. Apply evergreen principles: atomic (one concept), concept-oriented (not chronological), densely linked
6. Suggest WikiLinks: grep existing notes for related concepts; offer `[[Other Note]]` links

Valid `status`: `draft`, `live`, `updated`. Valid `visibility`: `public`, `private`, `draft`.

**Exit:** "Note created. Run `/co-wiki publish` to deploy, or continue editing."

---

## Mode: publish

Commit + push. Cloudflare auto-deploys.

**Usage:** `/co-wiki publish "commit message"` or `/co-wiki publish` (generates message)

```bash
cd [wiki_repo]
git status --short
git add -A
git commit -m "[type] [generated or provided message]"
git push origin main
```

**Exit:** "Pushed. Cloudflare will auto-deploy in ~90s."

---

## Mode: research

Convert long-form deep research (Gemini, GPT, Claude) into wiki format.

**Usage:** `/co-wiki research [path-to-research.md]`

Creates two files:
1. **Tripwire summary** in `src/content/notes/research-[slug].md` — short, links to full research
2. **Full research** in `src/content/research/[slug].md` — the long-form

Format external links with arrow icon. Suggest WikiLinks to existing notes.

**Exit:** "Research split into summary + full doc. Run `/co-wiki publish` to deploy."

---

## Mode: update

Pull upstream template improvements.

```bash
cd [wiki_repo]
git fetch upstream
git log HEAD..upstream/main --oneline
# confirm merge with architect
git merge upstream/main --no-edit
pnpm install && pnpm build
```

**Exit:** "Template updated. Run `/co-wiki publish` to deploy."

---

## Mode: recent

Generate weekly "Recent Updates" note from git history.

**Triggers:** Friday with >3 commits this week, >15 commits in a single day, or manual.

```bash
git log --since="1 week ago" --pretty=format:"%h %s" --name-only
```

Categorize: new notes, updated notes, research added. Save to `src/content/updates/YYYY-MM-DD.md`.

---

## When NOT to Use

- Vault notes (private business context) — those stay in the Codify vault
- General note-taking — use your notes app
- Quick scratch notes — wiki is for evergreen, linked, public knowledge

---

## Why Cloudflare

- Free tier covers most wikis
- Custom domains free
- Git auto-deploy, no CI to maintain
- Sovereign hosting — your repo, your content

---

## Troubleshooting

**"No wiki configured"** — Run `/co-wiki setup` first.

**Build failing on Windows with path error** — `astro.backlinks.ts` needs a Windows fix. Add `import { fileURLToPath } from 'node:url'` and use `fileURLToPath(dir)` instead of `dir.pathname`.

**Build failing with sitemap "reduce" error** — Temporarily comment out the sitemap integration in `astro.config.mjs`, deploy once, then re-enable.

**Stuck on Cloudflare dashboard** — Paste a screenshot.

---

## Tone

Wiki content is in the architect's voice (or the client's, if writing for a client wiki). Read `.codify/voice.md` before generating note bodies.
