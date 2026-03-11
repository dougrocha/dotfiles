import ".."
import "../Components"
import "../Services"
import "../Widgets"
import "Popups"
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

PanelWindow {
    property var modelData

    screen: modelData
    implicitHeight: Theme.panelHeight
    color: Theme.bg

    anchors {
        top: true
        left: true
        right: true
    }

    margins {
        top: Theme.panelMargin
        bottom: Theme.panelMargin
        left: Theme.panelMargin
        right: Theme.panelMargin
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.bg

        RowLayout {
            anchors.fill: parent
            spacing: 0

            Item {
                width: 8
            }

            // Avatar
            Rectangle {
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
                color: "transparent"

                Image {
                    anchors.fill: parent
                    source: "file:///home/doug/.config/user-img.jpg"
                    fillMode: Image.PreserveAspectFit
                }
            }

            Item {
                width: 8
            }

            // Workspaces
            Repeater {
                model: 9

                Rectangle {
                    property var workspace: {
                        var ws = Hyprland.workspaces.values.find(function (w) {
                            return w.id === index + 1;
                        });
                        return ws !== undefined ? ws : null;
                    }
                    property bool isActive: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id === (index + 1) : false
                    property bool hasWindows: workspace !== null

                    Layout.preferredWidth: 20
                    Layout.preferredHeight: parent.height
                    color: "transparent"

                    Text {
                        text: index + 1
                        color: parent.isActive ? Theme.cyan : (parent.hasWindows ? Theme.cyan : Theme.muted)
                        font.pixelSize: Theme.fontSize
                        font.family: Theme.fontFamily
                        font.bold: true
                        anchors.centerIn: parent
                    }

                    Rectangle {
                        width: 20
                        height: 3
                        color: parent.isActive ? Theme.purple : Theme.bg
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: Hyprland.dispatch("workspace " + (index + 1))
                    }
                }
            }

            // Spacer
            Item {
                Layout.fillWidth: true
            }

            // System Tray
            TraySection {}

            // Media Section
            MediaSection {
                colYellow: Theme.yellow
                colMuted: Theme.muted
                fontSize: Theme.fontSize
                fontFamily: Theme.fontFamily
            }

            // Streaming Status
            Streaming {}

            Rectangle {
                Layout.preferredWidth: StreamingService.isStreaming ? 1 : 0
                Layout.preferredHeight: 16
                Layout.alignment: Qt.AlignVCenter
                Layout.rightMargin: StreamingService.isStreaming ? 8 : 0
                color: Theme.muted
                visible: StreamingService.isStreaming
            }

            // CPU Usage
            CpuSection {}

            // Separator
            Rectangle {
                Layout.preferredWidth: 1
                Layout.preferredHeight: 16
                Layout.alignment: Qt.AlignVCenter
                Layout.rightMargin: 8
                color: Theme.muted
            }

            // Volume Section
            VolumeSection {
                textColor: Theme.purple
                separatorColor: Theme.muted
                fontSize: Theme.fontSize
                fontFamily: Theme.fontFamily
            }

            // Clock Widget
            ClockWidget {
                color: Theme.cyan
                font.pixelSize: Theme.fontSize
                font.family: Theme.fontFamily
                font.bold: true
                Layout.rightMargin: 8
            }

            // Settings Button
            SettingsPopupWindow {
                iconColor: Theme.cyan
                iconSize: Theme.fontSize
                fontFamily: Theme.fontFamily
                Layout.rightMargin: 8
            }

            Item {
                width: 8
            }
        }
    }
}
