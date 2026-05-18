import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs.Modules.Popups

Rectangle {
    id: root

    property var trayItem: modelData

    Layout.preferredWidth: 24
    Layout.preferredHeight: 24
    radius: 4
    color: "transparent"

    QsMenuOpener {
        id: menuOpener
        menu: root.trayItem.menu
    }

    IconImage {
        anchors.centerIn: parent
        width: 16
        height: 16
        source: root.trayItem.icon
        visible: status === Image.Ready
        mipmap: true
    }

    TrayMenuPopup {
        id: trayMenu
        anchorItem: root
        menuOpener: menuOpener
    }

    HoverHandler {
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        acceptedButtons: Qt.LeftButton
        onTapped: root.trayItem.activate()
    }

    TapHandler {
        acceptedButtons: Qt.RightButton
        onTapped: {
            if (root.trayItem.hasMenu)
                trayMenu.visible = true;
        }
    }
}
