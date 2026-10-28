# QML patterns

Copy these patterns. Each one comes from a real file in the config root.

## Add a bar panel

`Popup` registers the panel name as its IPC target. `Modules/Popups/SoundPopup.qml`:

```qml
Popup {
    id: panel

    panelName: "sound-panel"

    PanelHeader {
        title: "Sound"
    }

    PanelGroup {
        label: "Output"

        DeviceRow {
            glyph: PhosphorIcons.speakerHigh
            label: "Speakers"
            selected: true
        }
    }

    PanelFooterLink {
        label: "Sound Settings…"
        command: ["launch-or-focus-tui", "wiremix"]
    }
}
```

Put groups directly in the `Popup`. Its column puts `Theme.space.xl` between them.

`Modules/Bar/Bar.qml`:

```qml
LazyLoader {
    active: modelData === Theme.primaryScreen

    SoundPopup {
        anchor.window: topBar
        trigger: volumeIndicator
    }
}
```

`trigger` is the bar control, with an `id` in `Bar.qml`. The panel grows from it. The bar control, from `Modules/Bar/Components/VolumeIndicator.qml`:

```qml
active: AudioService.muted || Visibilities.isOpen("sound-panel")
onTapped: Visibilities.toggle("sound-panel")
```

## Show a secondary control on hover

From `Modules/Notifications/NotificationHistory.qml`:

```qml
IconActionButton {
    glyph: PhosphorIcons.x
    opacity: groupHover.hovered ? 1 : 0
    enabled: opacity > 0
    onTapped: NotificationService.clearAppHistory(group.modelData.app)

    Behavior on opacity {
        NumberAnimation {
            duration: Theme.motion.fast
        }
    }
}
```

## Let a row hover fill extend past the content edge

Build a panel row on `PanelRow`. It draws the hover fill `Theme.panel.rowBleed` past both content edges, and handles hover, tap, Return, and Space. Put the row content in it as children:

```qml
PanelRow {
    onTapped: panel.close()

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: "Label"
    }
}
```

`DeviceRow`, `PopupActionButton`, and `PanelFooterLink` are built on it. `ToggleRow` and `Divider` still take `bleed: Theme.panel.rowBleed`.

## Put a badge on a rounded corner

From `Modules/Notifications/NotificationCard.qml`:

```qml
CloseBadge {
    readonly property real cornerInset: surface.radius * (1 - Math.SQRT1_2)

    x: Math.round(cornerInset - width / 2)
    y: Math.round(cornerInset - height / 2)
    revealed: cardHover.hovered
}
```

## Animate a size change and fade in new content

From `Components/Popup.qml` and `Modules/Popups/CalendarView.qml`:

```qml
SizeMotion on height {}

ContentFade on opacity {}

transform: Translate {
    y: (1 - details.opacity) * -Theme.motion.nudge
}
```

## Show and hide a surface

From `Modules/Dictation/DictationPill.qml`. `Presence` owns the enter and exit motion: 200 ms in, 140 ms out, both on `Theme.motion.curveOut`, and a reversal starts from the current value. The window stays mapped until the exit ends.

```qml
Presence {
    id: presence

    active: DictationService.active
}

visible: presence.mapped

Rectangle {
    opacity: presence.progress
    scale: presence.scale
}
```

Set the origin to the trigger side for a popover (`Popup` does it from `trigger`) and keep the centre for an alert. Gate a `SizeMotion` on the same surface with `enabled: presence.progress === 1`, or content that lays out at open time animates as a slide.
