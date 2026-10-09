# Quick screenshot

Quick screenshot opens a toolbar-free overlay on every monitor, like macOS Cmd+Shift+4. The window under the pointer gets a rounded outline. A drag captures a region on release. A click captures the window under the pointer, or the whole monitor when no window is there. The file goes to `~/Pictures/Screenshots` and the clipboard, and a toast shows.

## Sub-features

- `quick-open` opens the overlay on all monitors without a toolbar or dim.
- `quick-hover` outlines the window under the pointer, before and after the pointer moves.
- `quick-drag` saves the dragged region on release.
- `quick-click` saves the window under the pointer.
- `quick-special` picks only windows of an open special workspace on its monitor.
- `quick-multimonitor` takes clicks and drags on DP-2 and drags across monitors.
- `quick-clean` saves files with no overlay border or dim in them.
- `quick-cancel` closes on Escape or on the bind again, and saves nothing.

## How to get to it (user POV)

- Press `Super+Ctrl+S`.
- Run `screenshot-ui toggleQuick` in a terminal. The bind runs this command.

## Driving it with qsv

Preconditions:

- Baseline from `README.md`.
- At least one window is on DP-1 and one on DP-2.

- **Open.** Press the bind. Run `qsv key super+ctrl+s`, wait 0.6s, then `qsv layers qs.screenshot_overlay`. You see two `qs.screenshot_overlay` lines, one per monitor.
- **Hover.** Point at a window. Run `qsv at 600 700` and `qsv shot hover "0,0 2560x1440"`. The pixel on the window's left edge (`qsv pixel <png> 12 700` for a window at x=12) is the accent at 70% opacity. A grab with no overlay shows the window color there.
- **Drag.** Run `qsv mark`, `qsv drag 300 300 800 700`, wait 1.2s, then `qsv captured quick-drag`. One file of `500x400` is saved, and `qsv layers qs.screenshot_overlay` prints nothing.
- **Click.** Reopen, then run `qsv mark`, `qsv click 600 700`, and `qsv captured quick-click`. The file size equals the window's `size` from `hyprctl clients -j`.
- **Special workspace.** Focus DP-1 and open a special workspace with `hyprctl dispatch 'hl.dsp.workspace.toggle_special("discord")'`. Reopen and click a point where a workspace window sits under it (`qsv click 100 500`). The saved size is the special workspace window's size, `2536x1380` on 2026-10-08. Close the special workspace afterwards.
- **Second monitor.** Run `qsv click 3000 500`, then `qsv drag 3000 300 3500 700`, then `qsv drag 2300 300 2900 600`, reopening between them. You get a DP-2 window, a `500x400` file, and a `600x300` file.
- **Clean capture.** Read the accent with `A=$(jq -r .accent ~/.config/quickshell/palette.json)`. Count it on a drag file with `qsv edge-count <file> "$A"`. Grab the same area clean with `qsv shot clean "<x>,<y> <w>x<h>"` and count it too. The counts match, `0` and `0` for a drag over a terminal on 2026-10-08. The old border bug gave 813.
- **Cancel.** Reopen and run `qsv key esc`. `qsv layers qs.screenshot_overlay` prints nothing and `qsv captured` prints `none`.

## Gotchas

- The bind toggles. If a case fails with the overlay still open, the next `qsv key super+ctrl+s` closes it. Run `qsv reset` before each case.
- `qsv drag` lands about 1px off at times, so a drag may save `499x400`. Treat ±1px as a pass.
- Clicking in a window gap captures the whole monitor.
- Each capture overwrites the clipboard and shows a toast.
