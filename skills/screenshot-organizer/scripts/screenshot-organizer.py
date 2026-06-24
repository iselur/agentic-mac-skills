#!/usr/bin/env python3
import argparse
import datetime as dt
import os
from pathlib import Path
import re
import shutil
import tempfile


DEFAULT_ROOTS = [
    Path("~/Desktop"),
    Path("~/Downloads"),
    Path("~/Pictures"),
]

IMAGE_EXTS = {".png", ".jpg", ".jpeg", ".heic", ".tiff", ".webp"}
VIDEO_EXTS = {".mov", ".mp4", ".m4v"}
SCREENSHOT_RE = re.compile(r"(screen shot|screenshot|cleanshot)", re.IGNORECASE)
RECORDING_RE = re.compile(r"(screen recording|recording)", re.IGNORECASE)
DATE_RE = re.compile(r"(20\d{2})[-_.](\d{2})[-_.](\d{2})")


def human_bytes(size: int) -> str:
    units = ["B", "KB", "MB", "GB", "TB"]
    value = float(size)
    idx = 0
    while value >= 1024 and idx < len(units) - 1:
        value /= 1024
        idx += 1
    if idx <= 1:
        return f"{value:.0f}{units[idx]}"
    return f"{value:.1f}{units[idx]}"


def classify(path: Path) -> str:
    name = path.name
    suffix = path.suffix.lower()
    if RECORDING_RE.search(name) and suffix in VIDEO_EXTS:
        return "screen-recording"
    if SCREENSHOT_RE.search(name) and suffix in IMAGE_EXTS:
        return "screenshot"
    if SCREENSHOT_RE.search(name) and suffix in VIDEO_EXTS:
        return "screenshot-video"
    return ""


def inferred_date(path: Path, modified: dt.datetime) -> dt.datetime:
    match = DATE_RE.search(path.name)
    if match:
        try:
            return dt.datetime(int(match.group(1)), int(match.group(2)), int(match.group(3)))
        except ValueError:
            pass
    return modified


def iter_candidates(roots: list[Path], errors: list[str]):
    for root in roots:
        root = root.expanduser()
        if not root.exists():
            errors.append(f"missing: {root}")
            continue
        if root.is_file():
            if classify(root):
                yield root
            continue
        if not root.is_dir():
            continue
        for dirpath, dirnames, filenames in os.walk(root, followlinks=False):
            dirnames[:] = [name for name in dirnames if name not in {".git", "node_modules", "Library"}]
            for filename in filenames:
                path = Path(dirpath) / filename
                if classify(path):
                    yield path


def collision_safe(target: Path) -> Path:
    if not target.exists():
        return target
    stem = target.stem
    suffix = target.suffix
    parent = target.parent
    idx = 2
    while True:
        candidate = parent / f"{stem}-{idx}{suffix}"
        if not candidate.exists():
            return candidate
        idx += 1


def build_records(roots: list[Path], min_bytes: int):
    errors: list[str] = []
    records = []
    seen: set[Path] = set()
    for path in iter_candidates(roots, errors):
        try:
            resolved = path.resolve()
            if resolved in seen:
                continue
            seen.add(resolved)
            stat = path.stat()
            if stat.st_size < min_bytes:
                continue
            modified = dt.datetime.fromtimestamp(stat.st_mtime)
            source_date = inferred_date(path, modified)
            records.append(
                {
                    "path": path,
                    "bytes": stat.st_size,
                    "kind": classify(path),
                    "modified": modified,
                    "month": source_date.strftime("%Y-%m"),
                    "ext": path.suffix.lower(),
                }
            )
        except OSError as exc:
            errors.append(f"{path}: {exc}")
    return records, errors


def copy_records(records, out_dir: Path):
    copied = []
    for rec in records:
        month_dir = out_dir / rec["month"]
        month_dir.mkdir(parents=True, exist_ok=True)
        target = collision_safe(month_dir / rec["path"].name)
        shutil.copy2(rec["path"], target)
        copied.append((rec["path"], target))
    return copied


def write_report(args, records, errors, copied, report_dir: Path):
    summary = report_dir / "summary.txt"
    tsv = report_dir / "screenshots.tsv"
    with tsv.open("w", encoding="utf-8") as handle:
        handle.write("bytes\tkind\tmonth\text\tmodified\tpath\n")
        for rec in records:
            handle.write(
                f"{rec['bytes']}\t{rec['kind']}\t{rec['month']}\t{rec['ext']}\t"
                f"{rec['modified'].strftime('%Y-%m-%d %H:%M')}\t{rec['path']}\n"
            )

    by_size = sorted(records, key=lambda rec: rec["bytes"], reverse=True)
    by_recent = sorted(records, key=lambda rec: rec["modified"], reverse=True)

    def counts(key):
        result = {}
        for rec in records:
            result[rec[key]] = result.get(rec[key], 0) + 1
        return sorted(result.items(), key=lambda item: (-item[1], item[0]))

    with summary.open("w", encoding="utf-8") as out:
        def emit(line: str = ""):
            print(line)
            out.write(line + "\n")

        emit("## Screenshot organizer audit")
        emit(f"report_dir: {report_dir}")
        emit(f"roots: {', '.join(str(p) for p in args.roots)}")
        emit(f"min_mb: {args.min_mb}")
        emit(f"matches: {len(records)}")
        emit(f"metadata: {tsv}")

        emit()
        emit("## Counts by kind")
        for key, value in counts("kind"):
            emit(f"{value}\t{key}")

        emit()
        emit("## Counts by month")
        for key, value in counts("month"):
            emit(f"{value}\t{key}")

        emit()
        emit("## Largest matches")
        emit("size\tkind\tmonth\tpath")
        for rec in by_size[: args.top]:
            emit(f"{human_bytes(rec['bytes'])}\t{rec['kind']}\t{rec['month']}\t{rec['path']}")

        emit()
        emit("## Most recent matches")
        emit("modified\tkind\tsize\tpath")
        for rec in by_recent[: args.top]:
            emit(f"{rec['modified'].strftime('%Y-%m-%d %H:%M')}\t{rec['kind']}\t{human_bytes(rec['bytes'])}\t{rec['path']}")

        if copied:
            emit()
            emit("## Copied files")
            for source, target in copied:
                emit(f"{source} -> {target}")

        if errors:
            emit()
            emit("## Scan warnings")
            for err in errors:
                emit(err)

        emit()
        emit("## Report files")
        emit(str(report_dir))
        emit(f"summary: {summary}")


def main() -> int:
    parser = argparse.ArgumentParser(description="Audit screenshots and screen recordings without moving originals.")
    parser.add_argument("roots", nargs="*", type=Path)
    parser.add_argument("--top", type=int, default=30)
    parser.add_argument("--min-mb", type=float, default=0.0)
    parser.add_argument("--copy", action="store_true", help="Copy matches into --out/YYYY-MM folders.")
    parser.add_argument("--out", type=Path, help="Output directory required by --copy.")
    args = parser.parse_args()

    if not args.roots:
        args.roots = DEFAULT_ROOTS
    if args.copy and not args.out:
        print("--out is required with --copy", flush=True)
        return 2

    min_bytes = int(args.min_mb * 1024 * 1024)
    records, errors = build_records(args.roots, min_bytes)
    copied = []
    if args.copy and args.out:
        copied = copy_records(records, args.out.expanduser())

    stamp = dt.datetime.now().strftime("%Y%m%d-%H%M%S-%f")
    report_dir = Path(tempfile.gettempdir()) / f"screenshot-organizer-{stamp}"
    report_dir.mkdir(parents=True, exist_ok=True)
    write_report(args, records, errors, copied, report_dir)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
