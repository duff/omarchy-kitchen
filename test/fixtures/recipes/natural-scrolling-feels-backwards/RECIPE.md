---
{
  "id": "sam/natural-scrolling-feels-backwards",
  "title": "Scrolling feels backwards on the touchpad",
  "summary": "Turn on natural scrolling for the touchpad.",
  "version": 1,
  "tested_on": {"omarchy": "4.0.4", "hyprland": "0.56.2"},
  "applies_to": "Laptops.",
  "requires": [{"laptop": true}],
  "touches": ["~/.config/hypr/input.lua"],
  "root": false,
  "network": false,
  "installs": [],
  "runs": [],
  "agent_config": false,
  "history": [{"who": "sam", "did": "created", "date": "2026-09-20"}]
}
---

# Scrolling feels backwards on the touchpad

## Problem

Two fingers up scrolls the page down, the opposite of a phone.

## Why it happens

Hyprland's `input.touchpad.natural_scroll` is off by default, and Omarchy
keeps that default in `/usr/share/omarchy/default/hypr/input.lua`.

## Fix

Add this to `~/.config/hypr/input.lua`:

```lua
hl.config({ input = { touchpad = { natural_scroll = true } } })
```

## Apply and check

```bash
hyprctl reload
hyprctl configerrors
```

Scroll a long page with two fingers: content should follow your fingers.

## Undo

Delete the line from `~/.config/hypr/input.lua` and run `hyprctl reload`.

## History

- Created by [@sam](https://github.com/sam) on 2026-09-20.
