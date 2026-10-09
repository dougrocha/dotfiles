---
name: verify-quickshell
description: Drive the running quickshell shell on Hyprland with real keyboard and pointer input (ydotool, wtype) and prove visual behavior with grim captures and pixel checks. Use it to verify a quickshell surface end to end the way a user reaches it, for example the screenshot overlay, bar panels, or toasts, and when a fix must be shown working rather than just reloading cleanly. Use quickshell-dev for reload and log steps, and quickshell for design rules.
---

# Verify quickshell

This skill proves a quickshell feature works by driving the live session like a user. It presses the real keybinds, moves and clicks the real pointer, and captures the screen with grim.

The helper is `.claude/skills/verify-quickshell/bin/qsv`, relative to the repo root. Run `qsv help` for every subcommand. The examples below call it as `qsv`. Use the full path, or put its directory on `PATH` for the session.

The feature recipes are in `features/`. Read `features/README.md` first.

## 1. Launch

Nothing to launch. Quickshell, Hyprland, and the user's apps already run in the user's session. You drive that one instance.

- Never start `qs` or `quickshell`. A second instance makes a second bar.
- Do not run `qs kill` unless the user tells you to.
- A file save reloads quickshell. Wait about 2 seconds after a save before you send input. Read `qsv log` to see that the reload is clean.
- Start a run before you capture anything. It makes the evidence directory:

    ```sh
    qsv start screenshot-quick
    ```

    The command prints `~/.cache/verify-quickshell/<name>-<timestamp>`. `qsv shot` and `qsv captured` write there.

ydotool needs its daemon, which runs as root. If `qsv doctor` reports that ydotoold does not accept input, ask the user to run this in the prompt. You cannot run sudo.

```sh
! sudo rm -f /tmp/.ydotool_socket; sudo -b ydotoold --socket-path=/tmp/.ydotool_socket --socket-own=1000:1000
```

## 2. Doctor

Run `qsv doctor` before you drive, and again whenever a result looks wrong. It is read only. Every line must be `ok`:

- One quickshell instance runs.
- Quickshell answers IPC.
- The last reload logged no errors.
- Hyprland answers.
- ydotoold accepts input. This is a live call, not a socket check. The daemon can die and leave its socket file behind.
- grim, magick, jq, and wtype are installed.

It also prints each monitor's position and size, open special workspaces, and the cursor position. Take coordinates from that output, not from memory.

## 3. Drive

Use real input. An IPC call is a shortcut for setup and reset only. It does not prove the user path.

| User action | Command | Notes |
|---|---|---|
| Press a keybind | `qsv key super+ctrl+s` | Hyprland binds fire only from ydotool. They ignore wtype. |
| Press a key in a focused surface | `qsv key esc`, `qsv key enter` | `wtype -k Escape` also works here. |
| Move the pointer | `qsv at 3000 500` | Global coordinates across all monitors. |
| Click | `qsv click 3000 500` | Moves first, then clicks. |
| Drag | `qsv drag 300 300 800 700` | Press, five moves, release. |
| Open a special workspace | `hyprctl dispatch 'hl.dsp.workspace.toggle_special("discord")'` | Run it again to close. |
| Focus a monitor | `hyprctl dispatch 'hl.dsp.focus({ monitor = "DP-1" })'` | |
| Make a window fullscreen | `hyprctl dispatch 'hl.dsp.window.fullscreen()'` | Toggles the focused window. |
| Send a test notification | `qsv notify -a QsvTest "title" "body"` | Takes `notify-send` arguments. Records the ID so `qsv cleanup` can close it. |

The config is Lua, so `hyprctl dispatch` takes a Lua expression. The old form `hyprctl dispatch movecursor 3000 500` fails with a parse error.

Run `qsv reset` before each case. It hides every IPC target that has a `hide` function (the screenshot overlay and the bar panels), and releases held keys and mouse buttons. Without it, one failed case corrupts the next. A toggle keybind then closes the overlay that the failed case left open.

## 4. Evidence

Each proof captures the action and the resulting state, and checks side effects as well as pixels.

- **Screen state.** `qsv shot <name> [geometry]` captures with grim. Wait approximately 0.8 seconds after an open before you capture. Then read the PNG.
- **Overlay surfaces.** `qsv layers qs.screenshot_overlay` lists the screenshot overlay surfaces that are mapped. Bar panels are popups, not layers, so they do not show here. Prove a panel with a shot.
- **Saved files.** Run `qsv mark` before the action. After it, `qsv captured <name>` copies each new file in `~/Pictures/Screenshots` into the run directory. It prints the copy, its size, and the original file name. "none" with exit 1 means nothing was saved.
- **Pixels.**
    - `qsv pixel <png> <x> <y>` reads one color.
    - `qsv edge-count <png> '<color>'` counts pixels near a color on the outer 2px frame. That is where a leaked selection border shows.
    - Always compare against a clean grab of the same area with no overlay. Live windows change between grabs, so a raw diff is noisy. Equal counts in the capture and the clean grab mean the color is window content.
- **Accent color.** It comes from the wallpaper through matugen and changes. Read it with `jq -r .accent ~/.config/quickshell/palette.json`. Do not hard-code it. A pixel sampled on a translucent outline is blended, so it does not equal the accent.

Write each result line with the expected value next to it, for example `quick drag DP-2, expect 500x400: size=500x400`.

## 5. Cleanup

Run `qsv cleanup` at the end of a run and after every failed attempt. It does four things:

- Runs `qsv reset`.
- Closes every notification that `qsv notify` sent, over D-Bus. A user cannot close a critical toast by clicking it, so this is the only clean way to remove one.
- Deletes the test files this run created in `~/Pictures/Screenshots`. It deletes only files that `qsv captured` recorded.
- Keeps the evidence directory under `~/.cache/verify-quickshell/`. The proof stays there.

Restore any state you changed: special workspaces, fullscreen, and overlay settings such as the capture mode. Then tell the user these things:

- Each capture overwrote their clipboard (`wl-copy`).
- Each capture showed a toast, unless Show Notification is off in the toolbar's options.
- Which state you restored.

## 6. Gotchas

- **wtype cannot trigger Hyprland binds.** Hyprland ignores binds from virtual keyboards. Use `qsv key` for chords.
- **ydotool absolute moves are wrong past the first monitor.** `ydotool mousemove -a -x 3000` landed at 2170. `qsv at` warps with `hl.dsp.cursor.move` and then sends a 1px ydotool move. Qt gets a real motion event from that move, so hover starts.
- **A silent ydotool call is not a click.** ydotool exits 2 when its daemon is gone. `qsv` stops with an error in that case. Do not hide ydotool errors in your own scripts.
- **Your shell's `/tmp` may not be quickshell's `/tmp`.** A quickshell process could not write to the agent scratchpad under `/tmp/claude-*`. To log from QML, write under `~/.cache`. `console.log` output did not show in `qs log`. A temporary probe that works:

    ```qml
    Quickshell.execDetached(["sh", "-c", "echo \"$0\" >> $HOME/.cache/qsv-debug.log", "PRESS " + mouse.x + "," + mouse.y])
    ```

    Remove the probe before you commit.
- **`qs ipc call <target> show` does not call `show()`.** It prints the function list. Use `toggle`, `open`, `hide`, or a function with another name.
- **Remembered screenshot regions are stored per monitor.** The overlay uses the monitor that is focused when it opens, and focus follows the mouse. If that monitor has no saved region, Enter in toolbar region mode does nothing. That is correct behavior.
- **The focused monitor decides some results.** Set it with `hl.dsp.focus` before a case that depends on it.
- **A flaky multi-monitor result needs a rerun from `qsv reset`.** Do this before you look for a bug. A held key or button from an aborted run makes later cases fail.
