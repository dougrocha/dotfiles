pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property int duration: 5000

    property var paths: []
    readonly property string path: paths.length > 0 ? paths[0] : ""
    property double shownAt: 0
    property bool hoverPaused: false
    property bool dragPaused: false
    readonly property bool paused: hoverPaused || dragPaused
    property double pausedAt: 0

    onPausedChanged: {
        if (paused) {
            pausedAt = Date.now();
        } else if (root.paths.length > 0) {
            root.shownAt += Date.now() - pausedAt;
        }
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
        root.shownAt = Date.now();
        root.pausedAt = root.paused ? root.shownAt : 0;
    }

    function dismiss(): void {
        root.paths = [];
        root.hoverPaused = false;
    }

    Timer {
        interval: 100
        repeat: true
        running: root.paths.length > 0 && !root.paused
        onTriggered: {
            if (Date.now() - root.shownAt > root.duration)
                root.dismiss();
        }
    }
}
