---
name: csv-clean-room
description: Profiles CSV files and optionally writes normalized clean copies without modifying originals, including delimiter detection, row/column counts, empty-column detection, duplicate header detection, whitespace trimming, and blank-row removal. Use when a user wants to replace simple spreadsheet cleanup apps or prepare CSV data for analysis.
---

# CSV Clean Room

## Quick Start

Profile a CSV without writing anything:

```zsh
scripts/csv-clean-room.py data.csv
```

Write a cleaned copy:

```zsh
scripts/csv-clean-room.py --write-clean --out cleaned.csv data.csv
```

## Workflow

1. Profile first and inspect delimiter, row count, columns, blank rows, empty columns, and duplicate headers.
2. Only write a cleaned copy when requested.
3. Keep originals untouched.
4. Explain every transformation applied.

## Cleaning Behavior

With `--write-clean`, the script:

- trims leading/trailing whitespace in cells
- drops fully blank rows
- preserves column order
- writes UTF-8 CSV with normalized newlines

It does not infer types, rewrite dates, or alter values beyond whitespace unless extended.
