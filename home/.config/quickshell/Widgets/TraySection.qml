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
    property bool drawerOpen: false
    property Item dragSource: null
    property var draggedTrayItem: null
    property string dragDestination: ""
    property int dragIndex: -1
    property point dragTranslation: Qt.point(0, 0)
    property string pendingFocusId: ""
    readonly property bool chevronActive: TrayState.drawerItems.length > 0 && TrayState.visibleItems.length > 0

    onChevronActiveChanged: {
        if (!chevronActive && !dragSource)
            drawerOpen = false;
    }

    function itemId(item) {
        return item && typeof item.id === "string" ? item.id.trim() : "";
    }
    function regionFor(item) {
        const id = itemId(item);
        return TrayState.drawerItems.some(candidate => itemId(candidate) === id) ? "drawer" : "visible";
    }
    function indexFor(item, region) {
        const id = itemId(item);
        const values = region === "drawer" ? TrayState.drawerItems : TrayState.visibleItems;
        return values.findIndex(candidate => itemId(candidate) === id);
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
    function insertionIndex(repeater, row, point) {
        const local = row.mapFromItem(root, point.x, point.y);
        for (let i = 0; i < repeater.count; ++i) {
            const delegate = repeater.itemAt(i);
            if (delegate && local.x < delegate.x + delegate.width / 2)
                return i;
        }
        return repeater.count;
    }
    function updateDropTarget() {
        dragDestination = "";
        dragIndex = -1;
        if (!dragSource)
            return;
        const point = dragPoint();
        const chevronPoint = chevron.mapFromItem(root, point.x, point.y);
        const overChevron = chevronPoint.x >= 0 && chevronPoint.x <= chevron.width && chevronPoint.y >= 0 && chevronPoint.y <= chevron.height;
        if (overChevron) {
            const sourceRegion = regionFor(draggedTrayItem);
            if (sourceRegion === "visible" && !drawerOpen && !drawerDwell.running)
                drawerDwell.start();
            dragDestination = sourceRegion === "visible" ? "drawer" : "visible";
            dragIndex = dragDestination === "drawer" ? TrayState.drawerItems.length : 0;
            return;
        }
        drawerDwell.stop();
        const visiblePoint = visibleRow.mapFromItem(root, point.x, point.y);
        if (visiblePoint.x >= -4 && visiblePoint.x <= visibleRow.width + 4 && Math.abs(visiblePoint.y - visibleRow.height / 2) <= visibleRow.height) {
            dragDestination = "visible";
            dragIndex = insertionIndex(visibleRepeater, visibleRow, point);
            return;
        }
        const drawerPoint = drawerRow.mapFromItem(root, point.x, point.y);
        if (drawerOpen && drawerPoint.x >= -4 && drawerPoint.x <= drawerRow.width + 4 && Math.abs(drawerPoint.y - drawerRow.height / 2) <= drawerRow.height) {
            dragDestination = "drawer";
            dragIndex = insertionIndex(drawerRepeater, drawerRow, point);
        }
    }
    function finishDrag(sourceItem, translation, cancelled) {
        if (sourceItem !== dragSource)
            return;
        updateDropTarget();
        if (!cancelled && dragDestination) {
            if (dragDestination === "drawer")
                drawerOpen = true;
            TrayState.move(itemId(draggedTrayItem), dragDestination, dragIndex);
        }
        drawerDwell.stop();
        dragSource = null;
        draggedTrayItem = null;
        dragDestination = "";
        dragIndex = -1;
    }
    function organize(item, command) {
        const sourceRegion = regionFor(item);
        const sourceIndex = indexFor(item, sourceRegion);
        let destination = sourceRegion;
        let index = sourceIndex;
        if (command === "left")
            index = Math.max(0, sourceIndex - 1);
        else if (command === "right")
            index = sourceIndex + 2;
        else {
            destination = sourceRegion === "visible" ? "drawer" : "visible";
            index = destination === "drawer" ? TrayState.drawerItems.length : TrayState.visibleItems.length;
            if (destination === "drawer")
                drawerOpen = true;
        }
        pendingFocusId = itemId(item);
        TrayState.move(pendingFocusId, destination, index);
        Qt.callLater(restoreFocus);
    }
    function restoreFocus() {
        for (const repeater of [drawerRepeater, visibleRepeater]) {
            for (let i = 0; i < repeater.count; ++i) {
                const delegate = repeater.itemAt(i);
                if (delegate && itemId(delegate.trayItem) === pendingFocusId) {
                    delegate.forceActiveFocus();
                    pendingFocusId = "";
                    return;
                }
            }
        }
    }

    visible: TrayState.liveItems.length > 0
    implicitWidth: visible ? mainLayout.width : 0
    implicitHeight: Theme.topBarHeight

    Connections {
        target: Visibilities
        function onCloseTrayMenus() {
            root.drawerOpen = false;
        }
    }
    Timer {
        id: drawerDwell
        interval: 250
        onTriggered: root.drawerOpen = true
    }

    component ItemDelegate: TrayItem {
        menuOpen: trayMenu.visible && root.activeTrayItem === trayItem
        onMenuRequested: (trayItem, anchorItem) => root.toggleMenu(trayItem, anchorItem)
        onDisappearing: anchorItem => root.clearMenu(anchorItem)
        onDragStarted: sourceItem => root.beginDrag(sourceItem)
        onDragMoved: (sourceItem, translation) => root.moveDrag(sourceItem, translation)
        onDragFinished: (sourceItem, translation, cancelled) => root.finishDrag(sourceItem, translation, cancelled)
        onOrganizeRequested: command => root.organize(trayItem, command)
    }

    RowLayout {
        id: mainLayout
        anchors.centerIn: parent
        spacing: 1
        Item {
            id: drawerClip
            Layout.preferredWidth: root.drawerOpen ? drawerRow.implicitWidth : 0
            Layout.preferredHeight: 24
            clip: true
            opacity: root.drawerOpen ? 1 : 0
            Behavior on Layout.preferredWidth {
                NumberAnimation {
                    duration: 180
                    easing.type: Easing.OutCubic
                }
            }
            Behavior on opacity {
                NumberAnimation {
                    duration: 180
                    easing.type: Easing.OutCubic
                }
            }
            RowLayout {
                id: drawerRow
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4
                Repeater {
                    id: drawerRepeater
                    model: TrayState.drawerItems
                    delegate: ItemDelegate {}
                }
            }
        }
        Rectangle {
            id: chevron
            Layout.preferredWidth: 14
            Layout.preferredHeight: 24
            radius: height / 2
            color: root.chevronActive && (chevronHover.hovered || activeFocus) ? Colors.surface_container_high : "transparent"
            opacity: root.chevronActive ? 1 : 0.35
            activeFocusOnTab: root.chevronActive
            Behavior on color {
                ColorAnimation {
                    duration: Theme.animations.fast
                }
            }
            Text {
                anchors.centerIn: parent
                text: root.drawerOpen ? PhosphorIcons.caretRight : PhosphorIcons.caretLeft
                font.family: Fonts.phosphorFont
                font.pixelSize: 11
                color: Colors.on_surface
            }
            HoverHandler {
                id: chevronHover
                enabled: root.chevronActive
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            }
            function toggle() {
                if (!root.chevronActive)
                    return;
                const open = !root.drawerOpen;
                Visibilities.closePopups();
                root.drawerOpen = open;
            }
            TapHandler {
                enabled: root.chevronActive
                onTapped: chevron.toggle()
            }
            Keys.onPressed: event => {
                if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                    chevron.toggle();
                    event.accepted = true;
                }
            }
        }
        RowLayout {
            id: visibleRow
            spacing: 4
            Repeater {
                id: visibleRepeater
                model: TrayState.visibleItems
                delegate: ItemDelegate {}
            }
        }
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
    Rectangle {
        visible: root.dragDestination !== ""
        width: 2
        height: 20
        radius: 1
        color: Colors.primary
        z: 19
        y: (root.height - height) / 2
        x: {
            const row = root.dragDestination === "drawer" ? drawerRow : visibleRow;
            const repeater = root.dragDestination === "drawer" ? drawerRepeater : visibleRepeater;
            const local = root.mapFromItem(row, 0, 0);
            if (root.dragIndex >= repeater.count)
                return local.x + row.width + 1;
            const item = repeater.itemAt(Math.max(0, root.dragIndex));
            return item ? root.mapFromItem(item, 0, 0).x - 3 : local.x;
        }
    }
    QsMenuOpener {
        id: menuOpener
        menu: root.activeTrayItem ? root.activeTrayItem.menu : null
    }
    TrayMenuPopup {
        id: trayMenu
        anchorItem: root.activeAnchor
        menuOpener: menuOpener
    }
}
