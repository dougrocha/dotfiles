# Fullscreen screenshot

Fullscreen screenshot saves one file per monitor with no overlay. Each file goes to the clipboard in turn, so the clipboard ends with the last monitor's file. One toast shows both thumbnails at the bottom right of DP-1 for 5 seconds. With several monitors, each file name ends with the monitor name.

## Sub-features

- `fullscreen-bind` saves one file per monitor from the keybind.
- `fullscreen-toolbar` does the same from the toolbar's fullscreen mode after you choose Capture. It also applies the toolbar's options, such as Show Cursor and the save folder.
- `fullscreen-toast` shows one toast for the batch. Hover pauses it, and a click opens the image.

## How to get to it (user POV)

- Press `Super+Shift+P`.
- Choose the monitor button in the screenshot toolbar, then Capture.

## Driving it with qsv

Preconditions:

- Baseline from `README.md`.
- No screenshot toast is showing. Wait 5s after the last capture.

- **Bind.** Run `qsv mark`, `qsv key super+shift+p`, wait 1.5s, then `qsv captured fullscreen`. It prints two `2560x1440` files, from `...-DP-1.png` and `...-DP-2.png`.
- **Toast.** Within 2s run `qsv shot toast "2100,1200 460x240"`. One card with two thumbnails shows at the bottom right. A shot 6s later shows no card.
- **Clipboard.** Compare `wl-paste --type image/png | md5sum` with `md5sum` of each copied file. It matches the DP-2 file, the last one saved.

## Gotchas

- The file name has a timestamp to the second. Two runs in the same second write the same name.
- Before grim runs, the script waits for every `qs.screenshot_overlay` layer to unmap. It checks 50 times with a 0.02s sleep, and each check also runs `hyprctl` and `jq`. That measured about 1.7s in total when an overlay never closed. After that it captures anyway.
- Clicking the toast opens the image in `imv`. Do not click it unless the task is about that.
