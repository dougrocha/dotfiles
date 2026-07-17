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
        readonly property bool popupOpen: Visibilities.musicPanel || Visibilities.settingsPanel || Visibilities.notificationCenter
        readonly property bool wantRevealed: !fullscreenOnScreen || barHover.hovered || popupOpen || Visibilities.barPinned
        property bool revealed: true

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

            Behavior on y {
                NumberAnimation {
                    duration: 180
                    easing.type: Easing.OutCubic
                }
            }

            Rectangle {
                anchors.fill: parent
                color: Colors.surface
            }

            Workspaces {
                id: workspaceModule
                targetMonitor: modelData.name

                anchors {
                    left: parent.left
                    leftMargin: 15
                    verticalCenter: parent.verticalCenter
                }
            }

            MediaSection {
                id: mediaSection
                anchors.centerIn: parent
                colYellow: Colors.secondary
                colMuted: Colors.outline
                fontSize: Fonts.p
                fontFamily: Fonts.font
                panelOpen: Visibilities.musicPanel
                onTogglePanel: Visibilities.toggleMusicPanel()
            }

            RowLayout {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.rightMargin: 16
                spacing: 14

                ScreenShare {}

                TraySection {}

                CpuIndicator {}

                BluetoothIndicator {}

                VolumeIndicator {}

                SettingsButton {}

                ClockButton {}
            }
        }

        LazyLoader {
            active: modelData.name === Theme.primaryMonitor

            MusicPanel {
                anchor.window: topBar
                anchor.rect.x: (topBar.width - 480) / 2
                anchor.rect.y: topBar.height + 8
                visible: Visibilities.musicPanel
                onVisibleChanged: Visibilities.musicPanel = visible
            }
        }

        LazyLoader {
            active: modelData.name === Theme.primaryMonitor

            SettingsPopup {
                anchor.window: topBar
                anchor.rect.x: topBar.width - implicitWidth - 8
                anchor.rect.y: topBar.height + 6
            }
        }

        LazyLoader {
            active: modelData.name === Theme.primaryMonitor

            CalendarPopup {
                anchor.window: topBar
                anchor.rect.x: topBar.width - implicitWidth - 8
                anchor.rect.y: topBar.height + 6
            }
        }
    }
}
