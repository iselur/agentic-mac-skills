---
name: image-batch-convert
description: Plans and optionally runs safe macOS image batch conversions using built-in tools, including resizing, JPEG/PNG/HEIC conversion, and output-folder copies without modifying originals. Use when a user wants to replace simple image converter/resizer apps or batch-process local image files.
---

# Image Batch Convert

## Quick Start

Plan a conversion without writing files:

```zsh
scripts/image-batch-convert.sh --format jpeg --max-width 1600 ~/Pictures/example-folder
```

Run it into a new output directory:

```zsh
scripts/image-batch-convert.sh --execute --out ~/Desktop/converted --format jpeg --max-width 1600 ~/Pictures/example-folder
```

## Workflow

1. Run without `--execute` first and inspect the planned outputs.
2. Require `--out` for execution so originals are never modified.
3. Use `sips` for built-in macOS conversion and resizing.
4. Report skipped files and existing outputs.

## Guardrails

- Never overwrite originals.
- Never execute unless the user explicitly asks for conversion.
- Do not promise professional image editing; this skill is for format/size batch operations.
