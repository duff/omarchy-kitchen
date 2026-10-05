#!/bin/bash

# A recipe's data declares what its fix does: root, network, installs,
# runs, agent_config. These Perl-style patterns (grep -P) spot those things
# in the fix's code, so a recipe can't do more than its labels say.

# Commands count wherever they appear in the fix's code, inline or not.
declare -A LABEL_COMMANDS=(
  [root]='\bsudo\b|\bpkexec\b|\bvisudo\b|\busermod\b|\bgpasswd\b|\bsystemctl\s+(?!--user)(?:enable|disable|start|restart|stop|mask|daemon-reload)\b|\b(?:pacman|yay|paru)\s+-[SR]|\bomarchy\s+pkg\s+(?:aur\s+)?(?:add|drop)\b|\bomarchy-pkg-(?:aur-)?(?:add|drop)\b'
  [network]='\b(?:curl|wget|ncat|socat)\b|/dev/(?:tcp|udp)/|\bnc\s+-|\bgit\s+clone\b|\bomarchy\s+(?:plugin\s+add|theme\s+install)\b|\bomarchy-(?:plugin-add|theme-install)\b'
  [installs]='\b(?:pacman|yay|paru)\s+-S|\bomarchy\s+pkg\s+(?:aur\s+)?add\b|\bomarchy-pkg-(?:aur-)?add\b|\bomarchy\s+install\b|\bomarchy\s+(?:plugin\s+add|theme\s+install)\b|\b(?:pip3?|pipx|cargo|go)\s+install\b|\bnpm\s+(?:i|install)\s+(?:-g|--global)\b|\bmise\s+(?:use|install)\b|\bflatpak\s+install\b'
  [runs]='\bsystemctl\s+(?:--user\s+)?(?:enable|start)\b|\bomarchy\s+hook\s+install\b|\bomarchy-hook-install\b|(?i:\bexec[-_]?once\b)|\bcrontab\b|\bRUN\+?='
  [agent_config]='\bclaude\s+config\s+set\b'
)

# File names count only in code blocks, files/, and touches. A path in
# backticks inside a sentence is usually a mention, not a change.
declare -A LABEL_PATHS=(
  [runs]='\.(?:service|timer|path|socket)\b|/hooks/|\bautostart\b|\.(?:bashrc|bash_profile|zshrc|profile)\b'
  [agent_config]='\bCLAUDE\.md\b|\bAGENTS\.md\b|~/\.(?:claude|codex|agents|grok|pi)\b|\.(?:claude|codex|agents|grok)/'
)

LABELS=(root network installs runs agent_config)

declare -A LABEL_MEANS=(
  [root]="needs root"
  [network]="uses the network"
  [installs]="installs software"
  [runs]="sets up something that runs on its own"
  [agent_config]="changes agent instructions or settings"
)

# Prints "label<TAB>evidence" for each label the fix's code needs.
#   kitchen_labels_needed <recipe-dir> <data-json>
kitchen_labels_needed() {
  local dir=$1 data=$2 label sections line touches all forward all_fenced forward_fenced
  touches=$(jq -r '(.touches // [])[] | strings' <<<"$data")
  all=$(kitchen_code "$dir")
  forward=$(kitchen_code "$dir" --forward)
  all_fenced=$(kitchen_code "$dir" --no-inline)
  forward_fenced=$(kitchen_code "$dir" --forward --no-inline)

  for label in "${LABELS[@]}"; do
    # Undo puts stock things back, like re-enabling a service the fix turned
    # off, so it counts for root and network but not installs and runs.
    if [[ $label == installs || $label == runs ]]; then
      line=$(grep -m1 -P -- "${LABEL_COMMANDS[$label]}" <<<"$forward" ||
        { [[ -n ${LABEL_PATHS[$label]:-} ]] && grep -m1 -P -- "${LABEL_PATHS[$label]}" <<<"$forward_fenced"$'\n'"$touches"; } || true)
    else
      line=$(grep -m1 -P -- "${LABEL_COMMANDS[$label]}" <<<"$all" ||
        { [[ -n ${LABEL_PATHS[$label]:-} ]] && grep -m1 -P -- "${LABEL_PATHS[$label]}" <<<"$all_fenced"$'\n'"$touches"; } || true)
    fi
    [[ -n $line ]] || continue
    line=$(sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//' <<<"$line")
    printf '%s\t%s\n' "$label" "${line:0:80}"
  done
}

# Plain-language problems where the code does more than the labels say.
kitchen_label_mismatches() {
  local dir=$1 data=$2 label evidence declared
  while IFS=$'\t' read -r label evidence; do
    if [[ $label == installs || $label == runs ]]; then
      declared=$(jq -r --arg l "$label" '(.[$l] // []) | if type == "array" and length > 0 then "yes" else "no" end' <<<"$data")
      [[ $declared == yes ]] || echo "the fix ${LABEL_MEANS[$label]} (\`$evidence\`), so \`$label\` has to list it"
    else
      declared=$(jq -r --arg l "$label" 'if .[$l] == true then "yes" else "no" end' <<<"$data")
      [[ $declared == yes ]] || echo "the fix ${LABEL_MEANS[$label]} (\`$evidence\`), so \`$label\` has to be true"
    fi
  done < <(kitchen_labels_needed "$dir" "$data")
}
