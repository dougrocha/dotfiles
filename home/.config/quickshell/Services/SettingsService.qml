pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string stateHome: Quickshell.env("XDG_STATE_HOME") || (Quickshell.env("HOME") + "/.local/state")
    readonly property string path: stateHome + "/quickshell/settings.json"

    property alias doNotDisturb: adapter.doNotDisturb
    property alias weekStart: adapter.weekStart
    property alias clockFormat: adapter.clockFormat
    property alias trayVersion: traySettings.version
    property alias trayOrder: traySettings.order

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

    property bool loaded: false

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

        onAdapterUpdated: if (root.loaded)
            saveTimer.restart()

        onLoaded: root.loaded = true

        onLoadFailed: error => {
            root.loaded = true;

            if (error === FileViewError.FileNotFound)
                writeAdapter();
        }

        JsonAdapter {
            id: adapter

            property bool doNotDisturb: false

            property int weekStart: 1

            property string clockFormat: "h:mmAP"

            property JsonObject tray: JsonObject {
                id: traySettings

                property int version: 0
                property list<string> order: []
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

                property var monitors: ({})
            }
        }
    }
}
