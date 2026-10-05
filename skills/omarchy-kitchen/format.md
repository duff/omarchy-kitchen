# Recipe format

A cookbook is a public GitHub repo, normally `<github-username>/omarchy-cookbook`:

```
omarchy-cookbook/
  README.md            # for people: whose cookbook this is, and every recipe linked by topic
  AGENTS.md            # for agents: this cookbook follows omarchy-kitchen
  CLAUDE.md            # one line, @AGENTS.md
  cookbook.json        # owner, method version, description
  recipes/
    <slug>/
      RECIPE.md        # the write-up, then the recipe data
      files/           # optional: scripts or configs too long to show inline
  .github/workflows/check.yml
```

`kitchen check` enforces everything below. A cookbook that fails it is left out of the library.

## cookbook.json

```json
{
  "owner": "duff",
  "kitchen": "v0.1.0",
  "description": "Duff's Omarchy customizations, one problem per recipe.",
  "allow": ["Duff"]
}
```

- `owner`: the GitHub username.
- `kitchen`: the omarchy-kitchen version this cookbook follows.
- `description`: one line, shown in the library. Describe the cookbook as yours, not as your current machines: those change, and most recipes fit any Omarchy machine.
- `allow` (optional): exact words the privacy scan should accept, like your first name.

## One recipe, one problem

Name the folder after the symptom someone would search for, not the fix: `workspaces-open-on-the-wrong-monitor`, not `workspace-rules`. Lowercase letters, digits, and hyphens.

Most recipes fit any Omarchy machine. If one needs particular hardware, say so in its title or the first line of its Problem, like "MacBook T2 trackpad moves the cursor while typing". People then see it without reading to the recipe data at the end.

A recipe applied from someone else's cookbook keeps their slug. If your cookbook already has a folder by that name, use `<their-username>--<slug>`.

## RECIPE.md

The write-up comes first, for people browsing on GitHub. The last section, `## Recipe data`, holds one JSON code block with the recipe's data for agents and the library, and nothing else. Write the JSON compactly, with one top-level field per line, and lists and objects on the same line as their field:

````markdown
# Workspaces open on unpredictable monitors

## Problem
## Why it happens
## Fix
## Apply and check
## Undo
## Notes
## History

- Created by [@duff](https://github.com/duff) on 2026-10-01.

## Recipe data

```json
{
  "id": "duff/workspaces-open-on-the-wrong-monitor",
  "title": "Workspaces open on unpredictable monitors",
  "summary": "Give each monitor its own block of workspace numbers.",
  "version": 1,
  "tested_on": {"omarchy": "4.0.4", "hyprland": "0.56.2"},
  "applies_to": "Setups with two or more monitors.",
  "requires": [{"monitors": 2}],
  "touches": ["~/.config/hypr/monitors.lua"],
  "root": false,
  "network": false,
  "installs": [],
  "runs": [],
  "agent_config": false,
  "history": [{"who": "duff", "did": "created", "date": "2026-10-01"}]
}
```
````

### Data fields

| Field | Required | What it holds |
|---|---|---|
| `id` | yes | `<github-username>/<slug>`. Never changes while the recipe is copied around. Only adapting it gives a new id. |
| `title` | yes | The problem in the words someone would search for. Same as the `#` heading. |
| `summary` | yes | The fix in one line, for lists and the library. |
| `version` | yes | Starts at 1. Bump it when the fix changes, not for wording. |
| `tested_on` | yes | Versions as strings: `omarchy` always, plus `hyprland` or any app the fix depends on. |
| `applies_to` | yes | One line for people: "Every machine.", "Laptops.", "Dell XPS 16 laptops." |
| `requires` | yes | What a machine must have, for agents to check. `[]` means any machine. See below. |
| `touches` | yes | Every file the fix writes, with `~` for home. `[]` if it only runs commands. |
| `root` | yes | `true` if any step needs sudo or writes outside home. |
| `network` | yes | `true` if the fix downloads something itself, or makes the machine talk to the network afterward. Installing the packages in `installs` doesn't count. |
| `installs` | yes | Packages, plugins, or tools the fix installs, like `keyd` or `aur/voxtype-bin`. `[]` for none. |
| `runs` | yes | Things that start on their own afterward: services, timers, hooks, autostart entries, shell startup files, udev rules. `[]` for none. |
| `agent_config` | yes | `true` if the fix changes agent instructions or settings: `CLAUDE.md`, `AGENTS.md`, `~/.claude`, skills, hooks, permissions. |
| `upstream` | no | `default` if this would make a better Omarchy default, `bug` if it works around an Omarchy bug. |
| `upstream_link` | no | The issue or pull request upstream. |
| `obsolete_since` | no | The Omarchy version that made this recipe unnecessary, as a string. |
| `history` | yes | Who created, applied, or adapted it. See below. |

The labels (`root`, `network`, `installs`, `runs`, `agent_config`) have to be honest. `kitchen check` looks at the code in Fix, Apply and check, Undo, and `files/`. If the code does something the labels don't admit, the cookbook fails the check. Saying `true` when unsure is fine.

### requires

Every item has to hold for a recipe to fit:

| Item | Fits when |
|---|---|
| `{"laptop": true}` | the machine is a laptop (`false`: isn't one) |
| `{"vendor": "Dell"}` | the maker contains this text |
| `{"model": "XPS 16"}` | the model or product family contains this text |
| `{"monitors": 2}` | at least this many monitors are connected (fewer: maybe) |
| `{"monitor": "StudioDisplay"}` | a connected monitor's make or model contains this text (none: maybe) |
| `{"device": "ErgoDox"}` | an input device's name contains this text (none: maybe) |
| `{"command": "voxtype"}` | the program is installed |
| `{"package": "keyd"}` | the package is installed |

A recipe that installs something doesn't require it. A recipe about tuning Voxtype requires `{"command": "voxtype"}`. A recipe that installs keyd doesn't require `{"package": "keyd"}`.

### history

```json
"history": [
  {"who": "freddy", "did": "created", "date": "2026-09-12"},
  {"who": "joe", "did": "applied", "date": "2026-10-02", "from": "freddy/omarchy-cookbook@4f2a9c1"},
  {"who": "duff", "did": "adapted", "date": "2026-10-20", "from": "joe/omarchy-cookbook@91bd03e", "parent": "freddy/caps-lock-as-escape"}
]
```

- The first entry is `created`.
- `applied` means copied unchanged. The id stays the same.
- `adapted` means the fix changed. The id becomes `<adapter>/<slug>`, and `parent` keeps the old id.
- Applied and adapted entries say exactly where the copy came from: `<owner>/<repo>@<commit>`.
- The last entry is always the cookbook's owner.
- A copy knows how it reached you, not who applied it after you. The library counts that.

The `## History` section repeats the data's history with links, because GitHub doesn't link `@username` inside repo files:

```markdown
## History

- Created by [@freddy](https://github.com/freddy) on 2026-09-12.
- Applied by [@joe](https://github.com/joe) on 2026-10-02, from [freddy/omarchy-cookbook@4f2a9c1](https://github.com/freddy/omarchy-cookbook/tree/4f2a9c1/recipes/caps-lock-as-escape).
- Adapted by [@duff](https://github.com/duff) on 2026-10-20, from [joe/omarchy-cookbook@91bd03e](https://github.com/joe/omarchy-cookbook/tree/91bd03e/recipes/caps-lock-as-escape): <what changed, in one line>.
```

### Body sections

- **Problem** (required): what stock Omarchy does, and why that gets in the way. One or two short paragraphs.
- **Why it happens** (recommended): where the stock behavior comes from: the file under `/usr/share/omarchy/`, the setting, the script.
- **Fix** (required): the change, with paths under `~/.config/` and the snippet. Never edit `/usr/share/omarchy/`.
  - Other agents treat a Fix as a suggestion and implement it their own way, so explain why it works, not just what to type.
  - Say which parts are specific to your machine.
- **Apply and check** (required): the commands that apply it, and how to confirm it worked.
- **Undo** (required): how to put things back, including packages, services, and files outside `~/.config`.
- **Notes** (optional): trade-offs and things that didn't work.
- **History** (required): as above.
- **Recipe data** (required, last): the JSON code block, and nothing else.

### files/

For scripts or configs too long to show inline. Every file in `files/` has to be named in RECIPE.md as `files/<name>`, so nothing ships unseen. No symlinks.

## Never in a recipe

`kitchen check` rejects these:

- a download piped straight into a shell (`curl ... | sh`)
- HTML comments, which GitHub hides from people but agents still read
- zero-width or text-direction characters
- fields the format doesn't define

`kitchen scan` looks for private data. The privacy rules are in [publish.md](publish.md).
