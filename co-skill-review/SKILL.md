---
name: co-skill-review
description: "Composable sub-skill. Runs dial-gated Seven Sweeps + auxiliary gates against a brief or copy draft. Returns synthesized P1/P2/P3 findings to the caller. Called by /co-site, /co-ad, /co-email, /co-content at pre-lock and pre-publish moments. Not a standalone operator skill — operators use /codify-review for ad-hoc reviews; this is the programmatic version."
---

# /co-skill-review — Composable Dial-Gated Review

Composable sub-skill. Other Codify skills call this at pre-lock and pre-publish to get structured P1/P2/P3 findings before shipping copy.

**Not the operator-facing skill.** Operators run ad-hoc reviews via `/codify-review`. This is the programmatic version that other skills invoke.

---

## Inputs

The caller passes:

- **Artifact** — path or pasted text of the brief / copy draft under review
- **Dial** — `convert | story | brand` (caller picks based on output kind)
- **Optional archetype tag** — for archetype-fidelity gate
- **Optional `do_not_state` list** — from the brief, for archetype check

Dial defaults if unspecified:

| Output kind | Default dial |
|---|---|
| Ad, email, sales page, landing | `convert` |
| VSL, long-form video, podcast intro | `story` |
| Organic content, wiki note, about page | `brand` |

---

## Outputs

A single structured report:

```json
{
  "ok": false,
  "dial": "convert",
  "sweeps_run": [1, 2, 3, 4, 5, 6, 7],
  "findings": [
    {"sweep": "Specificity", "priority": "P1", "line": 12, "note": "..."},
    {"sweep": "AI-Tells", "priority": "P2", "line": 34, "note": "..."}
  ],
  "panel_score": 7.2,
  "blocking": ["specificity", "ai-tells"]
}
```

- `ok: false` means at least one P1 finding exists. Caller should not ship without addressing.
- `blocking` lists the gates that produced P1s — caller surfaces these to the architect first.

---

## Flow

### 1. Pre-Flight

Confirm required files exist:

- `.codify/voice.md` — required (voice-fidelity gate)
- `.codify/audience.md` — required for Expert Panel on `convert` dial
- `.codify/offer.md` — required if reviewing offer-tied copy

If any required file is missing or `status: draft`: return immediately with:

```json
{"ok": false, "blocking": ["reference-substrate"], "note": "Cannot review against thin reference. Run /co-extract first."}
```

### 2. Pick Sweeps (Dial-Gated)

| Dial | Sweeps run |
|---|---|
| `convert` | 1, 2, 3, 4, 5, 6, 7 + Expert Panel |
| `story` | 1, 2, 3, 5, 6 |
| `brand` | 1, 2, 6 |

The Seven Sweeps:

1. **Specificity** — concrete numbers, names, mechanisms beat generic claims
2. **Audience-fit** — language matches `.codify/audience.md` voice-of-customer
3. **Proof presence** — claims backed by testimonials, numbers, mechanisms
4. **Objection-handling** — top 3 objections from `.codify/audience.md` addressed
5. **Story arc** — for `story` dial, narrative tension + resolution
6. **Voice-fidelity** — tone, vocabulary, cadence match `.codify/voice.md`
7. **CTA clarity** — single specific action, not "learn more" generics

### 3. Spawn Foreground Subagents in Parallel

One subagent per active sweep. Each gets the artifact + the relevant `.codify/` file(s) + the sweep's specific evaluation criteria. Each returns short P1/P2/P3 findings with line references.

**Subagents MUST be foreground.** Background writes silently fail; findings need to come back in the response, not as written files.

### 4. Run Auxiliary Gates (Parallel)

| Gate | What it checks |
|---|---|
| **De-AI'd** | No AI tells (`dive into`, `unlock`, `revolutionary`, `game-changer`, `at the end of the day`, `that being said`, etc.) |
| **Voice-fidelity** | Banned words from `.codify/voice.md` absent; required vocabulary present |
| **Archetype-fidelity** | If archetype tag passed, copy doesn't state the `do_not_state` items |

### 5. Expert Panel (Convert Dial Only)

For `convert` dial, spawn 3-5 personas drawn from `.codify/audience.md`. Each persona reads the copy and rates:

- Would I click / read past the hook? (1-10)
- Where did I lose interest? (line ref)
- What objection wasn't addressed? (line ref)

Average score becomes `panel_score`. Personas with score <6 produce P1 findings.

### 6. Synthesize

Aggregate all subagent findings into one report grouped by sweep, P-priority, line. Sort blocking gates (any sweep with P1) into the `blocking` array.

### 7. Return to Caller

Caller surfaces findings to the architect. If addressing, caller re-invokes `/co-skill-review` on the revised artifact for affected sweeps only.

---

## Operator-Defined Gates

If `.codify/review/` exists with custom `.md` files, each adds a custom sweep (compliance check, on-brand-tone, industry-specific gates, etc.). Each file is a prompt for one review subagent. Picked up automatically alongside defaults.

---

## When NOT to Use

- Mechanical outputs (status reports, file lists, checklists) — no review needed
- Pre-locked briefs that the architect is already iterating on — review burns tokens; let the iteration loop finish
- One-off internal notes — only review work that will ship externally

---

## Caller Examples

**`/co-site` Lander Flow:**

> Calls `/co-skill-review` at Step 4 (brief lock) with dial=`brand` to catch substrate issues, then again at Step 7 (pre-publish) with dial=`convert` to catch ship-blockers.

**`/co-ad`:**

> Calls `/co-skill-review` with dial=`convert` after generating ad copy. P1 findings block the architect from sending to the test queue.

**`/co-email`:**

> Calls `/co-skill-review` with dial=`convert` for cold outreach, `story` for warm nurture sequences.

---

## Provenance

Each review run's findings include:

```yaml
reviewer: co-skill-review
artifact: [path or hash]
dial: convert
reviewed_at: [iso timestamp]
sweeps_active: [1, 2, 3, 4, 5, 6, 7]
auxiliary_gates: [de-ai, voice-fidelity, archetype-fidelity]
panel_personas: 4
```

---

## Differentiation from `/codify-review`

| | `/codify-review` | `/co-skill-review` |
|---|---|---|
| Audience | Operator (ad-hoc) | Other skills (programmatic) |
| Invocation | Manual, by architect | Called inside another skill's flow |
| Output | Conversational report | Structured JSON to caller |
| Triggers | "review this copy", "is this good?" | Pre-lock / pre-publish moments in `/co-site`, `/co-ad`, etc. |

Both run the same underlying sweeps and use the same `.codify/` substrate.
