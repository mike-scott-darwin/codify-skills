# Codify — Getting Started

A plain-language quickstart for running Codify for your clients. Takes you from
"never opened this" to "ran a full round of outreach for a client." No technical
background needed — you type a few short commands and answer questions in plain
words.

**The one idea:** you add the Codify commands (they all start with `/co-`) to
your computer once, and every client gets their own private folder — a **vault**
— that holds how they sound, who they sell to, and what they offer. Every command
reads that folder first, so the work always sounds like *that* client.

---

## Part 1 — Set up once (do this one time, ever)

**1. Install Claude Code.** Open Terminal and run:
```
npm install -g @anthropic-ai/claude-code
```
*If you see `npm: command not found`:* install Node from https://nodejs.org (the
green **LTS** button), then run the line again.

**2. Log in (GitHub + Claude).**
```
gh auth login        # choose HTTPS → "Login with a web browser"
claude               # first run prints a sign-in link — click it, then close it
```
*If you see `gh: command not found`:* run `brew install gh` first.

**3. Add every `/co-` command — one command.**
```
git clone https://github.com/mike-scott-darwin/codify-skills.git ~/.claude/skills/codify
```
That's it — the commands are now on your computer, in every Claude Code project
and the Conductor skills dropdown.

> **Using Conductor?** Fully quit it (`⌘Q`) and reopen so it picks up the commands.
>
> **Update anytime:** `cd ~/.claude/skills/codify && git pull`

**Check it worked.** Type `claude` in any folder, then `/co-help`. If it lists a
bunch of `/co-` commands, you're set ✅. In Conductor, open any workspace and look
at the skills dropdown.

---

## Part 2 — Run a client

**1. Create the client.** In Claude, run and answer the two questions:
```
/co-setup
```
This makes the client's private GitHub vault, sets up the folders, and starts
capturing how they sound. (Their commands ride inside that vault too — same plain
`/co-`, that's expected.)

**2. Open the client's folder and start Claude there**, then run the round:
```
/co-start          # shows where things stand + the best next move
/co-extract        # (first time) capture the client's voice, audience, offer
/co-loop           # research → write → sequence → stage → editor review
```
`/co-loop` produces a full personalized outreach bundle — prospects researched,
deliverables written in the client's voice, follow-ups staged, an editor's review.

**3. Review and approve.** Read what came back. Nothing sends on its own — you
decide what goes out.

**4. Save.**
```
/co-deploy         # commits + backs up the client's vault to GitHub
```

That's a full round. Repeat `/co-start → /co-loop → /co-deploy` whenever you want
another.

---

## If you get stuck

| What happened | What to do |
|---|---|
| `/co` shows nothing, fresh machine | You skipped Part 1 → step 3, or haven't restarted. Run the `git clone` line, then quit + reopen (Claude, or Conductor with `⌘Q`). |
| `already exists and is not an empty directory` on the clone | Already installed. To update instead: `cd ~/.claude/skills/codify && git pull`. |
| Works in Terminal but not the Conductor dropdown | Fully quit Conductor (`⌘Q`) and reopen — it reads commands at startup. |
| `/co` shows nothing in a client folder | Quit Claude and reopen it **in that folder**. In Conductor, start a new workspace on the vault. |
| You don't know what to type next | `/co-help` and ask in plain words. |
| A command errors | `/co-doctor` — finds and fixes most problems automatically. |

---

## Updating later

Get the newest commands anytime:
```
cd ~/.claude/skills/codify && git pull
```

Inside a client's vault, `/co-update` refreshes that vault's copy.
