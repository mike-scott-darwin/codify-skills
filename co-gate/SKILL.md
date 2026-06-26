---
name: co-gate
description: "Skill tier gating — checks client tier before running locked skills. Reads tier from vault config."
---

# Skill Gating System

Every skill checks the client's tier before executing. The tier is stored in the vault's config file.

Source of truth for pricing and tier scope: `reference/core/offer.md`.

## Tier Config

The file `core/.tier` (or `.tier` in the vault root) stores the client's tier:

```
codify
```

Valid values: `snapshot`, `codify`, `orchestrate`

The architect sets this during `/co-setup`. Plain text file — no YAML, no complexity.

## How Gating Works

Every skill `SKILL.md` includes a tier requirement in its frontmatter. Before executing, check:

1. Read `core/.tier` (fall back to `.tier` in vault root if not found)
2. Compare against the skill's required tier
3. If the client's tier is sufficient, run the skill
4. If not, show the upgrade message

## Tier Hierarchy

```
snapshot < codify < orchestrate
```

- `snapshot` — free outbound brief. No vault. Delivered by architect; no skill access required on the prospect side.
- `codify` — full managed service ($297/mo, no setup fee). All client-facing skills unlocked.
- `orchestrate` — everything in Codify + autonomous agent team + sovereign infrastructure ($2,500 setup + $1,997/mo).

## Skill Map

### Station 1 — Snapshot (Free)

No vault on the prospect's side. The architect runs `/co-snapshot` against the prospect's public sources and delivers the brief outbound.

| Skill | Description |
|-------|-------------|
| `/co-snapshot` (architect-run) | Free brief from public sources — before/after + 3 opportunities, 24–48h |

### Station 2 — Codify ($297/mo, no setup fee)

All client-facing skills unlocked. Managed service — architect operates; client reviews via WhatsApp + web workspace.

| Skill | Description |
|-------|-------------|
| `/co-start` | Welcome screen — vault state and what to do next |
| `/co-extract` | Unlimited context extraction (soul, audience, offer, voice) |
| `/co-import` | Mine existing documents into Context files |
| `/co-content` | Content for any platform (LinkedIn, blog, newsletter, X/Twitter) |
| `/co-research` | Research prospects, competitors, market trends |
| `/co-brief` | Morning brief — decisions, priorities, open threads |
| `/co-think` | Research → decide → codify; cross-reference context against market signals |
| `/co-audit` | Vault health check |
| `/co-ad` | Generate ad copy (Meta/Facebook/Instagram) |
| `/co-email` | Generate email sequences (cold, warm, nurture, post-call follow-up) |
| `/co-landing` | Generate landing page copy |
| `/co-proposal` | Generate client proposal |
| `/co-pitch` | Elevator pitch, event intro, podcast bio, speaker page, objection responses |
| `/co-case-study` | Client win → formatted case study |
| `/co-site` | Website copy trained on the client's context |
| `/co-publish` | Distribute outputs to live channels |
| `/co-ghl` | Drive the client's GoHighLevel CRM — prospects → pipeline, sequences → workflows (paused), status sync |
| `/co-campaign` | Full pipeline — generate + distribute across channels |
| `/co-organic` | Short-form scripts + repurpose one output into channel variants |

### Station 3 — Orchestrate ($2,500 setup + $1,997/mo)

Everything in Codify, plus:

| Feature | Description |
|---------|-------------|
| Nightly overnight loop | Prospect Researcher → Deliverable Writer → Outreach Sequencer → Campaign Activator, 10pm–6am autonomous |
| Four paired agents | Research / Strategy / Marketing / Editor — review each other; no agent ships unreviewed |
| CEO agent | Spawns new agents on demand from the client's context |
| Sovereign vault | Paperclip (MIT) control plane on client VPS, Forgejo (not GitHub), optional local models |
| Per-agent budget gates | `budget_tokens` hard-stop — 70% warn, 90% human approval, 100% stop |
| Human-in-the-Loop | All outputs require sign-off before publishing |
| Chat-log → tuning loop | Every WhatsApp / workspace exchange feeds back into agent definitions |

### Architect-Only (Internal — Not Client-Facing)

| Skill | Description |
|-------|-------------|
| `/co-setup` | Initial vault provisioning and personalization |
| `/co-update` | Pull latest Codify skills and system files — never touches client data |
| `/co-openclaw` | Provision overnight OpenClaw jobs for an Orchestrate client |
| `/co-security` | Red-team vault audit |
| `/co-deploy` | Architect-side commit + push ritual |
| `/co-gate` | This skill — tier enforcement logic |

## Budget gate (the cost circuit-breaker)

Tier gating decides *what's allowed*; the budget gate decides *whether we can afford to run it right now*. **Before any expensive skill** — `/co-loop`, `/co-research`, `/co-openclaw`, or a full `/co-campaign` — check the cost breaker:

1. Read `~/.codify/budget-status` (written by `bin/budget-guard.sh`, which sums month-to-date `cost_usd` from every client's `operator-queue/` against `budget.monthly_usd_cap` in `~/.codify/operator.md`).
2. Act on it:
   - `ok` (<70% of cap) → run normally.
   - `warn` (70–89%) → run, but surface: *"Heads up — you're at <pct>% of this month's budget cap."*
   - `stop` (≥90%) → **do not run.** Say: *"Budget cap reached for this month (<spend> of <cap>). Raise `budget.monthly_usd_cap` in `~/.codify/operator.md`, or wait for the month to roll. Run `bin/budget-guard.sh` to recheck."*
3. If no status file exists, run `bin/budget-guard.sh` once to generate it; if there's still no cap configured, warn that spend is uncapped and recommend `/co-connect`.

Per-agent caps still apply on top: each agent's `budget_tokens` is a hard-stop — 70% warn, 90% human approval, 100% stop. The operator cap is the ceiling across *all* clients; the agent cap bounds a single agent. See `GUARDRAILS.md` §3.

## Upgrade Prompts

When context requires a higher tier:

**Snapshot → Codify:**
"This requires a Codify vault ($297/mo, no setup fee). We extract your expertise into a sovereign vault and run the weekly prospecting loop in your voice. Ready to start? [`codify.build/get-started`](https://codify.build/get-started) — or reply to the brief we sent you."

**Codify → Orchestrate:**
"This requires the Orchestrate tier ($2,500 setup + $1,997/mo). Nightly autonomous loop across every niche you have, plus four paired agents (Research / Strategy / Marketing / Editor) coordinating across your whole business on a sovereign vault. By application — talk to Michael."

## Notes

- The `.tier` file is a dotfile — hidden by default in most file browsers
- The architect sets the tier during `/co-setup` or manually
- Upgrading is just changing one word in `.tier` — no API calls, no license servers
- Honor system backed by the relationship, not DRM
