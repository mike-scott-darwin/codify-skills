---
name: co-activate
description: "Activator. Takes each sequencer cadence and writes a single outbox payload with day-0/+3/+9 send timestamps. No LLM, no SMTP — fixture-mode dispatch only. Use when: user types /co-activate or co-start routes here."
loops: [ship]
---

# Activate

Move each sequence into the outbox with scheduled send timestamps. No LLM call. No real send.

## Inputs

Every sequence in `sequences/{today}-*.md` with a matching sequencer ticket.

If no sequences exist for today, tell the user and route to `/co-sequence`.

## Method

This skill does NOT call the model. It's a deterministic file-shape transform. Use Bash + Read + Write tools to:

1. For each sequence, compute send timestamps:
   - `day0` = now (ISO)
   - `day3` = now + 3 days
   - `day9` = now + 9 days
2. Write one outbox payload per sequence to `outbox/{YYYY-MM-DD}-{slug}.md`.
3. Write one activator ticket per outbox to `operator-queue/{YYYY-MM-DD}-activator-{NNN}.md`.

## Output: outbox file shape

Frontmatter:

```yaml
---
type: outbox
format: scheduled-dispatch
date: <YYYY-MM-DD>
last-updated: <YYYY-MM-DD HH:MM>
agent: activator
prospect: <name>
company: <company>
sequence: sequences/<source>
parent_ticket_id: <sequencer ticket id>
send_at_day0: <ISO>
send_at_day3: <ISO>
send_at_day9: <ISO>
delivery_mode: fixture
---
```

Body:

```markdown
# Outbox: <name> — <company>

> **Fixture-mode dispatch.** No SMTP or SES is wired. Real send adapter
> swaps in here behind a SendRef interface in a later release.

## Schedule

- **Day 0**  · `<day0 ISO>` — pitch
- **Day +3** · `<day3 ISO>` — bump
- **Day +9** · `<day9 ISO>` — final

## Payload

<full body of the source sequence — pitch + bump + final + deactivation conditions>
```

## Output: activator ticket

```yaml
---
agent_id: activator
started_at: <ISO>
ended_at: <ISO>
surface: cli
input: "Activate sequence for <name> at <company>"
output_file: outbox/<file>
status: completed
parent_ticket_id: <sequencer ticket id>
marks: []
---
```

Body:

```markdown
## Output

Fixture-mode dispatch — no SMTP/SES wired.

Scheduled:
- Day 0: <ISO>
- Day +3: <ISO>
- Day +9: <ISO>

Outbox file: [outbox/<file>](../outbox/<file>)
```

## When you finish

```
5 outbox payloads scheduled.

⚠ Fixture-mode only — nothing is actually sent. Wire your sender later
  (Gmail / SES / Postmark) behind the SendRef interface.

Next: /co-edit    have the editor mark every artifact for voice
      /co-end     wrap up the day with a brief
```

## Do NOT

- Do NOT call the model. This skill is pure file logic.
- Do NOT actually send email. Even if the user asks. Tell them to wire a real sender first.
- Do NOT mutate the source sequence file.
