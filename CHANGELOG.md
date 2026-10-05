# Changes

Each version below says what behaves differently, for someone deciding whether to adopt it.

## v0.4.0

- **The weekly review is a conversation.** Instead of one long list, it goes one item at a time. Each recipe is a problem in plain words, with how it fits this machine and anything to know before saying yes; ids and links appear only when asked for. The person says apply, skip, later, or asks a question, and can stop whenever they like. What they don't reach waits for next time instead of being declined.
- **`kitchen pending`** lists the recipes from followed cookbooks that are still to decide on, new or changed ones first. It leaves out what's applied, declined, or doesn't fit, so a recipe that newly fits (a new monitor, a new program) comes back on its own.
- **Lighter reviews.** Safety reviews happen one recipe at a time, just before it's offered, so none are spent on recipes nobody reaches. Recipes plainly for a setup the person doesn't have are left out, and named at the end by their problem, with the reason.
- **Setup needs no preparation.** The agent installs the GitHub CLI if it's missing, helps someone without a GitHub account make one, and walks them through signing in. The message to a new person is now just the one line.
- **Git logins by name.** Setup points git at `gh` by name instead of running `gh auth setup-git`, which wrote this machine's full path to `gh`. The template's `snapshot.sh` fixes such a path if it appears anyway.
- **Default commit rules.** The private-repo template has a "Commits" section: commit and push each change right after a yes, one change per commit. Setup uses it instead of asking.
- **Setup fixes:** following a cookbook is committed, and the library question is asked only of people who make a cookbook.
- **Less noise.** `kitchen due` and `kitchen status` no longer count recipe applies as changes to share, and mention recipes waiting to be published only to people who have a cookbook.
- **A note to send back.** Someone who makes a public cookbook gets a short message, ready to send to whoever invited them, so that person can follow them back.
- **Vetting before following.** Following a cookbook first checks the account (is this the person you know?), runs `kitchen check` and `kitchen flags`, and safety-reviews small cookbooks completely and larger ones where flagged. One rejected recipe means the agent recommends not following.
- **Saved verdicts.** Safety verdicts are saved under each recipe's exact contents, so an unchanged recipe isn't reviewed twice.
- **A dedicated safety reviewer in Claude Code.** `install` adds a `kitchen-safety-reviewer` agent that can only read files and always runs at `xhigh` effort. This tightens safety; nothing here lets agents do more.
- **Effort advice:** setup and the README say once that reviews work best at high effort or above.

## v0.3.1

- **Cookbook template:** the README no longer claims every change goes in `~/.config/`. Many recipes also write elsewhere, and each recipe's data says exactly what it touches.

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
