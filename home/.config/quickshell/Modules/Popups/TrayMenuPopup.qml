import QtQuick
import Quickshell
import qs.Constants
import qs.Components
import qs.Services

PopupWindow {
    id: root

    property Item anchorItem
    property var menuOpener: null
    property bool open: false
    signal closeRequested
    signal hidden
    readonly property var barWindow: anchorItem ? anchorItem.QsWindow.window : null
    readonly property real maximumHeight: barWindow && barWindow.screen ? Math.max(120, barWindow.screen.height - barWindow.height - 24) : 600

    implicitWidth: 200

    implicitHeight: maximumHeight
    color: "transparent"
    visible: presence.mapped

    onOpenChanged: {
        if (open)
            Qt.callLater(() => menuRect.forceActiveFocus());
    }
    onVisibleChanged: {
        if (!visible)
            hidden();
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
        active: root.open
        windows: root.barWindow ? [root, root.barWindow] : [root]
        onDismissed: root.closeRequested()
    }

    Connections {
        target: Visibilities
        function onCloseTrayMenus() {
            root.closeRequested();
        }
    }

    mask: Region {
        item: root.open ? menuRect : null
    }

    Presence {
        id: presence

        active: root.open
    }

    Rectangle {
        id: menuRect
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: Math.min(menuColumn.implicitHeight + 16, root.maximumHeight)
        radius: Theme.radius.lg
        color: Theme.colors.raised
        border.color: Theme.stroke.hairline
        border.width: 1

        transformOrigin: Item.Top
        scale: presence.scale
        opacity: presence.progress
        enabled: root.open
        clip: true

        focus: root.open
        Keys.onPressed: function (event) {
            if (event.key === Qt.Key_Escape) {
                root.closeRequested();
                event.accepted = true;
            }
        }

        SizeMotion on height {
            enabled: presence.progress === 1
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
