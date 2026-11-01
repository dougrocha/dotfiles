import QtQuick
import Quickshell
import qs.Constants

PopupWindow {
    id: root

    property bool open: false
    property bool menu: false
    property var hostWindow: null
    property real originX: implicitWidth / 2
    readonly property real availableHeight: {
        const screen = hostWindow?.screen;
        return screen ? Math.max(400, screen.height - hostWindow.height - Theme.space.lg) : 800;
    }
    default property alias content: card.content

    signal opened
    signal dismissed
    signal hidden

    onOpenChanged: {
        if (!open)
            return;
        opened();
        Qt.callLater(() => card.forceActiveFocus());
    }
    onVisibleChanged: {
        if (!visible)
            hidden();
    }

    color: "transparent"
    visible: presence.mapped
    implicitWidth: card.implicitWidth
    implicitHeight: availableHeight

    mask: Region {
        item: root.open ? card : null
    }

    Presence {
        id: presence

        active: root.open
    }

    PopupGrab {
        active: root.open
        windows: root.hostWindow ? [root, root.hostWindow] : [root]
        onDismissed: root.dismissed()
    }

    PanelCard {
        id: card

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: implicitHeight
        menu: root.menu
        maxHeight: root.availableHeight
        enabled: root.open
        opacity: presence.progress
        transform: Scale {
            xScale: presence.scale
            yScale: presence.scale
            origin.x: root.originX
        }

        SizeMotion on height {
            enabled: presence.progress === 1
        }

        focus: root.open
        Keys.onEscapePressed: root.dismissed()
    }
}
