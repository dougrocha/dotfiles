pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

Singleton {
    id: root

    property bool isRecordingScreen: false
    property bool isScreenshare: false
    property list<string> screenAccessApps: []

    function updateScreenshare() {
        if (!Pipewire.ready || !Pipewire.nodes || !Pipewire.nodes.values)
            return;

        let foundStreaming = false;
        let foundRecording = false;
        let apps = [];
        let nodesList = Pipewire.nodes.values;
        for (let i = 0; i < nodesList.length; i++) {
            let node = nodesList[i];
            if (!node)
                continue;

            if (node.properties) {
                const mediaName = node.properties["media.name"] || "";
                const appName = node.properties["application.name"] || "";
                const clientName = node.properties["client.name"] || "";
                const binary = node.properties["application.process.binary"] || "";

                if (binary.includes("gpu-screen-recorder"))
                    foundRecording = true;

                if (mediaName.includes("xdph-streaming")) {
                    foundStreaming = true;
                }

                if (mediaName.includes("webrtc")) {
                    const appToAdd = appName || clientName || "Discord";
                    if (!apps.includes(appToAdd)) {
                        apps.push(appToAdd);
                    }
                }

                if (appName && !appName.includes("input")) {
                    if (mediaName.includes("xdph") || mediaName.includes("Screen") || mediaName.includes("screen") || mediaName.includes("RecordStream")) {
                        if (!apps.includes(appName)) {
                            apps.push(appName);
                        }
                    }
                }
            }
        }
        isScreenshare = foundStreaming;
        isRecordingScreen = foundRecording;
        screenAccessApps = apps;
    }

    function stopRecording() {
        toggleRecordingProcess.running = true;
    }

    Component.onCompleted: {
        updateScreenshare();
    }

    PwObjectTracker {
        objects: Pipewire.nodes.values
    }

    Connections {
        function onReadyChanged() {
            if (Pipewire.ready)
                root.updateScreenshare();
        }

        target: Pipewire
    }

    Connections {
        function onObjectInsertedPost() {
            root.updateScreenshare();
        }

        function onObjectRemovedPost() {
            root.updateScreenshare();
        }

        target: Pipewire.nodes
    }

    Process {
        id: toggleRecordingProcess

        command: ["toggle-recording"]
        running: false
    }
}
