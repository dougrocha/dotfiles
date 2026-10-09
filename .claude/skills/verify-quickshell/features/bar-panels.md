# Bar panels

Every monitor has a bar whose right-hand group holds CPU, Bluetooth, volume, settings, a Do Not Disturb bell when DND is on, and the clock. Bluetooth, volume, settings, and the clock each open a card under the bar on DP-1, whichever monitor's bar you clicked. Only one card is open at a time. The music panel is separate. It opens from the island at the top center, and it shows only while a media player is active.

## Sub-features

- `panel-notifications` opens the calendar and notification history from the clock.
- `panel-settings` opens settings from the gear.
- `panel-sound` opens sound from the speaker.
- `panel-bluetooth` opens Bluetooth from its icon.
- `panel-single` keeps only one card open. Opening another replaces it.
- `panel-close` closes a card on the same control again, on a click outside the card, or on Escape.
- `panel-other-monitor` opens the card on DP-1 from a control on DP-2's bar.
- `panel-music` expands the island into the music panel.

## How to get to it (user POV)

- Click the control in any bar's right-hand group.
- Click the island at the top center of DP-1 while media plays.
- Run `qs ipc call <target> open|hide|toggle`. This is for setup only. Targets are `notification-center`, `settings-panel`, `sound-panel`, `bluetooth-panel`, and `music-panel`. `qs ipc call panels closeAll` closes whichever is open.

## Driving it with qsv

Preconditions:

- Baseline from `README.md`.
- Find the control positions from `qsv shot bar "1900,0 660x40"`. On 2026-10-09 they were at y=17: Bluetooth x=2407, sound x=2433, settings x=2459, and clock x=2507. On DP-2 the clock was x=5067.

- **Open.** Run `qsv click 2507 17`, wait 0.8s, then `qsv shot panel "2150,40 400x620"`. The calendar and notification card shows under the bar.
- **Replace.** Run `qsv click 2407 17`. The shot shows only the Bluetooth card.
- **Same control closes.** Run `qsv click 2407 17` again. The shot shows no card. A `Bluetooth: On` tooltip can remain.
- **Outside click closes.** Run `qsv click 2459 17`, then `qsv click 1200 800`. The settings card is gone.
- **Escape.** Run `qsv click 2433 17`. `hyprctl submap` prints `qs-panel`. Run `qsv key esc`. The shot shows no card and `hyprctl submap` prints `default`.
- **Other monitor.** Run `qsv click 5067 17`. The calendar card shows on DP-1 in `"2150,40 400x620"`, and DP-2 shows no card.
- **Music.** Requires an active media player. Click the island at `1280,17`. The music panel expands. A click outside closes it.

## Gotchas

- Escape works through the Hyprland submap `qs-panel`, which quickshell enters while a card is open. If `hyprctl submap` still prints `qs-panel` with no card open, the reset failed. Press Escape once to leave it.
- The island and the music panel are hidden while no player is active. Report `panel-music` as unreachable with that prerequisite. Do not start playback on the user's machine to test it.
- The pointer stays on the control, so a shot can include its tooltip, for example `Settings`. Do not read the tooltip as a card.
- Cards are popups, not layer surfaces, so `qsv layers` does not list them. The music panel is part of the `qs.island` layer. Prove cards with a shot. Brightness averages do not tell a card from the window behind it.
- Tray items sit to the left of the controls and do not move them. The clock's text width and the Do Not Disturb bell do. Find the positions again from a bar shot each run.
- After a reload, wait 1s. Before that, IPC replies `Not ready to accept queries yet` and ignores the call.
