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
                anchors.fill: parent
                color: Theme.colors.bg
                opacity: topBar.autoHide ? 1 : 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.motion.fast
                    }
                }

                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: 1
                    color: Theme.stroke.hairline
                }
            }

            BarPill {
                faded: topBar.autoHide
                anchors.left: parent.left
                anchors.leftMargin: Theme.space.md
                anchors.verticalCenter: parent.verticalCenter
                width: workspaceModule.implicitWidth + Theme.space.md
                clip: true

                SizeMotion on width {}

                Workspaces {
                    id: workspaceModule
                    screen: topBar.modelData
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.space.md / 2
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            BarPill {
                id: indicatorPill

                faded: topBar.autoHide

                readonly property int rightPadding: 14
                readonly property int leftPadding: traySection.visible ? rightPadding - 4 : rightPadding

                anchors.right: parent.right
                anchors.rightMargin: Theme.space.md
                anchors.verticalCenter: parent.verticalCenter
                width: indicatorRow.implicitWidth + leftPadding + rightPadding
                RowLayout {
                    id: indicatorRow
                    anchors.right: parent.right
                    anchors.rightMargin: indicatorPill.rightPadding
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Theme.space.lg

                    TraySection {
                        id: traySection
                        Layout.rightMargin: Theme.space.md - indicatorRow.spacing
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

    component BarPill: Rectangle {
        property bool faded: false

        height: Theme.topBarHeight - 8
        radius: height / 2
        color: faded ? Theme.withAlpha(Theme.colors.surface, 0) : Theme.colors.surface

        Behavior on color {
            ColorAnimation {
                duration: Theme.motion.fast
            }
        }
    }
}
