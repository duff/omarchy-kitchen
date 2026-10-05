#!/bin/bash

# Assertions and builders for the tests. Each test runs in a subshell with
# its own temporary folder in $TEST_TMP.

ROOT=$(pwd)
KITCHEN="$ROOT/bin/kitchen"
FIXTURES="$ROOT/test/fixtures"
export KITCHEN_OFFLINE=1

fail() {
  echo "$*"
  exit 1
}

assert_eq() {
  [[ $1 == "$2" ]] || fail "expected: $1"$'\n'"     got: $2"
}

# assert_has <text> <extended regex>: some line of text matches.
assert_has() {
  grep -qE -- "$2" <<<"$1" || fail "expected a line matching: $2"$'\n'"in:"$'\n'"$1"
}

# assert_lacks <text> <extended regex>: no line of text matches.
assert_lacks() {
  ! grep -qE -- "$2" <<<"$1" || fail "expected no line matching: $2"$'\n'"in:"$'\n'"$1"
}

# A RECIPE.md that passes every check. An optional jq filter changes its
# data, like recipe '.root = true'.
recipe() {
  local filter=${1:-.}
  cat <<'EOF'
# Touchpad taps click things

## Problem

A light palm tap clicks.

## Fix

In `~/.config/hypr/input.lua`:

```lua
hl.config({ input = { touchpad = { tap_to_click = false } } })
```

## Apply and check

Run `hyprctl reload`.

## Undo

Delete the line and run `hyprctl reload`.

## History

- Created by [@duff](https://github.com/duff) on 2026-10-01.

## Recipe data

```json
EOF
  jq "$filter" <<'EOF'
{
  "id": "duff/touchpad-taps-click-things",
  "title": "Touchpad taps click things",
  "summary": "Turn off tap-to-click.",
  "version": 1,
  "tested_on": {"omarchy": "4.0.4", "hyprland": "0.56.2"},
  "applies_to": "Laptops.",
  "requires": [{"laptop": true}],
  "touches": ["~/.config/hypr/input.lua"],
  "root": false,
  "network": false,
  "installs": [],
  "runs": [],
  "agent_config": false,
  "history": [{"who": "duff", "did": "created", "date": "2026-10-01"}]
}
EOF
  echo '```'
}

# A new cookbook holding one recipe, read from stdin, in the given folder
# (default touchpad-taps-click-things). Prints its path. Set COOKBOOK_DIR to
# add the recipe to an existing cookbook instead.
cookbook() {
  local folder=${1:-touchpad-taps-click-things} owner=${2:-duff} dir=${COOKBOOK_DIR:-}
  [[ -n $dir ]] || dir=$(mktemp -d "$TEST_TMP/cookbook.XXXXXX")
  mkdir -p "$dir/recipes/$folder"
  cat >"$dir/recipes/$folder/RECIPE.md"
  [[ -f $dir/cookbook.json ]] ||
    echo "{\"owner\": \"$owner\", \"kitchen\": \"v0.1.0\", \"description\": \"Test cookbook.\"}" >"$dir/cookbook.json"
  echo "- [$folder](recipes/$folder/RECIPE.md)" >>"$dir/README.md"
  echo "$dir"
}

# Problems kitchen check finds in one recipe, read from stdin.
#   recipe_problems [folder] [owner]
recipe_problems() {
  local dir
  dir=$(cookbook "$@")
  "$KITCHEN" check "$dir" | sed -E 's#^recipes/[^:]+: ##'
}
