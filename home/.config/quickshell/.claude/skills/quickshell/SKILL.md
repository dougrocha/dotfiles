---
name: quickshell
description: Structure, code rules, and design rules for this quickshell config. Use this skill before you add, change, or review a QML file here. Use it when you design or restyle a surface (bar, popup, notification, panel) or when a surface looks wrong. Use quickshell-dev to apply and examine the change.
---

# Quickshell config

This config is a Wayland shell for Hyprland. It uses QML and Quickshell.
The design target is a quiet macOS look.

## 1. Structure

| Directory                      | Contents                                                                                                                             | Rule                                                                                  |
| ------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------- |
| `shell.qml`                    | The root. It makes one instance of each top-level module.                                                                            | Add a module here only when it has its own window.                                    |
| `Constants/`                   | `Theme.qml` (all design tokens) and `PhosphorIcons.qml` (icon glyphs).                                                               | Singletons in this directory cannot import each other. Put all tokens in `Theme.qml`. |
| `Services/`                    | Singletons that hold state and talk to the system (audio, Bluetooth, notifications, settings).                                       | Put state and system logic here. Do not put layout here. Each file starts with `pragma Singleton`, and its root is `Singleton {}`. |
| `Services/Visibilities.qml`    | One `bool` for each popup, and the `IpcHandler` targets.                                                                             | Open and close popups only through these properties.                                  |
| `Services/SettingsService.qml` | User settings. It writes them to `$XDG_STATE_HOME/quickshell/settings.json`. If `XDG_STATE_HOME` is not set, it uses `$HOME/.local/state`.                                                         | Add a persistent setting here.                                                        |
| `Components/`                  | Shared controls: `Popup`, `PopupCard`, `ListRow`, `ToggleRow`, `SectionLabel`, `Divider`, `IconActionButton`, `CloseBadge`, sliders. | Use a component from here before you make a new one.                                  |
| `Modules/<Name>/`              | One feature for each directory: `Bar`, `Notifications`, `Popups`, `Island`, `Screenshot`, `Polkit`, `TooltipOverlay`.                | Keep files for one feature in its directory. For a window on each monitor, use `Variants { model: Quickshell.screens }` with a `PanelWindow` delegate. |
| `Widgets/`                     | Small items that the bar uses: clock, tray.                                                                                          |                                                                                       |
| `palette.json`                 | Colors from matugen. `Theme.qml` reads this file and watches it for changes.                                                         | Do not edit it. Matugen writes it.                                                    |
| `format`                       | A script that runs `qmlformat` on all QML files.                                                                                     |                                                                                       |

Imports use the `qs.` prefix, for example `import qs.Components` and `import qs.Services`.

A bar panel (settings, sound, Bluetooth, notification center) has four parts:

1. A `bool` in `Visibilities.qml`, for example `soundPanel`.
2. An `open` function and a `toggle` function in `Visibilities.qml`. The `open` function calls `closePopups()` first. Thus only one panel is open at a time.
3. A `Popup` file in `Modules/Popups/`. Bind `shown` to the `bool`. Set the `bool` to `false` in `onDismissed`.
4. An instance in `Modules/Bar/Bar.qml` in a `LazyLoader` with `active: modelData === Theme.primaryScreen`. Set `anchor.window: topBar`.

Other popups use different patterns. Tray menus use `TrayMenuPopup.qml`, which is a `PopupWindow` with local state. The music panel is part of `Modules/Island/`.

## 2. Code rules

Apply these rules to new code and to code that you change. Some old files do not obey them yet. Do not change old files only to obey a rule.

- Write no comments in QML. The code has no comments now. Use clear names.
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
- Run `./format` from the config root after you change more than one file.
- Commit messages use this form: `fix(quickshell): <summary>` or `feat(quickshell): <summary>`.

## 3. Framework patterns

Use these patterns. They are the patterns that this config uses now.

| Task | Pattern | Example |
|---|---|---|
| Start a command and forget it | `Quickshell.execDetached(["cmd", "arg"])`. Quickshell does not track or stop the process. | None yet. Older code uses `Process` for this. Change it when you edit that code. |
| Run a command and use its result or state | `Process` with `command` as a string array. Set `running = true` to start it. | `Services/IdleService.qml` |
| Read command output line by line | `stdout: SplitParser { onRead: data => { } }` | `Services/IdleService.qml` |
| Read or write a file | `FileView` with `atomicWrites: true` and `printErrors: false`. Handle `FileViewError.FileNotFound` in `onLoadFailed`. | `Services/NotificationService.qml` |
| Typed JSON settings | `FileView` with a `JsonAdapter` | `Services/SettingsService.qml` |
| CLI control | `IpcHandler` with a `target` and typed functions | `Services/Visibilities.qml` |
| Audio nodes | Bind the nodes with `PwObjectTracker { objects: [...] }`. Without it, properties such as `audio.volume` are not available. | `Services/AudioService.qml` |
| Tray menus | `QsMenuOpener` gives the menu entries. The config draws the menu itself. | `Modules/Popups/TrayMenuList.qml` |

### 3.1 Known problems

| Problem | Cause and correction |
|---|---|
| An inline component cannot see an outer `id` or a `required property`. | Add `pragma ComponentBehavior: Bound`. |
| A hover check never changes. | `HoverHandler` has `hovered`. `containsMouse` is a `MouseArea` property. |
| `Process` does not start. | `command` is a string. Make it an array, for example `["sh", "-c", "..."]`. |
| An audio node has no `audio` data. | Add the node to `PwObjectTracker`. |
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
| Accent and danger | `Theme.accent`, `Theme.danger`                                                                        |
| Spacing           | `Theme.space.xxs` (2) to `.xxl` (24)                                                                  |
| Radius            | `Theme.radius.xxs` (2) to `.xxl` (24)                                                                 |
| Icon size         | `Theme.icon.xxs` (12) to `.xxl` (40)                                                                  |
| Type              | `Theme.type.title`, `.body`, `.label`, `.caption`, `.mono`, `.display` (each has `size` and `weight`) |
| Motion            | `Theme.motion.fast` (140), `.normal` (200), `.slow` (320), and the easing tokens                      |
| Font              | `Theme.font.ui`, `.mono`, `.icon`, `.iconFill`                                                        |

Do not write a hex color in a module. Use `Theme.withAlpha(color, alpha)` for transparency.
If a token does not exist, add it to `Theme.qml`. Do not write the value in the module.

## 5. Design rules

### 5.1 Surfaces

- Use one level of container. A popup is a card already (`PopupCard`). Do not put a filled card or a bordered card in it.
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

Do the squint test first. Blur the surface in your mind. You must see the title, then the groups, then the rows. If you cannot, change the spacing first. Do not add a line, a fill, or a color first.

- Put a small gap between a label and its content. Put a medium gap between rows. Put the largest gap between groups. The notification history uses approximately 8, 12, and 30 pixels.
- Put more space above a heading than below it.
- Make a label row the same height as its text. A 22 px row with 11 px text adds approximately 5 px of hidden space above and below the text.
- Use this type order. Do not add new sizes.

  | Role | Size | Weight | Color |
  |---|---|---|---|
  | Panel title | `type.title` | `type.title` | `text.primary` |
  | Item title | `type.body` | `type.title` | `text.primary` |
  | Body | `type.body` | `type.body` | `text.secondary` |
  | Metadata | `type.caption` or `type.label` | same | `text.tertiary` |
- Use `Theme.accent` only for selection, links, and active state. Use `Theme.danger` only for critical and destructive items.

### 5.4 Controls and hover

- Show secondary controls on an item (close, clear group) only on hover.
- Animate their `opacity` with `Theme.motion.fast`. Set `enabled: opacity > 0`.
- Keep primary actions and panel actions visible, for example "Clear all" in the notification center header.
- Align the row text with the content edge. Let the hover fill extend past the edge by `bleed` (see `ListRow` and `HistoryRow` in `NotificationHistory.qml`).
- If an ancestor has `clip: true`, add `bleed` on the left and on the right. Set `x: -bleed` and `width: parent.width + bleed * 2`. Move the content back with `x: bleed`. If not, the clip cuts the hover fill.
- Put a badge on a rounded corner at the center of the curve. Move it in by `radius * (1 - Math.SQRT1_2)` from the corner of the bounding box (see `CloseBadge` in `NotificationCard.qml`).

### 5.5 Motion

- Use `Behavior` with `Theme.motion.fast` for hover and color changes.
- Use `Theme.motion.normal` with `easeStandard` to open, and `Theme.motion.fast` with `easeExit` to close.
- Use motion to show a change of state only.

## 6. Checklist

Before you finish, make sure that:

- The squint test passes.
- The change has no hex colors, no nested cards, and no app icons.
- Public functions have types.
- New input code uses handlers. It uses `MouseArea` only for a task that handlers cannot do.
- You examined these conditions in the real render: empty state, long text, a group with many items, and a critical item.
