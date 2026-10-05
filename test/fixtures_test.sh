#!/bin/bash

# The deterministic half of the safety evals: each fixture recipe passes or
# fails kitchen check as test/evals/safety.json expects, and raises the
# expected warning flags.

EXPECTED="$ROOT/test/evals/safety.json"

test_every_fixture_has_an_expectation() {
  assert_eq "$(ls "$FIXTURES/recipes" | sort)" "$(jq -r 'keys[]' "$EXPECTED" | sort)"
}

test_fixture_check_results() {
  local folder want got
  for folder in $(jq -r 'keys[]' "$EXPECTED"); do
    want=$(jq -r --arg f "$folder" '.[$f].check' "$EXPECTED")
    COOKBOOK_DIR="" dir=$(cookbook "$folder" sam <"$FIXTURES/recipes/$folder/RECIPE.md")
    [[ -d $FIXTURES/recipes/$folder/files ]] && cp -a "$FIXTURES/recipes/$folder/files" "$dir/recipes/$folder/"
    if "$KITCHEN" check "$dir" >/dev/null; then got=pass; else got=fail; fi
    [[ $got == "$want" ]] || fail "$folder: expected check to $want, got $got: $("$KITCHEN" check "$dir")"
  done
}

test_fixture_flags() {
  local folder kinds kind
  for folder in $(jq -r 'keys[]' "$EXPECTED"); do
    kinds=$("$KITCHEN" flags "$FIXTURES/recipes/$folder" | cut -d: -f1 | sort -u)
    while IFS= read -r kind; do
      [[ -z $kind ]] && continue
      grep -qxF -- "$kind" <<<"$kinds" || fail "$folder: expected the flag \"$kind\", got: $kinds"
    done < <(jq -r --arg f "$folder" '.[$f].flags[]' "$EXPECTED")
    if [[ $(jq -r --arg f "$folder" '.[$f].flags | length' "$EXPECTED") == 0 ]]; then
      assert_eq "no warning signs" "$kinds"
    fi
  done
}

test_serious_flags_skip_routine_ones() {
  assert_eq "no warning signs" "$("$KITCHEN" flags "$FIXTURES/recipes/agent-commit-messages-ignore-conventions" --serious)"
  assert_has "$("$KITCHEN" flags "$FIXTURES/recipes/ssh-keys-lost-on-reinstall" --serious)" "^reads secrets or private data"
  assert_lacks "$("$KITCHEN" flags "$FIXTURES/recipes/ssh-keys-lost-on-reinstall" --serious)" "^starts something"
}

test_flags_ignore_problem_descriptions_and_titles() {
  dir=$(recipe | sed 's/^A light palm tap clicks./Stock Omarchy closes windows without asking, and a script once ran `curl` against ~\/.ssh./' | cookbook)
  assert_eq "no warning signs" "$("$KITCHEN" flags "$dir/recipes/touchpad-taps-click-things")"
  dir=$(recipe | sed 's/^Run `hyprctl reload`./Run `hyprctl eval "x"`./' | cookbook)
  assert_eq "no warning signs" "$("$KITCHEN" flags "$dir/recipes/touchpad-taps-click-things")"
  dir=$(recipe | sed 's/^Run `hyprctl reload`./Run `bash -c "$(cat x)"`./' | cookbook)
  assert_has "$("$KITCHEN" flags "$dir/recipes/touchpad-taps-click-things")" 'hides or decodes content: RECIPE.md:[0-9]+: .*bash -c'
}
