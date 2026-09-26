import QtQuick
import Quickshell
import qs.Components
import qs.Constants
import qs.Services

IconButton {
    visible: SettingsService.doNotDisturb
    glyph: PhosphorIcons.bellSlash
    tooltipText: "Do not disturb"
    onTapped: SettingsService.doNotDisturb = false
}
