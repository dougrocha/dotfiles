import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Constants
import qs.Components

PopupWindow {
    id: root

    property Item anchorItem
    property var menuOpener: null

    implicitWidth: 200
    implicitHeight: {
        const win = barWindow;
        return (win && win.screen) ? Math.max(300, win.screen.height - win.height - 24) : 600;
    }
    color: "transparent"
    visible: false

    anchor.item: root.anchorItem
    anchor.rect.x: anchorItem ? Math.round(anchorItem.width / 2 - implicitWidth / 2) : 0
    anchor.rect.y: anchorItem ? anchorItem.height + 12 : 0

    readonly property var barWindow: anchorItem ? anchorItem.QsWindow.window : null

    PopupGrab {
        popup: root
        anchorWindow: root.barWindow
        onDismissed: root.visible = false
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
                                    visible: modelData.checkState === Qt.Checked
                                    text: Icons.check
                                    color: Colors.primary
                                    font.pixelSize: Fonts.p
                                    font.family: Fonts.iconFont
                                }

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

    mask: Region {
        item: menuRect
    }

    Rectangle {
        id: menuRect
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: menuColumn.implicitHeight + 16
        radius: 8
        color: Colors.surface
        border.color: Colors.outline_variant
        border.width: 1

        transformOrigin: Item.Top
        scale: root.visible ? 1.0 : 0.92
        opacity: root.visible ? 1.0 : 0.0

        Behavior on scale {
            SpringAnimation {
                spring: 8.0
                damping: 0.7
                mass: 0.5
            }
        }
        Behavior on opacity {
            NumberAnimation {
                duration: 80
                easing.type: Easing.OutCubic
            }
        }

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
