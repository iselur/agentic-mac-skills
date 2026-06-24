---
name: archive-batch-tools
description: Lists, tests, and optionally extracts common local archive files such as .zip, .tar, .tgz, and .tar.gz into a separate output folder without modifying originals. Use when a user wants to replace simple archive/unzip apps, inspect archive contents safely, or batch-extract supported archives.
---

# Archive Batch Tools

## Quick Start

Inspect archives without extracting:

```zsh
scripts/archive-batch-tools.py archive.zip
```

Extract supported archives into a separate folder:

```zsh
scripts/archive-batch-tools.py --extract --out extracted archive.zip
```

## Workflow

1. Inspect first and verify archive type, member count, and suspicious paths.
2. Extract only when the user asks.
3. Always require an output directory for extraction.
4. Keep originals untouched.

## Guardrails

- Never extract into the current directory by default.
- Reject archive members with absolute paths or `..` path traversal.
- Do not claim full replacement for RAR/7z/password archives unless the environment has suitable tools.
