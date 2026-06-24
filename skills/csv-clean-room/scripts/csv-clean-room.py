#!/usr/bin/env python3
import argparse
import csv
from collections import Counter
from pathlib import Path
import sys


def detect_delimiter(path: Path) -> str:
    sample = path.read_text(encoding="utf-8-sig", errors="replace")[:65536]
    try:
        return csv.Sniffer().sniff(sample).delimiter
    except csv.Error:
        return ","


def read_rows(path: Path, delimiter: str) -> list[list[str]]:
    with path.open("r", encoding="utf-8-sig", errors="replace", newline="") as f:
        return list(csv.reader(f, delimiter=delimiter))


def profile(rows: list[list[str]], path: Path, delimiter: str) -> dict[str, object]:
    header = rows[0] if rows else []
    body = rows[1:] if rows else []
    width = max((len(r) for r in rows), default=0)
    blank_rows = sum(1 for r in body if not any(c.strip() for c in r))
    duplicate_headers = [k for k, v in Counter(h.strip() for h in header if h.strip()).items() if v > 1]
    empty_cols = []
    for idx in range(width):
        values = [(r[idx] if idx < len(r) else "").strip() for r in body]
        if values and not any(values):
            empty_cols.append(idx + 1)
    return {
        "path": str(path),
        "delimiter": repr(delimiter),
        "rows_including_header": len(rows),
        "columns_max": width,
        "header_count": len(header),
        "blank_body_rows": blank_rows,
        "duplicate_headers": duplicate_headers,
        "empty_column_numbers": empty_cols,
    }


def clean_rows(rows: list[list[str]]) -> list[list[str]]:
    cleaned = []
    for row in rows:
        trimmed = [cell.strip() for cell in row]
        if any(trimmed):
            cleaned.append(trimmed)
    return cleaned


def main() -> int:
    parser = argparse.ArgumentParser(description="Profile and optionally clean a CSV without modifying the original.")
    parser.add_argument("csv_path")
    parser.add_argument("--write-clean", action="store_true", help="Write a cleaned copy.")
    parser.add_argument("--out", help="Output CSV path for --write-clean.")
    args = parser.parse_args()

    path = Path(args.csv_path).expanduser()
    if not path.exists():
        print(f"missing: {path}", file=sys.stderr)
        return 2
    if args.write_clean and not args.out:
        print("--out is required with --write-clean", file=sys.stderr)
        return 2

    delimiter = detect_delimiter(path)
    rows = read_rows(path, delimiter)
    report = profile(rows, path, delimiter)

    print("## CSV profile")
    for key, value in report.items():
        print(f"{key}: {value}")

    if args.write_clean:
        out = Path(args.out).expanduser()
        out.parent.mkdir(parents=True, exist_ok=True)
        cleaned = clean_rows(rows)
        with out.open("w", encoding="utf-8", newline="") as f:
            csv.writer(f, lineterminator="\n").writerows(cleaned)
        print("\n## Wrote clean copy")
        print(out)
        print(f"rows_written: {len(cleaned)}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
