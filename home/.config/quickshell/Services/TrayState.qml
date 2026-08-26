pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.SystemTray

Singleton {
    id: root

    readonly property var liveItems: SystemTray.items.values
    property var items: []

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

    function reconcile() {
        if (!SettingsService.loaded)
            return;

        const saved = cleanIds(SettingsService.trayOrder, {});
        const byId = {};
        const anonymous = [];
        for (const item of liveItems) {
            const id = validId(item);
            if (id && !byId[id])
                byId[id] = item;
            else if (!id)
                anonymous.push(item);
        }

        const ordered = [];
        const placed = {};
        for (const id of saved) {
            if (byId[id]) {
                ordered.push(byId[id]);
                placed[id] = true;
            }
        }
        for (const item of liveItems) {
            const id = validId(item);
            if (id && !placed[id]) {
                ordered.push(item);
                placed[id] = true;
            }
        }
        ordered.push(...anonymous);
        items = ordered;
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

    function move(itemId, index) {
        itemId = typeof itemId === "string" ? itemId.trim() : "";
        if (!itemId)
            return false;

        const item = liveItems.find(candidate => validId(candidate) === itemId);
        if (!item)
            return false;

        const saved = cleanIds(SettingsService.trayOrder, {});
        const sourceIndex = items.findIndex(candidate => validId(candidate) === itemId);
        if (sourceIndex >= 0 && sourceIndex < index)
            index--;
        for (const live of items) {
            const id = validId(live);
            if (id && !saved.includes(id))
                saved.push(id);
        }

        const filtered = saved.filter(id => id !== itemId);
        const reordered = insertAtLiveIndex(filtered, items, itemId, index);

        SettingsService.trayVersion = 1;
        SettingsService.trayOrder = reordered;
        reconcile();
        return true;
    }

    onLiveItemsChanged: Qt.callLater(reconcile)

    Connections {
        target: SettingsService
        function onLoadedChanged() {
            root.reconcile();
        }
        function onTrayOrderChanged() {
            root.reconcile();
        }
    }

    Component.onCompleted: reconcile()
}
