import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
pragma Singleton

Singleton {
    id: root

    property bool isStreaming: false

    function updateStreaming() {
        if (!Pipewire.ready || !Pipewire.nodes || !Pipewire.nodes.values)
            return ;

        let foundStreaming = false;
        let nodesList = Pipewire.nodes.values;
        for (let i = 0; i < nodesList.length; i++) {
            let node = nodesList[i];
            if (!node)
                continue;

            if (node.properties && node.properties["media.name"]) {
                if (node.properties["media.name"].includes("xdph-streaming")) {
                    foundStreaming = true;
                    break;
                }
            }
        }
        isStreaming = foundStreaming;
    }

    Component.onCompleted: {
        updateStreaming();
    }

    PwObjectTracker {
        objects: Pipewire.nodes.values
    }

    Connections {
        function onReadyChanged() {
            if (Pipewire.ready)
                root.updateStreaming();

        }

        target: Pipewire
    }

    Connections {
        function onObjectInsertedPost() {
            root.updateStreaming();
        }

        function onObjectRemovedPost() {
            root.updateStreaming();
        }

        target: Pipewire.nodes
    }

}
