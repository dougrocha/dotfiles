import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs.Components
import qs.Constants
import qs.Services

Rectangle {
    id: root

    property var trayItem: modelData
    property bool menuOpen: false
    signal menuRequested(var trayItem, Item anchorItem)
    signal disappearing(Item anchorItem)

    function requestPrimaryAction() {
        if (root.trayItem.onlyMenu && root.trayItem.hasMenu) {
            root.menuRequested(root.trayItem, root);
        } else {
            Visibilities.closePopups();
            root.trayItem.activate();
        }
    }

    Layout.preferredWidth: 24
    Layout.preferredHeight: 24
    activeFocusOnTab: true
    radius: 4
    color: menuOpen || activeFocus ? Colors.surface_container_highest : hoverHandler.hovered ? Colors.surface_container_high : "transparent"
    border.width: trayItem.status === Status.NeedsAttention || activeFocus ? 1 : 0
    border.color: trayItem.status === Status.NeedsAttention ? Colors.primary : Colors.outline

    Behavior on color {
        ColorAnimation {
            duration: Theme.animations.fast
        }
    }

    IconImage {
        anchors.centerIn: parent
        width: 16
        height: 16
        source: root.trayItem.icon
        visible: status === Image.Ready
        mipmap: true
    }

    HoverHandler {
        id: hoverHandler
        cursorShape: Qt.PointingHandCursor
    }

    Tooltip {
        text: root.trayItem.tooltipTitle || root.trayItem.title || root.trayItem.id
        targetItem: root
        hovered: hoverHandler.hovered
    }

    TapHandler {
        acceptedButtons: Qt.LeftButton
        onTapped: root.requestPrimaryAction()
    }

    TapHandler {
        acceptedButtons: Qt.RightButton
        onTapped: {
            if (root.trayItem.hasMenu)
                root.menuRequested(root.trayItem, root);
        }
    }

    TapHandler {
        acceptedButtons: Qt.MiddleButton
        onTapped: {
            Visibilities.closePopups();
            root.trayItem.secondaryActivate();
        }
    }

    WheelHandler {
        onWheel: event => {
            const horizontal = Math.abs(event.angleDelta.x) > Math.abs(event.angleDelta.y);
            const delta = horizontal ? event.angleDelta.x : event.angleDelta.y;
            root.trayItem.scroll(delta, horizontal);
            event.accepted = true;
        }
    }

    Keys.onPressed: event => {
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
            root.requestPrimaryAction();
            event.accepted = true;
        } else if (event.key === Qt.Key_Menu && root.trayItem.hasMenu) {
            root.menuRequested(root.trayItem, root);
            event.accepted = true;
        }
    }

    Component.onDestruction: root.disappearing(root)
}
