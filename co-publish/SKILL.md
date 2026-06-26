---
name: co-publish
description: "Push generated outputs to live channels — email, social, blog, newsletter. The last mile from context to revenue."
---

# /co-publish — Distribute Your Outputs

Takes content from `campaigns/` and pushes it to live channels. This is the skill that turns reference files into revenue.

## Usage

```
/co-publish                    → Show recent outputs, ask where to send
/co-publish [filename]         → Publish a specific output
/co-publish [filename] email   → Send as email
/co-publish [filename] social  → Post to social channels
/co-publish [filename] blog    → Publish as blog post
/co-publish [filename] all     → Distribute to all channels
```

## Procedure

### 1. Select Output

If no filename specified, list the 5 most recent files in `campaigns/`:
```
Recent outputs ready to publish:
1. 2026-03-25-ad-copy-spring-campaign.md
2. 2026-03-24-linkedin-post-context-engineering.md
3. 2026-03-23-email-sequence-onboarding.md

Which one? (or type a filename)
```

### 2. Read the Output

Read the selected file. Check its `format` frontmatter to determine the best channels:

| Format | Default channels |
|--------|-----------------|
| ad | GoHighLevel social post |
| email | Gmail or GoHighLevel email |
| post | GoHighLevel social (LinkedIn, Facebook) |
| newsletter | GoHighLevel email campaign |
| blog | GoHighLevel blog post |
| proposal | Gmail direct send |
| landing | Suggest manual — provide copy for their landing page builder |
| vsl | Suggest manual — provide script for video recording |

### 3. Check the Public/Private Boundary

The vault is private. The channel is public. Before any preview, scan the content for:

- Client or prospect names from `audience.md` or `campaigns/` that weren't approved for public use
- Internal decision rationale, pricing logic, or unreleased offers from `decisions/` or `.codify/offer.md`
- Proprietary frameworks or mechanisms from `soul.md` — principles can ship, mechanisms stay in the vault
- Anything from `operator-queue/`, agent definitions, or research files quoted verbatim

If any of these appear, strip or rewrite them and tell the architect what was removed. Never publish raw vault content that wasn't written for a public channel.

### 4. Confirm Before Sending

ALWAYS confirm before publishing. Show:
- The content that will be sent
- The channel(s) it will go to
- The recipient(s) or audience

"Ready to publish this to [channel]. Here's what will go out:

[preview]

Send it? (yes/no)"

### 5. Distribute

**Targeting GoHighLevel?** Resolve the client's sub-account first: read `core/.ghl-location` for their **Location ID** and pass it on every `mcp__gohighlevel__*` call. The agency `GHL_API_KEY` (one key, all clients) lives in `~/.codify/.env`; the Location ID is what routes to *this* client. If `core/.ghl-location` is missing and the client runs on GHL, stop and capture it (`/co-setup` step 3.5, or `integrations/gohighlevel.md`) — never publish into an unset/guessed Location.

Use the appropriate MCP tool:

**Email (Gmail):**
- Use `mcp__gmail__send_email` for direct sends
- Use `mcp__gmail__draft_email` if they want to review first

**Email (GoHighLevel):**
- **Default for a GHL-run client: import as a draft, don't send.** Route to `/co-ghl import-email` — it creates a draft email **template** in the client's Location with `mcp__gohighlevel__create_email_template`. The client sends from their own GHL (their list, their consent, their sender).
- Use `mcp__gohighlevel__send_email` (a direct send) **only** when the client has explicitly asked you to send on their behalf, to a list they own (`GUARDRAILS.md` §1).

**Social (GoHighLevel):**
- Use `mcp__gohighlevel__create_social_post` for LinkedIn, Facebook, Instagram

**Blog (GoHighLevel):**
- Use `mcp__gohighlevel__create_blog_post`

**SMS (GoHighLevel):**
- Use `mcp__gohighlevel__send_sms` for text-based outreach

### 6. Log the Distribution

After publishing, update the output file's frontmatter:

```yaml
published:
  - channel: linkedin
    date: 2026-03-25
  - channel: email
    date: 2026-03-25
```

This prevents duplicate sends and tracks what went where.

### 7. Report

"Published to [channels]. Your [output type] is live."
