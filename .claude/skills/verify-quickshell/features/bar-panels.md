# Bar panels

The bar on the primary monitor opens one panel at a time from its controls on the right side. Each panel is a popup card below the bar, and opening another panel closes the open one.

## Sub-features

- `panel-notifications` opens the calendar and notification center from the clock.
- `panel-settings` opens settings from the gear.
- `panel-sound` opens sound from the speaker.
- `panel-bluetooth` opens Bluetooth from its icon.
- `panel-single` keeps only one panel open at a time.

## How to get to it (user POV)

- Click the control in the bar's right group on DP-1.
- Run `qs ipc call <panel> toggle`. This is for setup only. Targets are `notification-center`, `settings-panel`, `sound-panel`, `bluetooth-panel`, and `music-panel`.

## Driving it with qsv

Preconditions:

- Baseline from `README.md`.
- Find the control positions in a shot of the bar with `qsv shot bar "1900,0 660x40"`. On 2026-10-08 they were at y=17: Bluetooth x=2407, sound x=2433, settings x=2459, and clock x=2507.

- **Open from the bar.** Click a control, for example `qsv click 2507 17`. Wait 0.8s, then run `qsv shot panel "2150,40 400x620"`. The card for that panel shows below the bar.
- **One at a time.** Click a second control. The shot shows only the second panel.
- **Close.** Click the same control again, or run `qsv reset`. A new shot shows no card.

## Gotchas

- The pointer stays on the control, so a shot can include its hover tooltip, for example `Settings`. Do not read the tooltip as a panel.
- Panels are popups, not layer surfaces. `qsv layers` does not list them. Prove them with a shot.
- Control positions move when tray items appear or disappear. Find them again from a bar shot every run.
- After an IPC reload, wait 1s. Before that, IPC replies `Not ready to accept queries yet` and ignores the call.
