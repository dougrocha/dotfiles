---
name: quickshell-dev
description: Procedure to apply, verify, and examine a change to this quickshell config. Use this skill after you edit a QML file here. It tells you how to reload, read the log, show a surface, and get a screenshot. Use the quickshell skill for structure and design rules.
---

# Quickshell development procedure

## Rules

- WARNING: Do not start Quickshell. Do not run `qs`, `quickshell`, or `qs -p .`. One instance runs in the user session already. A second instance makes a second bar.
- Do not run `qs kill` unless the user tells you to.
- Examine the log after each change. A failed reload keeps the old build on the screen.

## 1. Apply the change

1. Save the file. The active instance reloads when a file changes.
2. If you replaced the full file (for example with `Write`), run `touch shell.qml` from the config root. The file watcher can miss a replaced file.

## 2. Read the log

1. Run this command. It shows only the last reload:

    ```sh
    qs log 2>&1 | tac | awk '{print} /Reloading configuration/{exit}' | tac
    ```

2. Make sure that no lines are between `Reloading configuration...` and `Configuration Loaded`.
3. If an error shows, go to the `File.qml[LINE:COL]` in the message. Correct the error. Do step 1 again.
4. If no new `Reloading configuration...` line shows, run `touch shell.qml`. Then do step 2 again.
5. After you examine the surface (step 5), read the log again. Some errors show only when a surface opens.

NOTE: These log lines are not errors. Ignore them:

- `qt.text.font.db: OpenType support missing ...`
- `quickshell.service.polkit ... already exists`
- `Could not load icon "..."`
- `quickshell.dbus.properties: Error updating property ...`

## 3. Show a surface

Use IPC to open and close a panel:

```sh
qs ipc call notification-center toggle
```

Panel targets: `notification-center`, `settings-panel`, `sound-panel`, `bluetooth-panel`, `music-panel`.

- Use `toggle` to open a panel.
- Use `hide` to close a panel. A second `toggle` can open the panel again if the first call failed.

The `top-bar` target does not show or hide the bar. Its `toggle` pins the bar above fullscreen windows.

Other targets: `music-control`, `screenshot-overlay`, `screenshot-toast`. Read their functions in the source before you call them.

CAUTION: Wait 1 second after a reload before you send an IPC call. Before that, the instance replies `Not ready to accept queries yet` and ignores the call. Then the next `toggle` opens the panel when you expect it to close.

CAUTION: `qs ipc call <target> show` does not call the function. It prints the list of functions and gives no error. Do not use `show` as the name of a new `IpcHandler` function.

## 4. Send test notifications

Before you start, make sure that Do Not Disturb is off. When it is on, notifications go directly to history.

- For a toast, close the notification center. Then send the notification.
- For history, open the notification center first. A normal notification that comes in while it is open goes directly to history. A critical notification always shows as a toast.

```sh
notify-send -a Vesktop "Riley" "yo are you on tonight? we're doing raids at 9"
notify-send -a Vesktop "Sam" "lunch?"
notify-send -a Chromium "GitHub" "Review requested on #412: refactor notification service"
notify-send -a Steam "Download complete" "Baldur's Gate 3 is ready to play"
```

- Actions: `( notify-send -A open=Open -A dismiss=Dismiss -a Zen "Title" "Body" >/dev/null & )`. The command waits for a click, so run it in the background.
- Critical: add `-u critical -t 0`. The notification stays until you close it. Without `-t 0`, a timeout from the sender can close it.

## 5. Get a screenshot

The primary monitor is `DP-1` at 2560×1440, position `0,0`. The bar and popups are at the top right.

1. Open the surface (step 3), or send toasts (step 4).
2. Wait approximately 0.8 seconds for the open animation.
3. Capture the region to your scratchpad directory. Use a full path:

    ```sh
    grim -g "2150,40 400x620" "$SCRATCH/shot.png"
    ```

    This region shows the bar panels and the toasts. For the music panel, capture the top center of the monitor.

4. Read the image.
5. Close the panel with `hide`. Toasts close when they time out, or when you close them.

If the surface is not in the image, capture all monitors with `grim "$SCRATCH/all.png"`. Then find it.

NOTE: `hyprctl dispatch movecursor` does not start hover in Quickshell. To examine a hover state, calculate it from the geometry. Then ask the user to examine it.

## 6. Iterate

1. Examine the render one time. Write down all problems.
2. Correct all problems in one change.
3. Examine the render one more time.
4. Stop. Tell the user what you changed, what problems remain, and what you could not examine.

## 7. Known problems

- The singletons in `Constants/` cannot import each other. `import qs.Constants` and `import "."` give `undefined` in that directory.
- After you change `Theme.qml`, a clean reload shows only that the file parsed. Search for the modules that use the changed token. Examine them too.
- When you rename tokens with `sed`, replace the longer name first. For example, `Theme.fill.selected` is the start of `Theme.fill.selectedSolid`. After the rename, search for broken names such as `selectedSolid[A-Za-z]`.
