#!/usr/bin/env python3
import argparse
import datetime as dt
import hashlib
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile


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


def mdls(path: Path, key: str) -> str:
    if not shutil.which("mdls"):
        return ""
    try:
        proc = subprocess.run(
            ["mdls", "-raw", "-name", key, str(path)],
            check=False,
            capture_output=True,
            text=True,
            timeout=5,
        )
    except Exception:
        return ""
    value = proc.stdout.strip().replace("\n", " ")
    if proc.returncode != 0 or value in {"", "(null)", "null"}:
        return ""
    return value


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def looks_like_pdf(path: Path) -> bool:
    try:
        with path.open("rb") as handle:
            return handle.read(5) == b"%PDF-"
    except OSError:
        return False


def iter_pdf_paths(roots: list[Path], errors: list[str]):
    for root in roots:
        if not root.exists():
            errors.append(f"missing: {root}")
            continue
        if root.is_file():
            if root.suffix.lower() == ".pdf":
                yield root
            continue
        if not root.is_dir():
            continue
        for dirpath, dirnames, filenames in os.walk(root, followlinks=False):
            dirnames[:] = [name for name in dirnames if name not in {".git", "node_modules"}]
            for filename in filenames:
                if filename.lower().endswith(".pdf"):
                    yield Path(dirpath) / filename


def normalized_name(path: Path) -> str:
    stem = path.stem.lower()
    stem = re.sub(r"\s+copy$", "", stem)
    stem = re.sub(r"\s+\(\d+\)$", "", stem)
    stem = re.sub(r"[-_ ]\d+$", "", stem)
    stem = re.sub(r"\s+", " ", stem).strip()
    return stem


def write_report(args, records, errors, report_dir: Path) -> Path:
    summary = report_dir / "summary.txt"
    tsv = report_dir / "pdfs.tsv"

    with tsv.open("w", encoding="utf-8") as handle:
        handle.write("bytes\tpages\tmodified\tis_pdf\tsha256\tpath\n")
        for rec in records:
            handle.write(
                f"{rec['bytes']}\t{rec['pages']}\t{rec['modified']}\t"
                f"{rec['is_pdf']}\t{rec.get('sha256', '')}\t{rec['path']}\n"
            )

    by_size = sorted(records, key=lambda rec: rec["bytes"], reverse=True)
    duplicate_names: dict[str, list[dict]] = {}
    for rec in records:
        duplicate_names.setdefault(normalized_name(Path(rec["path"])), []).append(rec)
    duplicate_names = {key: vals for key, vals in duplicate_names.items() if len(vals) > 1}

    exact_hashes: dict[str, list[dict]] = {}
    if args.hash:
        for rec in records:
            exact_hashes.setdefault(rec.get("sha256", ""), []).append(rec)
        exact_hashes = {key: vals for key, vals in exact_hashes.items() if key and len(vals) > 1}

    with summary.open("w", encoding="utf-8") as out:
        def emit(line: str = ""):
            print(line)
            out.write(line + "\n")

        emit("## PDF file audit")
        emit(f"report_dir: {report_dir}")
        emit(f"roots: {', '.join(str(p) for p in args.roots)}")
        emit(f"min_mb: {args.min_mb}")
        emit(f"pdfs_found: {len(records)}")
        emit(f"metadata: {tsv}")

        emit()
        emit("## Largest PDFs")
        emit("size\tpages\tpdf\tmodified\tpath")
        for rec in by_size[: args.top]:
            emit(
                f"{human_bytes(rec['bytes'])}\t{rec['pages'] or '-'}\t"
                f"{rec['is_pdf']}\t{rec['modified']}\t{rec['path']}"
            )

        emit()
        emit("## Duplicate-looking filenames")
        if not duplicate_names:
            emit("none")
        else:
            for key, vals in sorted(duplicate_names.items()):
                emit(f"{key}:")
                for rec in sorted(vals, key=lambda item: item["path"]):
                    emit(f"  {human_bytes(rec['bytes'])}\t{rec['path']}")

        if args.hash:
            emit()
            emit("## Exact duplicate hashes")
            if not exact_hashes:
                emit("none")
            else:
                for digest, vals in sorted(exact_hashes.items()):
                    emit(f"{digest}:")
                    for rec in sorted(vals, key=lambda item: item["path"]):
                        emit(f"  {human_bytes(rec['bytes'])}\t{rec['path']}")

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
    parser = argparse.ArgumentParser(description="Audit local PDF files without modifying originals.")
    parser.add_argument("roots", nargs="*", type=Path, default=[Path(".")])
    parser.add_argument("--top", type=int, default=30)
    parser.add_argument("--min-mb", type=float, default=5.0)
    parser.add_argument("--hash", action="store_true", help="Compute SHA-256 hashes for exact duplicate grouping.")
    args = parser.parse_args()

    min_bytes = int(args.min_mb * 1024 * 1024)
    errors: list[str] = []
    records = []
    seen: set[Path] = set()
    for path in iter_pdf_paths([p.expanduser() for p in args.roots], errors):
        try:
            resolved = path.resolve()
            if resolved in seen:
                continue
            seen.add(resolved)
            stat = path.stat()
            if stat.st_size < min_bytes:
                continue
            modified = dt.datetime.fromtimestamp(stat.st_mtime).strftime("%Y-%m-%d %H:%M")
            rec = {
                "path": str(path),
                "bytes": stat.st_size,
                "pages": mdls(path, "kMDItemNumberOfPages"),
                "modified": modified,
                "is_pdf": "yes" if looks_like_pdf(path) else "no",
            }
            if args.hash:
                rec["sha256"] = sha256(path)
            records.append(rec)
        except OSError as exc:
            errors.append(f"{path}: {exc}")

    stamp = dt.datetime.now().strftime("%Y%m%d-%H%M%S")
    report_dir = Path(tempfile.gettempdir()) / f"pdf-file-audit-{stamp}"
    report_dir.mkdir(parents=True, exist_ok=True)
    write_report(args, records, errors, report_dir)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
