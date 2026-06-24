#!/usr/bin/env python3
import argparse
from pathlib import Path
import sys
import tarfile
import zipfile


def is_unsafe_member(name: str) -> bool:
    p = Path(name)
    return p.is_absolute() or ".." in p.parts


def inspect_zip(path: Path):
    with zipfile.ZipFile(path) as zf:
        bad = zf.testzip()
        infos = zf.infolist()
        total = sum(i.file_size for i in infos)
        unsafe = [i.filename for i in infos if is_unsafe_member(i.filename)]
        return {
            "kind": "zip",
            "members": len(infos),
            "uncompressed_bytes": total,
            "test_error": bad,
            "unsafe": unsafe,
            "names": [i.filename for i in infos[:50]],
        }


def inspect_tar(path: Path):
    with tarfile.open(path) as tf:
        members = tf.getmembers()
        total = sum(m.size for m in members if m.isfile())
        unsafe = [m.name for m in members if is_unsafe_member(m.name)]
        return {
            "kind": "tar",
            "members": len(members),
            "uncompressed_bytes": total,
            "test_error": None,
            "unsafe": unsafe,
            "names": [m.name for m in members[:50]],
        }


def inspect(path: Path):
    if zipfile.is_zipfile(path):
        return inspect_zip(path)
    if tarfile.is_tarfile(path):
        return inspect_tar(path)
    raise ValueError("unsupported archive type")


def extract(path: Path, out_dir: Path, report: dict):
    if report["unsafe"]:
        raise ValueError("refusing to extract archive with unsafe member paths")
    target = out_dir / path.stem
    target.mkdir(parents=True, exist_ok=True)
    if report["kind"] == "zip":
        with zipfile.ZipFile(path) as zf:
            zf.extractall(target)
    elif report["kind"] == "tar":
        with tarfile.open(path) as tf:
            try:
                tf.extractall(target, filter="data")
            except TypeError:
                tf.extractall(target)
    return target


def main() -> int:
    parser = argparse.ArgumentParser(description="Inspect and optionally extract zip/tar archives safely.")
    parser.add_argument("archives", nargs="+")
    parser.add_argument("--extract", action="store_true")
    parser.add_argument("--out", help="Output directory for --extract.")
    args = parser.parse_args()

    if args.extract and not args.out:
        print("--out is required with --extract", file=sys.stderr)
        return 2

    out_dir = Path(args.out).expanduser() if args.out else None
    if out_dir:
        out_dir.mkdir(parents=True, exist_ok=True)

    status = 0
    for raw in args.archives:
        path = Path(raw).expanduser()
        print(f"\n## {path}")
        if not path.exists():
            print("missing")
            status = 1
            continue
        try:
            report = inspect(path)
        except Exception as exc:
            print(f"unsupported_or_invalid: {exc}")
            status = 1
            continue
        for key in ["kind", "members", "uncompressed_bytes", "test_error", "unsafe"]:
            print(f"{key}: {report[key]}")
        print("first_members:")
        for name in report["names"]:
            print(f"  {name}")
        if args.extract and out_dir:
            try:
                target = extract(path, out_dir, report)
            except Exception as exc:
                print(f"extract_failed: {exc}")
                status = 1
            else:
                print(f"extracted_to: {target}")
    return status


if __name__ == "__main__":
    raise SystemExit(main())
