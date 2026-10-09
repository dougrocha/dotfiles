# Notification toasts

Notifications show as toasts at the top right of the primary monitor. Normal toasts time out, critical toasts stay until closed, and notifications that come in while the notification center is open go to history.

## Sub-features

- `toast-normal` shows a toast that closes after its timeout.
- `toast-critical` shows a toast with a solid tinted fill that stays.
- `toast-actions` shows action buttons from the sender.
- `toast-history` sends notifications to history while the notification center is open.

## How to get to it (user POV)

- Any app sends a notification. In tests, `notify-send` stands in for the app.

## Driving it with qsv

Preconditions:

- Baseline from `README.md`.
- Do Not Disturb is off. Check it in the settings panel. With it on, notifications go directly to history.

- **Normal toast.** Run `notify-send -a Vesktop "Riley" "yo are you on tonight?"`. Wait 0.8s, then run `qsv shot toast "2150,40 400x620"`. A toast shows the app name, title, and body.
- **Critical toast.** Run `notify-send -u critical -t 0 -a Steam "Download failed" "Disk full"`. The toast has the danger-tinted fill and is still there after 10s.
- **Actions.** Run `( notify-send -A open=Open -A dismiss=Dismiss -a Zen "Title" "Body" >/dev/null & )`. The toast shows Open and Dismiss.
- **History.** Open the notification center with `qsv click 2507 17` and send a normal notification. No toast shows, and the shot of the panel lists the new entry.

## Gotchas

- `notify-send -A` waits for a click. Run it in the background as shown.
- Without `-t 0`, a sender timeout can close a critical toast.
- Close the critical toast at the end of the run. It does not time out.
