import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.Constants
import qs.Components
import qs.Modules.Bar.Components
import qs.Services
import qs.Widgets

PanelWindow {
    property var modelData

    screen: modelData
    implicitHeight: Theme.panelHeight
    color: Colors.surface

    anchors {
        top: true
        left: true
        right: true
    }

    Rectangle {
        anchors.fill: parent
        color: Colors.surface

        RowLayout {
            anchors.fill: parent
            spacing: 0

            WorkspaceIndicator {}

            // Spacer
            Item {
                Layout.fillWidth: true
            }

            // System Tray
            TraySection {}

            // Media Section
            MediaSection {
                colYellow: Colors.secondary
                colMuted: Colors.outline
                fontSize: Fonts.p
                fontFamily: Fonts.font
            }

            // Screen Share Status
            ScreenShare {}

            Rectangle {
                Layout.preferredWidth: ScreenShare.visible ?? false ? 1 : 0
                Layout.preferredHeight: 16
                Layout.alignment: Qt.AlignVCenter
                Layout.rightMargin: ScreenShare.visible ?? false ? 8 : 0
                color: Colors.on_surface_variant
                visible: ScreenShare.visible ?? false
            }

            // CPU Usage
            CpuSection {}

            // Separator
            Rectangle {
                Layout.preferredWidth: 1
                Layout.preferredHeight: 16
                Layout.alignment: Qt.AlignVCenter
                Layout.rightMargin: 8
                color: Colors.on_surface_variant
            }

            // Volume Section
            VolumeSection {
                textColor: Colors.primary
                separatorColor: Colors.outline
                fontSize: Fonts.p
                fontFamily: Fonts.font
            }

            // Clock Widget
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

            Item {
                width: 8
            }
        }
    }
}
