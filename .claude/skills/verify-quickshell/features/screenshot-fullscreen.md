# Fullscreen screenshot

Fullscreen screenshot saves one file per monitor with no overlay. It shows one toast for the batch. With several monitors, each file name ends with the monitor name.

## Sub-features

- `fullscreen-bind` saves one file per monitor from the keybind.
- `fullscreen-toolbar` does the same from the toolbar's fullscreen mode.

## How to get to it (user POV)

- Press `Super+Shift+P`.
- Choose the monitor button in the screenshot toolbar, then Capture.

## Driving it with qsv

Preconditions:

- Baseline from `README.md`.

- **Bind.** Run `qsv mark`, `qsv key super+shift+p`, wait 1.5s, then `qsv captured fullscreen`. It prints two files, `...-DP-1.png` and `...-DP-2.png`, each `2560x1440`.
- **Toast.** Run `qsv shot toast "2150,40 400x620"` within 2s. One toast shows for the batch.

## Gotchas

- The file name has a timestamp to the second. Two runs in the same second write the same name.
- The script waits until no `qs.screenshot_overlay` layer is mapped before it runs grim. A capture that hangs about 1.7s means an overlay was still open.
