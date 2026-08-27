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
    property double pausedAt: 0

    onHoverPausedChanged: {
        if (hoverPaused) {
            pausedAt = Date.now();
        } else {
            root.shownAt += Date.now() - pausedAt;
        }
    }

    function show(filePath) {
        root.showBatch([filePath]);
    }

    function showBatch(filePaths) {
        const sanitized = Array.isArray(filePaths) ? filePaths.filter(path => typeof path === "string" && path !== "") : [];
        if (sanitized.length === 0)
            return;
        root.paths = sanitized;
        root.shownAt = Date.now();
        root.hoverPaused = false;
    }

    function dismiss() {
        root.paths = [];
        root.hoverPaused = false;
    }

    Timer {
        interval: 100
        repeat: true
        running: root.paths.length > 0 && !root.hoverPaused
        onTriggered: {
            if (Date.now() - root.shownAt > root.duration)
                root.dismiss();
        }
    }
}
