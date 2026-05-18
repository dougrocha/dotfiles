import QtQuick
import Quickshell
import Quickshell.Io
import qs.Constants
import qs.Components
import qs.Services

Item {
    id: root
    implicitWidth: icon.implicitWidth
    implicitHeight: Theme.topBarHeight

    Text {
        id: icon
        anchors.centerIn: parent
        text: PhosphorIcons.cpu
        color: CpuService.usage > 80 ? Colors.error : Colors.on_surface_variant
        font.pixelSize: 16
        font.family: Fonts.phosphorFont
        Behavior on color {
            ColorAnimation {
                duration: 180
            }
        }
    }

    HoverHandler {
        id: hover
    }

    TapHandler {
        cursorShape: Qt.PointingHandCursor
        onTapped: proc.running = true
    }

    Tooltip {
        targetItem: root
        text: "CPU  " + CpuService.usage + "%"
        hovered: hover.hovered
    }

    Process {
        id: proc
        command: ["launch-or-focus-tui", "btop"]
    }
}
