pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.Components
import qs.Constants
import qs.Modules.Bar.Components
import qs.Modules.Popups
import qs.Services
import qs.Widgets

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

        Item {
            id: content
            width: parent.width
            height: parent.height
            y: topBar.revealed ? 0 : -height

            TapHandler {
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                onTapped: eventPoint => {
                    if (!traySection.contains(traySection.mapFromItem(content, eventPoint.position)))
                        Visibilities.closeTrayMenu();
                }
            }

            Behavior on y {
                NumberAnimation {
                    duration: Theme.motion.normal
                    easing.type: Theme.motion.easeStandard
                }
            }

            Rectangle {
                id: tint
                anchors.fill: parent

                function tintAt(alpha) {
                    return Theme.withAlpha(Theme.colors.bg, topBar.autoHide ? 1 : alpha);
                }

                gradient: Gradient {
                    GradientStop {
                        position: 0
                        color: tint.tintAt(Theme.bar.tintTop)
                    }
                    GradientStop {
                        position: 0.55
                        color: tint.tintAt(Theme.bar.tintMid)
                    }
                    GradientStop {
                        position: 1
                        color: tint.tintAt(0)
                    }
                }
            }

            Workspaces {
                screen: topBar.modelData
                anchors.left: parent.left
                anchors.leftMargin: Theme.bar.edgeMargin
                anchors.verticalCenter: parent.verticalCenter
            }

            RowLayout {
                id: indicatorRow
                anchors.right: parent.right
                anchors.rightMargin: Theme.bar.edgeMargin
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.space.xxs

                TraySection {
                    id: traySection
                }

                CpuIndicator {}

                BluetoothIndicator {
                    id: bluetoothIndicator
                }

                VolumeIndicator {
                    id: volumeIndicator
                }

                SettingsButton {
                    id: settingsButton
                }

                DoNotDisturbIndicator {}

                ClockButton {
                    id: clockButton
                }
            }
        }

        LazyLoader {
            active: topBar.primary

            SettingsPopup {
                anchor.window: topBar
                trigger: settingsButton
            }
        }

        LazyLoader {
            active: topBar.primary

            SoundPopup {
                anchor.window: topBar
                trigger: volumeIndicator
            }
        }

        LazyLoader {
            active: topBar.primary

            BluetoothPopup {
                anchor.window: topBar
                trigger: bluetoothIndicator
            }
        }

        LazyLoader {
            active: topBar.primary

            NotificationPopup {
                anchor.window: topBar
                trigger: clockButton
            }
        }
    }
}
