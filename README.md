# Codify Skills

The `/co-*` skill bundle that powers Codify — the managed marketing operations
layer. Clone it into your global Claude Code skills folder and every command is
available in every project, including the Conductor skills dropdown.

These skills are operated by Codify partners on behalf of their clients. Each
client also gets their own committed copy inside their vault — this repo is the
**partner's global toolkit** and the upstream that vaults refresh from.

> 📘 **New here? Start with [GETTING-STARTED.md](GETTING-STARTED.md)** — login →
> install → run a client → verify, in plain language.

---

## Install (one time)

**1. Accept the GitHub invite.** Check your email for a collaborator invite from
`mike-scott-darwin/codify-skills` and accept it (or visit
[the invitations page](https://github.com/mike-scott-darwin/codify-skills/invitations)).

**2. Make sure GitHub is connected** (so the private clone works without SSH keys):

```bash
gh auth login        # pick HTTPS → "Login with a web browser"
```

**3. Clone the bundle into your global skills folder:**

```bash
git clone https://github.com/mike-scott-darwin/codify-skills.git ~/.claude/skills/codify
```

That's it — the skills are now global, available in every Claude Code project.

**4. If you use Conductor**, fully quit it (`⌘Q`) and reopen so it picks up the
new commands.

## Verify

Open Claude Code in any folder and type `/co-help`. If it lists the `/co-*`
commands, you're set. In Conductor, check the skills dropdown.

## Update

```bash
cd ~/.claude/skills/codify && git pull
```

(Or re-run `install.sh`, which clones-or-updates in one step.)

---

## One-command install/update

Prefer a single idempotent command that also handles updates and Conductor /
Claude Code detection:

```bash
gh api -H "Accept: application/vnd.github.raw" \
  repos/mike-scott-darwin/codify-skills/contents/install.sh | bash
```

---

Source of truth: `codify-vault-template/.claude/skills/co-*` in the private
business repo. This bundle is published automatically on every change — do not
hand-edit skills here.
