# AI-Agent Readiness

Snapshot date: 2026-06-24.

This is the evidence behind the per-row `ai_agent_readiness` fields in `research/data/top-mac-app-category-mapping-2026-06-24.json`.

The short version: only a small slice of top-chart apps are truly agent-native. The strongest official MCP examples in this chart are Canva and Notion. Microsoft 365, Slack, Grammarly, Telegram, Tailscale, Cyberduck, Things, iA Writer, Due, MediaInfo, LosslessCut, and UTM are agent-addressable through APIs, CLIs, URL schemes, Shortcuts, or open-source repos. Most narrow paid utilities are still not "AI-agent ready" as products; they are replaceable because their jobs can be performed by generic local tools.

## Readiness Levels

| Level | Meaning |
|---|---|
| `native_mcp` | Official app/vendor MCP server or AI connector exists. |
| `native_agent_surface` | The category is already an AI/chat/agent workflow. |
| `api_or_connector_ready` | Official API, connector, URL scheme, Shortcuts, or automation surface exists. |
| `scriptable_cli` | Core workflow can be driven by local CLI tools, libraries, or generated scripts. |
| `web_automation` | Browser automation or web UI automation is plausible, with session and ToS caveats. |
| `partial_file_automation` | Files, exports, metadata, or config are automatable; core app UI remains. |
| `low` | Some automation may exist, but the core job is not a good agent target. |
| `not_a_fit` | Trust, hardware, DRM, identity, or real-time OS integration makes agent replacement inappropriate. |

## Official / Strong Evidence

| App/category | Level | Evidence | What exists | What is still missing |
|---|---|---|---|---|
| Canva | `native_mcp` | [Canva AI Connector](https://www.canva.dev/docs/connect/canva-mcp-server-setup/) | Canva documents an MCP-based AI connector for ChatGPT, Claude, Claude Code, Gemini CLI, Cursor, and VS Code. It can create designs, autofill templates, find designs, and export files. | It does not replace the full visual design canvas. |
| Notion | `native_mcp` | [Notion MCP](https://developers.notion.com/docs/mcp), [llms.txt](https://developers.notion.com/llms.txt) | Official hosted MCP server for secure workspace access, optimized formatting, search, write, and report workflows. | Notion Web Clipper remains a browser extension; workspace state remains Notion. |
| Linear | `native_mcp` | [Linear MCP server](https://linear.app/docs/mcp) | Official remote MCP server with setup instructions for Claude, Claude Code, Codex, Cursor, VS Code, v0, Windsurf, Zed, and others. | Linear is not in the captured top-100 rows, but it is a strong benchmark for agent-ready SaaS. |
| GitHub | `native_mcp` | [GitHub MCP Server](https://github.com/github/github-mcp-server) | Official MCP server for repo, issue, PR, workflow, and code-analysis automation. | GitHub is not in the captured Mac top rows; it is included as a benchmark. |
| Microsoft 365 / Office / Outlook / OneDrive / OneNote | `api_or_connector_ready` | [Microsoft 365 Copilot extensibility](https://learn.microsoft.com/en-us/microsoft-365/copilot/extensibility/overview), [Microsoft Graph](https://learn.microsoft.com/en-us/graph/use-the-api) | Microsoft documents Copilot connectors, Microsoft Graph, Work IQ APIs, and MCP as a context-access protocol for LLM clients. | Mac desktop UI behavior and tenant auth/policy remain outside a simple skill. |
| Slack | `api_or_connector_ready` | [Slack LLM docs](https://docs.slack.dev/llms.txt), [Slack platform docs](https://docs.slack.dev/) | Slack publishes LLM-friendly docs, CLI guidance, agent app scaffolding, and Slack app APIs. | Slack desktop/client UX and enterprise governance remain the product. |
| Grammarly | `api_or_connector_ready` | [Grammarly API docs](https://developer.grammarly.com/) | REST API access to Grammarly AI/ML technology and admin functionality. | The consumer Mac writing assistant UI is not replaced. |
| Telegram | `api_or_connector_ready` | [Telegram Bot API](https://core.telegram.org/bots/api) | Bot API, webhooks, and automation surface. | Personal encrypted chat client and network effects remain. |
| Tailscale | `scriptable_cli` | [Tailscale CLI](https://tailscale.com/kb/1080/cli) | Built-in CLI for managing/troubleshooting devices in a tailnet. | VPN trust boundary and OS networking client remain native. |
| Cyberduck | `scriptable_cli` | [duck CLI](https://duck.sh/) | Official command-line interface for FTP/SFTP/WebDAV/cloud-storage transfer workflows. | GUI browsing and credential handling still need care. |
| Things 3 | `api_or_connector_ready` | [Things URL scheme](https://culturedcode.com/things/support/articles/2803573/) | URL scheme and x-callback automation. | Persistent task UI and personal workflow remain the app. |
| iA Writer | `api_or_connector_ready` | [iA Writer Apple Shortcuts](https://ia.net/writer/support/basics/apple-shortcuts) | Shortcuts and URL command automation. | Writing environment and library remain the app. |
| Due | `api_or_connector_ready` | [Due developer docs](https://www.dueapp.com/developer.html) | URL scheme and x-callback automation. | Always-on reminder behavior remains the app. |
| MediaInfo | `scriptable_cli` | [MediaInfo CLI](https://mediaarea.net/en/MediaInfo/Support/CLI) | CLI-friendly media metadata inspection. | None for metadata inspection; richer media editing is separate. |
| LosslessCut | `scriptable_cli` | [LosslessCut repo](https://github.com/mifi/lossless-cut) | Open-source app with command/API-adjacent automation surfaces for media cuts. | Interactive preview and manual editing remain app-like. |
| UTM | `scriptable_cli` | [UTM repo](https://github.com/utmapp/UTM) | Open-source virtualization app; automation exists around app/project files and tooling. | Live VM session UX remains native. |

## Category-Level Conclusion

| Category | Readiness pattern | Practical conclusion |
|---|---|---|
| Office, email, calendar, meetings | APIs/connectors are strong | Agent-ready for drafting, search, summaries, and file operations; not a full UI replacement. |
| Storage, archive, PDF batch, image/video batch, screenshots/OCR | CLI/library-backed | Often more replaceable by a skill than by app-specific APIs. |
| Browser wrappers/extensions | Web automation or extension APIs | Many top-chart wrappers are weak products; automation can replace the workflow, but Safari distribution remains app-like. |
| Developer tools | Strong CLI/MCP ecosystem | Highly agent-ready, but IDE/simulator/debugger experiences remain specialized. |
| Notes/tasks/writing | Mixed API/URL/export support | Good for draft/migrate/summarize; not necessarily a full app replacement. |
| Pro creative/audio/video apps | Partial file/export automation | Agents help around the edges; the live canvas/timeline/instrument remains. |
| VPN/proxy/password/MFA/security | Mostly not a fit | Even when CLIs exist, this is a trust-boundary problem, not a replacement thesis. |
| Window managers/menu-bar/focus utilities | Low for agents | Better framed as open-source app alternatives, not skills. |
| Streaming, messaging, hardware, exams | Not a fit | Account, DRM, push, hardware, identity, or safety constraints dominate. |

## Implication

The app vendors that are genuinely AI-agent ready are mostly platform vendors or SaaS/workflow vendors: Microsoft, Notion, Canva, Linear, GitHub, Slack-like platforms. The long tail of paid Mac utilities is not building MCP servers. That does not make them safe from replacement; it means the replacement route is generic tools plus skills, not app-vendor integrations.
