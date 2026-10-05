# my-omarchy

This is {{name}}'s private Omarchy config: the real setup of every Omarchy machine they own. It stays private.

Every task in this repo is an Omarchy customization. Load the `omarchy` skill and the `omarchy-kitchen` skill before starting, even when the request doesn't say "Omarchy". Follow `RULES.md` to decide where each change goes.

## Commits

When I say yes to a change, commit it and push it right away: one change per commit, with a short, plain-English subject in the imperative, like "Turn on natural scrolling" or "Apply recipe duff/battery-percentage-not-shown-in-the-bar". Never rewrite history that's already pushed. Change this section to work differently.

## Each session

At the start of each session, run `~/.local/share/omarchy-kitchen/bin/kitchen due`, and follow "At the start of a session" in the omarchy-kitchen skill's `review.md`. If the review is due, ask once whether to do it now or when.
