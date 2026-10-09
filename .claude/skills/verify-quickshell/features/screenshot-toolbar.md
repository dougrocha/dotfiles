# Screenshot toolbar

The screenshot toolbar opens an overlay on every monitor and a toolbar on the primary monitor. The toolbar has region, window, fullscreen, and video modes, an Options menu, and a Capture button. Region mode dims everything outside the selection on every monitor, and window and fullscreen modes show no dim. With Remember Last Selection on, region mode restores the last selection of the monitor that was focused when the overlay opened. A timer replaces the toolbar with a countdown and a Cancel button before it captures.

## Sub-features

- `toolbar-open` shows the overlay on all monitors and the toolbar on DP-1 only.
- `toolbar-region` dims outside the selection and captures it with Enter or Capture.
- `toolbar-windows` captures the hovered window on click, with no dim, and respects an open special workspace.
- `toolbar-fullscreen` captures every monitor when you choose Capture.
- `toolbar-timer` counts down for 3, 5, or 10 seconds, with a Cancel button, before it captures.
- `toolbar-options` sets the save folder, timer, Show Notification, Remember Last Selection, System Audio, Microphone, and Show Cursor.
- `toolbar-video` starts `toggle-recording` with `--system-audio` and `--mic` when those options are on.
- `toolbar-cancel` closes on Escape, the close button, the countdown's Cancel, or the bind again, and saves nothing.

## How to get to it (user POV)

- Press `Super+Ctrl+Shift+S`.
- Run `screenshot-ui` in a terminal.

## Driving it with qsv

Preconditions:

- Baseline from `README.md`.
- Settings are in `~/.local/state/quickshell/settings.json` under `screenshot`. Read `captureMode`, `timerDelay`, `rememberLastSelection`, `showNotification`, and `monitors.<name>.region` first, and restore them at the end.
- The toolbar position is one entry, `monitors.DP-1.toolbar`. Find the buttons from a shot of the toolbar. On 2026-10-09 the toolbar was at `1062,1207`. The region button was at `1113,1230`, the window button at `1150,1230`, and Options at `1302,1232`. With Options open, Show Notification was at `1230,1022`. During a countdown, Cancel was at `1105,1234`.

- **Open.** Focus DP-1, then run `qsv key super+ctrl+shift+s`, wait 0.8s, and `qsv shot open "0,0 5120x1440"`. The toolbar shows on DP-1. In region mode, a pixel outside the selection is darker than the same pixel with no overlay on both monitors, for example `srgb(15,21,27)` became `srgb(9,13,16)`.
- **Region with Enter.** With Remember Last Selection on and a saved region for DP-1, run `qsv mark` and `qsv key enter`. The toolbar shows `Cancel` and the seconds left. After `timerDelay` plus 1.2s, `qsv captured toolbar-region` prints one file of the saved region's size.
- **Cancel the countdown.** Reopen, press Enter, then within the countdown run `qsv click 1105 1234`. No overlay layer stays, and after the countdown would have ended `qsv captured` prints `none`. Repeat with `qsv key super+ctrl+shift+s` in place of the click. The result is the same.
- **Window mode.** Reopen and run `qsv click 1150 1230`. `captureMode` reads `windows`. Point at a window with `qsv at 2000 300`. A DP-2 pixel equals its no-overlay color, so there is no dim. Run `qsv mark` and `qsv click 2000 300`, wait the timer, then `qsv captured toolbar-window`. The size equals that window's `size` from `hyprctl clients -j`.
- **Options.** Reopen, run `qsv click 1302 1232`, and take a shot of `"900,700 700x620"`. The menu shows Save to, Timer, Options, and Capture sections. `qsv click 1230 1022` flips `showNotification` in the settings file. Click it again to restore.
- **Restore the mode.** Reopen, run `qsv click 1113 1230` and `qsv key esc`. `captureMode` reads `region`.
- **Cancel.** Reopen and run `qsv key esc`. `qsv layers qs.screenshot_overlay` prints nothing.

## Gotchas

- Enter does nothing when Remember Last Selection is off or the focused monitor has no saved region. The monitor is the one focused when the overlay opened.
- Clicking a mode button or an option writes the settings file at once. Restore every value you change.
- Pressing the bind during a countdown cancels it, like Cancel and Escape. Before 2026-10-09 it captured at once.
- Wait for the whole countdown before you check for a file.
- Do not verify video mode unless the task is about recording. If you do, stop the recording afterwards.
