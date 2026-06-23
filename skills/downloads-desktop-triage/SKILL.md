---
name: downloads-desktop-triage
description: Inventories Downloads and Desktop clutter on macOS without deleting anything, highlighting old installers, disk images, archives, screenshots, videos, large files, and duplicate-looking filenames. Use when a user wants to clean Downloads/Desktop, find safe manual cleanup candidates, or replace basic cleaner-app clutter scans.
---

# Downloads/Desktop Triage

## Quick Start

Run the bundled read-only inventory:

```zsh
scripts/downloads-desktop-triage.sh
```

Adjust size and row limits:

```zsh
scripts/downloads-desktop-triage.sh --min-mb 250 --top 50
```

## Workflow

1. Run the script before suggesting deletion.
2. Inspect these sections:
   - `Root sizes`
   - `Large files`
   - `Installers, disk images, archives`
   - `Screenshots and screen recordings`
   - `Duplicate-looking basenames`
3. Group findings into safe categories:
   - old installers and `.dmg` files
   - duplicate exports/downloads
   - stale archives
   - screenshots and recordings
   - documents that need human review
4. Tell the user to delete or archive manually from Finder unless they explicitly request an automated deletion command.

## Guardrails

- Never delete files by default.
- Do not assume duplicate-looking filenames are true duplicates; compare size/date/content if deletion matters.
- Do not move documents, photos, tax records, legal records, or work files without explicit user approval.
- Prefer “review these paths” over broad cleanup commands.
