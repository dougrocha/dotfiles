import QtQuick
import Quickshell
import qs.Components
import qs.Constants
import qs.Services

IconButton {
    glyph: SettingsService.doNotDisturb ? PhosphorIcons.bellSlash : PhosphorIcons.bell
    active: Visibilities.notificationCenter
    activeColor: Theme.text.primary
    onTapped: Visibilities.toggleNotificationCenter()
}
