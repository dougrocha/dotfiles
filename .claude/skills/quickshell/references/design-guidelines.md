# Design guidelines for the shell

This file gives the design rules from Apple's Human Interface Guidelines (HIG) that apply to this shell. It also gives the writing rules from the `frontend-design` skill. The rules in `SKILL.md` and `qslint` come first. Use this file when a surface needs a decision that `SKILL.md` does not make.

Sources:

- The `ebuntario/apple-hig` skill (commit `c434b91`, files verified against the live HIG on 2026-04-20 and 2026-04-21). Each rule below names the HIG page.
- The `frontend-design` skill in `claude-plugins-official`, for writing and restraint only.

## 1. How the shell maps to Apple's terms

| Shell surface | Apple term | HIG page |
|---|---|---|
| Bar panels (`Popup`): sound, Bluetooth, settings, notification center | Popover from a menu bar extra | [popovers](https://developer.apple.com/design/human-interface-guidelines/popovers) |
| Tray menus (`TrayMenuPopup`) | Menu | [menus](https://developer.apple.com/design/human-interface-guidelines/menus) |
| Toasts (`NotificationManager`) | Notification banner | [managing-notifications](https://developer.apple.com/design/human-interface-guidelines/managing-notifications) |
| Island | Dynamic Island with a Live Activity | [live-activities](https://developer.apple.com/design/human-interface-guidelines/live-activities) |
| Polkit dialog | Alert | [alerts](https://developer.apple.com/design/human-interface-guidelines/alerts) |
| Screenshot toast | Feedback for a significant action | [feedback](https://developer.apple.com/design/human-interface-guidelines/feedback) |

Do not use iOS ideas here: tab bars, sheets from the bottom of the screen, "tap" in text, or swipe-only actions. The shell runs on a desktop with a pointer and a keyboard.

## 2. Motion

The HIG gives no exact durations. It asks for short motion that answers an action ([motion](https://developer.apple.com/design/human-interface-guidelines/motion)). The tokens in `Theme.motion` and `SizeMotion` already follow it.

- Animate only a change of state that the user caused or must see. Do not animate routine, frequent actions more than the control already does.
- Keep motion brief. A path that the user takes many times must take less than 500 ms.
- When a popover changes size, animate the size. Do not make it look as if a new popover replaced the old one ([popovers](https://developer.apple.com/design/human-interface-guidelines/popovers)). Use `SizeMotion`.
- Let a new action interrupt an animation. A `Behavior` restarts from the current value, so do not lock input during motion.
- Do not use motion as the only signal of a state. Show the state with text, an icon, or a fill too.
- For the Island: keep the position of each part when the Island expands. Make the parts larger. Do not move them to new places ([live-activities](https://developer.apple.com/design/human-interface-guidelines/live-activities)).

Reduce Motion: the HIG asks for cross-fades in place of moves and scales when the user turns on Reduce Motion ([accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility)). This shell has no such setting now. If you add one, put it in `SettingsService` and make `SizeMotion`, `ContentFade`, and `Theme.motion.nudge` read it.

## 3. Panels (popovers)

From [popovers](https://developer.apple.com/design/human-interface-guidelines/popovers):

- A panel holds a small amount of information or a few controls.
- Only one panel is open at a time. Do not open a panel from a panel. `Visibilities.current` enforces this.
- Nothing shows above a panel, except an alert (polkit).
- A panel closes when the user clicks outside it or chooses an item. Add a close button only when it removes doubt, for example to tell "cancel" from "save".
- A change made in a panel applies at once, or saves when the panel closes. Discard a change only on an explicit Cancel.
- The panel size follows its content.

## 4. Menus

From [menus](https://developer.apple.com/design/human-interface-guidelines/menus). Apps supply the tray menu entries. These rules apply to menus that this config writes.

- An item label is a verb or a verb phrase, in title case, with no article: "Copy Path", "Open Settings".
- Add `…` to an item that asks for more input before it acts.
- Show an item that is not available as dimmed. Do not hide it.
- Put frequent items first. Separate groups with a divider.
- Use one level of submenu at most, with about five items or fewer.
- For a toggle item, change the label ("Show Map" and "Hide Map") or use a checkmark.

## 5. Toasts and notifications

The shell is the notification server, so most HIG rules about notifications are for the apps that send them. These rules apply to the display:

- Show urgency as the sender set it. A critical notification stays until the user closes it. Other toasts close by themselves ([feedback](https://developer.apple.com/design/human-interface-guidelines/feedback)).
- Stack toasts in a queue. Do not let them overlap.
- Put an undo action in a toast that confirms a destructive action, for example a cleared group.
- An empty state says what will show there. Example: "No notifications" with "New notifications show here." Do not show a blank area.

## 6. Alerts (polkit)

From [alerts](https://developer.apple.com/design/human-interface-guidelines/alerts):

- The title states the situation in two lines or fewer. Do not use "Error" alone.
- Button labels are verbs that name the result: "Authenticate", "Try Again". The button that cancels is always "Cancel".
- Put the default button on the trailing side. Return activates it. Put Cancel on the leading side.
- When authentication fails, say what failed and what to do next. Do not blame the user.

## 7. Controls

From [toggles](https://developer.apple.com/design/human-interface-guidelines/toggles) and [sliders](https://developer.apple.com/design/human-interface-guidelines/sliders):

- A switch belongs in a list row (`ToggleRow`). Outside a row, use a button with an on and an off state.
- On and off differ by more than color: position and fill change too.
- A slider has its minimum on the left and its maximum on the right. Apply its value while the user drags it.
- Pointer targets are 28 by 28 px by default. The absolute minimum is 20 by 20 px ([accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility)).
- Show a hover state on every control that the user can click.

## 8. Feedback, loading, and errors

From [feedback](https://developer.apple.com/design/human-interface-guidelines/feedback) and [loading](https://developer.apple.com/design/human-interface-guidelines/loading):

- Match the surface to how important the event is. A passive state goes in a badge or a label. A recoverable error goes inline. Only a critical event that needs action gets an alert.
- Confirm a significant action (a screenshot saved). Do not confirm a routine action.
- When an action cannot complete, say so and say why. Do not fail silently.
- Show content at once. While a list refreshes, keep the old content and show a small indicator. Do not replace content with a spinner.
- Describe the work, not the wait: "Scanning for devices…", not "Loading…".

## 9. Color, materials, and hierarchy

- Use semantic tokens, never a raw color. `Theme.qml` has these tokens. Matugen sets the colors, the way macOS follows the user's accent color.
- Use the accent color for selection and active state only. When every item has the accent, no item stands out ([materials](https://developer.apple.com/design/human-interface-guidelines/materials)).
- Do not use a translucent fill on a colored control. The color shifts with the wallpaper.
- Text contrast is at least 4.5:1 for text up to 17 px, and 3:1 for larger or bold text ([accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility)). Check `Theme.text.tertiary` on `Theme.colors.surface` when you change the palette.
- Show a state with color and with an icon or a label.

## 10. Writing

From the `frontend-design` skill, with the HIG rules for macOS ([designing-for-macos](https://developer.apple.com/design/human-interface-guidelines/designing-for-macos)):

- Name things the way the user knows them. The user manages "Bluetooth devices", not "BlueZ adapters".
- An action keeps one name through the flow. A "Clear" button makes a toast that says "Cleared".
- Use sentence case for titles and buttons. Use title case for menu items.
- Use "click", never "tap".
- An error says what happened and how to fix it. It does not apologize.
- Do not use an exclamation mark, except for a real success that the user waited for.

## 11. Restraint

From the `frontend-design` skill:

- Make one element the memorable thing on a surface. Keep the rest quiet.
- Before you finish, remove one thing: a line, a label, a fill, or an animation.
- These are signs of generic AI design. Do not use them unless the content needs them: an all-caps label above each heading, metadata joined with middle dots (`A · B · C`), identical rounded cards with the same shadow, and a `→` after link and button text.
- `SectionLabel` is not one of these signs. It names a group of rows ("OUTPUT", "PAIRED"), like a section header in a macOS sidebar. Use it for a group of rows only, never above a panel title.

Do not use the rest of the `frontend-design` skill here. It asks for a bold, new visual identity for each project. This shell has a fixed visual identity in `Theme.qml`.
