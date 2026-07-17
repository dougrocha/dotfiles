import QtQuick
import Quickshell
import qs.Constants
import qs.Services

Item {
    id: root

    implicitWidth: settingsIcon.implicitWidth
    implicitHeight: Theme.topBarHeight

    Text {
        id: settingsIcon
        anchors.centerIn: parent
        text: PhosphorIcons.gear
        color: Visibilities.settingsPanel ? Colors.on_surface : (hoverHandler.hovered ? Colors.on_surface : Colors.on_surface_variant)
        font.pixelSize: Fonts.p
        font.family: Fonts.phosphorFont
        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }
    }

    HoverHandler {
        id: hoverHandler
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        onTapped: Visibilities.toggleSettings()
    }
}
