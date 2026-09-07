pragma Singleton
import QtQml
import QtQuick
import QtWebSockets
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property bool isOnline: ciderSocket.status === WebSocket.Open

    property bool inFavorites: false
    property bool inLibrary: false

    onIsOnlineChanged: if (!isOnline) {
        inFavorites = false;
        inLibrary = false;
    }

    function addToLibrary() {
        addToLibraryProcess.running = true;
    }

    Timer {
        id: reconnectTimer

        interval: 5000
        repeat: true
        running: true
        onTriggered: {
            if (ciderSocket.status !== WebSocket.Open && ciderSocket.status !== WebSocket.Connecting) {
                ciderSocket.active = false;
                reconnectDelay.start();
            }
        }
    }

    Timer {
        id: reconnectDelay

        interval: 100
        running: false
        onTriggered: {
            ciderSocket.active = true;
        }
    }

    Process {
        id: initialDataProcess

        command: ["curl", "-s", "http://localhost:10767/api/v1/playback/now-playing"]
        running: false

        stdout: SplitParser {
            onRead: data => {
                try {
                    var response = JSON.parse(data);
                    if (response.status === "ok" && response.info) {
                        inFavorites = response.info.inFavorites === true;
                        inLibrary = response.info.inLibrary === true;
                    }
                } catch (e) {}
            }
        }
    }

    WebSocket {
        id: ciderSocket

        url: "ws://localhost:10767/socket.io/?EIO=4&transport=websocket"
        active: true
        onStatusChanged: {
            if (ciderSocket.status === WebSocket.Open) {
                sendTextMessage("40");
                initialDataProcess.running = true;
            }
        }
        onTextMessageReceived: function (message) {

            if (message === "2") {
                sendTextMessage("3");
                return;
            }
            if (message.startsWith("42")) {
                var payload = JSON.parse(message.substring(2));
                if (payload[1].type === "playbackStatus.nowPlayingStatusDidChange") {
                    var data = payload[1].data;
                    inFavorites = data.inFavorites === true;
                    inLibrary = data.inLibrary === true;
                }
            }
        }
    }

    Process {
        id: addToLibraryProcess

        command: ["curl", "-s", "-X", "POST", "http://localhost:10767/api/v1/playback/add-to-library"]
        running: false
    }
}
