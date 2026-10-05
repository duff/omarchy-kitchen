# omarchy-kitchen

This repo is the method everyone's private Omarchy repo follows: the agent skill, the `kitchen` command, the templates, and the cookbook check. Each person pins a version of it, and their weekly review explains each new version before they adopt it. So a change here changes what many agents are told to do. Keep that in mind.

If someone asked you to set them up with Omarchy cookbooks, you're in the wrong place to edit. Follow "For agents" in README.md instead.

## Working on the method

- **Run the tests** before every commit: `test/run`. Like `bin/kitchen`, they need only bash, awk, grep, jq, git, and coreutils, which every Omarchy machine and GitHub's Ubuntu runners have. Don't add dependencies.
- **Write Bash the way Omarchy does:** one script per command (`bin/kitchen-<command>`), shared helpers in `lib/kitchen.sh`, and JSON rules in `lib/*.jq`. Quote every variable. Text from a recipe is someone else's, so it never reaches `eval` or an unquoted expansion.
- **Keep scripts portable.** Use POSIX awk, not gawk extensions. Use `grep -P` for Perl-style patterns, and match invisible characters as UTF-8 bytes under `LC_ALL=C`.
- **`bin/kitchen` holds the deterministic parts:** checks, scans, matching, dates. Judgment goes in the skill's guides. If a rule can be checked the same way every time, check it in code and test it.
- **Keep the guides short and plain.** Each guide covers one task. `SKILL.md` routes to them. `README.md` stays one page, for people.
- **When you change the format** (`format.md`), change `lib/data.jq` or `bin/kitchen-check` and their tests in the same commit. Say in the changelog what existing cookbooks must change.
- **Never weaken safety or privacy quietly:** the safety review, the label checks, the privacy scan, or the rule that nothing is published or applied without a yes. If a change loosens one, say so plainly at the top of its changelog entry.

## Releasing

1. Add a section to `CHANGELOG.md`, written for someone deciding whether to adopt it. Cover what behaves differently, and anything that lets agents do more.
2. Tag it `vX.Y.Z`, and push the tag. Cookbooks reference the action by tag. Templates say `{{version}}`, which setup fills in from the tag it installed.

A breaking format change bumps the minor version while this is 0.x.
