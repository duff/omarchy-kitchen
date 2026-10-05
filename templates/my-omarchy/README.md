# my-omarchy

{{name}}'s private config for [Omarchy](https://omarchy.org/) machines. Omarchy itself lives in `/usr/share/omarchy/` and is replaced on every `omarchy update`. This repo is the layer on top: only the differences.

```
config/             # copied into ~/.config/ on every machine
hosts/<hostname>/   # copied into ~/.config/ on that machine only, after config/
home/               # copied into ~: home/.bashrc is ~/.bashrc
kitchen/            # omarchy-kitchen: settings, review state, applied recipes
install.sh          # repo -> this machine
snapshot.sh         # this machine -> repo
RULES.md            # where each kind of change goes
```

## Use

```bash
./install.sh     # after cloning, or after git pull
./snapshot.sh    # after changing something live, before committing
```

`install.sh` also installs [omarchy-kitchen](https://github.com/duff/omarchy-kitchen) at the version in `kitchen/settings.json`. It never runs `omarchy refresh`.

## Recipes

Once a week, opening your agent in this folder offers a review: what's worth publishing to your cookbook, and what's new in the cookbooks you follow. Say when, if not now.
