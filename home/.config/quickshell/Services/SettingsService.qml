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
    property alias tray: traySettings
    property alias screenshot: screenshotSettings
    property alias audio: audioSettings

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

            property JsonObject audio: JsonObject {
                id: audioSettings

                property JsonObject outputs: JsonObject {
                    id: audioOutputSettings

                    property list<string> hidden: []
                }

                property JsonObject inputs: JsonObject {
                    id: audioInputSettings

                    property list<string> hidden: []
                }
            }
        }
    }
}
