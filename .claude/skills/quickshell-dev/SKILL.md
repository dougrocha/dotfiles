---
name: quickshell-dev
description: Procedure to apply, verify, and examine a change to the quickshell config in home/.config/quickshell. Use this skill after you edit a QML file there. It tells you how to reload, read the log, show a surface, and get a screenshot. Use the quickshell skill for structure and design rules.
---

# Quickshell development procedure

The config is in `home/.config/quickshell/` in this repo. `~/.config/quickshell` links to it. All paths and commands in this skill are relative to that directory, the config root.

`qsv` is the helper of the verify-quickshell skill: `.claude/skills/verify-quickshell/bin/qsv`, relative to the repo root. Use the full path, or put its directory on `PATH` for the session. Run `qsv help` for every subcommand.

## Rules

- WARNING: Do not start Quickshell. Do not run `qs`, `quickshell`, or `qs -p .`. One instance runs in the user session already. A second instance makes a second bar.
- Do not run `qs kill` unless the user tells you to.
- Examine the log after each change. A failed reload keeps the old build on the screen.

## 1. Apply the change

1. Save the file. The active instance reloads when a file changes.
2. If you replaced the full file (for example with `Write`), run `touch shell.qml` from the config root. The file watcher can miss a replaced file.

## 2. Read the log

1. Run `qsv log`. It prints the lines of the last reload and removes known noise. A clean reload prints nothing.
2. If an error shows, go to the `File.qml[LINE:COL]` in the message. Correct the error. Do step 1 again.
3. If the log does not change after a save, run `touch shell.qml`. Then do step 1 again.
4. After you examine the surface (step 5), read the log again. Some errors show only when a surface opens.

To add a noise pattern, edit the `grep -v` list in `cmd_log` of `qsv`. Do not keep a second list here.

## 3. Show a surface

Use IPC to open and close a panel:

```sh
qs ipc call notification-center toggle
```

Panel targets: `notification-center`, `settings-panel`, `sound-panel`, `bluetooth-panel`, `music-panel`.

- Use `open` to open a panel.
- Use `hide` to close a panel.

The `top-bar` target does not show or hide the bar. Its `pin`, `unpin`, and `toggle` functions pin the bar above fullscreen windows.

Other targets: `island`, `music-control`, `screenshot-overlay`, `screenshot-toast`. Run `qs ipc show` for every target and its functions.

CAUTION: Wait 1 second after a reload before you send an IPC call. Before that, the instance replies `Not ready to accept queries yet` and ignores the call. Then a later `toggle` opens the panel when you expect it to close. Use `open` and `hide`.

CAUTION: `qs ipc call <target> show` does not call the function. It prints the list of functions and gives no error. Do not use `show` as the name of a new `IpcHandler` function.

## 4. Send test notifications

Before you start, make sure that Do Not Disturb is off. When it is on, notifications go directly to history.

- For a toast, close the notification center. Then send the notification.
- For history, open the notification center first. A normal notification that comes in while it is open goes directly to history. A critical notification always shows as a toast.

Use `qsv notify`. It takes `notify-send` arguments and records each ID, so `qsv cleanup` closes the notifications. Run `qsv start <name>` first.

```sh
qsv notify -a Vesktop "Riley" "yo are you on tonight? we're doing raids at 9"
qsv notify -a Vesktop "Sam" "lunch?"
qsv notify -a Chromium "GitHub" "Review requested on #412: refactor notification service"
qsv notify -a Steam "Download complete" "Baldur's Gate 3 is ready to play"
```

- Actions: `( notify-send -A open=Open -A dismiss=Dismiss -a Zen "Title" "Body" >/dev/null & )`. The command waits for a click, so run it in the background.
- Critical: add `-u critical -t 0`. The notification stays until you close it. Without `-t 0`, a timeout from the sender can close it.

## 5. Get a screenshot

The bar and popups are at the top right of the primary monitor. Take monitor positions and sizes from `qsv doctor`, not from memory.

1. Run `qsv start <name>` one time. It makes the directory for the images.
2. Open the surface (step 3), or send toasts (step 4).
3. Wait approximately 0.8 seconds for the open animation.
4. Run `qsv shot <name> "<x>,<y> <w>x<h>"`. On a 2560-wide primary monitor at `0,0`, `"2150,40 400x620"` shows the bar panels and the toasts. For the music panel, capture the top center of the monitor. Without a geometry, `qsv shot` captures all monitors.
5. Read the image.
6. Close the panel with `hide`. Toasts close when they time out, or when you close them.

To examine a hover state, run `qsv at <x> <y>`. It moves the pointer and starts hover. For clicks, keybinds, and pixel checks, use the verify-quickshell skill.

## 6. Iterate

1. Examine the render one time. Write down all problems.
2. Correct all problems in one change.
3. Examine the render one more time.
4. Stop. Tell the user what you changed, what problems remain, and what you could not examine.

## 7. Known problems

- After you change `Theme.qml`, a clean reload shows only that the file parsed. Search for the modules that use the changed token. Examine them too.
- When you rename tokens with `sed`, replace the longer name first. For example, `Theme.fill.selected` is the start of `Theme.fill.selectedSolid`. After the rename, search for broken names such as `selectedSolid[A-Za-z]`.
