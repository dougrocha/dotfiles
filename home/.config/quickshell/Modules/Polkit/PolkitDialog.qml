pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import qs.Constants
import qs.Services

Scope {
    id: root

    readonly property color scrim: Theme.withAlpha(Theme.shadow, 0.5)
    property var hostScreen: Theme.primaryScreen

    property real presence: PolkitService.active ? 1 : 0
    Behavior on presence {
        NumberAnimation {
            duration: PolkitService.active ? Theme.motion.normal : Theme.motion.fast
            easing.type: PolkitService.active ? Theme.motion.easeStandard : Theme.motion.easeExit
        }
    }

    readonly property bool mapped: PolkitService.active || presence > 0
    readonly property var dimScreens: mapped ? Quickshell.screens.filter(s => s !== hostScreen) : []

    Connections {
        target: PolkitService

        function onRequestStarted() {
            if (!root.mapped)
                root.hostScreen = Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? Theme.primaryScreen;
            Visibilities.closeAll();
        }
    }

    Variants {
        model: root.dimScreens

        delegate: PanelWindow {
            required property var modelData

            screen: modelData
            visible: root.mapped
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
                opacity: root.presence
            }

            TapHandler {
                onTapped: card.focusField()
            }
        }
    }

    PanelWindow {
        screen: root.hostScreen
        visible: root.mapped
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
            opacity: root.presence
        }

        TapHandler {
            onTapped: card.focusField()
        }

        PolkitCard {
            id: card

            anchors.centerIn: parent
            opacity: root.presence
            scale: Theme.motion.scaleFrom + (1 - Theme.motion.scaleFrom) * root.presence
        }
    }
}
