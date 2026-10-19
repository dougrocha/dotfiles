# Design guidelines: style

Rules for color, writing, and restraint, from the HIG and the `frontend-design` skill in `claude-plugins-official`. The rules in `SKILL.md` and `qslint` come first. For surface rules, read `design-surfaces.md`.

## 1. Color, materials, and hierarchy

- Use semantic tokens, never a raw color. `Theme.qml` has these tokens. Matugen sets the colors, the way macOS follows the user's accent color.
- Use the accent color for selection and active state only. When every item has the accent, no item stands out ([materials](https://developer.apple.com/design/human-interface-guidelines/materials)).
- Do not use a translucent fill on a colored control. The color shifts with the wallpaper.
- Text contrast is at least 4.5:1 for text up to 17 px, and 3:1 for larger or bold text ([accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility)). Check `Theme.text.tertiary` on `Theme.colors.surface` when you change the palette.
- Show a state with color and with an icon or a label.

## 2. Writing

From the `frontend-design` skill, with the HIG rules for macOS ([designing-for-macos](https://developer.apple.com/design/human-interface-guidelines/designing-for-macos)):

- Name things the way the user knows them. The user manages "Bluetooth devices", not "BlueZ adapters".
- An action keeps one name through the flow. A "Clear" button makes a toast that says "Cleared".
- Use sentence case for titles and buttons. Use title case for menu items.
- Use "click", never "tap".
- An error says what happened and how to fix it. It does not apologize.
- Do not use an exclamation mark, except for a real success that the user waited for.

## 3. Restraint

From the `frontend-design` skill:

- Make one element the memorable thing on a surface. Keep the rest quiet.
- Before you finish, remove one thing: a line, a label, a fill, or an animation.
- These are signs of generic AI design. Do not use them unless the content needs them: an all-caps label above each heading, metadata joined with middle dots (`A · B · C`), identical rounded cards with the same shadow, and a `→` after link and button text.
- `SectionLabel` is not one of these signs. It names a group of rows ("OUTPUT", "PAIRED"), like a section header in a macOS sidebar. Use it for a group of rows only, never above a panel title.

Do not use the rest of the `frontend-design` skill here. It asks for a bold, new visual identity for each project. This shell has a fixed visual identity in `Theme.qml`.
