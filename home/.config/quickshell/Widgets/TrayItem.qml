import "../Modules/Popups"
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray

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

    Image {
        anchors.centerIn: parent
        width: 16
        height: 16
        source: root.trayItem.icon
        visible: status === Image.Ready
    }

    TrayMenuPopup {
        id: trayMenu
        anchorItem: root
        menuOpener: menuOpener
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: event => {
            if (event.button === Qt.LeftButton) {
                root.trayItem.activate();
            } else if (event.button === Qt.RightButton && root.trayItem.hasMenu) {
                trayMenu.visible = true;
            }
        }
    }
}
