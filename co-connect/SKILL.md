---
name: co-connect
description: "Operator-only. Set up (or change) your own always-on host + delivery channel for overnight ops and morning briefs. Run once at install. Writes your operator connection profile to ~/.codify/operator.md — never linked to anyone else's server. Modes: setup, status, test, clear."
---

# /co-connect — Your Always-On + Delivery Setup

**Operator-only. Run once at install** (and again any time your server or channel changes).

The overnight loop and the morning brief need to know **where they run** and **how they reach you** — and that's different for every operator. You might run a VPS, an always-on machine at home, or nothing at all (manual). Briefs might come to you on Telegram, WhatsApp, email, or just show up in the chat pane.

This skill captures *your* setup once and writes it to your **operator connection profile** — `~/.codify/operator.md`. Every overnight/delivery skill reads that file. **Nothing is ever hardcoded to another operator's server or channel.** If you skip this, everything still works — it just runs in **manual mode** (you run `/co-loop` yourself; briefs display in chat).

> **Profile, not secrets.** `~/.codify/operator.md` holds *non-secret* config only (mode, channel, target IDs). Tokens and keys live in `~/.codify/.env` (or your shell), referenced by name — never written into the profile, a vault, or a prompt (Rule 7). The profile lives in `~/.codify/`, **outside every client vault** — it's yours, shared across all your clients, and travels with the engine, not the client repos.

## Usage

```
/co-connect setup     → interview + write ~/.codify/operator.md  (default)
/co-connect status    → show your current profile (no secrets)
/co-connect test      → send a test brief through your configured channel
/co-connect clear     → reset to manual mode (deletes the profile)
```

## Mode: setup

Ask these, in plain language, and write the answers to the profile.

**1. Always-on host — "Do you have a machine that can run overnight jobs?"**

| Answer | `always_on.mode` | What it means |
|---|---|---|
| "No / not yet" | `none` | **Manual mode.** You run `/co-loop` yourself; briefs show in chat. No server needed. This is the honest default. |
| "This machine" | `local` | Jobs run on the operator's own machine (launchd/cron). Only fires while it's awake. |
| "A server / VPS" | `vps` | Jobs run on an always-on box you control. Capture an optional ssh label in `always_on.host`. |

If `none`, you can stop here — write the profile and exit. Delivery defaults to `chat`.

**2. Delivery channel — "When a brief is ready overnight, how should it reach you?"**

| Answer | `delivery.channel` | What you'll need |
|---|---|---|
| "Just show it in chat" | `chat` | Nothing. (Default when `always_on.mode = none`.) |
| "Telegram" | `telegram` | A bot **you** create (@BotFather) → set `TELEGRAM_BOT_TOKEN` in `~/.codify/.env`; capture your chat/topic id as `delivery.target`. |
| "WhatsApp" | `whatsapp` | **Your own** WhatsApp bridge (you host it — Codify does not provide one). Set `WHATSAPP_BRIDGE_URL` + `WHATSAPP_API_KEY` in `~/.codify/.env`; capture your group/JID as `delivery.target`. |
| "Email" | `email` | Your own SMTP/Gmail. Set `OPERATOR_EMAIL` as `delivery.target`; creds via your existing mail MCP/env. |

For any channel except `chat`, **print the exact env var names to set** and confirm they're set before `test`. Never ask for the secret value in chat — point at `~/.codify/.env`.

**3. Schedule — "What time do you want the morning brief?"** (default `30 5 * * *`). Store as `schedule.brief`.

**4. Budget cap — "What's the most you want to spend per month, across all clients?"** (default `$100`). Store as `budget.monthly_usd_cap`. This is the ceiling the cost circuit-breaker (`bin/budget-guard.sh`) enforces — at 90% of it, overnight loops refuse to run until you raise it. Also set `budget.max_active_crons` (default 10) as a runaway-cron guard. See `GUARDRAILS.md` §3.

### Write the profile

```bash
mkdir -p ~/.codify
cat > ~/.codify/operator.md <<'EOF'
---
type: operator-profile
always_on:
  mode: none            # none | local | vps
  host: ""              # optional ssh label for vps, e.g. ops@my-vps
delivery:
  channel: chat         # chat | telegram | whatsapp | email
  target: ""            # chat/topic id, group/JID, or email — channel-specific
schedule:
  brief: "30 5 * * *"
budget:                 # the cost circuit-breaker (bin/budget-guard.sh reads this)
  monthly_usd_cap: 100  # hard ceiling across ALL your clients' overnight spend
  max_active_crons: 10  # runaway-cron guard — warn before exceeding
secrets_in_env:         # NAMES only — values live in ~/.codify/.env
  - TELEGRAM_BOT_TOKEN  # if channel=telegram
  - WHATSAPP_BRIDGE_URL # if channel=whatsapp
  - WHATSAPP_API_KEY    # if channel=whatsapp
---

# Operator Connection Profile

Written by `/co-connect`. Yours alone — read by `/co-openclaw`, `/co-brief`, `/co-loop`.
Edit by re-running `/co-connect setup`. Manual mode (`mode: none`, `channel: chat`)
needs no server and no secrets.
EOF
```

Then: **"Profile saved to `~/.codify/operator.md` (mode: <mode>, delivery: <channel>). Set <env vars> in `~/.codify/.env`, then run `/co-connect test`."** If `mode: none`, say: **"You're in manual mode — run `/co-loop` yourself and briefs will show in chat. Re-run `/co-connect` any time you stand up a server."**

## Mode: status

Read `~/.codify/operator.md` and print mode, channel, target, schedule, and which named env vars are present (✓/✗) — **never the secret values**. If no profile exists: "No profile yet — you're in manual mode. Run `/co-connect setup` to wire a server/channel."

## Mode: test

Render a tiny sample brief and push it through `delivery.channel`. `chat` → print it. `telegram`/`whatsapp`/`email` → send via the configured target using the env-named secret; report success/failure with the exact var to fix if it fails. Mirrors `/co-brief`'s delivery path so a green `test` guarantees real briefs land.

## Mode: clear

Delete `~/.codify/operator.md` (confirm first). Returns the operator to manual mode. Does not touch `~/.codify/.env`.

## How the skills consume this

- **`/co-openclaw`** reads `always_on.{mode,host}` + `delivery.*` to provision jobs on *your* box and route briefs to *your* channel — instead of any shared/inherited server or group.
- **`/co-brief`** reads `delivery.channel`: `chat` → display only; otherwise send to your target. With no profile, it's display-only.
- **`/co-loop`** runs the same whether automated or manual; the profile only decides *who triggers it* and *where the brief goes*.

## What this skill does NOT do

- It does **not** provide a WhatsApp bridge or a server — you bring your own; this just records where they are.
- It does **not** write secrets anywhere but your env, and never into a client vault or a prompt.
- It does **not** put anything in a client's repo — the profile is operator-level, in `~/.codify/`.
