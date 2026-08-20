import QtQuick
import Quickshell
import qs.Constants
import qs.Services

// Opens the notification center (NotificationPopup); the island owns the clock now.
Item {
    id: root

    implicitWidth: bellIcon.implicitWidth
    implicitHeight: Theme.topBarHeight

    Text {
        id: bellIcon
        anchors.centerIn: parent
        text: SettingsService.doNotDisturb ? PhosphorIcons.bellSlash : PhosphorIcons.bell
        color: (Visibilities.notificationCenter || hoverHandler.hovered) ? Colors.on_surface : Colors.on_surface_variant
        font.pixelSize: Fonts.p
        font.family: Fonts.phosphorFont
        Behavior on color {
            ColorAnimation {
                duration: Theme.animations.fast
            }
        }
    }

    HoverHandler {
        id: hoverHandler
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        onTapped: Visibilities.toggleNotificationCenter()
    }
}
