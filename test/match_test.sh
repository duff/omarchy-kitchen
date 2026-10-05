#!/bin/bash

LAPTOP_PROFILE='{
  "vendor": "Dell Inc.", "model": "XPS 16 DA16260", "family": "Dell Laptops", "laptop": true,
  "monitors": ["LG Display 0x07C5"],
  "devices": ["zsa-technology-labs-ergodox-ez-keyboard", "ven_2c2f:00-2c2f:0033-touchpad"],
  "commands": ["ghostty", "voxtype"], "packages": ["keyd"], "omarchy": "4.0.4"
}'

# match <requires JSON> [tested omarchy version]: the full kitchen match output.
match() {
  local dir="$TEST_TMP/match/recipe"
  mkdir -p "$dir"
  recipe ".requires = $1 | .tested_on.omarchy = \"${2:-4.0.4}\"" >"$dir/RECIPE.md"
  echo "$LAPTOP_PROFILE" >"$TEST_TMP/profile.json"
  "$KITCHEN" match "$dir" --profile "$TEST_TMP/profile.json"
}

verdict() {
  match "$@" | head -n1
}

test_any_machine() {
  assert_eq "yes" "$(verdict '[]')"
}

test_hard_requirements_say_no() {
  assert_eq "no" "$(verdict '[{"laptop": false}]')"
  assert_eq "no" "$(verdict '[{"vendor": "Apple"}]')"
  assert_eq "no" "$(verdict '[{"model": "MacBook"}]')"
  assert_eq "no" "$(verdict '[{"command": "herdr"}]')"
  assert_eq "no" "$(verdict '[{"package": "tailscale"}]')"
}

test_hard_requirements_say_yes() {
  assert_eq "yes" "$(verdict '[{"laptop": true}, {"vendor": "dell"}, {"model": "XPS 16"}]')"
  assert_eq "yes" "$(verdict '[{"command": "voxtype"}, {"package": "keyd"}]')"
  assert_eq "yes" "$(verdict '[{"model": "Dell Laptops"}]')"
}

test_things_that_come_and_go_say_maybe() {
  output=$(match '[{"monitors": 3}]')
  assert_eq "maybe" "$(head -n1 <<<"$output")"
  assert_has "$output" "1 monitor connected now; needs 3"
  assert_eq "maybe" "$(verdict '[{"monitor": "StudioDisplay"}]')"
  assert_eq "maybe" "$(verdict '[{"device": "Viper"}]')"
}

test_device_names_match_hyprland_style() {
  assert_eq "yes" "$(verdict '[{"device": "ErgoDox EZ"}]')"
}

test_no_beats_maybe() {
  assert_eq "no" "$(verdict '[{"monitors": 3}, {"laptop": false}]')"
}

test_unknown_requirement_is_maybe() {
  assert_eq "maybe" "$(verdict '[{"gpu": "nvidia"}]')"
}

test_notes_a_different_omarchy_version() {
  assert_has "$(match '[]' 3.2.0)" "tested on Omarchy 3.2.0; this machine has 4.0.4"
  assert_lacks "$(match '[]' 4.0.1)" "tested on"
}

test_checks_commands_on_this_machine_without_a_profile_list() {
  dir="$TEST_TMP/live/recipe"
  mkdir -p "$dir"
  recipe '.requires = [{"command": "bash"}, {"command": "no-such-command-here"}]' >"$dir/RECIPE.md"
  jq 'del(.commands)' <<<"$LAPTOP_PROFILE" >"$TEST_TMP/profile.json"
  output=$("$KITCHEN" match "$dir" --profile "$TEST_TMP/profile.json")
  assert_eq "no" "$(head -n1 <<<"$output")"
  assert_has "$output" "has bash"
  assert_has "$output" "doesn't have no-such-command-here"
}
