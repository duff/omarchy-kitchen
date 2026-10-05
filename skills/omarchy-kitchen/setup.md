# Setup

## Setting up a new person

The usual request is "Set me up with Omarchy cookbooks from github.com/duff/omarchy-kitchen", sometimes followed by "and follow <username>'s cookbook". Ask before each step that creates something. Keep the explanations short: the person may be new to all of this.

1. **Check the basics,** and sort out anything missing yourself, so the person never needs to prepare anything before asking:
   - `omarchy version`, to confirm this is Omarchy.
   - `git --version`.
   - `gh --version`. Omarchy installs the GitHub CLI during its own setup. If it's missing, install it with the person's OK: `omarchy mise install gh`.
   - `gh auth status`. If they aren't signed in to GitHub:
     - Ask whether they have a GitHub account. If not, send them to https://github.com/signup and wait until they've made one.
     - Explain that you need them to sign in to GitHub once, so you can keep their config in a private repo.
     - In Claude Code, they can type `! gh auth login --web` right in the prompt. With other agents, they run `gh auth login --web` in another terminal. It opens the browser and shows a one-time code.
     - Wait for them, then check `gh auth status` again.
   - Let git use that GitHub login, calling `gh` by name so it keeps working after `gh` updates and on their other machines:

     ```bash
     for host in https://github.com https://gist.github.com; do
       git config --global --replace-all "credential.$host.helper" ''
       git config --global --add "credential.$host.helper" '!gh auth git-credential'
     done
     ```

     Don't use `gh auth setup-git`: it writes this machine's full path to `gh` into the git config. Tell the person in a sentence that git now uses their GitHub login.
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

   - Commit and push. The new repo's `AGENTS.md` has a "Commits" section with sensible defaults: commit and push each change as soon as they say yes, one change per commit. Use it without asking. Mention once that they can change that section if they'd like to work differently.

4. **Offer a cookbook.** Ask: "Do you want a public cookbook, so you can share your fixes with others?"
   - **If yes:**
     - Copy `templates/omarchy-cookbook/` to `~/Work/omarchy-cookbook`, and fill in the placeholders.
     - The template includes an MIT license, so others may reuse the recipes. Mention it, and ask whether they'd prefer another license.
     - Create the repo with `gh repo create <username>/omarchy-cookbook --public --source ~/Work/omarchy-cookbook --remote origin`.
     - Commit and push. It starts empty; the weekly review fills it.
     - **Then ask:** "Should it be listed in the Omarchy cookbook library, so others can find it?" On yes, run `gh repo edit <username>/omarchy-cookbook --add-topic omarchy-cookbook`. Otherwise, leave the topic off; they can add it any time.
   - **If no:** leave out the cookbook, and don't ask about the library. The weekly review then skips publishing.

5. **Let the agent reach the other folders.** The agent works from `~/Work/my-omarchy`, but it also reads and writes `~/Work/omarchy-cookbook` and `~/.cache/omarchy-kitchen`, and pushes the cookbook.
   - **Claude Code:** the template's `.claude/settings.json` lists these folders, plus the method's own folder, under `permissions.additionalDirectories`. The safety reviewer reads from all three. Claude Code uses it after the person trusts the folder the first time they start Claude there.
   - **Other agents:** find their equivalent setting (writable folders, and network for git push), and set it with the person's OK. If there's none, tell the person they'll see permission prompts for the cookbook.

6. **Continue in the new repo.** The rest of setup needs a session started in `~/Work/my-omarchy`.
   - **What that brings:** its `AGENTS.md` (commit rules) and its `.claude/settings.json` (folder access) take effect. In Claude Code, a new session also loads the `kitchen-safety-reviewer` agent: `install` created `~/.claude/agents/` after this session started, and Claude Code only watches folders that existed at startup.
   - **What to tell them, in Claude Code:** quit with `/exit`, then run `cd ~/Work/my-omarchy && claude`. When Claude asks whether to trust the folder, say yes. Then type the line to finish, which you write out for them with the cookbooks they named, for example: *Finish setting up and follow duff's cookbook.*
   - **Other agents:** the same, starting that agent in `~/Work/my-omarchy`.
   - **In the new session:** `kitchen/settings.json` and the repo show how far setup got. Carry on from step 7.

7. **Follow cookbooks.** For each one the person named, follow "Following a cookbook" below: confirm the account, check the cookbook, and add it to `following`. Then commit and push `kitchen/settings.json`.

8. **Offer a first look at those recipes now,** if they'd like. It's the weekly review's one-at-a-time walk-through ([review.md](review.md)), and they can stop whenever they like. Whatever they don't get to waits for next time.

9. **Explain how it works from here,** in three or four lines, using `kitchen status`:
   - Once a week, opening their agent in `~/Work/my-omarchy` offers a review. They can say when, if not now.
   - "Apply", "undo", or "publish" a recipe any time.
   - Everything waits for their yes.
   - The weekly review involves judgment calls, so it works best at high effort or above. In Claude Code, `/effort` shows and changes it.

10. **Offer a note to send back,** if they made a public cookbook and someone invited them, meaning they followed that person's cookbook. Give them a short message, ready to text or email, filled in with their own username:

   > I set up my Omarchy cookbook: https://github.com/sam-example/omarchy-cookbook
   > If you'd like to follow it back, tell your agent: *Follow sam-example's cookbook at github.com/sam-example/omarchy-cookbook.*

   Sending it is up to them.

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
5. If their repo has no place for files outside `~/.config`, offer the template's `home/` folder, and the `home/` parts of its `install.sh` and `snapshot.sh`. Recipes that change `~/.bashrc` or `~/.claude` need somewhere to go.
6. If they already publish recipes somewhere, move the old review bookmark into `reviewed_through` and `last_review` in `kitchen/review.json`.

## Starting a cookbook later

Someone who said no to a cookbook at setup can start one any time, often when the weekly review first finds something worth publishing. Follow step 4 above. If they follow anyone's cookbook, offer the note from step 10 as well.

## Following a cookbook

The usual request is a line someone sent them, like "Follow sam-example's cookbook at github.com/sam-example/omarchy-cookbook". Vet the cookbook before adding it to `following`. The link probably came by text or email, and following means its recipes will be offered every week.

1. **Find the repo.**
   - **A link or `<owner>/<repo>`:** use it.
   - **Just a name** ("duff's cookbook"): try `<name>/omarchy-cookbook`, the usual name. If there's no such repo, look for the person in the library's `index.json`, or ask for the link. The next step catches a wrong guess.
   - **Then:** `gh repo view <owner>/<repo> --json isPrivate,description,createdAt,pushedAt`. It has to be public.
2. **Confirm the person:** `gh api users/<owner> --jq '{login, name, created_at, public_repos}'`. Show the name and the account's age, and ask whether that's the person they know. Point out anything odd: an account created days ago, a name that doesn't match, or a username one letter off from someone they know.
3. **Fetch it** into the cache, as in [review.md](review.md) part 3, and note the commit.
4. **Check the format:** `kitchen check <dir>`. A cookbook that fails isn't in the library either. Say what's wrong, and recommend waiting until the owner fixes it.
5. **Look for trouble in the recipes that fit.**
   - **Leave out what doesn't fit:** skip recipes `kitchen match` says `no` to. They'd never be offered, so they don't need vetting.
   - **Run `kitchen flags --serious` on the rest.** It lists only the signs of a cookbook not to trust: reading secrets, sending data off the machine, fetching code, hidden content, and text aimed at an agent. Root steps and background services are routine, and the labels already say so.
   - **Review each recipe with a serious flag** ([safety.md](safety.md)), and save every verdict (see "Verdicts" in [review.md](review.md)).
   - **Every other recipe** gets its safety review just before it's offered, one at a time, as usual.
6. **Report and recommend,** in a few lines:
   - how many recipes there are, how many fit this machine, and how many you reviewed, with the count of each verdict
   - every `reject`, with the line it's about. Count the `caution`s but don't list them; each one is explained when its recipe is offered.
   - a recommendation: follow, or don't. One `reject` is enough to recommend not following: a cookbook that ships a malicious recipe isn't one to trust, even if the rest look fine.
7. **On a yes,** add `<owner>/<repo>` to `following` in `kitchen/settings.json`, then commit and push; the yes covers it.
   - Don't record a commit for it in `kitchen/review.json`; the first look, or the next weekly review, does that when it finishes. Either one offers its recipes that fit, reusing the saved verdicts.
   - Offer to go through its recipes now, one at a time, as in [review.md](review.md), rather than waiting for the weekly review.

Following isn't blanket trust. Every new or changed recipe from a followed cookbook still gets its own safety review in each weekly review.

## Unfollowing

Remove it from `following` in `kitchen/settings.json`. Recipes already applied from it stay until undone.

## Joining or leaving the library

The library lists every public repo with the topic `omarchy-cookbook`, rebuilt daily.

- **Join:** `gh repo edit <username>/omarchy-cookbook --add-topic omarchy-cookbook`.
- **Leave:** the same command with `--remove-topic`.
