#!/bin/bash

# A private repo following one cookbook, fetched into a cache in $TEST_TMP.
setup_following() {
  REPO="$TEST_TMP/repo"
  BOOK="$TEST_TMP/cache/cookbooks/sam/omarchy-cookbook"
  mkdir -p "$REPO/kitchen/applied" "$BOOK/recipes"
  jq -n --arg cache "$TEST_TMP/cache" '{following: ["sam/omarchy-cookbook"], cache: $cache}' >"$REPO/kitchen/settings.json"
  echo '{"last_review": null, "cookbooks": {}, "declined": []}' >"$REPO/kitchen/review.json"
  export GIT_AUTHOR_NAME=Test GIT_COMMITTER_NAME=Test GIT_AUTHOR_EMAIL=test@example.com GIT_COMMITTER_EMAIL=test@example.com
  git -C "$BOOK" init -q -b main
  for folder in tap-to-click no-laptop-only plain-one; do
    mkdir -p "$BOOK/recipes/$folder"
  done
  recipe '.id = "sam/tap-to-click" | .history[0].who = "sam"' >"$BOOK/recipes/tap-to-click/RECIPE.md"
  recipe '.id = "sam/no-laptop-only" | .requires = [{"laptop": false}] | .history[0].who = "sam"' >"$BOOK/recipes/no-laptop-only/RECIPE.md"
  recipe '.id = "sam/plain-one" | .requires = [] | .history[0].who = "sam"' >"$BOOK/recipes/plain-one/RECIPE.md"
  git -C "$BOOK" add -A && git -C "$BOOK" commit -qm "Add recipes"
  echo '{"laptop": true, "monitors": [], "devices": [], "commands": [], "packages": [], "omarchy": "4.0.4"}' >"$TEST_TMP/profile.json"
}

pending() {
  "$KITCHEN" pending --repo "$REPO" --profile "$TEST_TMP/profile.json"
}

set_bookmark() {
  jq --arg c "$(git -C "$BOOK" rev-parse HEAD)" '.cookbooks["sam/omarchy-cookbook"] = $c' "$REPO/kitchen/review.json" >"$TEST_TMP/r" &&
    mv "$TEST_TMP/r" "$REPO/kitchen/review.json"
}

test_everything_that_fits_is_new_before_the_first_review() {
  setup_following
  output=$(pending)
  assert_has "$output" $'^new\tyes\tsam/omarchy-cookbook\ttap-to-click\tsam/tap-to-click\t1$'
  assert_has "$output" $'^new\tyes\tsam/omarchy-cookbook\tplain-one\tsam/plain-one\t1$'
  assert_lacks "$output" "no-laptop-only"
}

test_undecided_recipes_stay_as_older_and_changed_ones_are_new() {
  setup_following
  set_bookmark
  assert_has "$(pending)" $'^older\tyes\tsam/omarchy-cookbook\ttap-to-click'
  sed -i 's/"version": 1/"version": 2/' "$BOOK/recipes/plain-one/RECIPE.md"
  git -C "$BOOK" commit -qam "Change plain-one"
  output=$(pending)
  assert_has "$output" $'^new\tyes\tsam/omarchy-cookbook\tplain-one\tsam/plain-one\t2$'
  assert_has "$output" $'^older\tyes\tsam/omarchy-cookbook\ttap-to-click'
  [[ $(head -n1 <<<"$output") == new* ]] || fail "new recipes should come first"
}

test_applied_and_declined_recipes_drop_out_until_their_version_changes() {
  setup_following
  echo '{"id": "sam/tap-to-click", "version": 1}' >"$REPO/kitchen/applied/sam--tap-to-click.json"
  jq '.declined = [{"id": "sam/plain-one", "version": 1, "date": "2026-10-05", "why": "not for me"}]' \
    "$REPO/kitchen/review.json" >"$TEST_TMP/r" && mv "$TEST_TMP/r" "$REPO/kitchen/review.json"
  assert_eq "" "$(pending)"
  sed -i 's/"version": 1/"version": 2/' "$BOOK/recipes/plain-one/RECIPE.md"
  assert_has "$(pending)" $'\tsam/plain-one\t2$'
}

test_a_cookbook_not_fetched_yet_is_reported() {
  setup_following
  rm -rf "$BOOK"
  output=$("$KITCHEN" pending --repo "$REPO" --profile "$TEST_TMP/profile.json" 2>&1)
  assert_has "$output" "sam/omarchy-cookbook isn't fetched yet"
}

test_later_comes_before_never_reached_and_left_out_drops_out() {
  setup_following
  set_bookmark
  jq '.later = [{"id": "sam/plain-one", "version": 1, "date": "2026-10-05"}]
      | .left_out = [{"id": "sam/tap-to-click", "version": 1, "why": "already handled"}]' \
    "$REPO/kitchen/review.json" >"$TEST_TMP/r" && mv "$TEST_TMP/r" "$REPO/kitchen/review.json"
  output=$(pending)
  assert_eq $'later\tyes\tsam/omarchy-cookbook\tplain-one\tsam/plain-one\t1' "$output"
  sed -i 's/"version": 1/"version": 2/' "$BOOK/recipes/tap-to-click/RECIPE.md"
  git -C "$BOOK" commit -qam "Change tap-to-click"
  assert_has "$(pending)" $'^new\tyes\tsam/omarchy-cookbook\ttap-to-click\tsam/tap-to-click\t2$'
}
