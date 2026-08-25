import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.Constants
import qs.Services

Item {
    id: root

    property string targetMonitor: ""

    implicitWidth: mainLayout.implicitWidth
    implicitHeight: Theme.topBarHeight

    readonly property var focusedWs: Hyprland.focusedWorkspace
    readonly property bool onNamedWs: focusedWs && !/^\d+$/.test(focusedWs.name) && !focusedWs.name.startsWith("special:")

    RowLayout {
        id: mainLayout
        anchors.centerIn: parent
        spacing: 0

        Row {
            spacing: 5
            Layout.alignment: Qt.AlignVCenter

            Repeater {
                model: Hyprland.workspaces

                delegate: Item {
                    required property var modelData

                    readonly property bool isActive: modelData.focused && !root.onNamedWs
                    readonly property bool hasWindows: (modelData.lastIpcObject?.windows ?? 0) > 0

                    visible: modelData.id >= 0 && /^\d+$/.test(modelData.name) && modelData.monitor?.name === root.targetMonitor
                    width: visible ? 10 : 0
                    height: 10

                    Behavior on width {
                        NumberAnimation {
                            duration: 120
                            easing.type: Easing.OutCubic
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: 5
                        color: isActive ? Colors.primary : Qt.rgba(Colors.primary.r, Colors.primary.g, Colors.primary.b, hasWindows ? 0.15 : 0.0)
                        border.color: isActive ? Qt.rgba(Colors.primary.r, Colors.primary.g, Colors.primary.b, 0) : Colors.primary
                        border.width: 1.5
                        opacity: isActive || hasWindows ? 1.0 : 0.35

                        Behavior on color {
                            ColorAnimation {
                                duration: 100
                            }
                        }
                        Behavior on opacity {
                            NumberAnimation {
                                duration: 100
                                easing.type: Easing.OutCubic
                            }
                        }
                        Behavior on border.color {
                            ColorAnimation {
                                duration: 100
                            }
                        }
                    }

                    HoverHandler {
                        cursorShape: Qt.PointingHandCursor
                    }
                    TapHandler {
                        onTapped: {
                            Visibilities.closePopups();
                            modelData.activate();
                        }
                    }
                }
            }
        }

        Item {
            clip: true
            implicitHeight: 16
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: root.onNamedWs ? namedBadge.implicitWidth + 5 : 0
            Layout.leftMargin: root.onNamedWs ? 5 : 0

            Behavior on Layout.preferredWidth {
                NumberAnimation {
                    duration: Theme.animations.fast
                    easing.type: Easing.OutCubic
                }
            }
            Behavior on Layout.leftMargin {
                NumberAnimation {
                    duration: Theme.animations.fast
                    easing.type: Easing.OutCubic
                }
            }

            Rectangle {
                id: namedBadge
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                implicitWidth: namedLabel.implicitWidth + 16
                height: 16
                radius: 8
                color: Colors.tertiary_container

                Text {
                    id: namedLabel
                    anchors.centerIn: parent
                    renderType: Text.NativeRendering
                    text: root.focusedWs?.name ?? ""
                    color: Colors.on_tertiary_container
                    font.family: Fonts.font
                    font.pixelSize: 10
                    font.weight: Font.Medium
                }
            }
        }
    }
}
