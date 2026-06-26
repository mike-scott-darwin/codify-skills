---
name: co-extract
description: "Run Context Extraction interviews via Claude Code. Populates Context files through conversation, and deepens existing files by asking follow-up questions based on what's already there — moving files from Draft to Compounding. Use to build context from scratch OR to enrich/cross-reference files that already exist."
---

# /co-extract — Context Extraction via Conversation

Run guided extraction interviews through the chat pane. Conversational — the client just answers questions. Answers are written directly to the Context files in `core/`.

## Usage

```
/co-extract              → Choose which file to extract
/co-extract soul         → Extract core identity (soul.md)
/co-extract audience     → Extract buyer profile (audience.md)
/co-extract offer        → Extract value proposition (offer.md)
/co-extract voice        → Extract communication style (voice.md)
/co-extract all          → Run all four in sequence
```

## Procedure

### 1. Detect Mode

Parse the user's input to determine which file to extract. If no argument, ask:

"Which file do you want to build? Soul, Audience, Offer, or Voice?"

### 2. Read Existing File

Before asking questions, read the target file in `core/`. If it already has content, acknowledge what's there and focus on gaps.

### 3. Run the Interview

Ask questions **one at a time.** Wait for the answer before asking the next one. Use natural, conversational language — not a form.

#### Context Extraction Questions (soul.md)
1. "If someone at a party asked what you do, what would you say?"
2. "What's the one thing you believe about your industry that most people get wrong?"
3. "Describe a moment when you knew your approach was different from everyone else's."
4. "What would you never do, even if it made you more money?"
5. "If you retired tomorrow, what knowledge would walk out the door with you?"
6. "What framework or process do you use that nobody else in your space talks about?"
7. "What do your best clients say about you that you'd never say about yourself?"

#### Audience Extraction Questions (audience.md)
1. "Describe the last person who bought from you. What were they struggling with?"
2. "What did they try before they found you?"
3. "What words do THEY use to describe their problem? Not your words — theirs."
4. "What's the moment they decide they need help? What triggers it?"
5. "Who should NOT buy from you? Describe the wrong fit."

#### Offer Extraction Questions (offer.md)
1. "What does your client's life look like 90 days after working with you?"
2. "What's the first thing they notice that's different?"
3. "What do you actually do in the first week together?"
4. "Why should they pay you instead of figuring it out themselves?"
5. "What guarantee or promise would you stake your reputation on?"

#### Voice Extraction Questions (voice.md)
1. "Read these three options. Which sounds most like you? A) 'Here's the data. Draw your own conclusions.' B) 'Let me walk you through what I've seen work.' C) 'I've been in the trenches. Here's what actually matters.'"
2. "What words or phrases do you say all the time in meetings?"
3. "What marketing language makes you cringe?"
4. "Paste an email or message you wrote recently that felt like 'you.'"
5. "How do you want people to feel after reading something from you?"

### 4. Write to File

After all questions are answered, write the structured output to the appropriate `core/` file. Use this format:

```markdown
---
type: context
status: draft  # extract sets draft, enrich sets active, cross-referencing sets compounding
date: [today's date]
last-updated: [today's date and time, e.g. 2026-03-26 14:30]
extracted_via: claude-code
---

# [File Name]

## [Section Heading]
[Client's answer, cleaned up but preserving their voice]

## [Next Section]
...
```

Preserve the client's exact language where possible. Clean up grammar only if it's unclear. Do NOT rewrite their voice — capture it.

### 5. Cross-Reference

After writing, scan the answer for references to other Context files:
- If they mention their audience → add `[[audience]]` link
- If they mention their offer → add `[[offer]]` link
- If they mention their voice/tone → add `[[voice]]` link

### 6. Completion Score

After extraction, report:

"Your [file] is at [depth level]. Here's what would deepen it: [specific suggestion]."

Depth levels:
- **Skeleton** — Template only, no real content
- **Draft** — Some answers, needs enrichment
- **Working** — Solid content, cross-referenced, usable by AI
- **Compounding** — Deep, linked, actively maintained
