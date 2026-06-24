# Top Chart Summary

Snapshot date: 2026-06-24.

This file turns the row-level mapping into the stats needed for the thesis. It separates strict/core replacement from broader agent assistance.

Definitions:

- `core_replaceable`: the app's core job can plausibly be replaced by a skill, plugin, connector, CLI, script, or a quick agent-built tool.
- `assistable_not_core_replaceable`: agents can handle adjacent workflows, but the app's core value is a live UI, persistent state, creative canvas, menu-bar behavior, or domain database.
- `hard_app_or_service`: the app is mainly a network, trust, hardware, streaming, identity, or OS-integration surface.

## Headline Stats

| Chart | Rows | Core replaceable | Assistable, not core replaceable | Hard app/service |
|---|---:|---:|---:|---:|
| free_overall | 98 | 47 (48.0%) | 19 (19.4%) | 32 (32.7%) |
| paid_overall | 100 | 41 (41.0%) | 38 (38.0%) | 21 (21.0%) |
| paid_productivity | 100 | 40 (40.0%) | 52 (52.0%) | 8 (8.0%) |

These are replacement-opportunity percentages, not measured install declines. See [market-traffic-install-evidence.md](market-traffic-install-evidence.md) for the evidence boundary.

## AI-Agent Readiness

| Chart | Native MCP | Native agent surface | API/connector ready | Scriptable CLI | Web automation | Partial file automation | Low/not a fit |
|---|---:|---:|---:|---:|---:|---:|---:|
| free_overall | 2 (2.0%) | 6 (6.1%) | 25 (25.5%) | 10 (10.2%) | 11 (11.2%) | 14 (14.3%) | 30 (30.6%) |
| paid_overall | 0 (0.0%) | 3 (3.0%) | 8 (8.0%) | 30 (30.0%) | 9 (9.0%) | 30 (30.0%) | 20 (20.0%) |
| paid_productivity | 0 (0.0%) | 7 (7.0%) | 30 (30.0%) | 20 (20.0%) | 11 (11.0%) | 24 (24.0%) | 8 (8.0%) |

## Category Rollup

| Category | Replacement bucket | Free overall | Paid overall | Paid Productivity | Note |
|---|---|---:|---:|---:|---|
| ai_chat_or_writing | core_replaceable | 6 (6.1%) | 0 (0.0%) | 1 (1.0%) | General chat/writing overlaps directly with Codex/Claude workflows. |
| archive_tools | core_replaceable | 2 (2.0%) | 2 (2.0%) | 0 (0.0%) | Core job is list/test/extract; this repo already covers common archive workflows. |
| backup_sync_storage_service | core_replaceable | 1 (1.0%) | 2 (2.0%) | 1 (1.0%) | Verification/reporting is replaceable; sync engines are not. |
| browser_extension_or_web_wrapper | core_replaceable | 12 (12.2%) | 8 (8.0%) | 10 (10.0%) | Many rows are thin wrappers around websites or browser rules; agents/browser automation can replace much of the workflow. |
| clipboard_automation | core_replaceable | 0 (0.0%) | 0 (0.0%) | 2 (2.0%) | Batch transforms are agent-friendly; clipboard history needs a resident utility. |
| creative_pro_editor | assistable_not_core_replaceable | 5 (5.1%) | 5 (5.0%) | 0 (0.0%) | Agents can automate prep/export/metadata; the live canvas/timeline remains the product. |
| data_visualization_or_analysis | core_replaceable | 0 (0.0%) | 0 (0.0%) | 1 (1.0%) | One-off analysis and generated charts are agent-friendly. |
| developer_tools | core_replaceable | 3 (3.1%) | 2 (2.0%) | 0 (0.0%) | Codebase work is highly agent-ready; IDEs, simulators, and distribution remain specialized. |
| diagram_mindmap | assistable_not_core_replaceable | 0 (0.0%) | 3 (3.0%) | 4 (4.0%) | Agents can generate diagrams; manual canvas editing remains app value. |
| education_exam_service | hard_app_or_service | 1 (1.0%) | 1 (1.0%) | 0 (0.0%) | Exam delivery and identity requirements are not local replacement targets. |
| email_calendar_meetings | core_replaceable | 12 (12.2%) | 1 (1.0%) | 5 (5.0%) | Connectors and APIs make triage/drafting/summaries agent-friendly; real-time chat/meeting clients remain. |
| file_manager_transfer | assistable_not_core_replaceable | 1 (1.0%) | 2 (2.0%) | 4 (4.0%) | Reports and batch copies can be scripted; device/cloud transfer clients may still be needed. |
| genealogy_reference | assistable_not_core_replaceable | 0 (0.0%) | 1 (1.0%) | 1 (1.0%) | Report/export workflows can be agentic; domain database UI remains app-specific. |
| hardware_device | hard_app_or_service | 4 (4.1%) | 3 (3.0%) | 0 (0.0%) | Drivers and hardware control need native integrations. |
| image_media_batch | core_replaceable | 0 (0.0%) | 7 (7.0%) | 0 (0.0%) | Batch conversion, metadata, duplicate scans, and contact sheets are agent-friendly. |
| messaging_social | hard_app_or_service | 5 (5.1%) | 1 (1.0%) | 0 (0.0%) | Network effects, accounts, push notifications, and encrypted UX are the product. |
| music_audio_pro | assistable_not_core_replaceable | 4 (4.1%) | 10 (10.0%) | 0 (0.0%) | Metadata/filing/conversion can be automated; instruments, notation, and DAW work remain apps. |
| network_security | hard_app_or_service | 10 (10.2%) | 4 (4.0%) | 0 (0.0%) | VPN/proxy/MFA clients are trust and OS-integration problems, not skill replacements. |
| notes_tasks_writing_app | assistable_not_core_replaceable | 3 (3.1%) | 6 (6.0%) | 23 (23.0%) | Agents can draft/migrate/summarize; persistent task/note UI remains useful. |
| office_documents | core_replaceable | 6 (6.1%) | 1 (1.0%) | 1 (1.0%) | Agents can generate, review, convert, and clean files; Microsoft/Google UIs still matter for collaboration. |
| password_identity_security | hard_app_or_service | 1 (1.0%) | 3 (3.0%) | 3 (3.0%) | Secrets/autofill/MFA have a stricter trust model than coding-agent tools. |
| pdf_document_tools | core_replaceable | 2 (2.0%) | 4 (4.0%) | 8 (8.0%) | Batch PDF inspection/split/merge/OCR are agent-friendly; polished signing/layout editing remains app-heavy. |
| presentation_screen_tools | assistable_not_core_replaceable | 0 (0.0%) | 1 (1.0%) | 3 (3.0%) | Deck generation is agent-friendly; live overlays/remotes need apps. |
| remote_desktop_virtualization | hard_app_or_service | 2 (2.0%) | 2 (2.0%) | 0 (0.0%) | VM and remote desktop clients need live native OS/network integration. |
| screenshot_ocr_capture | core_replaceable | 0 (0.0%) | 1 (1.0%) | 3 (3.0%) | Post-capture organization/OCR/reporting is agent-friendly; hotkey capture is resident-app territory. |
| shopping_service | hard_app_or_service | 1 (1.0%) | 0 (0.0%) | 0 (0.0%) | Retail/account extensions are service-bound. |
| storage_audit | core_replaceable | 1 (1.0%) | 3 (3.0%) | 0 (0.0%) | Core job is transparent local disk inspection; this repo already covers it. |
| streaming_content | hard_app_or_service | 7 (7.1%) | 2 (2.0%) | 0 (0.0%) | Licensed content and playback UX are service-bound. |
| system_utility | assistable_not_core_replaceable | 6 (6.1%) | 10 (10.0%) | 8 (8.0%) | Agents can inspect or generate config, but resident menu-bar/input behavior usually remains app territory. |
| timer_focus_utility | assistable_not_core_replaceable | 0 (0.0%) | 0 (0.0%) | 9 (9.0%) | Simple timers and reports can be scripted; always-on reminders remain resident utilities. |
| transcription_audio_notes | core_replaceable | 0 (0.0%) | 1 (1.0%) | 5 (5.0%) | Transcription and summarization are agent-friendly; capture/permissions remain app-specific. |
| video_media_batch | core_replaceable | 2 (2.0%) | 8 (8.0%) | 2 (2.0%) | ffmpeg-style transcode/trim/metadata/caption workflows are agent-friendly. |
| web_download_archive | core_replaceable | 0 (0.0%) | 1 (1.0%) | 1 (1.0%) | Automated web export/download flows are agent-friendly but session-dependent. |
| window_workspace_management | hard_app_or_service | 1 (1.0%) | 5 (5.0%) | 5 (5.0%) | Real-time window control needs resident accessibility/input integrations. |

## Main Insights From The Chart Data

1. Paid Mac charts are much richer skill-replacement territory than the free chart. Paid rows contain more narrow utilities: storage analyzers, archive tools, PDF tools, media metadata tools, OCR, web archivers, clipboard utilities, and file managers.
2. Free rows skew toward services and wrappers: messaging, streaming, VPNs, Microsoft/Google clients, meeting apps, and browser shells. Many are agent-addressable, but fewer are clean local app replacements.
3. The strongest immediate replacement targets are boring utilities, not pro apps: storage, archive, PDF batch work, screenshots/OCR, file inventory, browser wrappers, CSV/spreadsheets, and developer/cache audits.
4. Pro creative apps are not disappearing into skills. The agent value is around prep, export, metadata, conversion, batch reports, and repetitive cleanup.
5. Window managers, VPNs, password/MFA, streaming, hardware, and messaging should stay apps. Their core jobs depend on always-on OS behavior, trust, accounts, network effects, or licensed content.
