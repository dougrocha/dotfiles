pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property int duration: 5000

    property string path: ""
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
        root.path = filePath;
        root.shownAt = Date.now();
        root.hoverPaused = false;
    }

    function dismiss() {
        root.path = "";
        root.hoverPaused = false;
    }

    Timer {
        interval: 100
        repeat: true
        running: root.path !== "" && !root.hoverPaused
        onTriggered: {
            if (Date.now() - root.shownAt > root.duration)
                root.dismiss();
        }
    }
}
