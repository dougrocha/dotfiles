import QtQuick
import Quickshell
import qs.Constants
import qs.Modules.Popups
import qs.Widgets

Item {
    id: root

    implicitWidth: clock.implicitWidth
    implicitHeight: Theme.topBarHeight

    Text {
        id: clock
        anchors.centerIn: parent
        text: Qt.formatDateTime(new Date(), "h:mmAP")
        color: hoverHandler.hovered ? Colors.on_surface : Colors.on_surface_variant
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
            ColorAnimation { duration: 150 }
        }
    }

    HoverHandler {
        id: hoverHandler
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        onTapped: calendarLoader.item.visible = !calendarLoader.item.visible
    }

    LazyLoader {
        id: calendarLoader
        loading: true

        CalendarPopup {
            anchor.window: root.QsWindow.window
            anchor.rect.x: root.QsWindow.window ? root.QsWindow.window.width - implicitWidth - 8 : 0
            anchor.rect.y: root.QsWindow.window ? root.QsWindow.window.height + 8 : 0
            anchor.gravity: Edges.Bottom | Edges.Right
        }
    }
}
