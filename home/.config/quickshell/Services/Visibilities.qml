pragma Singleton
pragma ComponentBehavior: Bound

import QtQml
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property var names: ({
            settings: "settings-panel",
            sound: "sound-panel",
            bluetooth: "bluetooth-panel",
            notifications: "notification-center",
            music: "music-panel"
        })
    readonly property bool anyOpen: _current !== ""
    readonly property var trayMenu: _trayMenu

    readonly property string _trayMenuSlot: "tray-menu"
    property string _current: ""
    property var _trayMenu: null

    function isOpen(name: string): bool {
        return _current === name;
    }

    function open(name: string): void {
        if (!Object.values(names).includes(name)) {
            console.warn("Visibilities: unknown panel", name);
            return;
        }
        if (_current !== name)
            _set(name);
    }

    function close(name: string): void {
        if (_current === name)
            _set("");
    }

    function toggle(name: string): void {
        isOpen(name) ? close(name) : open(name);
    }

    function dismissAll(): void {
        _set("");
    }

    function toggleTrayMenu(screen: string, itemId: string): void {
        if (isTrayMenuOpen(screen, itemId)) {
            _set("");
            return;
        }
        _trayMenu = {
            screen: screen,
            itemId: itemId
        };
        _set(_trayMenuSlot);
    }

    function isTrayMenuOpen(screen: string, itemId: string): bool {
        return trayMenu !== null && trayMenu.screen === screen && trayMenu.itemId === itemId;
    }

    function closeTrayMenu(): void {
        if (_current === _trayMenuSlot)
            _set("");
    }

    function _set(slot: string): void {
        const wasOpen = _current !== "";
        _current = slot;
        if (slot !== _trayMenuSlot)
            _trayMenu = null;
        if (wasOpen !== (slot !== ""))
            Desktop.setSubmap(slot !== "" ? "qs-panel" : "reset");
    }

    component PanelIpc: IpcHandler {
        function open(): void {
            root.open(target);
        }
        function hide(): void {
            root.close(target);
        }
        function toggle(): void {
            root.toggle(target);
        }
    }

    PanelIpc {
        target: root.names.settings
    }

    PanelIpc {
        target: root.names.sound
    }

    PanelIpc {
        target: root.names.bluetooth
    }

    PanelIpc {
        target: root.names.notifications
    }

    PanelIpc {
        target: root.names.music
    }

    IpcHandler {
        target: "panels"

        function closeAll(): void {
            root.dismissAll();
        }
    }
}
