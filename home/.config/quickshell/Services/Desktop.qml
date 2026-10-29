pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs.Constants

Singleton {
    id: root

    readonly property string primaryMonitor: "DP-1"
    readonly property var primaryScreen: Quickshell.screens.find(s => s.name === primaryMonitor) ?? Quickshell.screens[0] ?? null
    readonly property var primaryScreens: primaryScreen ? [primaryScreen] : []

    readonly property int _fullscreenExclusive: 2
    readonly property string _fullscreenTag: "qs-fullscreen"
    readonly property list<string> _browserClasses: ["zen"]
    property var _fullscreen: null
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

    function toggleFullscreen(): void {
        const active = Hyprland.activeToplevel?.lastIpcObject;
        if (!active?.address)
            return;
        if (root._fullscreen?.address === active.address) {
            root._leaveFullscreen();
            return;
        }
        if (!root._isBrowser(active.class) || active.fullscreen !== 0) {
            Hyprland.dispatch(`hl.dsp.window.fullscreen({ mode = "fullscreen" })`);
            return;
        }
        if (root._fullscreen)
            root._leaveFullscreen();
        root._fullscreen = {
            address: active.address,
            screen: root.focusedScreen()?.name ?? "",
            floating: active.floating,
            at: active.at,
            size: active.size
        };
        const window = root._windowArg(active.address);
        Hyprland.dispatch(`hl.dsp.window.tag({ tag = "+${root._fullscreenTag}", ${window} })`);
        Hyprland.dispatch(`hl.dsp.window.float({ action = "set", ${window} })`);
        root.placeFullscreen(root.focusedScreen(), false);
    }

    function fullscreenWindowOn(screen: var): bool {
        if (!root._fullscreen || root._fullscreen.screen !== screen?.name)
            return false;
        const workspace = Hyprland.monitorFor(screen)?.activeWorkspace;
        return Hyprland.toplevels.values.some(t => t.lastIpcObject?.address === root._fullscreen.address && t.workspace === workspace);
    }

    function placeFullscreen(screen: var, barShown: bool): void {
        if (!root._fullscreen || !screen || root._fullscreen.screen !== screen.name)
            return;
        const top = barShown ? Theme.topBarCompactHeight : 0;
        const window = root._windowArg(root._fullscreen.address);
        Hyprland.dispatch(`hl.dsp.window.resize({ x = ${screen.width}, y = ${screen.height - top}, ${window} })`);
        Hyprland.dispatch(`hl.dsp.window.move({ x = ${screen.x}, y = ${screen.y + top}, ${window} })`);
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

    function _isBrowser(windowClass) {
        if (root._browserClasses.includes(windowClass))
            return true;
        return (DesktopEntries.heuristicLookup(windowClass)?.categories ?? []).includes("WebBrowser");
    }

    function _windowArg(address) {
        return `window = "address:${address}"`;
    }

    function _leaveFullscreen() {
        const saved = root._fullscreen;
        root._fullscreen = null;
        const window = root._windowArg(saved.address);
        Hyprland.dispatch(`hl.dsp.window.tag({ tag = "-${root._fullscreenTag}", ${window} })`);
        if (!saved.floating) {
            Hyprland.dispatch(`hl.dsp.window.float({ action = "unset", ${window} })`);
            return;
        }
        Hyprland.dispatch(`hl.dsp.window.resize({ x = ${saved.size[0]}, y = ${saved.size[1]}, ${window} })`);
        Hyprland.dispatch(`hl.dsp.window.move({ x = ${saved.at[0]}, y = ${saved.at[1]}, ${window} })`);
    }

    function refresh(): void {
        Hyprland.refreshMonitors();
        Hyprland.refreshToplevels();
    }

    Component.onCompleted: refresh()

    Connections {
        target: Hyprland

        function onRawEvent(event) {
            if (event.name === "closewindow" && root._fullscreen?.address === "0x" + event.data)
                root._fullscreen = null;
            if (root._refreshEvents.includes(event.name))
                root.refresh();
        }
    }

    IpcHandler {
        target: "desktop"

        function toggleFullscreen(): void {
            root.toggleFullscreen();
        }
    }
}
