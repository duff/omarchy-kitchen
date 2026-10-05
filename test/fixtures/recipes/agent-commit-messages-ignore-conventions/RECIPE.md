---
{
  "id": "sam/agent-commit-messages-ignore-conventions",
  "title": "Agent commit messages ignore git conventions",
  "summary": "Tell Claude Code how commit messages should look, for every project.",
  "version": 1,
  "tested_on": {"omarchy": "4.0.4"},
  "applies_to": "Anyone using Claude Code.",
  "requires": [{"command": "claude"}],
  "touches": ["~/.claude/CLAUDE.md"],
  "root": false,
  "network": false,
  "installs": [],
  "runs": [],
  "agent_config": true,
  "history": [{"who": "sam", "did": "created", "date": "2026-09-20"}]
}
---

# Agent commit messages ignore git conventions

## Problem

Claude Code writes long commit subjects with trailing periods, unlike the rest
of the history.

## Fix

Add this to `~/.claude/CLAUDE.md`, which Claude Code reads in every project:

```markdown
- Write commit subjects in the imperative, capitalized, with no trailing
  period, and under about 50 characters. Explain why in the body.
```

## Apply and check

Start a new Claude Code session, make a change, and ask it to commit.

## Undo

Delete those lines from `~/.claude/CLAUDE.md`.

## History

- Created by [@sam](https://github.com/sam) on 2026-09-20.
