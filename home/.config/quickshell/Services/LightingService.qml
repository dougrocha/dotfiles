pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property bool on: _committedState !== "off"
    readonly property bool busy: _wanted !== ""
    readonly property bool shownOn: busy ? _wanted === "on" : on
    readonly property bool failed: _failed && !busy

    property string _committedState: ""
    property string _wanted: ""
    property bool _failed: false
    property bool _started: false

    // set-lighting rolls the saved state back when applying fails, so after a
    // failure shownOn is the old state and toggling retries the new one.
    function toggle(): void {
        root._wanted = root.shownOn ? "off" : "on";
        root._reconcile();
    }

    function refresh(): void {
        stateFile.reload();
    }

    function _fail(reason: string): void {
        console.warn("set-lighting failed:", reason);
        IslandService.pushAlert("lighting", "warningCircle", "Case lights failed", 4);
    }

    function _reconcile() {
        if (apply.running || root._wanted === "")
            return;
        root._failed = false;
        root._started = false;
        apply.command = ["set-lighting", root._wanted];
        apply.running = true;
    }

    FileView {
        id: stateFile

        path: Quickshell.env("HOME") + "/.local/state/lighting/current"
        watchChanges: true
        printErrors: false

        onFileChanged: reload()
        onLoaded: root._committedState = text().trim()
        onLoadFailed: error => {
            if (error === FileViewError.FileNotFound)
                root._committedState = "";
        }
    }

    Process {
        id: apply

        stderr: StdioCollector {
            id: applyErrors
        }

        onStarted: root._started = true

        // A command that can't start never emits exited; running just drops
        // back to false. Give up instead of pulsing forever.
        onRunningChanged: {
            if (apply.running || root._started || root._wanted === "")
                return;
            root._wanted = "";
            root._failed = true;
            root._fail("could not start " + apply.command[0]);
        }

        onExited: code => {
            const ran = apply.command[1];
            if (root._wanted === ran)
                root._wanted = "";
            root._failed = code !== 0 && root._wanted === "";
            stateFile.reload();
            if (root._failed)
                root._fail(applyErrors.text.trim());
            root._reconcile();
        }
    }
}
