# Setup

## Setting up a new person

The usual request is "Set me up with Omarchy cookbooks from github.com/duff/omarchy-kitchen", sometimes followed by "and follow <username>'s cookbook". Ask before each step that creates something. Keep the explanations short: the person may be new to all of this.

1. **Check the basics:**
   - `omarchy version`, to confirm this is Omarchy.
   - `git --version`.
   - `gh auth status`. If GitHub isn't logged in, ask the person to run `gh auth login` in a terminal, and wait.
   - `gh auth setup-git`, so `git push` over HTTPS uses the same login.
   - Get their GitHub username: `gh api user --jq .login`.
   - Ask what first name to use in their README.

2. **Install the method,** unless `~/.local/share/omarchy-kitchen` already exists:

   ```bash
   git clone --quiet https://github.com/duff/omarchy-kitchen ~/.local/share/omarchy-kitchen
   cd ~/.local/share/omarchy-kitchen
   git checkout --quiet "$(git tag --sort=-v:refname | head -1)"
   ./install
   ```

   `install` links the skill where Omarchy's agents look for skills, the same places Omarchy links its own.

3. **Create the private repo.** If `~/Work/my-omarchy` already exists, see "Adding the kitchen to an existing private repo" below. Otherwise:
   - Copy `templates/my-omarchy/` to `~/Work/my-omarchy`.
   - Replace these placeholders in every file, including `.claude/settings.json`:
     - `{{username}}`
     - `{{name}}`
     - `{{version}}`: the tag you checked out
     - `{{home}}`: their home folder, as an absolute path
     - `{{year}}`: this year
   - Run `./snapshot.sh`. It lists files that differ from stock Omarchy. Go through them with the person, and sort each one by RULES.md: every machine (`config/`), this machine only (`hosts/<hostname>/`), or not in git. Explain the choice in a few words for each.
   - Ask, then create the GitHub repo. It is **private**:

     ```bash
     git -C ~/Work/my-omarchy init -q -b main
     gh repo create <username>/my-omarchy --private --source ~/Work/my-omarchy --remote origin
     ```

   - Commit and push, following the person's rules for commits. If they have none yet, ask first.

4. **Offer a cookbook.** Ask: "Do you want a public cookbook, so you can share your fixes with others?"
   - **If yes:**
     - Copy `templates/omarchy-cookbook/` to `~/Work/omarchy-cookbook`, and fill in the placeholders.
     - The template includes an MIT license, so others may reuse the recipes. Mention it, and ask whether they'd prefer another license.
     - Create the repo with `gh repo create <username>/omarchy-cookbook --public --source ~/Work/omarchy-cookbook --remote origin`.
     - Commit and push. It starts empty; the weekly review fills it.
   - **Then ask:** "Should it be listed in the Omarchy cookbook library, so others can find it?" On yes, run `gh repo edit <username>/omarchy-cookbook --add-topic omarchy-cookbook`. Otherwise, leave the topic off; they can add it any time.
   - **If no:** leave out the cookbook. The weekly review then skips publishing.

5. **Let the agent reach the other folders.** The agent works from `~/Work/my-omarchy`, but it also reads and writes `~/Work/omarchy-cookbook` and `~/.cache/omarchy-kitchen`, and pushes the cookbook.
   - **Claude Code:** the template's `.claude/settings.json` lists both folders under `permissions.additionalDirectories`. Claude Code uses it after the person trusts the folder the first time they start Claude there.
   - **Other agents:** find their equivalent setting (writable folders, and network for git push), and set it with the person's OK. If there's none, tell the person they'll see permission prompts for the cookbook.

6. **Follow cookbooks.** Add the ones the person named to `following` in `kitchen/settings.json`, as `<owner>/<repo>`, normally `<owner>/omarchy-cookbook`. Mention that they can browse the library for more any time.

7. **Run a first review now,** if they'd like. With nothing published yet, it's mostly part 3: recipes from the cookbooks they follow that fit their machine.

8. **Explain how it works from here,** in three or four lines, using `kitchen status`:
   - Once a week, opening their agent in `~/Work/my-omarchy` offers a review. They can say when, if not now.
   - "Apply", "undo", or "publish" a recipe any time.
   - Everything waits for their yes.

## A second machine

On the new machine, clone the private repo and run its install step:

```bash
gh repo clone <username>/my-omarchy ~/Work/my-omarchy
~/Work/my-omarchy/install.sh
```

`install.sh` installs omarchy-kitchen at the version `kitchen/settings.json` names.

## Adding the kitchen to an existing private repo

For someone who already keeps their Omarchy config in a repo:

1. Add `kitchen/settings.json`, `kitchen/review.json`, `kitchen/private-words`, and `kitchen/applied/` from `templates/my-omarchy/kitchen/`.
2. Add `kitchen/snooze` to `.gitignore`.
3. Add the session-start check to the repo's agent instructions (`AGENTS.md` or `CLAUDE.md`). Copy the paragraph from `templates/my-omarchy/AGENTS.md`.
4. Add the omarchy-kitchen block from `templates/my-omarchy/install.sh` to their install script, so other machines get the method too.
5. If they already publish recipes somewhere, move the old review bookmark into `reviewed_through` and `last_review` in `kitchen/review.json`.

## Following and unfollowing

- Following or unfollowing is an edit to `following` in `kitchen/settings.json`.
- A newly followed cookbook's recipes all come up in the next review, or right away if the person asks.
- Unfollowing leaves applied recipes alone. They stay until undone.

## Joining or leaving the library

The library lists every public repo with the topic `omarchy-cookbook`, rebuilt daily.

- **Join:** `gh repo edit <username>/omarchy-cookbook --add-topic omarchy-cookbook`.
- **Leave:** the same command with `--remove-topic`.
