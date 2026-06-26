---
name: co-import
description: "Import existing documents — proposals, emails, website copy, PDFs — and mine them into Context files. Faster than answering questions from scratch."
---

# /co-import — Mine Your Existing Documents

Instead of answering 22 questions from scratch, the client pastes or points to documents they've already written. Claude reads them and extracts Context-level insights automatically.

## Usage

```
/co-import              → Ask what they want to import
/co-import soul         → Mine documents for core identity
/co-import audience     → Mine documents for buyer insights
/co-import offer        → Mine documents for offer/value prop
/co-import voice        → Mine documents for tone and language
/co-import all          → Mine documents across all Context files
```

## Procedure

### 1. Ask for Documents

Say:
"I can build your identity files from things you've already written — proposals, emails, website copy, LinkedIn posts, even old decks. Just paste the text here, or tell me which files in your vault to read."

Accept any of these:

- **Pasted text** — client copies from Google Docs, Word, email, website, etc. and pastes into the chat
- **Vault files** — client says "read the PDF in research" or "look at my proposal in campaigns"
- **Multiple sources** — "here's my website About page and a proposal I sent last week"

If they seem unsure, prompt:
"Do you have any of these handy? A proposal you're proud of, your website About page, a LinkedIn post, an email where you explained what you do? Any of those would work."

### 2. Read and Analyze

Read everything they provide. Look for:

- **Soul signals** — beliefs, origin stories, anti-positions, proprietary frameworks
- **Audience signals** — who they're talking to, pain points, language the buyer uses
- **Offer signals** — transformations promised, deliverables, guarantees, pricing rationale
- **Voice signals** — tone, recurring phrases, anti-language, emotional register

### 3. Extract to Context Files

For each Context file that has relevant material:

1. Read the existing `core/[file].md`
2. Fill in sections that match the imported content
3. Preserve the client's exact language — do NOT rewrite their voice
4. Add `imported_from: [source description]` to the frontmatter
5. Add cross-references between Context files where relevant (`[[audience]]`, `[[offer]]`, etc.)

Write the updated file. Use this frontmatter:

```markdown
---
type: context
status: draft
date: [today's date]
last-updated: [today's date and time, e.g. 2026-03-26 14:30]
imported_from: [brief description of source documents]
extracted_via: claude-code
---
```

### 4. Show What Was Found

After importing, show a summary:

"Here's what I found in your documents:

- **Soul** — [what was extracted, or 'no signals found']
- **Audience** — [what was extracted, or 'no signals found']
- **Offer** — [what was extracted, or 'no signals found']
- **Voice** — [what was extracted, or 'no signals found']

[X] sections filled. [Y] sections still need your input."

### 5. Fill Gaps

For any sections that couldn't be filled from the documents, offer to ask the questions directly:

"There are [Y] sections I couldn't fill from your documents. Want me to ask you those questions now? It'll take about [estimated time]."

If yes, run the relevant `/co-extract` questions for just the missing sections — skip anything already populated.

## What Makes Good Import Material

| Source | What Claude Mines From It |
|--------|--------------------------|
| Proposals | Offer, transformation, deliverables, guarantees |
| Website About page | Soul, origin story, beliefs |
| LinkedIn posts | Voice, tone, signature phrases |
| Client testimonials | Audience, external perception |
| Sales emails | Audience pain points, offer framing, voice |
| Old decks/presentations | Framework, institutional knowledge |
| Case studies | Offer, audience, transformation |

## Tone

- **Encouraging.** "This is great material — I can pull a lot from this."
- **Specific.** Show them exactly what you extracted and where it went.
- **Efficient.** This should feel faster than answering questions. That's the whole point.
- **Honest.** If a document doesn't have useful signals, say so. Don't force it.

## Error Handling

| Situation | What to say |
|-----------|------------|
| Client pastes very short text | "That's a start. Do you have anything longer — a proposal or email? The more I read, the sharper your files get." |
| Document has no Soul signals | "This is useful for [audience/offer] but I didn't find much about your core beliefs. Want me to ask you a few questions about that?" |
| Client can't find documents | "No problem. Let's do it conversationally instead." Then run `/co-extract`. |
| PDF in vault can't be read | "I can see the PDF but I can't read its contents directly. Can you paste the key sections into the chat?" |
