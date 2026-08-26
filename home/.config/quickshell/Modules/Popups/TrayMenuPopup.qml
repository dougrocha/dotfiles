import QtQuick
import Quickshell
import qs.Constants
import qs.Components
import qs.Services

PopupWindow {
    id: root

    property Item anchorItem
    property var menuOpener: null
    signal closeRequested
    readonly property var barWindow: anchorItem ? anchorItem.QsWindow.window : null
    readonly property real maximumHeight: barWindow && barWindow.screen ? Math.max(120, barWindow.screen.height - barWindow.height - 24) : 600

    implicitWidth: 200
    // Keep the native window geometry stable while submenus animate. The mask
    // limits input to the visible menu rectangle.
    implicitHeight: maximumHeight
    color: "transparent"
    visible: false

    onVisibleChanged: {
        if (visible)
            Qt.callLater(() => menuRect.forceActiveFocus());
    }

    anchor.item: root.anchorItem
    anchor.rect.x: {
        if (!anchorItem || !barWindow)
            return 0;

        const anchorPosition = anchorItem.mapToItem(null, 0, 0).x;
        const desiredPosition = anchorPosition + anchorItem.width / 2 - implicitWidth / 2;
        const clampedPosition = Math.max(4, Math.min(barWindow.width - implicitWidth - 4, desiredPosition));
        return Math.round(clampedPosition - anchorPosition);
    }
    anchor.rect.y: anchorItem ? anchorItem.height + 12 : 0

    PopupGrab {
        popup: root
        anchorWindow: root.barWindow
        onDismissed: root.closeRequested()
    }

    Connections {
        target: Visibilities
        function onCloseTrayMenus() {
            root.closeRequested();
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
        height: Math.min(menuColumn.implicitHeight + 16, root.maximumHeight)
        radius: 8
        color: Colors.surface
        border.color: Colors.outline_variant
        border.width: 1

        transformOrigin: Item.Top
        scale: root.visible ? 1.0 : 0.92
        opacity: root.visible ? 1.0 : 0.0

        focus: root.visible
        Keys.onPressed: function (event) {
            if (event.key === Qt.Key_Escape) {
                root.closeRequested();
                event.accepted = true;
            }
        }

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

        Flickable {
            id: menuFlickable
            anchors {
                fill: parent
                margins: 8
            }
            clip: true
            contentWidth: width
            contentHeight: menuColumn.implicitHeight
            boundsBehavior: Flickable.StopAtBounds
            flickableDirection: Flickable.VerticalFlick

            Column {
                id: menuColumn
                width: menuFlickable.width
                spacing: 0

                TrayMenuList {
                    width: menuColumn.width
                    menuHandle: root.menuOpener ? root.menuOpener.menu : null
                    onCloseRequested: root.closeRequested()
                }
            }
        }
    }
}
