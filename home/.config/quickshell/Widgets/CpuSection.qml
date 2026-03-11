import "../Components"
import "../Services"

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets

RowLayout {
    id: root

    WrapperMouseArea {
        id: clickWrapper
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        Layout.rightMargin: 8
        onClicked: {
            btopProcess.running = true;
        }

        Text {
            text: "CPU: " + CpuService.usage + "%"
            color: Theme.yellow
            font.pixelSize: Theme.fontSize
            font.family: Theme.fontFamily
            font.bold: true
        }
    }

    Process {
        id: btopProcess

        command: ["launch-or-focus-tui", "btop"]
    }
}
