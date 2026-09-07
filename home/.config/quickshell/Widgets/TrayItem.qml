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
    property bool dragging: dragHandler.active
    property real previewOffsetX: 0
    signal menuRequested(var trayItem, Item anchorItem)
    signal disappearing(Item anchorItem)
    signal dragStarted(Item sourceItem)
    signal dragMoved(Item sourceItem, point translation)
    signal dragFinished(Item sourceItem, point translation, bool cancelled)
    signal organizeRequested(string command)

    function requestPrimaryAction() {
        if (root.trayItem.onlyMenu && root.trayItem.hasMenu) {
            root.menuRequested(root.trayItem, root);
        } else if (trayOverrides.triggerPrimaryAction()) {
            Visibilities.closePopups();
        } else {
            Visibilities.closePopups();
            root.trayItem.activate();
        }
    }

    Layout.preferredWidth: 24
    Layout.preferredHeight: 24
    activeFocusOnTab: true
    radius: height / 2
    color: menuOpen || activeFocus ? Theme.fill.press : hoverHandler.hovered ? Theme.fill.hover : Theme.withAlpha(Theme.fill.hover, 0)
    border.width: trayItem.status === Status.NeedsAttention || activeFocus ? 1 : 0
    border.color: trayItem.status === Status.NeedsAttention ? Theme.accent : Theme.stroke.strong
    transform: Translate {
        x: root.previewOffsetX
    }

    Behavior on color {
        ColorAnimation {
            duration: Theme.motion.fast
        }
    }
    Behavior on previewOffsetX {
        NumberAnimation {
            duration: Theme.motion.normal
            easing.type: Theme.motion.easeStandard
        }
    }

    IconImage {
        id: trayIcon
        anchors.centerIn: parent
        width: 16
        height: 16
        source: root.trayItem.icon
        visible: status === Image.Ready && !root.dragging
        mipmap: true
    }

    TrayItemOverrides {
        id: trayOverrides
        trayItem: root.trayItem
    }

    HoverHandler {
        id: hoverHandler
        cursorShape: Qt.PointingHandCursor
    }

    Tooltip {
        text: trayOverrides.displayTitle()
        targetItem: root
        hovered: hoverHandler.hovered && !root.dragging
    }

    DragHandler {
        id: dragHandler
        target: null
        acceptedButtons: Qt.LeftButton
        onActiveChanged: {
            if (active)
                root.dragStarted(root);
            else
                root.dragFinished(root, translation, false);
        }
        onTranslationChanged: if (active)
            root.dragMoved(root, translation)
        onCanceled: root.dragFinished(root, translation, true)
    }

    TapHandler {
        enabled: !root.dragging
        acceptedButtons: Qt.LeftButton
        onTapped: root.requestPrimaryAction()
    }

    TapHandler {
        enabled: !root.dragging
        acceptedButtons: Qt.RightButton
        onTapped: {
            if (root.trayItem.hasMenu)
                root.menuRequested(root.trayItem, root);
        }
    }

    TapHandler {
        enabled: !root.dragging
        acceptedButtons: Qt.MiddleButton
        onTapped: {
            Visibilities.closePopups();
            root.trayItem.secondaryActivate();
        }
    }

    WheelHandler {
        enabled: !root.dragging
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
        } else if (event.modifiers & Qt.ControlModifier) {
            if (event.key === Qt.Key_Left)
                root.organizeRequested("left");
            else if (event.key === Qt.Key_Right)
                root.organizeRequested("right");
            else
                return;
            event.accepted = true;
        }
    }

    Component.onDestruction: {
        if (root.dragging)
            root.dragFinished(root, dragHandler.translation, true);
        root.disappearing(root);
    }
}
