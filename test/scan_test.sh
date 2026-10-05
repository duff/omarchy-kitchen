#!/bin/bash

scan_text() {
  mkdir -p "$TEST_TMP/scan"
  cat >"$TEST_TMP/scan/RECIPE.md"
  "$KITCHEN" scan "$@" "$TEST_TMP/scan"
}

test_finds_common_private_data() {
  output=$(scan_text <<'EOF'
Mail me at someone@gmail.com.
The script lives in /home/alice/bin.
The printer is at 10.0.0.42.
Its MAC is a4:83:e7:12:34:56.
Reach it at printer.tail1234.ts.net.
monitor = "desc:Apple Computer Inc StudioDisplay 0xB6135CE1"
token = "ghp_abcdefghijklmnopqrstuvwxyz0123456789"
EOF
  )
  for kind in "an email address" "a home folder path" "an IP address" "a MAC address" \
    "a Tailscale name" "a display serial number" "a token or private key"; do
    assert_has "$output" "$kind"
  done
}

test_leaves_placeholders_and_documentation_values_alone() {
  output=$(scan_text <<'EOF'
git clone git@github.com:someone/repo.git
Mail you@example.com, or 41898282+github-actions[bot]@users.noreply.github.com.
Paths look like ~/.config or /home/user/.config or /home/YOU/.config.
Listen on 127.0.0.1 or 0.0.0.0, and see 192.0.2.10 in the docs.
monitor = "desc:Apple Computer Inc StudioDisplay 0xXXXXXXXX"
Colors like 0xff89b4fa are fine.
EOF
  )
  assert_eq "ok: nothing private found" "$output"
}

test_private_words_match_whole_words_only() {
  printf 'closet-air\n' >"$TEST_TMP/words"
  output=$(printf 'closet-air runs the server.\nThe aircloset is unrelated.\n' | scan_text --words "$TEST_TMP/words")
  assert_has "$output" "RECIPE.md:1: a private word"
  assert_lacks "$output" "RECIPE.md:2:"
}

test_words_file_skips_comments_and_blanks() {
  printf '# a comment\n\n  Surname  \n' >"$TEST_TMP/words"
  output=$(printf 'Surname here\n# a comment\n' | scan_text --words "$TEST_TMP/words")
  assert_has "$output" "RECIPE.md:1: a private word from this machine or your list: Surname"
  assert_lacks "$output" "RECIPE.md:2"
}

test_cookbook_allow_list() {
  mkdir -p "$TEST_TMP/book"
  echo '{"owner": "duff", "allow": ["Duff", "hello@duff.dev"]}' >"$TEST_TMP/book/cookbook.json"
  echo "Duff's setup; write to hello@duff.dev" >"$TEST_TMP/book/README.md"
  printf 'Duff\n' >"$TEST_TMP/words"
  assert_eq "ok: nothing private found" "$("$KITCHEN" scan --words "$TEST_TMP/words" --cookbook "$TEST_TMP/book")"
}

test_skips_git_and_binary_files() {
  mkdir -p "$TEST_TMP/tree/.git"
  echo "email = someone@gmail.com" >"$TEST_TMP/tree/.git/config"
  printf 'someone@gmail.com\0' >"$TEST_TMP/tree/image.png"
  echo "nothing here" >"$TEST_TMP/tree/notes.md"
  assert_eq "ok: nothing private found" "$("$KITCHEN" scan "$TEST_TMP/tree")"
}
