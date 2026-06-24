# Skill Selection Rationale

Snapshot date: 2026-06-24.

The 13 skills were chosen because they match the part of Mac utility apps that coding agents are genuinely good at: local file inspection, deterministic transforms, transparent reports, and reversible output copies. They were not chosen because they are exciting. They were chosen because they can replace a real job without building another app shell.

The rule is simple:

- Build skills for local, auditable, repeatable workflows.
- Avoid skills for live services, secure accounts, licensed content, hardware drivers, VPN/proxy clients, password managers, pro creative canvases, and always-on UI behavior.
- Prefer read-only first. If a workflow writes anything, write a separate output copy or report.

## Why These Skills

| Skill | App category it targets | Why it was chosen | What it does | What it deliberately does not do |
|---|---|---|---|---|
| `macos-system-data-audit` | Storage cleaners/analyzers | CleanMyMac, DaisyDisk, and GrandPerspective-style demand is often just "where did my disk go?" An agent can answer that with paths and sizes. | Explains macOS System Data, APFS/`du` gaps, user Library usage, Photos, recordings, wallpapers/aerial assets, installers, ISOs, and VM residue. | Does not delete files, run one-click cleanup, or replace a visual disk browser. |
| `downloads-desktop-triage` | Clutter/download cleaners | Downloads/Desktop cleanup is a repeated inventory problem, not a product. | Reports large files, installers, archives, screenshots, recordings, and duplicate-looking names on Desktop/Downloads. | Does not delete or move originals and does not claim duplicate-looking names are true duplicates. |
| `mac-app-inventory` | App inventory/uninstaller helpers | Many "uninstaller" apps start with an app/data inventory. That part is deterministic. | Lists app bundle sizes, versions, bundle IDs, and large support/cache/container folders. | Does not uninstall apps or remove security/VPN/MDM/browser/password/sync data by default. |
| `image-batch-convert` | Simple image converters/resizers | Batch image conversion is a perfect CLI-backed agent task. | Dry-runs and optionally writes converted image copies using macOS `sips`. | Does not overwrite originals and does not replace Lightroom/Pixelmator/Photoshop-style editing. |
| `backup-audit` | Backup health/storage checkers | Backup status and local snapshot inventory are inspectable and reportable. | Reports Time Machine state, latest backup, destinations, local snapshots, APFS usage, and backup-sized folders. | Does not delete snapshots, change Time Machine, or replace sync/backup engines. |
| `browser-profile-audit` | Browser cache/profile cleaners | Browser bloat can be reported without reading private browsing data. | Reports browser profile/cache/support-folder sizes and large browser files. | Does not read History, Cookies, Login Data, or browsing database contents. |
| `launch-agent-audit` | Startup/background item scanners | Startup inventory is a facts-first workflow where opaque cleaner apps often overreach. | Lists LaunchAgents, LaunchDaemons, launchctl services, and login/background item clues. | Does not unload, delete, edit, or label items malicious from names alone. |
| `developer-cache-audit` | Xcode/dev disk cleaners | Developer caches are large, path-based, and easy to mis-clean without context. | Reports Xcode DerivedData, archives, simulators, Homebrew/npm/pip/cargo/Gradle/PlatformIO caches, and build folders. | Does not delete caches, archives, signing assets, simulators, or build outputs without approval. |
| `csv-clean-room` | CSV/spreadsheet cleanup utilities | CSV profiling and normalization are deterministic and easy to verify. | Profiles delimiter, rows/columns, blank rows, duplicate headers, empty columns; can write a normalized clean copy. | Does not infer types, rewrite dates, or change values beyond whitespace cleanup. |
| `archive-batch-tools` | Archive/unzip apps | Listing, testing, and extracting archives is CLI-native and auditable. | Lists/tests ZIP and tar-family archives and optionally extracts to a separate output folder. | Does not promise full RAR/7z/password-archive parity and rejects unsafe archive paths. |
| `pdf-file-audit` | PDF utility/organizer apps | Many PDF "utility" jobs start with inventory: size, pages, duplicate-looking names, hashes. | Audits PDFs by size, page-count metadata, duplicate-looking names, and optional exact hashes. | Does not merge, split, OCR, compress, delete, rewrite, sign, or replace PDF Expert-style editing. |
| `plist-defaults-audit` | macOS preference/settings inspectors | Preferences/defaults inspection is structured local data, but writing prefs is risky. | Audits plist/defaults files by size, domain, readability, type, and top-level keys. | Does not reset, write, convert, or dump secrets/full nested values. |
| `screenshot-organizer` | Screenshot cleanup/desktop organizers | Screenshot and recording cleanup is a repeated local-file workflow. | Finds screenshots/screen recordings, reports counts by kind/month, largest/recent files, and can copy matches into dated folders. | Does not move/delete/rewrite originals and does not replace capture, OCR, annotation, or screen-overlay apps. |

## Why Not The Other App Categories

Some chart categories are agent-addressable but not clean app replacements:

- Office documents, email/calendar, and meetings can be handled through connectors, document tools, and scripted workflows, but the live collaboration UI still matters.
- Pro creative apps can be helped around batch export, metadata, conversion, and repetitive cleanup, but the editor/canvas/timeline is still the product.
- Notes, tasks, writing, diagrams, and mind maps can be drafted or migrated by agents, but persistent UI state still matters for many users.
- System utilities can often be inspected by agents, but resident menu-bar, accessibility, input, and always-on behavior still need apps.

Other categories should stay apps/services:

- VPN/proxy/MFA/password/security tools because the trust and OS-integration model is wrong for ad hoc agent code.
- Messaging/social/streaming because network effects, accounts, content rights, and push UX are the product.
- Hardware/device apps because drivers and device control need native integrations.
- Window managers because the core value is real-time accessibility/input control.

## Practical Product Thesis

The opportunity is not "AI replaces apps." That framing is too broad and mostly false.

The stronger thesis is:

> Coding agents replace a subset of paid Mac utility apps where the product is mostly a deterministic local workflow plus a thin UI.

That is why the repo started with boring local utilities. Those are the categories where a user can inspect the report, trust the path-level evidence, and avoid installing another opaque cleaner.
