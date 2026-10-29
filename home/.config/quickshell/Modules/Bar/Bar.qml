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
        readonly property bool ownsFullscreen: Desktop.fullscreenWindowOn(modelData)
        readonly property bool autoHide: fullscreenOnScreen || ownsFullscreen
        readonly property bool primary: modelData === Desktop.primaryScreen
        readonly property bool wantRevealed: BarService.wantsReveal(autoHide, barHover.hovered)
        property bool revealed: true

        function placeFullscreen() {
            Desktop.placeFullscreen(modelData, revealed);
        }

        onRevealedChanged: {
            if (primary)
                BarService.setRevealed(revealed);
            if (ownsFullscreen)
                placeFullscreen();
        }

        onAutoHideChanged: {
            if (autoHide && !BarService.wantsReveal(true, barHover.hovered)) {
                hideTimer.stop();
                revealed = false;
            }
        }

        onOwnsFullscreenChanged: {
            if (ownsFullscreen)
                placeFullscreen();
        }

        onWantRevealedChanged: {
            hideTimer.stop();
            revealTimer.stop();
            if (!wantRevealed)
                hideTimer.restart();
            else if (autoHide && !BarService.wantsReveal(true, false))
                revealTimer.restart();
            else
                revealed = true;
        }

        Timer {
            id: revealTimer
            interval: 250
            onTriggered: topBar.revealed = true
        }

        Timer {
            id: hideTimer
            interval: 1000
            onTriggered: topBar.revealed = false
        }

        WlrLayershell.layer: fullscreenOnScreen ? WlrLayer.Overlay : WlrLayer.Top
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
                    monitor: topBar.monitor
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
