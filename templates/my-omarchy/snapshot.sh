#!/usr/bin/env bash
# Copy live config back into this repo, then list files that differ from
# stock Omarchy but aren't in the repo yet. Sort each listed file by
# RULES.md: config/ for every machine, hosts/<hostname>/ for this one, or
# leave it out.
set -euo pipefail

root=$(cd "$(dirname "$0")" && pwd)
host=$(hostname)
config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
omarchy_path="${OMARCHY_PATH:-/usr/share/omarchy}"

# Files the repo already has: refresh them from their live copies.
refresh_tree() {
  local dir=$1 file rel live
  [[ -d $dir ]] || return 0
  while IFS= read -r -d '' file; do
    rel=${file#"$dir"/}
    [[ $(basename "$rel") == .gitkeep ]] && continue
    live="$config_home/$rel"
    if [[ -f $live ]]; then
      cmp -s "$live" "$file" || cp -a "$live" "$file"
    else
      echo "Not on this machine: ~/.config/$rel (still in the repo)"
    fi
  done < <(find "$dir" -type f -print0)
}

refresh_tree "$root/config"
refresh_tree "$root/hosts/$host"

# `gh auth setup-git` writes the full path to this machine's gh, which
# breaks after a gh update or on another machine. Keep the by-name helper,
# which works everywhere.
if [[ -f $root/config/git/config ]]; then
  sed -i -E 's#^([[:space:]]*helper = )!/[^[:space:]]*/gh auth git-credential$#\1!gh auth git-credential#' "$root/config/git/config"
fi

# Places people customize, and generated files inside them that aren't
# customizations.
watched=(hypr omarchy alacritty foot ghostty kitty git herdr tmux wireplumber starship.toml xdg-terminals.list)
ignored=(
  "omarchy/current/*" "omarchy/branding/*" "omarchy/themes/*/backgrounds/*"
  "*.sample" "*.bak.*" "*.bak" "*~" "*/.git/*"
)

# Plugins and themes installed from git are someone else's code. Record
# the install (the omarchy command and URL), not their files.
untracked=()
while IFS= read -r -d '' git_dir; do
  dir=${git_dir%/.git}
  rel=${dir#"$config_home"/}
  url=$(git -C "$dir" remote get-url origin 2>/dev/null || echo "unknown source")
  untracked+=("git      ~/.config/$rel (installed from $url)")
  ignored+=("$rel/*")
done < <(find "$config_home/omarchy/plugins" "$config_home/omarchy/themes" -mindepth 2 -maxdepth 2 -name .git -print0 2>/dev/null)

is_ignored() {
  local pattern
  for pattern in "${ignored[@]}"; do
    # shellcheck disable=SC2053
    [[ $1 == $pattern ]] && return 0
  done
  return 1
}

for top in "${watched[@]}"; do
  [[ -e $config_home/$top ]] || continue
  while IFS= read -r -d '' live; do
    rel=${live#"$config_home"/}
    [[ -f $root/config/$rel || -f $root/hosts/$host/$rel ]] && continue
    is_ignored "$rel" && continue
    stock="$omarchy_path/config/$rel"
    if [[ ! -f $stock ]]; then
      untracked+=("added    ~/.config/$rel")
    elif ! cmp -s "$live" "$stock"; then
      untracked+=("changed  ~/.config/$rel")
    fi
  done < <(find "$config_home/$top" -type f -print0 2>/dev/null)
done

if ((${#untracked[@]})); then
  echo "Differ from stock but not in this repo yet:"
  printf '  %s\n' "${untracked[@]}"
fi

if git -C "$root" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git -C "$root" status --short
fi
