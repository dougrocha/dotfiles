import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

Singleton {
    id: root

    property real usage: 0
    property var _lastCpuIdle: 0
    property var _lastCpuTotal: 0

    Process {
        id: cpuProc

        command: ["cat", "/proc/stat"]
        running: false
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0)
                console.warn("CpuService: Process exited with code", exitCode);

        }

        stdout: SplitParser {
            onRead: (data) => {
                if (!data || !data.startsWith("cpu "))
                    return ;

                var parts = data.trim().split(/\s+/);
                if (parts.length < 8)
                    return ;

                var user = parseInt(parts[1]) || 0;
                var nice = parseInt(parts[2]) || 0;
                var system = parseInt(parts[3]) || 0;
                var idle = parseInt(parts[4]) || 0;
                var iowait = parseInt(parts[5]) || 0;
                var irq = parseInt(parts[6]) || 0;
                var softirq = parseInt(parts[7]) || 0;
                var steal = parseInt(parts[8]) || 0;
                var guest = parseInt(parts[9]) || 0;
                var guest_nice = parseInt(parts[10]) || 0;
                var total = user + nice + system + idle + iowait + irq + softirq + steal;
                var idleTime = idle + iowait;
                if (_lastCpuTotal > 0) {
                    var totalDiff = total - _lastCpuTotal;
                    var idleDiff = idleTime - _lastCpuIdle;
                    if (totalDiff > 0) {
                        var activeDiff = totalDiff - idleDiff;
                        usage = Math.round((activeDiff / totalDiff) * 100);
                    }
                }
                _lastCpuTotal = total;
                _lastCpuIdle = idleTime;
            }
        }

    }

    Timer {
        interval: 2000 // Update every 2 seconds
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: cpuProc.running = true
    }

}
