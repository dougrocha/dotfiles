import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import qs.Constants
import qs.Components
import qs.Services

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
            color: Colors.tertiary
            font.pixelSize: Fonts.p
            font.family: Fonts.font
            font.bold: true
        }
    }

    Process {
        id: btopProcess

        command: ["launch-or-focus-tui", "btop"]
    }
}
