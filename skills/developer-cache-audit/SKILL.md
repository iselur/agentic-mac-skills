---
name: developer-cache-audit
description: Runs a read-only macOS developer cache audit covering Xcode DerivedData, archives, simulators, Homebrew, npm, pip, cargo, Gradle, PlatformIO, and common build artifact folders. Use when a user wants to replace developer disk cleaner apps, reclaim Xcode/dev-tool space, or understand build cache usage before deleting anything.
---

# Developer Cache Audit

## Quick Start

Run the bundled audit:

```zsh
scripts/developer-cache-audit.sh
```

## Workflow

1. Run the script before deleting dev caches.
2. Read `Known developer paths`, `Large files in developer paths`, and `Project-local build folders`.
3. Separate regenerable caches from valuable artifacts:
   - usually regenerable: `DerivedData`, `node_modules`, `.next`, `dist`, `build`, package-manager caches
   - review first: Xcode archives, simulator data, local databases, firmware/build outputs
4. Recommend tool-native cleanup commands or Finder review, not blind deletion.

## Guardrails

- Never delete by default.
- Do not remove archives, simulators, signing assets, or project build outputs without explicit approval.
- Mention that caches can be rebuilt but may cost time/network.
