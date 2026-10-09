pragma Singleton
pragma ComponentBehavior: Bound

import QtQml
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

Singleton {
    id: root

    property string current: ""
    readonly property bool anyOpen: current !== ""
    onAnyOpenChanged: Hyprland.dispatch(anyOpen ? 'hl.dsp.submap("qs-panel")' : 'hl.dsp.submap("reset")')

    property bool barPinned: false

    property bool barRevealed: true

    signal closeTrayMenus
    signal opened(string name)

    function isOpen(name: string): bool {
        return current === name;
    }

    function open(name: string): void {
        if (current === name)
            return;
        closeTrayMenus();
        current = name;
        opened(name);
    }

    function close(name: string): void {
        if (current === name)
            current = "";
    }

    function toggle(name: string): void {
        current === name ? close(name) : open(name);
    }

    function closeAll(): void {
        current = "";
        closeTrayMenus();
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
        target: "music-panel"
    }

    PanelIpc {
        target: "settings-panel"
    }

    PanelIpc {
        target: "sound-panel"
    }

    PanelIpc {
        target: "bluetooth-panel"
    }

    PanelIpc {
        target: "notification-center"
    }

    IpcHandler {
        target: "panels"
        function closeAll(): void {
            root.closeAll();
        }
    }

    IpcHandler {
        target: "top-bar"
        function pin(): void {
            root.barPinned = true;
        }
        function unpin(): void {
            root.barPinned = false;
        }
        function toggle(): void {
            root.barPinned = !root.barPinned;
        }
    }
}
