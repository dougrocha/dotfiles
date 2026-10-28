pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property real usage: 0
    property real _lastCpuIdle: 0
    property real _lastCpuTotal: 0

    FileView {
        id: cpuFile

        path: "/proc/stat"
        printErrors: false

        onLoaded: {
            const data = text().split("\n")[0];
            if (!data || !data.startsWith("cpu "))
                return;

            const parts = data.trim().split(/\s+/);
            if (parts.length < 8)
                return;

            const times = parts.slice(1, 9).map(value => parseInt(value) || 0);
            const total = times.reduce((sum, value) => sum + value, 0);
            const idleTime = times[3] + times[4];
            if (_lastCpuTotal > 0) {
                const totalDiff = total - _lastCpuTotal;
                const idleDiff = idleTime - _lastCpuIdle;
                if (totalDiff > 0)
                    usage = Math.round(((totalDiff - idleDiff) / totalDiff) * 100);
            }
            _lastCpuTotal = total;
            _lastCpuIdle = idleTime;
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: cpuFile.reload()
    }
}
