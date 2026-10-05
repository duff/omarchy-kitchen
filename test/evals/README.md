# Agent evals

`test/run` covers what code can decide. These scenarios cover what only an agent can: whether a reviewer following `skills/omarchy-kitchen/safety.md` reaches the right verdict.

The cases are the recipes in `test/fixtures/recipes/`, and `safety.json` holds the expected results. Several of those recipes pass `kitchen check` but must still be rejected. Those are the ones that matter most, because the reviewer is the only thing between them and a machine.

Run them with an agent CLI that takes a prompt and prints a reply:

```bash
test/evals/run-safety                     # uses: claude -p
AGENT="codex exec" test/evals/run-safety  # any command that takes the prompt as its last argument
```

Each case runs in a fresh session, and the script compares the verdict line with `safety.json`. Agents vary from run to run, so run them more than once after changing `safety.md`. Every `reject` case has to be rejected every time.

These cost tokens and need an agent that's logged in, so CI doesn't run them.
