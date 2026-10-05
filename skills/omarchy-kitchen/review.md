# The weekly review

One pass a week covers everything: what to publish, what's new in followed cookbooks, upkeep, and new versions of this method. The person answers once, item by item.

## At the start of a session

The private repo's `AGENTS.md` asks for this check at the start of each session in that repo:

```bash
~/.local/share/omarchy-kitchen/bin/kitchen due
```

- **`not due`** or **`snoozed`**: say nothing about the review.
- **`due`**: in one or two lines, say the review is due and what's waiting (the indented lines from `kitchen due`). Then ask: now, or when? Don't start on anything else first if the person's message is just a greeting. If they came with a task, ask at the end of your reply instead, once.
  - **Now**: run the review below.
  - **Later**: turn their answer into a date and time and snooze it, for example `kitchen snooze 2026-10-09 18:00`. "Tonight" means 18:00 today. "Tomorrow" means 09:00 tomorrow. "This weekend" means Saturday 09:00. Confirm the time in a few words. Until then, sessions stay quiet about the review.
  - **If they don't answer the question**, don't ask again in that session.

A snooze only lives on this machine (`kitchen/snooze` is ignored by git). The review date itself is in `kitchen/review.json`, which is committed, so it moves for every machine.

When the review is more than a week overdue, lead with how much has piled up when you ask, so the person can judge whether it's worth doing now.

## The review

The review is a conversation, one item at a time. Each item is a problem described in plain words, so the person can tell quickly whether they care. Do the reading quietly first. Then walk through the items, and let the person stop whenever they like.

Read `kitchen/settings.json` (merged over the method's `defaults.json`) and `kitchen/review.json`.

### 1. Method updates

```bash
git -C ~/.local/share/omarchy-kitchen fetch --tags --quiet
git -C ~/.local/share/omarchy-kitchen tag --sort=-v:refname | head -1
```

If the newest tag is newer than `method` in settings, and isn't `method_declined` in review.json:

- Read `CHANGELOG.md` for every version in between, **and** the actual diff: `git -C ~/.local/share/omarchy-kitchen diff <current>..<newest> -- skills bin defaults.json templates`.
- Explain in plain language what will behave differently for this person. Don't just restate the changelog.
- Call out anything that lets the agent do more: publish more, run more, reach the network, or skip a question. A method update changes what every agent following it is told to do, so it gets the strictest reading.
- Point out any setting in their `kitchen/settings.json` that the update affects.

### 2. Their own changes worth sharing

Skip this part if the person has no cookbook, meaning no `cookbook.json` at the path in the `cookbook` setting.

- **Changes since the last review.** List the commits with `git log --reverse <reviewed_through>..HEAD`.
  - Leave out commits that only touch `kitchen/`.
  - Leave out commits that touch `kitchen/applied/`: they apply or undo someone else's recipe, and come back as applied copies instead.
  - For each change that's left, decide whether it's worth sharing as a new recipe or as an update to one of theirs. Follow [publish.md](publish.md), and note what you'd leave out or generalize for privacy. Keep a short reason for each change you won't offer: private, housekeeping, or too small.
- **Applied recipes waiting to be published.** These are files in `kitchen/applied/` with `"published": false`, for recipes that are still applied. Offer each as an `applied` copy, or as `adapted` if their version differs (see `differences`).

### 3. Recipes from cookbooks they follow

Fetch each cookbook in `following` into the cache:

```bash
dir=~/.cache/omarchy-kitchen/cookbooks/<owner>/<repo>
git clone --quiet https://github.com/<owner>/<repo> "$dir" 2>/dev/null || git -C "$dir" fetch --quiet
git -C "$dir" reset --quiet --hard origin/HEAD   # the cache holds no work of yours
```

Then run `kitchen pending`.
- **What it lists:** the recipes still to decide on, new or changed ones first. It already leaves out what's applied or declined at that version, and what doesn't fit this machine.
- **What `older` means:** recipes the person put off, or never reached. They stay available until decided.
- **A recipe that newly fits:** after a new monitor or program, it shows up again on its own.
- **Run `kitchen check <dir>` on each cookbook once.** Leave out recipes it reports problems with.

Just before you offer each recipe, not all of them up front:

- **Is it plainly not for them?** Read its `applies_to` and Problem. Leave out anything for a setup they clearly don't have, like a gaming mouse or a laptop docked with the lid shut, and keep a short reason.
- **Do they already handle it?** Compare its `touches` and fix with their private repo. If they already customize the same thing, say what they have and how the recipe differs, or leave it out if it adds nothing.
- **Is it safe?** Give it a safety review ([safety.md](safety.md)), or reuse its saved verdict (see "Verdicts" below). Never offer a `reject`; note it for the end.
- **How would you do it here?** If your way differs from the recipe, plan to say so.

Doing this one recipe at a time keeps the person from waiting, and no review is spent on recipes they never get to.

### 4. Upkeep

- **Obsolete recipes.** For the person's applied recipes and their own cookbook's recipes, compare `obsolete_since` with `omarchy version`. Where Omarchy now does it, offer to undo the customization ([apply.md](apply.md)) and to mark the recipe in their cookbook.
- **Updates to applied recipes from cookbooks they don't follow.** Check the `from` repo of each applied record the same way as part 3.

### Verdicts

A safety verdict holds for exactly the recipe it reviewed. Save each one in `~/.cache/omarchy-kitchen/verdicts/<tree>.txt`.
- `<tree>` is the git tree id of the recipe's folder: `git -C <cookbook-dir> rev-parse HEAD:recipes/<folder>`.
- The tree id changes when anything in the folder changes, so a changed recipe is always reviewed again.
- Before reviewing a recipe, look for its verdict file and reuse it if it's there.
- Never edit a verdict by hand, and never reuse one across a different tree id.

## Going through it

**Open with two or three lines:** what's waiting, and how it works. For example:

> This week there's a new version of the method, one change of yours worth sharing, and 4 new recipes from duff's cookbook that fit your machine. I'll go one at a time. For each, say apply, skip, later, or ask me anything, and say stop whenever you like.

The first time (`last_review` is empty), add that this review comes back once a week.

**Order:**
1. the method update
2. their changes worth sharing
3. new and changed recipes from cookbooks they follow, most useful first: bugs and problems they're likely to hit, then matters of taste
4. upkeep
5. Then, if `kitchen pending` listed `older` recipes, ask whether to keep going: "There are 30 more from earlier you haven't decided on. Keep going, or leave them for another time?"

**Each item is written for a person, not a system:**
- **A heading:** the problem, as they'd say it. The recipe's title usually works.
- **Where it's from,** in plain words: "From duff's cookbook." No ids, folder names, commits, or links unless they ask.
- **What happens:** two to four sentences on what happens today on their machine, and what would change.
- **How it fits them:** "Your Framework has a battery, so this applies." Or how you'd do it differently here: "I'd add this to your existing kanata setup instead of installing keyd."
- **Anything to know before saying yes,** in plain words: it needs their password, installs something, runs in the background, or changes their agent's settings (quote the line it adds). Mention the safety review only when it found something worth saying.
- **The choices:** apply, skip, later, or ask.

For example:

> **Reboot closes everything without asking**
> From duff's cookbook.
>
> Right now, choosing Reboot from the menu, or pressing Ctrl+Alt+Delete, closes all your windows at once. This adds a quick "Are you sure?" to both.
>
> It fits your machine as written: two small config changes, and nothing needs your password.
>
> Apply, skip, later, or ask me about it?

Their own changes read the same way: "On Oct 4 you made the mouse less jumpy. Worth sharing as a recipe? I'd leave out your mouse's model name." So does a method update: what will work differently for them, in plain words.

**Answers:**
- **Apply, publish, or adopt:** do it now, then go to the next item.
  - **A recipe:** follow [apply.md](apply.md).
  - **Their change:** follow [publish.md](publish.md). The yes covers committing and pushing it to the cookbook.
  - **A method update:**
    - `git -C ~/.local/share/omarchy-kitchen checkout --quiet <tag>`, then run `~/.local/share/omarchy-kitchen/install`.
    - Set `"method": "<tag>"` in `kitchen/settings.json`.
    - If the changelog says cookbooks must change, say so when you explain the update, so their yes covers it too. Then, in the same step, convert their cookbook, set `kitchen` in `cookbook.json` and the version in its check workflow, run `kitchen check`, and commit and push the cookbook.
- **Skip:** for a recipe, add `{id, version, date, why}` to `declined` in review.json, so it isn't offered again until its version changes. For a method update, set `"method_declined": "<tag>"`; a newer version asks again.
- **Later:** record nothing. It comes back next time.
- **A question, or "tell me more":** answer from the recipe and their machine. Show the recipe's actual change, or the whole recipe if they want it. Give the link only if they ask. Then offer the choices again.
- **Stop:** everything not reached waits for next time.

**At the end,** in a few lines:
- what was applied, published, skipped, or left for later
- what you left out without asking. Name each one by its problem (the recipe's title is written that way), then say why in a few words, so the person can tell whether it matters to them:

  > Left out, since they don't seem to fit you:
  > - Gaming mouse moves the cursor too fast to place it precisely: you don't have a gaming mouse.
  > - Dictated text types out slowly: you don't use Voxtype.
  > - Laptop screen stays black after undocking with the lid shut and sleeping: you don't use a dock.
  >
  > If any of these does matter to you, say so and we'll look at it.

  When there are many, group them under each reason. Name every recipe that failed the safety check, and say why.

## Finishing

Update `kitchen/review.json`:

- `last_review`: today
- `reviewed_through`: the private repo's `HEAD` before any commits this review made
- `cookbooks`: for each followed cookbook, the commit you read up to. `kitchen pending` uses it to tell new recipes from older ones; undecided recipes stay available either way.
- `declined`: as above

Then remove the snooze with `kitchen snooze --clear`. Commit and push `kitchen/review.json`, with any applied recipes in their own commits. Doing the review was the ask. Committing review.json is how the other machines learn the review is done.
