pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Preferences that outlive a restart; a missing file degrades to the defaults here.
Singleton {
    id: root

    // Not Quickshell.stateDir — that's keyed by a hash of the shell's path, so symlinked launches diverge.
    readonly property string stateHome: Quickshell.env("XDG_STATE_HOME") || (Quickshell.env("HOME") + "/.local/state")
    readonly property string path: stateHome + "/quickshell/settings.json"

    property alias doNotDisturb: adapter.doNotDisturb
    property alias weekStart: adapter.weekStart
    property alias clockFormat: adapter.clockFormat
    property alias trayVersion: traySettings.version
    property alias trayVisible: traySettings.visible
    property alias trayDrawer: traySettings.drawer

    property alias screenshotCaptureMode: screenshotSettings.captureMode
    property alias screenshotTimerDelay: screenshotSettings.timerDelay
    property alias screenshotShowCursor: screenshotSettings.showCursor
    property alias screenshotShowNotification: screenshotSettings.showNotification
    property alias screenshotMicEnabled: screenshotSettings.micEnabled
    property alias screenshotSystemAudioEnabled: screenshotSettings.systemAudioEnabled
    property alias screenshotRememberLastSelection: screenshotSettings.rememberLastSelection
    property alias screenshotSaveDirectory: screenshotSettings.saveDirectory
    property alias screenshotRecentSaveLocations: screenshotSettings.recentSaveLocations
    property alias screenshotMonitors: screenshotSettings.monitors

    // Async load: nothing is saved until loaded, or defaults would overwrite the real file.
    property bool loaded: false

    // Defer past the tick: writing from onAdapterUpdated re-enters the adapter and reverts the next change.
    Timer {
        id: saveTimer
        interval: 0
        onTriggered: settingsFile.writeAdapter()
    }

    FileView {
        id: settingsFile

        path: root.path
        atomicWrites: true
        printErrors: false

        // No watchChanges — we're the only writer; a watcher would reload our own writes.
        onAdapterUpdated: if (root.loaded)
            saveTimer.restart()

        onLoaded: root.loaded = true

        onLoadFailed: error => {
            root.loaded = true;
            // First run only — other read failures leave the file alone.
            if (error === FileViewError.FileNotFound)
                writeAdapter();
        }

        JsonAdapter {
            id: adapter

            property bool doNotDisturb: false

            // 1 = Monday, 0 = Sunday.
            property int weekStart: 1

            property string clockFormat: "h:mmAP"

            property JsonObject tray: JsonObject {
                id: traySettings

                property int version: 0
                property list<string> visible: []
                property list<string> drawer: []
            }

            property JsonObject screenshot: JsonObject {
                id: screenshotSettings

                property string captureMode: "region"
                property int timerDelay: 0
                property bool showCursor: false
                property bool showNotification: true
                property bool micEnabled: false
                property bool systemAudioEnabled: true
                property bool rememberLastSelection: false
                property string saveDirectory: ""
                property list<string> recentSaveLocations: []
                // Keyed by monitor name; each entry may hold local `region` and/or `toolbar` coordinates.
                property var monitors: ({})
            }
        }
    }
}
