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

    function pushAlert(id: string, icon: string, text: string, seconds: real): void {
        const alert = {
            id: id,
            glyph: PhosphorIcons[icon] ?? icon,
            text: text,
            until: seconds > 0 ? Date.now() + seconds * 1000 : 0
        };
        alerts = [alert, ...alerts.filter(a => a.id !== id)];
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
    readonly property bool musicAvailable: (mprisPlayer?.trackTitle || "") !== ""
    readonly property string trackTitle: mprisPlayer?.trackTitle || ""
    readonly property string trackArtist: mprisPlayer?.trackArtist || ""
    readonly property string albumName: mprisPlayer?.trackAlbum || ""
    readonly property string trackArtUrl: mprisPlayer?.trackArtUrl || ""
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

    Component.onCompleted: Hyprland.refreshMonitors()

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
