I used Codex to debug why macOS "System Data" was huge.

The interesting bit: I didn't need CleanMyMac / CCleaner style magic.

I turned the workflow into reusable agent skills:

- read-only disk accounting
- exact paths + sizes
- APFS vs du gap explanation
- screen recordings / Photos / wallpaper assets / VM checks
- no deletion unless the human approves

Repo: https://github.com/iselur/agentic-mac-skills

This is the pattern I think will eat a lot of small Mac utility apps:

small deterministic scripts + Codex/Claude interpretation > opaque one-click cleaner.
