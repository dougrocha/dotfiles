# QML patterns

Copy these patterns. Each one comes from a real file in the config root.

## Add a bar panel

The panel name is also its IPC target. `Services/Visibilities.qml`:

```qml
PanelIpc {
    target: "sound-panel"
}
```

`Modules/Popups/SoundPopup.qml`:

```qml
Popup {
    id: panel

    panelName: "sound-panel"
}
```

`Modules/Bar/Bar.qml`:

```qml
LazyLoader {
    active: modelData === Theme.primaryScreen

    SoundPopup {
        anchor.window: topBar
    }
}
```

The bar control, from `Modules/Bar/Components/VolumeIndicator.qml`:

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

Pass `panel.rowBleed` from a `Popup` to `ListRow`, `ToggleRow`, `Divider`, or `PopupActionButton`:

```qml
ListRow {
    bleed: panel.rowBleed
}
```

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

From `Components/PopupCard.qml` and `Modules/Popups/CalendarView.qml`:

```qml
SizeMotion on height {}

ContentFade on opacity {}

transform: Translate {
    y: (1 - details.opacity) * -Theme.motion.nudge
}
```
