import QtQuick
import Quickshell
import qs.Components
import qs.Constants
import qs.Services

IconButton {
    glyph: SettingsService.doNotDisturb ? PhosphorIcons.bellSlash : PhosphorIcons.bell
    active: Visibilities.notificationCenter
    activeColor: Theme.text.primary
    tooltipText: SettingsService.doNotDisturb ? "Notifications: Do not disturb" : "Notifications"
    onTapped: Visibilities.toggleNotificationCenter()
}
