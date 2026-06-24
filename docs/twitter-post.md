I used Codex to debug why macOS "System Data" was huge.

The interesting bit: I didn't need CleanMyMac / CCleaner style magic.

I turned the workflow into 12 reusable Codex/Claude skills:

- read-only disk accounting
- exact paths + sizes
- APFS vs du gap explanation
- screen recordings / Photos / wallpaper assets / VM checks
- app inventory, browser cache, launch agent, dev cache, archive, image, PDF, plist, CSV, backup audits
- no deletion unless the human approves

Repo: https://github.com/iselur/agentic-mac-skills

I also checked the US Top Free Mac App chart. The replaceable category is not Slack/Word/VPN/banking. It is the narrow utilities:

- unzip tools
- PDF helpers
- converters
- cleanup scanners
- app inventory
- batch file tools

That is the pattern I think will eat a lot of small Mac utility apps:

small deterministic scripts + Codex/Claude interpretation > opaque one-click cleaner.
