import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import qs.Constants
import qs.Modules.Popups
import qs.Services

Item {
    id: root

    property var activeTrayItem: null
    property Item activeAnchor: null

    function toggleMenu(trayItem, anchorItem) {
        const shouldClose = trayMenu.visible && activeTrayItem === trayItem;
        Visibilities.closePopups();

        if (shouldClose) {
            return;
        }

        activeTrayItem = trayItem;
        activeAnchor = anchorItem;
        trayMenu.visible = true;
    }

    function clearMenu(anchorItem) {
        if (anchorItem && activeAnchor !== anchorItem)
            return;

        trayMenu.visible = false;
        activeTrayItem = null;
        activeAnchor = null;
    }

    visible: SystemTray.items.values.length > 0
    implicitWidth: visible ? mainLayout.width : 0
    implicitHeight: Theme.topBarHeight

    RowLayout {
        id: mainLayout
        anchors.centerIn: parent
        Layout.alignment: Qt.AlignVCenter
        spacing: 4

        Repeater {
            model: SystemTray.items.values
            delegate: TrayItem {
                menuOpen: trayMenu.visible && root.activeTrayItem === trayItem
                onMenuRequested: (trayItem, anchorItem) => root.toggleMenu(trayItem, anchorItem)
                onDisappearing: anchorItem => root.clearMenu(anchorItem)
            }
        }
    }

    QsMenuOpener {
        id: menuOpener
        menu: root.activeTrayItem ? root.activeTrayItem.menu : null
    }

    TrayMenuPopup {
        id: trayMenu
        anchorItem: root.activeAnchor
        menuOpener: menuOpener
    }
}
