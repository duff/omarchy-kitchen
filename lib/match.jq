# Decides whether a recipe fits a machine: yes, no, or maybe. "Maybe" means
# it depends on something that comes and goes, like a monitor or a mouse
# that isn't plugged in right now.
#
# Input: the recipe header. --argjson profile: kitchen profile's JSON, with
# "commands" and "packages" lists of what this machine has from the recipe's
# command and package requirements.
# Output: the verdict on the first line, then one reason per line.

def has_text($have; $want): ($have // "" | ascii_downcase) | contains($want | ascii_downcase);
def minor: split(".")[0:2] | join(".");

[(.requires // [])[] | to_entries[0] | . as {key: $k, value: $want}
  | if $k == "laptop" then
      ($profile.laptop == true) as $have
      | [if $have == $want then "yes" else "no" end,
         if $have then "this machine is a laptop" else "this machine isn't a laptop" end]
    elif $k == "vendor" then
      [if has_text($profile.vendor; $want) then "yes" else "no" end, "made by \($profile.vendor // "an unknown maker")"]
    elif $k == "model" then
      [if has_text($profile.model; $want) or has_text($profile.family; $want) then "yes" else "no" end,
       "model is \($profile.model // "unknown")"]
    elif $k == "monitors" then
      (($profile.monitors // []) | length) as $count
      | [if $count >= $want then "yes" else "maybe" end,
         "\($count) monitor\(if $count == 1 then "" else "s" end) connected now; needs \($want)"]
    elif $k == "monitor" then
      (any(($profile.monitors // [])[]; has_text(.; $want))) as $found
      | [if $found then "yes" else "maybe" end, if $found then "\($want) is connected" else "no \($want) connected now" end]
    elif $k == "device" then
      (any(($profile.devices // [])[]; has_text(.; $want) or has_text(.; $want | gsub(" "; "-")))) as $found
      | [if $found then "yes" else "maybe" end, if $found then "\($want) is connected" else "no \($want) connected now" end]
    elif $k == "command" then
      (($profile.commands // []) | index($want) != null) as $found
      | [if $found then "yes" else "no" end, if $found then "has \($want)" else "doesn't have \($want)" end]
    elif $k == "package" then
      (($profile.packages // []) | index($want) != null) as $found
      | [if $found then "yes" else "no" end, if $found then "\($want) is installed" else "\($want) isn't installed" end]
    else ["maybe", "can't check `\($k)`"]
    end
] as $results
| (.tested_on.omarchy // "") as $tested
| ($profile.omarchy // "") as $have
| (if any($results[]; .[0] == "no") then "no" elif any($results[]; .[0] == "maybe") then "maybe" else "yes" end),
  ($results[] | .[1]),
  (if ($results | length) == 0 then "fits any machine" else empty end),
  (if $tested != "" and $have != "" and ($tested | minor) != ($have | minor)
   then "tested on Omarchy \($tested); this machine has \($have)" else empty end)
