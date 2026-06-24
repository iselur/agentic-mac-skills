#!/usr/bin/env python3
import argparse
import datetime as dt
import os
from pathlib import Path
import plistlib
import subprocess
import tempfile


DEFAULT_ROOTS = [
    Path("~/Library/Preferences"),
    Path("~/Library/Containers"),
    Path("~/Library/Group Containers"),
    Path("/Library/Preferences"),
]


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


def iter_plists(roots: list[Path], errors: list[str]):
    for root in roots:
        root = root.expanduser()
        if not root.exists():
            errors.append(f"missing: {root}")
            continue
        if root.is_file():
            if root.suffix.lower() == ".plist":
                yield root
            continue
        if not root.is_dir():
            continue
        for dirpath, dirnames, filenames in os.walk(root, followlinks=False):
            dirnames[:] = [name for name in dirnames if name not in {".Trash", "Caches"}]
            for filename in filenames:
                if filename.lower().endswith(".plist"):
                    yield Path(dirpath) / filename


def defaults_domains() -> list[str]:
    try:
        proc = subprocess.run(
            ["defaults", "domains"],
            check=False,
            capture_output=True,
            text=True,
            timeout=10,
        )
    except Exception:
        return []
    if proc.returncode != 0:
        return []
    return [item.strip() for item in proc.stdout.strip().split(",") if item.strip()]


def summarize_plist(path: Path):
    with path.open("rb") as handle:
        data = plistlib.load(handle)
    kind = type(data).__name__
    count = ""
    keys = ""
    if isinstance(data, dict):
        count = str(len(data))
        keys = ", ".join(str(key) for key in list(data.keys())[:12])
    elif isinstance(data, list):
        count = str(len(data))
    return kind, count, keys


def write_report(args, records, invalid, errors, domains, domains_checked: bool, report_dir: Path) -> Path:
    summary = report_dir / "summary.txt"
    tsv = report_dir / "plists.tsv"

    with tsv.open("w", encoding="utf-8") as handle:
        handle.write("bytes\tmodified\tkind\tcount\tpath\n")
        for rec in records:
            handle.write(f"{rec['bytes']}\t{rec['modified']}\t{rec['kind']}\t{rec['count']}\t{rec['path']}\n")

    by_size = sorted(records, key=lambda rec: rec["bytes"], reverse=True)

    with summary.open("w", encoding="utf-8") as out:
        def emit(line: str = ""):
            print(line)
            out.write(line + "\n")

        emit("## Plist/defaults audit")
        emit(f"report_dir: {report_dir}")
        emit(f"roots: {', '.join(str(p) for p in args.roots)}")
        emit(f"domain_filter: {args.domain or '-'}")
        emit(f"min_kb: {args.min_kb}")
        emit(f"plists_found: {len(records)}")
        emit(f"metadata: {tsv}")

        emit()
        emit("## Defaults domains")
        if domains_checked:
            emit(f"count: {len(domains)}")
            for domain in domains[: args.top]:
                emit(domain)
        else:
            emit("skipped for explicit path scan")

        emit()
        emit("## Largest readable plist files")
        emit("size\tkind\tcount\tmodified\tpath")
        for rec in by_size[: args.top]:
            emit(f"{human_bytes(rec['bytes'])}\t{rec['kind']}\t{rec['count'] or '-'}\t{rec['modified']}\t{rec['path']}")

        emit()
        emit("## Top-level keys from largest plist files")
        for rec in by_size[: min(args.top, 10)]:
            emit(f"{rec['path']}:")
            emit(f"  {rec['keys'] or '-'}")

        emit()
        emit("## Unreadable or invalid plist files")
        if not invalid:
            emit("none")
        else:
            for item in invalid[: args.top]:
                emit(item)

        if errors:
            emit()
            emit("## Scan warnings")
            for err in errors:
                emit(err)

        emit()
        emit("## Report files")
        emit(str(report_dir))
        emit(f"summary: {summary}")

    return summary


def main() -> int:
    parser = argparse.ArgumentParser(description="Audit macOS plist/defaults files without writing changes.")
    parser.add_argument("roots", nargs="*", type=Path)
    parser.add_argument("--top", type=int, default=30)
    parser.add_argument("--min-kb", type=float, default=64.0)
    parser.add_argument("--domain", help="Only include plist paths or defaults domains containing this text.")
    args = parser.parse_args()

    explicit_roots = bool(args.roots)
    if not args.roots:
        args.roots = DEFAULT_ROOTS
    needle = args.domain.lower() if args.domain else ""
    min_bytes = int(args.min_kb * 1024)
    errors: list[str] = []
    invalid: list[str] = []
    records = []
    seen: set[Path] = set()

    for path in iter_plists(args.roots, errors):
        if needle and needle not in str(path).lower():
            continue
        try:
            resolved = path.resolve()
            if resolved in seen:
                continue
            seen.add(resolved)
            stat = path.stat()
            if stat.st_size < min_bytes:
                continue
            kind, count, keys = summarize_plist(path)
            modified = dt.datetime.fromtimestamp(stat.st_mtime).strftime("%Y-%m-%d %H:%M")
            records.append(
                {
                    "path": str(path),
                    "bytes": stat.st_size,
                    "modified": modified,
                    "kind": kind,
                    "count": count,
                    "keys": keys,
                }
            )
        except Exception as exc:
            invalid.append(f"{path}: {exc}")

    domains_checked = (not explicit_roots) or bool(needle)
    domains = defaults_domains() if domains_checked else []
    if needle:
        domains = [domain for domain in domains if needle in domain.lower()]

    stamp = dt.datetime.now().strftime("%Y%m%d-%H%M%S")
    report_dir = Path(tempfile.gettempdir()) / f"plist-defaults-audit-{stamp}"
    report_dir.mkdir(parents=True, exist_ok=True)
    write_report(args, records, invalid, errors, domains, domains_checked, report_dir)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
