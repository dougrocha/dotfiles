pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property int duration: 5000

    property var paths: []
    readonly property string path: paths.length > 0 ? paths[0] : ""
    property double remaining: duration
    property double resumedAt: 0
    property bool hoverPaused: false
    property bool dragPaused: false
    readonly property bool paused: hoverPaused || dragPaused

    onPausedChanged: {
        if (paused) {
            if (dismissTimer.running) {
                dismissTimer.stop();
                root.remaining -= Date.now() - root.resumedAt;
            }
        } else if (root.paths.length > 0) {
            root.startCountdown();
        }
    }

    function startCountdown() {
        root.resumedAt = Date.now();
        dismissTimer.interval = Math.max(0, root.remaining);
        dismissTimer.restart();
    }

    function localFileUrl(filePath: string): string {
        return "file://" + filePath.split("/").map(part => encodeURIComponent(part)).join("/");
    }

    function show(filePath: string): void {
        root.showBatch([filePath]);
    }

    function showBatch(filePaths: var): void {
        const sanitized = Array.isArray(filePaths) ? filePaths.filter(path => typeof path === "string" && path !== "") : [];
        if (sanitized.length === 0)
            return;
        root.paths = sanitized;
        root.remaining = root.duration;
        if (!root.paused)
            root.startCountdown();
    }

    function dismiss(): void {
        dismissTimer.stop();
        root.paths = [];
        root.hoverPaused = false;
    }

    Timer {
        id: dismissTimer

        onTriggered: root.dismiss()
    }

    IpcHandler {
        target: "screenshot-toast"

        function notify(path: string): void {
            root.show(path);
        }

        function notifyBatch(encodedPaths: string): void {
            root.showBatch(encodedPaths.split("|").map(path => decodeURIComponent(path)));
        }
    }
}
