# Community Alternatives And Tool Backends

Snapshot date: 2026-06-24.

The strongest public alternatives are not usually "skills" yet. They are mature CLIs, libraries, open-source utilities, and MCP/community connectors that a skill can wrap safely.

## Category Matrix

| Repo category | Public alternatives | Top-chart apps substituted | Fit for skills/plugins |
|---|---|---|---|
| `storage_audit` | [dust](https://github.com/bootandy/dust), [gdu](https://github.com/dundee/gdu), [dua-cli](https://github.com/Byron/dua-cli) | CleanMyMac, DaisyDisk, GrandPerspective, Disk Drill audit-only | Strong. Transparent disk reports are a natural skill backend. |
| `archive_tools` | [7-Zip](https://www.7-zip.org/), [libarchive](https://github.com/libarchive/libarchive), [unar/lsar](https://github.com/MacPaw/XADMaster) | Keka, RAR Extractor, The Unarchiver, Unzip | Strong. List/test/extract safely into output folders. |
| `pdf_document_tools` | [qpdf](https://github.com/qpdf/qpdf), [pikepdf](https://github.com/pikepdf/pikepdf), [pypdf](https://github.com/py-pdf/pypdf), [OCRmyPDF](https://github.com/ocrmypdf/OCRmyPDF) | PDF Expert, PDF Reader Pro, PDFgear, PageForge, PDFScanner | Strong for merge/split/OCR/compress/audit; weak for visual signing and redaction unless rendered and verified. |
| `image_media_batch` | [ImageMagick](https://github.com/ImageMagick/ImageMagick), [ExifTool](https://exiftool.org/) | GraphicConverter, PixelStyle, PhotoSweeper-style metadata workflows, Canva/Lightroom export cleanup | Strong for conversion, resize, metadata, contact sheets, and duplicate-looking reports. Not a pro editor. |
| `video_media_batch` | [FFmpeg](https://github.com/FFmpeg/FFmpeg), [HandBrakeCLI](https://github.com/HandBrake/HandBrake), [MediaInfo](https://github.com/MediaArea/MediaInfo) | LosslessCut, Smart Converter Pro, MediaInfo, CapCut batch tasks | Strong next skill target: inspect, trim, transcode, extract audio/subtitles, normalize metadata. |
| `browser_extension_or_web_wrapper` | [Finicky](https://github.com/johnste/finicky), [Hammerspoon](https://github.com/Hammerspoon/hammerspoon), [uBlock Origin](https://github.com/gorhill/uBlock), [Dark Reader](https://github.com/darkreader/darkreader) | Open Link Pro, Velja, Wipr-like blockers, Dark Reader/Noir, Google/YouTube wrapper apps | Partial. Link routing and web automation fit; Safari extension packaging remains app-like. |
| `office_documents` | [Pandoc](https://github.com/jgm/pandoc), [LibreOffice](https://github.com/LibreOffice/core), [DuckDB](https://github.com/duckdb/duckdb) | Word, Excel, PowerPoint, WPS Office, paid LibreOffice, markdown writers | Strong for conversion, generation, review, and data analysis; not a full collaborative office UI. |
| `email_calendar_meetings` | [notmuch](https://github.com/notmuch/notmuch), [gcalcli](https://github.com/insanum/gcalcli), [google-calendar-mcp](https://github.com/nspady/google-calendar-mcp), [whisper.cpp](https://github.com/ggerganov/whisper.cpp) | Outlook, Mail for Gmail, Webmail App, GCal, Whisper Notes, Trace, Aiko | Useful, but OAuth/token handling means community MCPs need review before recommending by default. |
| `developer_tools` | [mise](https://github.com/jdx/mise), [xcodes](https://github.com/XcodesOrg/xcodes), Xcode command-line tools | Xcode helper workflows, Node.js/JavaScript Compiler, dev cache cleaners | Strong for setup, audit, build, and cache workflows; not a debugger/IDE replacement. |
| `system_utility` / `window_workspace_management` | [Rectangle](https://github.com/rxhanson/Rectangle), [Stats](https://github.com/exelban/stats), [Maccy](https://github.com/p0deje/Maccy) | Magnet, BetterSnapTool, Moom, iStat Menus, Maccy, CopyClip | Mostly OSS app substitutes, not agent skills, because they need resident UI/hotkeys/accessibility. |
| `screenshot_ocr_capture` | [NormCap](https://github.com/dynobo/normcap), [Tesseract](https://github.com/tesseract-ocr/tesseract), [Flameshot](https://github.com/flameshot-org/flameshot) | TextSniper, Greenshot, Presentify, Cursor Pro | Strong for batch OCR and screenshot reports; weak for always-on capture overlays. |
| `file_manager_transfer` / `backup_sync_storage_service` | [rclone](https://github.com/rclone/rclone), [Syncthing](https://github.com/syncthing/syncthing), [croc](https://github.com/schollz/croc) | Cyberduck, Offline Files, FileBrowser Pro, Instashare, OneDrive workflows, MacDroid partial | Strong for scripted copy/sync/inventory; device-specific mounts still need native clients. |
| `web_download_archive` | [ArchiveBox](https://github.com/ArchiveBox/ArchiveBox), [MarkDownload](https://github.com/deathau/markdownload) | SiteSucker, MarkDownload | Good candidate for browser/export/archive skills. |

## Official Integration Surfaces To Prefer

| Surface | Categories | Use before community hacks? | Notes |
|---|---|---|---|
| macOS CLIs: `diskutil`, `du`, `tmutil`, `mdfind`, `sips`, `screencapture`, `textutil`, `qlmanage`, `caffeinate` | storage, backup, image, screenshot, system | Yes | Already matches the repo's safety model: local, inspectable, reversible. |
| AppleScript/JXA/Shortcuts/UI scripting | browser wrappers, office, meetings, screenshots | Sometimes | Useful for personal workflows, but TCC prompts and UI brittleness are real. |
| Google Gmail/Drive/Docs/Sheets/Calendar APIs/connectors | office, email/calendar, file workflows | Yes | Prefer APIs/connectors over browser automation when OAuth scopes are understood. |
| Microsoft Graph / Office file APIs | office, Outlook, OneDrive | Yes | Good for enterprise workflows; authentication and tenant policy are the hard part. |
| Slack/Zoom/Teams APIs and transcript exports | meetings, chat summaries | Yes | Good for summaries and exports; not live client replacement. |
| Xcode command-line tools: `xcodebuild`, `xcrun`, `simctl` | developer tools | Yes | Good for audits/builds; Xcode UI remains. |

## Gaps

- VPN/proxy, password managers, MFA, banking, and secure messengers are the wrong threat model for skills.
- Window managers, clipboard managers, menu-bar monitors, and focus timers can have open-source app substitutes, but they are poor one-shot skill targets.
- FFmpeg/ImageMagick replace batch chores, not Final Cut/Logic/Pixelmator/Lightroom.
- PDF redaction/signatures are risky unless rendered and visually verified; merge/split/OCR is safer.
- Safari extension signing, sandboxing, and distribution keep many browser-extension replacements app-like.
- Community MCP servers are promising, but token storage, OAuth scopes, and prompt-injection risk need review before recommending them as repo defaults.
