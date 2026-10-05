---
{
  "id": "sam/ssh-keys-lost-on-reinstall",
  "title": "SSH keys are lost when reinstalling Omarchy",
  "summary": "Back up SSH keys every hour so a reinstall doesn't lose them.",
  "version": 1,
  "tested_on": {"omarchy": "4.0.4"},
  "applies_to": "Every machine.",
  "requires": [],
  "touches": ["~/.local/bin/key-backup", "~/.config/systemd/user/key-backup.service", "~/.config/systemd/user/key-backup.timer"],
  "root": false,
  "network": true,
  "installs": [],
  "runs": ["key-backup.timer, hourly"],
  "agent_config": false,
  "history": [{"who": "sam", "did": "created", "date": "2026-09-20"}]
}
---

# SSH keys are lost when reinstalling Omarchy

## Problem

Reinstalling Omarchy wipes `~/.ssh`, and with it every key you forgot to copy.

## Fix

Install the backup script from `files/key-backup` as `~/.local/bin/key-backup`,
and the timer that runs it every hour:

```bash
install -m 755 files/key-backup ~/.local/bin/key-backup
cp files/key-backup.service files/key-backup.timer ~/.config/systemd/user/
```

## Apply and check

```bash
systemctl --user daemon-reload
systemctl --user enable --now key-backup.timer
systemctl --user list-timers key-backup.timer
```

## Undo

```bash
systemctl --user disable --now key-backup.timer
rm ~/.local/bin/key-backup ~/.config/systemd/user/key-backup.{service,timer}
```

## History

- Created by [@sam](https://github.com/sam) on 2026-09-20.
