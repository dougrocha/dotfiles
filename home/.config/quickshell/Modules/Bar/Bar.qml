pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
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

        readonly property var monitor: Hyprland.monitorFor(modelData)
        readonly property bool fullscreenOnScreen: Desktop.fullscreenOn(modelData)
        readonly property bool primary: modelData === Desktop.primaryScreen
        readonly property bool wantRevealed: BarService.wantsReveal(fullscreenOnScreen, barHover.hovered)
        property bool revealed: true

        onRevealedChanged: {
            if (primary)
                BarService.setRevealed(revealed);
        }

        onFullscreenOnScreenChanged: {
            if (fullscreenOnScreen && !wantRevealed) {
                hideTimer.stop();
                revealed = false;
            }
        }

        onWantRevealedChanged: {
            if (wantRevealed) {
                hideTimer.stop();
                revealed = true;
            } else {
                hideTimer.restart();
            }
        }

        Timer {
            id: hideTimer
            interval: 400
            onTriggered: topBar.revealed = false
        }

        WlrLayershell.layer: fullscreenOnScreen ? WlrLayer.Overlay : WlrLayer.Top
        WlrLayershell.namespace: "qs.topbar"
        exclusionMode: fullscreenOnScreen ? ExclusionMode.Ignore : ExclusionMode.Auto

        implicitHeight: Theme.topBarHeight
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
                id: barHover
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
                anchors.left: parent.left
                anchors.leftMargin: Theme.space.md
                anchors.verticalCenter: parent.verticalCenter
                width: workspaceModule.implicitWidth + Theme.space.md
                height: Theme.topBarHeight - 8
                radius: height / 2
                color: Theme.colors.surface
                clip: true

                SizeMotion on width {}

                Workspaces {
                    id: workspaceModule
                    monitor: topBar.monitor
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.space.md / 2
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Rectangle {
                id: indicatorPill

                readonly property int rightPadding: 14
                readonly property int leftPadding: traySection.visible ? rightPadding - 4 : rightPadding

                anchors.right: parent.right
                anchors.rightMargin: Theme.space.md
                anchors.verticalCenter: parent.verticalCenter
                width: indicatorRow.implicitWidth + leftPadding + rightPadding
                height: Theme.topBarHeight - 8
                radius: height / 2
                color: Theme.colors.surface

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
}
