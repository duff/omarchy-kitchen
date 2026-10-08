# omarchy-kitchen

Share your [Omarchy](https://omarchy.org/) customizations as recipes, and pick up other people's. Your agent does the legwork; you decide every step.

## How it works

- **Your private repo** (`my-omarchy`) holds your real config, for every machine you own.
- **Your cookbook** (`omarchy-cookbook`) is optional and public. It holds recipes: one problem each, with what stock Omarchy does, the fix, how to check it, and how to undo it.
- **You follow** cookbooks from people you trust. Your agent checks the account and safety-reviews every recipe before you follow one. If you make a cookbook, it gives you a note to send the person who invited you, so they can follow you back.
- **Once a week**, opening your agent in `my-omarchy` offers a review:
  - changes of yours worth publishing
  - new recipes from cookbooks you follow, if they fit your machine and you don't already have something better
  - new versions of this method

  Your own changes come as one list, and you can publish them all at once, pick some, or go one by one. Everything else goes one at a time, each described as a problem in plain words, and you say apply, skip, later, or ask about it. Stop whenever you like; the rest waits. If it's not a good time, tell it when.
- **Recipes are suggestions.** Your agent solves each problem its own way, fitted to your machine, your software, and how you like things. It borrows from the recipe where that fits.
- **Recipes from others** get a safety review before you see them.
- **Anything you apply can be undone.**
- **The [library](https://github.com/duff/omarchy-library)** lists every public cookbook.

Reviews involve judgment calls, so they work best at high effort or above. In Claude Code, `/effort` shows and changes it. The safety reviews always run at `xhigh`.

## Get started

In a terminal on your Omarchy machine, ask your agent:

> Set me up with Omarchy cookbooks from github.com/duff/omarchy-kitchen.

Add "and follow \<username\>'s cookbook" to start with someone's recipes. Your agent asks before creating anything: a private GitHub repo for your config, and a public cookbook if you want one.

## What's here

| Path | What it is |
|---|---|
| `skills/omarchy-kitchen/` | The instructions agents follow. [format.md](skills/omarchy-kitchen/format.md) is the recipe format. |
| `agents/` | The read-only safety reviewer for Claude Code, at `xhigh` effort. |
| `bin/kitchen` | Checks recipes, scans for private data, checks if a recipe fits a machine, describes your setup, and tracks the review schedule. |
| `templates/` | The starting private repo and cookbook. |
| `action.yml` | The check every cookbook runs on push. |
| `test/` | Tests for `bin/kitchen` and the templates, plus agent scenarios in `test/evals/`. |

## For agents

If someone asked you to set them up:

1. Clone this repo into `~/.local/share/omarchy-kitchen`.
2. Check out the newest tag, and run `./install`.
3. Follow `skills/omarchy-kitchen/setup.md`.

## Changes

New versions are tags, described in [CHANGELOG.md](CHANGELOG.md). Everyone's weekly review explains a new version and asks before adopting it. Pull requests are welcome.
