#!/bin/bash

# Shared helpers for the kitchen commands. Source this file; don't run it.
# Everything here needs only bash, awk, grep, jq, git, and coreutils, which
# every Omarchy machine and GitHub's Ubuntu runners have.

KITCHEN_ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
KITCHEN_LIB="$KITCHEN_ROOT/lib"

REQUIRED_SECTIONS=("Problem" "Fix" "Apply and check" "Undo" "History")

# The sections whose code changes a machine. "Problem" and "Why it happens"
# describe stock Omarchy, so their code doesn't count.
CODE_SECTIONS=("Fix" "Apply and check" "Undo")

# Zero-width and text-direction characters, as UTF-8 bytes. They hide text
# from people but not from agents. Match with LC_ALL=C grep -P.
HIDDEN_BYTES='\xE2\x80[\x8B-\x8F\xAA-\xAE]|\xE2\x81[\xA0-\xA4\xA6-\xA9]|\xEF\xBB\xBF'

kitchen_die() {
  echo "kitchen: $*" >&2
  exit 1
}

# ~/path -> /home/you/path
kitchen_expand() {
  local path=$1
  echo "${path/#\~/$HOME}"
}

# /home/you/path -> ~/path
kitchen_tilde() {
  local path=$1
  [[ $path == "$HOME" || $path == "$HOME"/* ]] && path="~${path#"$HOME"}"
  echo "$path"
}

# The JSON header of a RECIPE.md: the lines between the first two --- lines.
# Fails if the file doesn't start with a --- line.
kitchen_header() {
  awk '
    NR == 1 { if ($0 != "---") exit 1; next }
    $0 == "---" { found = 1; exit }
    { print }
    END { if (!found) exit 1 }
  ' "$1"
}

# Everything after the header.
kitchen_body() {
  awk '
    NR == 1 && $0 == "---" { header = 1; next }
    header && $0 == "---" { header = 0; next }
    !header { print }
  ' "$1"
}

# Reads Markdown on stdin and tracks code fences. Calls the awk function
# line() for every line outside a fence, and prints fenced lines when
# print_fenced is 1. Used by the section and code helpers below.
_kitchen_fences='
  function fence_check(   m) {
    if (match($0, /^(```+|~~~+)/)) {
      m = substr($0, 1, RLENGTH)
      if (fence == "") { fence = m; return 1 }
      if (index(m, fence) == 1) { fence = ""; return 1 }
    }
    return 0
  }
'

# The level-2 headings of a recipe's body, one per line. Headings inside
# code blocks don't count.
kitchen_sections() {
  kitchen_body "$1" | awk "$_kitchen_fences"'
    { if (fence_check()) next }
    fence == "" && /^## / { name = substr($0, 4); sub(/[ \t]+$/, "", name); print name }
  '
}

# The text under "## <name>", up to the next level-2 heading.
kitchen_section() {
  kitchen_body "$1" | awk -v want="$2" "$_kitchen_fences"'
    { was_fence = fence_check() }
    !was_fence && fence == "" && /^## / {
      name = substr($0, 4); sub(/[ \t]+$/, "", name); inside = (name == want); next
    }
    inside { print }
  '
}

# The code in Markdown on stdin: fenced blocks, plus inline `code` unless
# inline=0.
kitchen_code_in() {
  awk -v inline="${1:-1}" "$_kitchen_fences"'
    { if (fence_check()) next }
    fence != "" { print; next }
    inline == 1 {
      line = $0
      while (match(line, /`[^`]+`/)) {
        print substr(line, RSTART + 1, RLENGTH - 2)
        line = substr(line, RSTART + RLENGTH)
      }
    }
  '
}

# Paths of the files under a recipe's files/ folder, relative to the recipe.
kitchen_files() {
  local dir=$1
  [[ -d $dir/files ]] || return 0
  (cd "$dir" && find files \( -type f -o -type l \) | LC_ALL=C sort)
}

kitchen_is_text() {
  [[ -f $1 ]] && ! LC_ALL=C grep -qP '\x00' "$1"
}

# What a recipe's fix runs or installs: code in the given sections, plus
# every text file under files/.
#   kitchen_code <recipe-dir> [--forward] [--no-inline]
# --forward leaves out Undo, which puts stock things back.
kitchen_code() {
  local dir=$1 inline=1 sections=("${CODE_SECTIONS[@]}") section rel
  shift
  while (($#)); do
    case $1 in
      --forward) sections=("Fix" "Apply and check") ;;
      --no-inline) inline=0 ;;
    esac
    shift
  done
  for section in "${sections[@]}"; do
    kitchen_section "$dir/RECIPE.md" "$section" | kitchen_code_in "$inline"
  done
  while IFS= read -r rel; do
    kitchen_is_text "$dir/$rel" && cat "$dir/$rel"
    echo
  done < <(kitchen_files "$dir")
}

# The private repo: --repo DIR, or the git repo around the current folder.
# Sets KITCHEN_REPO and removes --repo DIR from the arguments in ARGS.
kitchen_find_repo() {
  ARGS=()
  KITCHEN_REPO=""
  while (($#)); do
    if [[ $1 == --repo ]]; then
      KITCHEN_REPO=$2
      shift 2
    else
      ARGS+=("$1")
      shift
    fi
  done
  [[ -n $KITCHEN_REPO ]] || KITCHEN_REPO=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
  [[ -f $KITCHEN_REPO/kitchen/review.json ]] ||
    kitchen_die "$KITCHEN_REPO has no kitchen/review.json; run this in your private Omarchy repo"
}

# The method's defaults with the private repo's kitchen/settings.json on top.
kitchen_settings() {
  local settings="$1/kitchen/settings.json"
  if [[ -f $settings ]]; then
    jq -s '.[0] * .[1]' "$KITCHEN_ROOT/defaults.json" "$settings"
  else
    cat "$KITCHEN_ROOT/defaults.json"
  fi
}

# "Now" as seconds since the epoch. Tests set KITCHEN_NOW to a date.
kitchen_now() {
  if [[ -n ${KITCHEN_NOW:-} ]]; then
    date -d "$KITCHEN_NOW" +%s
  else
    date +%s
  fi
}
