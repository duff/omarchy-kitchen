# Changes

Each version below says what behaves differently, for someone deciding whether to adopt it.

## v0.1.0

The first version.

- **Recipe format:** one folder per recipe, with a compact JSON header that says what the fix touches, what it needs, and who has created, applied, or adapted it. Settings and records are JSON too.
- **Weekly review:** four parts (method updates, publishing, recipes from followed cookbooks, upkeep), answered in one list. You can snooze it until a time you choose.
- **Safety review:** a separate read-only reviewer checks every recipe from someone else before it's offered.
- **Applying and undoing:** each applied recipe gets a record that says how to undo it. Applied recipes wait for the weekly review before they're published.
- **`kitchen` command:** `check`, `scan`, `flags`, `profile`, `match`, `status`, `due`, `snooze`. Written in Bash with jq, like Omarchy's own commands.
- **Explaining:** the agent explains the setup when asked, at the end of setup, and at the first review. It uses `kitchen status`, so it talks about your cookbook and the people you follow.
- **Commits:** a yes in the weekly review is the ask to commit and push what it covers.
- **Templates:** a private repo and a cookbook.
- **Cookbook check:** a GitHub Action every cookbook runs on push.
