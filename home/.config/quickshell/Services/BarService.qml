pragma Singleton

import QtQml
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property bool pinned: _pinned
    readonly property bool revealed: _revealed

    property bool _pinned: false
    property bool _revealed: true

    function wantsReveal(fullscreenOnScreen: bool, hovered: bool): bool {
        return !fullscreenOnScreen || hovered || Visibilities.anyOpen || _pinned;
    }

    function setRevealed(revealed: bool): void {
        _revealed = revealed;
    }

    IpcHandler {
        target: "top-bar"

        function pin(): void {
            root._pinned = true;
        }
        function unpin(): void {
            root._pinned = false;
        }
        function toggle(): void {
            root._pinned = !root._pinned;
        }
    }
}
