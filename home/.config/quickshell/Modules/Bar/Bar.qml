import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import qs.Constants
import qs.Components
import qs.Modules.Bar.Components
import qs.Modules.Popups
import qs.Services
import qs.Widgets

Variants {
    id: root
    model: Quickshell.screens

    component Separator: Rectangle {
        Layout.preferredWidth: 1
        Layout.preferredHeight: 12
        Layout.alignment: Qt.AlignVCenter
        color: Qt.rgba(Colors.on_surface_variant.r, Colors.on_surface_variant.g, Colors.on_surface_variant.b, 0.25)
    }

    delegate: PanelWindow {
        id: topBar

        required property var modelData
        screen: modelData

        readonly property int hyprlandFullscreenModeExclusive: 2

        readonly property var workspace: Hyprland.monitorFor(modelData)?.activeWorkspace
        readonly property bool hasFullscreen: workspace?.hasFullscreen ?? false
        readonly property var activeToplevel: Hyprland.activeToplevel
        readonly property int fullscreenMode: (hasFullscreen && activeToplevel?.workspace === workspace) ? (activeToplevel.lastIpcObject?.fullscreen ?? 0) : 0
        readonly property bool fullscreenOnScreen: fullscreenMode === hyprlandFullscreenModeExclusive
        readonly property bool popupOpen: Visibilities.musicPanel || Visibilities.settingsPanel || Visibilities.soundPanel || Visibilities.bluetoothPanel || Visibilities.notificationCenter
        readonly property bool wantRevealed: !fullscreenOnScreen || barHover.hovered || popupOpen || Visibilities.barPinned
        property bool revealed: true

        // The island overlay is a separate window; it follows this.
        onRevealedChanged: {
            if (modelData === Theme.primaryScreen)
                Visibilities.barRevealed = revealed;
        }

        onFullscreenOnScreenChanged: {
            if (fullscreenOnScreen && !wantRevealed) {
                hideTimer.stop();
                revealed = false;
            }
        }

        Component.onCompleted: Hyprland.refreshToplevels()
        onHasFullscreenChanged: {
            if (hasFullscreen)
                Hyprland.refreshToplevels();
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

        // When hidden, only a 2px strip at the top edge accepts input so
        // clicks pass through to the fullscreen window below.
        mask: Region {
            width: topBar.width
            height: topBar.revealed ? topBar.height : 2
        }

        anchors {
            top: true
            left: true
            right: true
        }

        // Stationary, so it still catches hover on the strip while the
        // content is slid out of view.
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
                    const point = traySection.mapFromItem(content, eventPoint.position.x, eventPoint.position.y);
                    if (point.x < 0 || point.x > traySection.width || point.y < 0 || point.y > traySection.height)
                        Visibilities.closeTrayMenus();
                }
            }

            Behavior on y {
                NumberAnimation {
                    duration: 180
                    easing.type: Easing.OutCubic
                }
            }

            Rectangle {
                anchors.left: parent.left
                anchors.leftMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                width: workspaceModule.implicitWidth + 28
                height: Theme.topBarHeight - 8
                radius: height / 2
                color: Colors.surface

                Workspaces {
                    id: workspaceModule
                    targetMonitor: modelData.name
                    anchors.centerIn: parent
                }
            }

            // Center pill is the island — its own overlay window, see Modules/Island/Island.qml.

            Rectangle {
                id: indicatorPill

                readonly property int leftPadding: traySection.visible ? 3 : 14
                readonly property int rightPadding: 14

                anchors.right: parent.right
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                width: indicatorRow.implicitWidth + leftPadding + rightPadding
                height: Theme.topBarHeight - 8
                radius: height / 2
                color: Colors.surface

                RowLayout {
                    id: indicatorRow
                    anchors.right: parent.right
                    anchors.rightMargin: indicatorPill.rightPadding
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 14

                    TraySection {
                        id: traySection
                    }

                    CpuIndicator {}

                    BluetoothIndicator {}

                    VolumeIndicator {}

                    SettingsButton {}

                    NotificationBellButton {}
                }
            }
        }

        LazyLoader {
            active: modelData === Theme.primaryScreen

            SettingsPopup {
                anchor.window: topBar
                anchor.rect.x: topBar.width - implicitWidth - 8
                anchor.rect.y: topBar.height + Theme.popup.gap
            }
        }

        LazyLoader {
            active: modelData === Theme.primaryScreen

            SoundPopup {
                anchor.window: topBar
                anchor.rect.x: topBar.width - implicitWidth - 8
                anchor.rect.y: topBar.height + Theme.popup.gap
            }
        }

        LazyLoader {
            active: modelData === Theme.primaryScreen

            BluetoothPopup {
                anchor.window: topBar
                anchor.rect.x: topBar.width - implicitWidth - 8
                anchor.rect.y: topBar.height + Theme.popup.gap
            }
        }

        LazyLoader {
            active: modelData === Theme.primaryScreen

            NotificationPopup {
                anchor.window: topBar
                anchor.rect.x: topBar.width - implicitWidth - 8
                anchor.rect.y: topBar.height + Theme.popup.gap
            }
        }
    }
}
