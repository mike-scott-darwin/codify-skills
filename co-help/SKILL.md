---
name: co-help
description: "Answer questions about Codify, the vault, and the skills. Use when: architect or client asks how/what/why questions, is confused about the vault structure, .codify/ files, skills, agent definitions, the graduation path (Snapshot/Codify/Orchestrate), encounters errors, says help or stuck, or wants to know what to do next. Explains why, not just what, and routes to the right next skill."
---

# /co-help — Answer Questions, Suggest Next Steps

Triage confusion. Explain how Codify works. Point at the right next skill.

---

## Workflow

1. **Triage** — Parse the question or brain-dump
2. **Locate** — Find the topic in the router below
3. **Answer** — Explain *why*, not just *what*
4. **Route** — End with the next skill or action

---

## Topic Router

| Keywords | Route / Reference |
|---|---|
| Getting started, setup, new client, first time | Route to `/co-setup` or `/co-start` |
| Vault structure, `.codify/`, core files, what's in here | "Vault Structure" below |
| Soul, audience, offer, voice, design files | "The Four Core Files" below |
| Exemplars, `.codify/exemplars/` | "Exemplars" below |
| Agents, agent definition, `.codify/agents/`, org chart, budget | "Agents" below |
| Operator queue, runs, logs, costs, marks | "Operator Queue" below |
| Graduation path, tiers, Snapshot, Codify, Orchestrate, $297, $1,997, setup fee | "The Graduation Path" below |
| WhatsApp, web vault, two surfaces, client interface | "Dual Surface" below |
| Architect, who runs this | "Architect-Operated" below |
| Research, decide, codify, enrich the core | Route to `/co-think` |
| End session, close, wrap up, goodnight | Route to `/co-end` |
| Ads, Meta, Facebook, Instagram, ad copy | Route to `/co-ad` |
| Email, cold outreach, nurture, follow-up | Route to `/co-email` |
| Content, LinkedIn, blog, X/Twitter, posts | Route to `/co-content` |
| Site, lander, minisite, landing page, deploy, Cloudflare | Route to `/co-site` |
| Proposal, client proposal | Route to `/co-proposal` |
| Snapshot, free brief, outbound, rebuilt homepage | Route to `/co-snapshot` |
| Case study, client win | Route to `/co-case-study` |
| VSL, video script, sales video | Route to `/co-site` (Path D — Video Script) |
| Repurpose, one output → many channels | Route to `/co-organic` |
| Pitch, elevator, podcast bio, speaker page | Route to `/co-pitch` |
| Research a prospect, competitor, market | Route to `/co-research` |
| Audit, vault health, drift, stale files | Route to `/co-audit` or `/co-doctor` |
| Bet, hypothesis, time-boxed test | Route to `/co-bet` |
| Brief, morning brief, what's next today | Route to `/co-brief` |
| Push, deploy, commit, GitHub, version control | Route to `/co-deploy` |
| Publish to live channels | Route to `/co-publish` |
| Security audit, threat model, red team | Route to `/co-security` |
| OpenClaw, overnight ops, autonomous, Orchestrate | Route to `/co-openclaw` |
| Compound, why does this work, philosophy | "The Compound Loop" below |
| Context > Prompts | "Why Context Beats Prompts" below |
| Stuck, lost, what next, I don't know what to do | "When Stuck" below |

---

## Vault Structure

Two coexisting layouts, same content, different audiences:

**Canonical (read by skills + agents):**
- `.codify/soul.md`, `voice.md`, `audience.md`, `offer.md` — the four core files
- `.codify/agents/<id>.md` — agent definitions
- `.codify/exemplars/<output-type>/` — past wins per output type
- `operator-queue/<date>-<agent>-<n>.md` — every agent run logged
- `campaigns/nightly/<date>/<prospect>/` — per-prospect overnight artifacts

**Human-friendly mirror (markdown editor):**
- `core/` — symlinks to `.codify/` core files
- `decisions/` — strategic decisions with dates and reasoning
- `research/` — market intel, competitor analysis, mining outputs
- `campaigns/` — generated content drafts
- `log/` — session notes, observations

The CLI always reads `.codify/`. The architect edits in either place.

---

## The Four Core Files

The substrate. Every output reads these before generating.

- `.codify/soul.md` — Why we exist. Beliefs, values, decision principles.
- `.codify/audience.md` — Who we serve. What they want, what they fear, their language.
- `.codify/offer.md` — What we sell. Pricing, mechanics, transformation.
- `.codify/voice.md` — How we sound. Tone, vocabulary, banned words.

These are the single source of truth. **Read them before generating anything.** Never hardcode pricing, tier names, or positioning into prompt text — read it from these files at runtime.

To build them: `/co-extract` (interview, also deepens what's there), `/co-import` (mine existing docs).

---

## Exemplars

`.codify/exemplars/<output-type>/` holds curated past wins per output type — ad, cold-email, content, landing, proposal, sales-page, vsl.

Generation skills read the relevant exemplars folder before writing. **Voice files set the rules; exemplars show the rules in practice.**

Add an exemplar when something performs unusually well. Strip the wins down to the structural patterns worth repeating.

---

## Agents

Agents are defined in `.codify/agents/<id>.md`. Each agent has:

- `role` — what this agent does
- `reports_to` — `null` for the root, an agent id for everyone else (org chart)
- `goals[]` — every operator-queue entry carries one of these as `goal_id`
- `budget_tokens` — monthly hard-stop. 70% used = warning, 90% = human approval, 100% = stop
- `schedule` — `daily 7am`, `weekly mon`, `on-demand`, `always-on`
- `skills[]` — which `/co-*` skills this agent invokes

The web workspace surfaces all four primitives at `codify.build/vault/{org,goals,queue,costs}`.

---

## Operator Queue

`operator-queue/<date>-<agent-id>-<seq>.md` — every agent run logs one file. Append-only; never edit a past run. If a run was wrong, write a corrective run referencing the original via `parent_ticket_id`.

Frontmatter carries: `agent_id`, `started_at`, `surface`, `input`, `output_file`, `status`, `goal_id`, `parent_ticket_id`, `cost_usd`, `tokens_used`, `marks`.

Marks come from the Editor agent reviewing recent runs: `✅` (exactly right), `👎` (off). The Editor proposes diffs to `.codify/agents/<id>.md` based on marks; the architect approves; the agent gets sharper. **That's the tuning loop.**

---

## The Graduation Path

Three stations. Same architecture, different scope.

- **Snapshot (free) — Station 1.** "Your customers wrote you a better homepage. We rebuilt it." For review-rich businesses: live rebuilt-homepage prototype + redline annotations + 4 extracted reference files in 24-48 hours. Fallback for thin-review businesses: 5 cold pitches in their voice.
- **Codify ($297/mo, no setup fee) — Station 2.** Single managed agent runs the overnight prospecting play in the client's voice on a weekly cadence. Prospects → research → custom deliverable per prospect → cold sequence → paused campaign → WhatsApp summary → one-tap activate.
- **Orchestrate ($2,500 setup + $1,997/mo) — Station 3.** Same loop, unthrottled (nightly 10pm-6am, multi-niche, 500-2000 prospects/night) PLUS four paired agents (Research, Strategy, Marketing, Editor) reviewing each other. Sovereign vault on Paperclip. Chat-log → tuning loop.

Tiers are stations on a graduation path, not features: rented harness → owned files → fully sovereign.

---

## Dual Surface

The client never opens a terminal.

- **WhatsApp (daily push)** — context-aware AI chat, voice notes, morning briefs, quick approvals, file delivery. Reads `.codify/` before replying.
- **Read-only web portal (weekly pull)** — `codify.build/vault`. Reads the live vault and shows everything — org, goals, queue, costs — but changes nothing. The one action it mirrors from WhatsApp is approve/activate.

The architect (or, at Orchestrate, the autonomous agent team) operates the CLI/skills on the client's behalf. The technical ~10% optionally drive directly via VS Code.

---

## Architect-Operated

Codify skills are run by the architect on behalf of the client. The client interacts through WhatsApp or the web workspace — never the terminal.

The architect's job is **harness design**: extract the client's expertise into `.codify/`, tune agents based on operator-queue marks, ship outputs that sound like the client.

---

## The Compound Loop

The vault gets smarter because:

1. Decisions and research are captured continuously.
2. Those files cross-reference the four core files in `.codify/`.
3. Every skill reads `.codify/` before generating.
4. Every agent run logs to `operator-queue/` with goal and cost.
5. The Editor agent reviews marks and proposes diffs to `.codify/agents/<id>.md`.
6. Outputs improve because **context compounds** and agents tune from real feedback.

Push-only jobs emit. Closed loops with synthesis (crystallize step → question, not summary) compound. Every cadence needs a bookend.

---

## Why Context Beats Prompts

Better prompts hit a ceiling. Better context doesn't.

Prompt engineering tunes the question. Context engineering changes what the model knows. The four `.codify/` files give every skill the same source of truth — voice, audience, offer, soul — so outputs sound like the client instead of generic AI slop.

This is why `.codify/` is gravity and the agents are velocity. Velocity without gravity scatters. Gravity without velocity stalls. The loop runs both.

---

## When Stuck

If the architect is lost, ask one question:

> "Are you trying to figure something out, generate output, or close out?"

- **Figure out** → `/co-think`
- **Generate** → `/co-ad`, `/co-email`, `/co-content`, `/co-site`, `/co-proposal`, `/co-pitch`, `/co-snapshot`
- **Close out** → `/co-end`
- **Check vault health** → `/co-audit` or `/co-status`

If they don't know what they want, start with `/co-brief` — it surfaces the day's open threads.

---

## Principles

- **Explain *why*, not just steps.**
- **End with a next action.** Suggest a specific `/co-*` skill.
- **Beginner-friendly.** Many architects are new to terminals and version control. Use plain language.
- **Honest about gaps.** Codify is evolving. If something is still being built, say so.

---

## Tone

Match `.codify/voice.md`. Direct. Practitioner. No hype.
