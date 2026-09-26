pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

Singleton {
    id: root

    readonly property var screenState: {
        let foundStreaming = false;
        let foundRecording = false;
        let apps = [];
        for (const node of Pipewire.nodes.values) {
            const props = node?.properties;
            if (!props)
                continue;

            const mediaName = props["media.name"] || "";
            const appName = props["application.name"] || "";
            const clientName = props["client.name"] || "";
            const binary = props["application.process.binary"] || "";

            if (binary.includes("gpu-screen-recorder"))
                foundRecording = true;

            if (mediaName.includes("xdph-streaming"))
                foundStreaming = true;

            if (mediaName.includes("webrtc")) {
                const appToAdd = appName || clientName || "Discord";
                if (!apps.includes(appToAdd))
                    apps.push(appToAdd);
            }

            if (appName && !appName.includes("input")) {
                if (mediaName.includes("xdph") || mediaName.includes("Screen") || mediaName.includes("screen") || mediaName.includes("RecordStream")) {
                    if (!apps.includes(appName))
                        apps.push(appName);
                }
            }
        }
        return {
            recording: foundRecording,
            streaming: foundStreaming,
            apps: apps
        };
    }

    readonly property bool isRecordingScreen: screenState.recording
    readonly property bool isScreenshare: screenState.streaming
    readonly property list<string> screenAccessApps: screenState.apps

    function stopRecording() {
        toggleRecordingProcess.running = true;
    }

    PwObjectTracker {
        objects: Pipewire.nodes.values
    }

    Process {
        id: toggleRecordingProcess

        command: ["toggle-recording"]
        running: false
    }
}
