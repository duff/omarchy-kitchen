# Publishing recipes

A recipe is a public write-up of one problem and its fix, drawn from the person's private repo. Nothing is written to the cookbook until the person has said yes to that item in the weekly review, or asked for it directly.

## Nothing private, ever

The cookbook is public, and may be read by people, agents, and search engines. Leave out:

- **People's names and personal details:** family details, email addresses, phone numbers, signatures. The cookbook owner's GitHub username and first name are fine. Their surname, age, and birth year aren't.
- **Machine and network identifiers:** hostnames, usernames in paths (write `~`, not `/home/<user>`), IP addresses, MAC addresses, Wi-Fi network names, Tailscale names, display or device serial numbers.
- **Revealing accounts and services:** anything that reveals finances, health, school, or home life, such as brokerages, banks, trading tools, calendars, Home Assistant entities and URLs, or children's curricula.
- **Private work:** names of private projects or repos.
- **Secrets:** any token, key, or credential, even an expired one.

When the technique is useful but the example is private, generalize it: "two logins to the same site as separate web apps", not the real site and account. When even the idea is private, skip it, and give "private" as the reason.

## Writing a new recipe

1. Find the problem the change solved. Name the folder after the symptom someone would search for ([format.md](format.md)).
2. Check the cookbook for a recipe on the same problem. If there is one, update it instead: bump `version` if the fix changed.
3. Write `recipes/<slug>/RECIPE.md` with the header and sections in [format.md](format.md):
   - Read the stock files under `/usr/share/omarchy/` to explain **Why it happens**.
   - Show only the snippet that fixes the problem, never the whole private file.
   - Make **Undo** complete: packages, services, and files outside `~/.config` too.
   - Set `tested_on` from `omarchy version` and `hyprctl version`.
   - Set `requires` and the labels honestly. Saying true when unsure is fine.
   - Add `upstream: bug` or `upstream: default` if this is an Omarchy bug or a better default. Link the issue if one exists.
4. Add the recipe to the cookbook's README.md, under the right topic, with a one-line summary.
5. Run the checks:

   ```bash
   K=~/.local/share/omarchy-kitchen/bin/kitchen
   $K check <cookbook>
   $K scan --local --words <private-repo>/kitchen/private-words --cookbook <cookbook>
   ```

   Fix everything `check` reports. For each `scan` finding, generalize the text, or, if it's truly fine to publish, add the exact string to `allow` in `cookbook.json` and say so to the person.
6. Show the person what will be published, if they haven't already seen the draft. Then commit and push the cookbook, following their rules for how to write commits. Their yes to publishing this item is the ask to commit and push it.

## Publishing a recipe applied from someone else

When the weekly review approves an applied recipe (a `kitchen/applied/*.json` record with `"published": false`):

1. Copy the recipe folder exactly as it was applied: the source commit is in the record's `from`. Use the folder name from [format.md](format.md).
2. Append a history entry, and the matching line in `## History`:

   ```json
   {"who": "<owner>", "did": "applied", "date": "<the date it was applied>", "from": "<their-owner>/<their-repo>@<commit>"}
   ```

3. If the person changed the fix after applying it, publish it as **adapted** instead:
   - The id becomes `<owner>/<slug>`, with `parent:` set to the old id.
   - `version` goes back to 1.
   - Write one line in `## History` saying what changed.
   - Don't count wording changes as adapting.
4. Run the checks above. Copied text needs the privacy scan as much as new text does.
5. Set `"published": true` in the applied record, in the private repo.

## The library

A cookbook is listed in the library when its repo has the GitHub topic `omarchy-cookbook`. Setup asks the person about this ([setup.md](setup.md)). Removing the topic removes the cookbook at the next daily build.
