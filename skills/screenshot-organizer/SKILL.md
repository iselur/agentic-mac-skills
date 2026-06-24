---
name: screenshot-organizer
description: Audits screenshots and screen recordings across Desktop, Downloads, Pictures, or chosen folders, then optionally copies them into dated folders without moving or deleting originals. Use when a user wants to replace simple screenshot cleanup, desktop organizer, or screen-recording triage utilities.
---

# Screenshot Organizer

## Quick Start

Audit default screenshot-heavy folders:

```zsh
scripts/screenshot-organizer.py
```

Audit specific folders:

```zsh
scripts/screenshot-organizer.py ~/Desktop ~/Downloads
```

Copy matches into dated folders without touching originals:

```zsh
scripts/screenshot-organizer.py --copy --out ~/Pictures/ScreenshotArchive ~/Desktop
```

## Workflow

1. Run the audit first and review counts by month, kind, and largest files.
2. Use `--copy --out ...` only when the user wants an organized duplicate set.
3. After the user verifies copied files in Finder, they can decide what to delete manually.
4. Treat unknown image/video files conservatively; do not assume every PNG or MOV is a screenshot.

## Guardrails

- Never moves, deletes, or rewrites originals.
- Requires `--out` for copy mode.
- Copies into `YYYY-MM/` folders based on filename date when available, otherwise file modified time.
- Handles filename collisions by adding a numeric suffix.
