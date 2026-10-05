# Changes

Each version below says what behaves differently, for someone deciding whether to adopt it.

## v0.3.0

- **Format change: `cookbook.json` no longer has `machines`.** A cookbook is a person's customizations, not a description of the machines they use today. Hardware belongs to the recipes that need it, in their `requires` and `applies_to`.
- **What cookbooks must change:** remove `machines` from `cookbook.json`, and point the check workflow at `duff/omarchy-kitchen@v0.3.0`. A description that names your current machines is worth rewriting too.
- **Writing recipes:** a recipe that needs particular hardware says so in its title or the first line of its Problem, so people see it without scrolling to the recipe data.

## v0.2.0

- **Format change: recipe data moves to the end.** The JSON that used to sit between `---` lines at the top of RECIPE.md now goes in a `## Recipe data` section at the end, as one JSON code block. People browsing a recipe on GitHub now see the problem and the fix first.
- **What cookbooks must change:** move each recipe's data to the end, and point the cookbook's check workflow at `duff/omarchy-kitchen@v0.2.0`. `kitchen check` explains what to do with a recipe still in the old layout. When it explains this update, the agent says the cookbook needs converting, and a yes covers converting and publishing it.

## v0.1.1

- **Recipes are suggestions.** Agents now solve each recipe's problem their own way, fitted to the person's machine, software, and preferences, and use the recipe's snippets only where they fit. The plan shown before applying says where it departs from the recipe. Nothing here lets agents do more: every change still waits for a yes, and the safety review still comes first.
- **Applied records** gain `differences`, a line on how this machine's version differs from the recipe. The weekly review uses it to publish a copy as applied or adapted.
- **Writing a Fix:** explain why it works, and which parts are specific to your machine, so other agents can adapt it rather than copy it.
- **Cookbook template:** includes an MIT license.

## v0.1.0

The first version.

- **Recipe format:** one folder per recipe, with compact JSON data that says what the fix touches, what it needs, and who has created, applied, or adapted it. Settings and records are JSON too.
- **Weekly review:** four parts (method updates, publishing, recipes from followed cookbooks, upkeep), answered in one list. You can snooze it until a time you choose.
- **Safety review:** a separate read-only reviewer checks every recipe from someone else before it's offered.
- **Applying and undoing:** each applied recipe gets a record that says how to undo it. Applied recipes wait for the weekly review before they're published.
- **`kitchen` command:** `check`, `scan`, `flags`, `profile`, `match`, `status`, `due`, `snooze`. Written in Bash with jq, like Omarchy's own commands.
- **Explaining:** the agent explains the setup when asked, at the end of setup, and at the first review. It uses `kitchen status`, so it talks about your cookbook and the people you follow.
- **Commits:** a yes in the weekly review is the ask to commit and push what it covers.
- **Templates:** a private repo and a cookbook.
- **Cookbook check:** a GitHub Action every cookbook runs on push.
