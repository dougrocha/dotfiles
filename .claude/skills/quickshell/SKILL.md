---
name: quickshell
description: Structure, code rules, and design rules for the quickshell config in home/.config/quickshell. Use this skill before you add, change, or review a QML file there. Use it when you design or restyle a surface (bar, popup, notification, panel) or when a surface looks wrong. Use quickshell-dev to apply and examine the change.
---

# Quickshell config

This config is a Wayland shell for Hyprland. It uses QML and Quickshell.
The design target is a quiet macOS look.

The config is in `home/.config/quickshell/` in this repo. `~/.config/quickshell` links to it. All paths and commands in this skill are relative to that directory, the config root, unless they start with `.claude/`. Those are relative to the repo root.

## 1. Structure

| Directory                      | Contents                                                                                                                             | Rule                                                                                  |
| ------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------- |
| `shell.qml`                    | The root. It makes one instance of each top-level module.                                                                            | Add a module here only when it has its own window.                                    |
| `Constants/`                   | `Theme.qml` (all design tokens) and `PhosphorIcons.qml` (icon glyphs).                                                               | Singletons in this directory cannot import each other (see 3.1). Put all tokens in `Theme.qml`. |
| `Services/`                    | Singletons that hold state and talk to the system (audio, Bluetooth, notifications, settings).                                       | Put state and system logic here. Do not put layout here. Each file starts with `pragma Singleton`, and its root is `Singleton {}`. |
| `Services/Visibilities.qml`    | The one slot for transient UI: a bar panel, the music panel, or a tray menu. `names` declares each panel name. It also registers the IPC targets of those panels and `panels`. | Open and close panels only with `open`, `close`, `toggle`, and `dismissAll`. Pass `Visibilities.names.<key>`, never a string. While the slot is in use, Hyprland stays in the `qs-panel` submap. Its Escape bind (in `home/.config/hypr/bindings.lua`) calls `closeAll` on the `panels` target, which calls `dismissAll`. |
| `Services/BarService.qml`      | Bar `pinned` and `revealed`, `wantsReveal(...)`, and the IPC target `top-bar`.                                                       | The bar calls `wantsReveal` and `setRevealed`. Island reads `revealed`. Do not keep bar state in `Visibilities`. |
| `Services/Desktop.qml`         | Screens and Hyprland state: `primaryScreen(s)`, `focusedScreen()`, `fullscreenOn(screen)`, `openSpecial(monitor)`, `isShowing(name)`, and the one refresh policy. | Read monitors, workspaces and fullscreen through it. Do not call `Hyprland.refresh*` or read `lastIpcObject` elsewhere, except for the screenshot window picker. |
| `Services/ScreenshotSession.qml` | The screenshot session: phase, selection, drag, options, toolbar placement, countdown, capture argv, and the IPC target `screenshot-overlay`. `ScreenshotGeometry.js` next to it holds the maths. | `Modules/Screenshot/` views read it and call `beginDrag`, `dragTo`, `endDrag`, `capture`, `dismiss`, and the option commands. They never write its state. |
| `Services/SettingsService.qml` | User settings. It writes them to `$XDG_STATE_HOME/quickshell/settings.json`. If `XDG_STATE_HOME` is not set, it uses `$HOME/.local/state`.                                                         | Add a persistent setting here. Put a feature's settings in its own `JsonObject` section, and read them as `SettingsService.<section>.<key>`. |
| `Components/`                  | Shared controls: `Popup`, `Presence`, `SizeMotion`, `ContentFade`, `SpringMotion`, `PanelHeader`, `PanelGroup`, `PanelRow`, `DeviceRow`, `PanelFooterLink`, `Switch`, `SectionLabel`, `Divider`, `IconActionButton`, `IconButton`, `CloseBadge`, `TextLink`, sliders. | Use a component from here before you make a new one.                                  |
| `Modules/<Name>/`              | One feature for each directory: `Bar`, `Notifications`, `Popups`, `Island`, `Screenshot`, `Polkit`, `Dictation`, `TooltipOverlay`.                | Keep files for one feature in its directory. For a window on each monitor, use `Variants { model: Quickshell.screens }` with a `PanelWindow` delegate. |
| `Widgets/`                     | Small items that the bar uses: clock, tray.                                                                                          |                                                                                       |
| `palette.json`                 | Colors from matugen. `Theme.qml` reads this file and watches it for changes.                                                         | Do not edit it. Matugen writes it.                                                    |
| `format`                       | A script that runs `qmlformat` on the files you pass, or on all QML files when you pass none.                                        |                                                                                       |

Imports use the `qs.` prefix, for example `import qs.Components` and `import qs.Services`.

A bar panel (settings, sound, Bluetooth, notification center) has four parts: a key in `Visibilities.names` (its value is also the IPC target, which `Visibilities` registers), a `Popup` file in `Modules/Popups/`, a `LazyLoader` instance in `Modules/Bar/Bar.qml` that sets `trigger` to the bar control, and the bar control. Copy them from "Add a bar panel" in `references/qml-patterns.md`. `Popup` sets the position, `shown`, and the enter and exit motion, and closes the panel when the user dismisses it. Use `onOpened` for work at open time. Call `panel.close()` to close the panel from a control.

`Visibilities` has one slot, so only one panel or tray menu is open at a time. `Visibilities.close(name)` closes only that panel, so a late dismiss from an old panel does not close the new panel. `open` warns and ignores a name that is not in `names`. Call `dismissAll()` to clear the panel and the tray menu, for example when a control launches an app.

A service does not own panel visibility. A service can read `Visibilities.isOpen(...)`, for example to hide the OSD while the sound panel is open.

Two panels do not use `Popup`. Tray menus use `Modules/Popups/TrayMenuPopup.qml`, a `PopupWindow` whose `open` flag `Widgets/TraySection.qml` binds to `Visibilities.trayMenu`. Open them with `toggleTrayMenu(screen, itemId)` and close them with `closeTrayMenu()`. The music panel is part of `Modules/Island/`.

### 1.1 Architecture style

Write imperative code that a reader can follow from top to bottom. The config has one author. Do not add plugins, manifests, registries, or tests.

- A feature has one owner of its state, usually a singleton in `Services/`. The owner exposes named commands, for example `capture()`, `dismiss(id)`, or `pause()`. Each command changes state in one function, step by step.
- Views read state and call commands. A view never writes the owner's state.
- Bindings only display state, for example `text: ScreenshotSession.mode`. Do not put logic in a chain of bindings that react to each other.
- Put maths, such as geometry, expiry, or date rules, in plain functions in the owner. Move them to a `.js` file next to it only when the owner gets too long.
- Keep one list for one set of items, such as capture modes or timer delays, in the owner. Other code reads that list.
- Keep the owner's interface small. A property or function that only the owner uses is not part of it; prefix it with `_`.

## 2. Code rules

Apply these rules to new code and to code that you change. Some old files do not obey them yet. Do not change a file only to obey a rule.

`.claude/skills/quickshell/bin/qslint` checks the rules that a script can prove: hex colors, comments, app icons, `PersistentProperties`, delegates without `Bound`, `MouseArea`, import order, untyped `IpcHandler` functions, size animations without `SizeMotion`, and scale starts other than `Theme.motion.scaleFrom`. It accepts file arguments. With no arguments it checks the QML files that changed since `HEAD`. `qslint --all` checks every file. A `MouseArea` result is correct when a handler cannot do the task.

- Write no comments in QML. Use clear names.
- Use `pragma ComponentBehavior: Bound` in files with delegates. Declare model data as `required property`.
- Use `ScriptModel` for a `Repeater` on a JavaScript array. Set `objectProp` to a property that is unique and stable for each item, for example `"id"` or `"address"`.
- Use a `component Name: Type { }` inline component for a part that only one file uses.
- Keep a property `readonly` when nothing writes to it.
- Put imports in this order: Qt (`QtQuick`, `QtQuick.Layouts`), then `Quickshell` modules, then `qs.*` modules.
- Give types to public functions: service functions that other files call, and all `IpcHandler` functions. Example: `function setVolume(volume: real): void`. Local helper functions do not need types.
- Use `TapHandler` and `HoverHandler` for input. Use `MouseArea` only when a handler cannot do the task, for example wheel events.
- Use `?.` and `??` on Quickshell objects that can be `null`, for example `sink?.audio?.volume ?? 0`.
- In `Connections`, write handlers as functions: `function onNotificationsChanged() { }`.
- Keep persistent data in files (`SettingsService`, `FileView`). Do not use `PersistentProperties`.
- Run `./format <files>` from the config root with the QML files that you changed. Do not run `./format` with no arguments, because it formats every QML file.
- Commit messages use this form: `fix(quickshell): <summary>` or `feat(quickshell): <summary>`.

## 3. Framework patterns

Use these patterns. They are the patterns that this config uses now.

| Task | Pattern | Example |
|---|---|---|
| Start a command and forget it | `Quickshell.execDetached(["cmd", "arg"])`. Quickshell does not track or stop the process. | `Modules/Popups/BluetoothPopup.qml`. Older code uses `Process` for this. Change it when you edit that code. |
| Run a command and use its result or state | `Process` with `command` as a string array. Set `running = true` to start it. | `Services/IdleService.qml` |
| Read command output line by line | `stdout: SplitParser { onRead: data => { } }` | `Services/IdleService.qml` |
| Read or write a file | `FileView` with `atomicWrites: true` and `printErrors: false`. Handle `FileViewError.FileNotFound` in `onLoadFailed`. | `Services/NotificationService.qml` |
| Typed JSON settings | `FileView` with a `JsonAdapter` | `Services/SettingsService.qml` |
| CLI control | `IpcHandler` with a `target` and typed functions | `Services/Visibilities.qml` |
| Audio nodes | Bind the nodes with `PwObjectTracker { objects: [...] }`. Without it, a node has no `audio` data and properties such as `audio.volume` are not available. | `Services/AudioService.qml` |
| Tray menus | `QsMenuOpener` gives the menu entries. The config draws the menu itself. | `Modules/Popups/TrayMenuList.qml` |

### 3.1 Known problems

| Problem | Cause and correction |
|---|---|
| An inline component cannot see an outer `id` or a `required property`. | Add `pragma ComponentBehavior: Bound`. |
| A `Constants/` singleton is `undefined` in another `Constants/` file. | `import qs.Constants` and `import "."` do not work in that directory. Put the value in `Theme.qml`. |
| A hover check never changes. | `HoverHandler` has `hovered`. `containsMouse` is a `MouseArea` property. |
| `Process` does not start. | `command` is a string. Make it an array, for example `["sh", "-c", "..."]`. |
| The log shows a binding loop. | Find the two properties that depend on each other. Remove one dependency. |
| `menu.open()` on a tray item does nothing. | `SystemTrayItem.menu` is a handle, not a menu. Give it to `QsMenuOpener` and draw the entries. |

## 4. Design tokens

Use only tokens from `Theme.qml` for these values:

| Value             | Token                                                                                                 |
| ----------------- | ----------------------------------------------------------------------------------------------------- |
| Surface color     | `Theme.colors.bg`, `.surface`, `.raised`, `.overlay`                                                  |
| Text color        | `Theme.text.primary`, `.secondary`, `.tertiary`                                                       |
| State fill        | `Theme.fill.hover`, `.press`, `.strong`, `.selected`                                                  |
| Line              | `Theme.stroke.hairline`, `.strong`, `.accent`                                                         |
| Accent and status | `Theme.accent`, `Theme.danger`, `Theme.caution`                                                       |
| Panel             | `Theme.panel.width` (320), `.padding` (12), `.rowBleed` (6)                                          |
| Spacing           | `Theme.space.xxs` (2) to `.xxl` (24)                                                                  |
| Radius            | `Theme.radius.xxs` (2) to `.xxl` (24)                                                                 |
| Icon size         | `Theme.icon.xxs` (12) to `.xxl` (40)                                                                  |
| Type              | `Theme.type.title`, `.body`, `.label`, `.caption`, `.mono`, `.display` (each has `size`, `weight`, and `tracking`) |
| Motion            | `Theme.motion.fast` (140), `.normal` (200), `.slow` (320), and the easing tokens                      |
| Font              | `Theme.font.ui`, `.mono`, `.icon`, `.iconFill`                                                        |

Do not write a hex color in a module. Use `Theme.withAlpha(color, alpha)` for transparency.
If a token does not exist, add it to `Theme.qml`. Do not write the value in the module.

## 5. Design rules

### 5.1 Surfaces

- Use one level of container. A popup is a card already (`Popup`). Do not put a filled card or a bordered card in it.
- Make groups with spacing, `Divider`, and hover fills.
- Card radius is `Theme.radius.xl`. Controls in a card use `radius.md` or `radius.sm`.
- Use a border or a shadow for elevation. Do not use the two together on one surface.
- Use a solid fill for a critical item: `Qt.tint(Theme.colors.surface, Theme.withAlpha(Theme.danger, 0.12))`. A transparent fill shows the desktop behind the window.

### 5.2 Icons

- Do not show app icons (`IconImage` with an app icon) in notifications, lists, or popups. Linux app icons do not have one style, and they look bad at small sizes.
- Exception: tray items show the icon that the app gives. The tray has no other identity for an item.
- Show the app name as text in `Theme.text.tertiary` or with `SectionLabel`.
- Use `PhosphorIcons` glyphs for controls. Use `Theme.font.icon` for these glyphs.

### 5.3 Hierarchy and spacing

Do the squint test first. Blur the surface in your mind. You must see the title, then the groups, then the rows. If you cannot, change the spacing. Do not add a line, a fill, or a color first.

- Put a small gap between a label and its content, a medium gap between rows, and the largest gap between groups. `PanelGroup` puts `Theme.space.sm` between its label and its content. `Popup` puts `Theme.space.xl` between groups.
- Put more space above a heading than below it.
- Make a label row the same height as its text. A 22 px row with 11 px text adds about 5 px of hidden space above and below the text.
- Use this type order. Do not add new sizes.

  | Role | Size | Weight | Color |
  |---|---|---|---|
  | Panel title | `type.title` | `type.title` | `text.primary` |
  | Item title | `type.body` | `type.title` | `text.primary` |
  | Body | `type.body` | `type.body` | `text.secondary` |
  | Metadata | `type.caption` or `type.label` | same | `text.tertiary` |
- Use `Theme.accent` only for selection, links, and active state. Use `Theme.danger` only for critical and destructive items.

### 5.4 Controls and hover

`references/qml-patterns.md` has the code for each rule below.

- Show secondary controls on an item (close, clear group) only on hover. Fade them with `Theme.motion.fast`, and set `enabled: opacity > 0`.
- Keep primary actions and panel actions visible, for example "Clear all" in the notification center header.
- Align the row text with the content edge. The hover fill extends past the edge. Build the row on `PanelRow`, or pass `bleed: Theme.panel.rowBleed`.
- If an ancestor has `clip: true`, set `x: -bleed` and `width: parent.width + bleed * 2` on the clipped item, and move the content back with `x: bleed`. Otherwise the clip cuts the hover fill.
- Put a badge on a rounded corner at the center of the curve, as `CloseBadge` in `NotificationCard.qml` does.

### 5.5 Motion

- Use `Behavior` with `Theme.motion.fast` for hover and color changes.
- Use `Theme.motion.normal` with `easeStandard` to open, and `Theme.motion.fast` with `easeExit` to close.
- Use motion to show a change of state only.
- To animate the size of a container, use `SizeMotion on height {}` (or `width`, `implicitWidth`, `Layout.preferredHeight`). It grows in `motion.normal` and shrinks in `motion.fast`. Do not write a `NumberAnimation` for size. Do not animate the size of a window. Make the window large enough for the largest state, and set `mask` to the animated item.
- Content that appears in a container that grows fades in with `ContentFade on opacity {}` and moves `Theme.motion.nudge` into place with a `Translate`. The calendar month change is the reference. It uses a short move and a fade, not a large slide. The code is in `references/qml-patterns.md`.
- Value fills (slider, OSD level, progress) and the Island springs are not size changes. Keep their own animations.
- A surface that appears and disappears uses `Presence`: `visible: presence.mapped`, `opacity: presence.progress`, `scale: presence.scale`. It scales from `Theme.motion.scaleFrom` (0.95) to 1 with a strong ease-out (`Theme.motion.curveOut`), enters in `motion.normal`, and exits in `motion.fast`. The window stays mapped until the exit ends. Do not write a second enter or exit animation. The code is in `references/qml-patterns.md`.
- Scale a popover from the side of its trigger, and an alert from its center. Never scale from 0 or from another literal. `qslint` checks this.

### 5.6 More design decisions

For a decision that this file does not make:

- Read `references/design-surfaces.md` for a surface: panels, menus, toasts, the Island, polkit, controls, and feedback. It maps each one to Apple's Human Interface Guidelines (HIG).
- Read `references/design-style.md` for color, UI text, and restraint.

## 6. Checklist

Before you finish, make sure that:

- `qslint` prints no problems, or each problem is a `MouseArea` that a handler cannot replace.
- The squint test passes.
- The change has no nested cards.
- Service functions that other files call have types.
- You examined these conditions in the real render (use quickshell-dev): empty state, long text, a group with many items, and a critical item.
