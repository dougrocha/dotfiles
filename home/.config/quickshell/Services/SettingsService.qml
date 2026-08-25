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
        }
    }
}
