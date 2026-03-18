pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool active: false

    function refresh() {
        statusProcess.running = true;
    }

    function toggle() {
        toggleProcess.running = true;
    }

    Process {
        id: statusProcess

        command: ["systemctl", "--user", "is-active", "hypridle.service"]
        stdout: SplitParser {
            onRead: data => {
                root.active = data.trim() === "active";
            }
        }
    }

    Process {
        id: toggleProcess

        command: ["toggle-idle"]
        onExited: (exitCode, exitStatus) => {
            statusProcess.running = true;
        }
    }
}
