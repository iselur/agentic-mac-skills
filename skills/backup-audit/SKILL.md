---
name: backup-audit
description: Runs a read-only macOS backup audit covering Time Machine state, local snapshots, backup destinations, APFS volume usage, and common oversized backup artifacts. Use when a user asks whether backups are healthy, why backup-related storage is large, or whether backup utility apps are necessary.
---

# Backup Audit

## Quick Start

Run the bundled audit:

```zsh
scripts/backup-audit.sh
```

## Workflow

1. Run the script before changing backup settings or deleting snapshots.
2. Read `Time Machine`, `Local snapshots`, `APFS overview`, and `Common backup-sized folders`.
3. Explain whether the issue is backup health, local snapshots, backup destination access, or user-created backup archives.
4. Recommend System Settings, Time Machine UI, or user-approved `tmutil` commands for changes.

## Guardrails

- Never delete local snapshots by default.
- Never disable Time Machine or remove backup destinations without explicit user approval.
- Treat sparsebundles, disk images, and backup archives as user data until proven obsolete.
