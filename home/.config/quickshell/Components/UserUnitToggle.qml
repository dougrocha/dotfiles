import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property string unit: ""
    property var toggleCommand: []
    property bool active: false

    function refresh(): void {
        statusProcess.running = true;
    }

    function toggle(): void {
        toggleProcess.running = true;
    }

    Component.onCompleted: refresh()

    property Process _status: Process {
        id: statusProcess

        command: ["systemctl", "--user", "is-active", root.unit]
        stdout: SplitParser {
            onRead: data => {
                root.active = data.trim() === "active";
            }
        }
    }

    property Process _toggle: Process {
        id: toggleProcess

        command: root.toggleCommand
        onExited: root.refresh()
    }
}
