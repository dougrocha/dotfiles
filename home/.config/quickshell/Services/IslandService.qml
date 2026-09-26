pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs.Constants

Singleton {
    id: root

    property var lastSeen: ({})

    function changed(key, value) {
        const known = lastSeen[key] !== undefined;
        const differs = lastSeen[key] !== value;
        lastSeen[key] = value;
        return known && differs;
    }

    property string osdMode: ""
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

    property var alerts: []
    readonly property var currentAlert: alerts[0] ?? null
    readonly property bool transientAlertActive: alerts.some(a => a.until > 0)

    function setAlert(id, icon, text, seconds, progress) {
        const alert = {
            id: id,
            glyph: PhosphorIcons[icon] ?? icon,
            text: text,
            until: seconds > 0 ? Date.now() + seconds * 1000 : 0,
            progress: progress
        };
        alerts = [alert, ...alerts.filter(a => a.id !== id)];
    }

    function pushAlert(id: string, icon: string, text: string, seconds: real): void {
        setAlert(id, icon, text, seconds, -1);
    }

    function pushProgress(id: string, icon: string, text: string, progress: real): void {
        setAlert(id, icon, text, 0, Math.max(0, Math.min(1, progress)));
    }

    function clearAlert(id: string): void {
        alerts = alerts.filter(a => a.id !== id);
    }

    Timer {
        interval: 250
        repeat: true
        running: root.transientAlertActive
        onTriggered: {
            const now = Date.now();
            const kept = root.alerts.filter(a => a.until === 0 || a.until > now);
            if (kept.length !== root.alerts.length)
                root.alerts = kept;
        }
    }

    IpcHandler {
        target: "island"

        function push(id: string, icon: string, text: string, seconds: real): void {
            root.pushAlert(id, icon, text, seconds);
        }

        function progress(id: string, icon: string, text: string, value: real): void {
            root.pushProgress(id, icon, text, value);
        }

        function clear(id: string): void {
            root.clearAlert(id);
        }
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

    readonly property var mprisPlayer: MprisService.musicPlayer

    readonly property var liveTrack: {
        const player = mprisPlayer;
        const title = player?.trackTitle || "";
        const artist = player?.trackArtist || "";
        const trackId = String(player?.metadata?.["mpris:trackid"] ?? "");
        return {
            key: title === "" ? "" : [player.dbusName || "", trackId, title, artist].join("|"),
            title: title,
            artist: artist,
            album: player?.trackAlbum || "",
            artUrl: player?.trackArtUrl || ""
        };
    }

    property var track: ({
            key: "",
            title: "",
            artist: "",
            album: "",
            artUrl: ""
        })
    property var pendingTrack: null
    property real lastCommitTime: 0

    readonly property bool musicAvailable: track.title !== ""
    readonly property string trackTitle: track.title
    readonly property string trackArtist: track.artist
    readonly property string albumName: track.album
    readonly property string trackArtUrl: track.artUrl

    onLiveTrackChanged: Qt.callLater(stageTrack)

    function sameTrack(a, b) {
        return a.key === b.key && a.title === b.title && a.artist === b.artist && a.album === b.album && a.artUrl === b.artUrl;
    }

    function stageTrack() {
        const next = liveTrack;
        if (next.title === "") {
            pendingTrack = null;
            artTimeout.stop();
            commitTrack(next);
            return;
        }
        if (sameTrack(next, track)) {
            pendingTrack = null;
            return;
        }
        pendingTrack = next;
        artPreloader.url = next.artUrl;
        artTimeout.restart();
        tryCommitTrack();
    }

    function tryCommitTrack() {
        const next = pendingTrack;
        if (!next)
            return;
        const artSettled = next.artUrl === "" || artPreloader.status === Image.Ready || artPreloader.status === Image.Error;
        if (!artSettled && artTimeout.running)
            return;
        const wait = lastCommitTime + Theme.motion.slow - Date.now();
        if (wait > 0) {
            commitDelay.interval = wait;
            commitDelay.restart();
            return;
        }
        pendingTrack = null;
        artTimeout.stop();
        commitTrack(next);
    }

    function commitTrack(next) {
        if (sameTrack(next, track))
            return;
        track = next;
        lastCommitTime = Date.now();
        announceTrack();
    }

    Image {
        id: artPreloader

        property string url: ""

        source: url
        asynchronous: true
        visible: false
        onStatusChanged: root.tryCommitTrack()
    }

    Timer {
        id: artTimeout
        interval: 1200
        onTriggered: root.tryCommitTrack()
    }

    Timer {
        id: commitDelay
        onTriggered: root.tryCommitTrack()
    }
    readonly property bool isPlaying: mprisPlayer?.isPlaying ?? false
    readonly property bool canSeek: mprisPlayer?.canSeek ?? false
    readonly property real position: mprisPlayer?.position ?? 0

    readonly property real duration: (mprisPlayer && mprisPlayer.lengthSupported) ? mprisPlayer.length : 0

    Timer {
        interval: 250
        repeat: true
        triggeredOnStart: true
        running: Visibilities.musicPanel && root.isPlaying && root.mprisPlayer !== null
        onTriggered: root.mprisPlayer?.positionChanged()
    }

    readonly property bool songNotif: songNotifTimer.running
    readonly property bool scratchpadOpen: root.isInWorkspace("special:scratchpad")
    property string lastTrackKey: ""

    function isInWorkspace(nameOrId) {
        return Hyprland.monitors.values.some(monitor => {
            const state = monitor.lastIpcObject;
            return [state?.activeWorkspace, state?.specialWorkspace].some(workspace => {
                if (!workspace || workspace.id === 0)
                    return false;
                return typeof nameOrId === "number" ? workspace.id === nameOrId : workspace.name === nameOrId;
            });
        });
    }

    onScratchpadOpenChanged: if (scratchpadOpen)
        root.dismissSongNotif()

    Component.onCompleted: {
        Hyprland.refreshMonitors();
        stageTrack();
    }

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name === "activespecial" || event.name === "workspace")
                Hyprland.refreshMonitors();
        }
    }

    Timer {
        id: songNotifTimer
        interval: 5000
    }

    function announceTrack() {
        const key = root.track.key;
        if (key === "" || key === root.lastTrackKey)
            return;
        const known = root.lastTrackKey !== "";
        root.lastTrackKey = key;

        if (!known || Visibilities.musicPanel || root.scratchpadOpen || MprisService.musicPlayerIsBrowser)
            return;
        songNotifTimer.restart();
    }

    function dismissSongNotif() {
        songNotifTimer.stop();
    }

    readonly property bool recording: StreamingService.isRecordingScreen || StreamingService.isScreenshare

    readonly property var activities: {
        const list = [];
        if (osdActive)
            list.push({
                id: "osd",
                priority: 100
            });
        if (currentAlert)
            list.push({
                id: "alert",
                priority: currentAlert.until > 0 ? 95 : 60
            });
        if (recording)
            list.push({
                id: "recording",
                priority: 90
            });
        if (musicAvailable)
            list.push({
                id: "music",
                priority: 50
            });
        return list.sort((a, b) => b.priority - a.priority);
    }

    readonly property string activity: activities[0]?.id ?? "idle"
    readonly property string secondaryActivity: activities.find(a => a.id !== "osd" && a.id !== activity)?.id ?? ""
}
