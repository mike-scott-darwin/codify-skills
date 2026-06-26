---
name: co-start
description: "Welcome back screen for Codify. Shows vault state, recent changes, and what to do next."
---

# /co-start — Welcome to Codify

When the client runs `/co-start`, do the following:

## 1. Read the Vault State

Before showing anything, silently read:
- All files in `core/` — check `status` and `last-updated` in frontmatter
- Recent files in `campaigns/` — last 3 by date
- Recent files in `decisions/` — last 3 by date
- Count of files in each folder

## 2. Determine If This Is a First Visit or Return

**First visit** — all Context files have `status: draft` or are template-only (contain `<!-- -->` comment placeholders with no real content).

**Returning** — at least one Context file has `status: active` or `status: compounding`.

## 3. Display the Right Welcome

### If First Visit:

**Welcome to Codify**

This is your Context Architecture — a secure vault where your expertise compounds over time. Everything you share here stays here. The AI reads it all before generating anything, so your outputs reflect your judgment, not generic advice.

**Start here:**
- Type `/co-extract soul` to capture your core identity
- Or `/co-import` if you have existing material (proposals, website copy, emails) — it's faster

### If Returning:

**Welcome back.**

Then show a brief status report:

**Your Context Files:**
- For each file in `core/`, show: name, depth (Getting there / Solid / Deep based on status field), and last-updated
- Flag any file not updated in 14+ days as "could use a refresh"

**Since your last session:**
- List any new files in `campaigns/` or `decisions/` created since the oldest `last-updated` across Context files
- If no new files, say "No new outputs since your last session."

**Recommended next step:**
- If any Context file has zero outgoing `[[links]]`: "Your [file] has no connections to other files. Run `/co-extract [file]` to link it up — this makes your outputs sharper."
- If any Context file is still `status: draft`: "Your [file] could go deeper. Run `/co-extract [file]` to strengthen it."
- If all Context files are `status: compounding`: "Your context is strong. Want the one move closest to revenue today? Run `/co-money-path`. Or to create: `/co-ad`, `/co-email`, `/co-content`, `/co-proposal`."
- When at least one Context file is `status: active`/`compounding`, you may append a one-line MoneyPath snapshot to the welcome by calling `/co-money-path --snapshot` — surface the bottleneck and the closest move so the architect can act without opening a laptop.

**What you can do:**

| Command | What It Does |
|---------|-------------|
| `/co-extract` | Build your context files through conversation |
| `/co-import` | Mine existing documents into context files |
| `/co-ad` | Create ad copy |
| `/co-email` | Create email sequences (cold, warm, nurture, post-call follow-up) |
| `/co-content` | Create content for any platform |
| `/co-proposal` | Create a client proposal |
| `/co-landing` | Create landing page copy |
| `/co-case-study` | Turn a client win into a case study |
| `/co-pitch` | Elevator pitch, event intro, speaker bio, objection responses |
| `/co-research` | Research a prospect, competitor, or market trend |
| `/co-money-path` | Find the one move closest to your next dollar |
| `/co-audit` | See your vault health |
| `/co-brief` | Summary of vault health and recommended focus |

## Tone Rules

- Do NOT mention git, GitHub, terminal, CLI, API, MCP, skills, or any technical infrastructure
- This client is a senior leader with deep expertise. Speak to their intelligence, not their technical ability.
- Keep it concise. No filler. Lead with what matters.
- If returning, the status report IS the value. The architect runs `/co-start` and surfaces the output on WhatsApp — the client immediately knows where they stand and what to do next without opening a laptop.
