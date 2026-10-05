#!/bin/bash

# private_repo [last review date] [review_every_days]: a private repo's
# kitchen files in $TEST_TMP/repo, with a cookbook in $TEST_TMP/cookbook
# (set NO_COOKBOOK=1 for none). Prints its path.
private_repo() {
  local repo="$TEST_TMP/repo" book="$TEST_TMP/cookbook"
  mkdir -p "$repo/kitchen/applied"
  jq -n --arg last "${1:-}" '{last_review: (if $last == "" then null else $last end), reviewed_through: null}' \
    >"$repo/kitchen/review.json"
  [[ -n ${NO_COOKBOOK:-} ]] || { mkdir -p "$book" && echo '{"owner": "duff"}' >"$book/cookbook.json"; }
  jq -n --arg book "$book" --arg every "${2:-}" \
    '{github: "duff", cookbook: $book} + (if $every == "" then {} else {review_every_days: ($every | tonumber)} end)' \
    >"$repo/kitchen/settings.json"
  echo "$repo"
}

due() {
  KITCHEN_NOW="2026-10-10 09:00" "$KITCHEN" due --repo "$1"
}

test_due_a_week_after_the_last_review() {
  assert_eq "due: the weekly review is due today (last review 2026-10-03)" "$(due "$(private_repo 2026-10-03)")"
  assert_has "$(due "$(private_repo 2026-10-01)")" "^due: the weekly review was due on 2026-10-08 \(last review 2026-10-01\)"
  assert_eq "not due: next review on 2026-10-11" "$(due "$(private_repo 2026-10-04)")"
}

test_settings_override_the_interval() {
  assert_has "$(due "$(private_repo 2026-10-07 3)")" "^due:"
}

test_never_reviewed_is_due() {
  assert_eq "due: the weekly review has never run" "$(due "$(private_repo)")"
}

test_snooze_keeps_it_quiet_until_then() {
  repo=$(private_repo 2026-09-01)
  echo "2026-10-10 18:00" >"$repo/kitchen/snooze"
  assert_eq "snoozed: until 2026-10-10 18:00" "$(due "$repo")"
  echo "2026-10-09" >"$repo/kitchen/snooze"
  assert_has "$(due "$repo")" "^due:"
}

test_snooze_command() {
  repo=$(private_repo)
  assert_eq "Snoozed until 2026-10-11 18:30." "$("$KITCHEN" snooze 2026-10-11 18:30 --repo "$repo")"
  assert_eq "2026-10-11 18:30" "$(cat "$repo/kitchen/snooze")"
  "$KITCHEN" snooze tomorrow --repo "$repo" 2>/dev/null && fail "accepted a snooze of 'tomorrow'"
  "$KITCHEN" snooze --clear --repo "$repo" >/dev/null
  [[ ! -e $repo/kitchen/snooze ]] || fail "snooze --clear left the file"
}

test_waiting_counts_commits_and_queued_recipes() {
  repo=$(private_repo 2026-09-01)
  export GIT_AUTHOR_NAME=Test GIT_COMMITTER_NAME=Test GIT_AUTHOR_EMAIL=test@example.com GIT_COMMITTER_EMAIL=test@example.com
  git -C "$repo" init -q -b main
  git -C "$repo" add -A && git -C "$repo" commit -qm Start
  start=$(git -C "$repo" rev-parse HEAD)
  jq --arg s "$start" '.reviewed_through = $s' "$repo/kitchen/review.json" >"$TEST_TMP/r" && mv "$TEST_TMP/r" "$repo/kitchen/review.json"
  mkdir -p "$repo/config/hypr" && echo x >"$repo/config/hypr/input.lua"
  git -C "$repo" add -A && git -C "$repo" commit -qm "Change input"
  echo '{"id": "sam/x", "published": false}' >"$repo/kitchen/applied/sam--x.json"
  git -C "$repo" add -A && git -C "$repo" commit -qm "Only kitchen files"
  mkdir -p "$repo/config/omarchy" && echo y >"$repo/config/omarchy/shell.json"
  echo '{"id": "sam/y", "published": false}' >"$repo/kitchen/applied/sam--y.json"
  git -C "$repo" add -A && git -C "$repo" commit -qm "Apply recipe sam/y"

  output=$(due "$repo")
  assert_has "$output" "^  1 commit since the last review$"
  assert_has "$output" "^  2 applied recipes waiting to be published$"
}

test_without_a_cookbook_nothing_waits_to_be_published() {
  repo=$(NO_COOKBOOK=1 private_repo 2026-09-01)
  echo '{"id": "sam/x", "published": false}' >"$repo/kitchen/applied/sam--x.json"
  assert_eq "due: the weekly review was due on 2026-09-08 (last review 2026-09-01)" "$(due "$repo")"
}
