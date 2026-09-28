import QtQuick
import qs.Components
import qs.Modules.Notifications
import qs.Services

Popup {
    id: panel

    cardWidth: 356

    panelName: "notification-center"

    NotificationCenter {
        width: parent.width
        maxHeight: panel.implicitHeight - panel.cardPadding * 2
    }
}
