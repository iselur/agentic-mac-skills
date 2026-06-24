# Agentic Mac Skills

Reusable Codex/Claude skills for replacing a narrow class of Mac utility apps with auditable agent workflows.

The first principle: do not build another cleaner app. Let an agent run small read-only probes, explain the result, and only then recommend normal Finder/app cleanup. This is a better fit for Codex/Claude than opaque one-click cleaners because the user can inspect the exact paths and sizes before anything is removed.

## Included Skills

Current set: 13 reusable skills.

| Skill | Replaces the need for | What it does |
|---|---|---|
| `macos-system-data-audit` | CleanMyMac/CCleaner-style storage mystery scans | Explains macOS System Data, APFS/du gaps, Photos, screen recordings, wallpaper/aerial assets, old ISOs, and VM residues. |
| `downloads-desktop-triage` | Basic clutter cleaners and duplicate-looking download scans | Inventories Downloads/Desktop large files, installers, archives, screenshots, recordings, and duplicate-looking filenames. |
| `mac-app-inventory` | Basic app inventory/uninstaller scans | Lists installed apps, bundle sizes, versions, bundle IDs, and large app support/cache/container folders. |
| `image-batch-convert` | Simple image converter/resizer apps | Dry-run-first batch image resize/format conversion using built-in macOS `sips`, writing copies only. |
| `backup-audit` | Basic backup health/storage checker apps | Reports Time Machine state, local snapshots, APFS usage, and common backup-sized folders. |
| `browser-profile-audit` | Browser cache/profile cleaner scans | Reports browser profile/cache/support-folder sizes without reading history contents. |
| `launch-agent-audit` | Startup item/background service scanners | Lists launch agents/daemons and login/background item clues without disabling anything. |
| `developer-cache-audit` | Xcode/dev disk cleaner scans | Reports Xcode, simulator, package-manager, and project build cache sizes. |
| `csv-clean-room` | Simple spreadsheet/CSV cleanup utilities | Profiles CSV files and writes normalized clean copies on request. |
| `archive-batch-tools` | Simple unzip/archive apps | Lists, tests, and extracts ZIP/tar archives into safe output folders. |
| `pdf-file-audit` | Narrow PDF organizer/audit utilities | Reports large PDFs, page-count metadata, duplicate-looking names, and optional exact hashes. |
| `plist-defaults-audit` | macOS preference/settings inspection utilities | Audits plist/defaults files by size, domain, readability, and top-level keys without writing changes. |
| `screenshot-organizer` | Screenshot cleanup/desktop organizer utilities | Audits screenshots and screen recordings, then optionally copies matches into dated folders. |

All scripts are read-only by default. They print report paths under the system temp directory and never delete files.

## Install

Clone this repo, then copy the skills you want into your agent skills directory:

```zsh
git clone https://github.com/iselur/agentic-mac-skills.git
cd agentic-mac-skills

# Codex personal skills
mkdir -p ~/.codex/skills
cp -R skills/* ~/.codex/skills/

# Claude-style agents that read ~/.agents/skills
mkdir -p ~/.agents/skills
cp -R skills/* ~/.agents/skills/
```

Restart your agent session so it reloads skill metadata.

## Example Prompts

```text
Use $macos-system-data-audit to explain why System Data is huge. Do not delete anything.
```

```text
Use $downloads-desktop-triage to find safe cleanup candidates in Downloads and Desktop.
```

```text
Use $mac-app-inventory to show which installed apps and app data folders are using the most space.
```

```text
Use $image-batch-convert to dry-run converting these PNGs to 1600px JPEG copies.
```

```text
Use $developer-cache-audit to find Xcode and package-manager cache bloat.
```

## What This Can and Cannot Replace

Skills can replace utility apps whose core job is deterministic inspection, transformation, or report generation. They cannot replace apps where the value is a real-time service, a secure account, proprietary content, hardware integration, professional interactive UI, or regulated workflow.

Good skill candidates:

- storage audits
- downloads cleanup planning
- app inventory
- PDF file audits
- image/video format conversion
- backup health checks
- browser profile/cache bloat audits
- startup/background item audits
- developer cache reports
- CSV cleanup and normalization
- archive listing/testing/extraction
- macOS plist/defaults inspection
- screenshot and screen-recording organization
- transcript cleanup and summarization
- meeting note extraction from local recordings/transcripts
- screenshot/report generation
- project scaffolding
- backup verification reports

Poor skill candidates:

- banking/payment apps
- secure messengers
- VPN/proxy clients
- pro creative editors where live UI matters
- streaming services
- maps/navigation with live routing
- password managers
- device drivers
- medical or safety-critical apps

See [research/app-replacement-map.md](research/app-replacement-map.md) for the chart-based analysis.

## Safety Model

These skills bias toward:

1. Read-only first.
2. Exact paths and sizes.
3. Owner app/Finder cleanup before shell deletion.
4. Explicit user approval before destructive operations.
5. No “clean everything” commands.

## License

MIT.
