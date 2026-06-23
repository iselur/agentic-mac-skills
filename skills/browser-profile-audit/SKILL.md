---
name: browser-profile-audit
description: Audits browser profile, cache, extension, and support-folder disk usage on macOS without reading browsing history contents or deleting data. Use when a user wants to replace browser cleaner/cache cleaner apps, find profile bloat, or understand Chrome/Safari/Firefox/Edge/Brave storage.
---

# Browser Profile Audit

## Quick Start

Run the bundled read-only audit:

```zsh
scripts/browser-profile-audit.sh
```

## Workflow

1. Run the script and inspect `Known browser paths`, `Large browser files`, and browser-specific sections.
2. Separate cache bloat from profile data such as bookmarks, sessions, extensions, history, and logged-in state.
3. Recommend browser UI cleanup first: clear cache, remove unused profiles, or uninstall extensions.
4. Only suggest filesystem deletion when the user understands they may lose sessions/profile state.

## Privacy Guardrails

- Do not open or dump History, Cookies, Login Data, or browsing databases.
- Use file sizes and paths only.
- Never delete browser profiles by default.
