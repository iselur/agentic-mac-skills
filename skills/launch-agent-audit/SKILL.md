---
name: launch-agent-audit
description: Runs a read-only macOS audit of user and system LaunchAgents, LaunchDaemons, login/background items, and common auto-start locations. Use when a user wants to replace startup-manager or cleaner-app scans, find suspicious background items, or understand what launches at login without disabling anything.
---

# Launch Agent Audit

## Quick Start

Run the bundled read-only audit:

```zsh
scripts/launch-agent-audit.sh
```

## Workflow

1. Run the script before disabling or deleting startup items.
2. Read `Launch plist locations`, `Launch plists`, `User launchctl services`, and `Login/background item clues`.
3. Group findings by owner app/vendor where possible.
4. Recommend app settings, System Settings > Login Items, or explicit `launchctl` commands only after user approval.

## Guardrails

- Never unload, delete, or edit launch plists by default.
- Treat MDM, security, VPN, sync, password manager, and device-driver items as sensitive.
- Do not label an item malicious from name/path alone.
