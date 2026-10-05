# Checks a recipe's data (the JSON under "## Recipe data") against
# format.md, and prints one problem per line. Run with --arg folder <recipe folder name> --arg owner <cookbook
# owner, or "">.

def one_line: type == "string" and test("\\S") and (test("\n") | not);
def strings: type == "array" and all(.[]; type == "string" and test("\\S"));
def username: type == "string" and test("^[A-Za-z0-9](?:[A-Za-z0-9]|-(?=[A-Za-z0-9])){0,38}$");
def slug: type == "string" and test("^[a-z0-9]+(?:-[a-z0-9]+)*$");
def version: type == "string" and test("^[0-9]+(\\.[0-9]+)*$");
def date: type == "string" and test("^[0-9]{4}-[0-9]{2}-[0-9]{2}$")
  and ((try (strptime("%Y-%m-%d") | mktime) catch null) != null);
def source: type == "string" and test("^[A-Za-z0-9-]+/[A-Za-z0-9._-]+@[0-9a-f]{7,40}$");
def recipe_id: type == "string" and test("^[^/]+/[^/]+$")
  and (split("/")[0] | username) and (split("/")[1] | slug);

def fields: [
  "id", "title", "summary", "version", "tested_on", "applies_to", "requires", "touches",
  "root", "network", "installs", "runs", "agent_config", "upstream", "upstream_link",
  "obsolete_since", "history"
];
def requirements: ["laptop", "vendor", "model", "monitors", "monitor", "device", "command", "package"];
def actions: ["created", "applied", "adapted"];

def history_problems:
  if (type != "array") or length == 0 then
    "`history` has to list at least the entry that created the recipe"
  else
    to_entries | map(
      (.key + 1) as $n | .value as $e
      | if ($e | type) != "object" then "history entry \($n) has to have who, did, and date"
        else
          ((($e | keys) - ["who", "did", "date", "from", "parent"]) as $unknown
            | if ($unknown | length) > 0 then "history entry \($n) has unknown field \($unknown | join(", "))" else empty end),
          (if ($e.who | username) then empty else "history entry \($n): `who` has to be a GitHub username" end),
          (if ($e.did | IN(actions[])) then empty else "history entry \($n): `did` is created, applied, or adapted" end),
          (if ($e.date | date) then empty else "history entry \($n): `date` has to be a date, like \"2026-10-05\"" end),
          (if ($e.did | IN("applied", "adapted")) and (($e.from | source) | not)
           then "history entry \($n): `from` has to be <owner>/<repo>@<commit>" else empty end),
          (if $e.did == "adapted" and (($e.parent | recipe_id) | not)
           then "history entry \($n): `parent` has to be the id of the recipe it was adapted from" else empty end)
        end
    ) | .[]
  end;

def history_order($id; $owner):
  . as $entries
  | (if $entries[0].did == "created" then empty else "the first history entry has to be `did: created`" end),
    (if [$entries[].date] == ([$entries[].date] | sort) then empty
     else "history dates have to be in order, oldest first" end),
    (if $owner != "" and ($entries[-1].who != $owner)
     then "the last history entry has to be the cookbook owner (\($owner)): who created, adapted, or applied it here"
     else empty end),
    ([$entries[] | select(.did == "created" or .did == "adapted")] | last) as $author
    | if $author != null and ($id | type) == "string" and ($id | split("/")[0]) != $author.who
      then "the id has to start with \($author.who)/, who \($author.did) this version" else empty end;

if type != "object" then
  "the recipe data has to be a JSON object"
else
  . as $h
  | ((keys - fields) as $unknown
      | if ($unknown | length) > 0 then "unknown field " + ($unknown | map("`\(.)`") | join(", ")) else empty end),

    (if ($h.id | recipe_id) then
       ($h.id | split("/")) as [$o, $s]
       | if any([$s, "\($o)--\($s)"][]; . == $folder) then empty
         else "the folder has to be named \($s) (or \($o)--\($s) if that's taken)" end
     else "`id` has to be <github-username>/<slug>, with a lowercase-and-hyphens slug" end),

    (("title", "summary", "applies_to") as $f
      | if ($h[$f] | one_line) then empty else "`\($f)` has to be one line of text" end),

    (if ($h.version | type) == "number" and $h.version >= 1 and $h.version == ($h.version | floor) then empty
     else "`version` has to be a whole number, starting at 1" end),

    (if ($h.tested_on | type) == "object" and ($h.tested_on | has("omarchy")) then
       ($h.tested_on | to_entries[]
        | if (.value | version) then empty
          else "`tested_on.\(.key)` has to be a version in quotes, like \"4.0.4\"" end)
     else "`tested_on` has to list versions, at least omarchy" end),

    (if ($h.requires | type) == "array" then
       ($h.requires[]
        | if type != "object" or length != 1 then "each `requires` item is one key and value, like {\"laptop\": true}"
          else to_entries[0] as {key: $k, value: $v}
          | if ($k | IN(requirements[]) | not) then "`requires` doesn't know `\($k)` (known: \(requirements | join(", ")))"
            elif $k == "laptop" and ($v | type) != "boolean" then "`requires: laptop` has to be true or false"
            elif $k == "monitors" and (($v | type) != "number" or $v < 1 or $v != ($v | floor)) then "`requires: monitors` is how many monitors, like 2"
            elif ($k | IN("laptop", "monitors") | not) and ($v | one_line | not) then "`requires: \($k)` has to be one line of text"
            else empty end
          end)
     else "`requires` has to be a list (use [] for any machine)" end),

    (("touches", "installs", "runs") as $f
      | if ($h[$f] | strings) then empty else "`\($f)` has to be a list (use [] for none)" end),

    (($h.touches | if type == "array" then .[] else empty end) | select(type == "string")
      | if startswith("~/") or startswith("/") then empty else "`touches` paths start with ~/ or / (\(.))" end,
        if startswith("/home/") then "`touches` uses ~, not a home folder path (\(.))" else empty end),

    (("root", "network", "agent_config") as $f
      | if ($h[$f] | type) == "boolean" then empty else "`\($f)` has to be true or false" end),

    (if $h.root == false and any(($h.touches // [])[]; type == "string" and test("^/(etc|usr|boot|opt|var)/"))
     then "the fix changes system files, so `root` has to be true" else empty end),

    (if $h | has("upstream") then
       (if $h.upstream | IN("default", "bug") then empty
        else "`upstream` is default (a better default for Omarchy) or bug" end)
     else empty end),
    (if $h | has("upstream_link") then
       (if ($h.upstream_link | type) == "string" and ($h.upstream_link | startswith("https://")) then empty
        else "`upstream_link` has to be an https:// link" end)
     else empty end),
    (if $h | has("obsolete_since") then
       (if ($h.obsolete_since | version) then empty
        else "`obsolete_since` has to be an Omarchy version in quotes, like \"4.1.0\"" end)
     else empty end),

    ([$h.history | history_problems] as $problems
      | if ($problems | length) > 0 then $problems[] else ($h.history | history_order($h.id; $owner)) end)
end
