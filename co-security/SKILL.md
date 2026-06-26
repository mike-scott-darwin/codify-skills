---
name: co-security
description: "Run a security audit on the vault. Red team simulation, threat assessment, and hardening report the client can hold."
---

# /co-security — Vault Security Audit

Simulates threats specific to the client's industry and generates a security report they can hold, share with advisors, or use in due diligence.

## Usage

```
/co-security              → Full security audit
/co-security threats      → Threat assessment based on industry and context
/co-security red-team     → Simulate specific breach scenarios
/co-security report       → Generate a formatted security report for stakeholders
```

## Before Running

Read these files:
1. `core/soul.md` — Their industry, what they do, what IP they hold
2. `core/audience.md` — Who they serve (reveals sensitivity of client data)
3. `core/offer.md` — Their proprietary frameworks and delivery methods
4. `research/` — Any competitor research (reveals competitive exposure risk)

## Mode: Full Audit

Run all checks silently, then present findings.

### 1. Vault Infrastructure Check

Assess current setup and report:

| Check | What to verify |
|-------|---------------|
| **Storage location** | Where is the vault hosted? Local machine, GitHub, VPS? |
| **Encryption at rest** | Is the disk/repo encrypted? |
| **Encryption in transit** | Is sync happening over SSH/HTTPS? |
| **Network exposure** | Public IP or mesh-only? |
| **Access control** | Who has access? Single user or shared? |
| **Backup status** | Are there off-site encrypted backups? |
| **Jurisdiction** | Where is the data physically stored? Legal implications? |
| **Git history** | Is there a complete audit trail? |

### 1b. Credential Hygiene + Identity-from-Facts Scan

Two deterministic checks on how agents hold secrets and identity. Both report facts, never
auto-edit configs.

**Plaintext credential scan.** Grep the agent configs that touch this vault — `~/.claude.json`,
project `.mcp.json` / `.claude/settings*.json`, any `mcp` blocks — for credential-shaped values
(keys named `*token*`, `*key*`, `*secret*`, `*password*`, `Authorization`, bearer strings).
For each hit report **file + key name only, value redacted** — never echo the secret into the
report. Exclude ISO-date housekeeping fields (`last-updated`, `expires_at`, etc.) — they look
key-shaped but aren't secrets. A clean scan is a finding too: "No plaintext credentials in agent
configs." Recommend env-var / secret-store indirection (`~/.codify/.env`) for any hit.

**Identity-from-facts assertion.** Verify agents read business identity (ad account, pixel, page,
sender domain, GHL location) from **recorded facts** — `core/*.md`, `core/.ghl-location`,
`reference/core/*.md` — not from live state scraped at runtime or hardcoded into prompts. This is
CLAUDE.md rule #7 made checkable: facts live in reference files; prompts read them at runtime. Flag
any agent prompt or skill that bakes an identity value inline. A pass reads: "Identity sourced from
facts, not live state or hardcoded prompts."

### 2. IP Exposure Assessment

Based on the Context files, identify what's at risk:

- **Proprietary frameworks** — from `soul.md#Proprietary Framework`. Could a competitor replicate this if leaked?
- **Client data** — from `audience.md`. Are specific client names, deals, or strategies in the vault?
- **Strategic decisions** — from `decisions/`. Do these reveal competitive positioning?
- **Pricing and offers** — from `offer.md`. Would exposure undermine negotiating leverage?

Rate each category: **Low / Medium / High / Critical**

### 3. Threat Modeling

Based on their industry and IP, assess these threat vectors:

| Threat | Likelihood | Impact | Mitigation |
|--------|-----------|--------|------------|
| **Competitor espionage** | Based on industry competitiveness | Would leaked strategies cost revenue? | Mesh network, no public exposure |
| **Cloud provider access** | Are they on US cloud? Cloud Act applies | Provider can be compelled to hand over data | Swiss/Finnish VPS, outside Cloud Act |
| **AI provider data use** | Which AI models touch the vault? | Training data risk | Anthropic API policy: not used for training |
| **Insider threat** | Who else has access? Employees, contractors? | Could someone copy frameworks and compete? | Single-user mesh, instant revocation |
| **Device loss/theft** | Laptop stolen with vault on it | Full IP exposure | Full-disk encryption, remote wipe capability |
| **Legal/regulatory** | Industry-specific compliance | Subpoena, audit, discovery | Jurisdiction choice, audit trail, encryption |
| **Social engineering** | Phishing, pretexting | Account compromise | MFA on all access points, HITL for outbound |
| **Data loss** | Hardware failure, ransomware | Irreplaceable IP lost | Encrypted off-site backups, git distribution |

Adjust likelihood and impact based on the client's actual industry and IP sensitivity.

## Mode: Red Team

Simulate specific breach scenarios. Ask:

"What's your biggest security fear? Pick one or tell me what keeps you up at night."

Common scenarios for high-ticket clients:

### Scenario 1: "My competitor gets my strategy files"
- **Attack path:** Compromised email → GitHub access → clone repo
- **What they'd see:** Every decision, every framework, every client strategy
- **Current protection level:** [assess based on setup]
- **Recommended hardening:** [specific steps]

### Scenario 2: "A former employee takes my frameworks"
- **Attack path:** Copy vault folder to USB before departure
- **What they'd see:** Complete proprietary methodology, client list, pricing
- **Current protection level:** [assess]
- **Recommended hardening:** Single-device mesh access, encrypted vault at rest, immediate access revocation protocol

### Scenario 3: "A government agency requests my data"
- **Attack path:** Subpoena to cloud provider (US Cloud Act for US-based services)
- **What they'd access:** Everything on the provider's servers
- **Current protection level:** [assess]
- **Recommended hardening:** Swiss/Finnish VPS, zero-knowledge architecture, no US cloud dependencies

### Scenario 4: "Someone intercepts my AI conversations"
- **Attack path:** Man-in-the-middle on public WiFi, compromised API endpoint
- **What they'd see:** Raw strategy conversations, unfiltered thinking
- **Current protection level:** [assess — HTTPS by default, but coffee shop WiFi is vulnerable]
- **Recommended hardening:** Tailscale mesh (all traffic encrypted end-to-end, no public transit)

### Scenario 5: "My laptop is stolen"
- **Attack path:** Physical theft → access local vault files
- **What they'd access:** Full vault if disk unencrypted
- **Current protection level:** [assess — FileVault on Mac?]
- **Recommended hardening:** Full-disk encryption verified, strong login password, remote wipe enabled

For each scenario, output:
1. **How it would happen** — specific attack path
2. **What's exposed** — exactly which files and data
3. **Current gap** — what's missing in their setup
4. **The fix** — specific, actionable hardening step

## Mode: Report

Generate a formatted security report the client can hold, print, or share with their legal/advisory team.

### Report Structure

```markdown
# Sovereign Vault — Security Assessment

**Prepared for:** [Client name]
**Date:** [today]
**Classification:** Confidential

---

## Executive Summary
[2-3 sentences: overall security posture, top risk, top recommendation]

## Vault Overview
- Location: [where hosted]
- Jurisdiction: [legal jurisdiction]
- Encryption: [at rest + in transit status]
- Network: [public/mesh/hybrid]
- Access: [who has access]
- Backup: [status]

## IP Inventory
| Asset | Location | Sensitivity | Protection |
|-------|----------|-------------|------------|
| Proprietary frameworks | soul.md | Critical | [status] |
| Client strategies | audience.md, research/ | High | [status] |
| Pricing/offers | offer.md | Medium | [status] |
| Strategic decisions | decisions/ | High | [status] |

## Threat Assessment
[Table from threat modeling — customized to their industry]

## Red Team Results
[Scenario summaries with pass/fail/partial for each]

## Recommendations (Priority Order)
1. [Highest impact hardening step]
2. [Second priority]
3. [Third priority]

## Compliance Notes
[Any industry-specific compliance relevant to their setup]

---

*This assessment covers the security architecture of the Sovereign Vault.
It does not constitute legal advice. Consult your legal counsel for
jurisdiction-specific compliance requirements.*
```

## Save Output

Write to `campaigns/[YYYY-MM-DD]-security-assessment.md` with frontmatter:

```yaml
---
type: output
format: security-assessment
date: [today]
last-updated: [today's date and time]
classification: confidential
source_files:
  - core/soul.md
  - core/audience.md
  - core/offer.md
---
```

## Tone

- **Authoritative.** This is a security document, not a sales pitch.
- **Specific.** Name the threats, name the mitigations. No hand-waving.
- **Honest.** If something is vulnerable, say so clearly. Trust is built on honesty.
- **Actionable.** Every finding has a recommendation. No "you should consider" — say what to do.
- **No fear-mongering.** State the facts. The client is smart enough to draw conclusions.

## Orchestrate Tier Upgrade Path

After presenting the security assessment, if the client is on Codify tier:

"Your vault contains [critical/high]-sensitivity intellectual property. Right now it's protected by [current setup on GitHub Private]. Orchestrate ($2,500 setup + $1,997/mo) moves your vault to sovereign infrastructure — your VPS, Forgejo instead of GitHub, optional [Swiss/Finnish] jurisdiction, optional local models. Same architecture, no third-party hosting. Want me to walk you through what that looks like?"

Do NOT pressure. Present the facts. Let the gap speak for itself.
