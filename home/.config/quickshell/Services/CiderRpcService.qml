pragma Singleton
import QtQml
import QtQuick
import QtWebSockets
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string trackTitle: ""
    property string trackArtist: ""
    property string albumName: ""
    property string trackArtUrl: ""
    property bool inFavorites: false
    property bool inLibrary: false
    property bool isOnline: ciderSocket.status === WebSocket.Open
    property bool isPlaying: false
    property real position: 0
    property real duration: 0

    function next() {
        nextProcess.running = true;
    }

    function previous() {
        prevProcess.running = true;
    }

    function pause() {
        pauseProcess.running = true;
    }

    function play() {
        playProcess.running = true;
    }

    function playpause() {
        playpauseProcess.running = true;
    }

    function seek(seconds) {
        seekProcess.command = ["curl", "-s", "-X", "POST", "-H", "Content-Type: application/json", "-d", "{\"position\": " + seconds + "}", "http://localhost:10767/api/v1/playback/seek"];
        seekProcess.running = true;
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
                        var info = response.info;
                        trackTitle = info.name || "";
                        trackArtist = info.artistName || "";
                        albumName = info.albumName || "";
                        trackArtUrl = (info.artwork && info.artwork.url) || "";
                        position = info.currentPlaybackTime || 0;
                        duration = (info.durationInMillis || 0) / 1000;
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
                isOnline = true;
                sendTextMessage("40");
                initialDataProcess.running = true;
            } else if (ciderSocket.status === WebSocket.Error) {
                isOnline = false;
            }
        }
        onTextMessageReceived: function (message) {
            // Socket.IO heart beat msg
            if (message === "2") {
                sendTextMessage("3");
                return;
            }
            if (message.startsWith("42")) {
                var payload = JSON.parse(message.substring(2));
                var eventType = payload[1].type;
                var data = payload[1].data;
                if (eventType === "playbackStatus.playbackTimeDidChange") {
                    position = data.currentPlaybackTime || 0;
                    duration = data.currentPlaybackDuration || 0;
                    isPlaying = data.isPlaying === true;
                }
                if (eventType === "playbackStatus.playbackStateDidChange" || eventType === "playbackStatus.nowPlayingItemDidChange") {
                    var attrs = data.attributes || data;
                    trackTitle = attrs.name || "";
                    trackArtist = attrs.artistName || "";
                    albumName = attrs.albumName || "";
                    trackArtUrl = attrs.artwork ? (attrs.artwork.url || "") : "";
                    duration = (attrs.durationInMillis || 0) / 1000;
                    if (attrs.currentPlaybackTime !== undefined)
                        position = attrs.currentPlaybackTime;

                    isOnline = true;
                }
                if (eventType === "playbackStatus.playbackStateDidChange") {
                    var state = data.state;
                    if (state === "playing")
                        isPlaying = true;
                    else if (state === "paused" || state === "stopped")
                        isPlaying = false;
                }
                if (eventType === "playbackStatus.nowPlayingStatusDidChange") {
                    inFavorites = data.inFavorites === true;
                    inLibrary = data.inLibrary === true;
                }
            }
        }
    }

    Process {
        id: nextProcess

        command: ["curl", "-s", "-X", "POST", "http://localhost:10767/api/v1/playback/next"]
        running: false
    }

    Process {
        id: prevProcess

        command: ["curl", "-s", "-X", "POST", "http://localhost:10767/api/v1/playback/previous"]
        running: false
    }

    Process {
        id: pauseProcess

        command: ["curl", "-s", "-X", "POST", "http://localhost:10767/api/v1/playback/pause"]
        running: false
    }

    Process {
        id: playProcess

        command: ["curl", "-s", "-X", "POST", "http://localhost:10767/api/v1/playback/play"]
        running: false
    }

    Process {
        id: playpauseProcess

        command: ["curl", "-s", "-X", "POST", "http://localhost:10767/api/v1/playback/playpause"]
        running: false
    }

    Process {
        id: seekProcess

        command: ["curl", "-s", "-X", "POST", "-H", "Content-Type: application/json", "-d", "{\"position\": 0}", "http://localhost:10767/api/v1/playback/seek"]
        running: false
    }

    Process {
        id: addToLibraryProcess

        command: ["curl", "-s", "-X", "POST", "http://localhost:10767/api/v1/playback/add-to-library"]
        running: false
    }
}
