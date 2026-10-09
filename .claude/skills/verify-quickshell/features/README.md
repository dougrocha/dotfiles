# Quickshell verification map

This directory is the maintained source for verifying the user-facing behavior of the quickshell config. Read this index before you drive the session, then use the matching feature file as the recipe.

## Baseline preconditions

- `qsv doctor` prints `ok` on every line.
- `qsv start <feature>` made the run's evidence directory.
- `qsv reset` ran, so no overlay or panel is open and no key or button is held.
- No special workspace is open unless the recipe opens one.
- Monitors as `qsv doctor` printed them on 2026-10-08:
    - DP-1 at `0,0` is 2560x1440 at scale 1 and is the primary monitor.
    - DP-2 at `2560,0` is 2560x1440.
    - Check the doctor output before you reuse a coordinate from a recipe.

## Driving conventions

- Press keybinds with `qsv key`. Every bind uses `super`.
- Click and drag with `qsv click` and `qsv drag` in global coordinates.
- Use IPC (`qs ipc call ...`) only to set up or reset state, never as the proof of a user path.
- Run `qsv reset` before each case.
- Restore every workspace and setting you change.

## Proof and skip reporting

- Pair each user action with its result: a shot, a saved file and its size, or the mapped layers.
- Each pixel claim compares the capture with a clean grab of the same area.
- Record the feature ID and the entry point used with every result line.
- Report an unreachable path with the command you ran and the precondition that failed.
- Do not report an entry point as verified because another entry point worked.

## Feature entry contract

Each feature file starts with an H1 title and one paragraph about the user-visible behavior. Then it has exactly four H2 sections in this order:

1. `Sub-features` lists short IDs with one line each.
2. `How to get to it (user POV)` lists every user entry point.
3. `Driving it with qsv` starts with `Preconditions:`. Each bullet pairs a user action with an exact command and the result you can observe.
4. `Gotchas` lists traps that waste or invalidate a run.

## Features

- [Quick screenshot](./screenshot-quick.md) covers `Super+Ctrl+S`: region drag, window click, special workspace priority, both monitors, and Escape.
- [Screenshot toolbar](./screenshot-toolbar.md) covers `Super+Ctrl+Shift+S`: region, window, and fullscreen modes, the timer, and Escape.
- [Fullscreen screenshot](./screenshot-fullscreen.md) covers `Super+Shift+P`: one file per monitor.
- [Bar panels](./bar-panels.md) covers the notification center, settings, sound, and Bluetooth panels.
- [Notification toasts](./notifications.md) covers toasts, critical toasts, and history.
