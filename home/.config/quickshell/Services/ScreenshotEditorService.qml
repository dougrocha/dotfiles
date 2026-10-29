pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string path: _path

    property string _path: ""

    function open(filePath: string): void {
        root._path = filePath;
    }

    function close(): void {
        root._path = "";
    }

    IpcHandler {
        target: "screenshot-editor"

        function open(path: string): void {
            root.open(path);
        }

        function close(): void {
            root.close();
        }
    }
}
