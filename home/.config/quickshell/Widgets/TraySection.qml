import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs.Constants
import qs.Modules.Popups
import qs.Services

Item {
    id: root
    property var activeTrayItem: null
    property Item activeAnchor: null
    property Item dragSource: null
    property var draggedTrayItem: null
    property int dragIndex: -1
    property point dragTranslation: Qt.point(0, 0)
    property string pendingFocusId: ""
    readonly property int traySlot: 24 + visibleRow.spacing

    function itemId(item) {
        return item && typeof item.id === "string" ? item.id.trim() : "";
    }
    function indexFor(item) {
        const id = itemId(item);
        return TrayState.items.findIndex(candidate => itemId(candidate) === id);
    }
    function toggleMenu(trayItem, anchorItem) {
        const shouldClose = trayMenu.visible && activeTrayItem === trayItem;
        Visibilities.closePopups();
        if (shouldClose)
            return;
        activeTrayItem = trayItem;
        activeAnchor = anchorItem;
        trayMenu.visible = true;
    }
    function clearMenu(anchorItem) {
        if (anchorItem && activeAnchor !== anchorItem)
            return;
        trayMenu.visible = false;
        activeTrayItem = null;
        activeAnchor = null;
    }
    function beginDrag(sourceItem) {
        if (!itemId(sourceItem.trayItem))
            return;
        dragSource = sourceItem;
        draggedTrayItem = sourceItem.trayItem;
        dragTranslation = Qt.point(0, 0);
        updateDropTarget();
    }
    function moveDrag(sourceItem, translation) {
        if (sourceItem !== dragSource)
            return;
        dragTranslation = translation;
        updateDropTarget();
    }
    function dragPoint() {
        if (!dragSource)
            return Qt.point(-1, -1);
        const origin = root.mapFromItem(dragSource, dragSource.width / 2, dragSource.height / 2);
        return Qt.point(origin.x + dragTranslation.x, origin.y + dragTranslation.y);
    }
    function previewOffset(item) {
        if (!dragSource || item === draggedTrayItem)
            return 0;
        const i = indexFor(item);
        const s = indexFor(draggedTrayItem);
        const finalIndex = s < dragIndex ? dragIndex - 1 : dragIndex;
        const closing = i > s ? 1 : 0;
        const oi = i - closing;
        const opening = oi >= finalIndex ? 1 : 0;
        return traySlot * (opening - closing);
    }
    function placeholderX() {
        const s = indexFor(draggedTrayItem);
        const finalIndex = s < dragIndex ? dragIndex - 1 : dragIndex;
        let boundary = null;
        let last = null;
        let oi = 0;
        for (let i = 0; i < visibleRepeater.count; ++i) {
            if (i === s)
                continue;
            const delegate = visibleRepeater.itemAt(i);
            if (!delegate)
                continue;
            if (oi === finalIndex)
                boundary = delegate;
            last = delegate;
            oi++;
        }
        if (boundary)
            return boundary.x + previewOffset(boundary.trayItem) - traySlot;
        if (last)
            return last.x + previewOffset(last.trayItem) + traySlot;
        return 0;
    }
    function insertionIndex(point) {
        const local = visibleRow.mapFromItem(root, point.x, point.y);
        for (let i = 0; i < visibleRepeater.count; ++i) {
            const delegate = visibleRepeater.itemAt(i);
            if (!delegate || delegate.trayItem === root.draggedTrayItem)
                continue;
            if (local.x < delegate.x + delegate.width / 2)
                return i;
        }
        return visibleRepeater.count;
    }
    function updateDropTarget() {
        dragIndex = dragSource ? insertionIndex(dragPoint()) : -1;
    }
    function finishDrag(sourceItem, translation, cancelled) {
        if (sourceItem !== dragSource)
            return;
        updateDropTarget();
        const id = itemId(draggedTrayItem);
        const shouldMove = !cancelled && dragIndex >= 0;
        const targetIndex = dragIndex;
        dragSource = null;
        draggedTrayItem = null;
        dragIndex = -1;
        if (shouldMove)
            TrayState.move(id, targetIndex);
    }
    function organize(item, command) {
        const sourceIndex = indexFor(item);
        let index = sourceIndex;
        if (command === "left")
            index = Math.max(0, sourceIndex - 1);
        else if (command === "right")
            index = sourceIndex + 2;
        else
            return;
        pendingFocusId = itemId(item);
        TrayState.move(pendingFocusId, index);
        Qt.callLater(restoreFocus);
    }
    function restoreFocus() {
        for (let i = 0; i < visibleRepeater.count; ++i) {
            const delegate = visibleRepeater.itemAt(i);
            if (delegate && itemId(delegate.trayItem) === pendingFocusId) {
                delegate.forceActiveFocus();
                pendingFocusId = "";
                return;
            }
        }
    }

    visible: TrayState.liveItems.length > 0
    implicitWidth: visible ? visibleRow.width : 0
    implicitHeight: Theme.topBarHeight

    component ItemDelegate: TrayItem {
        menuOpen: trayMenu.visible && root.activeTrayItem === trayItem
        previewOffsetX: root.dragSource ? root.previewOffset(trayItem) : 0
        onMenuRequested: (trayItem, anchorItem) => root.toggleMenu(trayItem, anchorItem)
        onDisappearing: anchorItem => root.clearMenu(anchorItem)
        onDragStarted: sourceItem => root.beginDrag(sourceItem)
        onDragMoved: (sourceItem, translation) => root.moveDrag(sourceItem, translation)
        onDragFinished: (sourceItem, translation, cancelled) => root.finishDrag(sourceItem, translation, cancelled)
        onOrganizeRequested: command => root.organize(trayItem, command)
    }

    RowLayout {
        id: visibleRow
        anchors.centerIn: parent
        spacing: Theme.space.xs
        Repeater {
            id: visibleRepeater
            model: TrayState.items
            delegate: ItemDelegate {}
        }
    }

    Rectangle {
        visible: root.dragSource !== null
        width: 24
        height: 24
        radius: Theme.radius.lg
        color: "transparent"
        border.width: 1
        border.color: Theme.stroke.strong
        z: 10
        y: (root.height - height) / 2
        x: root.mapFromItem(visibleRow, 0, 0).x + root.placeholderX()
    }
    IconImage {
        visible: root.dragSource !== null
        width: 16
        height: 16
        source: root.draggedTrayItem ? root.draggedTrayItem.icon : ""
        x: root.dragPoint().x - width / 2
        y: root.dragPoint().y - height / 2
        z: 20
        mipmap: true
    }
    QsMenuOpener {
        id: menuOpener
        menu: root.activeTrayItem ? root.activeTrayItem.menu : null
    }
    TrayMenuPopup {
        id: trayMenu
        anchorItem: root.activeAnchor
        menuOpener: menuOpener
        onCloseRequested: root.clearMenu(null)
    }
}
