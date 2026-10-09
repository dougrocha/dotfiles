# Screenshot toolbar

The screenshot toolbar opens a dimmed overlay on every monitor and a toolbar on the primary monitor. The toolbar has region, window, fullscreen, and video modes, an options menu, and a Capture button. Region mode can restore the last selection for the focused monitor. A timer shows a countdown in the toolbar before it captures.

## Sub-features

- `toolbar-open` shows the dim on all monitors and the toolbar on DP-1 only.
- `toolbar-region` captures the selection with Enter or Capture.
- `toolbar-windows` captures the hovered window on click, and respects an open special workspace.
- `toolbar-fullscreen` captures every monitor.
- `toolbar-timer` counts down for 3, 5, or 10 seconds before it captures.
- `toolbar-cancel` closes on Escape or the close button and saves nothing.

## How to get to it (user POV)

- Press `Super+Ctrl+Shift+S`.
- Run `screenshot-ui` in a terminal.

## Driving it with qsv

Preconditions:

- Baseline from `README.md`.
- Settings are in `~/.local/state/quickshell/settings.json` under `screenshot`. Read `captureMode`, `timerDelay`, and `monitors.<name>.region` first, and restore them at the end.
- The toolbar position is `monitors.DP-1.toolbar`. Find the buttons in a shot of the toolbar. On 2026-10-08 the toolbar was at `1062,1207`, with the region button at `1113,1230` and the window button at `1150,1230`.

- **Open.** Run `qsv key super+ctrl+shift+s`, wait 0.8s, then `qsv shot toolbar "0,0 2560x1440"`. The toolbar shows on DP-1 at its saved position and both monitors are dimmed.
- **Region with Enter.** With a saved region on the focused monitor, run `qsv mark` and `qsv key enter`. Wait `timerDelay` plus 1.6s, then run `qsv captured toolbar-region`. The file size equals the saved region size.
- **Window mode.** Click the window button with `qsv click 1150 1230`. Then point at a window with `qsv at 100 500` and click with `qsv click`. The file size equals that window's size. With a special workspace open on that monitor, the special window wins.
- **Restore the mode.** Click the region button with `qsv click 1113 1230`. Then check that `captureMode` is back to its starting value.
- **Cancel.** Reopen and run `qsv key esc`. `qsv layers qs.screenshot_overlay` prints nothing.

## Gotchas

- Enter does nothing when the focused monitor has no saved region. Focus follows the mouse, so pointing at DP-2 changes which monitor that is.
- Clicking a mode button changes the saved `captureMode`. Restore it.
- With a timer, the overlay stays open during the countdown. Wait for the whole countdown before you check for the file.
- The video mode starts `toggle-recording`. Do not verify it unless the task is about recording. Stop the recording afterwards.
