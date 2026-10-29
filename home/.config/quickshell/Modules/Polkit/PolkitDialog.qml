pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import qs.Components
import qs.Constants
import qs.Services

Scope {
    id: root

    readonly property color scrim: Theme.withAlpha(Theme.shadow, 0.5)
    property var hostScreen: Theme.primaryScreen

    readonly property var dimScreens: presence.mapped ? Quickshell.screens.filter(s => s !== hostScreen) : []

    Presence {
        id: presence

        active: PolkitService.active
    }

    Connections {
        target: PolkitService

        function onRequestStarted() {
            if (!presence.mapped)
                root.hostScreen = Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? Theme.primaryScreen;
            Visibilities.dismissAll();
        }
    }

    Variants {
        model: root.dimScreens

        delegate: PanelWindow {
            required property var modelData

            screen: modelData
            visible: presence.mapped
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.namespace: "qs.polkit.dim"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            Rectangle {
                anchors.fill: parent
                color: root.scrim
                opacity: presence.progress
            }

            TapHandler {
                onTapped: card.focusField()
            }
        }
    }

    PanelWindow {
        screen: root.hostScreen
        visible: presence.mapped
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.namespace: "qs.polkit"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        Rectangle {
            anchors.fill: parent
            color: root.scrim
            opacity: presence.progress
        }

        TapHandler {
            onTapped: card.focusField()
        }

        PolkitCard {
            id: card

            anchors.centerIn: parent
            opacity: presence.progress
            scale: presence.scale
        }
    }
}
