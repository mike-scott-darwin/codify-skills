---
name: co-ghl
description: "Drive a client's GoHighLevel sub-account from the vault — push researched prospects into the CRM as contacts + pipeline opportunities, import approved email drafts as templates, enroll contacts into the operator's EXISTING GHL workflows (the API cannot create workflows), and sync pipeline status back into the vault. The CRM/pipeline counterpart to /co-publish (which handles social/blog/SMS/email). Use when: user types /co-ghl, or wants the loop's output to land in GoHighLevel. Modes: status, push-prospects, import-email, load-sequence, sync. Reads core/.ghl-location; agency GHL_API_KEY from env."
loops: [publish]
---

# /co-ghl — Drive the client's GoHighLevel CRM

Codify generates the work in the client's voice; `/co-ghl` lands it in their **GoHighLevel sub-account** — the CRM, the pipeline, the workflows. `/co-publish` covers social/blog/SMS/email *content*; this skill covers the *CRM surface*: contacts, opportunities, and sequence loading.

See [`integrations/gohighlevel.md`](../../integrations/gohighlevel.md) for the model. **One agency account, one Location per client.**

## Preflight (every mode)

1. **Resolve the Location.** Read `core/.ghl-location` for this client's Location ID. **If it's missing, stop** — never write into a guessed/unset Location. Capture it via `/co-setup` (step 3.5) or `integrations/gohighlevel.md`.
2. **Confirm auth.** Agency `GHL_API_KEY` must be set in `~/.codify/.env`. If absent, stop and say which env var to set.
3. **Tier + budget gate.** GHL distribution is Codify-tier or above (`/co-gate`). Honor the cost breaker before bulk writes.
4. **Confirm before bulk writes.** Any mode that creates/updates more than a handful of records shows a count and asks once: *"Push N records into <Location>? [y/N]."*

## Usage

```
/co-ghl status                    → verify connection; list pipelines, stages, calendars
/co-ghl push-prospects [pipeline] → loop's researched prospects → contacts + opportunities
/co-ghl import-email <file>       → approved email draft → GHL email template (DRAFT)
/co-ghl load-sequence <file>      → approved sequence → GHL workflow/campaign, PAUSED
/co-ghl sync                      → pull pipeline/opportunity status back into the vault
```

---

## Mode: status

Verify the client is wired and show the operator what they're working with — so pushes target real stages, not guesses.

- Resolve Location; confirm auth.
- `mcp__gohighlevel__get_pipelines` → list pipelines + stage names/ids.
- `mcp__gohighlevel__get_calendars` (optional) → bookable calendars.
- Report: Location id, pipelines & stages, calendars, and whether `push-prospects`/`load-sequence` have what they need.

**Exit:** "GHL connected for <client> (Location <id>). Pipelines: <names>. Ready to push."

---

## Mode: push-prospects

Turn the loop's researched prospects into CRM records the client can work.

**Source:** the current round's prospects — `campaigns/nightly/<date>/<slug>/research.md` (or `briefs/`). **Only push prospects whose deliverable passed the editor** (`/co-edit` 👍/✅) — never load unreviewed or 👎 work into a client's CRM.

**For each prospect:**
1. **Upsert the contact** — `mcp__gohighlevel__upsert_contact` (upsert, not create, so re-runs don't duplicate) with `locationId`, name, email/phone **from research only** (never invented — `GUARDRAILS.md` §2), and a source tag like `codify-<date>`.
2. **Create the opportunity** — `mcp__gohighlevel__create_opportunity` in the chosen `[pipeline]` (default: first pipeline from `status`), at the first/"New" stage, named for the prospect, linked to the contact, with the deliverable URL/path in the notes.
3. **Tag** for traceability: `codify`, the niche, the round date.

Log one operator-queue entry (`agent_id: co-ghl`, the count, the Location, the pipeline). Report: *"Pushed N contacts + N opportunities into <pipeline> for <client>."*

> **CRM writes only — no send.** Creating contacts/opportunities does not message anyone. Outreach is `load-sequence` (paused) + client activation.

---

## Mode: import-email

Run email **through GHL**, not Gmail: take an approved email draft and import it into the client's Location as a **draft email template**. The client reviews and sends from their own GHL — Codify never sends. This is the default email path for a GHL-run client (their list, their sender, their consent).

1. **Source:** an approved email — a `/co-email` output, a `/co-write` pitch, or a sequence step file.
2. **Confirm it passed `/co-edit`** (claims sweep + voice). If not, refuse and route to `/co-edit`. Never import unreviewed or 👎 copy into a client's GHL.
3. **Create the template (draft, not a send):**
   - `mcp__gohighlevel__create_email_template` with `locationId` (from `core/.ghl-location`), the subject, and the body (HTML + text). Name it for traceability: `Codify — <topic> — <date>`.
   - For a multi-step sequence, import each step as its own template (`day-0`, `+3d`, `+9d`) so the client can stage them in a GHL campaign.
4. **Do not send and do not schedule.** No `send_email`, no scheduled campaign. The output is a draft template sitting in the client's GHL, ready for *them* to send.

Log one operator-queue entry (count, Location). Report: *"Imported N email drafts into <client>'s GHL as templates — drafts only, nothing sent. The client reviews and sends from GHL."*

> **Why import, not send:** `mcp__gohighlevel__send_email` *sends*. For a GHL-run client the send belongs to them — their list, their consent, their sender reputation (`GUARDRAILS.md` §1). Import the draft; let the client fire it. Use a direct send only when the client has explicitly asked you to send on their behalf, to a list they own.

---

## Mode: load-sequence — *enroll into an existing GHL workflow*

> **Capability boundary (GHL MCP):** Codify **cannot create or build a GHL workflow** — the API has no `create_workflow`. It can only **enroll contacts into a workflow the operator already built** in GHL (`add_contact_to_workflow`). Build the automation once in GHL's UI; this mode just adds the round's contacts to it.

1. Take the sequence file (an approved `/co-sequence` / `/co-activate` output) — its email steps go in via `/co-ghl import-email` as draft templates; this mode handles **enrollment**.
2. Confirm it passed `/co-edit`. If not, refuse and route to `/co-edit`.
3. Resolve the **existing** workflow: ask the operator which GHL workflow to enroll into (`mcp__gohighlevel__ghl_get_workflows` to list them). If none exists, stop — tell the operator to build the workflow in GHL first; Codify can't author it.
4. **Mind auto-execution.** Enrolling a contact into an *active* workflow starts it immediately. To honor "nothing sends by itself" (`GUARDRAILS.md` §1), enroll **only** into a workflow the operator has designed to wait for client approval (or one kept in draft). Default safer move: skip enrollment, and let `/co-ghl push-prospects` tag the contacts so the client enrolls them in GHL when ready. Confirm with the operator before enrolling into any live workflow.
5. `mcp__gohighlevel__add_contact_to_workflow` per contact; report: *"Enrolled N contacts into <existing workflow> for <client>."*

The send still belongs to the client: they own the list, the consent, the workflow design, and the activation. You enrolled contacts into their automation; you did not build it or fire it.

---

## Mode: sync

Pull real pipeline movement back into the vault so the morning brief reflects reality, not last night's guess.

- `mcp__gohighlevel__search_opportunities` (filter by `locationId`, the `codify` tag) → current stage per opportunity.
- Write a snapshot to `campaigns/<date>-ghl-pipeline.md` (or update the round folder): per prospect → stage, last activity.
- Surface deltas for `/co-brief`: who advanced, who went cold, what needs a nudge.

**Exit:** "Synced N opportunities. M advanced since last sync; K stalled — flagged for the brief."

---

## What this skill does NOT do

- It does **not** write into an unset or guessed Location — `core/.ghl-location` is required.
- It does **not** send or enable anything — sequences load **paused**; activation is the client's.
- It does **not** invent contact data — names, emails, phones come from research, never fabricated (`GUARDRAILS.md` §2).
- It does **not** manage deliverability, sender domains, or list consent — those live in the client's GHL and are the client's (`GUARDRAILS.md` §1).
- It does **not** put `GHL_API_KEY` anywhere but env — never a vault, never a prompt (Rule 7).

## See also

- `integrations/gohighlevel.md` — the model, per-client wiring, capability map
- `/co-publish`, `/co-campaign` — content distribution (social/blog/SMS/email)
- `/co-loop`, `/co-sequence`, `/co-activate` — where the prospects + sequences come from
- `GUARDRAILS.md` §1 (never auto-sends), §2 (no fabrication), §5 (secrets/sovereignty)
