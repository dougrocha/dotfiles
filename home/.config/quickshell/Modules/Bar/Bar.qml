import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import qs.Constants
import qs.Components
import qs.Modules.Bar.Components
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

        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.namespace: "qs.topbar"

        implicitHeight: Theme.topBarHeight
        color: Colors.surface

        anchors {
            top: true
            left: true
            right: true
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

        MediaSection {
            id: mediaSection
            anchors.centerIn: parent
            colYellow: Colors.secondary
            colMuted: Colors.outline
            fontSize: Fonts.p
            fontFamily: Fonts.font
            panelOpen: Visibilities.musicPanel
            onTogglePanel: Visibilities.musicPanel = !Visibilities.musicPanel
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
}
