import "../../Components"
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

PopupWindow {
    id: root

    property Item anchorItem
    property var menuOpener: null

    implicitWidth: 200
    implicitHeight: menuColumn.implicitHeight + 16
    color: "transparent"
    visible: false

    anchor {
        item: root.anchorItem
        edges: Edges.Bottom | Edges.HCenter
        gravity: Edges.Bottom | Edges.HCenter
        margins.top: 4
    }

    HyprlandFocusGrab {
        id: focusGrab
        active: false
        windows: [root]
        onActiveChanged: {
            if (!active && root.visible)
                root.visible = false;
        }
    }

    Timer {
        id: grabDelay
        interval: 50
        repeat: false
        onTriggered: focusGrab.active = true
    }

    onVisibleChanged: {
        if (visible) {
            grabDelay.restart();
        } else {
            grabDelay.stop();
            focusGrab.active = false;
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: 8
        color: Theme.bg
        border.color: Theme.muted
        border.width: 1

        Column {
            id: menuColumn
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: 8
            }
            spacing: 2

            Repeater {
                model: root.menuOpener ? root.menuOpener.children.values : []

                delegate: Item {
                    width: menuColumn.width
                    height: modelData.isSeparator ? 9 : 28

                    // Separator
                    Rectangle {
                        visible: modelData.isSeparator
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width
                        height: 1
                        color: Theme.muted
                    }

                    // Menu entry
                    Rectangle {
                        visible: !modelData.isSeparator
                        anchors.fill: parent
                        radius: 4
                        color: entryMa.containsMouse && modelData.enabled ? Qt.rgba(1, 1, 1, 0.08) : "transparent"

                        RowLayout {
                            anchors {
                                fill: parent
                                leftMargin: 8
                                rightMargin: 8
                            }
                            spacing: 6

                            Image {
                                visible: modelData.icon !== ""
                                source: modelData.icon
                                width: 14
                                height: 14
                                Layout.alignment: Qt.AlignVCenter
                            }

                            Text {
                                Layout.fillWidth: true
                                text: modelData.text
                                color: modelData.enabled ? Theme.fg : Theme.muted
                                font.pixelSize: Theme.fontSize
                                font.family: Theme.fontFamily
                                elide: Text.ElideRight
                            }

                            Text {
                                visible: modelData.hasChildren
                                text: "›"
                                color: Theme.muted
                                font.pixelSize: Theme.fontSize
                            }
                        }

                        MouseArea {
                            id: entryMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: modelData.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                            enabled: modelData.enabled && !modelData.isSeparator
                            onClicked: {
                                modelData.triggered();
                                root.visible = false;
                            }
                        }
                    }
                }
            }
        }
    }
}
