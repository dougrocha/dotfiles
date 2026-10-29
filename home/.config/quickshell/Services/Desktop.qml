pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs.Constants
import "ScreenshotGeometry.js" as Geometry

Singleton {
    id: root

    readonly property string _primaryMonitor: "DP-1"
    readonly property var primaryScreen: screenNamed(_primaryMonitor) ?? Quickshell.screens[0] ?? null
    readonly property var primaryScreens: primaryScreen ? [primaryScreen] : []

    readonly property int _fullscreenExclusive: 2
    readonly property string _fullscreenTag: "qs-fullscreen"
    readonly property list<string> _browserClasses: ["zen"]
    property var _fullscreen: null
    readonly property var _refreshEvents: ({
            workspace: true,
            activespecial: true,
            focusedmon: true,
            fullscreen: true,
            openwindow: true,
            closewindow: true
        })

    function screenNamed(name: string): var {
        return Quickshell.screens.find(s => s.name === name) ?? null;
    }

    function focusedScreen(): var {
        return root.screenNamed(Hyprland.focusedMonitor?.name ?? "") ?? root.primaryScreen;
    }

    function fullscreenKind(screen: var): string {
        const workspace = Hyprland.monitorFor(screen)?.activeWorkspace;
        if (!workspace)
            return "none";
        if (workspace.hasFullscreen && Hyprland.toplevels.values.some(t => t.workspace === workspace && (t.lastIpcObject?.fullscreen ?? 0) === root._fullscreenExclusive))
            return "exclusive";
        if (root._fullscreen?.screen === screen.name && Hyprland.toplevels.values.some(t => "0x" + t.address === root._fullscreen.address && t.workspace === workspace))
            return "windowed";
        return "none";
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
        const window = root._windowArg(active.address);
        Hyprland.dispatch(`hl.dsp.window.tag({ tag = "+${root._fullscreenTag}", ${window} })`);
        Hyprland.dispatch(`hl.dsp.window.float({ action = "set", ${window} })`);
        root._fullscreen = {
            address: active.address,
            screen: root.focusedScreen()?.name ?? "",
            floating: active.floating,
            at: active.at,
            size: active.size
        };
    }

    function placeFullscreen(screen: var, barShown: bool): void {
        if (!root._fullscreen || !screen || root._fullscreen.screen !== screen.name)
            return;
        const top = barShown ? Theme.topBarCompactHeight : 0;
        root._placeWindow(root._fullscreen.address, screen.x, screen.y + top, screen.width, screen.height - top);
    }

    function activeWorkspaceId(screen: var): int {
        return Hyprland.monitorFor(screen)?.activeWorkspace?.id ?? -1;
    }

    function openSpecial(screen: var): string {
        return Hyprland.monitorFor(screen)?.lastIpcObject?.specialWorkspace?.name ?? "";
    }

    function focusWorkspace(id: int): void {
        Hyprland.dispatch(`hl.dsp.focus({ workspace = ${id} })`);
    }

    function focusNamedWorkspace(name: string): void {
        Hyprland.dispatch(`hl.dsp.focus({ workspace = ${JSON.stringify("name:" + name)} })`);
    }

    function toggleSpecial(name: string): void {
        Hyprland.dispatch(`hl.dsp.workspace.toggle_special(${JSON.stringify(name)})`);
    }

    function setSubmap(name: string): void {
        Hyprland.dispatch(`hl.dsp.submap(${JSON.stringify(name)})`);
    }

    function visibleWindows(): var {
        return Geometry.visibleWindows(Hyprland.toplevels.values, Hyprland.monitors.values);
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

    function _placeWindow(address, x, y, width, height) {
        const window = root._windowArg(address);
        Hyprland.dispatch(`hl.dsp.window.resize({ x = ${width}, y = ${height}, ${window} })`);
        Hyprland.dispatch(`hl.dsp.window.move({ x = ${x}, y = ${y}, ${window} })`);
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
        root._placeWindow(saved.address, saved.at[0], saved.at[1], saved.size[0], saved.size[1]);
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
            if (root._refreshEvents[event.name])
                refreshTimer.restart();
        }
    }

    Timer {
        id: refreshTimer
        interval: 16
        onTriggered: root.refresh()
    }

    IpcHandler {
        target: "desktop"

        function toggleFullscreen(): void {
            root.toggleFullscreen();
        }
    }
}
