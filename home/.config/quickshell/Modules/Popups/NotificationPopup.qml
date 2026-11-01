import QtQuick
import qs.Components
import qs.Modules.Notifications
import qs.Services

Popup {
    id: panel

    panelName: Visibilities.names.notifications
    onOpened: center.reset()

    NotificationCenter {
        id: center

        width: parent.width
    }
}
