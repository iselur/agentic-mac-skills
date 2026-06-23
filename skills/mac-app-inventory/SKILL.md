---
name: mac-app-inventory
description: Builds a read-only inventory of installed Mac apps, app bundle sizes, versions, bundle identifiers, and large app-support/cache/container folders. Use when a user wants to audit installed apps, find app-related disk usage, prepare manual uninstalls, or replace basic app-manager/uninstaller scans.
---

# Mac App Inventory

## Quick Start

Run the bundled inventory:

```zsh
scripts/mac-app-inventory.sh
```

Show more rows:

```zsh
scripts/mac-app-inventory.sh --top 50
```

## Workflow

1. Run the script and read:
   - `Largest app bundles`
   - `App metadata`
   - `Large app-support folders`
   - `Large cache/container folders`
2. Separate app bundle size from app data size. A small app can own a huge cache or support folder.
3. For cleanup, recommend the app’s own settings, official uninstaller, or normal Finder uninstall first.
4. Only propose removing support/cache leftovers after confirming the app is uninstalled or the user accepts losing local state.

## Guardrails

- Never delete apps or support folders by default.
- Do not remove security, VPN, MDM, endpoint protection, browser profile, password manager, or sync-agent data casually.
- Treat `/System/Applications` as Apple-owned and not a cleanup target.
- If package receipts or launch agents are relevant, inspect them separately before recommending removal.
