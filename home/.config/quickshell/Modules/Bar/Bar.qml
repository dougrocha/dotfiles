pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Components
import qs.Constants
import qs.Modules.Popups
import qs.Services

Variants {
    id: root
    model: Quickshell.screens

    delegate: PanelWindow {
        id: topBar

        required property var modelData
        screen: modelData

        readonly property string fullscreenKind: Desktop.fullscreenKind(modelData)
        readonly property bool autoHide: fullscreenKind !== "none"
        readonly property bool primary: modelData === Desktop.primaryScreen
        readonly property bool revealed: BarService.revealedOn(modelData)

        WlrLayershell.layer: fullscreenKind === "exclusive" ? WlrLayer.Overlay : WlrLayer.Top
        WlrLayershell.namespace: "qs.topbar"
        exclusionMode: autoHide ? ExclusionMode.Ignore : ExclusionMode.Auto

        implicitHeight: autoHide ? Theme.topBarCompactHeight : Theme.topBarHeight
        color: "transparent"

        mask: Region {
            width: topBar.width
            height: topBar.revealed ? topBar.height : 2
        }

        anchors {
            top: true
            left: true
            right: true
        }

        Item {
            anchors.fill: parent

            HoverHandler {
                onHoveredChanged: BarService.setHovered(topBar.modelData, hovered)
            }
        }

        BarContent {
            id: content
            width: parent.width
            height: parent.height
            y: topBar.revealed ? 0 : -height
            screen: topBar.modelData
            autoHide: topBar.autoHide

            Behavior on y {
                NumberAnimation {
                    duration: Theme.motion.normal
                    easing.type: Theme.motion.easeStandard
                }
            }
        }

        LazyLoader {
            active: topBar.primary

            SettingsPopup {
                anchor.window: topBar
                trigger: content.settingsButton
            }
        }

        LazyLoader {
            active: topBar.primary

            SoundPopup {
                anchor.window: topBar
                trigger: content.volumeIndicator
            }
        }

        LazyLoader {
            active: topBar.primary

            BluetoothPopup {
                anchor.window: topBar
                trigger: content.bluetoothIndicator
            }
        }

        LazyLoader {
            active: topBar.primary

            NotificationPopup {
                anchor.window: topBar
                trigger: content.clockButton
            }
        }
    }
}
