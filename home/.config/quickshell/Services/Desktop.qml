pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland

Singleton {
    id: root

    readonly property string primaryMonitor: "DP-1"
    readonly property var primaryScreen: Quickshell.screens.find(s => s.name === primaryMonitor) ?? Quickshell.screens[0] ?? null
    readonly property var primaryScreens: primaryScreen ? [primaryScreen] : []

    readonly property int _fullscreenExclusive: 2
    readonly property list<string> _refreshEvents: ["workspace", "activespecial", "focusedmon", "fullscreen", "openwindow", "closewindow"]

    function focusedScreen(): var {
        return Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? root.primaryScreen;
    }

    function fullscreenOn(screen: var): bool {
        const workspace = Hyprland.monitorFor(screen)?.activeWorkspace;
        if (!workspace?.hasFullscreen)
            return false;
        const active = Hyprland.activeToplevel;
        return active?.workspace === workspace && (active.lastIpcObject?.fullscreen ?? 0) === root._fullscreenExclusive;
    }

    function openSpecial(monitor: var): string {
        return monitor?.lastIpcObject?.specialWorkspace?.name ?? "";
    }

    function isShowing(name: string): bool {
        return Hyprland.monitors.values.some(monitor => {
            const state = monitor.lastIpcObject;
            return [state?.activeWorkspace, state?.specialWorkspace].some(workspace => workspace && workspace.id !== 0 && workspace.name === name);
        });
    }

    function refresh(): void {
        Hyprland.refreshMonitors();
        Hyprland.refreshToplevels();
    }

    Component.onCompleted: refresh()

    Connections {
        target: Hyprland

        function onRawEvent(event) {
            if (root._refreshEvents.includes(event.name))
                root.refresh();
        }
    }
}
