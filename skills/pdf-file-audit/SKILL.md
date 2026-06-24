---
name: pdf-file-audit
description: Audits local PDF files by size, page-count metadata, duplicate-looking names, and optional hashes without modifying originals. Use when a user wants to replace narrow PDF utility workflows such as finding oversized PDFs, checking PDF folders, or preparing a PDF cleanup/organization report.
---

# PDF File Audit

## Quick Start

Audit PDFs under the current folder:

```zsh
scripts/pdf-file-audit.py .
```

Audit a few folders and only show PDFs above 20 MB:

```zsh
scripts/pdf-file-audit.py --min-mb 20 ~/Downloads ~/Documents
```

Include hashes for exact-duplicate analysis:

```zsh
scripts/pdf-file-audit.py --hash ~/Downloads
```

## Workflow

1. Run an audit before recommending cleanup or organization.
2. Use the largest-file and duplicate-looking-name sections to identify candidates.
3. Prefer Finder/app-level review before deleting or moving any PDF.
4. Use `--hash` only when exact duplicate detection is worth the extra disk reads.

## Guardrails

- Read-only by default.
- Does not merge, split, OCR, compress, delete, or rewrite PDFs.
- Page counts come from Spotlight metadata when available, so missing counts do not mean the PDF is broken.
- Do not claim this replaces full PDF editors such as PDFgear or Acrobat; it replaces narrow audit and triage workflows.
