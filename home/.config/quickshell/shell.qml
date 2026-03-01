import "./Components"
import "./Services"
import "./Widgets"
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    id: root

    // Theme colors
    property color colBg: "#1a1b26"
    property color colFg: "#a9b1d6"
    property color colMuted: "#444b6a"
    property color colCyan: "#0db9d7"
    property color colPurple: "#ad8ee6"
    property color colRed: "#f7768e"
    property color colYellow: "#e0af68"
    property color colBlue: "#7aa2f7"
    // Font
    property string fontFamily: "JetBrainsMono Nerd Font Propo"
    property int fontSize: 14
    // System info properties
    property string activeWindow: "Window"
    property string currentLayout: "Tile"

    // Active window title
    Process {
        id: windowProc

        command: ["sh", "-c", "hyprctl activewindow -j | jq -r '.title // empty'"]
        Component.onCompleted: running = true

        stdout: SplitParser {
            onRead: (data) => {
                if (data && data.trim())
                    activeWindow = data.trim();

            }
        }

    }

    // Current layout (Hyprland: dwindle/master/floating)
    Process {
        id: layoutProc

        command: ["sh", "-c", "hyprctl activewindow -j | jq -r 'if .floating then \"Floating\" elif .fullscreen == 1 then \"Fullscreen\" else \"Tiled\" end'"]
        Component.onCompleted: running = true

        stdout: SplitParser {
            onRead: (data) => {
                if (data && data.trim())
                    currentLayout = data.trim();

            }
        }

    }

    // Event-based updates for window/layout (instant)
    Connections {
        function onRawEvent(event) {
            windowProc.running = true;
            layoutProc.running = true;
        }

        target: Hyprland
    }

    // Backup timer for window/layout (catches edge cases)
    Timer {
        interval: 200
        running: true
        repeat: true
        onTriggered: {
            windowProc.running = true;
            layoutProc.running = true;
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            property var modelData

            screen: modelData
            implicitHeight: 30
            color: root.colBg

            anchors {
                top: true
                left: true
                right: true
            }

            margins {
                top: 0
                bottom: 0
                left: 0
                right: 0
            }

            Rectangle {
                anchors.fill: parent
                color: root.colBg

                RowLayout {
                    anchors.fill: parent
                    spacing: 0

                    Item {
                        width: 8
                    }

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

                    Repeater {
                        model: 9

                        Rectangle {
                            property var workspace: {
                                var ws = Hyprland.workspaces.values.find(function(w) {
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
                                color: parent.isActive ? root.colCyan : (parent.hasWindows ? root.colCyan : root.colMuted)
                                font.pixelSize: root.fontSize
                                font.family: root.fontFamily
                                font.bold: true
                                anchors.centerIn: parent
                            }

                            Rectangle {
                                width: 20
                                height: 3
                                color: parent.isActive ? root.colPurple : root.colBg
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.bottom: parent.bottom
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: Hyprland.dispatch("workspace " + (index + 1))
                            }

                        }

                    }

                    Rectangle {
                        Layout.preferredWidth: 1
                        Layout.preferredHeight: 16
                        Layout.alignment: Qt.AlignVCenter
                        Layout.leftMargin: 8
                        Layout.rightMargin: 8
                        color: root.colMuted
                    }

                    Text {
                        text: currentLayout
                        color: root.colFg
                        font.pixelSize: root.fontSize
                        font.family: root.fontFamily
                        font.bold: true
                        Layout.leftMargin: 5
                        Layout.rightMargin: 5
                    }

                    Rectangle {
                        Layout.preferredWidth: 1
                        Layout.preferredHeight: 16
                        Layout.alignment: Qt.AlignVCenter
                        Layout.leftMargin: 2
                        Layout.rightMargin: 8
                        color: root.colMuted
                    }

                    Text {
                        text: activeWindow
                        color: root.colPurple
                        font.pixelSize: root.fontSize
                        font.family: root.fontFamily
                        font.bold: true
                        Layout.leftMargin: 8
                        elide: Text.ElideRight
                        maximumLineCount: 1
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    MediaSection {
                        colYellow: root.colYellow
                        colMuted: root.colMuted
                        fontSize: root.fontSize
                        fontFamily: root.fontFamily
                    }

                    Streaming {
                    }

                    Rectangle {
                        Layout.preferredWidth: StreamingService.isStreaming ? 1 : 0
                        Layout.preferredHeight: 16
                        Layout.alignment: Qt.AlignVCenter
                        Layout.leftMargin: 0
                        Layout.rightMargin: StreamingService.isStreaming ? 8 : 0
                        color: root.colMuted
                        visible: StreamingService.isStreaming
                    }

                    Text {
                        text: "CPU: " + CpuService.usage + "%"
                        color: root.colYellow
                        font.pixelSize: root.fontSize
                        font.family: root.fontFamily
                        font.bold: true
                        Layout.rightMargin: 8
                    }

                    Rectangle {
                        Layout.preferredWidth: 1
                        Layout.preferredHeight: 16
                        Layout.alignment: Qt.AlignVCenter
                        Layout.leftMargin: 0
                        Layout.rightMargin: 8
                        color: root.colMuted
                    }

                    VolumeSection {
                        textColor: root.colPurple
                        separatorColor: root.colMuted
                        fontSize: root.fontSize
                        fontFamily: root.fontFamily
                    }

                    ClockWidget {
                        color: root.colCyan
                        font.pixelSize: root.fontSize
                        font.family: root.fontFamily
                        font.bold: true
                        Layout.rightMargin: 8
                    }

                    SettingsPopupWindow {
                        iconColor: root.colCyan
                        iconSize: root.fontSize
                        fontFamily: root.fontFamily
                        Layout.rightMargin: 8
                    }

                    Item {
                        width: 8
                    }

                }

            }

        }

    }

}
