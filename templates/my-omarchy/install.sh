#!/usr/bin/env bash
# Copy this repo onto this machine: config/ everywhere, then hosts/<hostname>/
# on this machine only. A file removed from the repo since the last install
# goes back to Omarchy's stock copy, or is deleted if Omarchy has none.
set -euo pipefail

root=$(cd "$(dirname "$0")" && pwd)
host=$(hostname)
config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
omarchy_path="${OMARCHY_PATH:-/usr/share/omarchy}"
state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/my-omarchy"
manifest="$state_dir/installed"
export LC_ALL=C

mkdir -p "$state_dir"
installed=$(mktemp)
trap 'rm -f "$installed"' EXIT

install_tree() {
  local src=$1 file rel
  [[ -d $src ]] || return 0
  while IFS= read -r -d '' file; do
    rel=${file#"$src"/}
    [[ $(basename "$rel") == .gitkeep ]] && continue
    mkdir -p "$(dirname "$config_home/$rel")"
    cp -a "$file" "$config_home/$rel"
    printf '%s\n' "$rel" >> "$installed"
  done < <(find "$src" -type f -print0)
}

install_tree "$root/config"
install_tree "$root/hosts/$host"
sort -u -o "$installed" "$installed"

if [[ -f $manifest ]]; then
  while IFS= read -r rel; do
    [[ -n $rel ]] || continue
    if [[ -f $omarchy_path/config/$rel ]]; then
      cp -a "$omarchy_path/config/$rel" "$config_home/$rel"
      echo "Back to stock: ~/.config/$rel"
    elif [[ -e $config_home/$rel ]]; then
      rm -f "$config_home/$rel"
      echo "Removed: ~/.config/$rel"
    fi
  done < <(comm -23 "$manifest" "$installed")
fi
cp "$installed" "$manifest"

# omarchy-kitchen, at the version kitchen/settings.json names.
kitchen_dir="$HOME/.local/share/omarchy-kitchen"
version=$(jq -r '.method // empty' "$root/kitchen/settings.json" 2>/dev/null)
if [[ -n $version ]]; then
  if [[ ! -d $kitchen_dir/.git ]]; then
    git clone --quiet https://github.com/duff/omarchy-kitchen "$kitchen_dir" ||
      echo "Couldn't download omarchy-kitchen. Run install.sh again when online." >&2
  fi
  if [[ -d $kitchen_dir/.git ]]; then
    git -C "$kitchen_dir" fetch --quiet --tags || true
    if git -C "$kitchen_dir" checkout --quiet "$version"; then
      "$kitchen_dir/install"
    else
      echo "omarchy-kitchen has no version $version." >&2
    fi
  fi
fi

echo "Installed. Reload what changed: hyprctl reload, omarchy restart shell, or omarchy restart terminal."
