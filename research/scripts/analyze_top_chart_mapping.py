#!/usr/bin/env python3
"""Summarize top-chart mapping into replacement and category statistics."""

from __future__ import annotations

from collections import Counter, defaultdict
import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
DATA_PATH = ROOT / "research" / "data" / "top-mac-app-category-mapping-2026-06-24.json"
SUMMARY_JSON = ROOT / "research" / "data" / "top-mac-app-category-summary-2026-06-24.json"
SUMMARY_MD = ROOT / "research" / "top-chart-summary.md"


CORE_REPLACEABLE_CATEGORIES = {
    "storage_audit",
    "archive_tools",
    "browser_extension_or_web_wrapper",
    "office_documents",
    "email_calendar_meetings",
    "ai_chat_or_writing",
    "developer_tools",
    "backup_sync_storage_service",
    "pdf_document_tools",
    "image_media_batch",
    "video_media_batch",
    "screenshot_ocr_capture",
    "transcription_audio_notes",
    "web_download_archive",
    "clipboard_automation",
    "data_visualization_or_analysis",
}


ASSISTABLE_CATEGORIES = CORE_REPLACEABLE_CATEGORIES | {
    "system_utility",
    "creative_pro_editor",
    "music_audio_pro",
    "notes_tasks_writing_app",
    "file_manager_transfer",
    "genealogy_reference",
    "timer_focus_utility",
    "diagram_mindmap",
    "presentation_screen_tools",
}


HARD_APP_CATEGORIES = {
    "network_security",
    "messaging_social",
    "streaming_content",
    "hardware_device",
    "password_identity_security",
    "remote_desktop_virtualization",
    "shopping_service",
    "education_exam_service",
    "window_workspace_management",
}


CATEGORY_NOTES = {
    "storage_audit": "Core job is transparent local disk inspection; this repo already covers it.",
    "archive_tools": "Core job is list/test/extract; this repo already covers common archive workflows.",
    "browser_extension_or_web_wrapper": "Many rows are thin wrappers around websites or browser rules; agents/browser automation can replace much of the workflow.",
    "office_documents": "Agents can generate, review, convert, and clean files; Microsoft/Google UIs still matter for collaboration.",
    "email_calendar_meetings": "Connectors and APIs make triage/drafting/summaries agent-friendly; real-time chat/meeting clients remain.",
    "ai_chat_or_writing": "General chat/writing overlaps directly with Codex/Claude workflows.",
    "developer_tools": "Codebase work is highly agent-ready; IDEs, simulators, and distribution remain specialized.",
    "backup_sync_storage_service": "Verification/reporting is replaceable; sync engines are not.",
    "pdf_document_tools": "Batch PDF inspection/split/merge/OCR are agent-friendly; polished signing/layout editing remains app-heavy.",
    "image_media_batch": "Batch conversion, metadata, duplicate scans, and contact sheets are agent-friendly.",
    "video_media_batch": "ffmpeg-style transcode/trim/metadata/caption workflows are agent-friendly.",
    "screenshot_ocr_capture": "Post-capture organization/OCR/reporting is agent-friendly; hotkey capture is resident-app territory.",
    "transcription_audio_notes": "Transcription and summarization are agent-friendly; capture/permissions remain app-specific.",
    "web_download_archive": "Automated web export/download flows are agent-friendly but session-dependent.",
    "clipboard_automation": "Batch transforms are agent-friendly; clipboard history needs a resident utility.",
    "data_visualization_or_analysis": "One-off analysis and generated charts are agent-friendly.",
    "system_utility": "Agents can inspect or generate config, but resident menu-bar/input behavior usually remains app territory.",
    "creative_pro_editor": "Agents can automate prep/export/metadata; the live canvas/timeline remains the product.",
    "music_audio_pro": "Metadata/filing/conversion can be automated; instruments, notation, and DAW work remain apps.",
    "notes_tasks_writing_app": "Agents can draft/migrate/summarize; persistent task/note UI remains useful.",
    "file_manager_transfer": "Reports and batch copies can be scripted; device/cloud transfer clients may still be needed.",
    "genealogy_reference": "Report/export workflows can be agentic; domain database UI remains app-specific.",
    "timer_focus_utility": "Simple timers and reports can be scripted; always-on reminders remain resident utilities.",
    "diagram_mindmap": "Agents can generate diagrams; manual canvas editing remains app value.",
    "presentation_screen_tools": "Deck generation is agent-friendly; live overlays/remotes need apps.",
    "network_security": "VPN/proxy/MFA clients are trust and OS-integration problems, not skill replacements.",
    "messaging_social": "Network effects, accounts, push notifications, and encrypted UX are the product.",
    "streaming_content": "Licensed content and playback UX are service-bound.",
    "hardware_device": "Drivers and hardware control need native integrations.",
    "password_identity_security": "Secrets/autofill/MFA have a stricter trust model than coding-agent tools.",
    "remote_desktop_virtualization": "VM and remote desktop clients need live native OS/network integration.",
    "shopping_service": "Retail/account extensions are service-bound.",
    "education_exam_service": "Exam delivery and identity requirements are not local replacement targets.",
    "window_workspace_management": "Real-time window control needs resident accessibility/input integrations.",
}


def pct(count: int, total: int) -> float:
    return round((count / total) * 100, 1) if total else 0.0


def replacement_bucket(category: str) -> str:
    if category in CORE_REPLACEABLE_CATEGORIES:
        return "core_replaceable"
    if category in ASSISTABLE_CATEGORIES:
        return "assistable_not_core_replaceable"
    if category in HARD_APP_CATEGORIES:
        return "hard_app_or_service"
    return "needs_manual_review"


def summarize_chart(rows: list[dict]) -> dict:
    total = len(rows)
    bucket_counts = Counter(replacement_bucket(row["mapped_category"]) for row in rows)
    replaceability_counts = Counter(row["replaceability"] for row in rows)
    readiness_counts = Counter(row["ai_agent_readiness"] for row in rows)
    category_counts = Counter(row["mapped_category"] for row in rows)
    return {
        "total": total,
        "replacement_buckets": {
            key: {"count": count, "percent": pct(count, total)}
            for key, count in sorted(bucket_counts.items())
        },
        "raw_replaceability": {
            key: {"count": count, "percent": pct(count, total)}
            for key, count in sorted(replaceability_counts.items())
        },
        "ai_agent_readiness": {
            key: {"count": count, "percent": pct(count, total)}
            for key, count in sorted(readiness_counts.items())
        },
        "top_categories": [
            {"category": category, "count": count, "percent": pct(count, total)}
            for category, count in category_counts.most_common()
        ],
    }


def category_rollup(charts: dict[str, list[dict]]) -> list[dict]:
    categories = sorted({row["mapped_category"] for rows in charts.values() for row in rows})
    rows = []
    for category in categories:
        item = {
            "category": category,
            "replacement_bucket": replacement_bucket(category),
            "note": CATEGORY_NOTES.get(category, ""),
        }
        for chart_name, chart_rows in charts.items():
            matched = [row for row in chart_rows if row["mapped_category"] == category]
            item[chart_name] = {
                "count": len(matched),
                "percent": pct(len(matched), len(chart_rows)),
                "apps": [f"#{row['rank']} {row['name']} ({row['price']})" for row in matched],
            }
        rows.append(item)
    return rows


def write_json(summary: dict) -> None:
    SUMMARY_JSON.write_text(json.dumps(summary, indent=2, ensure_ascii=False) + "\n")


def write_markdown(summary: dict) -> None:
    def fmt_pct(value: float | int) -> str:
        return f"{float(value):.1f}%"

    lines = [
        "# Top Chart Summary",
        "",
        "Snapshot date: 2026-06-24.",
        "",
        "This file turns the row-level mapping into the stats needed for the thesis. It separates strict/core replacement from broader agent assistance.",
        "",
        "Definitions:",
        "",
        "- `core_replaceable`: the app's core job can plausibly be replaced by a skill, plugin, connector, CLI, script, or a quick agent-built tool.",
        "- `assistable_not_core_replaceable`: agents can handle adjacent workflows, but the app's core value is a live UI, persistent state, creative canvas, menu-bar behavior, or domain database.",
        "- `hard_app_or_service`: the app is mainly a network, trust, hardware, streaming, identity, or OS-integration surface.",
        "",
        "## Headline Stats",
        "",
        "| Chart | Rows | Core replaceable | Assistable, not core replaceable | Hard app/service |",
        "|---|---:|---:|---:|---:|",
    ]
    for chart_name, chart_summary in summary["charts"].items():
        buckets = chart_summary["replacement_buckets"]
        core = buckets.get("core_replaceable", {"count": 0, "percent": 0})
        assist = buckets.get("assistable_not_core_replaceable", {"count": 0, "percent": 0})
        hard = buckets.get("hard_app_or_service", {"count": 0, "percent": 0})
        lines.append(
            f"| {chart_name} | {chart_summary['total']} | "
            f"{core['count']} ({fmt_pct(core['percent'])}) | "
            f"{assist['count']} ({fmt_pct(assist['percent'])}) | "
            f"{hard['count']} ({fmt_pct(hard['percent'])}) |"
        )

    lines.extend([
        "",
        "These are replacement-opportunity percentages, not measured install declines. See [market-traffic-install-evidence.md](market-traffic-install-evidence.md) for the evidence boundary.",
        "",
        "## AI-Agent Readiness",
        "",
        "| Chart | Native MCP | Native agent surface | API/connector ready | Scriptable CLI | Web automation | Partial file automation | Low/not a fit |",
        "|---|---:|---:|---:|---:|---:|---:|---:|",
    ])
    for chart_name, chart_summary in summary["charts"].items():
        readiness = chart_summary["ai_agent_readiness"]

        def cell(key: str) -> str:
            value = readiness.get(key, {"count": 0, "percent": 0})
            return f"{value['count']} ({fmt_pct(value['percent'])})"

        low_count = sum(readiness.get(key, {"count": 0})["count"] for key in ["low", "not_a_fit", "unknown"])
        low_pct = pct(low_count, chart_summary["total"])
        lines.append(
            f"| {chart_name} | {cell('native_mcp')} | {cell('native_agent_surface')} | "
            f"{cell('api_or_connector_ready')} | {cell('scriptable_cli')} | {cell('web_automation')} | "
            f"{cell('partial_file_automation')} | {low_count} ({fmt_pct(low_pct)}) |"
        )

    lines.extend([
        "",
        "## Category Rollup",
        "",
        "| Category | Replacement bucket | Free overall | Paid overall | Paid Productivity | Note |",
        "|---|---|---:|---:|---:|---|",
    ])
    for item in summary["category_rollup"]:
        lines.append(
            f"| {item['category']} | {item['replacement_bucket']} | "
            f"{item['free_overall']['count']} ({fmt_pct(item['free_overall']['percent'])}) | "
            f"{item['paid_overall']['count']} ({fmt_pct(item['paid_overall']['percent'])}) | "
            f"{item['paid_productivity']['count']} ({fmt_pct(item['paid_productivity']['percent'])}) | "
            f"{item['note']} |"
        )

    lines.extend([
        "",
        "## Main Insights From The Chart Data",
        "",
        "1. Paid Mac charts are much richer skill-replacement territory than the free chart. Paid rows contain more narrow utilities: storage analyzers, archive tools, PDF tools, media metadata tools, OCR, web archivers, clipboard utilities, and file managers.",
        "2. Free rows skew toward services and wrappers: messaging, streaming, VPNs, Microsoft/Google clients, meeting apps, and browser shells. Many are agent-addressable, but fewer are clean local app replacements.",
        "3. The strongest immediate replacement targets are boring utilities, not pro apps: storage, archive, PDF batch work, screenshots/OCR, file inventory, browser wrappers, CSV/spreadsheets, and developer/cache audits.",
        "4. Pro creative apps are not disappearing into skills. The agent value is around prep, export, metadata, conversion, batch reports, and repetitive cleanup.",
        "5. Window managers, VPNs, password/MFA, streaming, hardware, and messaging should stay apps. Their core jobs depend on always-on OS behavior, trust, accounts, network effects, or licensed content.",
        "",
    ])
    SUMMARY_MD.write_text("\n".join(lines))


def main() -> None:
    mapping = json.loads(DATA_PATH.read_text())
    charts = mapping["charts"]
    summary = {
        "captured_at": mapping["captured_at"],
        "definitions": {
            "core_replaceable": "The app's core job can plausibly be replaced by a skill, plugin, connector, CLI, script, or quick agent-built tool.",
            "assistable_not_core_replaceable": "Agents can handle adjacent workflows, but the app's core value remains a live UI, persistent state, creative canvas, menu-bar behavior, or domain database.",
            "hard_app_or_service": "The app is mainly a network, trust, hardware, streaming, identity, or OS-integration surface.",
        },
        "charts": {name: summarize_chart(rows) for name, rows in charts.items()},
        "category_rollup": category_rollup(charts),
    }
    write_json(summary)
    write_markdown(summary)


if __name__ == "__main__":
    main()
