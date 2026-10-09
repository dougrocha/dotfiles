# Notification toasts

Notifications show as a stack of cards at the top right of DP-1, below the bar. A normal card closes after the sender's timeout, or 3 seconds by default, and then moves to history. Hover pauses the timeout. A critical card has a red-tinted fill and border and stays unless the sender gave a positive timeout. While Do Not Disturb is on or the notification center is open, normal notifications go straight to history. A critical one still shows as a card, and while the center is open it waits until the center closes.

## Sub-features

- `toast-normal` shows a card that closes after its timeout.
- `toast-close` closes a normal card on a left click. The source also closes it on a right click and on its X badge, which shows on hover. Those two paths were not driven on 2026-10-09.
- `toast-critical` shows a red-tinted card that stays.
- `toast-actions` shows the sender's action buttons.
- `toast-history` sends normal notifications to history while the center is open or Do Not Disturb is on.
- `toast-held-critical` holds a critical card while the center is open and shows it after the center closes.
- `toast-history-file` saves history to `~/.local/state/quickshell/notifications.json`.

## How to get to it (user POV)

- Any app sends a notification. In tests, `qsv notify` stands in for the app.
- Open history from the bar clock.
- Toggle Do not disturb in the settings card from the gear.

## Driving it with qsv

Preconditions:

- Baseline from `README.md`.
- Do not disturb is off. The settings card shows its switch off, and the bar has no bell icon.
- Move the pointer away from the stack with `qsv at 1200 800`. A hovered card does not time out.

- **Normal.** Run `qsv notify -a QsvTest "qsv normal" "normal body"`, wait 0.8s, then `qsv shot toast "2150,40 400x620"`. The card shows the title, the body, and `QsvTest`. A shot 4.3s later shows no card.
- **Click closes.** Run `qsv notify -t 15000 -a QsvTest "qsv long" "click me"`, then click the card. It is gone well before 15s.
- **Actions.** Run `( notify-send -A open=Open -A dismiss=Dismiss -a QsvTest "qsv actions" "has actions" >/dev/null & )`. The card shows Open and Dismiss buttons.
- **Critical.** Run `qsv notify -u critical -t 0 -a QsvTest "qsv critical" "stays"`. The card has a red tint and is still there after 10s.
- **History.** Run `qsv click 2507 17` to open the center, then `qsv notify -a QsvTest "qsv history" "while center open"`. No card shows, and the center lists the entry under `QsvTest`.
- **Held critical.** With the center open, run `qsv notify -u critical -t 0 -a QsvTest "qsv held" "held"`. No card shows. Close the center with `qsv click 2507 17`. The critical card now shows.
- **History file.** `jq -r '[.. | strings | select(test("^qsv "))] | unique' ~/.local/state/quickshell/notifications.json` lists the normal test titles.
- **Cleanup.** `qsv cleanup` closes every card that `qsv notify` sent, critical ones included.

## Gotchas

- A critical card does not close on a left click, a right click, or its X badge. This was observed on 2026-10-09 and is a product gap, while normal cards close on a click. Send critical tests through `qsv notify` so `qsv cleanup` can close them over D-Bus.
- `notify-send -A` waits for a click and prints no ID while it waits, so `qsv notify` cannot record it. Run it in the background as shown and let it time out.
- Without `-t 0`, a sender timeout can close a critical card.
- Test titles stay in the history file. Clear them from the center's `Clear all` only if the user agrees, because that clears their real history too.
