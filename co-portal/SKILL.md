---
name: co-portal
description: |
  Stand up and operate a client's READ-ONLY portal on codify-app — the rich surface at codify.build (Next.js, Supabase auth, GitHub-backed vault, dashboard views over the full Build→Research→Queue→Outputs loop). The client gets a read-only window: reads the live vault, shows everything, changes nothing. The interactive sibling of /co-obsidian (operator-only). Use when:
  (1) Onboarding a new client into codify.build as a read-only viewer (connect their GitHub vault → name workspace → hand over login)
  (2) Wiring or repairing a client's GitHub vault-repo connection (read-only access)
  (3) Running codify-app locally to preview/iterate before onboarding a client
  (4) Setting a client's read-only role + tier-gated views
  (5) Handing the client their logged-in codify.build URL

  NOT a marketing/lander surface (/co-site). NOT a public wiki (/co-wiki). NOT the operator's local Obsidian view (/co-obsidian). NOT infra redeploy of the app itself (rare architect-only Vercel action — see `deploy`).

  Triggered by: /co-portal, "give the client a read-only portal", "onboard this client into codify.build read-only", "connect the client's vault to the app", "give the client their portal login".
---

# /co-portal — Read-Only Client Portal on codify-app

The client's portal is **codify-app** — the app deployed at **codify.build** (`$CODIFY_APP_DIR`) — pointed at the client's vault and constrained to **read-only**. It reads the live vault, shows everything, and **changes nothing**. This honors the dual-surface doctrine exactly: the client web surface is a *read-only operations view*, and Codify stays **operated, not self-served**.

codify-app is one multi-tenant Next.js app, already deployed on Vercel. You do **not** deploy a new app per client. Standing up a client's portal means **onboarding them as a read-only viewer and pointing the app at their vault repo**, which it reads live via the GitHub API. It is the interactive sibling of `/co-obsidian` (operator-only local view).

## Scope — read this first

- **Read-only, always.** The client can browse — never generate, edit, approve, publish, or write back to the vault. Edits happen through the CLI/skills and extraction calls. This is doctrine: *"reads the live vault, shows everything, changes nothing"* (`CLAUDE.md`, `decisions/2026-05-09-portal-vs-whatsapp-surface-split.md`), and operated-not-self-served (`decisions/2026-04-25-managed-service-shape-automate-vs-high-touch.md`).
- **codify-app is read-WRITE today — this is a prerequisite gap, not a setting.** The app requests GitHub OAuth `scope=repo` (write) and the dashboard mutates (generate, save reference, publish). There is **no read-only/viewer role yet**. A genuinely read-only client portal therefore requires a change in codify-app first (see "Read-only enforcement"). Do not hand a client a login until that enforcement is real — otherwise "read-only" is a promise the surface doesn't keep.
- **The sacred line holds.** The exec never *has* to log in to run their day — WhatsApp stays the daily action surface across tiers. The portal is for weekly review, files/charts WhatsApp can't carry, and the demo close.
- **Secrets live in codify-app, not the vault.** Supabase keys, GitHub OAuth creds, LLM keys are codify-app env config (`.env.local` / Vercel env) — never hardcode them into vault files or prompts (Rule 7).

## Read-only enforcement (two layers — both required)

A read-only portal is only real if a client cannot write even if they try. Enforce at both layers:

1. **App layer — a read-only role/flag in codify-app.** Add a viewer role (or reuse tier gating in `src/lib/tier.ts` / `hasAccess()`) that **hides and disables every write action**: generate, save/enrich reference, queue approve/reject, publish, repo writes, terminal mutations. Read views only (reference files, research, outputs history, org/goals/queue/costs).
2. **Access layer — read-only GitHub access.** The vault connection must be read-only: a fine-grained read-only token or narrowed scope, **not** `scope=repo`. So even if a write path is missed in the UI, the GitHub API rejects it. Today's OAuth (`src/app/api/auth/github/route.ts`, `scope=repo`) must be narrowed for viewer clients.

Until both exist in codify-app, this skill can `run-local` and `status`, but **`onboard` must not hand over a client login** — flag the gap to the architect instead.

## Repo + key surfaces

> Set `CODIFY_APP_DIR` to wherever you checked out your `codify-app` repo (e.g. `export CODIFY_APP_DIR=~/code/codify-app`). The paths below resolve against it.

```
$CODIFY_APP_DIR
├── src/lib/tier.ts                 ← tier gating (hasAccess, FEATURE_REQUIRED_TIER) — reuse for viewer role
├── src/app/api/auth/github/        ← OAuth (scope=repo today → must narrow to read-only for viewers)
├── src/app/api/github/             ← init/ config/ create-repo/ files/ (vault wiring)
├── src/app/dashboard/              ← views to expose read-only (files/research/outputs/queue/settings)
├── src/lib/repo-context.tsx        ← RepoProvider: loads vault files from GitHub on mount
├── .env.local | .env.production    ← Supabase + GitHub OAuth + LLM keys (NOT in vault)
└── supabase-schema*.sql            ← DB schema (RLS)
```

## Prerequisites

- codify-app checked out (above) with working env (`.env.local`: `NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_ANON_KEY`, `ANTHROPIC_API_KEY`, GitHub OAuth creds).
- **A read-only role + read-only GitHub access exist in codify-app** (see enforcement). If not, stop at `run-local`/`status` and flag.
- The client has a **GitHub vault repo** — the sovereign repo the CLI/skills operate.
- `node` + `npm` (the app uses `npm`/`next`).

## Modes

| Mode | What it does | Hands client a login? |
|---|---|---|
| `onboard` | Connect the client's vault (read-only) → name workspace → set viewer role → hand over read-only login | Yes — **only if enforcement is real** |
| `connect-repo` | Wire/repair a client's vault connection with **read-only** GitHub access | No |
| `run-local` | Operator runs codify-app locally to preview/iterate (`npm install && npm run dev`) | No |
| `configure` | Set the client's viewer role + tier-gated read views | No |
| `status` | Report a client's connected repo, role, exposed views, last sync | No |
| `deploy` | **Architect-only, rare.** Deploy/redeploy the app itself to Vercel (codify.build) | No |

Default mode is `onboard` (gated on enforcement being real).

---

## Mode: onboard

Bring a client onto codify.build as a **read-only viewer**.

0. **Gate:** confirm the read-only role + read-only GitHub access exist (see enforcement). If not, do **not** proceed — report the gap to the architect.
1. **Confirm the client's vault repo.** Same sovereign GitHub repo the CLI/skills operate.
2. **Provision the account** (Supabase email OTP) and set the **viewer role** (`configure`).
3. **Connect the vault read-only** (`connect-repo`) — read-only token/scope, not `scope=repo`.
4. **Name the workspace** (client/business name). `RepoContext` loads `.codify/` reference files from GitHub.
5. **Confirm write actions are absent.** Spot-check that generate/publish/save/approve are hidden and disabled for this role before handing over.
6. **Hand over the login** (see `share` text).

**Exit:** "Client onboarded read-only at codify.build. Their vault is connected; the dashboard reads it live and can change nothing."

---

## Mode: connect-repo

Wire or repair the client's vault connection — **read-only**.

- **Existing repo:** `POST /api/github/init` then `/api/github/config` with a read-only token; confirm `RepoContext` loads `.codify/` files.
- **Verify read-only:** `/api/github/files` returns reference files (read), and any write path fails against the read-only token.
- Never write secrets into the vault. Never connect a viewer client with `scope=repo`.

---

## Mode: run-local

```bash
cd $CODIFY_APP_DIR
# ensure .env.local has Supabase + GitHub OAuth + at least one LLM key
npm install
npm run dev      # next dev — http://localhost:3000
```

Use to preview the read-only viewer experience before any client sees it. Do not commit `.env*`.

---

## Mode: configure

| Setting | Where |
|---|---|
| Viewer role (read-only) | `src/lib/tier.ts` gating / a viewer flag — disables all writes |
| Exposed read views | Dashboard views the role may see (files/research/outputs/queue/org/goals/costs) |
| GitHub access | `connect-repo` with read-only token (re-run if it drifted to write) |

---

## Mode: status

Report for a client: connected vault repo (owner/name), role (must be viewer/read-only), exposed views, GitHub access mode (must be read-only), last sync. Read from the app's GitHub config + `user_profiles` — don't guess.

---

## Mode: deploy (architect-only, rare)

codify-app is already deployed at codify.build. Redeploy only for an app-level change (e.g. landing the read-only role), not per client.

```bash
cd $CODIFY_APP_DIR
npm run build           # verify it compiles before shipping (Rule 6)
# deploy via Vercel (git push to the production branch, or `vercel --prod`)
```

Confirm env parity on Vercel before relying on a deploy.

---

## Client handoff (the `share` text)

```
Your portal is live: https://codify.build  (sign in with your email)

It's a read-only window into the work we run for you — the reference files we
maintain in your voice, your research, and what's been published. Look as
deeply as you want; nothing here can change anything.

You never have to open it to run your day — WhatsApp still does that. This is
for when you want to look harder.
```

## What This Skill Does NOT Do

- It does **not** give the client any write ability — no generate, edit, approve, publish, or repo writes.
- It does **not** hand over a login until read-only is enforced at both the app and GitHub-access layers.
- It does **not** deploy a new app per client. One Vercel app at codify.build; clients are read-only accounts + connected repos.
- It does **not** put secrets in the vault, or make the portal mandatory-to-operate.
- It does **not** build marketing pages (`/co-site`) or a public wiki (`/co-wiki`).

## See also

- `$CODIFY_APP_DIR/CLAUDE.md` + `docs/architecture.md` — the app's own canonical docs
- `decisions/2026-05-09-portal-vs-whatsapp-surface-split.md` — read-only client surface; which artifacts require the portal
- `decisions/2026-04-25-managed-service-shape-automate-vs-high-touch.md` — operated-vs-self-served (why read-only)
- `/co-obsidian` — operator-only local sibling; `/co-wiki`, `/co-site` — other deploy surfaces
