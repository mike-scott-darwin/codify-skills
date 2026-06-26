---
name: co-skill-concept
description: "Composable sub-skill. Generates N concept variations of a site or output artifact in parallel using foreground subagents. Default 2. Architect picks one to promote. Called by /co-site, /co-ad, /co-email when a brief is locked and parallel exploration beats single-shot generation. Not a standalone operator skill — invoked by other Codify skills programmatically."
---

# /co-skill-concept — Parallel Concept Variations

Composable sub-skill. Other Codify skills call this when they have a locked brief and want N distinct concept variations side-by-side, instead of one-shot generation.

**Not a standalone operator skill.** Invoked by `/co-site`, `/co-ad`, `/co-email`, etc.

---

## Inputs

The caller passes:

- **Brief path** — locked brief in `decisions/[YYYY-MM-DD]-[slug].md`
- **Reference URLs / artifacts** — taste anchors (not templates to copy)
- **Output kind** — `site-page` (HTML), `ad` (image+copy), `email` (subject+body), `pitch` (script), `vsl` (script)
- **Variation count** — default 2, max 5
- **Output directory** — where each variation lands (e.g., `campaigns/co-site/[slug]-concept-`)

---

## Outputs

- **N variations**, each in its own subdirectory or file with `-concept-[A|B|C]` suffix
- **Comparison summary** for the architect: 1-line hook + 1-line voice variant + 1-line visual/structural choice per variation
- **Picked variation** promoted to the canonical output path; other variations archived

---

## Flow

### 1. Read the Brief

Load the brief file. Extract: promise, audience, offer, tone, sections, CTA. If the brief is missing or `status: draft`, stop and return to caller with: "Brief not locked. Lock first."

### 2. Spawn N Foreground Subagents in Parallel

Each subagent gets the same brief + reference URLs but is asked to make **different decisions** along these axes:

| Variation Axis | Example differentiation |
|---|---|
| Hero approach | direct/transformation lead vs. problem-first vs. proof-first |
| Visual register | minimal/typographic vs. dense/data-rich vs. editorial/photo-led |
| Voice variant | sharp/declarative vs. warm/conversational vs. analytical/measured |
| Structure | linear scroll vs. tabbed/sectioned vs. story-arc |

Each subagent prompt:

> "You are generating Concept [A|B|C] of [N] for a [output-kind]. Brief is attached. Reference URLs are taste anchors only — do not copy. Your distinguishing choice is **[axis + value]** — every other concept will make a different choice on this axis. Read `.codify/voice.md`, `.codify/audience.md`, `.codify/offer.md` before writing. Write the artifact to `[output-path]-concept-[letter].[ext]`. Verify the write by reading the file after. Return: file path + 3-line summary (hook / voice / structural choice)."

**Subagents MUST be foreground.** Background subagent writes are known to silently fail. Foreground only.

### 3. Validate Each Variation

After all subagents return:

- File exists on disk (re-read to confirm)
- Required structural elements present (e.g., for site-page: hero + CTA + footer)
- No AI tells in copy (`dive into`, `unlock`, `revolutionary`, etc.)
- Matches `.codify/voice.md` "never say" list

If any variation fails validation: regenerate just that one (single subagent) before showing the architect.

### 4. Present Side-by-Side

Show the architect a comparison table:

```
Concept A: [hook line] | [voice variant] | [structural choice]
Concept B: [hook line] | [voice variant] | [structural choice]
Concept C: [hook line] | [voice variant] | [structural choice]
```

Plus the file paths so the architect can open each.

### 5. Architect Picks

Architect names the winner (or asks for another round on a specific axis).

### 6. Promote + Archive

- **Promoted:** copy/rename the chosen variation to the canonical output path
- **Archived:** move other variations to `[output-dir]/concepts/` for reference

Return to caller with: `{ picked: "A", path: "[canonical-output-path]", archived: ["B", "C"] }`.

---

## Foreground Rule (Non-Negotiable)

Subagents in this skill MUST be foreground (`run_in_background: false` or omitted). Background subagent file writes are known to silently fail in current Claude Code — files appear written but don't persist. Foreground subagents return content the caller can verify on disk.

If a foreground subagent reports a write failure, it must return the **full artifact content** in its response so the caller can write it from the main conversation.

---

## When NOT to Use

- One-shot generation is fine (no need to explore alternatives) — caller should generate directly
- Brief is unclear or unlocked — fix the brief first; variations on a vague brief are wasted compute
- Output is mechanical (a status report, a checklist) — no creative variation needed
- Caller already has a locked direction — don't generate alternatives to second-guess

---

## Caller Examples

**`/co-site` Lander Flow Step 5:**

> Calls `/co-skill-concept` with brief from `decisions/[date]-site-[slug].md`, output_kind=`site-page`, N=3. Subagents generate 3 hero variations (direct / problem-first / proof-first). Architect picks. Picked concept promoted to `index.html` in site repo; others archived to `concepts/`.

**`/co-ad` for a new offer test:**

> Calls `/co-skill-concept` with brief from the ad-test decision, output_kind=`ad`, N=3. Subagents generate 3 hook+image-prompt pairs (pain-led / curiosity-led / aspiration-led). Architect picks. Picked ad promoted to live test queue.

---

## Provenance

Each variation's frontmatter records:

```yaml
---
generated_by: co-skill-concept
brief: decisions/[YYYY-MM-DD]-[slug].md
variation: A
axis: hero-approach
axis_value: direct-transformation
generated_at: [iso timestamp]
---
```

So future review can trace why each concept made the choices it did.
