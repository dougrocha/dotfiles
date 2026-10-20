pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string state: "idle"
    property real level: 0
    readonly property bool recording: state === "recording"
    readonly property bool transcribing: state === "transcribing"
    readonly property bool active: recording || transcribing

    function levelFromPeak(peak) {
        if (peak <= 0)
            return 0;
        return Math.max(0, Math.min(1, (20 * Math.log10(peak) + 50) / 44));
    }

    onRecordingChanged: if (!recording)
        level = 0

    Process {
        id: statusFollow

        running: true
        command: ["voxtype", "status", "--follow", "--format", "json"]
        stdout: SplitParser {
            onRead: data => {
                try {
                    root.state = JSON.parse(data).class ?? "idle";
                } catch (error) {}
            }
        }
        onExited: {
            root.state = "idle";
            reconnect.start();
        }
    }

    Timer {
        id: reconnect

        interval: 5000
        onTriggered: statusFollow.running = true
    }

    Process {
        running: root.recording
        command: ["voxtype-audio-bridge"]
        stdout: SplitParser {
            onRead: data => {
                let frame;
                try {
                    frame = JSON.parse(data);
                } catch (error) {
                    return;
                }
                if (typeof frame.peak === "number")
                    root.level = root.levelFromPeak(frame.peak);
            }
        }
    }
}
