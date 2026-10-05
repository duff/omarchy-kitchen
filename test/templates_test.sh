#!/bin/bash

# The private-repo template's install.sh and snapshot.sh, run against a
# throwaway home folder and a fake Omarchy.

setup_machine() {
  REPO="$TEST_TMP/repo"
  HOME_DIR="$TEST_TMP/home"
  OMARCHY="$TEST_TMP/omarchy"
  cp -a "$ROOT/templates/my-omarchy" "$REPO"
  # No method version, so install.sh doesn't try to download omarchy-kitchen.
  echo '{"github": "test", "following": []}' >"$REPO/kitchen/settings.json"
  mkdir -p "$OMARCHY/config/hypr" "$HOME_DIR/.config/hypr"
  echo "stock input" | tee "$OMARCHY/config/hypr/input.lua" >"$HOME_DIR/.config/hypr/input.lua"
  echo "stock looks" | tee "$OMARCHY/config/hypr/looknfeel.lua" >"$HOME_DIR/.config/hypr/looknfeel.lua"
}

run_script() {
  env -u XDG_CONFIG_HOME -u XDG_STATE_HOME HOME="$HOME_DIR" OMARCHY_PATH="$OMARCHY" "$REPO/$1" 2>&1 ||
    fail "$1 failed"
}

test_install_copies_shared_then_host_files() {
  setup_machine
  mkdir -p "$REPO/config/hypr" "$REPO/hosts/$(uname -n)/hypr" "$REPO/hosts/another-machine/hypr"
  echo "mine everywhere" | tee "$REPO/config/hypr/input.lua" >"$REPO/config/hypr/looknfeel.lua"
  echo "mine here" >"$REPO/hosts/$(uname -n)/hypr/looknfeel.lua"
  echo "not here" >"$REPO/hosts/another-machine/hypr/input.lua"
  run_script install.sh >/dev/null

  assert_eq "mine everywhere" "$(cat "$HOME_DIR/.config/hypr/input.lua")"
  assert_eq "mine here" "$(cat "$HOME_DIR/.config/hypr/looknfeel.lua")"
  [[ ! -e $HOME_DIR/.config/.gitkeep ]] || fail "copied a .gitkeep"
}

test_files_removed_from_the_repo_go_back_to_stock_or_away() {
  setup_machine
  mkdir -p "$REPO/config/hypr" "$REPO/config/recipe"
  echo "mine" >"$REPO/config/hypr/input.lua"
  echo "added by a recipe" >"$REPO/config/recipe/extra.conf"
  run_script install.sh >/dev/null
  assert_eq "added by a recipe" "$(cat "$HOME_DIR/.config/recipe/extra.conf")"

  rm "$REPO/config/hypr/input.lua" "$REPO/config/recipe/extra.conf"
  output=$(run_script install.sh)
  assert_eq "stock input" "$(cat "$HOME_DIR/.config/hypr/input.lua")"
  [[ ! -e $HOME_DIR/.config/recipe/extra.conf ]] || fail "left a removed file behind"
  assert_has "$output" "Back to stock: ~/.config/hypr/input.lua"
  assert_has "$output" "Removed: ~/.config/recipe/extra.conf"
}

test_snapshot_refreshes_tracked_files_and_lists_new_differences() {
  setup_machine
  mkdir -p "$REPO/config/hypr" "$HOME_DIR/.config/omarchy/current/theme" "$HOME_DIR/.config/chromium/Default"
  echo "old" >"$REPO/config/hypr/input.lua"
  echo "changed live" >"$HOME_DIR/.config/hypr/input.lua"
  echo "changed from stock" >"$HOME_DIR/.config/hypr/looknfeel.lua"
  echo "new file" >"$HOME_DIR/.config/hypr/extra.lua"
  echo "generated" >"$HOME_DIR/.config/omarchy/current/theme/colors.toml"
  echo "not a config" >"$HOME_DIR/.config/chromium/Default/Cookies"

  output=$(run_script snapshot.sh)
  assert_eq "changed live" "$(cat "$REPO/config/hypr/input.lua")"
  assert_has "$output" "changed  ~/.config/hypr/looknfeel.lua"
  assert_has "$output" "added    ~/.config/hypr/extra.lua"
  assert_lacks "$output" "current|Cookies"
}

test_snapshot_keeps_the_gh_login_helper_by_name() {
  setup_machine
  mkdir -p "$REPO/config/git" "$HOME_DIR/.config/git"
  printf '[credential "https://github.com"]\n\thelper =\n\thelper = !/home/sam/.local/share/mise/installs/gh/2.83.1/bin/gh auth git-credential\n' \
    >"$HOME_DIR/.config/git/config"
  echo old >"$REPO/config/git/config"
  run_script snapshot.sh >/dev/null
  assert_has "$(cat "$REPO/config/git/config")" $'^\thelper = !gh auth git-credential$'
  assert_lacks "$(cat "$REPO/config/git/config")" "mise/installs"
}
