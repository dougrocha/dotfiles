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
        Layout.preferredHeight: 16
        Layout.alignment: Qt.AlignVCenter
        color: Colors.on_surface_variant
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

        MusicPanel {
            id: musicPopout
            anchor.window: topBar
            anchor.rect.x: (topBar.width - 480) / 2
            anchor.rect.y: topBar.height + 8
        }

        MediaSection {
            id: mediaSection
            anchors.centerIn: parent
            colYellow: Colors.secondary
            colMuted: Colors.outline
            fontSize: Fonts.p
            fontFamily: Fonts.font
            panelOpen: musicPopout.visible
            onTogglePanel: musicPopout.visible = !musicPopout.visible
        }

        RowLayout {
            anchors.right: parent.right
            spacing: 8

            ScreenShare {}

            TraySection {}

            Separator {
                visible: ScreenShare.visible ?? false
            }

            CpuSection {}

            Separator {}

            VolumeSection {
                textColor: Colors.primary
                fontSize: Fonts.p
                fontFamily: Fonts.font
            }

            Separator {}

            ClockWidget {
                color: Colors.primary
                font.pixelSize: Fonts.p
                font.family: Fonts.font
                font.bold: true
                Layout.rightMargin: 8
            }

            SettingsButton {
                Layout.rightMargin: 8
            }
        }
    }
}
