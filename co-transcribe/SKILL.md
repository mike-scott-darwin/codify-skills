---
name: co-transcribe
description: "Pull a clean transcript from a YouTube video, playlist, or channel into research/transcripts/ — the raw material /co-think and /co-research mine. Use when the architect has a video/podcast link to capture."
---

# /co-transcribe — Turn a Video Into Mineable Text

Downloads the transcript of any YouTube video (or a whole playlist/channel) and
saves it as plain text in the vault, where `/co-think` and `/co-research` can
mine it for angles, proof, objections, and voice. The "get the source into the
vault" step that the research skills assume you've already done.

This skill **fetches and files** — it does not analyze. Once a transcript lands,
hand off to `/co-think mine` or `/co-research topic` to pull insight from it.

## Usage

```
/co-transcribe [url]              → One video — fetch + file its transcript
/co-transcribe playlist [url]     → Every video in a playlist
/co-transcribe channel [url]      → Recent videos from a channel (ask how many)
```

## Prerequisite

This uses `yt-dlp`. Check it's installed; if not, install it:

```
command -v yt-dlp >/dev/null || brew install yt-dlp   # or: pip install -U yt-dlp
```

If neither `brew` nor `pip` is available, tell the architect and stop — don't
guess at another fetch method.

## What to Do

1. **Fetch the subtitles** (no video download). Prefer human captions, fall back
   to auto-generated, convert to SRT, write into `research/transcripts/`:

   ```
   mkdir -p research/transcripts
   yt-dlp --skip-download --write-subs --write-auto-subs \
     --sub-langs "en.*" --convert-subs srt \
     -o "research/transcripts/%(title)s [%(id)s].%(ext)s" "URL"
   ```

   For `playlist`/`channel`, pass the playlist/channel URL; add
   `--playlist-end N` when the architect caps how many.

2. **Clean each `.srt` into readable prose.** Strip the sequence numbers,
   timestamps, and blank lines so it greps cleanly and feeds the research skills.
   Save the cleaned version as `research/transcripts/<slug>.md` with frontmatter,
   then remove the raw `.srt`:

   ```markdown
   ---
   type: research
   status: active
   source: <youtube-url>
   title: <video title>
   date: YYYY-MM-DD
   last-updated: YYYY-MM-DD HH:MM
   ---

   # Transcript — <video title>

   <cleaned text>
   ```

3. **Report** what landed: title(s), file path(s), rough word count. Do **not**
   summarize or analyze here.

## Before You Finish

- If subtitles don't exist for a video (no captions at all), say so plainly and
  skip it — never fabricate a transcript.
- Keep transcripts in `research/transcripts/` so they don't clutter the main
  `research/` index but are still inside the substrate.

## Hand Off

Point the architect at the next step:
- **Mine it for the business** → `/co-think mine` (pull angles/proof/objections into `.codify/`)
- **One-off research question** → `/co-research topic <topic>`
- **Repurpose into content** → `/co-organic repurpose`

A transcript is input, not a decision — it compounds only once `/co-think` lifts
what matters out of it and into the core files.
