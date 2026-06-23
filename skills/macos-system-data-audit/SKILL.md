---
name: macos-system-data-audit
description: Runs a read-only macOS disk audit to explain large System Data, hidden Library usage, old installer images, app caches, Photos libraries, screen recordings, wallpaper/aerial assets, and VM/Parallels residues. Use when a user asks why macOS storage/System Data is large, what is safe to clean, or whether cleaner apps such as CleanMyMac or CCleaner are needed.
---

# macOS System Data Audit

## Quick Start

Run the bundled audit script from this skill directory:

```zsh
scripts/macos-system-data-audit.sh
```

For a deeper whole-Data-volume large-file scan:

```zsh
scripts/macos-system-data-audit.sh --full
```

## Workflow

1. Run the script before doing manual `du` or `find` exploration.
2. Read these summary sections first:
   - `Accounting gap`
   - `Home folder top level`
   - `User Library top level`
   - `Known high-signal suspects`
   - `Large files`
   - `VM / Parallels artifacts`
3. If the report shows a large unaccounted gap or permission errors, ask the user to grant Full Disk Access to the terminal/Codex/Claude host, restart it, and rerun the same command.
4. Do not delete anything from script output. Present exact paths, sizes, and the safest owner UI or app workflow to clean each item.

## Interpretation Rules

- `df` reports actual volume usage. `du` reports readable directory trees and can exceed `df` on APFS because of clones/shared accounting.
- Large `group.com.apple.screencapture/ScreenRecordings` files are macOS screen recordings.
- `com.apple.wallpaper` and `com.apple.idleassetsd` are Apple wallpaper/aerial assets.
- `~/Library/Parallels/Downloads/*.iso` is usually an installer image, not a VM disk.
- Real VM leftovers usually show as `.pvm`, `.hdd`, `.vmdk`, `.vdi`, `.qcow2`, or `.sparsebundle`.
- Treat `/System/Volumes/Preboot`, `/System/Volumes/VM`, and protected Apple stores as system-owned unless the user has a precise, reversible cleanup path.

## Output

Give a short ranked list:

1. What is actually using space.
2. What is safe to remove through normal Finder/app settings.
3. What should not be manually deleted.
4. What extra permission or follow-up scan would prove the remaining unknowns.
