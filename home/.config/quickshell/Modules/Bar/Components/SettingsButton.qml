import QtQuick
import Quickshell
import qs.Constants
import qs.Modules.Popups

Item {
    id: root

    implicitWidth: settingsIcon.implicitWidth
    implicitHeight: Theme.topBarHeight

    Text {
        id: settingsIcon
        anchors.centerIn: parent
        text: PhosphorIcons.gear
        color: hoverHandler.hovered ? Colors.on_surface : Colors.on_surface_variant
        font.pixelSize: Fonts.h5
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
        onTapped: settingsLoader.item.visible = !settingsLoader.item.visible
    }

    LazyLoader {
        id: settingsLoader
        loading: true

        SettingsPopup {
            anchor.window: root.QsWindow.window
            anchor.rect.x: root.QsWindow.window ? root.QsWindow.window.width - implicitWidth - 8 : 0
            anchor.rect.y: root.QsWindow.window ? root.QsWindow.window.height + 8 : 0
            anchor.gravity: Edges.Bottom | Edges.Right
        }
    }
}
