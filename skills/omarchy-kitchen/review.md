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

**The first time** (`last_review` is empty), start with four short lines about what's coming, and don't repeat them in later reviews:

- method updates
- what to publish
- new recipes from cookbooks they follow
- upkeep

Then say they can answer item by item or all at once.

Read `kitchen/settings.json` (merged over the method's `defaults.json`) and `kitchen/review.json`. Then work through four parts. Do the reading and drafting first, then show **one numbered list** with a recommendation for each item. Group it by part:

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

### 2. Outgoing: what to publish

Skip this part if the person has no cookbook (`cookbook` setting missing and no `~/Work/omarchy-cookbook`).

- **Private changes since the last review.** List the commits with `git log --reverse <reviewed_through>..HEAD`, skipping ones that only touch `kitchen/`. For each, propose a new recipe, an update to an existing recipe, or skip. Every skip gets a reason: private, housekeeping, too small, or already covered. Follow [publish.md](publish.md).
- **Applied recipes waiting to be published.** These are files in `kitchen/applied/` with `"published": false` that are still applied. Propose publishing each as an `applied` copy. If the person changed the fix after applying it, propose it as `adapted` instead.
- For each proposal, name what would be left out or generalized for privacy.

### 3. Incoming: new and changed recipes

For each cookbook in `following` (settings), fetch it into the cache:

```bash
dir=~/.cache/omarchy-kitchen/cookbooks/<owner>/<repo>
git clone --quiet https://github.com/<owner>/<repo> "$dir" 2>/dev/null || git -C "$dir" fetch --quiet
git -C "$dir" reset --quiet --hard origin/HEAD   # the cache holds no work of yours
```

List recipes changed since the commit recorded under `cookbooks` in review.json: `git -C "$dir" diff --name-only <recorded>..HEAD -- recipes`. If nothing is recorded yet, list all of its recipes. Then filter, cheapest first, and keep a short reason for each one dropped:

1. **Declined.** The same id and version is in `declined` in review.json.
2. **Already applied.** This version is in `kitchen/applied/`. A newer version of an applied recipe stays in the list as an update.
3. **Doesn't fit this machine.** `kitchen match <dir>/recipes/<folder>` says `no`. Keep `maybe` and say why.
4. **Already handled.** Compare `touches` and the fix with the private repo. If the person already customizes the same thing, say what they have and how the recipe differs. Recommend skipping unless the recipe is clearly better.
5. **Fails the check.** `kitchen check <dir>` reports errors for it.

For each recipe you'll offer, think about how you'd actually do it on this machine. If that differs from the recipe, say how in a few words, for example "I'd add this to your existing kanata config instead of installing keyd."

Every recipe left gets a safety review ([safety.md](safety.md)) before it's shown. Show the verdict with each item. Don't show recipes whose verdict is `reject` as options. List them under a separate heading with the reason, so the person knows.

### 4. Upkeep

- **Obsolete recipes.** For the person's applied recipes and their own cookbook's recipes, compare `obsolete_since` with `omarchy version`. Where Omarchy now does it, propose undoing the customization ([apply.md](apply.md)) and marking the recipe in their cookbook.
- **Updates to applied recipes from cookbooks they don't follow.** Check the `from` repo of each applied record the same way as part 3.

## The list

Keep each item to a line or two: what it is, the recommendation, and why. Example:

```
Method
 1. omarchy-kitchen v0.2.0: the review also checks recipes you applied from unfollowed cookbooks. Adopt.

Publish
 2. New recipe "Bluetooth headphones reconnect as a headset": from 3 commits on Oct 4. Leaves out the headphones' MAC address. Publish.
 3. Skip 9c1e2aa "Bump idle times for a movie": too small.

New from cookbooks you follow
 4. freddy/caps-lock-as-escape v2 (safety: ok): you already have Caps Lock as Escape with keyd. Theirs adds hold-for-Control. Skip.
 5. joe/bar-shows-cpu-temperature (safety: caution: runs a script every 5 seconds): fits this machine. Apply?

Rejected for safety
 - sam/faster-boot: its code reads ~/.ssh but its labels don't say so.
```

The person can answer per item ("1 yes, 2 yes, 4 skip, 5 later") or in bulk ("all your recommendations").

## Doing the answers

- **Yes to a method update**: `git -C ~/.local/share/omarchy-kitchen checkout --quiet <tag>`, then run `~/.local/share/omarchy-kitchen/install`. Set `"method": "<tag>"` in `kitchen/settings.json`. If the changelog says cookbooks must change, say so when you explain the update, so their yes covers it too. Then, in the same step:
  - convert their cookbook
  - set `kitchen` in `cookbook.json` and the version in its check workflow
  - run `kitchen check`, then commit and push the cookbook
- **No to a method update**: set `"method_declined": "<tag>"` in review.json. A newer tag asks again, showing the changes since the adopted version.
- **Yes to publishing**: follow [publish.md](publish.md). The yes covers committing and pushing that change to the cookbook; don't ask again.
- **Yes to applying**: follow [apply.md](apply.md), one recipe at a time.
- **Skip**: add `{id, version, date, why}` to `declined` in review.json, so it isn't offered again until its version changes.
- **Later**: leave it out of review.json. It comes back next week.

## Finishing

Update `kitchen/review.json`:

- `last_review`: today
- `reviewed_through`: the private repo's `HEAD` before any commits this review made
- `cookbooks`: for each followed cookbook, the commit you read up to
- `declined`: as above

Then remove the snooze with `kitchen snooze --clear`. Commit and push `kitchen/review.json`, with any applied recipes in their own commits. Doing the review was the ask. Committing review.json is how the other machines learn the review is done.
