pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.SystemTray

// Reconciles durable tray placement with the currently connected protocol items.
Singleton {
    id: root

    readonly property var liveItems: SystemTray.items.values
    property var visibleItems: []
    property var drawerItems: []

    function validId(item) {
        return item && typeof item.id === "string" ? item.id.trim() : "";
    }

    function cleanIds(values, seen) {
        const result = [];
        for (const raw of values || []) {
            const id = typeof raw === "string" ? raw.trim() : "";
            if (id && !seen[id]) {
                seen[id] = true;
                result.push(id);
            }
        }
        return result;
    }

    function reconciledIds() {
        const seen = {};
        const visible = cleanIds(SettingsService.trayVisible, seen);
        const drawer = cleanIds(SettingsService.trayDrawer, seen);
        return {
            visible,
            drawer
        };
    }

    function reconcile() {
        if (!SettingsService.loaded)
            return;

        const saved = reconciledIds();
        const byId = {};
        const anonymous = [];
        for (const item of liveItems) {
            const id = validId(item);
            if (id && !byId[id])
                byId[id] = item;
            else if (!id)
                anonymous.push(item);
        }

        const visible = [];
        const drawer = [];
        const placed = {};
        for (const id of saved.visible) {
            if (byId[id]) {
                visible.push(byId[id]);
                placed[id] = true;
            }
        }
        for (const id of saved.drawer) {
            if (byId[id]) {
                drawer.push(byId[id]);
                placed[id] = true;
            }
        }
        // New and not-yet-identifiable items are visible, in protocol order.
        for (const item of liveItems) {
            const id = validId(item);
            if (id && !placed[id]) {
                visible.push(item);
                placed[id] = true;
            }
        }
        visible.push(...anonymous);
        visibleItems = visible;
        drawerItems = drawer;
    }

    function insertAtLiveIndex(stored, live, itemId, index) {
        const result = stored.filter(id => id !== itemId);
        const liveIds = live.map(item => validId(item)).filter(id => id && id !== itemId);
        const bounded = Math.max(0, Math.min(index, liveIds.length));
        if (bounded < liveIds.length) {
            const anchor = result.indexOf(liveIds[bounded]);
            result.splice(anchor < 0 ? result.length : anchor, 0, itemId);
        } else if (liveIds.length > 0) {
            const anchor = result.indexOf(liveIds[liveIds.length - 1]);
            result.splice(anchor < 0 ? result.length : anchor + 1, 0, itemId);
        } else {
            result.push(itemId);
        }
        return result;
    }

    // destination is "visible" or "drawer"; index is in the live destination region.
    function move(itemId, destination, index) {
        itemId = typeof itemId === "string" ? itemId.trim() : "";
        if (!itemId || (destination !== "visible" && destination !== "drawer"))
            return false;

        const item = liveItems.find(candidate => validId(candidate) === itemId);
        if (!item)
            return false;

        const saved = reconciledIds();
        const sourceRegion = saved.drawer.includes(itemId) ? "drawer" : "visible";
        const sourceLive = sourceRegion === "drawer" ? drawerItems : visibleItems;
        const sourceIndex = sourceLive.findIndex(candidate => validId(candidate) === itemId);
        if (sourceRegion === destination && sourceIndex >= 0 && sourceIndex < index)
            index--;
        // Include newly discovered IDs only when an actual organization change is committed.
        for (const live of visibleItems) {
            const id = validId(live);
            if (id && !saved.visible.includes(id) && !saved.drawer.includes(id))
                saved.visible.push(id);
        }
        for (const live of drawerItems) {
            const id = validId(live);
            if (id && !saved.visible.includes(id) && !saved.drawer.includes(id))
                saved.drawer.push(id);
        }

        saved.visible = saved.visible.filter(id => id !== itemId);
        saved.drawer = saved.drawer.filter(id => id !== itemId);
        if (destination === "visible")
            saved.visible = insertAtLiveIndex(saved.visible, visibleItems, itemId, index);
        else
            saved.drawer = insertAtLiveIndex(saved.drawer, drawerItems, itemId, index);

        SettingsService.trayVersion = 1;
        SettingsService.trayVisible = saved.visible;
        SettingsService.trayDrawer = saved.drawer;
        reconcile();
        return true;
    }

    onLiveItemsChanged: Qt.callLater(reconcile)

    Connections {
        target: SettingsService
        function onLoadedChanged() {
            root.reconcile();
        }
        function onTrayVisibleChanged() {
            root.reconcile();
        }
        function onTrayDrawerChanged() {
            root.reconcile();
        }
    }

    Component.onCompleted: reconcile()
}
