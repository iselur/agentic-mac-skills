---
name: plist-defaults-audit
description: Audits macOS plist/defaults preference files by size, domain, readability, type, and top-level keys without writing changes. Use when a user wants to replace simple macOS settings inspection utilities or understand app preference files before changing defaults.
---

# Plist Defaults Audit

## Quick Start

Audit common user and system preference folders:

```zsh
scripts/plist-defaults-audit.py
```

Search for one app or domain:

```zsh
scripts/plist-defaults-audit.py --domain safari
```

Audit a specific folder:

```zsh
scripts/plist-defaults-audit.py ~/Library/Preferences
```

## Workflow

1. Run the read-only audit first.
2. Use the largest and unreadable plist sections to identify preference stores worth inspecting.
3. If changing defaults later, prefer app UI settings first, then `defaults read`, then a clearly reviewed `defaults write`.
4. Keep this skill separate from any write/reset operation.

## Guardrails

- Never writes, deletes, resets, or converts preference files.
- Reports top-level keys only; it does not dump secrets or full nested values.
- System and managed preferences can be protected by macOS permissions.
- Do not treat unreadable files as corrupt without a separate `plutil -lint` or app-specific check.
