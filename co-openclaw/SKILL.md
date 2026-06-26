---
name: co-openclaw
description: "Architect-only. Set up OpenClaw autonomous operations for an Orchestrate tier client on YOUR own always-on host. Reads your connection profile (~/.codify/operator.md from /co-connect); routes briefs to your own channel. Run /co-connect first."
---

# /co-openclaw — Set Up Autonomous Operations

Architect-only skill. Connects an Orchestrate tier client's sovereign vault to OpenClaw for the nightly overnight prospecting loop, morning briefs, and automated backups.

Source of truth for tier scope: `reference/core/offer.md` §"Station 3 — Orchestrate".

**Prerequisites:** OpenClaw running on your own always-on machine, **and an operator connection profile** (`~/.codify/operator.md`, written by `/co-connect`). This skill reads `always_on.{mode,host}` and `delivery.*` from that profile — it never assumes a shared/inherited server or channel. If the profile is missing or `always_on.mode: none`, stop and tell the operator to run `/co-connect` first (overnight ops need a host).

## Usage

```
/co-openclaw setup              → Set up a new client
/co-openclaw status [client]    → Check a client's jobs
/co-openclaw pause [client]     → Pause all jobs for a client
/co-openclaw resume [client]    → Resume paused jobs
```

## Setup Procedure

### 1. Load your profile + gather 2 inputs

First read `~/.codify/operator.md` (from `/co-connect`) for `always_on.host` and `delivery.{channel,target}` — *your* server and *your* channel. Then ask:
1. **"Client name?"** → Used for workspace name (lowercase, hyphens)
2. **"Vault repo URL?"** → The client's GitHub sovereign vault URL

Delivery routing comes from the profile, not from this prompt. If `delivery.channel` is `telegram`, the steps below create the client's topic; for `whatsapp`/`email`, route to the profile's `target` instead; for `chat`, skip remote delivery (briefs surface when the operator opens the session).

### 2. Create Workspace

```bash
# Clone the client's vault to the OpenClaw machine
git clone [vault-repo-url] ~/vaults/[client-name]-sovereign-vault

# Create OpenClaw workspace
openclaw workspace create [client-name] \
  --vault-path ~/vaults/[client-name]-sovereign-vault
```

### 3. Create Telegram Topic

```bash
# Create a topic thread in YOUR delivery supergroup (delivery.target from ~/.codify/operator.md)
# (Telegram Bot API — create_forum_topic)
curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/createForumTopic" \
  -d "chat_id=$TELEGRAM_SUPERGROUP_ID" \
  -d "name=[Client Name] — Ops" \
  | python3 -c "import sys,json; print(json.load(sys.stdin)['result']['message_thread_id'])"
```

Save the topic ID for cron job configuration.

### 4. Add Standard Cron Jobs

```bash
# Morning brief — 5:30 AM daily
openclaw workspace [client-name] cron add "morning-brief" \
  --schedule "30 5 * * *" \
  --telegram-topic [topic-id]

# Overnight research — 2:00 AM daily
openclaw workspace [client-name] cron add "deep-research" \
  --schedule "0 2 * * *"

# Vault backup — every hour
openclaw workspace [client-name] cron add "vault-sync" \
  --schedule "0 * * * *"

# Staleness check — 6:00 AM daily
openclaw workspace [client-name] cron add "staleness-check" \
  --schedule "0 6 * * *" \
  --telegram-topic [topic-id]

# Competitor monitor — Monday 3:00 AM
openclaw workspace [client-name] cron add "competitor-scan" \
  --schedule "0 3 * * 1"
```

### 5. Test

```bash
# Run a test morning brief
openclaw workspace [client-name] run morning-brief

# Verify Telegram delivery
# Should appear in the client's topic thread
```

### 6. Confirm

Say: "OpenClaw is live for [client name]. They'll get their first morning brief tomorrow at 5:30 AM."

## What Gets Created

| Component | Details |
|-----------|---------|
| Workspace | `~/vaults/[client]-sovereign-vault` on OpenClaw machine |
| Cron jobs | 5 jobs: brief, research, sync, staleness, competitor |
| Telegram | New topic thread in your delivery channel |
| Git sync | Hourly pull/push against client's sovereign vault |

## Cost Per Client

| Item | Cost |
|------|------|
| VPS overhead | ~$1/mo per client (shared $4/mo VPS) |
| API calls (overnight research) | ~$0.50/day (cheap model tier) |
| Telegram | Free |
| **Total** | **~$15-20/mo per client** |

Covered by the Orchestrate fee ($2,500 setup + $1,997/mo). The one-time setup funds deep expertise extraction, connector wiring, and the 90-day ramp; the monthly is operating + compounding. The control plane is open-source (Paperclip, MIT), so the client pays for deployment and operation, not SaaS margins — and still comes in at a fraction of an agency ($5k–$12k/mo) or a fractional CMO ($10k–$30k/mo), with the client owning their files.

## Troubleshooting

| Problem | Fix |
|---------|-----|
| Cron not firing | `openclaw workspace [client] cron list` — check schedule |
| Telegram not delivering | Verify bot token and topic ID |
| Git sync fails | Check SSH key / GitHub auth on OpenClaw machine |
| Brief is empty | Vault has no recent activity — normal for new clients |
| Research job times out | Check model routing — use cheap tier (Gemini Flash) |
