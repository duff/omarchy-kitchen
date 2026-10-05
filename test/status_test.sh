#!/bin/bash

test_status_describes_the_setup() {
  repo="$TEST_TMP/my-omarchy"
  book="$TEST_TMP/omarchy-cookbook"
  mkdir -p "$repo/kitchen/applied" "$book/recipes/one"
  echo '{"last_review": "2026-10-01"}' >"$repo/kitchen/review.json"
  jq -n --arg book "$book" '{method: "v0.1.0", cookbook: $book, following: ["sam/omarchy-cookbook"]}' >"$repo/kitchen/settings.json"
  echo '{"id": "sam/x", "published": false}' >"$repo/kitchen/applied/sam--x.json"
  echo '{"owner": "duff"}' >"$book/cookbook.json"
  echo x >"$book/recipes/one/RECIPE.md"

  output=$(KITCHEN_NOW="2026-10-05 09:00" "$KITCHEN" status --repo "$repo")
  assert_has "$output" "^Method: omarchy-kitchen v0\.1\.0"
  assert_has "$output" "^Cookbook: duff/omarchy-cookbook at .*, 1 recipe$"
  assert_has "$output" "^Following: sam/omarchy-cookbook$"
  assert_has "$output" "^Weekly review: next review on 2026-10-08$"
  assert_has "$output" "^Applied from others: 1 \(1 waiting to be published\)$"
}

test_status_without_a_cookbook() {
  repo="$TEST_TMP/my-omarchy"
  mkdir -p "$repo/kitchen"
  echo '{"last_review": null}' >"$repo/kitchen/review.json"
  jq -n --arg book "$TEST_TMP/missing" '{cookbook: $book}' >"$repo/kitchen/settings.json"
  output=$("$KITCHEN" status --repo "$repo")
  assert_has "$output" "^Cookbook: none"
  assert_has "$output" "^Following: nobody yet$"
  assert_has "$output" "^Weekly review: due now$"
}
