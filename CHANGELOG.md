# Changes

Each version below says what behaves differently, for someone deciding whether to adopt it.

## v0.6.1

- **A privacy finding always stops to ask.** v0.6.0 said this, but publishing still let the agent add a flagged word to the cookbook's public `allow` list and only mention it. Now the agent shows the finding and asks, and adds to `allow` only on a yes. This tightens privacy.
- **"One by one" means one answer per item.** v0.6.0's review guide could be read as "one by one" covering every item on the list. Now only "all", or the items picked, count as a yes to push them; going one by one, each item needs its own "publish".
- **Publishing all at once follows the right steps.** Applied copies keep their source and history instead of being rewritten as new recipes. The list replaces each draft, so drafts aren't shown one by one. Everything is written and checked before anything is pushed. After the yes, the text changes only to fix check findings or generalize private details.
- **Asking directly still works.** "Publish the mouse fix" is a yes, as before; v0.6.0 had narrowed it to the review and "what is there to publish?".
- **Smaller fixes:** the list is numbered so "all but 3" works, "temporary" is a reason to leave a change out in both guides, and the review guide no longer says everything is one item at a time.

## v0.6.0

- **Publishing your own changes is one question, not one per change.** The review (or asking "anything to publish?") lists every change worth sharing (new recipes, updates to your recipes, and recipes you applied from others) with what's left out and why. Then it asks once: publish them all, pick some, or go one by one. Answering "all" publishes and pushes each listed recipe without showing each draft first. This lets the agent publish several recipes on one yes, where before each needed its own. The privacy scan and `kitchen check` still run on every recipe, and a privacy finding that can't be generalized away still stops to ask. Recipes from other cookbooks and method updates are still offered one at a time.

## v0.5.0

- **Vetting is quick.** Before following a cookbook, the agent vets only the recipes that fit this machine, and fully reviews only those with serious warning signs: reading secrets, sending data off the machine, fetching code, hidden content, or text aimed at an agent. Everything else is reviewed one at a time, just before it's offered. For duff's cookbook on a Framework laptop, that's 4 reviews instead of 36. The report lists rejects and only counts cautions.
- **`kitchen flags` looks at what runs.** Code warnings come only from the Fix, Apply and check, and Undo sections, the files a recipe ships, and the paths it touches, so a problem description that mentions `curl` isn't flagged. Hidden text and text aimed at an agent are still looked for everywhere, with tighter patterns ("without asking" in a title no longer counts). It now catches `bash -c "$(…)"`, and ignores `hyprctl eval`. `--serious` lists only the serious kinds.
- **Remembering what was put off or left out.** review.json gains `later` (recipes the person put off, offered first next time) and `left_out` (recipes the agent left out, with the reason). Left-out recipes aren't offered, counted, or named again unless they change.
- **Setup continues in the new repo.** After making the private repo, setup has the person restart their agent in `~/Work/my-omarchy`, so its commit rules, folder access, and the safety reviewer agent all load. The agent writes out the line to type to finish.
- **Finding a cookbook by name.** "Follow duff's cookbook" works without a link: the agent tries `duff/omarchy-cookbook`, then the library, then asks, and the account check catches a wrong guess.
- **A home for files outside `~/.config`.** The private-repo template has a `home/` folder laid out like the home folder: `home/.bashrc` is `~/.bashrc`. `install.sh` copies it into `~` and `snapshot.sh` refreshes it. Recipes that change `~/.bashrc`, `~/.claude`, or `~/.XCompose` now have somewhere to go, follow the person to their other machines, and can be undone from git. `install.sh` never deletes a home-folder file on its own.
- **A lighter weekly nudge.** When the review is due, the agent asks whether to see what's waiting, instead of a bare "now or when?". Looking fetches the cookbooks and counts what's new; if nothing is waiting, the week is marked done. The session-start check itself stays local and instant.
- **An OK for surprises.** When an agent's plan for a recipe departs from what it described when offering it, it waits for an OK before changing anything.
- **`kitchen due` says "due today"** on the day the review is due, and "was due on…" only after.
- **Cleaner review items.** Each recipe opens with its problem alone, without "From duff's cookbook". The wrap-up sums up recipes that need programs or hardware the person lacks in one line, instead of naming each.

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
