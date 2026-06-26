---
name: co-deploy
description: "End-of-session GitHub ritual: check status, confirm files are in the right place, log decisions, update last-updated stamps, then commit and push the vault. The hygiene ritual that turns local notes into version history and closes out a work session cleanly."
---

# /co-deploy — Ship Your Vault to GitHub

Saves the current state of your vault to your private GitHub repo. This is how your expertise becomes version history — every change you make gets a timestamp, a message, and a permanent record.

## When to Use

- End of a work session.
- Right after making a decision worth preserving.
- Before stepping away from a long chat.
- Any time you want a clean "this is where we are right now" checkpoint.

## Procedure

### 1. Status Check

Run `git status` and `git log --oneline -5`. Show the user:

```
Branch: [current branch]
Uncommitted files: [count] ([list if <10])
Last 5 commits:
  [hash] [message]
  ...
```

If there are no changes, tell the user cleanly: "Nothing to deploy — your vault is already up to date."

### 2. Confirm What's Going Out

If there are uncommitted changes, show them the scope before committing. Group files by folder:

```
Ready to commit:
- decisions/ (2 new files)
- core/ (1 updated file)
- campaigns/ (3 new files)

Proceed? (yes / review / cancel)
```

- **yes** → continue to step 3
- **review** → show `git diff --stat` and ask again
- **cancel** → stop, leave things unchanged

### 3. Write a Commit Message

Prefix commit messages based on the change:
- `[add]` — new files
- `[update]` — edits to existing files
- `[fix]` — corrections
- `[remove]` — deletions

Keep messages short (one line, under 70 chars) and describe the *why* not the *what* where possible. Examples:
- `[add] Voice memo decision — why we moved from Otter to local Whisper`
- `[update] Audience file — added new avatar after Jeff call`

If there are multiple unrelated changes, commit them as separate commits rather than lumping them together.

### 4. Commit and Push

Run:
```bash
git add .
git commit -m "[prefix] [message]"
git push
```

Report the commit hash and a one-line summary back to the user:

```
Deployed: [hash]
[message]

Your vault is now saved to GitHub. View it here: [github.com/user/repo]
```

### 5. Verify

Run `git log origin/main -1 --oneline` (or the current branch) to confirm the push landed. If it didn't, troubleshoot:
- Branch tracking missing → `git push -u origin [branch]`
- Auth failure → tell the user to check their GitHub token
- Conflict → pull first, then retry

## What This Skill Does NOT Do

- It does NOT merge to main on its own. If the user is on a feature branch and wants to ship to main, they should open a PR or explicitly ask.
- It does NOT force-push. If there's a conflict, stop and ask.
- It does NOT touch other repos. This skill is scoped to the current vault.

## Why This Matters

GitHub is your memory system. Every file change creates a permanent record — who changed what, when, and why. The longer you use the vault, the richer that history gets. Running `/co-deploy` regularly means your vault tells the story of your business over time. Skip deploys and you lose that story.
