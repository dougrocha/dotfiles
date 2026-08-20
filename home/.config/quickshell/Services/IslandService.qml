pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root

    // A (re)bound audio node replays its current state, so the first value per key is a baseline, not a user action.
    property var lastSeen: ({})

    function changed(key, value) {
        const known = lastSeen[key] !== undefined;
        const differs = lastSeen[key] !== value;
        lastSeen[key] = value;
        return known && differs;
    }

    property string osdMode: "" // "volume" | "mic"
    property real osdLevel: 0
    property bool osdMuted: false
    property string osdLabel: ""
    readonly property bool osdActive: osdTimer.running

    function flashOsd(mode, level, muted, label) {
        osdMode = mode;
        osdLevel = level ?? 0;
        osdMuted = !!muted;
        osdLabel = label ?? "";
        osdTimer.restart();
    }

    Timer {
        id: osdTimer
        interval: 1500
    }

    Connections {
        target: AudioService.sink?.audio ?? null
        function onVolumeChanged() {
            if (root.changed("volume", AudioService.volume) && !Visibilities.soundPanel)
                root.flashOsd("volume", AudioService.volume, AudioService.muted);
        }
        function onMutedChanged() {
            if (root.changed("muted", AudioService.muted) && !Visibilities.soundPanel)
                root.flashOsd("volume", AudioService.volume, AudioService.muted);
        }
    }

    Connections {
        target: AudioService.source?.audio ?? null
        function onMutedChanged() {
            if (root.changed("sourceMuted", AudioService.sourceMuted) && !Visibilities.soundPanel)
                root.flashOsd("mic", AudioService.sourceVolume, AudioService.sourceMuted, "Live");
        }
    }

    readonly property bool usingCider: CiderRpcService.isOnline && CiderRpcService.trackTitle !== ""
    readonly property var mprisPlayer: MprisService.musicPlayer
    readonly property bool musicAvailable: usingCider || ((mprisPlayer?.trackTitle || "") !== "")
    readonly property string trackTitle: usingCider ? CiderRpcService.trackTitle : (mprisPlayer?.trackTitle || "")
    readonly property string trackArtist: usingCider ? CiderRpcService.trackArtist : (mprisPlayer?.trackArtist || "")
    readonly property string trackArtUrl: usingCider ? CiderRpcService.trackArtUrl : (mprisPlayer?.trackArtUrl || "")
    readonly property bool isPlaying: usingCider ? CiderRpcService.isPlaying : (mprisPlayer?.isPlaying ?? false)

    readonly property bool songNotif: songNotifTimer.running
    property string lastTrackKey: ""

    Timer {
        id: songNotifTimer
        interval: 5000
    }

    onTrackTitleChanged: root._checkSongChange()
    onTrackArtistChanged: root._checkSongChange()

    function _checkSongChange() {
        if (!root.trackTitle)
            return;
        const key = root.trackTitle + root.trackArtist;
        if (key === root.lastTrackKey)
            return;
        const known = root.lastTrackKey !== "";
        root.lastTrackKey = key;

        // What was already playing at startup, and tracks passing while the panel is open, still count as seen.
        if (!known || Visibilities.musicPanel)
            return;
        songNotifTimer.restart();
    }

    function dismissSongNotif() {
        songNotifTimer.stop();
    }

    readonly property bool recording: StreamingService.isRecordingScreen || StreamingService.isScreenshare

    // A transient flash outranks everything; recording outranks ambient music.
    readonly property string activity: osdActive ? "osd" : recording ? "recording" : musicAvailable ? "music" : "idle"
}
