import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.Constants
import qs.Components

PopupWindow {
    id: root

    property Item anchorItem
    property var menuOpener: null

    // Window size tracks the content container's full natural size instantly —
    // no animation here so Hyprland never sees a mid-animation resize.
    implicitWidth: 200
    implicitHeight: menuColumn.implicitHeight + 16
    color: "transparent"
    visible: false

    Behavior on implicitHeight {
        NumberAnimation {
            duration: 150
            easing.type: Easing.OutCubic
        }
    }

    anchor {
        item: root.anchorItem
        edges: Edges.Bottom | Edges.HCenter
        gravity: Edges.Bottom | Edges.HCenter
        margins.top: 12
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

    // Recursive submenu list component — used at every nesting level.
    // `menuHandle`  : a QsMenuHandle (QsMenuEntry is-a QsMenuHandle)
    // `indentLevel` : how many levels deep we are (drives left padding)
    Component {
        id: menuListComponent

        Item {
            id: menuListItem

            property var menuHandle: null
            property int indentLevel: 0

            QsMenuOpener {
                id: levelOpener
                menu: menuListItem.menuHandle
            }

            // implicitHeight reflects the FULL expanded size so the window
            // can size itself correctly without waiting for animations.
            implicitHeight: levelColumn.implicitHeight
            width: parent ? parent.width : 0

            Column {
                id: levelColumn
                width: parent.width
                spacing: 2

                Repeater {
                    model: levelOpener.children.values

                    delegate: Column {
                        id: entryColumn
                        width: levelColumn.width
                        spacing: 2

                        property bool expanded: false

                        // Separator
                        Item {
                            visible: modelData.isSeparator
                            width: entryColumn.width
                            height: 9

                            Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width
                                height: 1
                                color: Colors.on_surface_variant
                            }
                        }

                        // Menu entry row
                        Rectangle {
                            visible: !modelData.isSeparator
                            width: entryColumn.width
                            height: 28
                            radius: 4
                            color: rowMa.containsMouse && modelData.enabled ? Colors.surface_container : "transparent"

                            RowLayout {
                                anchors {
                                    fill: parent
                                    leftMargin: 8 + menuListItem.indentLevel * 12
                                    rightMargin: 8
                                }
                                spacing: 6

                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.text
                                    color: modelData.enabled ? Colors.on_surface : Colors.on_surface_variant
                                    font.pixelSize: Fonts.p
                                    font.family: Fonts.font
                                    elide: Text.ElideRight
                                }

                                Text {
                                    visible: modelData.hasChildren
                                    text: Icons.chevronRight
                                    color: entryColumn.expanded ? Colors.on_surface : Colors.on_surface_variant
                                    font.pixelSize: Fonts.p
                                    font.family: Fonts.iconFont

                                    transform: Rotation {
                                        origin.x: 4
                                        origin.y: 8
                                        angle: entryColumn.expanded ? 90 : 0

                                        Behavior on angle {
                                            NumberAnimation {
                                                duration: 150
                                                easing.type: Easing.OutCubic
                                            }
                                        }
                                    }
                                }
                            }

                            MouseArea {
                                id: rowMa
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: modelData.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                enabled: modelData.enabled && !modelData.isSeparator
                                onClicked: {
                                    if (modelData.hasChildren) {
                                        entryColumn.expanded = !entryColumn.expanded;
                                    } else {
                                        modelData.triggered();
                                        root.visible = false;
                                    }
                                }
                            }
                        }

                        // Inline submenu (recursive)
                        Loader {
                            id: submenuLoader
                            active: modelData.hasChildren
                            width: entryColumn.width
                            clip: true
                            height: entryColumn.expanded && item ? item.implicitHeight : 0

                            Behavior on height {
                                NumberAnimation {
                                    duration: 150
                                    easing.type: Easing.OutCubic
                                }
                            }

                            sourceComponent: menuListComponent
                            onLoaded: {
                                item.menuHandle = modelData;
                                item.indentLevel = menuListItem.indentLevel + 1;
                            }
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: 8
        color: Colors.surface
        border.color: Colors.on_surface_variant
        border.width: 1

        Column {
            id: menuColumn
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: 8
            }
            spacing: 0

            Loader {
                width: menuColumn.width
                active: root.menuOpener !== null
                sourceComponent: menuListComponent
                onLoaded: {
                    item.menuHandle = root.menuOpener ? root.menuOpener.menu : null;
                    item.indentLevel = 0;
                    root.menuOpenerChanged.connect(function () {
                        if (item)
                            item.menuHandle = root.menuOpener ? root.menuOpener.menu : null;
                    });
                }
            }
        }
    }
}
