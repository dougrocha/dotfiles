import QtQuick
import Quickshell
import qs.Constants
import qs.Services

Item {
    id: root

    implicitWidth: clock.implicitWidth
    implicitHeight: Theme.topBarHeight

    Text {
        id: clock
        anchors.centerIn: parent
        text: Qt.formatDateTime(new Date(), "h:mmAP")
        color: (Visibilities.notificationCenter || hoverHandler.hovered) ? Colors.on_surface : Colors.on_surface_variant
        renderType: Text.NativeRendering
        font.pixelSize: Fonts.p
        font.family: Fonts.font
        font.weight: Font.Light
        font.letterSpacing: 1

        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: clock.text = Qt.formatDateTime(new Date(), "h:mmAP")
        }

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
        onTapped: Visibilities.notificationCenter = !Visibilities.notificationCenter
    }
}
