import QtQuick
import Quickshell
import qs.Components
import qs.Modules.Notifications
import qs.Services

// Window wrapper: NotificationCenter has no surface of its own.
PopupWindow {
    id: panel

    color: "transparent"

    implicitWidth: container.width
    implicitHeight: {
        const win = anchor.window;
        return (win && win.screen) ? Math.max(400, win.screen.height - win.height - 12) : 800;
    }

    mask: Region {
        item: container
    }

    visible: Visibilities.notificationCenter

    PopupGrab {
        popup: panel
        onDismissed: Visibilities.notificationCenter = false
    }

    PopupCard {
        id: container

        width: center.implicitWidth + padding * 2

        shown: Visibilities.notificationCenter
        onDismissed: Visibilities.notificationCenter = false

        NotificationCenter {
            id: center
            width: parent.width
            maxHeight: panel.implicitHeight
        }
    }
}
