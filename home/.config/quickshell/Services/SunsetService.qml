pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool active: false

    function refresh(): void {
        statusProcess.running = true;
    }

    function toggle(): void {
        toggleProcess.running = true;
    }

    Component.onCompleted: refresh()

    Process {
        id: statusProcess

        command: ["systemctl", "--user", "is-active", "hyprsunset.service"]
        stdout: SplitParser {
            onRead: data => {
                root.active = data.trim() === "active";
            }
        }
    }

    Process {
        id: toggleProcess

        command: ["toggle-sunset"]
        onExited: statusProcess.running = true
    }
}
