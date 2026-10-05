# Checks a cookbook's cookbook.json, and prints one problem per line.

def one_line: type == "string" and test("\\S") and (test("\n") | not);
def strings: type == "array" and all(.[]; type == "string" and test("\\S"));

if type != "object" then
  "has to be a JSON object"
else
  (if (.owner | type) == "string" and (.owner | test("^[A-Za-z0-9](?:[A-Za-z0-9]|-(?=[A-Za-z0-9])){0,38}$")) then empty
   else "`owner` has to be a GitHub username" end),
  (if (.kitchen | type) == "string" and (.kitchen | test("^v[0-9]+\\.[0-9]+\\.[0-9]+$")) then empty
   else "`kitchen` has to be the omarchy-kitchen version it follows, like \"v0.1.0\"" end),
  (if (.description | one_line) then empty else "`description` has to be one line" end),
  (if has("machines") and (.machines | strings | not) then "`machines` has to be a list of text" else empty end),
  (if has("allow") and (.allow | strings | not) then "`allow` has to be a list of text" else empty end),
  ((keys - ["owner", "kitchen", "description", "machines", "allow"]) as $unknown
    | if ($unknown | length) > 0 then "unknown field " + ($unknown | map("`\(.)`") | join(", ")) else empty end)
end
