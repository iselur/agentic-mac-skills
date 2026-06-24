# Market Traffic And Install Evidence

Snapshot date: 2026-06-24.

The short answer: there is public evidence that AI search/answer surfaces are changing web traffic, but I did not find public evidence that AI agents/skills have already reduced Mac App Store installs for the app categories in this repo. The App Store chart snapshot supports a replacement-opportunity thesis, not a demand-decline thesis.

## What We Can Say

| Question | Current evidence | Conclusion |
|---|---|---|
| Are AI answer surfaces reducing some web traffic? | Yes. A 2026 arXiv paper on Google AI Overviews and Wikipedia estimates about a 15% reduction in daily English Wikipedia article traffic after AIO exposure: <https://arxiv.org/abs/2602.18455>. Another 2026 benchmark found AI Overviews for 51.5% of representative real-user queries: <https://arxiv.org/abs/2604.27790>. A third 2026 measurement study found 13.7% overall AIO activation and 64.7% activation for question-form queries: <https://arxiv.org/abs/2605.14021>. | Yes, for informational web traffic. |
| Does that prove Mac utility-app installs are falling? | No. Web-search substitution is not the same metric as Mac App Store downloads, paid purchases, subscriptions, or usage. | No. It is directional context only. |
| Do public App Store ranks prove installs declined? | No. Appfigures documents public rank APIs and snapshots, but ranks are standings, not downloads. It also notes historical category snapshots beyond the recent window require contacting Appfigures: <https://docs.appfigures.com/api/reference/v2/ranks>. | No. Ranks are relative visibility signals. |
| Is install/download data publicly available for these apps? | Not generally. Appfigures' sales endpoint includes downloads, revenue, returns, and uninstalls, but requires `private:read`, meaning it is for apps/accounts the caller can access: <https://docs.appfigures.com/api/reference/v2/sales>. | No, not as a public source of truth for third-party Mac apps. |
| Can market-intelligence vendors estimate it? | Yes, in principle. Similarweb says it uses aggregated site/app-level behavioral data and cross-validation to estimate market trends: <https://support.similarweb.com/hc/en-us/articles/360001631538-Similarweb-Data-Methodology>. Appfigures, Sensor Tower, data.ai, 42matters/Similarweb, and similar vendors may have historical estimates. | Yes, but that is paid/estimated data and still needs causal analysis. |

## Six Months / One Year / Two To Three Years

| Window | What is confirmable from public sources | What is not confirmed |
|---|---|---|
| Last 6 months | 2026 studies show AI Overviews are visible at meaningful rates and can reduce traffic for some informational content. | No public proof that top Mac paid utility installs fell because users replaced them with agents or skills. |
| Last 1 year | AI search/answer adoption and AI-mediated browsing are credible market forces. Public studies support traffic reallocation away from some source pages. | No clean public app-install trend by "agent-replaceable Mac utility" category. |
| Last 2-3 years | The timing overlaps with ChatGPT, Claude, Cursor, Codex, MCP, and local-agent adoption, so displacement is plausible for narrow utility workflows. | No public causal dataset connecting those launches to lower Mac App Store demand for DaisyDisk/Keka/PDF tools/window managers/etc. |

## What The Current Repo Actually Proves

The chart work proves composition:

- The captured free overall chart has 98 mapped rows.
- The captured paid overall chart has 100 mapped rows.
- The captured paid Productivity chart has 100 mapped rows.
- Paid charts contain many narrow utilities whose core jobs are deterministic local workflows.
- In the current mapping, 41.0% of paid overall rows and 40.0% of paid Productivity rows are classified as core-replaceable by skills/plugins/connectors/CLIs/quick tools.

It does not prove demand decline:

- No historical download counts were collected.
- No revenue/subscription estimates were collected.
- No vendor website traffic series were collected.
- No causal model was run.

## Source-Of-Truth Options

| Source | What it can answer | Caveat |
|---|---|---|
| App Store Connect Sales and Trends | Real downloads, proceeds, units, subscriptions for owned apps. | Private to the developer account. Not useful for third-party top charts unless we own the apps. |
| Appfigures public ranks | Rank history and category snapshots. | Ranks are not downloads; long historical snapshots require paid access/contact. |
| Appfigures sales reports | Downloads/revenue/uninstalls. | Private account scope. |
| Sensor Tower / data.ai / Similarweb App Intelligence / 42matters | Estimated downloads, revenue, usage, app/web traffic, category trends. | Paid estimates; methodology and confidence vary by app size/platform. |
| Vendor website traffic via Similarweb/Semrush/Ahrefs | Whether vendor acquisition traffic is falling. | Website traffic is not app installs, and many Mac App Store purchases happen without vendor-site visits. |
| Our own repeated chart snapshots | Whether replaceable categories keep appearing in top charts. | Good for monitoring composition, weak for install volume. |

## Practical Measurement Plan

1. Keep daily/weekly snapshots of the same Apple Mac charts: free overall, paid overall, paid Productivity.
2. Add paid market-intelligence download/revenue estimates for the top app IDs if access is available.
3. Group apps by this repo's replacement bucket: `core_replaceable`, `assistable_not_core_replaceable`, `hard_app_or_service`.
4. Compare rank, estimated download, and revenue trends by bucket over 6, 12, 24, and 36 months.
5. Treat AI-agent adoption as a hypothesis, not a causal answer, unless a changepoint/control model supports it.

## Bottom Line

Use the App Store mapping for the product thesis:

> Paid Mac charts contain many thin, deterministic utility workflows that coding agents can replace or compress into skills.

Do not claim this yet:

> AI agents have already reduced Mac App Store installs for paid utility apps.

That second claim needs historical installs/revenue or credible third-party estimates.
